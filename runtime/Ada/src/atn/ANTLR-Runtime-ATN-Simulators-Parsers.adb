-- €

with Ada.Real_Time;
with Ada.Wide_Wide_Text_IO;
with Aspect;

use Ada;
use Aspect;

package body ANTLR.Runtime.ATN.Simulators.Parsers is

   function MurMur3_Hash (Key : DoubleKey) return Ada.Containers.Hash_Type is
   begin
      return 0; --TOFIX
   end MurMur3_Hash;

   function Equivalent_DoubleKeys (Left, Right : DoubleKey) return Boolean
      is (MurMur3_Hash (Left) = MurMur3_Hash (Right)
      or else MurMur3_Hash ((Left.B, Left.B)) = MurMur3_Hash (Right)); --TOFIX

   function "=" (Left, Right : Element_Type) return Boolean
      is (Left = Right); --TOFIX

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

   procedure Initialize (Self : in out ParserATNSimulator;
                         parser : Parser;
                         atn : ATN;
                         decisionToDFA : DFA_List;
                         sharedContextCache : PredictionContextCache) is
   begin
      self.parser := parser;
      self.decisionToDFA := decisionToDFA;
      Super (Self).init (atn, sharedContextCache);
      if Is_Active (Aspect.DEBUG) then
         declare
            dot : DOTGenerator := new DOTGenerator ( (Valid => False));
         begin
            Wide_Wide_Text_IO.Put_Line (dot.getDOT (Self.atn.rules.get (0), Self.parser.getRuleNames)'Image);
            Wide_Wide_Text_IO.Put_Line (dot.getDOT (Self.atn.rules.get (1), Self.parser.getRuleNames)'Image);
         end;
      end if;
   end Initialize;

   -- Only for testing purposes !!
   procedure Test_Initialize (Self : ParserATNSimulator;
                         atn : ATN;
                         decisionToDFA : DFA_List;
                         sharedContextCache : PredictionContextCache) is
   begin
      Self.Initialize ( (Valid => False), atn, decisionToDFA, sharedContextCache);
   end Test_Initialize;

   overriding
   procedure reset (This : ParserATNSimulator) is
   begin
       null;
   end reset;

   overriding
   procedure clearDFA (This : ParserATNSimulator) is
   begin
      for d in 0 .. This.decisionToDFA.count -1 loop
            This.decisionToDFA.Insert (Key => d, New_Item => DFA (atn.getDecisionState (d)!, d));
      end loop;
   end clearDFA;

   function adaptivePredict (This : ParserATNSimulator;
                             input : TokenStream;
                             decision : Integer;
                             outerContext : Optional_ParserRuleContext)
                             return Integer is
   begin
      outerContext := outerContext;
      if This.debug or else This.trace_atn_sim then
         debugInfo := "adaptivePredict decision " & decision'Image & ' ';
         debugInfo := @ & "exec LA (1)==" & getLookaheadName (input) & ' ';
         debugInfo := @ & "line " & input.LT (1)!.getLine & ':';
         debugInfo := @ & input.LT (1)!.getCharPositionInLine;
         Wide_Wide_Text_IO.Put_Line (debugInfo);
      end if;

      This.input := input;
      This.startIndex := This.input.index;
      This.outerContext := outerContext;
      dfa : constant := This.decisionToDFA.Element (decision);
      This.dfa := dfa;

      m : constant := This.input.mark;
      index : constant := This.startIndex;

      -- Now we are certain to have a specific decision's DFA
      -- But, do we still need an initial state?
      --TODO: exception handler
      declare
         s0 : Optional_DFAState;
      begin
         if This.dfa.isPrecedenceDfa then
            -- the start state for a precedence DFA depends on the current
            -- parser precedence, and is provided by a DFA method.
            s0 := dfa.getPrecedenceStartState (This.parser.getPrecedence);
         else
            -- the start state for a "regular" DFA is just s0
            s0 := dfa.s0;
         end if;

         if not Is_Valid (s0) then
            --BIG BUG  --TOFIX
            if outerContext =  (Valid => False) then
               outerContext := ParserRuleContext.EMPTY;
            end if;
            if This.debug or else This.trace_atn_sim then
               debugInfo := "predictATN decision " & dfa.decision
               debugInfo := @ & "exec LA (1)==" & getLookaheadName (input) & ", ";
               debugInfo := @ & "outerContext=" & outerContext!.toString (parser);
               Wide_Wide_Text_IO.Put_Line (debugInfo);
            end if;

            fullCtx : constant := False;
            s0_closure := computeStartState (dfa.atnStartState, ParserRuleContext.EMPTY, fullCtx);

            if This.dfa.isPrecedenceDfa then
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
               dfa.setPrecedenceStartState (This.parser.getPrecedence, s0!);
            else
               s0 := addDFAState (dfa, DFAState (s0_closure));
               dfa.s0 := s0;
            end if;
         end if;

         alt : constant := execATN (dfa, s0!, input, index, outerContext!);
         if This.debug then
            Wide_Wide_Text_IO.Put_Line ("DFA after predictATN: " & dfa.toString (This.parser.getVocabulary));
         end if;
         mergeCache := DoubleKeyMap.Empty_Vector; -- wack cache after each prediction
         This.dfa :=  (Valid => False);
         input.seek (index); -- try!
         input.release (m); -- try!
         return alt;
      end;
   end adaptivePredict;

   function execATN (This : ParserATNSimulator;
                     dfa : DFA;
                     s0 : DFAState;
                     input : TokenStream;
                     startIndex : Integer;
                     outerContext : ParserRuleContext)
                     return Integer is
   begin
      if This.debug or else This.trace_atn_sim then
         Wide_Wide_Text_IO.Put_Line ("execATN decision " & dfa.decision & " exec LA (1)==" & getLookaheadName (input) & " line " & input.LT (1)!.getLine () & ':' & input.LT (1)!.getCharPositionInLine ());
      end if;

      previousD := s0;

      if This.debug then
         Wide_Wide_Text_IO.Put_Line ("s0 := " & s0'Image);
      end if;

      t := input.LA (1);

      loop
         -- while more work
         D : DFAState;
         dState : constant := getExistingTargetState (previousD, t);
         if Is_Valid (dState) then
            D := dState;
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

         if D.requiresFullContext and then (This.mode /= SLL) then
            -- IF PREDS, MIGHT RESOLVE TO SINGLE ALT => SLL (or syntax error);
            conflictingAlts := Value (D.configs.conflictingAlts);
            preds : constant := D.predicates;
            if Is_Valid (preds) then
               if This.debug then
                  Wide_Wide_Text_IO.Put_Line ("DFA state has preds in DFA sim LL failover");
               end if;
               conflictIndex : constant := This.input.index;
               if conflictIndex /= startIndex then
                  input.seek (startIndex);
               end if;

               conflictingAlts := evalSemanticContext (preds, outerContext, True);
               if This.conflictingAlts.cardinality = 1 then
                  if This.debug then
                     Wide_Wide_Text_IO.Put_Line ("Full LL avoided");
                  end if;
                  return This.conflictingAlts.firstSetBit;
               end if;

               if conflictIndex /= startIndex then
                  -- restore the index so reporting the fallback to full
                  -- context occurs with the index at the correct spot
                  input.seek (conflictIndex);
               end if;
            end if;

            if This.dfa_debug then
                  Wide_Wide_Text_IO.Put_Line ("ctx sensitive state " & outerContext'Image & " in " & D'Image);
            end if;
            fullCtx : constant := True;
            s0_closure : constant := computeStartState (dfa.atnStartState, outerContext, fullCtx);
            reportAttemptingFullContext (dfa, conflictingAlts, D.configs, startIndex, This.input.index);
            alt : constant := execATNWithFullContext (dfa, D, s0_closure,
                  input, startIndex,
                  outerContext);
            return alt;
         end if;

         if D.isAcceptState then
            preds : constant := D.predicates;
            if not Is_Valid (preds) then
               return D.prediction;
            end if;

            stopIndex : constant := This.input.index;
            input.seek (startIndex);
            alts : constant := evalSemanticContext (preds, outerContext, True);
            case This.alts.cardinality is
               when 0 =>
                  raise ANTLRException.recognition with noViableAlt (input, outerContext, D.configs, startIndex);
               when 1 =>
                  return This.alts.firstSetBit;
               when others =>
                  -- report ambiguity after predicate evaluation to make sure the correct
                  -- set of ambig alts is reported.
                  This.reportAmbiguity (dfa => dfa,
                                        D => D, -- the DFA state from This.execATN that had SLL conflicts
                                        startIndex => startIndex,
                                        stopIndex => stopIndex,
                                        exact => False,
                                        ambigAlts => alts,
                                        configs => D.configs);
                  return This.alts.firstSetBit;
            end case;
         end if;

         previousD := D;

         if t /= BufferedTokenStream.EOF then
            This.input.consume;
            t := input.LA (1);
         end if;
      end loop;
   end execATN;

   function getExistingTargetState (This : ParserATNSimulator; previousD : DFAState; t : Integer) return Optional_DFAState is
      edges : constant := previousD.edges;
   begin
      if not Is_Valid (edges) or else (t + 1) < 0 or else (t + 1) >= (Value (edges).Length) then
         return  (Valid => False);
      end if;
      return Value (edges).Element (t + 1);
   end getExistingTargetState;

   function computeTargetState (This : ParserATNSimulator; dfa : DFA; previousD : DFAState; t : Integer) return DFAState is
      reach : constant ATNConfigSet := computeReachSet (previousD.configs, t, False);
   begin
      if not Is_Valid (reach) then
         addDFAEdge (dfa, previousD, t, ATNSimulator.ERROR);
         return ATNSimulator.ERROR
      end if;

      -- create new target state; we'll add to DFA after it's complete
      D : constant := DFAState (reach);

      predictedAlt : constant := ParserATNSimulator.getUniqueAlt (reach);

      if This.debug then
         altSubSets : constant PredictionMode := PredictionModes.getConflictingAltSubsets (reach);
         Wide_Wide_Text_IO.Put_Line ("SLL altSubSets=" & altSubSets'Image & ", configs=" & reach'Image & ", predict=" & predictedAlt'Image & ", allSubsetsConflict=" & PredictionModes.allSubsetsConflict (altSubSets) & ", conflictingAlts=" & getConflictingAlts (reach));
      end if;

      if predictedAlt /= ATN.INVALID_ALT_NUMBER then
         -- NO CONFLICT, UNIQUELY PREDICTED ALT
         D.isAcceptState := True;
         D.configs.uniqueAlt := predictedAlt
         D.prediction := predictedAlt
      else
         if PredictionModes.hasSLLConflictTerminatingPrediction (This.mode, reach) then
            -- MORE THAN ONE VIABLE ALTERNATIVE
            D.configs.conflictingAlts := getConflictingAlts (reach);
            D.requiresFullContext := True;
            -- in SLL-only mode, we will stop at this state and return the minimum alt
            D.isAcceptState := True;
            D.prediction := Value (D.configs.conflictingAlts).firstSetBit;
         end if;
      end if;

      if D.isAcceptState and then D.configs.hasSemanticContext then
            predicateDFAState (D, Value (atn.getDecisionState (dfa.decision)));
            if Is_Valid (D.predicates) then
               D.prediction := ATN.INVALID_ALT_NUMBER;
            end if;
      end if;
      -- all adds to dfa are done after we've created full D state
      return addDFAEdge (dfa, previousD, t, D);
   end computeTargetState;

   procedure predicateDFAState (This : ParserATNSimulator; dfaState : DFAState; decisionState : DecisionState) is
      -- We need to test all predicates, even in DFA states that
      -- uniquely predict alternative.
      nalts : constant := This.decisionState.getNumberOfTransitions;
   begin
      -- Update DFA so reach becomes accept state with (predicate,alt);
      -- pairs if preds found for conflicting alts
      altsToCollectPredsFrom : constant := getConflictingAltsOrUniqueAlt (dfaState.configs);
      altToPred : constant := getPredsForAmbigAlts (altsToCollectPredsFrom, dfaState.configs, nalts);
      if Is_Valid (altToPred) then
         dfaState.predicates := getPredicatePredictions (altsToCollectPredsFrom, altToPred);
         dfaState.prediction := ATN.INVALID_ALT_NUMBER; -- make sure we use preds
      else
         -- There are preds in configs but they might go away
         -- when OR'd together like {p}? or else NONE = NONE. If neither
         -- alt has preds, resolve to min alt
         dfaState.prediction := This.altsToCollectPredsFrom.firstSetBit;
      end if;
   end predicateDFAState;

   function execATNWithFullContext (This : ParserATNSimulator;dfa : DFA;
                                    D : DFAState; -- how far we got in SLL DFA before failing over
      s0 : ATNConfigSet;
      input : TokenStream; startIndex : Integer;
      outerContext : ParserRuleContext) return Integer is
      fullCtx : constant Boolean := True;
      foundExactAmbig : Boolean := False;
   begin
      if This.debug or else This.trace_atn_sim then
         Wide_Wide_Text_IO.Put_Line ("execATNWithFullContext " & s0'Image);
      end if;
      reach : Optional_ATNConfigSet :=  (Valid => False);
      previous := s0;
      input.seek (startIndex);
      t := input.LA (1);
      predictedAlt := ATN.INVALID_ALT_NUMBER;
      loop
         -- while more work
         if computeReach : constant := computeReachSet (previous, t, fullCtx) then
            reach := computeReach;
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

         if Is_Valid (reach) then
            altSubSets : constant PredictionMode := PredictionModes.getConflictingAltSubsets (reach);
            if This.debug then
               Wide_Wide_Text_IO.Put_Line ("LL altSubSets=" & altSubSets'Image & ", predict=" & PredictionModes.getUniqueAlt (altSubSets) & ", resolvesToJustOneViableAlt=" & PredictionModes.resolvesToJustOneViableAlt (altSubSets));
            end if;

            reach.uniqueAlt := ParserATNSimulator.getUniqueAlt (reach);
            -- unique prediction?
            if reach.uniqueAlt /= ATN.INVALID_ALT_NUMBER then
               predictedAlt := reach.uniqueAlt;
               exit;
            end if;
            if This.mode /= PredictionModes.LL_EXACT_AMBIG_DETECTION then
               predictedAlt : PredictionMode := PredictionModes.resolvesToJustOneViableAlt (altSubSets);
               exit when predictedAlt /= ATN.INVALID_ALT_NUMBER;
            else
               -- In exact ambiguity mode, we never to terminate early.;
               -- Just keeps scarfing until we know what the conflict is
               if PredictionModes.allSubsetsConflict (altSubSets)
               and PredictionModes.allSubsetsEqual (altSubSets) then
                  foundExactAmbig := True;
                  predictedAlt : PredictionMode := PredictionModes.getSingleViableAlt (altSubSets);
                  exit;
               end if;
               -- else there are multiple non-conflicting subsets or
               -- we're not sure what the ambiguity is yet.
               -- So, keep going.
            end if;

            previous := reach;
            if t /= BufferedTokenStream.EOF then
               This.input.consume;
               t := input.LA (1);
            end if;
         end if;
      end loop;

      if Is_Valid (reach) then
         -- If the configuration set uniquely predicts an alternative,
         -- without conflict, then we know that it's a full LL decision
         -- not SLL.
         if reach.uniqueAlt /= ATN.INVALID_ALT_NUMBER then
            reportContextSensitivity (dfa, predictedAlt, reach, startIndex, This.input.index);
            return predictedAlt
         end if;

         -- We do not check predicates here because we have checked them
         -- on-the-fly when doing full context prediction.

         --
         -- In non-exact ambiguity detection mode, we might   actually be able to
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
         reportAmbiguity (dfa, D, startIndex, This.input.index, foundExactAmbig,
                        This.reach.getAlts, reach);
      end if;
      return predictedAlt;
   end execATNWithFullContext;

   function computeReachSet (This : ParserATNSimulator;
                             closureConfigSet : ATNConfigSet;
                             t : Integer;
                             fullCtx : Boolean)
                             return Optional_ATNConfigSet is
   begin
      if This.debug then
         Wide_Wide_Text_IO.Put_Line ("in computeReachSet, starting closure: " & closureConfigSet'Image);
      end if;

      if DoubleKeyMap.Is_Empty (mergeCache) then --TOFIX
         This.mergeCache := DoubleKeyMap.Empty_Map; -- This.PredictionContext.DoubleKeyMap;
      end if;

      intermediate : constant ATNConfigSet := ATNConfigSet (fullCtx);

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
      skippedStopStates : ATNConfig_List := (Valid => False);

      -- First figure out where we can reach on input t
      configs : constant := closureConfigSet.configs
      for config of configs loop
         if This.debug then
            Wide_Wide_Text_IO.Put_Line ("testing " & getTokenName (t) & " at " & Image (config));
         end if;

         if config.state is RuleStopState then
            pragma assert (config.context!.isEmpty (), "Expected: c.context.isEmpty ()");
            if fullCtx or else t = BufferedTokenStream.EOF then
               if not Is_Valid (skippedStopStates) then
                  skippedStopStates := ATNConfig.Container.Empty_Vector;
               end if;
               Value (skippedStopStates).append (config);
            end if;
            goto CONTINUE;
         end if;

         n : constant := This.config.state.getNumberOfTransitions;
         for ti in 0 .. n - 1 loop
            -- for each transition
            trans : constant := config.state.transition (ti);
            if target : constant := getReachableTarget (trans, t) then
               intermediate.add (ATNConfig (config, target), This.mergeCache); -- try!
            end if;
            <<CONTINUE>>
         end loop;
      end loop;

      -- Now figure out where the reach operation can take us ..
      reach : Optional_ATNConfigSet; :=  (Valid => False);

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
      if not Is_Valid (skippedStopStates) and then t /= CommonToken.EOF then
         if This.intermediate.size = 1 then
            -- Don't pursue the closure if there is just one state.
            -- It can only have one alternative; just add to result
            -- Also don't pursue the closure if there is unique alternative
            -- among the configurations.
            reach := intermediate;
         else
            if ParserATNSimulator.getUniqueAlt (intermediate) /= ATN.INVALID_ALT_NUMBER then
               -- Also don't pursue the closure if there is unique alternative
               -- among the configurations.
               reach := intermediate;
            end if;
         end if;
      end if;

      --
      -- If the reach set could not be trivially determined, perform a closure
      -- operation on the intermediate set to compute its initial value.
      --
      if not Is_Valid (reach) then
         reach := ATNConfigSet (fullCtx);
         closureBusy : Set_of_ATNConfigs;
         treatEofAsEpsilon : constant Boolean := (t = CommonToken.EOF);
         for config of intermediate.configs loop
            closure (config, Value (reach), closureBusy'Access, False, fullCtx, treatEofAsEpsilon);
         end loop;
      end if;

      if t = EOF then
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
         reach := removeAllConfigsNotInRuleStopState (Value (reach), Value (reach) === intermediate);
      end if;

      --
      -- If skippedStopStates is not  (Valid => False), then it contains at least one
      -- configuration. For full-context reach operations, these
      -- configurations reached the end of the start rule, in which case we
      -- only add them back to reach if no configuration during the current
      -- closure operation reached such a state. This ensures adaptivePredict
      -- chooses an alternative matching the longest overall sequence when
      -- multiple alternatives are viable.
      --
      if Is_Valid (reach) then
         skippedStopStates : constant := skippedStopStates, (not fullCtx or else not PredictionModes.hasConfigInRuleStopState (reach));
         if  Is_Valid (skippedStopStates) then
            pragma assert (not skippedStopStates.isEmpty, "Expected: not skippedStopStates.isEmpty ()");
            for c of skippedStopStates loop
               reach.add (c, This.mergeCache); -- try!
            end loop;
         end if;

         if This.reach.isEmpty then
            return (Valid => False);
         end if;
      end if;
      return reach;
   end computeReachSet;

   function removeAllConfigsNotInRuleStopState (This : ParserATNSimulator; configs : ATNConfigSet; lookToEndOfRule : Boolean) return ATNConfigSet
      is (configs.removeAllConfigsNotInRuleStopState (This.mergeCache,lookToEndOfRule,atn));

   function computeStartState (This : ParserATNSimulator;p : ATNState; ctx : RuleContext; fullCtx : Boolean) return ATNConfigSet is
            initialContext : constant := PredictionContext.fromRuleContext (atn, ctx);
            configs : constant := ATNConfigSet (fullCtx);
            length : constant := This.p.getNumberOfTransitions;
   begin
      for i in 0 .. length - 1 loop
         target : constant := p.transition (i).target
         c : constant := ATNConfig (target, i + 1, initialContext);
         closureBusy : Set_of_ATNConfigs;
         closure (c, configs, closureBusy'Access, True, fullCtx, False);
      end loop;
      return configs;
   end computeStartState;

   function applyPrecedenceFilter (This : ParserATNSimulator; configs : ATNConfigSet) return ATNConfigSet
      is (configs.applyPrecedenceFilter (This.mergeCache,parser,This.outerContext));

   function getReachableTarget (This : ParserATNSimulator;trans : ATNTransition; tType : Token_Kind) return Optional_ATNState is
   begin
      if trans.matches (ttype, 0, atn.maxTokenType) then
         return trans.target;
      else
         return  (Valid => False);
      end if;
   end getReachableTarget;

   function getPredsForAmbigAlts (This : ParserATNSimulator;
                                  ambigAlts : BitSet;
                                  configs : ATNConfigSet;
                                  nalts : Integer)
                                  return SemanticContext_List is
      -- REACH=[1|1|[]|0:0, 1|2|[]|0:1]
      --
      -- altToPred starts as an array of all  (Valid => False) contexts. The enat index i;
      -- corresponds to alternative i. altToPred.Element (i) may have one of three values:
      -- 1.  (Valid => False): no ATNConfig c is found such that c.alt = i
      -- 2. SemanticContext.Empty.Instance: At least one ATNConfig c exists such that
      -- c.alt = i and c.semanticContext = SemanticContext.Empty.Instance. In other words,
      -- alt i has at least one unpredicated config.
      -- 3. Non-NONE Semantic Context: There exists at least one, and for all
      -- ATNConfig c such that c.alt = i, c.semanticContext /= SemanticContext.Empty.Instance.
      --
      -- From this, it is clear that NONE or anything = NONE.
      --
      altToPred : constant := configs.getPredsForAmbigAlts (ambigAlts,nalts);
   begin
      if This.debug then
         Wide_Wide_Text_IO.Put_Line ("getPredsForAmbigAlts result " & UString (describing => altToPred));
      end if;
      return altToPred;
   end if;

   function getPredicatePredictions (This : ParserATNSimulator;
                                     ambigAlts : Optional_BitSet;
                                     altToPred : SemanticContext_List)
                                     return DFAState.PredPrediction.Vector is
      pairs : DFAState.PredPrediction.Vector;
      containsPredicate : Boolean := False;
   begin  
      for (i, pred) in This.altToPred.enumerated.dropFirst () loop
         -- unpredicated is indicated by SemanticContext.Empty.Instance
         pragma assert (pred /=  (Valid => False), "Expected: pred /=  (Valid => False)");

         if ambigAlts : constant := ambigAlts, ambigAlts.get (i) then -- try!
            pairs.append (DFAState.PredPrediction (pred!, i));
         end if;
         if pred /= SemanticContext.Empty.Instance then
            containsPredicate := True;
         end if;
      end loop;

      if not containsPredicate then
         return (Valid => False);
      end if;

      return pairs;    --pairs.toArray (new, DFAState.PredPrediction[pairs.size ()]);
   end getPredicatePredictions;

   function getSynValidOrSemInvalidAltThatFinishedDecisionEntryRule (This : ParserATNSimulator; 
                                                                     configs : ATNConfigSet;
                                                                     outerContext : ParserRuleContext)
                                                                     return Integer is
      SemConfigs : constant Splitted_ConfigSets 
         := splitAccordingToSemanticValidity (configs => configs, outerContext => outerContext);
      -- Succeeded => semValidConfigs
      -- Failed    => semInvalidConfigs
   begin
      alt := getAltThatFinishedDecisionEntryRule (SemConfigs.Succeeded);
      if alt /= INVALID_ALT_NUMBER then
         -- semantically/syntactically viable path exists
         return alt;
      end if;
      -- Is there a syntactically valid path with a failed pred?
      if SemConfigs.Failed.Length > 0 then
         alt := getAltThatFinishedDecisionEntryRule (SemConfigs.Failed);
         if alt /= INVALID_ALT_NUMBER then
            -- syntactically viable path exists
            return alt;
         end if;
      end if;
      return INVALID_ALT_NUMBER
   end getSynValidOrSemInvalidAltThatFinishedDecisionEntryRule;

   function getAltThatFinishedDecisionEntryRule (This : ParserATNSimulator; configs : ATNConfigSet) return Integer
      is (This.configs.getAltThatFinishedDecisionEntryRule);

   function splitAccordingToSemanticValidity (This : ParserATNSimulator;
                                              configs : ATNConfigSet;
                                              outerContext : ParserRuleContext)
                                              return Splitted_ConfigSets
      is (configs.splitAccordingToSemanticValidity (outerContext, evalSemanticContext'Access));

   function evalSemanticContext (This : ParserATNSimulator;
                                 predPredictions : PredPrediction_List;
                                 outerContext : ParserRuleContext;
                                 complete : Boolean)
                                 return BitSet is
      predictions : BitSet;
   begin
      for pair of predPredictions loop
         if pair.pred = SemanticContext.Empty.Instance then
            predictions.set (pair.alt); -- try!
            exit when not complete;
            goto CONTINUE;
         end if;

         fullCtx : constant := False; -- in dfa
         predicateEvaluationResult : constant := evalSemanticContext (pair.pred, outerContext, pair.alt, fullCtx);
         if This.debug or else This.dfa_debug then
            Wide_Wide_Text_IO.Put_Line ("eval pred " & pair'Image & "= " & predicateEvaluationResult'Image);
         end if;

         if predicateEvaluationResult then
            if This.debug or else This.dfa_debug then
               Wide_Wide_Text_IO.Put_Line ("PREDICT " & pair.alt);
            end if;
            predictions.set (pair.alt); -- try!
            exit when not complete;
         end if;
         <<CONTINUE>>
      end loop;
      return predictions;
   end evalSemanticContext;

   function evalSemanticContext (This : ParserATNSimulator;
                                 pred : SemanticContext;
                                 parserCallStack : ParserRuleContext;
                                 alt : Integer;
                                 fullCtx : Boolean)
                                 return Boolean
      is (pred.eval (parser, parserCallStack));

   --
   -- TODO: If we are doing predicates, there is no point in pursuing
   -- closure operations if we reach a DFA state that uniquely predicts
   -- alternative. We will not be caching that DFA state and it is a
   -- waste to pursue the closure. Might have to advance when we do
   -- ambig detection thought :(
   --
   procedure closure (This : ParserATNSimulator;
                      config : ATNConfig;
                      configs : ATNConfigSet;
                      closureBusy : in out Set_of_ATNConfigs;
                      collectPredicates : Boolean;
                      fullCtx : Boolean;
                      treatEofAsEpsilon : Boolean) is
      initialDepth : constant Integer := 0;
   begin
      This.closureCheckingStopState (config, configs, closureBusy, collectPredicates, fullCtx, initialDepth, treatEofAsEpsilon);

      pragma assert (not fullCtx or else not configs.dipsIntoOuterContext, "Expected: not fullCtx or not configs.dipsIntoOuterContext");
   end closure;

   procedure closureCheckingStopState (This : ParserATNSimulator;
                                       config : ATNConfig;
                                       configs : ATNConfigSet;
                                       closureBusy : in out Set_of_ATNConfigs;
                                       collectPredicates : Boolean;
                                       fullCtx : Boolean;
                                       depth : Integer;
                                       treatEofAsEpsilon : Boolean) is
   begin
      if This.debug then
         Wide_Wide_Text_IO.Put_Line ("closure (" & config.toString (parser, True) & ')');
      end if;

      if config.state'Tag = RuleStopState'Tag then
         configContext : constant PredictionContext := Value (config.context); -- !
         -- We hit rule end. If we have context info, use it
         -- run thru all possible stack tops in ctx
         if not This.configContext.isEmpty then
            length : constant := This.configContext.size;
            for i in 0 .. length - 1 loop
                  if configContext.getReturnState (i) == PredictionContext.EMPTY_RETURN_STATE then
                     if fullCtx then
                        configs.add (ATNConfig (config, config.state, EmptyPredictionContext.Instance), This.mergeCache); -- try!
                        goto CONTINUE;
                     else
                        -- we have no context info, just chase follow links (if greedy);
                        if This.debug then
                           Wide_Wide_Text_IO.Put_Line ("FALLING off rule" & getRuleName (config.state.ruleIndex!));
                        end if;
                        closure_2 (config, configs, closureBusy'Access, collectPredicates,
                              fullCtx, depth, treatEofAsEpsilon);
                     end if;
                     goto CONTINUE;
                  end if;
                  returnState : constant ATNState := atn.states[configContext.getReturnState (i)]!;
                  newContext : constant Optional_PredictionContext := configContext.getParent (i); -- "pop" return state;
                  c : constant ATNConfig := ATNConfig (returnState, config.alt, newContext,
                     config.semanticContext);
                  -- While we have context to pop back from, we may have
                  -- gotten that context AFTER having falling off a rule.
                  -- Make sure we track that we are now out of context.
                  --
                  -- This assignment also propagates the
                  -- This.isPrecedenceFilterSuppressed value to the new
                  -- configuration.
                  c.reachesIntoOuterContext := config.reachesIntoOuterContext
                  pragma assert (depth > Int.min, "Expected: depth>Integer.MIN_VALUE");
                  closureCheckingStopState (c, configs, closureBusy'Access, collectPredicates,
                     fullCtx, depth - 1, treatEofAsEpsilon);
                  <<CONTINUE>>
            end loop;
            return
         end if; elsif fullCtx then
            -- reached end of start rule
            configs.add (config, This.mergeCache); -- try!
            return
         else
            -- else if we have no context info, just chase follow links (if greedy);
            if This.debug then
                  Wide_Wide_Text_IO.Put_Line ("FALLING off rule " & getRuleName (Value (config.state.ruleIndex)));
            end if;

         end if;
      end if;
      This.closure_2 (config, configs, closureBusy'Access, collectPredicates, fullCtx, depth, treatEofAsEpsilon);
   end closureCheckingStopState;

   --
   -- Do the actual work of walking epsilon edges
   --
   procedure closure_2 (This : ParserATNSimulator;
                        config : ATNConfig;
                        configs : ATNConfigSet;
                        closureBusy : in out Set_of_ATNConfigs,
                        collectPredicates : Boolean;
                        fullCtx : Boolean;
                        depth : Integer;
                        treatEofAsEpsilon : Boolean;
                        Function_Name : UString) is
         p : constant := config.state;
         length : constant := This.p.getNumberOfTransitions;
         startTime, finishTime : constant Real_Time.Time;
      begin

      <<CROSSCUT_JOINPOINT_START_PROFILE_TIMINGS>>
      if Is_Active (Aspect.PROFILE_TIMINGS) then
         Wide_Wide_Text_IO.Put_Line (Function_Name);   
         startTime := Real_Time.Clock;
         -- optimization
      end if;

      if not This.p.onlyHasEpsilonTransitions then
         configs.add (config, This.mergeCache); -- try!
         -- make sure to not return here, because EOF transitions can act as
         -- both epsilon transitions and non-epsilon transitions.
         if Is_Active (Aspect.DEBUG) then
            if This.debug then
               Wide_Wide_Text_IO.Put_Line ("added config " & configs'Image);
            end if;
         end if;
      end if;
      for i in 0 .. length - 1 loop
         if i = 0 and then canDropLoopEntryEdgeInLeftRecursiveRule (config) then
            goto CONTINUE;
         end if;
         t : constant := p.transition (i);
         continueCollecting : constant Boolean := not (t is ActionTransition) and then collectPredicates;
         c : constant := getEpsilonTarget (config, t, continueCollecting, depth = 0, fullCtx, treatEofAsEpsilon);
         if Is_Valid (c) then
            newDepth := depth;
            if config.state'Tag = RuleStopState'Tag then
               pragma assert (not fullCtx, "Expected: not fullCtx");
               -- target fell off end of rule; mark resulting c as having dipped into outer context
               -- We can't get here if incoming config was rule stop and we had context
               -- track how far we dip into outer context.  Might
               -- come in handy and we avoid evaluating context dependent
               -- preds if this is > 0.
               if Is_Valid (This.dfa) and then This.$1dfa.isPrecedenceDfa then
                  outermostPrecedenceReturn : constant Integer := EpsilonTransition ((t);).outermostPrecedenceReturn ();
                  if outermostPrecedenceReturn = This.dfa.atnStartState.ruleIndex then
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

               configs.dipsIntoOuterContext := True; -- TODO: can remove? only care when we add to set per middle of this method
               if Is_Active (Aspect.DEBUG) then
                  Wide_Wide_Text_IO.Put ("newDepth=>" & newDepth'Image);
               end if;

               pragma assert (newDepth > Int.min, "Expected: newDepth>Integer.MIN_VALUE");
               newDepth := @ - 1;

               if This.debug then
                  Wide_Wide_Text_IO.Put_Line ("dips into outer ctx: " & c'Image);
               end if;
            else
               if not This.t.isEpsilon then
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

            closureCheckingStopState (c, configs, closureBusy'Access, continueCollecting,
                  fullCtx, newDepth, treatEofAsEpsilon);
         end if;
         <<CONTINUE>>
      end loop;

      <<CROSSCUT_JOINPOINT_STOP_PROFILE_TIMINGS>>
      if Is_Active (Aspect.PROFILE_TIMINGS) then
         finishTime := Real_Time.Clock;
         if (finishTime - startTime) > 1; --TOFIX
            Wide_Wide_Text_IO.Put_Line ("That took: " & (Real_Time.To_Duration (finishTime - startTime) * 1_000.0)'Image & " ms");
         end if,
      end if;
   end closure_2;

   function canDropLoopEntryEdgeInLeftRecursiveRule (This : ParserATNSimulator; config : ATNConfig) return Boolean is
   begin
      if TURN_OFF_LR_LOOP_ENTRY_BRANCH_OPT then
         return False;
      end if;
      p : constant ATNState := config.state;
      configContext : constant PredictionContext := config.context;
      if not Is_Valid (configContext) then
            return False;
      end if;
      -- First check to see if we are in StarLoopEntryState generated during
      -- left-recursion elimination. For efficiency, also check if
      -- the context has an empty stack case. If so, it would mean
      -- global FOLLOW so we can't perform optimization
      if p.getStateType /= STAR_LOOP_ENTRY
         or else not ( (StarLoopEntryState (p))).precedenceRuleDecision
         or else -- Are we the special loop entry/exit state?
            This.configContext.isEmpty
         or else -- If SLL wildcard
            This.configContext.hasEmptyPath then
            return False;
      end if;

      -- Require all return states to return back to the same rule
      -- that p is in.
      numCtxs : constant := This.configContext.size;
      for  i in 0 ..< numCtxs loop -- for each stack context
         returnState : constant := atn.states[configContext.getReturnState (i)]!
         if  returnState.ruleIndex /= p.ruleIndex then
            return False;
         end if;
      end if;

      decisionStartState : constant BlockStartState := BlockStartState (p.transition (0).target);
      blockEndStateNum : constant := Value (decisionStartState.endState).stateNumber;
      blockEndState : constant BlockEndState := BlockEndState (atn.states.Element (blockEndStateNum));

      -- Verify that the top of each stack context leads to loop entry/exit
      -- state through epsilon edges and w/o leaving rule.
      for  i in 0 .. numCtxs - 1 loop -- for each stack context
         returnStateNumber : constant := configContext.getReturnState (i);
         returnState : constant := Value (atn.states.Element (returnStateNumber));
         -- all states must have single outgoing epsilon edge
         if This.returnState.getNumberOfTransitions /= 1
         or else not returnState.transition (0).isEpsilon then
            return False;
         end if;
         -- Look for prefix op case like 'not expr', (' type ')' expr
         returnStateTarget : constant := returnState.transition (0).target;
         if This.returnState.getStateType = BLOCK_END
         and then returnStateTarget = p then
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
         if This.returnStateTarget.getStateType = BLOCK_END
         and then This.returnStateTarget.getNumberOfTransitions = 1
         and then returnStateTarget.transition (0).isEpsilon
         and then returnStateTarget.transition (0).target = p then
            goto CONTINUE;
         end if;

         -- anything else ain't conforming
         return False;
         <<CONTINUE>>
      end loop;
      return True;
   end canDropLoopEntryEdgeInLeftRecursiveRule;

   function getRuleName (This : ParserATNSimulator; index : Integer) return UString is
   begin
      if index >= 0  then
         return This.parser.getRuleNames[index];
      else
         return "<rule " & index'Image & '>'';
      end if;
   end getRuleName;

   function getEpsilonTarget (This : ParserATNSimulator;
                              config : ATNConfig;
                              t : ATNTransition;
                              collectPredicates : Boolean;
                              inContext : Boolean;
                              fullCtx : Boolean;
                              treatEofAsEpsilon : Boolean)
                              return Optional_ATNConfig is
   begin
      case This.t.getSerializationType is

         when Transition.RULE =>
            return ruleTransition (config, RuleTransition (t));

         when Transition.PRECEDENCE =>
            return precedenceTransition (config, PrecedencePredicateTransition (t), collectPredicates, inContext, fullCtx);

         when Transition.PREDICATE =>
            return predTransition (config, PredicateTransition (t),
               collectPredicates,
               inContext,
               fullCtx);

         when Transition.ACTION =>
            return actionTransition (config, ActionTransition (t));

         when Transition.EPSILON =>
            return ATNConfig (config, t.target);

         when Transition.ATOM  => -- fallthrough;
            return  (Valid => False);

         when TRANSITION_RANGE => -- fallthrough;
            return  (Valid => False);

         when Transition.SET   =>
            -- EOF transitions act like epsilon transitions after the first EOF
            -- transition is traversed
            if treatEofAsEpsilon then
               if t.matches (CommonToken.EOF, 0, 1) then
                  return ATNConfig (config, t.target);
               end if;
            end if;
            return  (Valid => False);

         when others =>
            return  (Valid => False);
      end case;
   end getEpsilonTarget;

   function actionTransition (This : ParserATNSimulator;
                              config : ATNConfig;
                              t : ActionTransition)
                              return ATNConfig is
   begin
      if This.debug then
         Wide_Wide_Text_IO.Put_Line ("ACTION edge " & t.ruleIndex & ':' & t.actionIndex);
      end if;
      return ATNConfig (config, t.target);
   end actionTransition;

   function precedenceTransition (This : ParserATNSimulator;config : ATNConfig;
                                  pt : PrecedencePredicateTransition;
                                  collectPredicates : Boolean;
                                  inContext : Boolean;
                                  fullCtx : Boolean) return Optional_ATNConfig is
   begin
      if This.debug then
         Wide_Wide_Text_IO.Put_Line ("PRED (collectPredicates=" & collectPredicates'Image & ") " & pt.precedence & ">=_p, ctx dependent=True");
         -- if parser /= (Valid => False) then
               Wide_Wide_Text_IO.Put_Line ("context surrounding pred is " & parser.getRuleInvocationStack ());
         -- end if;
      end if;

      c : Optional_ATNConfig;
      if collectPredicates and then inContext then
         if fullCtx then
            -- In full context mode, we can evaluate predicates on-the-fly
            -- during closure, which dramatically reduces the size of
            -- the config sets. It also obviates the need to test predicates
            -- later during conflict resolution.
            currentPosition : constant Integer := This.input.index;
            This.input.seek (This.startIndex);
            predSucceeds : constant Boolean := evalSemanticContext (This.pt.getPredicate, This.outerContext, config.alt, fullCtx);
            This.input.seek (currentPosition);
            if predSucceeds then
               c := ATNConfig (config, pt.target);  -- no pred context
            end if;
         else
            newSemCtx : constant SemanticContext := SemanticContext.and (config.semanticContext, This.pt.getPredicate);
            c := ATNConfig (config, pt.target, newSemCtx);
         end if;
      else
         c := ATNConfig (config, pt.target);
      end if;

      if This.debug then
         Wide_Wide_Text_IO.Put_Line ("config from pred transition=" & c?'Image, Default => (Valid => False) & ')'); --TOFIX
      end if;
      return c;
   end precedenceTransition;

   function predTransition (This : ParserATNSimulator;config : ATNConfig;
                              pt : PredicateTransition;
                              collectPredicates : Boolean;
                              inContext : Boolean;
                              fullCtx : Boolean) return Optional_ATNConfig is
   begin
      if This.debug then
         Wide_Wide_Text_IO.Put_Line ("PRED (collectPredicates=" & collectPredicates'Image & ") " & pt.ruleIndex & ':' & pt.predIndex & ", ctx dependent=" & pt.isCtxDependent);
         -- if parser /=  (Valid => False) then
         Wide_Wide_Text_IO.Put_Line ("context surrounding pred is " & This.parser.getRuleInvocationStack);
         -- end if;
      end if;

      c : Optional_ATNConfig;
      if collectPredicates
      and then (not pt.isCtxDependent or else (pt.isCtxDependent and then inContext)) then
         if fullCtx then
            -- In full context mode, we can evaluate predicates on-the-fly
            -- during closure, which dramatically reduces the size of
            -- the config sets. It also obviates the need to test predicates
            -- later during conflict resolution.
            currentPosition : constant Integer := This.input.index;
            This.input.seek (This.startIndex);
            predSucceeds : constant Boolean := evalSemanticContext (This.pt.getPredicate, This.outerContext, config.alt, fullCtx);
            This.input.seek (currentPosition);
            if predSucceeds then
               c := ATNConfig (config, pt.target);  -- no pred context
            end if;
         else
            newSemCtx : constant := SemanticContext.and (config.semanticContext, This.pt.getPredicate);
            c := ATNConfig (config, pt.target, newSemCtx);
         end if;
      else
         c := ATNConfig (config, pt.target);
      end if;

      if This.debug then
         Wide_Wide_Text_IO.Put_Line ("config from pred transition=" & c?'Image, Default => (Valid => False) & ')'); --TOFIX
      end if;
      return c
   end precedenceTransition;

   function ruleTransition (This : ParserATNSimulator; config : ATNConfig; t : RuleTransition) return ATNConfig is
      returnState : constant ATNState := t.followState;
      newContext : constant SingletonPredictionContext := SingletonPredictionContext.create (config.context, returnState.stateNumber);
   begin
      if This.debug then
         Wide_Wide_Text_IO.Put_Line ("CALL rule " & getRuleName (t.target.ruleIndex!) & ", ctx=" & config.context?'Image, Default => (Valid => False) & ')');
      end if;

      return ATNConfig (config, t.target, newContext);
   end ruleTransition;

   function getConflictingAlts (This : ParserATNSimulator; configs : ATNConfigSet) return BitSet is
      altsets : constant PredictionMode := PredictionModes.getConflictingAltSubsets (configs);
   begin
      return PredictionModes.getAlts (altsets);
   end getConflictingAlts;

   function getConflictingAltsOrUniqueAlt (This : ParserATNSimulator; configs : ATNConfigSet) return BitSet is
      conflictingAlts : BitSet;
   begin
      if configs.uniqueAlt /= ATN.INVALID_ALT_NUMBER then
         conflictingAlts := This.BitSet;
         conflictingAlts.set (configs.uniqueAlt); -- try!
      else
         conflictingAlts := Value (configs.conflictingAlts);
      end if;
      return conflictingAlts;
   end getConflictingAltsOrUniqueAlt;

   function getTokenName (This : ParserATNSimulator; t : Integer) return UString is
   begin
      if t = CommonToken.EOF then
         return "EOF";
      else
         vocabulary : constant Vocabulary := This.parser.getVocabulary;
         displayName : constant UString := vocabulary.getDisplayName (t);
         if displayName = UString (t) then
            return displayName;
         else
            return displayName'Image & " <" & t'Image & '>';
         end if;
      end if;
   end getTokenName;

   procedure dumpDeadEndConfigs (This : ParserATNSimulator; nvae : NoViableAltException) is
   begin
      Wide_Wide_Text_IO.Put_Line (Standard_Error, "dead end configs: ");
      for c of nvae.getDeadEndConfigs ()!.configs loop
         trans := "no edges";
         if c.state.getNumberOfTransitions > 0 then
            t : constant Transition := c.state.transition (0);
            at : constant Optional_AtomTransition := Maybe (t);
            if Is_Valid (at) then
               trans := "Atom " & getTokenName (at.label);
            else
               st : constant SetTransition := SetTransition (t);
               if Is_Valid (st) then
                  not_sign : constant Boolean := st'Tag = NotSetTransition'Tag;
                  if not_sign then
                     trans := "~"  & "Set " & st.set'Image;
                  else
                     trans := "" & "Set " & st.set'Image;
                  end if;
               end if;
            end if;
         end if;
         Wide_Wide_Text_IO.Put_Line (Standard_Error, c.toString (parser, True) & ':' & trans'Image);
      end loop;
   end dumpDeadEndConfigs;

   function noViableAlt (This : ParserATNSimulator;
                         input : TokenStream;
                         outerContext : ParserRuleContext;
                         configs : ATNConfigSet;
                         startIndex : Integer)
                         return NoViableAltException is
      startToken : constant Token'Class := input.get (startIndex); -- try!
   begin
      offendingToken : Optional_Token; := (Valid => False);
      begin
         offendingToken := input.LT (1);
      exception
         when others => null;
      end;
      return This.NoViableAltException (parser, input, startToken, offendingToken, configs, outerContext);
   end noViableAlt;

   function addDFAEdge (This : ParserATNSimulator;
                        dfa : DFA;
                        from : DFAState;
                        t : Integer;
                        to : DFAState)
                        return DFAState is
      to_var : DFAState := to;

      function Closure return … is
      begin
         [unowned This] in
         if from.edges =  (Valid => False) then
            from.edges := [DFAState?](repeating:  (Valid => False), count => This.atn.maxTokenType + 1 + 1);  --new DFAState[atn.maxTokenType+1+1];
         end if;

         from.edges[t + 1] := to -- connect
      end Closure;
      closure_2Return_Value : …;
      function Synchronized_Closure is new Mutex.Gen_Closure (Closure => Closure, Result_Type => …);

   begin
      if This.debug then
         Wide_Wide_Text_IO.Put_Line ("EDGE " & from'Image & " -> " & to'Image & " upon " & getTokenName (t));
      end if;

      to_var := addDFAState (dfa, to_var) -- used existing if possible not incoming
      if t < -1 or else t > atn.maxTokenType then
         return to_var;
      else
         from.Mutex.Run (Synchronized_Closure'Access, closure_2Return_Value);
         --TOFIX return closure_2Return_Value;
         if This.debug then
               Wide_Wide_Text_IO.Put_Line ("DFA=\n" & dfa.toString (This.parser.getVocabulary));
         end if;

         return to_var;
      end if;
   end addDFAEdge;

   function addDFAState (This : ParserATNSimulator; dfa : DFA; D : DFAState) return DFAState is

      function Closure return DFAState is
      begin
         if existing : constant := dfa.states.Element (D) then
            return existing;
         end if;

         D.stateNumber := dfa.states.count;

         if not D.configs.isReadonly then
            D.configs.optimizeConfigs (This); -- try!
            D.configs.setReadonly (True);
         end if;

         dfa.states.Insert (Key => D, New_Item => D);
         if This.debug then
            Wide_Wide_Text_IO.Put_Line ("adding new DFA state: " & D'Image);
         end if;

         return D;
      end Closure;

      closure_2Return_Value : DFAState;
      function Synchronized_Closure is new Mutex.Gen_Closure (Closure => Closure, Result_Type => DFAState);

   begin
      if D = ERROR then
         return D;
      end if;

      dfa.statesMutex.Run (Synchronized_Closure'Access, closure_2Return_Value);
      return closure_2Return_Value;
   end addDFAState;

   procedure reportAttemptingFullContext (This : ParserATNSimulator;
                                          dfa : DFA;
                                          conflictingAlts : Optional_BitSet;
                                          configs : ATNConfigSet;
                                          startIndex, stopIndex : Integer) is
   begin
      if This.debug or else This.retry_debug then
         input : constant := getTextInInterval (startIndex, stopIndex);
         Wide_Wide_Text_IO.Put_Line ("reportAttemptingFullContext decision=" & dfa.decision & ':' & configs'Image & ", input=" & input'Image);
      end if;
      This.parser.getErrorListenerDispatch.reportAttemptingFullContext (parser, dfa, startIndex, stopIndex, conflictingAlts, configs);
   end reportAttemptingFullContext;

   procedure reportContextSensitivity (This : ParserATNSimulator;
                                       dfa : DFA;
                                       prediction : Integer;
                                       configs : ATNConfigSet;
                                       startIndex, stopIndex : Integer) is
   begin
      if This.debug or else This.retry_debug then
         input : constant := getTextInInterval (startIndex, stopIndex);
         Wide_Wide_Text_IO.Put_Line ("reportContextSensitivity decision=" & dfa.decision & ':' & configs'Image & ", input=" & input'Image);
      end if;

      This.parser.getErrorListenerDispatch.reportContextSensitivity (parser, dfa, startIndex, stopIndex, prediction, configs);
   end reportContextSensitivity;

   procedure reportAmbiguity (This : ParserATNSimulator;
                              dfa : DFA;
                              D : DFAState; -- the DFA state from This.execATN that had SLL conflicts
                              startIndex, stopIndex : Integer;
                              exact : Boolean;
                              ambigAlts : BitSet;
                              configs : ATNConfigSet) is
   begin
      if This.debug or else This.retry_debug then
         input : constant := getTextInInterval (startIndex, stopIndex);
         Wide_Wide_Text_IO.Put_Line ("reportAmbiguity " & ambigAlts'Image & ':' & configs'Image & ", input=" & input'Image);
      end if;

      This.parser.getErrorListenerDispatch.reportAmbiguity (parser, dfa, startIndex, stopIndex,
            exact, ambigAlts, configs);
   end reportAmbiguity;

   function getTextInInterval (This : ParserATNSimulator;
                               startIndex, stopIndex : Integer)
                              return UString is
      interval : constant := Interval.Set (startIndex, stopIndex);
   begin
      return This.parser.getTokenStream?.getText (interval), Default => "<unknown>";
   exception
      when others =>
         return "<unknown>";
   end getTextInInterval;

   procedure setPredictionMode (This : ParserATNSimulator; mode : PredictionMode) is
   begin
      This.mode := mode;
   end setPredictionMode;

end ANTLR.Runtime.ATN.Simulators.Parsers;
