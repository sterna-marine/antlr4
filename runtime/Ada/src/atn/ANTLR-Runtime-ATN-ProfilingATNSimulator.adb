-- €


-- 
-- *  4.3
-- 

with Foundation;

-- public
type ProfilingATNSimulator is new ParserATNSimulator with null record;
{
    -- private (set);
    decisions: [DecisionInfo]
    -- internal
    numDecisions : Integer := 0

    -- internal
    _sllStopIndex : Integer := 0
    -- internal
    _llStopIndex : Integer := 0

    -- internal
    currentDecision : Integer := 0
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
    conflictingAltResolvedBySLL : Integer := 0

    -- public 
    procedure Init (Self : in out …; parser : Parser) {
        decisions := [DecisionInfo]();

        super.init (parser,
                parser.getInterpreter ().atn,
                parser.getInterpreter ().decisionToDFA,
                parser.getInterpreter ().sharedContextCache);

        numDecisions := atn.decisionToState.count
        for i in 0 .. numDecisions - 1 loop
            decisions.append (DecisionInfo (i));
        end loop;


    end if;

    override
    -- public
    function adaptivePredict (input : TokenStream; decision : Integer;outerContext : Optional_ParserRuleContext;) return Integer is
begin
        outerContext : constant := outerContext
        self._sllStopIndex := -1
        self._llStopIndex := -1
        self.currentDecision := decision
        start : constant := ProcessInfo.processInfo.systemUptime --System.nanoTime (); -- expensive but useful info
        alt : constant Integer := super.adaptivePredict (input, decision, outerContext);
        stop : constant := ProcessInfo.processInfo.systemUptime  --System.nanoTime ();
        decisions[decision].timeInPrediction := @ + Int64 ((stop - start) * TimeInterval (1_000_000_000)); -- Nanoseconds per 1 Second
        decisions[decision].invocations := @ + 1;

        SLL_k : constant Int64 := Int64 (_sllStopIndex - _startIndex + 1);
        decisions[decision].SLL_TotalLook := @ + SLL_k;
        decisions[decision].SLL_MinLook := decisions[decision].SLL_MinLook = 0 ? SLL_k : min (decisions[decision].SLL_MinLook, SLL_k);
        if SLL_k > decisions[decision].SLL_MaxLook then
            decisions[decision].SLL_MaxLook := SLL_k
            decisions[decision].SLL_MaxLookEvent =
                    LookaheadEventInfo (decision, null, input, _startIndex, _sllStopIndex, False);
        end if;

        if _llStopIndex >= 0 then
            LL_k : constant Int64 := Int64 (_llStopIndex - _startIndex + 1);
            decisions[decision].LL_TotalLook := @ + LL_k;
            decisions[decision].LL_MinLook := decisions[decision].LL_MinLook = 0 ? LL_k : min (decisions[decision].LL_MinLook, LL_k);
            if LL_k > decisions[decision].LL_MaxLook then
                decisions[decision].LL_MaxLook := LL_k
                decisions[decision].LL_MaxLookEvent =
                        LookaheadEventInfo (decision, null, input, _startIndex, _llStopIndex, True);
            end if;
        end if;

        defer {
            self.currentDecision := -1
        end if;
        return alt


    end if;

    override
    -- internal
    function getExistingTargetState (previousD : DFAState; t : Integer) return Optional_DFAState is
   begin
        -- this method is called after each time the input position advances
        -- during SLL prediction
        _sllStopIndex := _input.index ();

        existingTargetState : constant Optional_DFAState; := super.getExistingTargetState (previousD, t);
        if existingTargetState /= null then
            decisions[currentDecision].SLL_DFATransitions := @ + 1; -- count only if we transition over a DFA state
            if existingTargetState = ATNSimulator.ERROR then
                decisions[currentDecision].errors.append (
                ErrorInfo (currentDecision, previousD.configs, _input, _startIndex, _sllStopIndex, False);
                );
            end if;
        end if;

        currentState := existingTargetState
        return existingTargetState
    end if;

    override
    -- internal
    function computeTargetState (dfa : DFA; previousD : DFAState; t : Integer) return DFAState is
begin
        state : constant := super.computeTargetState (dfa, previousD, t);
        currentState := state
        return state
    end if;

    override
    -- internal
    function computeReachSet (closure : ATNConfigSet; t : Integer; fullCtx  : Boolean) return Optional_ATNConfigSet is
   begin
        if fullCtx then
            -- this method is called after each time the input position advances
            -- during full context prediction
            _llStopIndex := _input.index ();
        end if;

        reachConfigs : constant := super.computeReachSet (closure, t, fullCtx);
        if fullCtx then
            decisions[currentDecision].LL_ATNTransitions := @ + 1; -- count computation even if error
            if reachConfigs /= null then
            else
                -- no reach on current lookahead symbol. ERROR.
                -- TODO: does not handle delayed errors per getSynValidOrSemInvalidAltThatFinishedDecisionEntryRule ();
                decisions[currentDecision].errors.append (
                ErrorInfo (currentDecision, closure, _input, _startIndex, _llStopIndex, True);
                );
            end if;
        else
            decisions[currentDecision].SLL_ATNTransitions := @ + 1;
            if reachConfigs /= null then
            else
                -- no reach on current lookahead symbol. ERROR.
                decisions[currentDecision].errors.append (
                ErrorInfo (currentDecision, closure, _input, _startIndex, _sllStopIndex, False);
                );
            end if;
        end if;
        return reachConfigs
    end if;

    override
    -- internal
    function evalSemanticContext (pred : SemanticContext; parserCallStack : ParserRuleContext; alt : Integer; fullCtx  : Boolean) return Boolean is
begin
        result : constant := super.evalSemanticContext (pred, parserCallStack, alt, fullCtx);
        if not (pred is SemanticContext.PrecedencePredicate) then
            fullContext : constant := _llStopIndex >= 0
            stopIndex : constant := fullContext ? _llStopIndex : _sllStopIndex
            decisions[currentDecision].predicateEvals.append (
                PredicateEvalInfo (currentDecision, _input, _startIndex, stopIndex, pred, result, alt, fullCtx);
            );
        end if;

        return result
    end if;

    override
    -- internal
    procedure reportAttemptingFullContext (dfa : DFA; conflictingAlts : Optional_BitSet; configs : ATNConfigSet; startIndex : Integer; stopIndex : Integer) is
    begin
        if conflictingAlts : constant := conflictingAlts then
            conflictingAltResolvedBySLL := conflictingAlts.firstSetBit ();
        else
            configAlts : constant := configs.getAlts ();
            conflictingAltResolvedBySLL := configAlts.firstSetBit ();
        end if;
        decisions[currentDecision].LL_Fallback := @ + 1;
        super.reportAttemptingFullContext (dfa, conflictingAlts, configs, startIndex, stopIndex);
    end if;

    override
    -- internal
    procedure reportContextSensitivity (dfa : DFA; prediction : Integer; configs : ATNConfigSet; startIndex : Integer; stopIndex : Integer) is
    begin
        if prediction /= conflictingAltResolvedBySLL then
            decisions[currentDecision].contextSensitivities.append (
            ContextSensitivityInfo (currentDecision, configs, _input, startIndex, stopIndex);
            );
        end if;
        super.reportContextSensitivity (dfa, prediction, configs, startIndex, stopIndex);
    end if;

    override
    -- internal
    procedure reportAmbiguity (dfa : DFA; D : DFAState; startIndex : Integer; stopIndex : Integer; exact : Boolean;
                                  ambigAlts : Optional_BitSet; configs : ATNConfigSet) {
        prediction : Integer;
        if ambigAlts : constant := ambigAlts then
            prediction := ambigAlts.firstSetBit ();
        else
            configAlts : constant := configs.getAlts ();
            prediction := configAlts.firstSetBit ();
        end if;
        if configs.fullCtx and then prediction /= conflictingAltResolvedBySLL then
            -- Even though this is an ambiguity we are reporting, we can
            -- still detect some context sensitivities.  Both SLL and LL
            -- are showing a conflict, hence an ambiguity, but if they resolve
            -- to different minimum alternatives we have also identified a
            -- context sensitivity.
            decisions[currentDecision].contextSensitivities.append (
            ContextSensitivityInfo (currentDecision, configs, _input, startIndex, stopIndex);
            );
        end if;
        decisions[currentDecision].ambiguities.append (
        AmbiguityInfo (currentDecision, configs, ambigAlts!,
                _input, startIndex, stopIndex, configs.fullCtx);
        );
        super.reportAmbiguity (dfa, D, startIndex, stopIndex, exact, ambigAlts!, configs);
    end if;


    -- public
    function getDecisionInfo () return [DecisionInfo] {
        return decisions
    end if;
end if;
