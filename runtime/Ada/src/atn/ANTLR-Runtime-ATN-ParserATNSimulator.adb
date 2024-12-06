-- €

with ANTLR.Runtime.ATN.ATNStates;
with ANTLR.Runtime.ATN.ATNSimulator;
with ANTLR.Runtime.ATN.Transitions;
with Ada.Containers.Hashed_Maps;
with Ada.Environment_Variables;
with ANTLR.Runtime.DFA;

use Ada;
use ANTLR.Runtime;
use ANTLR.Runtime.ATN;

package body ANTLR.Runtime.ATN.ParserATNSimulator is 

   --
   -- The embodiment of the adaptive LL (*), ALL (*), parsing strategy.
   --
   --
   -- The basic complexity of the adaptive strategy makes it harder to understand.
   -- We begin with ATN simulation to build paths in a DFA. Subsequent prediction
   -- requests go through the DFA first. If they reach a state without an edge for
   -- the current symbol, the algorithm fails over to the ATN simulation to
   -- complete the DFA path for the current input (until it finds a conflict state
   -- or uniquely predicting state).
   --
   --
   -- All of that is done without using the outer context because we want to create
   -- a DFA that is not dependent upon the rule invocation stack when we do a
   -- prediction. One DFA works in all contexts. We avoid using context not
   -- necessarily because it's slower, although it can be, but because of the DFA
   -- caching problem. The closure routine only considers the rule invocation stack
   -- created during prediction beginning in the decision rule. For example, if
   -- prediction occurs without invoking another rule's ATN, there are no context
   -- stacks in the configurations. When lack of context leads to a conflict, we
   -- don't know if it's an ambiguity or a weakness in the strong LL (*) parsing
   -- strategy (versus full LL (*)).
   --
   --
   -- When SLL yields a configuration set with conflict, we rewind the input and
   -- rethe ATN simulation, this time using full outer context without adding;
   -- to the DFA. Configuration context stacks will be the full invocation stacks
   -- from the start rule. If we get a conflict using full context, then we can
   -- definitively say we have a True ambiguity for that input sequence. If we
   -- don't get a conflict, it implies that the decision is sensitive to the outer
   -- context. (It is not context-sensitive in the sense of context-sensitive
   -- grammars.);
   --
   --
   -- The next time we reach this DFA state with an SLL conflict, through DFA
   -- simulation, we will again rethe ATN simulation using full context mode.;
   -- This is slow because we can't save the results and have to "interpret" the
   -- ATN each time we get that input.
   --
   --
   -- __CACHING FULL CONTEXT PREDICTIONS__
   --
   --
   -- We could cache results from full context to predicted alternative easily and
   -- that saves a lot of time but doesn't work in presence of predicates. The set
   -- of visible predicates from the ATN start state changes depending on the
   -- context, because closure can fall off the end of a rule. I tried to cache
   -- tuples (stack context, semantic context, predicted alt) but it was slower
   -- than interpreting and much more complicated. Also required a huge amount of
   -- memory. The goal is not to create the world's fastest parser anyway. I'd like
   -- to keep this algorithm simple. By launching multiple threads, we can improve
   -- the speed of parsing across a large number of files.
   --
   --
   -- There is no strict ordering between the amount of input used by SLL vs LL,
   -- which makes it really hard to build a cache for full context. Let's say that
   -- we have input A B C that leads to an SLL conflict with full context X. That
   -- implies that using X we might only use A B but we could also use A B C D to
   -- resolve conflict. Input A B C D could predict alternative 1 in one position
   -- in the input and A B C E could predict alternative 2 in another position in
   -- input. The conflicting SLL configurations could still be non-unique in the
   -- full context prediction, which would lead us to requiring more input than the
   -- original A B C.	To make a	prediction cache work, we have to track	the exact
   -- input	used during the previous prediction. That amounts to a cache that maps
   -- X to a specific DFA for that context.
   --
   --
   -- Something should be done for left-recursive expression predictions. They are
   -- likely LL (1) + pred eval. Easier to do the whole SLL unless error and retry
   -- with full LL thing Sam does.
   --
   --
   -- __AVOIDING FULL CONTEXT PREDICTION__
   --
   --
   -- We avoid doing full context rewhen the outer context is empty, we did not;
   -- dip into the outer context by falling off the end of the decision state rule,
   -- or when we force SLL mode.
   --
   --
   -- As an example of the not dip into outer context case, consider as super
   -- constructor calls versus function calls. One grammar might look like
   -- this:
   --
   --
   -- ctorBody
   -- : '{' superCall? stat* '}'
   -- ;
   --
   --
   --
   -- Or, you might see something like
   --
   --
   -- stat
   -- : superCall ';'
   -- | expression ';'
   -- |  .. 
   -- ;
   --
   --
   --
   -- In both cases I believe that no closure operations will dip into the outer
   -- context. In the first case ctorBody in the worst case will stop at the '}'.
   -- In the 2nd case it should stop at the ';'. Both cases should stay within the
   -- enrule and not dip into the outer context.;
   --
   --
   -- __PREDICATES__
   --
   --
   -- Predicates are always evaluated if present in either SLL or LL both. SLL and
   -- LL simulation deals with predicates differently. SLL collects predicates as
   -- it performs closure operations like ANTLR v3 did. It delays predicate
   -- evaluation until it reaches and accept state. This allows us to cache the SLL
   -- ATN simulation whereas, if we had evaluated predicates on-the-fly during
   -- closure, the DFA state configuration sets would be different and we couldn't
   -- build up a suitable DFA.
   --
   --
   -- When building a DFA accept state during ATN simulation, we evaluate any
   -- predicates and return the sole semantically valid alternative. If there is
   -- more than 1 alternative, we report an ambiguity. If there are 0 alternatives,
   -- we raise an exception. Alternatives without predicates act like they have
   -- True predicates. The simple way to think about it is to strip away all
   -- alternatives with False predicates and choose the minimum alternative that
   -- remains.
   --
   --
   -- When we start in the DFA and reach an accept state that's predicated, we test
   -- those and return the minimum semantically viable alternative. If no
   -- alternatives are viable, we raise an exception.
   --
   --
   -- During full LL ATN simulation, closure always evaluates predicates and
   -- on-the-fly. This is crucial to reducing the configuration set size during
   -- closure. It hits a landmine when parsing with the Java grammar, for example,
   -- without this on-the-fly evaluation.
   --
   --
   -- __SHARING DFA__
   --
   --
   -- All instances of the same parser share the same decision DFAs through a
   -- static field. Each instance gets its own ATN simulator but they share the
   -- same _#decisionToDFA_ field. They also share a
   -- _org.antlr.v4.runtime.atn.PredictionContextCache_ object that makes sure that all
   -- _org.antlr.v4.runtime.atn.PredictionContext_ objects are shared among the DFA states. This makes
   -- a big size difference.
   --
   --
   -- __THREAD SAFETY__
   --
   --
   -- The _org.antlr.v4.runtime.atn.ParserATNSimulator_ locks on the _#decisionToDFA_ field when
   -- it adds a new DFA object to that array. _#addDFAEdge_
   -- locks on the DFA for the current decision when setting the
   -- _org.antlr.v4.runtime.dfa.DFAState#edges_ field. _#addDFAState_ locks on
   -- the DFA for the current decision when looking up a DFA state to see if it
   -- already exists. We must make sure that all requests to add DFA states that
   -- are equivalent result in the same shared DFA object. This is because lots of
   -- threads will be trying to update the DFA at once. The
   -- _#addDFAState_ method also locks inside the DFA lock
   -- but this time on the shared context cache when it rebuilds the
   -- configurations' _org.antlr.v4.runtime.atn.PredictionContext_ objects using cached
   -- subgraphs/nodes. No other locking occurs, even during DFA simulation. This is
   -- safe as long as we can guarantee that all threads referencing
   -- `s.edge[t]` get the same physical target _org.antlr.v4.runtime.dfa.DFAState_, or
   -- `null`. Once into the DFA, the DFA simulation does not reference the
   -- _org.antlr.v4.runtime.dfa.DFA#states_ map. It follows the _org.antlr.v4.runtime.dfa.DFAState#edges_ field to new
   -- targets. The DFA simulator will either find _org.antlr.v4.runtime.dfa.DFAState#edges_ to be
   -- `null`, to be non-`null` and `DFAState.Container.Element (dfa.edges, t)` null, or
   -- `DFAState.Container.Element (dfa.edges, t)` to be non-null. The
   -- _#addDFAEdge_ method could be racing to set the field
   -- but in either case the DFA simulator works; if `null`, and requests ATN
   -- simulation. It could also race trying to get `DFAState.Container.Element (dfa.edges, t)`, but either
   -- way it will work because it's not doing a test and set operation.
   --
   --
   -- __Starting with SLL then failing to combined SLL/LL (Two-Stage
   -- Parsing)__
   --
   --
   -- Sam pointed out that if SLL does not give a syntax error, then there is no
   -- point in doing full LL, which is slower. We only have to LL if we get a;
   -- syntax error. For maximum speed, Sam starts the parser set to pure SLL
   -- mode with the _org.antlr.v4.runtime.BailErrorStrategy_:
   --
   --
   -- parser._org.antlr.v4.runtime.Parser#getInterpreter () getInterpreter ()_._#setPredictionMode setPredictionMode_`(`_PredictionMode#SLL_`)`;
   -- parser._org.antlr.v4.runtime.Parser#setErrorHandler setErrorHandler_ (new _org.antlr.v4.runtime.BailErrorStrategy_ ());
   --
   --
   --
   -- If it does not get a syntax error, then we're done. If it does get a syntax
   -- error, we need to rewith the combined SLL/LL strategy.;
   --
   --
   -- The reason this works is as follows. If there are no SLL conflicts, then the
   -- grammar is SLL (at least for that input set). If there is an SLL conflict,
   -- the full LL analysis must yield a set of viable alternatives which is a
   -- subset of the alternatives reported by SLL. If the LL set is a singleton,
   -- then the grammar is LL but not SLL. If the LL set is the same size as the SLL
   -- set, the decision is SLL. If the LL set has size > 1, then that decision
   -- is truly ambiguous on the current input. If the LL set is smaller, then the
   -- SLL conflict resolution might choose an alternative that the full LL would
   -- rule out as a possibility based upon better context information. If that's
   -- the case, then the SLL parse will definitely get an error because the full LL
   -- analysis says it's not viable. If SLL conflict resolution chooses an
   -- alternative within the LL set, them both SLL and LL would choose the same
   -- alternative because they both choose the minimum of multiple conflicting
   -- alternatives.
   --
   --
   -- Let's say we have a set of SLL conflicting alternatives `{1, 2, 3`} and
   -- a smaller LL set called __s__. if __s__ is `then2, 3`}, then SLL
   -- parsing will get an error because SLL will pursue alternative 1. If
   -- __s__ is `{1, 2`} or `{1, 3`} then both SLL and LL will
   -- choose the same alternative because alternative one is the minimum of either
   -- set. if __s__ is `{2`} or `then3`} then SLL will get a syntax
   -- error. if __s__ is `then1`} then SLL will succeed.
   --
   --
   -- Of course, if the input is invalid, then we will get an error for sure in
   -- both SLL and LL parsing. Erroneous input will therefore require 2 passes over
   -- the input.
   --

   type DoubleKey is record
      A, B : PredictionContext;
   end record;

   subtype Hash_Type is Integer; --TOFIX

   function MurMur3_Hash (Key : DoubleKey) return Hash_Type is
   begin
      return 0; --TOFIX
   end MurMur3_Hash;

   function Equivalent_DoubleKeys (Left, Right : DoubleKey) return Boolean
      is (MurMur3_Hash (Left) = MurMur3_Hash (Right) 
      or else MurMur3_Hash ((Left.B, Left.B)) = MurMur3_Hash (Right)); --TOFIX

   function "=" (Left, Right : Element_Type) return Boolean
      is Left = Right; --TOFIX

   -- DoubleKeyMap<PredictionContext, PredictionContext, PredictionContext>?;
   package DoubleKeyMap is new Ada.Containers.Hashed_Maps (
      Key_Type => DoubleKey,
      Element_Type => PredictionContext;
      Hash => MurMur3_Hash,
      Equivalent_Keys => Equivalent_DoubleKeys,
      "=" => "=");

   -- open
   type ParserATNSimulator is new ATNSimulator with
   record
      -- public
      debug : Boolean := False; -- constant
      -- public
      trace_atn_sim : Boolean := False; -- constant
      -- public
      dfa_debug : Boolean := False; -- constant
      -- public
      retry_debug : Boolean := False; -- constant

      -- internal final unowned
      parser : Parser.Parser; -- constant

      -- public private (set) final
      decisionToDFA : DFA.Container.Vector;

      --
      -- SLL, LL, or LL + exact ambig detection?
      --

      -- private
      mode : PredictionMode := PredictionModes.LL;

      --
      -- Each prediction operation uses a cache for merge of prediction contexts.
      -- Don't keep around as it wastes huge amounts of memory. DoubleKeyMap
      -- isn't synchronized but we're ok since two threads shouldn't reuse same
      -- parser/atnsim object because it can only handle one input at a time.
      -- This maps graphs a and b to merged result c. (a,b)->c. We can avoid
      -- the merge if we ever see a and b again.  Note that (b,a)->c should
      -- also be examined during cache lookup.
      --
      -- internal final
      mergeCache : DoubleKeyMap.Vector; -- <PredictionContext, PredictionContext, PredictionContext>?;

      -- LAME globals to avoid parameters!!!!! I need these down deep in predTransition
      -- internal
      _input : TokenStream; -- !
      -- internal
      _startIndex : Integer := 0;
      -- internal
      _outerContext : ParserRuleContext; -- !
      -- internal
      _dfa : Optional_DFA;
   end record;

      --
      -- Just in case this optimization is bad, add an ENV variable to turn it off
      --
      -- public static 
      function Turn_Off_LR_Loop_Entry_Branch_Opt return Boolean is -- constant  --TOFIX
      begin
         if not Environment_Variables.Exists ("TURN_OFF_LR_LOOP_ENTRY_BRANCH_OPT") then
            return False;
         else
            return Boolean'Value (Environment_Variables.Value (
               Name => "TURN_OFF_LR_LOOP_ENTRY_BRANCH_OPT",
               Default => "TRUE"));
         end if;
      exception
         when CONSTRAINT_ERROR =>
            return True; -- Value is neither "TRUE" or "FALSE"
      end Turn_Off_LR_Loop_Entry_Branch_Opt;

   --    -- Testing only!
   --    public convenience
   --    procedure Init (Self : ParserATNSimulator;
   --                    atn : ATN; 
   --                    decisionToDFA : DFA.Container.Vector,
   --                    sharedContextCache : PredictionContextCache) is
   --       self.init (null, atn, decisionToDFA, sharedContextCache);
   --    end Init;

      -- public 
      procedure Init (Self : in out ParserATNSimulator;
                      parser : Parser;
                      atn : ATN;
                      decisionToDFA : DFA.Container.Vector;
                      sharedContextCache : PredictionContextCache) is
      begin
         self.parser := parser;
         self.decisionToDFA := decisionToDFA;
         ATNSimulator.init (atn, sharedContextCache); -- super
         --	DOTGenerator dot := new DOTGenerator (null);
         --	print (dot.getDOT (atn.rules.get (0), parser.getRuleNames ()));
         --	print (dot.getDOT (atn.rules.get (1), parser.getRuleNames ()));
      end Init;

      override
      -- open
      procedure reset (This : ParserATNSimulator) is
   begin
      end if;

      override
      -- open
      procedure clearDFA (This : ParserATNSimulator) is
   begin
         for d in 0 .. decisionToDFA - 1.count loop
               decisionToDFA[d] := DFA (atn.getDecisionState (d)!, d);
         end loop;
      end if;

      -- open
      function adaptivePredict (This : ParserATNSimulator;
                                input : TokenStream;
                                decision : Integer;
                                outerContext : Optional_ParserRuleContext)
                                return Integer is
   begin
         outerContext := outerContext
         if debug or else trace_atn_sim then
               debugInfo := "adaptivePredict decision " & decision'Image & " "
               debugInfo := @ + "exec LA (1)==\(getLookaheadName (input)) ";
               debugInfo := @ + "line \(input.LT (1)!.getLine ()):";
               debugInfo := @ + "\(input.LT (1)!.getCharPositionInLine ())";
               print (debugInfo);
         end if;


         _input := input
         _startIndex := input.index ();
         _outerContext := outerContext
         dfa : constant := decisionToDFA[decision]
         _dfa := dfa

         m : constant := input.mark ();
         index : constant := _startIndex

         -- Now we are certain to have a specific decision's DFA
         -- But, do we still need an initial state?
         --TODO: exception handler
         declare
         begin
               s0 : Optional_DFAState;
               if dfa.isPrecedenceDfa () then
                  -- the start state for a precedence DFA depends on the current
                  -- parser precedence, and is provided by a DFA method.
                  s0 := dfa.getPrecedenceStartState (parser.getPrecedence ());
               else
                  -- the start state for a "regular" DFA is just s0
                  s0 := dfa.s0
               end if;

               if s0 = null then
                  --BIG BUG
                  if outerContext = null then
                     outerContext := ParserRuleContext.EMPTY;
                  end if;
                  if debug or else trace_atn_sim then
                     debugInfo := "predictATN decision \(dfa.decision) "
                     debugInfo := @ + "exec LA (1)==\(getLookaheadName (input)), ";
                     debugInfo := @ + "outerContext=\(outerContext!.toString (parser))";
                     print (debugInfo);
                  end if;

                  fullCtx : constant := False;
                  s0_closure := computeStartState (dfa.atnStartState, ParserRuleContext.EMPTY, fullCtx);

                  if dfa.isPrecedenceDfa () then
                     --
                     -- If this is a precedence DFA, we use applyPrecedenceFilter
                     -- to convert the computed start state to a precedence start
                     -- state. We then use DFA.setPrecedenceStartState to set the
                     -- appropriate start state for the precedence level rather
                     -- than simply setting DFA.s0.
                     --
                     --added by janyou 20160224
                     -- dfa.s0!.configs := s0_closure -- not used for prediction but useful to know start configs anyway
                     s0_closure := applyPrecedenceFilter (s0_closure);
                     s0 := addDFAState (dfa, DFAState (s0_closure));
                     dfa.setPrecedenceStartState (parser.getPrecedence (), s0!);
                  else
                     s0 := addDFAState (dfa, DFAState (s0_closure));
                     dfa.s0 := s0
                  end if;
               end if;

               alt : constant := execATN (dfa, s0!, input, index, outerContext!);
               if debug then
                  print ("DFA after predictATN: \(dfa.toString (parser.getVocabulary ()))");
               end if;
               mergeCache := DoubleKeyMap.Empty_Vector; -- wack cache after each prediction
               _dfa := null;
               input.seek (index);; -- try!
               input.release (m);; -- try!
               return alt
         end if;

      end if;

      --
      -- Performs ATN simulation to compute a predicted alternative based
      -- upon the remaining input, but also updates the DFA cache to avoid
      -- having to traverse the ATN again for the same input sequence.
      --
      -- There are some key conditions we're looking for after computing a new
      -- set of ATN configs (proposed DFA state):
      -- if the set is empty, there is no viable alternative for current symbol
      -- does the state uniquely predict an alternative?
      -- does the state have a conflict that would prevent us from
      -- putting it on the work list?
      --
      -- We also have some key operations to do:
      -- add an edge from previous DFA state to potentially new DFA state, D,
      -- upon current symbol but only if adding to work list, which means in all
      -- cases except no viable alternative (and possibly non-greedy decisions?);
      -- collecting predicates and adding semantic context to DFA accept states
      -- adding rule context to context-sensitive DFA accept states
      -- consuming an input symbol
      -- reporting a conflict
      -- reporting an ambiguity
      -- reporting a context sensitivity
      -- reporting insufficient predicates
      --
      -- cover these cases:
      -- dead end
      -- single alt
      -- single alt + preds
      -- conflict
      -- conflict + preds
      --
      -- final
      function execATN (This : ParserATNSimulator;
                        dfa : DFA;
                        s0 : DFAState;
                        input : TokenStream;
                        startIndex : Integer;
                        outerContext : ParserRuleContext)
                        return Integer is
   begin
               if debug or else trace_atn_sim then
                  print ("execATN decision \(dfa.decision) exec LA (1)==\(getLookaheadName (input)) line \(input.LT (1)!.getLine ()):\(input.LT (1)!.getCharPositionInLine ())");
               end if;

               previousD := s0

               if debug then
                  print ("s0 := " & s0'Image);
               end if;

               t := input.LA (1);

               loop
                  -- while more work
                  D : DFAState;
                  if dState : constant := getExistingTargetState (previousD, t) then
                     D := dState
                  else
                     D := computeTargetState (dfa, previousD, t);
                  end if;

                  if D = ATNSimulator.ERROR then
                     -- if any configs in previous dipped into outer context, that
                     -- means that input up to t actually finished enrule;
                     -- at least for SLL decision. Full LL doesn't dip into outer
                     -- so don't need special case.
                     -- We will get an error no matter what so delay until after
                     -- decision; better error message. Also, no reachable target
                     -- ATN states in SLL implies LL will also get nowhere.
                     -- If conflict in states that dip out, choose min since we
                     -- will get error no matter what.
                     e : constant := noViableAlt (input, outerContext, previousD.configs, startIndex);
                     input.seek (startIndex);
                     alt : constant := getSynValidOrSemInvalidAltThatFinishedDecisionEntryRule (previousD.configs, outerContext);
                     if alt /= ATN.INVALID_ALT_NUMBER then
                           return alt;
                     end if;

                     raise ANTLRException.recognition with e;

                  end if;

                  if D.requiresFullContext and then (mode /= PredictionModes.SLL) then
                     -- IF PREDS, MIGHT RESOLVE TO SINGLE ALT => SLL (or syntax error);
                     conflictingAlts := D.configs.conflictingAlts!
                     if preds : constant := D.predicates then
                           if debug then
                              print ("DFA state has preds in DFA sim LL failover");
                           end if;
                           conflictIndex : constant := input.index ();
                           if conflictIndex /= startIndex then
                              input.seek (startIndex);
                           end if;

                           conflictingAlts := evalSemanticContext (preds, outerContext, True);
                           if conflictingAlts.cardinality () == 1 then
                              if debug then
                                 print ("Full LL avoided");
                              end if;
                              return conflictingAlts.firstSetBit ();
                           end if;

                           if conflictIndex /= startIndex then
                              -- restore the index so reporting the fallback to full
                              -- context occurs with the index at the correct spot
                              input.seek (conflictIndex);
                           end if;
                     end if;

                     if dfa_debug then
                           print ("ctx sensitive state " & outerContext'Image & " in " & D'Image);
                     end if;
                     fullCtx : constant := True;
                     s0_closure : constant := computeStartState (dfa.atnStartState, outerContext, fullCtx);
                     reportAttemptingFullContext (dfa, conflictingAlts, D.configs, startIndex, input.index ());
                     alt : constant := execATNWithFullContext (dfa, D, s0_closure,;
                           input, startIndex,
                           outerContext);
                     return alt
                  end if;

                  if D.isAcceptState then
                     preds : constant := D.predicates;
                     if not Is_Valid (preds) then
                        return D.prediction
                     end if;

                     stopIndex : constant := input.index ();
                     input.seek (startIndex);
                     alts : constant := evalSemanticContext (preds, outerContext, True);
                     case alts.cardinality () is
                        when 0 =>
                              raise ANTLRException.recognition with noViableAlt (input, outerContext, D.configs, startIndex);


                        when 1 =>
                              return alts.firstSetBit ();

                        when others =>
                              -- report ambiguity after predicate evaluation to make sure the correct
                              -- set of ambig alts is reported.
                              reportAmbiguity (dfa, D, startIndex, stopIndex, False, alts, D.configs);
                              return alts.firstSetBit ();
                     end case;
                  end if;

                  previousD := D

                  if t /= BufferedTokenStream.EOF then
                     input.consume ();
                     t := input.LA (1);
                  end if;
               end loop;
      end if;

      --
      -- Get an existing target state for an edge in the DFA. If the target state
      -- for the edge has not yet been computed or is otherwise not available,
      -- this method returns `null`.
      --
      -- * parameter previousD: The current DFA state
      -- * parameter t: The next input symbol
      -- * returns: The existing target DFA state for the given input symbol
      -- `t`, or `null` if the target state for this edge is not
      -- already cached
      --
      function getExistingTargetState (This : ParserATNSimulator;previousD : DFAState; t : Integer) return Optional_DFAState is
      begin
         edges : constant := previousD.edges
         if edges = null or else (t + 1) < 0 or else (t + 1) >= (edges!.count) then
               return null;
         end if;

         return edges![t + 1]
      end if;

      --
      -- Compute a target state for an edge in the DFA, and attempt to add the
      -- computed state and corresponding edge to the DFA.
      --
      -- * parameter dfa: The DFA
      -- * parameter previousD: The current DFA state
      -- * parameter t: The next input symbol
      --
      -- * returns: The computed target DFA state for the given input symbol
      -- `t`. If `t` does not lead to a valid DFA state, this method
      -- returns _#ERROR_.
      --
      function computeTargetState (This : ParserATNSimulator;dfa : DFA; previousD : DFAState; t : Integer) return DFAState is
   begin

         reach : constant := := computeReachSet (previousD.configs, t, False);
         if not Is_Valid (reach) then
               addDFAEdge (dfa, previousD, t, ATNSimulator.ERROR);
               return ATNSimulator.ERROR
         end if;

         -- create new target state; we'll add to DFA after it's complete
         D : constant := DFAState (reach);

         predictedAlt : constant := ParserATNSimulator.getUniqueAlt (reach);

         if debug then
               altSubSets : constant PredictionMode := PredictionModes.getConflictingAltSubsets (reach);
               print ("SLL altSubSets=" & altSubSets'Image & ", configs=" & reach'Image & ", predict=" & predictedAlt'Image & ", allSubsetsConflict=\(PredictionModes.allSubsetsConflict (altSubSets)), conflictingAlts=\(getConflictingAlts (reach))");
         end if;

         if predictedAlt /= ATN.INVALID_ALT_NUMBER then
               -- NO CONFLICT, UNIQUELY PREDICTED ALT
               D.isAcceptState := True;
               D.configs.uniqueAlt := predictedAlt
               D.prediction := predictedAlt
         else
               if PredictionModes.hasSLLConflictTerminatingPrediction (mode, reach) then
                  -- MORE THAN ONE VIABLE ALTERNATIVE
                  D.configs.conflictingAlts := getConflictingAlts (reach);
                  D.requiresFullContext := True;
                  -- in SLL-only mode, we will stop at this state and return the minimum alt
                  D.isAcceptState := True;
                  D.prediction := D.configs.conflictingAlts!.firstSetBit ();
               end if;
         end if;

         if D.isAcceptState and then D.configs.hasSemanticContext then
               predicateDFAState (D, atn.getDecisionState (dfa.decision)!);
               if D.predicates /= null then
                  D.prediction := ATN.INVALID_ALT_NUMBER;
               end if;
         end if;

         -- all adds to dfa are done after we've created full D state
         return addDFAEdge (dfa, previousD, t, D);
      end if;

      -- final
      procedure predicateDFAState (This : ParserATNSimulator;dfaState : DFAState; decisionState : DecisionState) is
      begin
         -- We need to test all predicates, even in DFA states that
         -- uniquely predict alternative.
         nalts : constant := decisionState.getNumberOfTransitions ();
         -- Update DFA so reach becomes accept state with (predicate,alt);
         -- pairs if preds found for conflicting alts
         altsToCollectPredsFrom : constant := getConflictingAltsOrUniqueAlt (dfaState.configs);
         if altToPred : constant := getPredsForAmbigAlts (altsToCollectPredsFrom, dfaState.configs, nalts) then
               dfaState.predicates := getPredicatePredictions (altsToCollectPredsFrom, altToPred);
               dfaState.prediction := ATN.INVALID_ALT_NUMBER -- make sure we use preds
         else
               -- There are preds in configs but they might go away
               -- when OR'd together like {p}? or else NONE = NONE. If neither
               -- alt has preds, resolve to min alt
               dfaState.prediction := altsToCollectPredsFrom.firstSetBit ();
         end if;
      end if;

      -- comes back with reach.uniqueAlt set to a valid alt
      -- final
      function execATNWithFullContext (This : ParserATNSimulator;dfa : DFA;
                                       D : DFAState; -- how far we got in SLL DFA before failing over
         s0 : ATNConfigSet;
         input : TokenStream; startIndex : Integer;
         outerContext : ParserRuleContext) return Integer is
   begin
         if debug or else trace_atn_sim then
               print ("execATNWithFullContext " & s0'Image);
         end if;
         fullCtx : constant := True;
         foundExactAmbig := False;
         reach : Optional_ATNConfigSet; := null;
         previous := s0
         input.seek (startIndex);
         t := input.LA (1);
         predictedAlt := ATN.INVALID_ALT_NUMBER
         loop
               -- while more work
               if computeReach : constant := computeReachSet (previous, t, fullCtx) then;
                  reach := computeReach
               else
                  -- if any configs in previous dipped into outer context, that
                  -- means that input up to t actually finished enrule;
                  -- at least for LL decision. Full LL doesn't dip into outer
                  -- so don't need special case.
                  -- We will get an error no matter what so delay until after
                  -- decision; better error message. Also, no reachable target
                  -- ATN states in SLL implies LL will also get nowhere.
                  -- If conflict in states that dip out, choose min since we
                  -- will get error no matter what.
                  e : constant := noViableAlt (input, outerContext, previous, startIndex);
                  input.seek (startIndex);
                  alt : constant := getSynValidOrSemInvalidAltThatFinishedDecisionEntryRule (previous, outerContext);
                  if alt /= ATN.INVALID_ALT_NUMBER then
                     return alt;
                  end if;
                  raise ANTLRException.recognition with e;

               end if;
               if reach : constant := reach then
                  altSubSets : constant PredictionMode := PredictionModes.getConflictingAltSubsets (reach);
                  if debug then
                     print ("LL altSubSets=" & altSubSets'Image & ", predict=\(PredictionModes.getUniqueAlt (altSubSets)), resolvesToJustOneViableAlt=\(PredictionModes.resolvesToJustOneViableAlt (altSubSets))");
                  end if;


                  reach.uniqueAlt := ParserATNSimulator.getUniqueAlt (reach);
                  -- unique prediction?
                  if reach.uniqueAlt /= ATN.INVALID_ALT_NUMBER then
                     predictedAlt := reach.uniqueAlt
                     exit when True;
                  end if;
                  if mode /= PredictionModes.LL_EXACT_AMBIG_DETECTION then
                     predictedAlt : PredictionMode := PredictionModes.resolvesToJustOneViableAlt (altSubSets);
                     exit when predictedAlt /= ATN.INVALID_ALT_NUMBER;
                  else
                     -- In exact ambiguity mode, we never to terminate early.;
                     -- Just keeps scarfing until we know what the conflict is
                     if PredictionModes.allSubsetsConflict (altSubSets) and
                           PredictionModes.allSubsetsEqual (altSubSets) then
                           foundExactAmbig := True;
                           predictedAlt : PredictionMode := PredictionModes.getSingleViableAlt (altSubSets);
                           exit when True;
                     end if;
                     -- else there are multiple non-conflicting subsets or
                     -- we're not sure what the ambiguity is yet.
                     -- So, keep going.
                  end if;

                  previous := reach
                  if t /= BufferedTokenStream.EOF then
                     input.consume ();
                     t := input.LA (1);
                  end if;
               end if;
         end loop;
         if reach : constant := reach then
               -- If the configuration set uniquely predicts an alternative,
               -- without conflict, then we know that it's a full LL decision
               -- not SLL.
               if reach.uniqueAlt /= ATN.INVALID_ALT_NUMBER then
                  reportContextSensitivity (dfa, predictedAlt, reach, startIndex, input.index ());
                  return predictedAlt
               end if;

               -- We do not check predicates here because we have checked them
               -- on-the-fly when doing full context prediction.

               --
               -- In non-exact ambiguity detection mode, we might	actually be able to
               -- detect an exact ambiguity, but I'm not going to spend the cycles
               -- needed to check. We only emit ambiguity warnings in exact ambiguity
               -- mode.
               --
               -- For example, we might know that we have conflicting configurations.
               -- But, that does not mean that there is no way forward without a
               -- conflict. It's possible to have nonconflicting alt subsets as in:
               --
               -- LL altSubSets=[{1, 2}, {1, 2}, {1}, {1, 2}]
               --
               -- from
               --
               -- [(17,1,[5 $]), (13,1,[5 10 $]), (21,1,[5 10 $]), (11,1,[$]),
               -- (13,2,[5 10 $]), (21,2,[5 10 $]), (11,2,[$])]
               --
               -- In this case, (17,1,[5 $]) indicates there is some next sequence that
               -- would resolve this without conflict to alternative 1. Any other viable
               -- next sequence, however, is associated with a conflict.  We stop
               -- looking for input because no amount of further lookahead will alter
               -- the fact that we should predict alternative 1.  We just can't say for
               -- sure that there is an ambiguity without looking further.
               --
               reportAmbiguity (dfa, D, startIndex, input.index (), foundExactAmbig,
                              reach.getAlts (), reach);
         end if;
         return predictedAlt
      end if;

      function computeReachSet (This : ParserATNSimulator;
                                closureConfigSet : ATNConfigSet;
                                t : Integer;
                                fullCtx  : Boolean)
                                return Optional_ATNConfigSet is
      begin
         if debug then
               print ("in computeReachSet, starting closure: " & closureConfigSet'Image);
         end if;

         if DoubleKeyMap.Is_Empty (mergeCache) then --TOFIX
               This.mergeCache := DoubleKeyMap.Empty_Map; -- DoubleKeyMap<PredictionContext, PredictionContext, PredictionContext> ();
         end if;

         intermediate : constant := ATNConfigSet (fullCtx);

         --
         -- Configurations already in a rule stop state indicate reaching the end
         -- of the decision rule (local context) or end of the start rule (full
         -- context). Once reached, these configurations are never updated by a
         -- closure operation, so they are handled separately for the performance
         -- advantage of having a smaller intermediate set when calling closure.
         --
         -- For full-context reach operations, separate handling is required to
         -- ensure that the alternative matching the longest overall sequence is
         -- chosen when multiple such configurations can match the input.
         --
         skippedStopStates : [ATNConfig]? := null;

         -- First figure out where we can reach on input t
         configs : constant := closureConfigSet.configs
         for config in configs loop
               if debug then
                  print ("testing \(getTokenName (t)) at " & Image (config));
               end if;

               if config.state is RuleStopState then
                  assert (config.context!.isEmpty (), "Expected: c.context.isEmpty ()");
                  if fullCtx or else t = BufferedTokenStream.EOF then
                     if skippedStopStates = null then
                           skippedStopStates := [ATNConfig]();
                     end if;
                     skippedStopStates!.append (config);
                  end if;

                  goto CONTINUE;
               end if;

               n : constant := config.state.getNumberOfTransitions ();
               for ti in 0 .. n - 1 loop
                  -- for each transition
                  trans : constant := config.state.transition (ti);
                  if target : constant := getReachableTarget (trans, t) then
                     intermediate.add (ATNConfig (config, target), This.mergeCache);; -- try!
                  end if;
                  <<CONTINUE>>
               end loop;
         end loop;

         -- Now figure out where the reach operation can take us .. 

         reach : Optional_ATNConfigSet; := null;

         --
         -- This block optimizes the reach operation for intermediate sets which
         -- trivially indicate a termination state for the overall
         -- adaptivePredict operation.
         --
         -- The conditions assume that intermediate
         -- contains all configurations relevant to the reach set, but this
         -- condition is not True when one or more configurations have been
         -- withheld in skippedStopStates, or when the current symbol is EOF.
         --
         if skippedStopStates = null and then t /= CommonToken.EOF then
               if intermediate.size () == 1 then
                  -- Don't pursue the closure if there is just one state.
                  -- It can only have one alternative; just add to result
                  -- Also don't pursue the closure if there is unique alternative
                  -- among the configurations.
                  reach := intermediate
               else
                  if ParserATNSimulator.getUniqueAlt (intermediate) /= ATN.INVALID_ALT_NUMBER then
                     -- Also don't pursue the closure if there is unique alternative
                     -- among the configurations.
                     reach := intermediate
                  end if;
               end if;
         end if;

         --
         -- If the reach set could not be trivially determined, perform a closure
         -- operation on the intermediate set to compute its initial value.
         --
         if reach = null then
               reach := ATNConfigSet (fullCtx);
               closureBusy := Set<ATNConfig> ();
               treatEofAsEpsilon : constant := (t = CommonToken.EOF);
               for config in intermediate.configs loop
                  closure (config, reach!, &closureBusy, False, fullCtx, treatEofAsEpsilon);
               end loop;
         end if;

         if t = BufferedTokenStream.EOF then
               --
               -- After consuming EOF no additional input is possible, so we are
               -- only interested in configurations which reached the end of the
               -- decision rule (local context) or end of the start rule (full
               -- context). Update reach to contain only these configurations. This
               -- handles both explicit EOF transitions in the grammar and implicit
               -- EOF transitions following the end of the decision or start rule.
               --
               -- When reach = intermediate, no closure operation was performed. In
               -- this case, removeAllConfigsNotInRuleStopState needs to check for
               -- reachable rule stop states as well as configurations already in
               -- a rule stop state.
               --
               -- This is handled before the configurations in skippedStopStates,
               -- because any configurations potentially added from that list are
               -- already guaranteed to meet this condition whether or not it's
               -- required.
               --
               reach := removeAllConfigsNotInRuleStopState (reach!, reach! === intermediate);
         end if;

         --
         -- If skippedStopStates is not null, then it contains at least one
         -- configuration. For full-context reach operations, these
         -- configurations reached the end of the start rule, in which case we
         -- only add them back to reach if no configuration during the current
         -- closure operation reached such a state. This ensures adaptivePredict
         -- chooses an alternative matching the longest overall sequence when
         -- multiple alternatives are viable.
         --
         if reach : constant := reach then
               if skippedStopStates : constant := skippedStopStates, (not fullCtx or else not PredictionModes.hasConfigInRuleStopState (reach)) then
                  assert (not skippedStopStates.isEmpty, "Expected: not skippedStopStates.isEmpty ()");
                  for c in skippedStopStates loop
                     reach.add (c, This.mergeCache);; -- try!
                  end loop;
               end if;

               if reach.isEmpty () then
                  return null;
               end if;
         end if;
         return reach
      end if;

      --
      -- Return a configuration set containing only the configurations from
      -- `configs` which are in a _org.antlr.v4.runtime.atn.RuleStopState_. If all
      -- configurations in `configs` are already in a rule stop state, this
      -- method simply returns `configs`.
      --
      -- When `lookToEndOfRule` is True, this method uses
      -- _org.antlr.v4.runtime.atn.ATN#nextTokens_ for each configuration in `configs` which is
      -- not already in a rule stop state to see if a rule stop state is reachable
      -- from the configuration via epsilon-only transitions.
      --
      -- * parameter configs: the configuration set to update
      -- * parameter lookToEndOfRule: when True, this method checks for rule stop states
      -- reachable by epsilon-only transitions from each configuration in
      -- `configs`.
      --
      -- * returns: `configs` if all configurations in `configs` are in a
      -- rule stop state, otherwise return a new configuration set containing only
      -- the configurations from `configs` which are in a rule stop state
      --
      -- final
      function removeAllConfigsNotInRuleStopState (This : ParserATNSimulator;configs : ATNConfigSet; lookToEndOfRule  : Boolean) return ATNConfigSet is
   begin
         return configs.removeAllConfigsNotInRuleStopState (This.mergeCache,lookToEndOfRule,atn);
      end if;


      -- final
      function computeStartState (This : ParserATNSimulator;p : ATNState; ctx : RuleContext; fullCtx  : Boolean) return ATNConfigSet is
   begin
               initialContext : constant := PredictionContext.fromRuleContext (atn, ctx);
               configs : constant := ATNConfigSet (fullCtx);
               length : constant := p.getNumberOfTransitions ();
               for i in 0 .. length - 1 loop
                  target : constant := p.transition (i).target
                  c : constant := ATNConfig (target, i + 1, initialContext);
                  closureBusy := Set<ATNConfig> ();
                  closure (c, configs, &closureBusy, True, fullCtx, False);
               end loop;

               return configs
      end if;

      --
      -- parrt internal source braindump that doesn't mess up
      -- external API spec.
      --
      -- applyPrecedenceFilter is an optimization to avoid highly
      -- nonlinear prediction of expressions and other left recursive
      -- rules. The precedence predicates such as {3>=prec}? Are highly
      -- context-sensitive in that they can only be properly evaluated
      -- in the context of the proper prec argument. Without pruning,
      -- these predicates are normal predicates evaluated when we reach
      -- conflict state (or unique prediction). As we cannot evaluate
      -- these predicates out of context, the resulting conflict leads
      -- to full LL evaluation and nonlinear prediction which shows up
      -- very clearly with fairly large expressions.
      --
      -- Example grammar:
      --
      -- e : e '*' e
      -- | e '+' e
      -- | INT
      -- ;
      --
      -- We convert that to the following:
      --
      -- e[int prec]
      -- :   INT
      -- ( {3>=prec}? '*' e[4]
      -- | {2>=prec}? '+' e[3]
      -- )*
      -- ;
      --
      -- The (..)* loop has a decision for the inner block as well as
      -- an enter or exit decision, which is what concerns us here. At
      -- the 1st + of input 1+2+3, the loop ensees both predicates;
      -- and the loop exit also sees both predicates by falling off the
      -- edge of e.  This is because we have no stack information with
      -- SLL and find the follow of e, which will hit the return states
      -- inside the loop after e[4] and e[3], which brings it back to
      -- the enter or exit decision. In this case, we know that we
      -- cannot evaluate those predicates because we have fallen off
      -- the edge of the stack and will in general not know which prec
      -- parameter is the right one to use in the predicate.
      --
      -- Because we have special information, that these are precedence
      -- predicates, we can resolve them without failing over to full
      -- LL despite their context sensitive nature. We make an
      -- assumption that prec[-1] <= prec[0], meaning that the current
      -- precedence level is greater than or equal to the precedence
      -- level of recursive invocations above us in the stack. For
      -- example, if predicate then3>=prec}? is True of the current prec,
      -- then one option is to enter the loop to match it now. The
      -- other option is to exit the loop and the left recursive rule
      -- to match the current operator in rule invocation further up
      -- the stack. But, we know that all of those prec are lower or
      -- the same value and so we can decide to enter the loop instead
      -- of matching it later. That means we can strip out the other
      -- configuration for the exit branch.
      --
      -- So imagine we have (14,1,$,{2>=prec}?) and then
      -- (14,2,$-dipsIntoOuterContext,{2>=prec}?). The optimization
      -- allows us to collapse these two configurations. We know that
      -- if then2>=prec}? is True for the current prec parameter, it will
      -- also be True for any prec from an invoking e call, indicated
      -- by dipsIntoOuterContext. As the predicates are both True, we
      -- have the option to evaluate them early in the decision start
      -- state. We do this by stripping both predicates and choosing to
      -- enter the loop as it is consistent with the notion of operator
      -- precedence. It's also how the full LL conflict resolution
      -- would work.
      --
      -- The solution requires a different DFA start state for each
      -- precedence level.
      --
      -- The basic filter mechanism is to remove configurations of the
      -- form (p, 2, pi) if (p, 1, pi) exists for the same p and pi. In
      -- other words, for the same ATN state and predicate context,
      -- remove any configuration associated with an exit branch if
      -- there is a configuration associated with the enter branch.
      --
      -- It's also the case that the filter evaluates precedence
      -- predicates and resolves conflicts according to precedence
      -- levels. For example, for input 1+2+3 at the first +, we see
      -- prediction filtering
      --
      -- [(11,1,[$],{3>=prec}?), (14,1,[$],{2>=prec}?), (5,2,[$],up=1),
      -- (11,2,[$],up=1), (14,2,[$],up=1)],hasSemanticContext=True,dipsIntoOuterContext
      --
      -- to
      --
      -- [(11,1,[$]), (14,1,[$]), (5,2,[$],up=1)],dipsIntoOuterContext
      --
      -- This filters because {3>=prec}? evals to True and collapses
      -- (11,1,[$],{3>=prec}?) and (11,2,[$],up=1) since early conflict
      -- resolution based upon rules of operator precedence fits with
      -- our usual match first alt upon conflict.
      --
      -- We noticed a problem where a recursive call resets precedence
      -- to 0. Sam's fix: each config has flag indicating if it has
      -- returned from an expr[0] call. then just don't filter any
      -- config with that flag set. flag is carried along in
      -- closure (). so to avoid adding field, set bit just under sign
      -- bit of dipsIntoOuterContext (SUPPRESS_PRECEDENCE_FILTER).
      -- With the change you filter "unless (p, 2, pi) was reached
      -- after leaving the rule stop state of the LR rule containing
      -- state p, corresponding to a rule invocation with precedence
      -- level 0"
      --

      --
      -- This method transforms the start state computed by
      -- _#computeStartState_ to the special start state used by a
      -- precedence DFA for a particular precedence value. The transformation
      -- process applies the following changes to the start state's configuration
      -- set.
      --
      -- * Evaluate the precedence predicates for each configuration using
      -- _org.antlr.v4.runtime.atn.SemanticContext#evalPrecedence_.
      -- * When _org.antlr.v4.runtime.atn.ATNConfig#isPrecedenceFilterSuppressed_ is `False`,
      -- remove all configurations which predict an alternative greater than 1,
      -- for which another configuration that predicts alternative 1 is in the
      -- same ATN state with the same prediction context. This transformation is
      -- valid for the following reasons:
      --
      -- * The closure block cannot contain any epsilon transitions which bypass
      -- the body of the closure, so all states reachable via alternative 1 are
      -- part of the precedence alternatives of the transformed left-recursive
      -- rule.
      -- * The "primary" portion of a left recursive rule cannot contain an
      -- epsilon transition, so the only way an alternative other than 1 can exist
      -- in a state that is also reachable via alternative 1 is by nesting calls
      -- to the left-recursive rule, with the outer calls not being at the
      -- preferred precedence level. The
      -- _org.antlr.v4.runtime.atn.ATNConfig#isPrecedenceFilterSuppressed_ property marks ATN
      -- configurations which do not meet this condition, and therefore are not
      -- eligible for elimination during the filtering process.
      --
      -- The prediction context must be considered by this filter to address
      -- situations like the following.
      -- ```
      -- grammar TA;
      -- prog: statement* EOF;
      -- statement: letterA | statement letterA 'b' ;
      -- letterA: 'a';
      -- ```
      -- If the above grammar, the ATN state immediately before the token
      -- reference `'a'` in `letterA` is reachable from the left edge
      -- of both the primary and closure blocks of the left-recursive rule
      -- `statement`. The prediction context associated with each of these
      -- configurations distinguishes between them, and prevents the alternative
      -- which stepped out to `prog` (and then back in to `statement`
      -- from being eliminated by the filter.
      --
      -- * parameter configs: The configuration set computed by
      -- _#computeStartState_ as the start state for the DFA.
      -- * returns: The transformed configuration set representing the start state
      -- for a precedence DFA at a particular precedence level (determined by
      -- calling _org.antlr.v4.runtime.Parser#getPrecedence_).
      --
      -- final internal
      function applyPrecedenceFilter (This : ParserATNSimulator;configs : ATNConfigSet) return ATNConfigSet is
   begin
         return configs.applyPrecedenceFilter (This.mergeCache,parser,_outerContext);
      end if;

      -- final internal
      function getReachableTarget (This : ParserATNSimulator;trans : Transition; tType : Token_Kind) return Optional_ATNState is
      begin

         if trans.matches (ttype, 0, atn.maxTokenType) then
               return trans.target;
         end if;

         return null;
      end if;

      -- final internal
      function getPredsForAmbigAlts (This : ParserATNSimulator; ambigAlts : BitSet;
         configs : ATNConfigSet;
         nalts : Integer) return SemanticContext.Container.Vector is
               -- REACH=[1|1|[]|0:0, 1|2|[]|0:1]
               --
               -- altToPred starts as an array of all null contexts. The enat index i;
               -- corresponds to alternative i. altToPred[i] may have one of three values:
               -- 1. null: no ATNConfig c is found such that c.alt = i
               -- 2. SemanticContext.Empty.Instance: At least one ATNConfig c exists such that
               -- c.alt = i and c.semanticContext = SemanticContext.Empty.Instance. In other words,
               -- alt i has at least one unpredicated config.
               -- 3. Non-NONE Semantic Context: There exists at least one, and for all
               -- ATNConfig c such that c.alt = i, c.semanticContext /= SemanticContext.Empty.Instance.
               --
               -- From this, it is clear that NONE or anything = NONE.
               --
               altToPred : constant := configs.getPredsForAmbigAlts (ambigAlts,nalts);
               if debug then
                  print ("getPredsForAmbigAlts result \(String (describing: altToPred))");
               end if;
               return altToPred
      end if;

      -- final internal
      function getPredicatePredictions (This : ParserATNSimulator; ambigAlts : Optional_BitSet;
         altToPred : SemanticContext.Container.Vector) return DFAState.PredPrediction.Vector is
               pairs := DFAState.PredPrediction.Vector;
               containsPredicate := False;
               for (i, pred) in altToPred.enumerated ().dropFirst () loop

                  -- unpredicated is indicated by SemanticContext.Empty.Instance
                  assert (pred /= null, "Expected: pred /= null");

                  if ambigAlts : constant := ambigAlts, try! ambigAlts.get (i) then
                     pairs.append (DFAState.PredPrediction (pred!, i));
                  end if;
                  if pred /= SemanticContext.Empty.Instance then
                     containsPredicate := True;
                  end if;
               end loop;

               if not containsPredicate then
                  return null;
               end if;

               return pairs    --pairs.toArray (new, DFAState.PredPrediction[pairs.size ()]);
      end if;

      --
      -- This method is used to improve the localization of error messages by
      -- choosing an alternative rather than throwing a
      -- _org.antlr.v4.runtime.NoViableAltException_ in particular prediction scenarios where the
      -- _#ERROR_ state was reached during ATN simulation.
      --
      -- The default implementation of this method uses the following
      -- algorithm to identify an ATN configuration which successfully parsed the
      -- decision enrule. Choosing such an alternative ensures that the;
      -- _org.antlr.v4.runtime.ParserRuleContext_ returned by the calling rule will be complete
      -- and valid, and the syntax error will be reported later at a more
      -- localized location.
      --
      -- * If a syntactically valid path or paths reach the end of the decision rule and
      -- they are semantically valid if predicated, return the min associated alt.
      -- * Else, if a semantically invalid but syntactically valid path exist
      -- or paths exist, return the minimum associated alt.
      -- * Otherwise, return _org.antlr.v4.runtime.atn.ATN#INVALID_ALT_NUMBER_.
      --
      -- In some scenarios, the algorithm described above could predict an
      -- alternative which will result in a _org.antlr.v4.runtime.FailedPredicateException_ in
      -- the parser. Specifically, this could occur if the __only__ configuration
      -- capable of successfully parsing to the end of the decision rule is
      -- blocked by a semantic predicate. By choosing this alternative within
      -- _#adaptivePredict_ instead of throwing a
      -- _org.antlr.v4.runtime.NoViableAltException_, the resulting
      -- _org.antlr.v4.runtime.FailedPredicateException_ in the parser will identify the specific
      -- predicate which is preventing the parser from successfully parsing the
      -- decision rule, which helps developers identify and correct logic errors
      -- in semantic predicates.
      --
      -- * parameter configs: The ATN configurations which were valid immediately before
      -- the _#ERROR_ state was reached
      -- * parameter outerContext: The is the \gamma_0 initial parser context from the paper
      -- or the parser stack at the instant before prediction commences.
      --
      -- * returns: The value to return from _#adaptivePredict_, or
      -- _org.antlr.v4.runtime.atn.ATN#INVALID_ALT_NUMBER_ if a suitable alternative was not
      -- identified and _#adaptivePredict_ should report an error instead.
      --
      -- final internal
      function getSynValidOrSemInvalidAltThatFinishedDecisionEntryRule (This : ParserATNSimulator;configs : ATNConfigSet;
         outerContext : ParserRuleContext) return Integer is
   begin
               let (semValidConfigs, semInvalidConfigs) := splitAccordingToSemanticValidity (configs, outerContext);
               alt := getAltThatFinishedDecisionEntryRule (semValidConfigs);
               if alt /= ATN.INVALID_ALT_NUMBER then
                  -- semantically/syntactically viable path exists
                  return alt
               end if;
               -- Is there a syntactically valid path with a failed pred?
               if semInvalidConfigs.size () > 0 then
                  alt := getAltThatFinishedDecisionEntryRule (semInvalidConfigs);
                  if alt /= ATN.INVALID_ALT_NUMBER then
                     -- syntactically viable path exists
                     return alt
                  end if;
               end if;
               return ATN.INVALID_ALT_NUMBER
      end if;

      -- final internal
      function getAltThatFinishedDecisionEntryRule (This : ParserATNSimulator;configs : ATNConfigSet) return Integer is
   begin

         return configs.getAltThatFinishedDecisionEntryRule ();
      end if;

      --
      -- Walk the list of configurations and split them according to
      -- those that have preds evaluating to True/False.  If no pred, assume
      -- True pred and include in succeeded set.  Returns Pair of sets.
      --
      -- Create a new set so as not to alter the incoming parameter.
      --
      -- Assumption: the input stream has been restored to the starting point
      -- prediction, which is where predicates need to evaluate.
      --
      -- final internal procedure splitAccordingToSemanticValidity (
         configs : ATNConfigSet;
         outerContext : ParserRuleContext) return (ATNConfigSet, ATNConfigSet) {

               return configs.splitAccordingToSemanticValidity (outerContext, evalSemanticContext);
      }

      --
      -- Look through a list of predicate/alt pairs, returning alts for the
      -- pairs that win. A `NONE` predicate indicates an alt containing an
      -- unpredicated config which behaves as "always True." If not complete
      -- then we stop at the first predicate that evaluates to True. This
      -- includes pairs with null predicates.
      --
      -- final internal
      function evalSemanticContext (This : ParserATNSimulator;predPredictions : [DFAState.PredPrediction],
         outerContext : ParserRuleContext;
         complete  : Boolean) return BitSet is
   begin
               predictions : constant := BitSet ();
               for pair in predPredictions loop
                  if pair.pred = SemanticContext.Empty.Instance then
                     predictions.set (pair.alt);; -- try!
                     exit when not complete;
                     goto CONTINUE;
                  end if;

                  fullCtx : constant := False -- in dfa
                  predicateEvaluationResult : constant := evalSemanticContext (pair.pred, outerContext, pair.alt, fullCtx);
                  if debug or else dfa_debug then
                     print ("eval pred " & pair'Image & "= " & predicateEvaluationResult'Image);
                  end if;

                  if predicateEvaluationResult then
                     if debug or else dfa_debug then
                           print ("PREDICT \(pair.alt)");
                     end if;
                     predictions.set (pair.alt);; -- try!
                     exit when not complete;
                  end if;
                  <<CONTINUE>>
               end loop;

               return predictions
      end if;

      --
      -- Evaluate a semantic context within a specific parser context.
      --
      -- This method might not be called for every semantic context evaluated
      -- during the prediction process. In particular, we currently do not
      -- evaluate the following but it may change in the future:
      --
      -- * Precedence predicates (represented by
      -- _org.antlr.v4.runtime.atn.SemanticContext.PrecedencePredicate_) are not currently evaluated
      -- through this method.
      -- * Operator predicates (represented by _org.antlr.v4.runtime.atn.SemanticContext.AND_ and
      -- _org.antlr.v4.runtime.atn.SemanticContext.OR_) are evaluated as a single semantic
      -- context, rather than evaluating the operands individually.
      -- Implementations which require evaluation results from individual
      -- predicates should override this method to explicitly handle evaluation of
      -- the operands within operator predicates.
      --
      -- * parameter pred: The semantic context to evaluate
      -- * parameter parserCallStack: The parser context in which to evaluate the
      -- semantic context
      -- * parameter alt: The alternative which is guarded by `pred`
      -- * parameter fullCtx: `True` if the evaluation is occurring during LL
      -- prediction; otherwise, `False` if the evaluation is occurring
      -- during SLL prediction
      --
      -- * since: 4.3
      --
      -- internal
      function evalSemanticContext (This : ParserATNSimulator;pred : SemanticContext; parserCallStack : ParserRuleContext; alt : Integer; fullCtx  : Boolean) return Boolean is
   begin
         return pred.eval (parser, parserCallStack);
      end if;

      --
      -- TODO: If we are doing predicates, there is no point in pursuing
      -- closure operations if we reach a DFA state that uniquely predicts
      -- alternative. We will not be caching that DFA state and it is a
      -- waste to pursue the closure. Might have to advance when we do
      -- ambig detection thought :(
      --
      -- final internal
      procedure closure (config : ATNConfig;
         configs : ATNConfigSet;
         closureBusy : in out Set<ATNConfig>,
         collectPredicates : Boolean;
         fullCtx : Boolean;
         treatEofAsEpsilon  : Boolean) {
               initialDepth : constant Integer := 0;
               closureCheckingStopState (config, configs, &closureBusy, collectPredicates, fullCtx, initialDepth, treatEofAsEpsilon);
               assert (not fullCtx or else not configs.dipsIntoOuterContext, "Expected: not fullCtx or not configs.dipsIntoOuterContext");
      }


      -- final internal
      procedure closureCheckingStopState (config : ATNConfig;
         configs : ATNConfigSet;
         closureBusy : in out Set<ATNConfig>,
         collectPredicates : Boolean;
         fullCtx : Boolean;
         depth : Integer;
         treatEofAsEpsilon  : Boolean) {

               if debug then
                  print ("closure (" + config.toString (parser, True) + ")");
               end if;

               if config.state is RuleStopState then
                  configContext : constant := config.context!
                  -- We hit rule end. If we have context info, use it
                  -- run thru all possible stack tops in ctx
                  if not configContext.isEmpty () then
                     length : constant := configContext.size ();
                     for i in 0 .. length - 1 loop
                           if configContext.getReturnState (i) == PredictionContext.EMPTY_RETURN_STATE then
                              if fullCtx then
                                 configs.add (ATNConfig (config, config.state, EmptyPredictionContext.Instance), This.mergeCache);; -- try!
                                 goto CONTINUE;
                              else
                                 -- we have no context info, just chase follow links (if greedy);
                                 if debug then
                                       print ("FALLING off rule\(getRuleName (config.state.ruleIndex!))");
                                 end if;
                                 closure_ (config, configs, &closureBusy, collectPredicates,;
                                       fullCtx, depth, treatEofAsEpsilon);
                              end if;
                              goto CONTINUE;
                           end if;
                           returnState : constant ATNState := atn.states[configContext.getReturnState (i)]!;
                           newContext : constant Optional_PredictionContext; := configContext.getParent (i) -- "pop" return state;
                           c : constant ATNConfig := ATNConfig (returnState, config.alt, newContext,;
                              config.semanticContext);
                           -- While we have context to pop back from, we may have
                           -- gotten that context AFTER having falling off a rule.
                           -- Make sure we track that we are now out of context.
                           --
                           -- This assignment also propagates the
                           -- isPrecedenceFilterSuppressed () value to the new
                           -- configuration.
                           c.reachesIntoOuterContext := config.reachesIntoOuterContext
                           assert (depth > Int.min, "Expected: depth>Integer.MIN_VALUE");
                           closureCheckingStopState (c, configs, &closureBusy, collectPredicates,;
                              fullCtx, depth - 1, treatEofAsEpsilon);
                           <<CONTINUE>>
                     end loop;
                     return
                  end if; elsif fullCtx then
                     -- reached end of start rule
                     configs.add (config, This.mergeCache);; -- try!
                     return
                  else
                     -- else if we have no context info, just chase follow links (if greedy);
                     if debug then
                           print ("FALLING off rule \(getRuleName (config.state.ruleIndex!))");
                     end if;

                  end if;
               end if;
               closure_ (config, configs, &closureBusy, collectPredicates, fullCtx, depth, treatEofAsEpsilon);
      }

      --
      -- Do the actual work of walking epsilon edges
      --
      -- final internal
      procedure closure_ (This : ParserATNSimulator; config : ATNConfig;
         configs : ATNConfigSet;
         closureBusy : in out Set<ATNConfig>,
         collectPredicates : Boolean;
         fullCtx : Boolean;
         depth : Integer;
         treatEofAsEpsilon  : Boolean) is
         begin
               -- print (__FUNCTION__);
               --long startTime := System.currentTimeMillis ();
               p : constant := config.state
               -- optimization
               if not p.onlyHasEpsilonTransitions () then
                  configs.add (config, This.mergeCache);; -- try!
                  -- make sure to not return here, because EOF transitions can act as
                  -- both epsilon transitions and non-epsilon transitions.
                  --            if ( debug ) print ("added config "+configs);
               end if;
               length : constant := p.getNumberOfTransitions ();
               for i in 0 .. length - 1 loop
                  if i = 0 and
                     canDropLoopEntryEdgeInLeftRecursiveRule (config) then
                     goto CONTINUE;
                  end if;
                  t : constant := p.transition (i);
                  continueCollecting : constant Boolean := not (t is ActionTransition) and then collectPredicates
                  c : constant := getEpsilonTarget (config, t, continueCollecting, depth = 0, fullCtx, treatEofAsEpsilon);
                  if c : constant := c then
                     newDepth := depth
                     if config.state is RuleStopState then
                           assert (not fullCtx, "Expected: not fullCtx");
                           -- target fell off end of rule; mark resulting c as having dipped into outer context
                           -- We can't get here if incoming config was rule stop and we had context
                           -- track how far we dip into outer context.  Might
                           -- come in handy and we avoid evaluating context dependent
                           -- preds if this is > 0.
                           if _dfa : constant := _dfa , _dfa.isPrecedenceDfa () then
                              outermostPrecedenceReturn : constant Integer := EpsilonTransition ((t);).outermostPrecedenceReturn ();
                              if outermostPrecedenceReturn = _dfa.atnStartState.ruleIndex then
                                 c.setPrecedenceFilterSuppressed (True);
                              end if;
                           end if;

                           c.reachesIntoOuterContext := @ + 1;
                           if closureBusy.contains (c) then
                              -- avoid infinite recursion for right-recursive rules
                              goto CONTINUE;
                           else
                              closureBusy.insert (c);
                           end if;

                           configs.dipsIntoOuterContext := True -- TODO: can remove? only care when we add to set per middle of this method
                           --print ("newDepth=>" & newDepth'Image);
                           assert (newDepth > Int.min, "Expected: newDepth>Integer.MIN_VALUE");
                           newDepth := @ - 1;

                           if debug then
                              print ("dips into outer ctx: " & c'Image);
                           end if;
                     else
                           if not t.isEpsilon () then
                              if closureBusy.contains (c) then
                                 -- avoid infinite recursion for EOF* and EOF+
                                 goto CONTINUE;
                              else
                                 closureBusy.insert (c);
                              end if;
                           end if;

                           if t is RuleTransition then
                              -- latch when newDepth goes negative - once we step out of the encontext we can't return;
                              if newDepth >= 0 then
                                 newDepth := @ + 1;
                              end if;
                           end if;
                     end if;

                     closureCheckingStopState (c, configs, &closureBusy, continueCollecting,;
                           fullCtx, newDepth, treatEofAsEpsilon);
                  end if;
                  <<CONTINUE>>
               end loop;
               --long finishTime := System.currentTimeMillis ();
               --  if ((finishTime-startTime)>1);
               --print ("That took: "+(finishTime-startTime)+ " ms");
      end closure_;

      --
      -- Implements first-edge (loop entry) elimination as an optimization
      -- during closure operations.  See antlr/antlr4#1398.
      --
      -- The optimization is to avoid adding the loop enconfig when;
      -- the exit path can only lead back to the same
      -- StarLoopEntryState after popping context at the rule end state
      -- (traversing only epsilon edges, so we're still in closure, in
      -- this same rule).
      --
      -- We need to detect any state that can reach loop enon;
      -- epsilon w/o exiting rule. We don't have to look at FOLLOW
      -- links, just ensure that all stack tops for config refer to key
      -- states in LR rule.
      --
      -- To verify we are in the right situation we must first check
      -- closure is at a StarLoopEntryState generated during LR removal.
      -- Then we check that each stack top of context is a return state
      -- from one of these cases:
      --
      -- 1. 'not' expr, '(' type ')' expr. The return state points at loop enstate;
      -- 2. expr op expr. The return state is the block end of internal block of ( .. )*
      -- 3. 'between' expr 'and' expr. The return state of 2nd expr reference.
      -- That state points at block end of internal block of ( .. )*.
      -- 4. expr '?' expr ':' expr. The return state points at block end,
      -- which points at loop enstate.;
      --
      -- If any is True for each stack top, then closure does not add a
      -- config to the current config set for edge[0], the loop enbranch.;
      --
      -- Conditions fail if any context for the current config is:
      --
      -- a. empty (we'd fall out of expr to do a global FOLLOW which could
      -- even be to some weird spot in expr) or,
      -- b. lies outside of expr or,
      -- c. lies within expr but at a state not the BlockEndState
      -- generated during LR removal
      --
      -- Do we need to evaluate predicates ever in closure for this case?
      --
      -- No. Predicates, including precedence predicates, are only
      -- evaluated when computing a DFA start state. I.e., only before
      -- the lookahead (but not parser) consumes a token.
      --
      -- There are no epsilon edges allowed in LR rule alt blocks or in
      -- the "primary" part (ID here). If closure is in
      -- StarLoopEntryState any lookahead operation will have consumed a
      -- token as there are no epsilon-paths that lead to
      -- StarLoopEntryState. We do not have to evaluate predicates
      -- therefore if we are in the generated StarLoopEntryState of a LR
      -- rule. Note that when making a prediction starting at that
      -- decision point, decision d=2, compute-start-state performs
      -- closure starting at edges[0], edges[1] emanating from
      -- StarLoopEntryState. That means it is not performing closure on
      -- StarLoopEntryState during compute-start-state.
      --
      -- How do we know this always gives same prediction answer?
      --
      -- Without predicates, loop enand exit paths are ambiguous;
      -- upon remaining input +b (in, say, a+b). Either paths lead to
      -- valid parses. Closure can lead to consuming + immediately or by
      -- falling out of this call to expr back into expr and loop back
      -- again to StarLoopEntryState to match +b. In this special case,
      -- we choose the more efficient path, which is to take the bypass
      -- path.
      --
      -- The lookahead language has not changed because closure chooses
      -- one path over the other. Both paths lead to consuming the same
      -- remaining input during a lookahead operation. If the next token
      -- is an operator, lookahead will enter the choice block with
      -- operators. If it is not, lookahead will exit expr. Same as if
      -- closure had chosen to enter the choice block immediately.
      --
      -- Closure is examining one config (some loopentrystate, some alt,
      -- context) which means it is considering exactly one alt. Closure
      -- always copies the same alt to any derived configs.
      --
      -- How do we know this optimization doesn't mess up precedence in
      -- our parse trees?
      --
      -- Looking through expr from left edge of stat only has to confirm
      -- that an input, say, a+b+c; begins with any valid interpretation
      -- of an expression. The precedence actually doesn't matter when
      -- making a decision in stat seeing through expr. It is only when
      -- parsing rule expr that we must use the precedence to get the
      -- right interpretation and, hence, parse tree.
      --
      -- *  4.6
      --
      -- internal
      function canDropLoopEntryEdgeInLeftRecursiveRule (This : ParserATNSimulator;config : ATNConfig) return Boolean is
   begin
         if ParserATNSimulator.TURN_OFF_LR_LOOP_ENTRY_BRANCH_OPT then
               return False;
         end if;
         p : constant := config.state
         configContext : constant := config.context;
         if not Is_Valid (configContext) then
               return False;
         end if;
         -- First check to see if we are in StarLoopEntryState generated during
         -- left-recursion elimination. For efficiency, also check if
         -- the context has an empty stack case. If so, it would mean
         -- global FOLLOW so we can't perform optimization
         if p.getStateType () /= ATNState.STAR_LOOP_ENTRY
          or else not ( (StarLoopEntryState (p))).precedenceRuleDecision
          or else -- Are we the special loop entry/exit state?
               configContext.isEmpty ()
          or else -- If SLL wildcard
               configContext.hasEmptyPath () then
               return False;
         end if;

         -- Require all return states to return back to the same rule
         -- that p is in.
         numCtxs : constant := configContext.size ();
         for  i in 0 ..< numCtxs loop -- for each stack context
               returnState : constant := atn.states[configContext.getReturnState (i)]!
               if  returnState.ruleIndex /= p.ruleIndex
               {return False}
         end if;

         decisionStartState : constant BlockStartState := BlockStartState ((p.transition (0).target););
         blockEndStateNum : constant := decisionStartState.endState!.stateNumber
         blockEndState : constant BlockEndState := BlockEndState ((atn.states[blockEndStateNum]););

         -- Verify that the top of each stack context leads to loop entry/exit
         -- state through epsilon edges and w/o leaving rule.
         for  i in 0 ..< numCtxs loop -- for each stack context
               returnStateNumber : constant := configContext.getReturnState (i);
               returnState : constant := atn.states[returnStateNumber]!
               -- all states must have single outgoing epsilon edge
               if  returnState.getNumberOfTransitions () /= 1 or else not returnState.transition (0).isEpsilon ()then
                  return False;
               end if;
               -- Look for prefix op case like 'not expr', (' type ')' expr
               returnStateTarget : constant := returnState.transition (0).target
               if returnState.getStateType () == ATNState.BLOCK_END and
                  returnStateTarget = p then
                  goto CONTINUE;
               end if;
               -- Look for 'expr op expr' or case where expr's return state is block end
               -- of ( .. )* internal block; the block end points to loop back
               -- which points to p but we don't need to check that
               if returnState = blockEndState then
                  goto CONTINUE;
               end if;
               -- Look for ternary expr ? expr : expr. The return state points at block end,
               -- which points at loop enstate;
               if returnStateTarget = blockEndState then
                  goto CONTINUE;
               end if;
               -- Look for complex prefix 'between expr and expr' case where 2nd expr's
               -- return state points at block end state of ( .. )* internal block
               if  returnStateTarget.getStateType () == ATNState.BLOCK_END and
                  returnStateTarget.getNumberOfTransitions () == 1 and
                  returnStateTarget.transition (0).isEpsilon () and
                  returnStateTarget.transition (0).target = p then
                  goto CONTINUE;
               end if;

               -- anything else ain't conforming
               return False;
               <<CONTINUE>>
         end loop;

         return True;
      end if;

      -- open
      function getRuleName (This : ParserATNSimulator;index : Integer) return String is
   begin
         if index >= 0  then
               return parser.getRuleNames ()[index];
         end if;
         return "<rule " & index'Image & ">"
      end if;


      -- final
      function getEpsilonTarget (This : ParserATNSimulator;config : ATNConfig;
         t : Transition;
         collectPredicates : Boolean;
         inContext : Boolean;
         fullCtx : Boolean;
         treatEofAsEpsilon  : Boolean) return Optional_ATNConfig is
      begin
               case t.getSerializationType () is
                  when Transition.RULE =>
                     return ruleTransition (config, RuleTransition (t));

                  when Transition.PRECEDENCE =>
                     return precedenceTransition (config, PrecedencePredicateTransition (t), collectPredicates, inContext, fullCtx);

                  when Transition.PREDICATE =>
                     return predTransition (config, PredicateTransition (t),;
                        collectPredicates,
                        inContext,
                        fullCtx);

                  when Transition.ACTION =>
                     return actionTransition (config, ActionTransition (t));

                  when Transition.EPSILON =>
                     return ATNConfig (config, t.target);

                  when Transition.ATOM => fallthrough;
                  when Transition.RANGE => fallthrough;
                  when Transition.SET =>
                     -- EOF transitions act like epsilon transitions after the first EOF
                     -- transition is traversed
                     if treatEofAsEpsilon then
                        if t.matches (CommonToken.EOF, 0, 1) then
                              return ATNConfig (config, t.target);
                        end if;
                     end if;

                     return null;

                  when others =>
                     return null;
               end case;

               --return null;

      end if;


      -- final
      function actionTransition (This : ParserATNSimulator;config : ATNConfig; t : ActionTransition) return ATNConfig is
   begin
         if debug then
               print ("ACTION edge \(t.ruleIndex):\(t.actionIndex)");
         end if;
         return ATNConfig (config, t.target);
      end if;


      -- final
      function precedenceTransition (This : ParserATNSimulator;config : ATNConfig;
                                       pt : PrecedencePredicateTransition;
                                       collectPredicates : Boolean;
                                       inContext : Boolean;
                                       fullCtx  : Boolean) return Optional_ATNConfig is
      begin
         if debug then
               print ("PRED (collectPredicates=" & collectPredicates'Image & ") \(pt.precedence)>=_p, ctx dependent=True");
               --if ( parser /= null )  then
               print ("context surrounding pred is \(parser.getRuleInvocationStack ())");
               -- }
         end if;

         c : Optional_ATNConfig; := null;
         if collectPredicates and then inContext then
               if fullCtx then
                  -- In full context mode, we can evaluate predicates on-the-fly
                  -- during closure, which dramatically reduces the size of
                  -- the config sets. It also obviates the need to test predicates
                  -- later during conflict resolution.
                  currentPosition : constant := _input.index ();
                  _input.seek (_startIndex);
                  predSucceeds : constant := evalSemanticContext (pt.getPredicate (), _outerContext, config.alt, fullCtx);
                  _input.seek (currentPosition);
                  if predSucceeds then
                     c := ATNConfig (config, pt.target);  -- no pred context
                  end if;
               else
                  newSemCtx : constant := SemanticContext.and (config.semanticContext, pt.getPredicate ());
                  c := ATNConfig (config, pt.target, newSemCtx);
               end if;
         else
               c := ATNConfig (config, pt.target);
         end if;

         if debug then
               print ("config from pred transition=\(c?.description ?? "null")");
         end if;
         return c
      end if;


      -- final
      function predTransition (This : ParserATNSimulator;config : ATNConfig;
                                 pt : PredicateTransition;
                                 collectPredicates : Boolean;
                                 inContext : Boolean;
                                 fullCtx  : Boolean) return Optional_ATNConfig is
      begin
         if debug then
               print ("PRED (collectPredicates=" & collectPredicates'Image & ") \(pt.ruleIndex):\(pt.predIndex), ctx dependent=\(pt.isCtxDependent)");
               -- if parser /= null then
               print ("context surrounding pred is \(parser.getRuleInvocationStack ())");
               -- end if;
         end if;

         c : Optional_ATNConfig; := null;
         if collectPredicates and
               (not pt.isCtxDependent or else (pt.isCtxDependent and then inContext)) {
               if fullCtx then
                  -- In full context mode, we can evaluate predicates on-the-fly
                  -- during closure, which dramatically reduces the size of
                  -- the config sets. It also obviates the need to test predicates
                  -- later during conflict resolution.
                  currentPosition : constant := _input.index ();
                  _input.seek (_startIndex);
                  predSucceeds : constant := evalSemanticContext (pt.getPredicate (), _outerContext, config.alt, fullCtx);
                  _input.seek (currentPosition);
                  if predSucceeds then
                     c := ATNConfig (config, pt.target);  -- no pred context
                  end if;
               else
                  newSemCtx : constant := SemanticContext.and (config.semanticContext, pt.getPredicate ());
                  c := ATNConfig (config, pt.target, newSemCtx);
               end if;
         else
               c := ATNConfig (config, pt.target);
         end if;

         if debug then
               print ("config from pred transition=\(c?.description ?? "null")");
         end if;
         return c
      end if;


      -- final
      function ruleTransition (This : ParserATNSimulator;config : ATNConfig; t : RuleTransition) return ATNConfig is
   begin
         if debug then
               print ("CALL rule \(getRuleName (t.target.ruleIndex!)), ctx=\(config.context?.description ?? "null")");
         end if;

         returnState : constant := t.followState
         newContext : constant := SingletonPredictionContext.create (config.context, returnState.stateNumber);
         return ATNConfig (config, t.target, newContext);
      end if;

      --
      -- Gets a _java.util.BitSet_ containing the alternatives in `configs`
      -- which are part of one or more conflicting alternative subsets.
      --
      -- * parameter configs: The _org.antlr.v4.runtime.atn.ATNConfigSet_ to analyze.
      -- * returns: The alternatives in `configs` which are part of one or more
      -- conflicting alternative subsets. If `configs` does not contain any
      -- conflicting subsets, this method returns an empty _java.util.BitSet_.
      --
      -- final
      function getConflictingAlts (This : ParserATNSimulator;configs : ATNConfigSet) return BitSet is
   begin
         altsets : constant PredictionMode := PredictionModes.getConflictingAltSubsets (configs);
         return PredictionModes.getAlts (altsets);
      end if;

      --
      -- Sam pointed out a problem with the previous definition, v3, of
      -- ambiguous states. If we have another state associated with conflicting
      -- alternatives, we should keep going. For example, the following grammar
      --
      -- s : (ID | ID ID?) ';' ;
      --
      -- When the ATN simulation reaches the state before ';', it has a DFA
      -- state that looks like: [12|1|[], 6|2|[], 12|2|[]]. Naturally
      -- 12|1|[] and 12|2|[] conflict, but we cannot stop processing this node
      -- because alternative to has another way to continue, via [6|2|[]].
      -- The key is that we have a single state that has config's only associated
      -- with a single alternative, 2, and crucially the state transitions
      -- among the configurations are all non-epsilon transitions. That means
      -- we don't consider any conflicts that include alternative 2. So, we
      -- ignore the conflict between alts 1 and 2. We ignore a set of
      -- conflicting alts when there is an intersection with an alternative
      -- associated with a single alt state in the state&rarr;config-list map.
      --
      -- It's also the case that we might have two conflicting configurations but
      -- also a 3rd nonconflicting configuration for a different alternative:
      -- [1|1|[], 1|2|[], 8|3|[]]. This can come about from grammar:
      --
      -- a : A | A | A B ;
      --
      -- After matching input A, we reach the stop state for rule A, state 1.
      -- State 8 is the state right before B. Clearly alternatives 1 and 2
      -- conflict and no amount of further lookahead will separate the two.
      -- However, alternative 3 will be able to continue and so we do not
      -- stop working on this state. In the previous example, we're concerned
      -- with states associated with the conflicting alternatives. Here alt
      -- 3 is not associated with the conflicting configs, but since we can continue
      -- looking for input reasonably, I don't declare the state done. We
      -- ignore a set of conflicting alts when we have an alternative
      -- that we still need to pursue.
      --
      -- final
      function getConflictingAltsOrUniqueAlt (This : ParserATNSimulator;configs : ATNConfigSet) return BitSet is
   begin
         conflictingAlts : BitSet;
         if configs.uniqueAlt /= ATN.INVALID_ALT_NUMBER then
               conflictingAlts := BitSet ();
               conflictingAlts.set (configs.uniqueAlt);; -- try!
         else
               conflictingAlts := configs.conflictingAlts!;
         end if;
         return conflictingAlts
      end if;


      -- public final
      function getTokenName (This : ParserATNSimulator;t : Integer) return String is
   begin
         if t = CommonToken.EOF then
               return "EOF";
         end if;
         vocabulary : constant := parser.getVocabulary ();
         displayName : constant := vocabulary.getDisplayName (t);
         if displayName = String (t) then
               return displayName;
         end if;

         return "" & displayName'Image & " <" & t'Image & ">"
      end if;

      -- public final
      function getLookaheadName (This : ParserATNSimulator;input : TokenStream) return String is
   begin
         return getTokenName (input.LA (1));
      end if;

      --
      -- Used for debugging in adaptivePredict around execATN but I cut
      -- it out for clarity now that alg. works well. We can leave this
      -- "dead" code for a bit.
      --
      -- public final
      procedure dumpDeadEndConfigs (This : ParserATNSimulator; nvae : NoViableAltException) is
      begin
         errPrint ("dead end configs: ");
         for c in nvae.getDeadEndConfigs ()!.configs loop
               trans := "no edges"
               if c.state.getNumberOfTransitions () > 0 then
                  t : constant := c.state.transition (0);
                  at : constant Optional_AtomTransition := Set (t);
                  if Is_Valid (at) then
                     trans := "Atom " + getTokenName (at.label);
                  else -- elseif
                     st : constant SetTransition := SetTransition (t);
                     if Is_Valid (st) then
                     not : constant := st is NotSetTransition
                     trans := (not ? "~" : "") + "Set " + st.set.description
                  end if;
               end if;
               errPrint ("\(c.toString (parser, True)):" & trans'Image);
         end if;
      end if;


      -- final
      function noViableAlt (This : ParserATNSimulator;input : TokenStream;
                              outerContext : ParserRuleContext;
                              configs : ATNConfigSet;
                              startIndex : Integer) return NoViableAltException is
   begin
         startToken : constant := try! input.get (startIndex);
         offendingToken : Optional_Token; := null;
         declare
         begin
               offendingToken := input.LT (1);
         end if;
         exception
            when others =>
         end if;
         return NoViableAltException (parser, input, startToken, offendingToken, configs, outerContext);
      end if;

      -- internal static
      function getUniqueAlt (configs : ATNConfigSet) return Integer is
   begin
         alt : constant := configs.getUniqueAlt ();
         return alt
      end if;

      --
      -- Add an edge to the DFA, if possible. This method calls
      -- _#addDFAState_ to ensure the `to` state is present in the
      -- DFA. If `from` is `null`, or if `t` is outside the
      -- range of edges that can be represented in the DFA tables, this method
      -- returns without adding the edge to the DFA.
      --
      -- If `to` is `null`, this method returns `null`.
      -- Otherwise, this method returns the _org.antlr.v4.runtime.dfa.DFAState_ returned by calling
      -- _#addDFAState_ for the `to` state.
      --
      -- * parameter dfa: The DFA
      -- * parameter from: The source state for the edge
      -- * parameter t: The input symbol
      -- * parameter to: The target state for the edge
      --
      -- * returns: the result of calling _#addDFAState_ on `to`
      --
      @discardableResult
      -- private final
      function addDFAEdge (This : ParserATNSimulator;dfa : DFA;
                           from : DFAState;
                           t : Integer;
                           to : DFAState) return DFAState is

         function Closure return … is
         begin
            [unowned This] in
            if from.edges = null then
               from.edges := [DFAState?](repeating: null, count: This.atn.maxTokenType + 1 + 1);  --new DFAState[atn.maxTokenType+1+1];
            end if;

            from.edges[t + 1] := to -- connect
         end Closure;
         Closure_Return_Value : …;
         function Synchronized_Closure is new Mutex.Gen_Closure (Closure => Closure, Result_Type => …);

      begin
         to := to
         if debug then
               print ("EDGE " & from'Image & " -> " & to'Image & " upon \(getTokenName (t))");
         end if;

         to := addDFAState (dfa, to) -- used existing if possible not incoming
         if t < -1 or else t > atn.maxTokenType then
               return to;
         end if;

         from.Mutex.Run (Synchronized_Closure'Access, Closure_Return_Value);
         --TOFIX return Closure_Return_Value;

         if debug then
               print ("DFA=\n" + dfa.toString (parser.getVocabulary ()));
         end if;

         return to;
      end addDFAEdge;

      --
      -- Add state `D` to the DFA if it is not already present, and return
      -- the actual instance stored in the DFA. If a state equivalent to `D`
      -- is already in the DFA, the existing state is returned. Otherwise this
      -- method returns `D` after adding it to the DFA.
      --
      -- If `D` is _#ERROR_, this method returns _#ERROR_ and
      -- does not change the DFA.
      --
      -- * parameter dfa: The dfa
      -- * parameter D: The DFA state to add
      -- * returns: The state stored in the DFA. This will be either the existing
      -- state if `D` is already in the DFA, or `D` itself if the
      -- state was not already present.
      --
      -- private final
      function addDFAState (This : ParserATNSimulator;dfa : DFA; D : DFAState) return DFAState is

         function Closure return DFAState is
         begin
               if existing : constant := dfa.states[D] then
                  return existing;
               end if;

               D.stateNumber := dfa.states.count

               if not D.configs.isReadonly () then
                  D.configs.optimizeConfigs (This);; -- try!
                  D.configs.setReadonly (True);
               end if;

               dfa.states[D] := D
               if debug then
                  print ("adding new DFA state: " & D'Image);
               end if;

               return D
         end Closure;
         Closure_Return_Value : DFAState;
         function Synchronized_Closure is new Mutex.Gen_Closure (Closure => Closure, Result_Type => DFAState);

      begin
         if D = ATNSimulator.ERROR then
               return D;
         end if;

        dfa.statesMutex.Run (Synchronized_Closure'Access, Closure_Return_Value);
        return Closure_Return_Value;

      end addDFAState;

      procedure reportAttemptingFullContext (This : ParserATNSimulator; dfa : DFA; conflictingAlts : Optional_BitSet; configs : ATNConfigSet; startIndex : Integer; stopIndex : Integer) {
         if debug or else retry_debug then
               input : constant := getTextInInterval (startIndex, stopIndex);
               print ("reportAttemptingFullContext decision=\(dfa.decision):" & configs'Image & ", input=" & input'Image);
         end if;
         parser.getErrorListenerDispatch ().reportAttemptingFullContext (parser, dfa, startIndex, stopIndex, conflictingAlts, configs);
      end if;

      procedure reportContextSensitivity (This : ParserATNSimulator; dfa : DFA; prediction : Integer; configs : ATNConfigSet; startIndex : Integer; stopIndex : Integer) {
         if debug or else retry_debug then
               input : constant := getTextInInterval (startIndex, stopIndex);
               print ("reportContextSensitivity decision=\(dfa.decision):" & configs'Image & ", input=" & input'Image);
         end if;
         parser.getErrorListenerDispatch ().reportContextSensitivity (parser, dfa, startIndex, stopIndex, prediction, configs);
      end if;

      --
      -- If context sensitive parsing, we know it's ambiguity not conflict
      --
      -- configs that LL not SLL considered conflictin
      -- internal
      procedure reportAmbiguity (This : ParserATNSimulator; dfa : DFA;
         D : DFAState; -- the DFA state from execATN () that had SLL conflicts
         startIndex : Integer; stopIndex : Integer;
         exact : Boolean;
         ambigAlts : BitSet;
         configs : ATNConfigSet);
      {
         if debug or else retry_debug then
               input : constant := getTextInInterval (startIndex, stopIndex);
               print ("reportAmbiguity " & ambigAlts'Image & ":" & configs'Image & ", input=" & input'Image);
         end if;
         parser.getErrorListenerDispatch ().reportAmbiguity (parser, dfa, startIndex, stopIndex,
               exact, ambigAlts, configs);
      end if;

      -- private
      function getTextInInterval (This : ParserATNSimulator;startIndex : Integer; stopIndex : Integer) return String is
   begin
         interval : constant := Interval.of (startIndex, stopIndex);
         declare
         begin
               return parser.getTokenStream ()?.getText (interval) ?? "<unknown>";
         end if;
         exception
            when others =>
               return "<unknown>"
         end if;
      end if;

      -- public final
      procedure setPredictionMode (This : ParserATNSimulator; mode : PredictionMode) is
      begin
         This.mode := mode
      end if;


      -- public final
      function getPredictionMode (This : ParserATNSimulator) return PredictionMode is
   begin
         return mode
      end if;

      -- public final
      function getParser (This : ParserATNSimulator) return Parser is
   begin
         return parser
      end if;

end ANTLR.Runtime.ATN.ParserATNSimulator;
