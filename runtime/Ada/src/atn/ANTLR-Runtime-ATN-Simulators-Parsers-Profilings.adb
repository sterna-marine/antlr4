-- €

with ANTLR.Runtime.ATN.States;
with ANTLR.Runtime.ATN.Simulators;
with ANTLR.Runtime.ATN.Transitions;
with ANTLR.Runtime.ATN.DecisionInfo;
with ANTLR.Runtime.DFA.States;

use ANTLR.Runtime.ATN.Simulators.Parsers;
use ANTLR.Runtime.ATN.DecisionInfo;
use ANTLR.Runtime.DFA.States;

package body ANTLR.Runtime.ATN.Simulators.Parsers.Profilings is

   -- public
   type ProfilingATNSimulator is new ParserATNSimulator with
   record
      -- private (set);
      decisions: DecisionInfo_List; -- := DecisionInfo.Container.Empty_Vector;
      -- internal
      numDecisions : Integer := 0;
      -- internal
      _sllStopIndex : Integer := 0;
      -- internal
      _llStopIndex : Integer := 0;
      -- internal
      currentDecision : State := INVALID; --TOFIX
      -- internal
      currentState : Optional_DFAState;

      --
      -- At the point of LL failover, we record how SLL would resolve the conflict so that
      -- we can determine whether or not a decision / input pair is context-sensitive.
      -- If LL gives a different result than SLL's predicted alternative, we have a
      -- context sensitivity for sure. The converse is not necessarily True, however.
      -- It's possible that after conflict resolution chooses minimum alternatives,
      -- SLL could get the same answer as LL. Regardless of whether or not the result indicates
      -- an ambiguity, it is not treated as a context sensitivity because LL prediction
      -- was not required in order to produce a correct prediction for this decision and input sequence.
      -- It may in fact still be a context sensitivity but we don't know by looking at the
      -- minimum alternatives for the current input.
      --
      -- internal
      conflictingAltResolvedBySLL : Integer := 0;
   end record;

   -- public
   procedure Initialize (Self : in out ProfilingATNSimulator; parser : Parser) is
   begin
      Self.decisions := DecisionInfo.Container.Empty_Vector;
      Super (Self).Initialize (
                              parser,
                              parser.getInterpreter ().atn,
                              parser.getInterpreter ().decisionToDFA,
                              parser.getInterpreter ().sharedContextCache); -- super

      Self.numDecisions := atn.decisionToState.count;
      for i in 0 .. numDecisions - 1 loop
         Self.decisions.append (DecisionInfo (i));
      end loop;
   end Initialize;

   -- public
   overriding
   function adaptivePredict (This : ProfilingATNSimulator;
                             input : TokenStream;
                             decision : Integer;
                             outerContext : Optional_ParserRuleContext)
                             return Integer is
      outerContext : constant := outerContext;
      start : constant := ProcessInfo.processInfo.systemUptime --System.nanoTime (); -- expensive but useful info
      alt : constant Integer := ParserATNSimulator.adaptivePredict (This, input, decision, outerContext);
      stop : constant := ProcessInfo.processInfo.systemUptime  --System.nanoTime ();
      LL_k : Integer_64;
   begin
      This._sllStopIndex := -1;
      This._llStopIndex := -1;
      This.currentDecision := decision;
      This.decisions.Element (decision).timeInPrediction := @ + Integer_64 ((stop - start) * TimeInterval (1_000_000_000)); -- Nanoseconds per 1 Second
      This.decisions.Element (decision).invocations := @ + 1;

      SLL_k : constant Integer_64 := Integer_64 (This._sllStopIndex - This._startIndex + 1);
      This.decisions.Element (decision).SLL_TotalLook := @ + SLL_k;
      
      if This.decisions.Element (decision).SLL_MinLook = 0 then 
         This.decisions.Element (decision).SLL_MinLook := SLL_k;
      else
         This.decisions.Element (decision).SLL_MinLook := min (This.decisions.Element (decision).SLL_MinLook, SLL_k);
      end if;

      if SLL_k > This.decisions.Element (decision).SLL_MaxLook then
         This.decisions.Element (decision).SLL_MaxLook := SLL_k;
         This.decisions.Element (decision).SLL_MaxLookEvent :=
                  LookaheadEventInfo (decision, null, input, This._startIndex, This._sllStopIndex, False);
      end if;

      if This._llStopIndex >= 0 then
         LL_k := Integer_64 (This._llStopIndex - This._startIndex + 1);
         This.decisions.Element (decision).LL_TotalLook := @ + LL_k;
         
         if This.decisions.Element (decision).LL_MinLook = 0 then
            This.decisions.Element (decision).LL_MinLook := LL_k;
         else
            This.decisions.Element (decision).LL_MinLook := min (This.decisions.Element (decision).LL_MinLook, LL_k);
         end if;

         if LL_k > This.decisions.Element (decision).LL_MaxLook then
               This.decisions.Element (decision).LL_MaxLook := LL_k
               This.decisions.Element (decision).LL_MaxLookEvent =
                     LookaheadEventInfo (decision, null, input, This._startIndex, This._llStopIndex, True);
         end if;
      end if;

      defer {
         This.currentDecision := -1
      end if;
      return alt
   end adaptivePredict;

   -- internal
   overriding
   function getExistingTargetState (This : ProfilingATNSimulator; previousD : DFAState; t : Integer) return Optional_DFAState is
   begin
      -- this method is called after each time the input position advances
      -- during SLL prediction
      This._sllStopIndex := _input.index ();

      existingTargetState : constant Optional_DFAState; := ParserATNSimulator.getExistingTargetState (This, previousD, t);
      if Is_Valid (existingTargetState) then
         This.decisions.Element (This.currentDecision).SLL_DFATransitions := @ + 1; -- count only if we transition over a DFA state
         if existingTargetState = ATNSimulator.ERROR then
               This.decisions.Element (This.currentDecision).errors.append (
               ErrorInfo (This.currentDecision, previousD.configs, _input, This._startIndex, This._sllStopIndex, False);
               );
         end if;
      end if;

      This.currentState := existingTargetState
      return existingTargetState
   end getExistingTargetState;

   -- internal
   overriding
   function computeTargetState (This : ProfilingATNSimulator; dfa : DFA; previousD : DFAState; t : Integer) return DFAState is
   begin
      state : constant := ParserATNSimulator.computeTargetState (This, dfa, previousD, t);
      This.currentState := state
      return state
   end computeTargetState;

   overriding
   -- internal
   function computeReachSet (This : ProfilingATNSimulator; closure : ATNConfigSet; t : Integer; fullCtx  : Boolean) return Optional_ATNConfigSet is
   begin
      if fullCtx then
         -- this method is called after each time the input position advances
         -- during full context prediction
         This._llStopIndex := _input.index ();
      end if;

      reachConfigs : constant := ParserATNSimulator.computeReachSet (This, closure, t, fullCtx);
      if fullCtx then
         This.decisions.Element (This.currentDecision).LL_ATNTransitions := @ + 1; -- count computation even if error
         if Is_Valid (reachConfigs) then
         else
               -- no reach on current lookahead symbol. ERROR.
               -- TODO: does not handle delayed errors per getSynValidOrSemInvalidAltThatFinishedDecisionEntryRule ();
               This.decisions.Element (This.currentDecision).errors.append (
               ErrorInfo (This.currentDecision, closure, _input, This._startIndex, This._llStopIndex, True);
               );
         end if;
      else
         This.decisions.Element (This.currentDecision).SLL_ATNTransitions := @ + 1;
         if Is_Valid (reachConfigs) then
         else
               -- no reach on current lookahead symbol. ERROR.
               This.decisions.Element (This.currentDecision).errors.append (
               ErrorInfo (This.currentDecision, closure, _input, This._startIndex, This._sllStopIndex, False);
               );
         end if;
      end if;
      return reachConfigs
   end computeReachSet;

   -- internal
   overriding
   function evalSemanticContext (This : ProfilingATNSimulator; pred : SemanticContext; parserCallStack : ParserRuleContext; alt : Integer; fullCtx  : Boolean) return Boolean is
   begin
      result : constant := ParserATNSimulator.evalSemanticContext (This, pred, parserCallStack, alt, fullCtx);
      if not (pred is SemanticContext.PrecedencePredicate) then
         fullContext : constant := This._llStopIndex >= 0
         stopIndex : constant := fullContext ? This._llStopIndex : This._sllStopIndex
         This.decisions.Element (This.currentDecision).predicateEvals.append (
               PredicateEvalInfo (This.currentDecision, _input, This._startIndex, stopIndex, pred, result, alt, fullCtx);
         );
      end if;

      return result
   end evalSemanticContext;

   -- internal
   overriding
   procedure reportAttemptingFullContext (This : ProfilingATNSimulator; dfa : DFA; conflictingAlts : Optional_BitSet; configs : ATNConfigSet; startIndex : Integer; stopIndex : Integer) is
   begin
      if conflictingAlts : constant := conflictingAlts then
         This.conflictingAltResolvedBySLL := conflictingAlts.firstSetBit ();
      else
         configAlts : constant := configs.getAlts ();
         This.conflictingAltResolvedBySLL := configAlts.firstSetBit ();
      end if;
      This.decisions.Element (This.currentDecision).LL_Fallback := @ + 1;
      ParserATNSimulator.reportAttemptingFullContext (This, dfa, conflictingAlts, configs, startIndex, stopIndex);
   end reportAttemptingFullContext;

   -- internal
   overriding
   procedure reportContextSensitivity (This : ProfilingATNSimulator; dfa : DFA; prediction : Integer; configs : ATNConfigSet; startIndex : Integer; stopIndex : Integer) is
   begin
      if prediction /= This.conflictingAltResolvedBySLL then
         This.decisions.Element (This.currentDecision).contextSensitivities.append (
         ContextSensitivityInfo (This.currentDecision, configs, _input, startIndex, stopIndex);
         );
      end if;
      ParserATNSimulator.reportContextSensitivity (This, dfa, prediction, configs, startIndex, stopIndex);
   end reportContextSensitivity;

   -- internal
   overriding
   procedure reportAmbiguity (This : ProfilingATNSimulator; dfa : DFA; D : DFAState; startIndex : Integer; stopIndex : Integer; exact : Boolean;
                                 ambigAlts : Optional_BitSet; configs : ATNConfigSet) {
      prediction : Integer;
      if ambigAlts : constant := ambigAlts then
         prediction := ambigAlts.firstSetBit ();
      else
         configAlts : constant := configs.getAlts ();
         prediction := configAlts.firstSetBit ();
      end if;
      if configs.fullCtx and then prediction /= This.conflictingAltResolvedBySLL then
         -- Even though this is an ambiguity we are reporting, we can
         -- still detect some context sensitivities.  Both SLL and LL
         -- are showing a conflict, hence an ambiguity, but if they resolve
         -- to different minimum alternatives we have also identified a
         -- context sensitivity.
         This.decisions.Element (This.currentDecision).contextSensitivities.append (
         ContextSensitivityInfo (This.currentDecision, configs, _input, startIndex, stopIndex);
         );
      end if;
      This.decisions.Element (This.currentDecision).ambiguities.append (
      AmbiguityInfo (This.currentDecision, configs, ambigAlts!,
               _input, startIndex, stopIndex, configs.fullCtx);
      );
      ParserATNSimulator.reportAmbiguity (This, dfa, D, startIndex, stopIndex, exact, ambigAlts!, configs);
   end reportAmbiguity;

   -- public
   function getDecisionInfo (This : ProfilingATNSimulator) return DecisionInfo_Container.Vector
      is (This.decisions);

end ANTLR.Runtime.ATN.Simulators.Parsers.Profilings;
