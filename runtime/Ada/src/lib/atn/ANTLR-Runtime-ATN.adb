-- €

with ANTLR.Runtime.Misc.Exceptions.Errors;

use ANTLR.Runtime.Misc.Exceptions.Errors;

package body ANTLR.Runtime.ATN is

   procedure Initialize (Self : in out ATN;
                   grammarType : ATNType;
                   maxTokenType : Token_Kind) is
   begin
      self.grammarType := grammarType;
      self.maxTokenType := maxTokenType;
   end Initialize;

   function nextTokens (This : ATN; s : ATNState; ctx : Optional_RuleContext) return IntervalSet is
      anal : constant := LL1Analyzer (This);
      next : constant := anal.LOOK (s, ctx);
   begin
      return next;
   end nextTokens;

   function nextTokens (This : ATN; s : ATNState) return IntervalSet is
      nextTokenWithinRule : constant IntervalSet := s.nextTokenWithinRule;
   begin
      if Is_Valid (nextTokenWithinRule) then
         return nextTokenWithinRule;
      else
         declare
            intervalSet : constant IntervalSet := nextTokens (s, null);
            --TOFIX S : ATNState;
         begin
            s.nextTokenWithinRule := intervalSet;
            intervalSet.makeReadonly;
            return intervalSet;
         end;
      end if;
   end nextTokens;

   procedure addState (This : ATN; state : Optional_ATNState) is
      state : constant Optional_ATNState := state;
   begin
      if Is_Valid (state) then
         state.atn := This;
         state.stateNumber := This.states.Length;
      end if;

      This.states.Append (state);
   end addState;

   procedure removeState (This : ATN; state : ATNState) is
   begin
      This.states.Replace (Index => state.stateNumber, New_Item => (Valid => False));
      --states.set (state.stateNumber, null); -- just free mem, don't shift states in list
   end removeState;

   function defineDecisionState (This : ATN; s : DecisionState) return State is
   begin
      This.decisionToState.Append (s);
      -- s.decision := State'Val (This.decisionToState.Length - 1);
      s.decision := State'Val (This.decisionToState.Length - 1); --TOFIX
      return s.decision;
   end defineDecisionState;

   function getDecisionState (This : ATN; decision : State) return Optional_DecisionState is
   begin
      if not This.decisionToState.Is_Empty  then
         return This.decisionToState.Element (decision); --TOFIX
      else
         return (Valid => False);
      end if;
   end getDecisionState;

   function getExpectedTokens (This : ATN; stateNumber : ATNStates.State; context : RuleContext) return IntervalSet is
   begin
      if not This.states.indices.contains (stateNumber) then
         raise ANTLRError.illegalArgument with "Invalid state number.";
      end if;

      ctx : Optional_RuleContext := context;
      s : constant ATNStates.State := This.states.Element (stateNumber);
      following := nextTokens (s);
      if not following.contains (CommonToken.EPSILON) then
         return following;
      end if;

      expected : constant := This.IntervalSet;
      expected.addAll (following); -- try!
      expected.Delete (CommonToken.EPSILON); -- try!
      ctxWrap : Optional_RuleContext := ctx; --TOFIX
      while Is_Valid (ctxWrap)  --TOFIX
         and then ctxWrap.invokingState >= 0
         and then following.contains (CommonToken.EPSILON) loop
            declare
               invokingState : constant := This.states.Element (ctxWrap.invokingState);
               rt : constant RuleTransition := RuleTransition (invokingState.transition (0));
            begin
               following := nextTokens (rt.followState);
               expected.addAll (following); -- try!
               expected.Delete (CommonToken.EPSILON); -- try!
               ctx := ctxWrap.parent;
            exception
               when others => null;
            end;
         ctxWrap := ctx; --TOFIX
      end loop;

      if following.contains (CommonToken.EPSILON) then
         expected.add (EOF); -- try!
      end if;

      return expected;
   end getExpectedTokens;

   procedure appendDecisionToState (This : ATN; state : DecisionState) is
   begin
      This.decisionToState.Append (state);
   end appendDecisionToState;

   procedure appendModeToStartState (This : ATN; state : TokensStartState) is
   begin
      This.modeToStartState.Append (state);
   end appendModeToStartState;

end ANTLR.Runtime.ATN;
