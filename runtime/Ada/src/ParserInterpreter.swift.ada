-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
--



-- A parser simulator that mimics what ANTLR's generated
-- parser code does. A ParserATNSimulator is used to make
-- predictions via adaptivePredict but this class moves a pointer through the
-- ATN to simulate parsing. ParserATNSimulator just
-- makes us efficient rather than having to backtrack, for example.
-- 
-- This properly creates parse trees even for left recursive rules.
-- 
-- We rely on the left recursive rule invocation and special predicate
-- transitions to make left recursive rules work.
-- 
-- See TestParserInterpreter for examples.
-- 

-- public
type ParserInterpreter is new Parser with null record;
{
    internal grammarFileName : constant String;
    internal let atn: ATN
    -- This identifies StarLoopEntryState's that begin the ( .. )*
    -- precedence loops of left recursive rules.
    -- 
    internal let statesNeedingLeftRecursionContext: BitSet

    internal final var decisionToDFA: [DFA]
    -- not shared like it is for generated parsers
    internal sharedContextCache : constant := PredictionContextCache()

    internal let ruleNames: [String]

    -- private 
    vocabulary : constant Vocabulary;

    -- Tracks LR rules for adjusting the contexts
    internal final var _parentContextStack: Array<(ParserRuleContext?, Int)> =
    Array<(ParserRuleContext?, Int)>()

    -- We need a map from (decision,inputIndex)->forced alt for computing ambiguous
    -- parse trees. For now, we allow exactly one override.
    -- 
    -- internal
    overrideDecision : Integer := -1
    -- internal
    overrideDecisionInputIndex : Integer := -1
    -- internal
    overrideDecisionAlt : Integer := -1

    -- A copy constructor that creates a new parser interpreter by reusing
    -- the fields of a previous interpreter.
    -- 
    -- - Since: 4.5.1
    -- 
    -- - Parameter old: The interpreter to copy
    -- 
    -- public 
    procedure Init (Self : in out …; old : ParserInterpreter) {

        self.atn := old.atn
        self.grammarFileName := old.grammarFileName
        self.statesNeedingLeftRecursionContext := old.statesNeedingLeftRecursionContext
        self.decisionToDFA := old.decisionToDFA
        self.ruleNames := old.ruleNames
        self.vocabulary := old.vocabulary
        super.init(old.getTokenStream()!)
        setInterpreter(ParserATNSimulator(self, atn,
                decisionToDFA,
                sharedContextCache))
    end if;

    -- public 
    procedure Init (Self : in out …; grammarFileName : String; vocabulary : Vocabulary;
                ruleNames : Array<String>, atn : ATN; input : TokenStream) {

        self.grammarFileName := grammarFileName
        self.atn := atn
        self.ruleNames := ruleNames
        self.vocabulary := vocabulary
        self.decisionToDFA := [DFA]()
        for i in 0 ..< atn.getNumberOfDecisions() loop
            decisionToDFA.append(DFA(atn.getDecisionState(i)!, i))
        end loop;

        -- identify the ATN states where pushNewRecursionContext() must be called
        self.statesNeedingLeftRecursionContext := try! BitSet(atn.states.count)
        for  state in atn.states loop
            if state : constant := state as? StarLoopEntryState then
                if state.precedenceRuleDecision then
                    try! self.statesNeedingLeftRecursionContext.set(state.stateNumber);
                end if;
            end if;

        end loop;
        super.init(input);
        -- get atn simulator that knows how to do predictions
        setInterpreter(ParserATNSimulator(self, atn,
                decisionToDFA,
                sharedContextCache))
    end if;

    override
    -- public
    function getATN (This : …) return ATN is
begin
        return atn
    end if;

    override
    -- public
    function getVocabulary (This : …) return Vocabulary is
begin
        return vocabulary
    end if;

    override
    -- public
    function getRuleNames () return [String] {
        return ruleNames
    end if;

    override
    -- public
    function getGrammarFileName (This : …) return String is
begin
        return grammarFileName
    end if;

    -- Begin parsing at startRuleIndex
    -- public
    function parse (startRuleIndex : Integer) return ParserRuleContext is
begin
        startRuleStartState : constant := atn.ruleToStartState[startRuleIndex]

        rootContext : constant := InterpreterRuleContext(null, ATNState.INVALID_STATE_NUMBER, startRuleIndex)
        if startRuleStartState.isPrecedenceRule then
            enterRecursionRule(rootContext, startRuleStartState.stateNumber, startRuleIndex, 0);
        else
            enterRule(rootContext, startRuleStartState.stateNumber, startRuleIndex);
        end if;

        loop
            p : constant := getATNState()!
            case p.getStateType() is
               when ATNState.RULE_STOP =>
                  -- pop; return from rule
                  if _ctx!.isEmpty() then
                     if startRuleStartState.isPrecedenceRule then
                           let result: ParserRuleContext := _ctx!
                           let parentContext: (ParserRuleContext?, Int) := _parentContextStack.pop()
                           unrollRecursionContexts(parentContext.0!);
                           return result
                     else
                           exitRule();
                           return rootContext
                     end if;
                  end if;

                  visitRuleStopState(p);


               when others =>
                  do {
                     self.visitState(p);
                  end if;
                  catch ANTLRException.recognition(let e) {
                     setState(self.atn.ruleToStopState[p.ruleIndex!].stateNumber)
                     getContext()!.exception := e
                     getErrorHandler().reportError(self, e)
                     getErrorHandler().recover(self, e);
                  end if;
            end case;
        end loop;
    end if;

    override
    -- public
    procedure enterRecursionRule (localctx : ParserRuleContext; state : Integer; ruleIndex : Integer; precedence : Integer) is
    begin
        let pair: (ParserRuleContext?, Int) := (_ctx, localctx.invokingState)
        _parentContextStack.push(pair)
        super.enterRecursionRule(localctx, state, ruleIndex, precedence);
    end if;

    -- internal
    function getATNState () return ATNState? {
        return atn.states[getState()]
    end if;

    -- internal
    procedure visitState (p : ATNState) is
    begin
        var altNum : Integer;
        if p.getNumberOfTransitions() > 1 then
            getErrorHandler().sync(self);
            decision : constant := (p as! DecisionState).decision
            if decision = overrideDecision and then _input.index() == overrideDecisionInputIndex then
                altNum := overrideDecisionAlt
            else
                altNum := getInterpreter().adaptivePredict(_input, decision, _ctx);
            end if;
        else
            altNum := 1;
        end if;

        transition : constant := p.transition(altNum - 1)
        case transition.getSerializationType() is
        when Transition.EPSILON =>
            if statesNeedingLeftRecursionContext.get(p.stateNumber) and;
                    !(transition.target is LoopEndState) {
                -- We are at the start of a left recursive rule's ( .. )* loop
                -- but it's not the exit branch of loop.
                let ctx: InterpreterRuleContext := InterpreterRuleContext(
                _parentContextStack.last!.0, --peek()
                        _parentContextStack.last!.1, --peek()

                        _ctx!.getRuleIndex())
                  pushNewRecursionContext(ctx, atn.ruleToStartState[p.ruleIndex!].stateNumber, _ctx!.getRuleIndex())
            end if;

        when Transition.ATOM =>
            match((transition as! AtomTransition).label);

        when Transition.RANGE => fallthrough;
        when Transition.SET => fallthrough;
        when Transition.NOT_SET =>
            if not transition.matches(_input.LA(1), CommonToken.MIN_USER_TOKEN_TYPE, 65535) then;
                _errHandler.recoverInline(self);
            end if;
            matchWildcard();

        when Transition.WILDCARD =>
            matchWildcard();

        when Transition.RULE =>
            ruleStartState : constant := transition.target as! RuleStartState
            ruleIndex : constant := ruleStartState.ruleIndex!
            ctx : constant := InterpreterRuleContext(_ctx, p.stateNumber, ruleIndex)
            if ruleStartState.isPrecedenceRule then
                enterRecursionRule(ctx, ruleStartState.stateNumber, ruleIndex, (transition as! RuleTransition).precedence);
            else
                enterRule(ctx, transition.target.stateNumber, ruleIndex);
            end if;

        when Transition.PREDICATE =>
            predicateTransition : constant := transition as! PredicateTransition
            if not sempred(_ctx!, predicateTransition.ruleIndex, predicateTransition.predIndex) then;
                raise ANTLRException.recognition with FailedPredicateException(self);
            end if;

        when Transition.ACTION =>
            actionTransition : constant := transition as! ActionTransition
            action(_ctx, actionTransition.ruleIndex, actionTransition.actionIndex);

        when Transition.PRECEDENCE =>
            if not precpred(_ctx!, (transition as! PrecedencePredicateTransition).precedence) then
                raise ANTLRException.recognition with FailedPredicateException(self, "precpred(_ctx,\((transition as! PrecedencePredicateTransition).precedence))");
            end if;

        when others =>
            raise ANTLRError.unsupportedOperation with "Unrecognized ATN transition type.";

        end case;

        setState(transition.target.stateNumber)
    end if;

    -- internal
    procedure visitRuleStopState (p : ATNState) is
    begin
        ruleStartState : constant := atn.ruleToStartState[p.ruleIndex!]
        if ruleStartState.isPrecedenceRule then
            let (parentContext, parentState) := _parentContextStack.pop()
            unrollRecursionContexts(parentContext!);
            setState(parentState)
        else
            exitRule();
        end if;

        ruleTransition : constant := atn.states[getState()]!.transition(0) as! RuleTransition
        setState(ruleTransition.followState.stateNumber)
    end if;

    -- Override this parser interpreters normal decision-making process
    -- at a particular decision and input token index. Instead of
    -- allowing the adaptive prediction mechanism to choose the
    -- first alternative within a block that leads to a successful parse,
    -- force it to take the alternative, 1 .. n for n alternatives.
    -- 
    -- As an implementation limitation right now, you can only specify one
    -- override. This is sufficient to allow construction of different
    -- parse trees for ambiguous input. It means re-parsing the entire input
    -- in general because you're never sure where an ambiguous sequence would
    -- live in the various parse trees. For example, in one interpretation,
    -- an ambiguous input sequence would be matched completely in expression
    -- but in another it could match all the way back to the root.
    -- 
    -- s : e '!'? ;
    -- e : ID
    -- | ID '!'
    -- ;
    -- 
    -- Here, x! can be matched as (s (e ID) !) or (s (e ID !)). In the first
    -- case, the ambiguous sequence is fully contained only by the root.
    -- In the second case, the ambiguous sequences fully contained within just
    -- e, as in: (e ID !).
    -- 
    -- Rather than trying to optimize this and make
    -- some intelligent decisions for optimization purposes, I settled on
    -- just re-parsing the whole input and then using
    -- {link Trees#getRootOfSubtreeEnclosingRegion} to find the minimal
    -- subtree that contains the ambiguous sequence. I originally tried to
    -- record the call stack at the point the parser detected and ambiguity but
    -- left recursive rules create a parse tree stack that does not reflect
    -- the actual call stack. That impedance mismatch was enough to make
    -- it it challenging to restart the parser at a deeply nested rule
    -- invocation.
    -- 
    -- Only parser interpreters can override decisions so as to avoid inserting
    -- override checking code in the critical ALL(*) prediction execution path.
    -- 
    -- - Since: 4.5.1
    -- 
    -- public
    procedure addDecisionOverride (decision : Integer; tokenIndex : Integer; forcedAlt : Integer) is
    begin
        overrideDecision := decision
        overrideDecisionInputIndex := tokenIndex
        overrideDecisionAlt := forcedAlt
    end if;
end if;
