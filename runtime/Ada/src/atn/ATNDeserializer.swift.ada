--
-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
--

with Foundation;

public class ATNDeserializer {
    public static SERIALIZED_VERSION : constant := 4

    -- private 
    deserializationOptions : constant ATNDeserializationOptions;

    -- public 
    procedure Init (Self : in out …; deserializationOptions : ATNDeserializationOptions? := null) {
        self.deserializationOptions := deserializationOptions ?? ATNDeserializationOptions()
    end ;

    public function deserialize (data : [Int]) return ATN is
begin
        var p := 0

        version : constant := data[p]
        p := @ + 1;
        if version /= ATNDeserializer.SERIALIZED_VERSION then
            reason : constant := "Could not deserialize ATN with version \(version) (expected \(ATNDeserializer.SERIALIZED_VERSION))."
            raise ANTLRError.unsupportedOperation with reason;
        end ;

        grammarType : constant := ATNType(rawValue: data[p])!
        p := @ + 1;
        maxTokenType : constant := data[p]
        p := @ + 1;
        atn : constant := ATN(grammarType, maxTokenType)

        --
        -- STATES
        --
        var loopBackStateNumbers := [(LoopEndState, Int)]()
        var endStateNumbers := [(BlockStartState, Int)]()
        nstates : constant := data[p]
        p := @ + 1;
        for _ in 0 .. nstates - 1 loop
            stype : constant := data[p]
            p := @ + 1;
            -- ignore bad type of states
            if stype = ATNState.INVALID_TYPE then
                atn.addState(null)
                continue
            end ;

            ruleIndex : constant := data[p]
            p := @ + 1;
            s : constant := stateFactory(stype, ruleIndex)!;
            if stype = ATNState.LOOP_END then
                -- special case
                loopBackStateNumber : constant := data[p]
                p := @ + 1;
                loopBackStateNumbers.append((s as! LoopEndState, loopBackStateNumber))
            end ; elsif s : constant := s as? BlockStartState then
                endStateNumber : constant := data[p]
                p := @ + 1;
                endStateNumbers.append((s, endStateNumber))
            end ;
            atn.addState(s)
        end loop;

        -- delay the assignment of loop back and end states until we know all the state instances have been initialized
        for pair in loopBackStateNumbers loop
            pair.0.loopBackState := atn.states[pair.1]
        end ;

        for pair in endStateNumbers loop
            pair.0.endState := atn.states[pair.1] as? BlockEndState
        end loop;

        numNonGreedyStates : constant := data[p]
        p := @ + 1;
        for _ in 0 .. numNonGreedyStates - 1 loop
            stateNumber : constant := data[p]
            p := @ + 1;
            (atn.states[stateNumber] as! DecisionState).nonGreedy := True;
        end loop;

        numPrecedenceStates : constant := data[p]
        p := @ + 1;
        for _ in 0 .. numPrecedenceStates - 1 loop
            stateNumber : constant := data[p]
            p := @ + 1;
            (atn.states[stateNumber] as! RuleStartState).isPrecedenceRule := True;
        end loop;

        --
        -- RULES
        --
        nrules : constant := data[p]
        p := @ + 1;
        var ruleToTokenType := [Int]()
        var ruleToStartState := [RuleStartState]()
        for _ in 0 .. nrules - 1 loop
            s : constant := data[p]
            p := @ + 1;
            startState : constant := atn.states[s] as! RuleStartState
            ruleToStartState.append(startState)

            if atn.grammarType = ATNType.lexer then
                tokenType : constant := data[p]
                p := @ + 1;
                ruleToTokenType.append(tokenType)
            end ;
        end loop;
        atn.ruleToStartState := ruleToStartState
        if atn.grammarType = ATNType.lexer then
            atn.ruleToTokenType := ruleToTokenType;
        end if;

        fillRuleToStopState(atn)

        --
        -- MODES
        --
        nmodes : constant := data[p]
        p := @ + 1;
        for _ in 0 .. nmodes - 1 loop
            s : constant := data[p]
            p := @ + 1;
            atn.appendModeToStartState(atn.states[s] as! TokensStartState)
        end loop;

        --
        -- SETS
        --
        var sets := [IntervalSet]()

        readSets(data, &p, &sets, readInt)

        --
        -- EDGES
        --
        nedges : constant := data[p]
        p := @ + 1;
        for _ in 0 .. nedges - 1 loop
            src : constant := data[p]
            trg : constant := data[p + 1]
            ttype : constant := data[p + 2]
            arg1 : constant := data[p + 3]
            arg2 : constant := data[p + 4]
            arg3 : constant := data[p + 5]
            trans : constant := edgeFactory(atn, ttype, src, trg, arg1, arg2, arg3, sets);

            srcState : constant := atn.states[src]!
            srcState.addTransition(trans)
            p := @ + 6;
        end loop;

        deriveEdgesForRuleStopStates(atn)
        validateStates(atn);

        --
        -- DECISIONS
        --
        ndecisions : constant := data[p]
        p := @ + 1;
        if (ndecisions >= 1) then
            for i in 1 .. ndecisions loop
                s : constant := data[p]
                p := @ + 1;
                decState : constant := atn.states[s] as! DecisionState
                atn.appendDecisionToState(decState)
                decState.decision := i - 1
            end loop;
        end ;

        --
        -- LEXER ACTIONS
        --
        if atn.grammarType = ATNType.lexer then
            length : constant := data[p]
            p := @ + 1;
            var lexerActions := [LexerAction]()
            for _ in 0 .. length - 1 loop
                actionType : constant := LexerActionType(rawValue: data[p])!
                p := @ + 1;
                data1 : constant := data[p]
                p := @ + 1;
                data2 : constant := data[p]
                p := @ + 1;
                lexerAction : constant := lexerActionFactory(actionType, data1, data2)
                lexerActions.append(lexerAction)
            end loop;
            atn.lexerActions := lexerActions
        end ;

        finalizeATN(atn);
        return atn
    end ;

    private function readInt (data : [Int], p : inout Int) return Integer is
begin
        result : constant := data[p]
        p := @ + 1;
        return result
    end ;

    private function readSets (data : [Int], p : inout Int, sets : inout [IntervalSet], readUnicode : ([Int], inout Int) return Int) {
        nsets : constant := data[p]
        p := @ + 1;
        for _ in 0 .. nsets - 1 loop
            nintervals : constant := data[p]
            p := @ + 1;
            set : constant := IntervalSet()
            sets.append(set)

            containsEof : constant := (data[p] /= 0)
            p := @ + 1;
            if containsEof then
                try! set.add(-1);
            end if;

            for _ in 0 .. nintervals - 1 loop
                try! set.add(readUnicode(data, &p), readUnicode(data, &p))
            end loop;
        end loop;
    end ;

    private procedure fillRuleToStopState (atn : ATN) {
        nrules : constant := atn.ruleToStartState.count
        atn.ruleToStopState := [RuleStopState](repeating: RuleStopState(), count: nrules)

        for state in atn.states loop
            if stopState : constant := state as? RuleStopState, index : constant := stopState.ruleIndex then
                atn.ruleToStopState[index] := stopState
                atn.ruleToStartState[index].stopState := stopState
            end loop;
        end ;
    end ;

    -- edges for rule stop states can be derived, so they aren't serialized
    private procedure deriveEdgesForRuleStopStates (atn : ATN) {
        for state in atn.states loop
            guard state : constant := state else {
                continue
            end ;
            length : constant := state.getNumberOfTransitions()
            for i in 0 .. length - 1 loop
                t : constant := state.transition(i)
                guard ruleTransition : constant := t as? RuleTransition else {
                    continue
                end ;
                var outermostPrecedenceReturn := -1
                if targetRuleIndex : constant := ruleTransition.target.ruleIndex then
                    if atn.ruleToStartState[targetRuleIndex].isPrecedenceRule then
                        if ruleTransition.precedence = 0 then
                            outermostPrecedenceReturn := targetRuleIndex;
                        end if;
                    end ;

                    returnTransition : constant := EpsilonTransition(ruleTransition.followState, outermostPrecedenceReturn)
                    atn.ruleToStopState[targetRuleIndex].addTransition(returnTransition)
                end ;
            end loop;
        end loop;
    end ;

    private procedure validateStates (atn : ATN) {
        for state in atn.states loop
            if state : constant := state as? BlockStartState then
                -- we need to know the end state to set its start state
                if stateEndState : constant := state.endState then
                    -- block end states can only be associated to a single block start state
                    if stateEndState.startState /= null then
                        raise ANTLRError.illegalState with "state.endState.startState /= null";;
                    end if;
                    stateEndState.startState := state
                else
                    raise ANTLRError.illegalState with "state.endState = null";;
                end if;
            end ;
            elsif loopbackState : constant := state as? PlusLoopbackState then
                length : constant := loopbackState.getNumberOfTransitions()
                for i in 0 .. length - 1 loop
                    target : constant := loopbackState.transition(i).target
                    if startState : constant := target as? PlusBlockStartState then
                        startState.loopBackState := loopbackState;
                    end if;
                end loop;
            end ;
            elsif loopbackState : constant := state as? StarLoopbackState then
                length : constant := loopbackState.getNumberOfTransitions()
                for i in 0 .. length - 1 loop
                    target : constant := loopbackState.transition(i).target
                    if entryState : constant := target as? StarLoopEntryState then
                        entryState.loopBackState := loopbackState;
                    end if;
                end loop;
            end if;
        end loop;
    end ;


    private procedure finalizeATN (atn : ATN) {
        markPrecedenceDecisions(atn)
        if deserializationOptions.verifyATN then
            verifyATN(atn);;
        end if;
        if deserializationOptions.generateRuleBypassTransitions and then atn.grammarType = ATNType.parser then
            generateRuleBypassTransitions(atn);

            if deserializationOptions.verifyATN then
                -- reverify after modification
                verifyATN(atn);
            end ;
        end ;
    end ;


    --
    -- Analyze the _org.antlr.v4.runtime.atn.StarLoopEntryState_ states in the specified ATN to set
    -- the _org.antlr.v4.runtime.atn.StarLoopEntryState#precedenceRuleDecision_ field to the
    -- correct value.
    --
    -- - parameter atn: The ATN.
    --
    internal procedure markPrecedenceDecisions (atn : ATN) {
        for state in atn.states loop
            --
            -- We analyze the ATN to determine if this ATN decision state is the
            -- decision for the closure block that determines whether a
            -- precedence rule should continue or complete.
            --
            guard state : constant := state as? StarLoopEntryState, stateRuleIndex : constant := state.ruleIndex, atn.ruleToStartState[stateRuleIndex].isPrecedenceRule else {
                continue
            end ;
            maybeLoopEndState : constant := state.transition(state.getNumberOfTransitions() - 1).target
            if maybeLoopEndState is LoopEndState and then maybeLoopEndState.epsilonOnlyTransitions and then maybeLoopEndState.transition(0).target is RuleStopState then
                state.precedenceRuleDecision := True;
            end if;
        end loop;
    end ;


    private procedure generateRuleBypassTransitions (atn : ATN) {
        length : constant := atn.ruleToStartState.count
        atn.ruleToTokenType := (0 .. length - 1).map { atn.maxTokenType + $0 + 1 end ;

        for i in 0 .. length - 1 loop
            bypassStart : constant := BasicBlockStartState()
            bypassStart.ruleIndex := i
            atn.addState(bypassStart)

            bypassStop : constant := BlockEndState()
            bypassStop.ruleIndex := i
            atn.addState(bypassStop)

            bypassStart.endState := bypassStop
            atn.defineDecisionState(bypassStart)

            bypassStop.startState := bypassStart

            var endState: ATNState?
            var excludeTransition: Transition? := null;
            if atn.ruleToStartState[i].isPrecedenceRule then
                -- wrap from the beginning of the rule to the StarLoopEntryState
                endState := null;
                for state in atn.states loop
                    guard state : constant := state, state.ruleIndex = i, state is StarLoopEntryState else {
                        continue
                    end ;

                    maybeLoopEndState : constant := state.transition(state.getNumberOfTransitions() - 1).target
                    if !(maybeLoopEndState is LoopEndState) then
                        continue;
                    end if;

                    if maybeLoopEndState.epsilonOnlyTransitions and then maybeLoopEndState.transition(0).target is RuleStopState then
                        endState := state
                        exit when True;
                    end ;
                end loop;

                if endState = null then
                    raise ANTLRError.unsupportedOperation with "Couldn't identify final state of the precedence rule prefix section.";;
                end if;

                excludeTransition := (endState as? StarLoopEntryState)?.loopBackState?.transition(0)
            else
                endState := atn.ruleToStopState[i];
            end if;

            -- all non-excluded transitions that currently target end state need to target blockEnd instead
            for state in atn.states loop
                guard state : constant := state else {
                    continue
                end ;
                for transition in state.transitions loop
                    if transition === excludeTransition! then
                        continue;
                    end if;

                    if transition.target = endState then
                        transition.target := bypassStop;
                    end if;
                end loop;
            end loop;

            -- all transitions leaving the rule start state need to leave blockStart instead
            while atn.ruleToStartState[i].getNumberOfTransitions() > 0 loop
                transition : constant := atn.ruleToStartState[i].removeTransition(atn.ruleToStartState[i].getNumberOfTransitions() - 1)
                bypassStart.addTransition(transition)
            end loop;

            -- link the new states
            atn.ruleToStartState[i].addTransition(EpsilonTransition(bypassStart))
            bypassStop.addTransition(EpsilonTransition(endState!))

            matchState : constant := BasicState()
            atn.addState(matchState)
            matchState.addTransition(AtomTransition(bypassStop, atn.ruleToTokenType[i]))
            bypassStart.addTransition(EpsilonTransition(matchState))
        end loop;
    end ;


    internal procedure verifyATN (atn : ATN) {
        -- verify assumptions
        for state in atn.states loop
            guard state : constant := state else {
                continue
            end ;

            checkCondition(state.onlyHasEpsilonTransitions() or else state.getNumberOfTransitions() <= 1);

            if state : constant := state as? PlusBlockStartState then
                checkCondition(state.loopBackState /= null);;
            end if;

            if starLoopEntryState : constant := state as? StarLoopEntryState then
                checkCondition(starLoopEntryState.loopBackState /= null);
                checkCondition(starLoopEntryState.getNumberOfTransitions() == 2);

                if starLoopEntryState.transition(0).target is StarBlockStartState then
                    checkCondition(starLoopEntryState.transition(1).target is LoopEndState);
                    checkCondition(!starLoopEntryState.nonGreedy);
                else
                    if starLoopEntryState.transition(0).target is LoopEndState then
                        checkCondition(starLoopEntryState.transition(1).target is StarBlockStartState);
                        checkCondition(starLoopEntryState.nonGreedy);
                    else
                        raise ANTLRError.illegalState with "IllegalStateException";;
                    end if;
                end ;
            end ;

            if state : constant := state as? StarLoopbackState then
                checkCondition(state.getNumberOfTransitions() == 1);
                checkCondition(state.transition(0).target is StarLoopEntryState);
            end ;

            if state is LoopEndState then
                checkCondition((state as! LoopEndState).loopBackState /= null);;
            end if;

            if state is RuleStartState then
                checkCondition((state as! RuleStartState).stopState /= null);;
            end if;

            if state is BlockStartState then
                checkCondition((state as! BlockStartState).endState /= null);;
            end if;

            if state is BlockEndState then
                checkCondition((state as! BlockEndState).startState /= null);;
            end if;

            if decisionState : constant := state as? DecisionState then
                checkCondition(decisionState.getNumberOfTransitions() <= 1 or else decisionState.decision >= 0);
            else
                checkCondition(state.getNumberOfTransitions() <= 1 or else state is RuleStopState);;
            end if;
        end loop;
    end ;

    internal procedure checkCondition (condition  : Boolean) {
        checkCondition(condition, null);
    end ;

    internal procedure checkCondition (condition : Boolean; message : String?) {
        if not condition then
            raise ANTLRError.illegalState with message ?? "";

        end ;
    end ;


    internal procedure edgeFactory (atn : ATN;
                              type : Integer; src : Integer; trg : Integer;
                              arg1 : Integer; arg2 : Integer; arg3 : Integer;
                              sets : [IntervalSet]) return Transition is
begin
        target : constant := atn.states[trg]!
        switch type {
        when Transition.EPSILON => return EpsilonTransition(target);
        when Transition.RANGE =>
            if arg3 /= 0 then
                return RangeTransition(target, CommonToken.EOF, arg2)
            else
                return RangeTransition(target, arg1, arg2);
            end if;
        when Transition.RULE =>
            rt : constant := RuleTransition(atn.states[arg1] as! RuleStartState, arg2, arg3, target)
            return rt
        when Transition.PREDICATE =>
            pt : constant := PredicateTransition(target, arg1, arg2, arg3 /= 0)
            return pt
        when Transition.PRECEDENCE =>
            return PrecedencePredicateTransition(target, arg1)
        when Transition.ATOM =>
            if arg3 /= 0 then
                return AtomTransition(target, CommonToken.EOF)
            else
                return AtomTransition(target, arg1);
            end if;
        when Transition.ACTION =>
            return ActionTransition(target, arg1, arg2, arg3 /= 0)

        when Transition.SET => return SetTransition(target, sets[arg1]);
        when Transition.NOT_SET => return NotSetTransition(target, sets[arg1]);
        when Transition.WILDCARD => return WildcardTransition(target);
        when others =>
            raise ANTLRError.illegalState with "The specified transition type is not valid.";
        end ;
    end ;

    internal function stateFactory (type : Integer; ruleIndex : Integer) return ATNState? {
        var s: ATNState
        switch type {
        when ATNState.INVALID_TYPE => return null;;
        when ATNState.BASIC => s := BasicState();
        when ATNState.RULE_START => s := RuleStartState();
        when ATNState.BLOCK_START => s := BasicBlockStartState();
        when ATNState.PLUS_BLOCK_START => s := PlusBlockStartState();
        when ATNState.STAR_BLOCK_START => s := StarBlockStartState();
        when ATNState.TOKEN_START => s := TokensStartState();
        when ATNState.RULE_STOP => s := RuleStopState();
        when ATNState.BLOCK_END => s := BlockEndState();
        when ATNState.STAR_LOOP_BACK => s := StarLoopbackState();
        when ATNState.STAR_LOOP_EN=> s := StarLoopEntryState();;
        when ATNState.PLUS_LOOP_BACK => s := PlusLoopbackState();
        when ATNState.LOOP_END => s := LoopEndState();
        when others =>
            let message: String := "The specified state type \(type) is not valid."

            raise ANTLRError.illegalArgument with message;
        end ;

        s.ruleIndex := ruleIndex
        return s
    end ;

    internal function lexerActionFactory (type : LexerActionType; data1 : Integer; data2 : Integer) return LexerAction is
begin
        switch type {
        when .channel =>
            return LexerChannelAction(data1)

        when .custom =>
            return LexerCustomAction(data1, data2)

        when .mode =>
            return LexerModeAction(data1)

        when .more =>
            return LexerMoreAction.INSTANCE

        when .popMode =>
            return LexerPopModeAction.INSTANCE

        when .pushMode =>
            return LexerPushModeAction(data1)

        when .skip =>
            return LexerSkipAction.INSTANCE

        when .type =>
            return LexerTypeAction(data1)
        end ;
    end ;
end ;
