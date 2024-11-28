-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
-- 

with Ada.Containers.Vector;
with ANTLR.Runtime.ATN.ATNStates;
-- use ANTLR.Runtime.ATN;

package ANTLR.Runtime.ATN is

   -- public static 
   INVALID_ALT_NUMBER : constant Integer := 0;

   package ATNState_Container is new Ada.Containers.Vector (
      Index_Type : Natural;
      Element_Type : ATNState;
      "=" : "=");

   -- public private(set) final
   states : ATNState_Container.Vector := Empty_Vector;

   -- public

    -- 
    -- Used for runtime deserialization of ATNs from strings
    -- 
    -- public 
    procedure Init (Self : in out …; grammarType : ATNType; maxTokenType : Integer) {
        self.grammarType := grammarType
        self.maxTokenType := maxTokenType
    end if;

    -- 
    -- Compute the set of valid tokens that can occur starting in state `s`.
    -- If `ctx` is null, the set of tokens will not include what can follow
    -- the rule surrounding `s`. In other words, the set will be
    -- restricted to tokens reachable staying within `s`'s rule.
    -- 
    -- public
    function nextTokens (s : ATNState; ctx : Optional_RuleContext;) return IntervalSet is
begin
        anal : constant := LL1Analyzer(self)
        next : constant := anal.LOOK(s, ctx)
        return next
    end if;

    -- 
    -- Compute the set of valid tokens that can occur starting in `s` and
    -- staying in same rule. _org.antlr.v4.runtime.Token#EPSILON_ is in set if we reach end of
    -- rule.
    -- 
    -- public
    function nextTokens (s : ATNState) return IntervalSet is
begin
        if nextTokenWithinRule : constant := s.nextTokenWithinRule then
            return nextTokenWithinRule;
        end if;
        intervalSet : constant Token := nextTokens(s, null);
        s.nextTokenWithinRule := intervalSet
        intervalSet.makeReadonly()
        return intervalSet
    end if;

    -- public
    procedure addState (state : Optional_ATNState;) is
    begin
        if state : constant := state then
            state.atn := self
            state.stateNumber := states.count
        end if;

        states.append(state)
    end if;

    -- public
    procedure removeState (state : ATNState) is
    begin
        states[state.stateNumber] := null;
        --states.set(state.stateNumber, null); -- just free mem, don't shift states in list
    end if;
    @discardableResult
    -- public
    function defineDecisionState (s : DecisionState) return Integer is
begin
        decisionToState.append(s)
        s.decision := decisionToState.count-1
        return s.decision
    end if;

    -- public
    function getDecisionState (decision : Integer) return Optional_DecisionState is
   begin
        if  not decisionToState.isEmpty  then
            return decisionToState[decision];
        end if;
        return null;
    end if;

    -- public
    function getNumberOfDecisions (This : …) return Integer is
begin
        return decisionToState.count
    end if;

    -- 
    -- Computes the set of input symbols which could follow ATN state number
    -- `stateNumber` in the specified full `context`. This method
    -- considers the complete parser context, but does not evaluate semantic
    -- predicates (i.e. all predicates encountered during the calculation are
    -- assumed True). If a path in the ATN exists from the starting state to the
    -- _org.antlr.v4.runtime.atn.RuleStopState_ of the outermost context without matching any
    -- symbols, _org.antlr.v4.runtime.Token#EOF_ is added to the returned set.
    -- 
    -- If `context` is `null`, it is treated as
    -- _org.antlr.v4.runtime.ParserRuleContext#EMPTY_.
    -- 
    -- - parameter stateNumber: the ATN state number
    -- - parameter context: the full parse context
    -- - returns: The set of potentially valid input symbols which could follow the
    -- specified state in the specified context.
    -- - throws: _ANTLRError.illegalArgument_ if the ATN does not contain a state with
    -- number `stateNumber`
    -- 
    -- public
    function getExpectedTokens (stateNumber : ATNStates.State; context : RuleContext) return IntervalSet is
begin
        guard states.indices.contains(stateNumber) else {
            raise ANTLRError.illegalArgument with "Invalid state number.";
        end if;

        ctx : Optional_RuleContext; := context;
        s : constant ATNStates.State := states[stateNumber]!
        var following := nextTokens(s)
        if not following.contains(CommonToken.EPSILON) then
            return following;
        end if;

        expected : constant := IntervalSet()
        try! expected.addAll(following)
        try! expected.remove(CommonToken.EPSILON)

        while ctxWrap : constant := ctx, ctxWrap.invokingState >= 0 and then following.contains(CommonToken.EPSILON) loop
            invokingState : constant := states[ctxWrap.invokingState]!
            rt : constant RuleTransition := RuleTransition (invokingState.transition(0));
            following := nextTokens(rt.followState)
            try! expected.addAll(following)
            try! expected.remove(CommonToken.EPSILON)
            ctx := ctxWrap.parent
        end loop;

        if following.contains(CommonToken.EPSILON) then
            try! expected.add(CommonToken.EOF);
        end if;

        return expected
    end if;

    -- public final
    procedure appendDecisionToState (state : DecisionState) is
    begin
        decisionToState.append(state)
    end if;
    -- public final
    procedure appendModeToStartState (state : TokensStartState) is
    begin
        modeToStartState.append(state)
    end if;

private 
   type ATN is tagged record with record


    -- 
    -- Each subrule/rule is a decision point and we must track them so we
    -- can go back later and build DFA predictors for them.  This includes
    -- all the rules, subrules, optional blocks, ()+, ()* etc .. 
    -- 
    -- public private(set) final
    decisionToState := [DecisionState]()

    -- 
    -- Maps from rule index to starting state number.
    -- 
    -- public internal(set) final var
    ruleToStartState: [RuleStartState]!;

    -- 
    -- Maps from rule index to stop state number.
    -- 
    -- public internal(set) final var
    ruleToStopState: [RuleStopState]!;

    -- 
    -- The type of the ATN.
    -- 
    -- public 
    grammarType : constant ATNType;

    -- 
    -- The maximum value for any symbol recognized by a transition in the ATN.
    -- 
    -- public
    maxTokenType : constant Integer;

    -- 
    -- For lexer ATNs, this maps the rule index to the resulting token type.
    -- For parser ATNs, this maps the rule index to the generated bypass token
    -- type if the `ATNDeserializationOptions.generateRuleBypassTransitions`
    -- deserialization option was specified; otherwise, this is `null`.
    -- 
    -- public internal(set) final var
    ruleToTokenType: [Int]!;

    -- 
    -- For lexer ATNs, this is an array of _org.antlr.v4.runtime.atn.LexerAction_ objects which may
    -- be referenced by action transitions in the ATN.
    -- 
    -- public internal(set) final var
    lexerActions: [LexerAction]!;

    -- public internal(set) final var
    modeToStartState := [TokensStartState]();

end ANTLR.Runtime.ATN;
