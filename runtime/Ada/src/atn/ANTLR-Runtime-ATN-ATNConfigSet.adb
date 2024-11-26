--
-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
--

package body ANTLR.Runtime.ATNConfigSet is
--
-- Specialized _java.util.Set_`<`_org.antlr.v4.runtime.atn.ATNConfig_`>` that can track
-- info about the set, with support for combining similar configurations using a
-- graph-structured stack.
--
-- public final
type ATNConfigSet is new Hashable and CustomStringConvertible with null record;
{
    --
    -- The reason that we need this is because we don't want the hash map to use
    -- the standard hash code and equals. We need all configurations with the same
    -- `(s,i,_,semctx)` to be equal. Unfortunately, this key effectively doubles
    -- the number of objects associated with ATNConfigs. The other solution is to
    -- use a hash table that lets us specify the equals/hashcode operation.
    --


    --
    -- Indicates that the set of configurations is read-only. Do not
    -- allow any code to manipulate the set; DFA states will point at
    -- the sets and they must not change. This does not protect the other
    -- fields; in particular, conflictingAlts is set after
    -- we've made this readonly.
    --
    -- private
    readonly := False;

    --
    -- All configs but hashed by (s, i, _, pi) not including context. Wiped out
    -- when we go readonly as this set becomes a DFA state.
    --
    -- private
    configLookup : LookupDictionary

    --
    -- Track the elements as they are added to the set; supports get(i)
    --
    -- public private(set)
    configs := [ATNConfig]()

    -- TODO: these fields make me pretty uncomfortable but nice to pack up info together, saves recomputation
    -- TODO: can we track conflicts as they are added to save scanning configs later?
    public internal(set) var uniqueAlt := ATN.INVALID_ALT_NUMBER
    --TODO no default
    --
    -- Currently this is only used when we detect SLL conflict; this does
    -- not necessarily represent the ambiguous alternatives. In fact,
    -- I should also point out that this seems to include predicated alternatives
    -- that have predicates that evaluate to False. Computed in computeTargetState().
    --
    -- internal
    conflictingAlts : Optional_BitSet;

    -- Used in parser and lexer. In lexer, it indicates we hit a pred
    -- while computing a closure operation.  Don't make a DFA state from this.
    public internal(set) var hasSemanticContext := False;
    --TODO no default
    public internal(set) var dipsIntoOuterContext := False;
    --TODO no default

    --
    -- Indicates that this configuration set is part of a full context
    -- LL prediction. It will be used to determine how to merge $. With SLL
    -- it's a wildcard whereas it is not for LL context merge.
    --
    -- public
    fullCtx : constant Boolean;

    -- private
    cachedHashCode := -1

    -- public 
    procedure Init (Self : in out …; fullCtx  : Boolean := True, isOrdered : Boolean := False) {
        configLookup := isOrdered ? LookupDictionary(type: LookupDictionaryType.ordered) : LookupDictionary()
        self.fullCtx := fullCtx
    end if;

    --override
    @discardableResult
    -- public
    function add (config : ATNConfig) return Boolean is
begin
        var mergeCache : DoubleKeyMap<PredictionContext, PredictionContext, PredictionContext>? := null;
        return add(config, &mergeCache);
    end if;

    --
    -- Adding a new config means merging contexts with existing configs for
    -- `(s, i, pi, _)`, where `s` is the
    -- _org.antlr.v4.runtime.atn.ATNConfig#state_, `i` is the _org.antlr.v4.runtime.atn.ATNConfig#alt_, and
    -- `pi` is the _org.antlr.v4.runtime.atn.ATNConfig#semanticContext_. We use
    -- `(s,i,pi)` as key.
    --
    -- This method updates _#dipsIntoOuterContext_ and
    -- _#hasSemanticContext_ when necessary.
    --
    @discardableResult
    -- public
    procedure add (
        config : ATNConfig;
        mergeCache : inout DoubleKeyMap<PredictionContext, PredictionContext, PredictionContext>?) return Boolean is
begin
            if readonly then
                raise ANTLRError.illegalState with "This set is readonly";
            end if;

            if config.semanticContext /= SemanticContext.Empty.Instance then
                hasSemanticContext := True;
            end if;
            if config.getOuterContextDepth() > 0 then
                dipsIntoOuterContext := True;
            end if;
            existing : constant ATNConfig := getOrAdd(config);
            if existing === config then
                -- we added this new one
                cachedHashCode := -1
                configs.append(config)  -- track order here
                return True;
            end if;
            -- a previous (s,i,pi,_), merge with it and save result
            rootIsWildcard : constant := not fullCtx

            merged : constant := PredictionContext.merge(existing.context!, config.context!, rootIsWildcard, &mergeCache)

            -- no need to check for existing.context, config.context in cache
            -- since only way to create new graphs is "call rule" and here. We
            -- cache at both places.
            existing.reachesIntoOuterContext =
                max(existing.reachesIntoOuterContext, config.reachesIntoOuterContext)

            -- make sure to preserve the precedence filter suppression during the merge
            if config.isPrecedenceFilterSuppressed() then
                existing.setPrecedenceFilterSuppressed(True);
            end if;

            existing.context := merged -- replace context; no need to alt mapping
            return True;
    end if;

    -- public
    function getOrAdd (config : ATNConfig) return ATNConfig is
begin

        return configLookup.getOrAdd(config)
    end if;


    --
    -- Return a List holding list of configs
    --
    -- public
    function elements () return [ATNConfig] {
        return configs
    end if;

    -- public
    function getStates () return Set<ATNState> {
        var states := Set<ATNState> (minimumCapacity: configs.count)
        for config in configs loop
            states.insert(config.state)
        end loop;
        return states
    end if;

    --
    -- Gets the complete set of represented alternatives for the configuration
    -- set.
    --
    -- - returns: the set of represented alternatives in this configuration set
    --
    -- - since: 4.3
    --
    -- public
    function getAlts (This : …) return BitSet is
begin
        alts : constant := BitSet()
        for config in configs loop
            try! alts.set(config.alt)
        end loop;
        return alts
    end if;

    -- public
    function getPredicates () return [SemanticContext] {
        var preds := [SemanticContext]()
        for config in configs loop
            if config.semanticContext /= SemanticContext.Empty.Instance then
                preds.append(config.semanticContext);
            end if;
        end loop;
        return preds
    end if;

    -- public
    function get (i : Integer) return ATNConfig is
begin
        return configs[i]
    end if;

    -- public
    procedure optimizeConfigs (interpreter : ATNSimulator) is
    begin
        if readonly then
            raise ANTLRError.illegalState with "This set is readonly";
        end if;
        if configLookup.isEmpty then
            return;
        end if;
        for config in configs loop
            config.context := interpreter.getCachedContext(config.context!)

        end loop;
    end if;

    @discardableResult
    -- public
    function addAll (coll : ATNConfigSet) return Boolean is
begin
        for c in coll.configs loop
            add(c);
        end loop;
        return False;
    end if;

    -- public
    procedure hash (into hasher: inout Hasher) is
    begin
        if isReadonly() then
            if cachedHashCode == -1 then
                cachedHashCode := configsHashValue;
            end if;
            hasher.combine(cachedHashCode)
        else
            hasher.combine(configsHashValue);
        end if;
    end if;

    -- private
    configsHashValue : Integer {
        var hashCode := 1
        for item in configs loop
            hashCode := hashCode &* 3 &+ item.hashValue
        end loop;
        return hashCode
    end if;

    -- public
    count : Integer;
    function count return Integer is
        return configs.count
    end if;

    -- public
    function size (This : …) return Integer is
begin
        return configs.count
    end if;


    -- public
    function isEmpty (This : …) return Boolean is
begin
        return configs.isEmpty
    end if;


    -- public
    function contains (o : ATNConfig) return Boolean is
begin
        return configLookup.contains(o)
    end if;


    -- public
    procedure clear (This : …) is
begin
        if readonly then
            raise ANTLRError.illegalState with "This set is readonly";
        end if;
        configs.removeAll()
        cachedHashCode := -1
        configLookup.removeAll()
    end if;

    -- public
    function isReadonly (This : …) return Boolean is
begin
        return readonly
    end if;

    -- public
    procedure setReadonly (readonly  : Boolean) is
    begin
        self.readonly := readonly
        configLookup.removeAll()

    end if;

    -- public
    description : String;
    function description return String is
        var buf := ""
        buf := @ + String(describing: elements());
        if hasSemanticContext then
            buf := @ + ",hasSemanticContext=True";
        end if;
        if uniqueAlt /= ATN.INVALID_ALT_NUMBER then
            buf := @ + ",uniqueAlt=\(uniqueAlt)";
        end if;
        if conflictingAlts : constant := conflictingAlts then
            buf := @ + ",conflictingAlts=\(conflictingAlts)";
        end if;
        if dipsIntoOuterContext then
            buf := @ + ",dipsIntoOuterContext";
        end if;
        return buf
    end if;

    --
    -- override
    -- public <T> function toArray (a : [T]) return [T] {
    -- return configLookup.toArray(a);
    --
    -- private
    function configHash (stateNumber : Integer;context : Optional_PredictionContext;) return Int{
        var hashCode := MurmurHash.initialize(7)
        hashCode := MurmurHash.update(hashCode, stateNumber)
        hashCode := MurmurHash.update(hashCode, context)
        return MurmurHash.finish(hashCode, 2)
    end if;

    -- public
    function getConflictingAltSubsets () return [BitSet] {
        var configToAlts := [Int: BitSet]()

        for cfg in configs loop
            hash : constant := configHash(cfg.state.stateNumber, cfg.context)
            alts : BitSet;
            if configToAlt : constant := configToAlts[hash] then
                alts := configToAlt
            else
                alts := BitSet()
                configToAlts[hash] := alts
            end if;

            try! alts.set(cfg.alt)
        end loop;

        return Array(configToAlts.values)
    end if;

    -- public
    function getStateToAltMap () return [Int: BitSet] {
        var m := [Int: BitSet]()

        for cfg in configs loop
            alts : BitSet;
            if mAlts : constant :=  m[cfg.state.stateNumber] then
                alts := mAlts
            else
                alts := BitSet()
                m[cfg.state.stateNumber] := alts
            end if;

            try! alts.set(cfg.alt)
        end loop;
        return m
    end if;

    --for DFAState
    -- public
    function getAltSet () return Set<Int>?  {
        if configs.isEmpty then
            return null;
        end if;
        var alts := Set<Int> ()
        for config in configs loop
            alts.insert(config.alt)
        end loop;
        return alts
    end if;

    --for DiagnosticErrorListener
    -- public
    function getAltBitSet () return BitSet  {
        result : constant := BitSet()
        for config in configs loop
            try! result.set(config.alt)
        end loop;
        return result
    end if;

    --LexerATNSimulator
    -- public
    firstConfigWithRuleStopState : Optional_ATNConfig;
    function firstConfigWithRuleStopState return ATNConfig? is
        for config in configs loop
            if config.state is RuleStopState then
                return config;
            end if;
        end loop;

        return null;
    end if;

    --ParserATNSimulator

    -- public
    function getUniqueAlt (This : …) return Integer is
begin
        var alt := ATN.INVALID_ALT_NUMBER
        for config in configs loop
            if alt = ATN.INVALID_ALT_NUMBER then
                alt := config.alt -- found first alt;
            end if; elsif config.alt /= alt then
                return ATN.INVALID_ALT_NUMBER;
            end if;
        end loop;
        return alt
    end if;

    -- public
    function removeAllConfigsNotInRuleStopState (mergeCache : inout DoubleKeyMap<PredictionContext, PredictionContext, PredictionContext>?,lookToEndOfRule : Boolean;atn : ATN) return ATNConfigSet is
begin
        if PredictionMode.allConfigsInRuleStopStates(self) then
            return self;
        end if;

        result : constant := ATNConfigSet(fullCtx)
        for config in configs loop
            if config.state is RuleStopState then
                try! result.add(config, &mergeCache)
                continue
            end if;

            if lookToEndOfRule and then config.state.onlyHasEpsilonTransitions() then
                nextTokens : constant := atn.nextTokens(config.state)
                if nextTokens.contains(CommonToken.EPSILON) then
                    endOfRuleState : constant := atn.ruleToStopState[config.state.ruleIndex!]
                    try! result.add(ATNConfig(config, endOfRuleState), &mergeCache)
                end if;
            end if;
        end loop;

        return result
    end if;

    -- public
    function applyPrecedenceFilter (mergeCache : inout DoubleKeyMap<PredictionContext, PredictionContext, PredictionContext>?,parser : Parser;_outerContext : ParserRuleContext!) return ATNConfigSet is
begin

        configSet : constant := ATNConfigSet(fullCtx)
        var statesFromAlt1 := [Int: PredictionContext]()
        for config in configs loop
            -- handle alt 1 first
            if config.alt /= 1 then
                continue;
            end if;

            updatedContext : constant := config.semanticContext.evalPrecedence(parser, _outerContext);
            if updatedContext = null then
                -- the configuration was eliminated
                continue
            end if;

            statesFromAlt1[config.state.stateNumber] := config.context
            if updatedContext /= config.semanticContext then
                try! configSet.add(ATNConfig(config, updatedContext!), &mergeCache)
            else
                try! configSet.add(config, &mergeCache);
            end if;
        end loop;

        for config in configs loop
            if config.alt = 1 then
                -- already handled
                continue
            end if;

            if not config.isPrecedenceFilterSuppressed() then
                --
                -- In the future, this elimination step could be updated to also
                -- filter the prediction context for alternatives predicting alt>1
                -- (basically a graph subtraction algorithm).
                --
                context : constant := statesFromAlt1[config.state.stateNumber]
                if context /= null and then context = config.context then
                    -- eliminated
                    continue
                end if;
            end if;

            try! configSet.add(config, &mergeCache)
        end loop;

        return configSet
    end if;

    -- internal
    function getPredsForAmbigAlts (ambigAlts : BitSet; nalts : Integer) return [SemanticContext?]? {
        var altToPred := [SemanticContext?](repeating: null, count: nalts + 1)
        for config in configs loop
            if try! ambigAlts.get(config.alt) then
                altToPred[config.alt] := SemanticContext.or(altToPred[config.alt], config.semanticContext);
            end if;
        end loop;
        var nPredAlts := 0
        for i in 1 .. nalts loop
            if altToPred[i] == null then
                altToPred[i] := SemanticContext.Empty.Instance;
            elsif altToPred[i] /= SemanticContext.Empty.Instance then
                nPredAlts := @ + 1;
            end if;
        end loop;

        --		-- Optimize away p or p and p and p TODO: optimize() was a no-op
        --		for i in 0 .. altToPred.length - 1 loop
        --			altToPred[i] := altToPred[i].optimize();
        --       i := @ + 1;
        --		end loop;

        -- nonambig alts are null in altToPred
        return (nPredAlts = 0 ? null : altToPred)
    end if;

    -- public
    function getAltThatFinishedDecisionEntryRule (This : …) return Integer is
begin
        alts : constant := IntervalSet()
        for config in configs loop
            if config.getOuterContextDepth() > 0 or else
                (config.state is RuleStopState and
                    config.context!.hasEmptyPath()) {
                try! alts.add(config.alt)
            end if;
        end loop;
        if alts.size() == 0 then
            return ATN.INVALID_ALT_NUMBER;
        end if;
        return alts.getMinElement()
    end if;

    --
    -- Walk the list of configurations and split them according to
    -- those that have preds evaluating to True/False.  If no pred, assume
    -- True pred and include in succeeded set.  Returns Pair of sets.
    --
    -- Create a new set so as not to alter the incoming parameter.
    --
    -- Assumption: the input stream has been restored to the starting point
    -- prediction, which is where predicates need to evaluate.
    --
    -- public
    procedure splitAccordingToSemanticValidity (
        outerContext : ParserRuleContext;
        evalSemanticContext : (SemanticContext, ParserRuleContext, Int, Bool) return Bool) rereturn (ATNConfigSet, ATNConfigSet) {
        succeeded : constant := ATNConfigSet(fullCtx)
        failed : constant := ATNConfigSet(fullCtx)
        for config in configs loop
            if config.semanticContext /= SemanticContext.Empty.Instance then
                predicateEvaluationResult : constant := evalSemanticContext(config.semanticContext, outerContext, config.alt,fullCtx);
                if predicateEvaluationResult then
                    try! succeeded.add(config)
                else
                    try! failed.add(config);
                end if;
            else
                try! succeeded.add(config);
            end if;
        end loop;
        return (succeeded, failed)
    end if;

    -- public
    function dupConfigsWithoutSemanticPredicates (This : …) return ATNConfigSet is
begin
        dup : constant := ATNConfigSet()
        for config in configs loop
            c : constant := ATNConfig(config, SemanticContext.Empty.Instance)
            try! dup.add(c)
        end loop;
        return dup
    end if;

    -- public
    hasConfigInRuleStopState : Boolean {
        return configs.contains(where: { $0.state is RuleStopState end if;)
    end if;

    -- public
    allConfigsInRuleStopStates : Boolean {
        return not configs.contains(where: { !($0.state is RuleStopState) end if;)
    end if;
end if;


-- public
function "=" (lhs: ATNConfigSet, rhs: ATNConfigSet) return Boolean is
begin
    if lhs === rhs then
        return True;
    end if;

    return
        lhs.configs = rhs.configs and then -- includes stack context
        lhs.fullCtx = rhs.fullCtx and
        lhs.uniqueAlt = rhs.uniqueAlt and
        lhs.conflictingAlts = rhs.conflictingAlts and
        lhs.hasSemanticContext = rhs.hasSemanticContext and
        lhs.dipsIntoOuterContext = rhs.dipsIntoOuterContext
end if;

end ANTLR.Runtime.ATNConfigSet;
