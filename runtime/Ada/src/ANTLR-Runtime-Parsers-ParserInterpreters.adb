-- €

package body ANTLR.Runtime.Parsers.ParserInterpreters is

   procedure Initialize (Self : in out ParserInterpreter; old : ParserInterpreter) is
   begin
      self.atn := old.atn;
      self.grammarFileName := old.grammarFileName;
      self.statesNeedingLeftRecursionContext := old.statesNeedingLeftRecursionContext;
      self.decisionToDFA := old.decisionToDFA;
      self.ruleNames := old.ruleNames;
      self.vocabulary := old.vocabulary;
      super.Initialize (Self, Value (old.getTokenStream));
      Self.setInterpreter (ParserATNSimulator (atn,
                                               decisionToDFA,
                                               sharedContextCache));
   end Initialize;

   procedure Initialize (Self : in out ParserInterpreter;
                         grammarFileName : UString;
                         vocabulary : Vocabulary;
                         ruleNames : UString_List;
                         atn : ATN;
                         input : TokenStream) is
   begin  
      self.grammarFileName := grammarFileName;
      self.atn := atn;
      self.ruleNames := ruleNames;
      self.vocabulary := vocabulary;
      self.decisionToDFA := DFA_Container.Empty_Vector;
      for i in 0 .. atn.getNumberOfDecisions - 1 loop
         decisionToDFA.append (DFA.Initialize (atn.getDecisionState (i)!, i));
      end loop;

      -- identify the ATN states where This.pushNewRecursionContext must be called
      self.statesNeedingLeftRecursionContext := BitSet (atn.states.count); -- try!
      for  state in atn.states loop
         state : constant Optional_StarLoopEntryState := Maybe (state);
         if Is_Valid (state) then
            if state.precedenceRuleDecision then
               self.statesNeedingLeftRecursionContext.set (state.stateNumber); -- try!
            end if;
         end if;

      end loop;
      Super (Self).Initialize (input);
      -- get atn simulator that knows how to do predictions
      This.setInterpreter (ParserATNSimulator.Initialize (This,  --TOFIX
                                                          atn,
                                                          decisionToDFA,
                                                          sharedContextCache));
   end Initialize;

   function parse (This : ParserInterpreter;
                   startRuleIndex : Integer)
                   return ParserRuleContext is
      startRuleStartState : constant := atn.ruleToStartState.Element (startRuleIndex);
      rootContext : constant := InterpreterRuleContext.Initialize (null, ATNState.INVALID_STATE_NUMBER, startRuleIndex);
   begin
      if startRuleStartState.isPrecedenceRule then
         This.enterRecursionRule (rootContext, startRuleStartState.stateNumber, startRuleIndex, 0);
      else
         This.enterRule (rootContext, startRuleStartState.stateNumber, startRuleIndex);
      end if;

      loop
         p : constant State := Value (This.getATNState);
         case p.getStateType is
            when ATNState.RULE_STOP =>
               -- pop; return from rule
               if Value (This.ctx).Is_Empty then
                  if startRuleStartState.isPrecedenceRule then
                        result : constant ParserRuleContext := Value (This.ctx);
                        parentContext : constant (ParserRuleContext?, Int) := This.parentContextStack.pop;
                        unrollRecursionContexts (Value (parentContext.0));
                        return result;
                  else
                        This.exitRule;
                        return rootContext;
                  end if;
               end if;

               visitRuleStopState (p);


            when others =>
               declare
               begin
                  self.visitState (p);
               end if;
               exception
                  when ANTLRException.recognition =>
                     (let e)
                  This.setState (self.atn.ruleToStopState.Element (Value (p.ruleIndex)).stateNumber);
                  Value (This.getContext).exception := e
                  This.getErrorHandler.reportError (self, e);
                  This.getErrorHandler.recover (self, e);
               end if;
         end case;
      end loop;
   end parse;

   overriding
   procedure enterRecursionRule (This : ParserInterpreter;
                                 localctx : ParserRuleContext;
                                 state : Integer;
                                 ruleIndex : Integer;
                                 precedence : Integer) is
   begin
      pair : constant (ParserRuleContext?, Int) := (This.ctx, localctx.invokingState);
      This.parentContextStack.push (pair);
      super.enterRecursionRule (localctx, state, ruleIndex, precedence);
   end enterRecursionRule;

   procedure visitState (This : ParserInterpreter; p : ATNState) is
   begin
      altNum : Integer;
      if p.getNumberOfTransitions > 1 then
         This.getErrorHandler.sync (self);
         decision : constant DecisionState := DecisionState ((p)).decision
         if decision = overrideDecision and then This.input.index = overrideDecisionInputIndex then
               altNum := overrideDecisionAlt
         else
               altNum := This.getInterpreter.adaptivePredict (This.input, decision, This.ctx);
         end if;
      else
         altNum := 1;
      end if;

      transition : constant := p.transition (altNum - 1);
      case transition.getSerializationType is
      when Transition.EPSILON =>
         if statesNeedingLeftRecursionContext.get (p.stateNumber) and;
                  not (transition.target is LoopEndState) {
               -- We are at the start of a left recursive rule's ( .. )* loop
               -- but it's not the exit branch of loop.
               ctx : constant InterpreterRuleContext := InterpreterRuleContext (;
               Value (This.parentContextStack.last).0, --peek;
                     Value (This.parentContextStack.last).1, --peek;

                     Value (This.ctx).getRuleIndex);
               pushNewRecursionContext (ctx, atn.ruleToStartState.Element (Value (p.ruleIndex)).stateNumber, Value (This.ctx).getRuleIndex);
         end if;

      when Transition.ATOM =>
         match ((AtomTransition (transition)).label);

      when TRANSITION_RANGE => fallthrough;
      when Transition.SET => fallthrough;
      when Transition.NOT_SET =>
         if not transition.matches (This.input.LA (1), CommonToken.MIN_USER_TOKEN_TYPE, 65535) then
               _errHandler.recoverInline (self);
         end if;
         This.matchWildcard;

      when Transition.WILDCARD =>
         This.matchWildcard;

      when Transition.RULE =>
         ruleStartState : constant RuleStartState := RuleStartState (transition.target);
         ruleIndex : constant := Value (ruleStartState.ruleIndex)
         ctx : constant := InterpreterRuleContext (This.ctx, p.stateNumber, ruleIndex);
         if ruleStartState.isPrecedenceRule then
               enterRecursionRule (ctx, ruleStartState.stateNumber, ruleIndex, (RuleTransition (transition)).precedence);
         else
               enterRule (ctx, transition.target.stateNumber, ruleIndex);
         end if;

      when Transition.PREDICATE =>
         predicateTransition : constant PredicateTransition := PredicateTransition (transition);
         if not sempred (Value (This.ctx), predicateTransition.ruleIndex, predicateTransition.predIndex) then
               raise ANTLRException.recognition with FailedPredicateException (self);
         end if;

      when Transition.ACTION =>
         actionTransition : constant ActionTransition := ActionTransition (transition);
         action (This.ctx, actionTransition.ruleIndex, actionTransition.actionIndex);

      when Transition.PRECEDENCE =>
         if not precpred (Value (This.ctx), (PrecedencePredicateTransition (transition)).precedence) then
               raise ANTLRException.recognition
                  with FailedPredicateException (self, "precpred (ctx," & PrecedencePredicateTransition (transition).precedence'Image) & ')';
         end if;

      when others =>
         raise ANTLRError.unsupportedOperation
            with "Unrecognized ATN transition type.";

      end case;

      This.setState (transition.target.stateNumber);
   end visitState;

   procedure visitRuleStopState (This : ParserInterpreter; p : ATNState) is
      ruleStartState : constant := atn.ruleToStartState.ELement (Value (p.ruleIndex));
   begin
      if ruleStartState.isPrecedenceRule then
         let (parentContext, parentState) := This.parentContextStack.pop;
         unrollRecursionContexts (Value (parentContext));
         This.setState (parentState);
      else
         This.exitRule;
      end if;

      ruleTransition : constant RuleTransition := Value (RuleTransition (atn.states.Element (getState)).transition (0));
      This.setState (ruleTransition.followState.stateNumber);
   end visitRuleStopState;;

   procedure addDecisionOverride (This : ParserInterpreter;
                                  decision : Integer;
                                  tokenIndex : Integer;
                                  forcedAlt : Integer) is
   begin
      This.overridingDecision := decision;
      This.overridingDecisionInputIndex := tokenIndex;
      This.overridingDecisionAlt := forcedAlt;
   end addDecisionOverride;;

end ANTLR.Runtime.Parsers.ParserInterpreters;
