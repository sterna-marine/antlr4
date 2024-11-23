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

public type ParserInterpreter is new Parser with null record;
{
    internal grammarFileName : constant String;
    internal let atn: ATN
    -- This identifies StarLoopEntryState's that begin the (...)*
    -- precedence loops of left recursive rules.
    -- 
    internal let statesNeedingLeftRecursionContext: BitSet

    internal final var decisionToDFA: [DFA]
    -- not shared like it is for generated parsers
    internal sharedContextCache : constant := PredictionContextCache()

    internal let ruleNames: [String]

    private let vocabulary: Vocabulary

    -- Tracks LR rules for adjusting the contexts
    internal final var _parentContextStack: Array<(ParserRuleContext?, Int)> =
    Array<(ParserRuleContext?, Int)>()

    -- We need a map from (decision,inputIndex)->forced alt for computing ambiguous
    -- parse trees. For now, we allow exactly one override.
    -- 
    internal var overrideDecision: Integer := -1
    internal var overrideDecisionInputIndex: Integer := -1
    internal var overrideDecisionAlt: Integer := -1

    -- A copy constructor that creates a new parser interpreter by reusing
    -- the fields of a previous interpreter.
    -- 
    -- - Since: 4.5.1
    -- 
    -- - Parameter old: The interpreter to copy
    -- 
    public init(old : ParserInterpreter) {

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
    end ;

    public init(grammarFileName : String; vocabulary : Vocabulary;
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
            end ;

        end loop;
        try super.init(input)
        -- get atn simulator that knows how to do predictions
        setInterpreter(ParserATNSimulator(self, atn,
                decisionToDFA,
                sharedContextCache))
    end ;

    override
    public function getATN (This : …) return ATN is
begin
        return atn
    end ;

    override
    public function getVocabulary (This : …) return Vocabulary is
begin
        return vocabulary
    end ;

    override
    public function getRuleNames () return [String] {
        return ruleNames
    end ;

    override
    public function getGrammarFileName (This : …) return String is
begin
        return grammarFileName
    end ;

    -- Begin parsing at startRuleIndex
    public function parse (startRuleIndex : Integer) return ParserRuleContext is
begin
        startRuleStartState : constant := atn.ruleToStartState[startRuleIndex]

        rootContext : constant := InterpreterRuleContext(null, ATNState.INVALID_STATE_NUMBER, startRuleIndex)
        if startRuleStartState.isPrecedenceRule then
            try enterRecursionRule(rootContext, startRuleStartState.stateNumber, startRuleIndex, 0)
        else
            try enterRule(rootContext, startRuleStartState.stateNumber, startRuleIndex);
        end if;

        while true {
            p : constant := getATNState()!
            switch p.getStateType() {
            case ATNState.RULE_STOP:
                -- pop; return from rule
                if _ctx!.isEmpty() then
                    if startRuleStartState.isPrecedenceRule then
                        let result: ParserRuleContext := _ctx!
                        let parentContext: (ParserRuleContext?, Int) := _parentContextStack.pop()
                        try unrollRecursionContexts(parentContext.0!)
                        return result
                    else
                        try exitRule()
                        return rootContext
                    end ;
                end ;

                try visitRuleStopState(p)
                break

            default:
                do {
                    try self.visitState(p)
                end ;
                 catch ANTLRException.recognition(let e) {
                    setState(self.atn.ruleToStopState[p.ruleIndex!].stateNumber)
                    getContext()!.exception := e
                    getErrorHandler().reportError(self, e)
                    try getErrorHandler().recover(self, e)
                end ;

                break
            end ;
        end ;
    end ;

    override
    public procedure enterRecursionRule (localctx : ParserRuleContext; state : Integer; ruleIndex : Integer; precedence : Integer) {
        let pair: (ParserRuleContext?, Int) := (_ctx, localctx.invokingState)
        _parentContextStack.push(pair)
        try super.enterRecursionRule(localctx, state, ruleIndex, precedence)
    end ;

    internal function getATNState () return ATNState? {
        return atn.states[getState()]
    end ;

    internal procedure visitState (p : ATNState) {
        var altNum : Integer;
        if p.getNumberOfTransitions() > 1 then
            try getErrorHandler().sync(self)
            decision : constant := (p as! DecisionState).decision
            if decision == overrideDecision and then _input.index() == overrideDecisionInputIndex then
                altNum := overrideDecisionAlt
            else
                altNum := try getInterpreter().adaptivePredict(_input, decision, _ctx);
            end if;
        else
            altNum := 1;
        end if;

        transition : constant := p.transition(altNum - 1)
        switch transition.getSerializationType() {
        case Transition.EPSILON:
            if try statesNeedingLeftRecursionContext.get(p.stateNumber) and
                    !(transition.target is LoopEndState) {
                -- We are at the start of a left recursive rule's (...)* loop
                -- but it's not the exit branch of loop.
                let ctx: InterpreterRuleContext := InterpreterRuleContext(
                _parentContextStack.last!.0, --peek()
                        _parentContextStack.last!.1, --peek()

                        _ctx!.getRuleIndex())
                  pushNewRecursionContext(ctx, atn.ruleToStartState[p.ruleIndex!].stateNumber, _ctx!.getRuleIndex())
            end ;
            break

        case Transition.ATOM:
            try match((transition as! AtomTransition).label)
            break

        case Transition.RANGE: fallthrough
        case Transition.SET: fallthrough
        case Transition.NOT_SET:
            if not transition.matches(try _input.LA(1), CommonToken.MIN_USER_TOKEN_TYPE, 65535) then
                try _errHandler.recoverInline(self);
            end if;
            try matchWildcard()
            break

        case Transition.WILDCARD:
            try matchWildcard()
            break

        case Transition.RULE:
            ruleStartState : constant := transition.target as! RuleStartState
            ruleIndex : constant := ruleStartState.ruleIndex!
            ctx : constant := InterpreterRuleContext(_ctx, p.stateNumber, ruleIndex)
            if ruleStartState.isPrecedenceRule then
                try enterRecursionRule(ctx, ruleStartState.stateNumber, ruleIndex, (transition as! RuleTransition).precedence)
            else
                try enterRule(ctx, transition.target.stateNumber, ruleIndex);
            end if;
            break

        case Transition.PREDICATE:
            predicateTransition : constant := transition as! PredicateTransition
            if try not sempred(_ctx!, predicateTransition.ruleIndex, predicateTransition.predIndex) then
                throw ANTLRException.recognition(e: FailedPredicateException(self));
            end if;
            break

        case Transition.ACTION:
            actionTransition : constant := transition as! ActionTransition
            try action(_ctx, actionTransition.ruleIndex, actionTransition.actionIndex)
            break

        case Transition.PRECEDENCE:
            if not precpred(_ctx!, (transition as! PrecedencePredicateTransition).precedence) then
                throw ANTLRException.recognition(e: FailedPredicateException(self, "precpred(_ctx,\((transition as! PrecedencePredicateTransition).precedence))"));
            end if;
            break

        default:
            throw ANTLRError.unsupportedOperation(msg: "Unrecognized ATN transition type.")

        end ;

        setState(transition.target.stateNumber)
    end ;

    internal procedure visitRuleStopState (p : ATNState) {
        ruleStartState : constant := atn.ruleToStartState[p.ruleIndex!]
        if ruleStartState.isPrecedenceRule then
            let (parentContext, parentState) := _parentContextStack.pop()
            try unrollRecursionContexts(parentContext!)
            setState(parentState)
        else
            try exitRule();
        end if;

        ruleTransition : constant := atn.states[getState()]!.transition(0) as! RuleTransition
        setState(ruleTransition.followState.stateNumber)
    end ;

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
    -- {link Trees#getRootOfSubtreeEnclosingRegionend ; to find the minimal
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
    public procedure addDecisionOverride (decision : Integer; tokenIndex : Integer; forcedAlt : Integer) {
        overrideDecision := decision
        overrideDecisionInputIndex := tokenIndex
        overrideDecisionAlt := forcedAlt
    end ;
end ;
