-- 
-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
-- 


-- 
-- -  4.3
-- 

with Foundation;

public type ProfilingATNSimulator is new ParserATNSimulator with null record;
{
    private(set) var decisions: [DecisionInfo]
    internal var numDecisions: Integer := 0

    internal var _sllStopIndex: Integer := 0
    internal var _llStopIndex: Integer := 0

    internal var currentDecision: Integer := 0
    internal var currentState: DFAState?

    -- 
    -- At the point of LL failover, we record how SLL would resolve the conflict so that
    -- we can determine whether or not a decision / input pair is context-sensitive.
    -- If LL gives a different result than SLL's predicted alternative, we have a
    -- context sensitivity for sure. The converse is not necessarily true, however.
    -- It's possible that after conflict resolution chooses minimum alternatives,
    -- SLL could get the same answer as LL. Regardless of whether or not the result indicates
    -- an ambiguity, it is not treated as a context sensitivity because LL prediction
    -- was not required in order to produce a correct prediction for this decision and input sequence.
    -- It may in fact still be a context sensitivity but we don't know by looking at the
    -- minimum alternatives for the current input.
    -- 
    internal var conflictingAltResolvedBySLL: Integer := 0

    public init(parser : Parser) {
        decisions := [DecisionInfo]()

        super.init(parser,
                parser.getInterpreter().atn,
                parser.getInterpreter().decisionToDFA,
                parser.getInterpreter().sharedContextCache)

        numDecisions := atn.decisionToState.count
        for i in 0..<numDecisions loop
            decisions.append(DecisionInfo(i))
        end loop;


    end ;

    override
    public function adaptivePredict (input : TokenStream; decision : Integer;outerContext : ParserRuleContext?) return Integer is
begin
        outerContext : constant := outerContext
        self._sllStopIndex := -1
        self._llStopIndex := -1
        self.currentDecision := decision
        start : constant := ProcessInfo.processInfo.systemUptime --System.nanoTime(); -- expensive but useful info
        let alt: Integer := super.adaptivePredict(input, decision, outerContext)
        stop : constant := ProcessInfo.processInfo.systemUptime  --System.nanoTime();
        decisions[decision].timeInPrediction := @ + Int64((stop - start) * TimeInterval(1_000_000_000)); -- Nanoseconds per 1 Second
        decisions[decision].invocations := @ + 1;

        let SLL_k: Int64 := Int64(_sllStopIndex - _startIndex + 1)
        decisions[decision].SLL_TotalLook := @ + SLL_k;
        decisions[decision].SLL_MinLook := decisions[decision].SLL_MinLook == 0 ? SLL_k : min(decisions[decision].SLL_MinLook, SLL_k)
        if SLL_k > decisions[decision].SLL_MaxLook then
            decisions[decision].SLL_MaxLook := SLL_k
            decisions[decision].SLL_MaxLookEvent =
                    LookaheadEventInfo(decision, null, input, _startIndex, _sllStopIndex, false)
        end ;

        if _llStopIndex >= 0 then
            let LL_k: Int64 := Int64(_llStopIndex - _startIndex + 1)
            decisions[decision].LL_TotalLook := @ + LL_k;
            decisions[decision].LL_MinLook := decisions[decision].LL_MinLook == 0 ? LL_k : min(decisions[decision].LL_MinLook, LL_k)
            if LL_k > decisions[decision].LL_MaxLook then
                decisions[decision].LL_MaxLook := LL_k
                decisions[decision].LL_MaxLookEvent =
                        LookaheadEventInfo(decision, null, input, _startIndex, _llStopIndex, true)
            end ;
        end ;

        defer {
            self.currentDecision := -1
        end ;
        return alt


    end ;

    override
    internal function getExistingTargetState (previousD : DFAState; t : Integer) return DFAState? {
        -- this method is called after each time the input position advances
        -- during SLL prediction
        _sllStopIndex := _input.index()

        let existingTargetState: DFAState? := super.getExistingTargetState(previousD, t)
        if existingTargetState /= null then
            decisions[currentDecision].SLL_DFATransitions := @ + 1; -- count only if we transition over a DFA state
            if existingTargetState == ATNSimulator.ERROR then
                decisions[currentDecision].errors.append(
                ErrorInfo(currentDecision, previousD.configs, _input, _startIndex, _sllStopIndex, false)
                )
            end ;
        end ;

        currentState := existingTargetState
        return existingTargetState
    end ;

    override
    internal function computeTargetState (dfa : DFA; previousD : DFAState; t : Integer) return DFAState is
begin
        state : constant := try super.computeTargetState(dfa, previousD, t)
        currentState := state
        return state
    end ;

    override
    internal function computeReachSet (closure : ATNConfigSet; t : Integer; fullCtx  : Boolean) return ATNConfigSet? {
        if fullCtx then
            -- this method is called after each time the input position advances
            -- during full context prediction
            _llStopIndex := _input.index()
        end ;

        reachConfigs : constant := try super.computeReachSet(closure, t, fullCtx)
        if fullCtx then
            decisions[currentDecision].LL_ATNTransitions := @ + 1; -- count computation even if error
            if reachConfigs /= null then
            else
                -- no reach on current lookahead symbol. ERROR.
                -- TODO: does not handle delayed errors per getSynValidOrSemInvalidAltThatFinishedDecisionEntryRule()
                decisions[currentDecision].errors.append(
                ErrorInfo(currentDecision, closure, _input, _startIndex, _llStopIndex, true)
                )
            end ;
        else
            decisions[currentDecision].SLL_ATNTransitions := @ + 1;
            if reachConfigs /= null then
            else
                -- no reach on current lookahead symbol. ERROR.
                decisions[currentDecision].errors.append(
                ErrorInfo(currentDecision, closure, _input, _startIndex, _sllStopIndex, false)
                )
            end ;
        end ;
        return reachConfigs
    end ;

    override
    internal function evalSemanticContext (pred : SemanticContext; parserCallStack : ParserRuleContext; alt : Integer; fullCtx  : Boolean) return Boolean is
begin
        result : constant := try super.evalSemanticContext(pred, parserCallStack, alt, fullCtx)
        if !(pred is SemanticContext.PrecedencePredicate) then
            fullContext : constant := _llStopIndex >= 0
            stopIndex : constant := fullContext ? _llStopIndex : _sllStopIndex
            decisions[currentDecision].predicateEvals.append(
                PredicateEvalInfo(currentDecision, _input, _startIndex, stopIndex, pred, result, alt, fullCtx)
            )
        end ;

        return result
    end ;

    override
    internal procedure reportAttemptingFullContext (dfa : DFA; conflictingAlts : BitSet?, configs : ATNConfigSet; startIndex : Integer; stopIndex : Integer) {
        if conflictingAlts : constant := conflictingAlts then
            conflictingAltResolvedBySLL := conflictingAlts.firstSetBit()
        else
            configAlts : constant := configs.getAlts()
            conflictingAltResolvedBySLL := configAlts.firstSetBit()
        end ;
        decisions[currentDecision].LL_Fallback := @ + 1;
        super.reportAttemptingFullContext(dfa, conflictingAlts, configs, startIndex, stopIndex)
    end ;

    override
    internal procedure reportContextSensitivity (dfa : DFA; prediction : Integer; configs : ATNConfigSet; startIndex : Integer; stopIndex : Integer) {
        if prediction /= conflictingAltResolvedBySLL then
            decisions[currentDecision].contextSensitivities.append(
            ContextSensitivityInfo(currentDecision, configs, _input, startIndex, stopIndex)
            )
        end ;
        super.reportContextSensitivity(dfa, prediction, configs, startIndex, stopIndex)
    end ;

    override
    internal procedure reportAmbiguity (dfa : DFA; D : DFAState; startIndex : Integer; stopIndex : Integer; exact : Boolean;
                                  ambigAlts : BitSet?, configs : ATNConfigSet) {
        var prediction : Integer;
        if ambigAlts : constant := ambigAlts then
            prediction := ambigAlts.firstSetBit()
        else
            configAlts : constant := configs.getAlts()
            prediction := configAlts.firstSetBit()
        end ;
        if configs.fullCtx and then prediction /= conflictingAltResolvedBySLL then
            -- Even though this is an ambiguity we are reporting, we can
            -- still detect some context sensitivities.  Both SLL and LL
            -- are showing a conflict, hence an ambiguity, but if they resolve
            -- to different minimum alternatives we have also identified a
            -- context sensitivity.
            decisions[currentDecision].contextSensitivities.append(
            ContextSensitivityInfo(currentDecision, configs, _input, startIndex, stopIndex)
            )
        end ;
        decisions[currentDecision].ambiguities.append(
        AmbiguityInfo(currentDecision, configs, ambigAlts!,
                _input, startIndex, stopIndex, configs.fullCtx)
        )
        super.reportAmbiguity(dfa, D, startIndex, stopIndex, exact, ambigAlts!, configs)
    end ;


    public function getDecisionInfo () return [DecisionInfo] {
        return decisions
    end ;
end ;
