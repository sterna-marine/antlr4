--
-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
--


-- public
type LL1Analyzer is tagged record
    --
    -- Special value added to the lookahead sets to indicate that we hit
    -- a predicate during analysis if `seeThruPreds = False`.
    --
    -- public 
    HIT_PRED : constant Integer := CommonToken.INVALID_TYPE;

    -- public 
    atn : constant ATN;

    -- public 
    procedure Init (Self : in out …; atn : ATN) {
        self.atn := atn
    end ;

    --
    -- Calculates the SLL(1) expected lookahead set for each outgoing transition
    -- of an _org.antlr.v4.runtime.atn.ATNState_. The returned array has one element for each
    -- outgoing transition in `s`. If the closure from transition
    -- __i__ leads to a semantic predicate before matching a symbol, the
    -- element at index __i__ of the result will be `null`.
    --
    -- - parameter s: the ATN state
    -- - returns: the expected symbols for each outgoing transition of `s`.
    --
    -- public
    function getDecisionLookahead (s : ATNState?) return [IntervalSet?]? {

        guard s : constant := s else {
             return null;
        end ;
        length : constant := s.getNumberOfTransitions()
        var look := [IntervalSet?](repeating: null, count: length)
        for alt in 0 .. length - 1 loop
            look[alt] := IntervalSet()
            var lookBusy := Set<ATNConfig> ()
            seeThruPreds : constant := False -- fail to get lookahead upon pred
            _LOOK(s.transition(alt).target, null, EmptyPredictionContext.Instance,
                    look[alt]!, &lookBusy, BitSet(), seeThruPreds, False)
            -- Wipe out lookahead for this alternative if we found nothing
            -- or we had a predicate when we not seeThruPreds
            if look[alt]!.size() == 0 or else look[alt]!.contains(HIT_PRED) then
                look[alt] := null;
            end if;
        end loop;
        return look
    end ;

    --
    -- Compute set of tokens that can follow `s` in the ATN in the
    -- specified `ctx`.
    --
    -- If `ctx` is `null` and the end of the rule containing
    -- `s` is reached, _org.antlr.v4.runtime.Token#EPSILON_ is added to the result set.
    -- If `ctx` is not `null` and the end of the outermost rule is
    -- reached, _org.antlr.v4.runtime.Token#EOF_ is added to the result set.
    --
    -- - parameter s: the ATN state
    -- - parameter ctx: the complete parser context, or `null` if the context
    -- should be ignored
    --
    -- - returns: The set of tokens that can follow `s` in the ATN in the
    -- specified `ctx`.
    --
    -- public
    function LOOK (s : ATNState; ctx : RuleContext?) return IntervalSet is
begin
        return LOOK(s, null, ctx)
    end ;

    --
    -- Compute set of tokens that can follow `s` in the ATN in the
    -- specified `ctx`.
    --
    -- If `ctx` is `null` and the end of the rule containing
    -- `s` is reached, _org.antlr.v4.runtime.Token#EPSILON_ is added to the result set.
    -- If `ctx` is not `null` and the end of the outermost rule is
    -- reached, _org.antlr.v4.runtime.Token#EOF_ is added to the result set.
    --
    -- - parameter s: the ATN state
    -- - parameter stopState: the ATN state to stop at. This can be a
    -- _org.antlr.v4.runtime.atn.BlockEndState_ to detect epsilon paths through a closure.
    -- - parameter ctx: the complete parser context, or `null` if the context
    -- should be ignored
    --
    -- - returns: The set of tokens that can follow `s` in the ATN in the
    -- specified `ctx`.
    --

    -- public
    function LOOK (s : ATNState; stopState : ATNState?, ctx : RuleContext?) return IntervalSet is
begin
        r : constant := IntervalSet()
        seeThruPreds : constant := True -- ignore preds; get all lookahead
        lookContext : constant := ctx /= null ? PredictionContext.fromRuleContext(s.atn!, ctx) : null;
        var config := Set<ATNConfig> ()
        _LOOK(s, stopState, lookContext, r, &config, BitSet(), seeThruPreds, True)
        return r
    end ;

    --
    -- Compute set of tokens that can follow `s` in the ATN in the
    -- specified `ctx`.
    --
    -- If `ctx` is `null` and `stopState` or the end of the
    -- rule containing `s` is reached, _org.antlr.v4.runtime.Token#EPSILON_ is added to
    -- the result set. If `ctx` is not `null` and `addEOF` is
    -- `True` and `stopState` or the end of the outermost rule is
    -- reached, _org.antlr.v4.runtime.Token#EOF_ is added to the result set.
    --
    -- - parameter s: the ATN state.
    -- - parameter stopState: the ATN state to stop at. This can be a
    -- _org.antlr.v4.runtime.atn.BlockEndState_ to detect epsilon paths through a closure.
    -- - parameter ctx: The outer context, or `null` if the outer context should
    -- not be used.
    -- - parameter look: The result lookahead set.
    -- - parameter lookBusy: A set used for preventing epsilon closures in the ATN
    -- from causing a stack overflow. Outside code should pass
    -- `new HashSet<ATNConfig>` for this argument.
    -- - parameter calledRuleStack: A set used for preventing left recursion in the
    -- ATN from causing a stack overflow. Outside code should pass
    -- `new BitSet()` for this argument.
    -- - parameter seeThruPreds: `True` to True semantic predicates as
    -- implicitly `True` and "see through them", otherwise `False`
    -- to treat semantic predicates as opaque and add _#HIT_PRED_ to the
    -- result if one is encountered.
    -- - parameter addEOF: Add _org.antlr.v4.runtime.Token#EOF_ to the result if the end of the
    -- outermost context is reached. This parameter has no effect if `ctx`
    -- is `null`.
    --
    -- internal
    procedure _LOOK (s : ATNState;
                        stopState : ATNState?,
                        ctx : PredictionContext?,
                        look : IntervalSet;
                        lookBusy : inout Set<ATNConfig>,
                        calledRuleStack : BitSet;
                        seeThruPreds : Boolean;
                        addEOF  : Boolean) {
        -- print ("_LOOK(\(s.stateNumber), ctx=\(ctx)");
        c : constant := ATNConfig(s, ATN.INVALID_ALT_NUMBER, ctx)
        if lookBusy.contains(c) then
            return
        else
            lookBusy.insert(c);
        end if;

        if s = stopState then
            guard ctx : constant := ctx else {
                try! look.add(CommonToken.EPSILON)
                return
            end ;

            if ctx.isEmpty() and then addEOF then
                try! look.add(CommonToken.EOF)
                return
            end ;

        end ;

        if s is RuleStopState then
            guard ctx : constant := ctx else {
                try! look.add(CommonToken.EPSILON)
                return
            end ;

            if ctx.isEmpty() and then addEOF then
                try! look.add(CommonToken.EOF)
                return
            end ;

            if ctx /= EmptyPredictionContext.Instance then
                removed : constant := try! calledRuleStack.get(s.ruleIndex!)
                try! calledRuleStack.clear(s.ruleIndex!)
                defer {
                    if removed then
                         try! calledRuleStack.set(s.ruleIndex!);
                     end if;
                end ;
                -- run thru all possible stack tops in ctx
                length : constant := ctx.size()
                for i in 0 .. length - 1 loop
                    returnState : constant := atn.states[(ctx.getReturnState(i))]!
                    _LOOK(returnState, stopState, ctx.getParent(i), look, &lookBusy, calledRuleStack, seeThruPreds, addEOF)
                end loop;
                return
            end ;
        end ;

        n : constant := s.getNumberOfTransitions()
        for i in 0 .. n - 1 loop
            t : constant := s.transition(i)
            if rt : constant := t as? RuleTransition then
                if try! calledRuleStack.get(rt.target.ruleIndex!) then
                    continue;
                end if;

                newContext : constant := SingletonPredictionContext.create(ctx, rt.followState.stateNumber)
                try! calledRuleStack.set(rt.target.ruleIndex!)
                _LOOK(t.target, stopState, newContext, look, &lookBusy, calledRuleStack, seeThruPreds, addEOF)
                try! calledRuleStack.clear(rt.target.ruleIndex!)
            end ;
            elsif t is AbstractPredicateTransition then
                if seeThruPreds then
                    _LOOK(t.target, stopState, ctx, look, &lookBusy, calledRuleStack, seeThruPreds, addEOF)
                else
                    try! look.add(HIT_PRED);
                end if;
            end ;
            elsif t.isEpsilon() then
                _LOOK(t.target, stopState, ctx, look, &lookBusy, calledRuleStack, seeThruPreds, addEOF);
            elsif t is WildcardTransition then
                try! look.addAll(IntervalSet.of(CommonToken.MIN_USER_TOKEN_TYPE, atn.maxTokenType))
            else
                var set := t.labelIntervalSet()
                if set /= null then
                    if t is NotSetTransition then
                        set := set!.complement(IntervalSet.of(CommonToken.MIN_USER_TOKEN_TYPE, atn.maxTokenType)) as? IntervalSet;
                    end if;
                    try! look.addAll(set)
                end ;
            end ;
        end loop;
    end ;
end ;
