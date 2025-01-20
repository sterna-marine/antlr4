-- €

with Ada.Real_Time;

use Ada;

package body ANTLR.Runtime.ATN.Simulators.Parsers.Profilings is

   procedure Initialize (Self : in out ProfilingATNSimulator; parser : Parser) is
   begin
      Self.decisions := DecisionInfo.Container.Empty_Vector;
      Super (Self).Initialize (parser,
                               parser.getInterpreter.atn,
                               parser.getInterpreter.decisionToDFA,
                               parser.getInterpreter.sharedContextCache);
      Self.numDecisions := atn.decisionToState.count;
      for i in 0 .. numDecisions - 1 loop
         Self.decisions.append (DecisionInfo (i));
      end loop;
   end Initialize;

   overriding
   function adaptivePredict (This : ProfilingATNSimulator;
                             input : TokenStream;
                             decision : State;
                             outerContext : Optional_ParserRuleContext)
                             return Integer is
      outerContext : constant Optional_ParserRuleContext := outerContext;
      Start, Stop : Real_Time.Time;
      alt : constant Integer;
      LL_k, SLL_k : Long_Long_Integer;
   begin
      Start := Real_Time.Clock; -- expensive but useful info
      alt   := Super (This).adaptivePredict (input, decision, outerContext);
      Stop  := Real_Time.Clock; -- expensive but useful info

      This.sllStopIndex := -1;
      This.llStopIndex := -1;
      This.currentDecision := decision;
      This.decisions.Element (decision).timeInPrediction := @ + (stop - start); -- seconds
      This.decisions.Element (decision).invocations := @ + 1;

      SLL_k := Long_Long_Integer (This.sllStopIndex - This.startIndex + 1);
      This.decisions.Element (decision).SLL_TotalLook := @ + SLL_k;
      
      if This.decisions.Element (decision).SLL_MinLook = 0 then 
         This.decisions.Element (decision).SLL_MinLook := SLL_k;
      else
         This.decisions.Element (decision).SLL_MinLook := min (This.decisions.Element (decision).SLL_MinLook, SLL_k);
      end if;

      if SLL_k > This.decisions.Element (decision).SLL_MaxLook then
         This.decisions.Element (decision).SLL_MaxLook := SLL_k;
         This.decisions.Element (decision).SLL_MaxLookEvent := LookaheadEventInfo (
                   decision => decision,
                   configs => (Valid => False),
                   input => input,
                   startIndex => This.startIndex,
                   stopIndex => This.llStopIndex,
                   fullCtx  => False);
      end if;

      if This.llStopIndex >= 0 then
         LL_k := Long_Long_Integer (This.llStopIndex - This.startIndex + 1);
         This.decisions.Element (decision).LL_TotalLook := @ + LL_k;
         
         if This.decisions.Element (decision).LL_MinLook = 0 then
            This.decisions.Element (decision).LL_MinLook := LL_k;
         else
            This.decisions.Element (decision).LL_MinLook := min (This.decisions.Element (decision).LL_MinLook, LL_k);
         end if;

         if LL_k > This.decisions.Element (decision).LL_MaxLook then
               This.decisions.Element (decision).LL_MaxLook := LL_k
               This.decisions.Element (decision).LL_MaxLookEvent = LookaheadEventInfo (
                   decision => decision,
                   configs => (Valid => False),
                   input => input,
                   startIndex => This.startIndex,
                   stopIndex => This.llStopIndex,
                   fullCtx  => True);
         end if;
      end if;

      defer :
         begin
            This.currentDecision := -1;
         end defer;
      return alt;
   end adaptivePredict;

   overriding
   function getExistingTargetState (This : ProfilingATNSimulator;
                                    previousD : DFAState;
                                    t : Integer)
                                    return Optional_DFAState is
   begin
      -- this method is called after each time the input position advances
      -- during SLL prediction
      This.sllStopIndex := This.input.index;

      existingTargetState : constant Optional_DFAState := Super (This).getExistingTargetState (previousD, t);
      if Is_Valid (existingTargetState) then
         This.decisions.Element (This.currentDecision).SLL_DFATransitions := @ + 1; -- count only if we transition over a DFA state
         if existingTargetState = ATNSimulator.ERROR then
            This.decisions.Element (This.currentDecision).errors.append (
               ErrorInfos.Initialize (
                  decision => This.currentDecision,
                  configs => previousD.configs,
                  input => This.input,
                  startIndex => This.startIndex,
                  stopIndex => This.sllStopIndex,
                  fullCtx  => False));
         end if;
      end if;

      This.currentState := existingTargetState;
      return existingTargetState;
   end getExistingTargetState;

   overriding
   function computeTargetState (This : ProfilingATNSimulator;
                                dfa : DFA;
                                previousD : DFAState;
                                t : Integer)
                                return DFAState is
      state : constant DFAState := Super (This).computeTargetState (dfa, previousD, t);
   begin
      This.currentState := state;
      return state;
   end computeTargetState;

   overriding
   function computeReachSet (This : ProfilingATNSimulator;
                             closure : ATNConfigSet;
                             t : Integer;
                             fullCtx  : Boolean)
                             return Optional_ATNConfigSet is
   begin
      if fullCtx then
         -- this method is called after each time the input position advances
         -- during full context prediction
         This.llStopIndex := This.input.index;
      end if;

      reachConfigs : constant ATNConfigSet := Super (This).computeReachSet (closure, t, fullCtx);
      if fullCtx then
         This.decisions.Element (This.currentDecision).LL_ATNTransitions := @ + 1; -- count computation even if error
         if not Is_Valid (reachConfigs) then
            -- no reach on current lookahead symbol. ERROR.
            -- TODO: does not handle delayed errors per This.getSynValidOrSemInvalidAltThatFinishedDecisionEntryRule;
            This.decisions.Element (This.currentDecision).errors.append (
               ErrorInfos.Initialize (
                  decision => This.currentDecision,
                  configs => closure,
                  input => This.input,
                  startIndex => This.startIndex,
                  stopIndex => This.llStopIndex,
                  fullCtx  => True));
         end if;
      else
         This.decisions.Element (This.currentDecision).SLL_ATNTransitions := @ + 1;
         if not Is_Valid (reachConfigs) then
            -- no reach on current lookahead symbol. ERROR.
            This.decisions.Element (This.currentDecision).errors.append (
               ErrorInfos.Initialize (
                  decision => This.currentDecision,
                  configs => closure,
                  input => This.input,
                  startIndex => This.startIndex,
                  stopIndex => This.sllStopIndex,
                  fullCtx  => False));
         end if;
      end if;
      return reachConfigs;
   end computeReachSet;

   overriding
   function evalSemanticContext (This : ProfilingATNSimulator;
                                 pred : SemanticContext;
                                 parserCallStack : ParserRuleContext;
                                 alt : Integer;
                                 fullCtx  : Boolean)
                                 return Boolean is
      stopIndex : Integer;
      result : constant Boolean := Super (This).evalSemanticContext (pred, parserCallStack, alt, fullCtx);
   begin
      if not (pred is SemanticContext.PrecedencePredicate) then

         if This.llStopIndex >= 0 then -- fullContext
            stopIndex := This.llStopIndex;
         else
            stopIndex := This.sllStopIndex;
         end if;

         This.decisions.Element (This.currentDecision).predicateEvals.append (
            PredicateEvalInfos.Initialize (
               decision => This.currentDecision,
               input => This.input,
               startIndex => This.startIndex,
               stopIndex => stopIndex,
               semctx => pred,
               evalResult => result,
               predictedAlt => alt,
               fullCtx  => fullCtx));
      end if;
      return result;
   end evalSemanticContext;

   overriding
   procedure reportAttemptingFullContext (This : ProfilingATNSimulator;
                                          dfa : DFA;
                                          conflictingAlts : Optional_BitSet;
                                          configs : ATNConfigSet;
                                          startIndex, stopIndex : Integer) is
         conflictingAlts : constant := conflictingAlts;
      begin
      if Is_Valid (conflictingAlts) then
         This.conflictingAltResolvedBySLL := conflictingAlts.firstSetBit;
      else
         configAlts : constant := configs.getAlts;
         This.conflictingAltResolvedBySLL := configAlts.firstSetBit;
      end if;
      This.decisions.Element (This.currentDecision).LL_Fallback := @ + 1;
      Super (This).reportAttemptingFullContext (dfa, conflictingAlts, configs, startIndex, stopIndex);
   end reportAttemptingFullContext;

   overriding
   procedure reportContextSensitivity (This : ProfilingATNSimulator;
                                       dfa : DFA;
                                       prediction : Integer;
                                       configs : ATNConfigSet;
                                       startIndex, stopIndex : Integer) is
   begin
      if prediction /= This.conflictingAltResolvedBySLL then
         This.decisions.Element (This.currentDecision).contextSensitivities.append (
            ContextSensitivityInfos.Initialize (
                  decision => This.currentDecision,
                  configs => configs,
                  input => This.input,
                  startIndex => startIndex,
                  stopIndex => stopIndex));
      end if;
      Super (This).reportContextSensitivity (dfa, prediction, configs, startIndex, stopIndex);
   end reportContextSensitivity;

   overriding
   procedure reportAmbiguity (This : ProfilingATNSimulator;
                              dfa : DFA;
                              D : DFAState;
                              startIndex, stopIndex : Integer;
                              exact : Boolean;
                              ambigAlts : Optional_BitSet;
                              configs : ATNConfigSet) is
      prediction : Integer;
   begin   
      if Is_Valid (ambigAlts) then
         prediction := ambigAlts.firstSetBit;
      else
         configAlts : constant := configs.getAlts;
         prediction := configAlts.firstSetBit;
      end if;
      if configs.fullCtx and then prediction /= This.conflictingAltResolvedBySLL then
         -- Even though this is an ambiguity we are reporting, we can
         -- still detect some context sensitivities.  Both SLL and LL
         -- are showing a conflict, hence an ambiguity, but if they resolve
         -- to different minimum alternatives we have also identified a
         -- context sensitivity.
         This.decisions.Element (This.currentDecision).contextSensitivities.append (
            ContextSensitivityInfos.Initialize (This.currentDecision, configs, This.input, startIndex, stopIndex));
      end if;
      This.decisions.Element (This.currentDecision).ambiguities.append (
         AmbiguityInfos (This.currentDecision, configs, Value (ambigAlts), This.input, startIndex, stopIndex, configs.fullCtx));
      Super (This).reportAmbiguity (dfa, D, startIndex, stopIndex, exact, Value (ambigAlts), configs);
   end reportAmbiguity;

end ANTLR.Runtime.ATN.Simulators.Parsers.Profilings;
