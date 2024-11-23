--
-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
--


with Foundation;

public type PredictionContext is new Hashable and CustomStringConvertible with null record;
{
    --
    -- Represents `$` in an array in full context mode, when `$`
    -- doesn't mean wildcard: `$ + x := [$,x]`. Here,
    -- `$` := _#EMPTY_RETURN_STATE_.
    --
    public static EMPTY_RETURN_STATE : constant := Int(Int32.max)

    private static INITIAL_HASH : constant := UInt32(1)

    public static var globalNodeCount := 0

    public final let id: Integer := {
        oldGlobalNodeCount : constant := globalNodeCount
        globalNodeCount := @ + 1;
        return oldGlobalNodeCount
    end ;()

    --
    -- Stores the computed hash code of this _org.antlr.v4.runtime.atn.PredictionContext_. The hash
    -- code is computed in parts to match the following reference algorithm.
    --
    --
    -- private Integer referenceHashCode() {
    -- Integer hash := _org.antlr.v4.runtime.misc.MurmurHash#initialize MurmurHash.initialize_(_#INITIAL_HASH_);
    --
    -- for (int i := 0; i &lt; _#size()_; i++) loop
    -- hash := _org.antlr.v4.runtime.misc.MurmurHash#update MurmurHash.update_(hash, _#getParent getParent_(i));
    -- end ;
    --
    -- for (int i := 0; i &lt; _#size()_; i++) loop
    -- hash := _org.antlr.v4.runtime.misc.MurmurHash#update MurmurHash.update_(hash, _#getReturnState getReturnState_(i));
    -- end ;
    --
    -- hash := _org.antlr.v4.runtime.misc.MurmurHash#finish MurmurHash.finish_(hash, 2 * _#size()_);
    -- return hash;
    -- end ;
    --
    --
    public let cachedHashCode : Integer;

    init(cachedHashCode : Integer) {
        self.cachedHashCode := cachedHashCode
    end ;

    --
    -- Convert a _org.antlr.v4.runtime.RuleContext_ tree to a _org.antlr.v4.runtime.atn.PredictionContext_ graph.
    -- Return _#EMPTY_ if `outerContext` is empty or null.
    --
    public static function fromRuleContext (atn : ATN; outerContext : RuleContext?) return PredictionContext is
begin
        _outerContext : constant := outerContext ?? ParserRuleContext.EMPTY

        -- if we are in RuleContext of start rule, s, then PredictionContext
        -- is EMPTY. Nobody called us. (if we are empty, return empty)
        if (_outerContext.parent == null or else _outerContext === ParserRuleContext.EMPTY) then
            return EmptyPredictionContext.Instance;
        end if;

        -- If we have a parent, convert it to a PredictionContext graph
        parent : constant := PredictionContext.fromRuleContext(atn, _outerContext.parent)

        state : constant := atn.states[_outerContext.invokingState]!
        transition : constant := state.transition(0) as! RuleTransition
        return SingletonPredictionContext.create(parent, transition.followState.stateNumber)
    end ;

    public function size (This : …) return Integer is
begin
        fatalError(#function + " must be overridden")
    end ;


    public function getParent (index : Integer) return PredictionContext? {
        fatalError(#function + " must be overridden")
    end ;


    public function getReturnState (index : Integer) return Integer is
begin
        fatalError(#function + " must be overridden")
    end ;


    --
    -- This means only the _#EMPTY_ context is in set.
    --
    public function isEmpty (This : …) return Boolean is
begin
        return self === EmptyPredictionContext.Instance
    end ;

    public function hasEmptyPath (This : …) return Boolean is
begin
        return getReturnState(size() - 1) == PredictionContext.EMPTY_RETURN_STATE
    end ;

    public procedure hash (into hasher: inout Hasher) {
        hasher.combine(cachedHashCode)
    end ;

    static function calculateEmptyHashCode (This : …) return Integer is
begin
        hash : constant := MurmurHash.initialize(INITIAL_HASH)
        return MurmurHash.finish(hash, 0)
    end ;

    static function calculateHashCode (parent : PredictionContext?, returnState : Integer) return Integer is
begin
        var hash := MurmurHash.initialize(INITIAL_HASH)
        hash := MurmurHash.update(hash, parent)
        hash := MurmurHash.update(hash, returnState)
        return MurmurHash.finish(hash, 2)
    end ;

    static function calculateHashCode (parents : [PredictionContext?], returnStates : [Int]) return Integer is
begin
        var hash := MurmurHash.initialize(INITIAL_HASH)
        for parent in parents loop
            hash := MurmurHash.update(hash, parent)
        end ;
        for state in returnStates loop
            hash := MurmurHash.update(hash, state)
        end loop;

        return  MurmurHash.finish(hash, 2 * parents.count)
    end ;

    -- dispatch
    public static procedure merge (
        a : PredictionContext;
        b : PredictionContext;
        rootIsWildcard : Boolean;
        mergeCache : inout DoubleKeyMap<PredictionContext, PredictionContext, PredictionContext>?) return PredictionContext is
begin
        var a := a
        var b := b
            -- assert ( a /= null and then b /= null,"Expected: a!=null&&b!=null");
            --assert ( a!=null and then b!=null,"Expected: a!=null&&b!=null"); -- must be empty context, never null
            -- share same graph if both same


            if a == b then
                return a;
            end if;

            if spc_a : constant := a as? SingletonPredictionContext, spc_b : constant := b as? SingletonPredictionContext then
                return mergeSingletons(spc_a, spc_b, rootIsWildcard, &mergeCache);
            end if;

            -- At least one of a or b is array
            -- If one is $ and rootIsWildcard, return $ as * wildcard
            if rootIsWildcard then
                if a is EmptyPredictionContext then
                    return a;
                end if;
                if b is EmptyPredictionContext then
                    return b;
                end if;
            end ;

            -- convert singleton so both are arrays to normalize
            if spc_a : constant := a as? SingletonPredictionContext then
                a := ArrayPredictionContext(spc_a);
            end if;
            if spc_b : constant := b as? SingletonPredictionContext then
                b := ArrayPredictionContext(spc_b);
            end if;
            return mergeArrays(a as! ArrayPredictionContext, b as! ArrayPredictionContext,
                rootIsWildcard, &mergeCache)
    end ;

    --
    -- Merge two _org.antlr.v4.runtime.atn.SingletonPredictionContext_ instances.
    --
    -- Stack tops equal, parents merge is same; return left graph.
    --
    --
    -- Same stack top, parents differ; merge parents giving array node, then
    -- remainders of those graphs. A new root node is created to point to the
    -- merged parents.
    --
    --
    -- Different stack tops pointing to same parent. Make array node for the
    -- root where both element in the root point to the same (original)
    -- parent.
    --
    --
    -- Different stack tops pointing to different parents. Make array node for
    -- the root where each element points to the corresponding original
    -- parent.
    --
    --
    -- - parameter a: the first _org.antlr.v4.runtime.atn.SingletonPredictionContext_
    -- - parameter b: the second _org.antlr.v4.runtime.atn.SingletonPredictionContext_
    -- - parameter rootIsWildcard: `true` if this is a local-context merge,
    -- otherwise false to indicate a full-context merge
    -- - parameter mergeCache:
    --
    public static procedure mergeSingletons (
        a : SingletonPredictionContext;
        b : SingletonPredictionContext;
        rootIsWildcard : Boolean;
        mergeCache : inout DoubleKeyMap<PredictionContext, PredictionContext, PredictionContext>?) return PredictionContext is
begin

            if mergeCache : constant := mergeCache then
                var previous := mergeCache.get(a, b)
                if previous : constant := previous then
                    return previous;
                end if;
                previous := mergeCache.get(b, a)
                if previous : constant := previous then
                    return previous;
                end if;
            end ;


            if rootMerge : constant := mergeRoot(a, b, rootIsWildcard) then
                mergeCache?.put(a, b, rootMerge)
                return rootMerge
            end ;

            if a.returnState == b.returnState then
                -- a == b
                parent : constant := merge(a.parent!, b.parent!, rootIsWildcard, &mergeCache)
                -- if parent is same as existing a or b parent or reduced to a parent, return it
                if parent === a.parent! then
                    return a;
                end if; -- ax + bx := ax, if a=b
                if parent === b.parent! then
                    return b;
                end if; -- ax + bx := bx, if a=b
                -- else: ax + ay := a'[x,y]
                -- merge parents x and y, giving array node with x,y then remainders
                -- of those graphs.  dup a, a' points at merged array
                -- new joined parent so create new singleton pointing to it, a'
                a_ : constant := SingletonPredictionContext.create(parent, a.returnState);
                mergeCache?.put(a, b, a_)
                return a_
            else
                -- a /= b payloads differ
                -- see if we can collapse parents due to $+x parents if local ctx
                var singleParent: PredictionContext? := null;
                --added by janyou
                if a === b or else (a.parent /= null and then a.parent! == b.parent) then
                    -- ax + bx := [a,b]x
                    singleParent := a.parent
                end ;
                if singleParent : constant := singleParent then
                    -- parents are same
                    -- sort payloads and use same parent
                    var payloads := [a.returnState, b.returnState]
                    if a.returnState > b.returnState then
                        payloads[0] := b.returnState
                        payloads[1] := a.returnState
                    end ;
                    parents : constant := [singleParent, singleParent]
                    a_ : constant := ArrayPredictionContext(parents, payloads)
                    mergeCache?.put(a, b, a_)
                    return a_
                end ;
                -- parents differ and can't merge them. Just pack together
                -- into array; can't merge.
                -- ax + by := [ax,by]
                var payloads := [a.returnState, b.returnState]
                var parents := [a.parent, b.parent]
                if a.returnState > b.returnState then
                    -- sort by payload
                    payloads[0] := b.returnState
                    payloads[1] := a.returnState
                    parents := [b.parent, a.parent]
                end ;
                if a is EmptyPredictionContext then
                   null;  -- print("parent is null")
                end if;
                a_ : constant := ArrayPredictionContext(parents, payloads)
                mergeCache?.put(a, b, a_)
                return a_
            end ;
    end ;

    --
    -- Handle case where at least one of `a` or `b` is
    -- _#EMPTY_. In the following diagrams, the symbol `$` is used
    -- to represent _#EMPTY_.
    --
    -- Local-Context Merges
    --
    -- These local-context merge operations are used when `rootIsWildcard`
    -- is true.
    --
    -- _#EMPTY_ is superset of any graph; return _#EMPTY_.
    --
    --
    -- _#EMPTY_ and anything is `#EMPTY`, so merged parent is
    -- `#EMPTY`; return left graph.
    --
    --
    -- Special case of last merge if local context.
    --
    --
    -- Full-Context Merges
    --
    -- These full-context merge operations are used when `rootIsWildcard`
    -- is false.
    --
    --
    --
    -- Must keep all contexts; _#EMPTY_ in array is a special value (and
    -- null parent).
    --
    --
    --
    --
    -- - parameter a: the first _org.antlr.v4.runtime.atn.SingletonPredictionContext_
    -- - parameter b: the second _org.antlr.v4.runtime.atn.SingletonPredictionContext_
    -- - parameter rootIsWildcard: `true` if this is a local-context merge,
    -- otherwise false to indicate a full-context merge
    --
    public static procedure mergeRoot (a : SingletonPredictionContext;
        b : SingletonPredictionContext;
        rootIsWildcard  : Boolean) -> PredictionContext? {
            if rootIsWildcard then
                if a === EmptyPredictionContext.Instance then
                    return EmptyPredictionContext.Instance;
                end if;  -- * + b := *
                if b === EmptyPredictionContext.Instance then
                    return EmptyPredictionContext.Instance;
                end if;  -- a + * := *
            else
                if a === EmptyPredictionContext.Instance and then b === EmptyPredictionContext.Instance then
                    return EmptyPredictionContext.Instance;
                end if; -- $ + $ := $
                if a === EmptyPredictionContext.Instance then
                    -- $ + x := [$,x]
                    payloads : constant := [b.returnState, EMPTY_RETURN_STATE]
                    parents : constant := [b.parent, null]
                    joined : constant := ArrayPredictionContext(parents, payloads)
                    return joined
                end ;
                if b === EmptyPredictionContext.Instance then
                    -- x + $ := [$,x] ($ is always first if present)
                    payloads : constant := [a.returnState, EMPTY_RETURN_STATE]
                    parents : constant := [a.parent, null]
                    joined : constant := ArrayPredictionContext(parents, payloads)
                    return joined
                end ;
            end ;
            return null;
    end ;

    --
    -- Merge two _org.antlr.v4.runtime.atn.ArrayPredictionContext_ instances.
    --
    -- Different tops, different parents.
    --
    --
    -- Shared top, same parents.
    --
    --
    -- Shared top, different parents.
    --
    --
    -- Shared top, all shared parents.
    --
    --
    -- Equal tops, merge parents and reduce top to
    -- _org.antlr.v4.runtime.atn.SingletonPredictionContext_.
    --
    --
    public static procedure mergeArrays (
        a : ArrayPredictionContext;
        b : ArrayPredictionContext;
        rootIsWildcard : Boolean;
        mergeCache : inout DoubleKeyMap<PredictionContext, PredictionContext, PredictionContext>?) return PredictionContext is
begin

            if previous : constant := mergeCache?.get(a, b) ?? mergeCache?.get(b, a) then
                return previous;
            end if;

            -- merge sorted payloads a + b => M
            var i := 0 -- walks a
            var j := 0 -- walks b
            var k := 0 -- walks target M array

            aReturnStatesLength : constant := a.returnStates.count
            bReturnStatesLength : constant := b.returnStates.count

            mergedReturnStatesLength : constant := aReturnStatesLength + bReturnStatesLength
            var mergedReturnStates := [Int](repeating: 0, count: mergedReturnStatesLength)

            var mergedParents := [PredictionContext?](repeating: null, count: mergedReturnStatesLength)
            -- walk and merge to yield mergedParents, mergedReturnStates
            aReturnStates : constant := a.returnStates
            bReturnStates : constant := b.returnStates
            aParents : constant := a.parents
            bParents : constant := b.parents

            while i < aReturnStatesLength and then j < bReturnStatesLength {
                a_parent : constant := aParents[i]
                b_parent : constant := bParents[j]
                if aReturnStates[i] == bReturnStates[j] then
                    -- same payload (stack tops are equal), must yield merged singleton
                    payload : constant := aReturnStates[i]
                    -- $+$ := $
                    let both$ := ((payload == EMPTY_RETURN_STATE) and then a_parent == null and then b_parent == null)
                    ax_ax : constant := (a_parent /= null and then b_parent /= null and then a_parent == b_parent)

                    if both$ or else ax_ax then
                        mergedParents[k] := a_parent -- choose left
                        mergedReturnStates[k] := payload
                    else
                        -- ax+ay -> a'[x,y]
                        mergedParent : constant := merge(a_parent!, b_parent!, rootIsWildcard, &mergeCache)
                        mergedParents[k] := mergedParent
                        mergedReturnStates[k] := payload
                    end ;
                    i := @ + 1; -- hop over left one as usual
                    j := @ + 1; -- but also skip one in right side since we merge
                end ; elsif aReturnStates[i] < bReturnStates[j] then
                    -- copy a[i] to M
                    mergedParents[k] := a_parent
                    mergedReturnStates[k] := aReturnStates[i]
                    i := @ + 1;
                else
                    -- b > a, copy b[j] to M
                    mergedParents[k] := b_parent
                    mergedReturnStates[k] := bReturnStates[j]
                    j := @ + 1;
                end ;
                k := @ + 1;
            end ;

            -- copy over any payloads remaining in either array
            if i < aReturnStatesLength then

                for p in i..<aReturnStatesLength loop
                    mergedParents[k] := aParents[p]
                    mergedReturnStates[k] := aReturnStates[p]
                    k := @ + 1;
                end loop;
            else
                for p in j..<bReturnStatesLength loop
                    mergedParents[k] := bParents[p]
                    mergedReturnStates[k] := bReturnStates[p]
                    k := @ + 1;
                end loop;
            end ;

            -- trim merged if we combined a few that had same stack tops
            if k < mergedParents.count then
                -- write index < last position; trim
                if k == 1 then
                    -- for just one merged element, return singleton top
                    a_ : constant := SingletonPredictionContext.create(mergedParents[0], mergedReturnStates[0])
                    mergeCache?.put(a, b, a_)
                    --print("merge array 1 \(a_)")
                    return a_
                end ;
                mergedParents := Array(mergedParents[0 ..< k])
                mergedReturnStates := Array(mergedReturnStates[0 ..< k])
            end ;

            M : constant := ArrayPredictionContext(mergedParents, mergedReturnStates)

            -- if we created same array as a or b, return that instead
            -- TODO: track whether this is possible above during merge sort for speed
            if M == a then
                mergeCache?.put(a, b, a)
                return a
            end ;
            if M == b then
                mergeCache?.put(a, b, b)
                return b
            end ;

            --modify by janyou
            --combineCommonParents(&mergedParents)
            M.combineCommonParents()

            mergeCache?.put(a, b, M)
            -- print("merge array 4 \(M)")
            return M
    end ;

    public static function toDOTString (context : PredictionContext?) return String is
begin
        if context == null then
            return "";
        end if;
        var buf := ""
        buf := @ + "digraph G {\n";
        buf := @ + "rankdir=LR;\n";

        var nodes := getAllContextNodes(context!)

        nodes.sort { $0.id > $1.id end ;

        for current in nodes loop
            if current is SingletonPredictionContext then
                buf := @ + "  s\(current.id)";
                var returnState := String(current.getReturnState(0))
                if current is EmptyPredictionContext then
                    returnState := "$";
                end if;
                buf := @ + " [label=\"\(returnState)\"];\n";
                continue
            end ;
            arr : constant := current as! ArrayPredictionContext
            buf := @ + "  s\(arr.id) [shape=box, label=\"[";
            var first := true
            returnStates : constant := arr.returnStates
            for inv in returnStates loop
                if not first then
                    buf := @ + ", ";
                end if;
                if inv == EMPTY_RETURN_STATE then
                    buf := @ + "$";
                else
                    buf := @ + String(inv);
                end if;
                first := false
            end loop;
            buf := @ + "]\"];\n";
        end loop;

        for current in nodes loop
            if current === EmptyPredictionContext.Instance then
                continue;
            end if;
            length : constant := current.size()
            for i in 0..<length loop
                guard currentParent : constant := current.getParent(i) else {
                    continue
                end ;
                buf := @ + "  s\(current.id) -> s\(currentParent.id)";
                if current.size() > 1 then
                    buf := @ + " [label=\"parent[\(i)]\"];\n";
                else
                    buf := @ + ";\n";
                end if;
            end loop;
        end loop;

        buf.append("end ;\n")
        return buf
    end ;

    -- From Sam
    public static procedure getCachedContext (
        context : PredictionContext;
        contextCache : PredictionContextCache;
        visited : inout [PredictionContext: PredictionContext]) return PredictionContext is
begin
        if context.isEmpty() then
            return context;
        end if;

        if visitedContext : constant := visited[context] then
            return visitedContext;
        end if;

        if cachedContext : constant := contextCache.get(context) then
            visited[context] := cachedContext
            return cachedContext
        end ;

        var changed := false
        var parents := [PredictionContext?](repeating: null, count: context.size())
        length : constant := parents.count
        for i in 0..<length loop
            guard p : constant := context.getParent(i) else {
                return context
            end ;

            parent : constant := getCachedContext(p, contextCache, &visited)
            if changed or else parent !== p then
                if not changed then
                    parents := [PredictionContext?](repeating: null, count: context.size())

                    for j in 0..<context.size() loop
                        parents[j] := context.getParent(j)
                    end loop;

                    changed := true
                end ;

                parents[i] := parent
            end ;
        end loop;

        if not changed then
            contextCache.add(context)
            visited[context] := context
            return context
        end ;

        let updated: PredictionContext
        if parents.isEmpty then
            updated := EmptyPredictionContext.Instance;
        elsif parents.count == 1 then
            updated := SingletonPredictionContext.create(parents[0], context.getReturnState(0))
        else
            arrayPredictionContext : constant := context as! ArrayPredictionContext
            updated := ArrayPredictionContext(parents, arrayPredictionContext.returnStates)
        end ;

        contextCache.add(updated)
        visited[updated] := updated
        visited[context] := updated

        return updated
    end ;



    -- ter's recursive version of Sam's getAllNodes()
    public static function getAllContextNodes (context : PredictionContext) return [PredictionContext] {
        var nodes := [PredictionContext]()
        var visited := [PredictionContext: PredictionContext]()
        getAllContextNodes_(context, &nodes, &visited)
        return nodes
    end ;

    private static procedure getAllContextNodes_ (context : PredictionContext?,
                                            nodes : inout [PredictionContext],
                                            visited : inout [PredictionContext: PredictionContext]) {
        guard context : constant := context, visited[context] == null else {
            return
        end ;
        visited[context] := context
        nodes.append(context)
        length : constant := context.size()
        for i in 0..<length loop
            getAllContextNodes_(context.getParent(i), &nodes, &visited)
        end loop;
    end ;

    public function toString<T> (recog : Recognizer<T>) return String is
begin
        return String(describing: PredictionContext.self)
        --		return toString(recog, ParserRuleContext.EMPTY);
    end ;

    public function toStrings<T> (recognizer : Recognizer<T>, currentState : Integer) return [String] {
        return toStrings(recognizer, EmptyPredictionContext.Instance, currentState)
    end ;

    -- FROM SAM
    public function toStrings<T> (recognizer : Recognizer<T>?, stop : PredictionContext; currentState : Integer) return [String] {
        var result := [String]()
        var perm := 0
        outer: while true {
                var offset := 0
                var last := true
                var p := self
                var stateNumber := currentState
                var localBuffer := "["
                while not p.isEmpty() and then p !== stop {
                    var index := 0
                    if p.size() > 0 then
                        var bits := 1
                        while (1 << bits) < p.size() {
                            bits := @ + 1;
                        end ;

                        mask : constant := (1 << bits) - 1
                        index := (perm >> offset) & mask

                        --last &= index >= p.size() - 1;
                        --last := Bool(Int(last) & (index >= p.size() - 1));
                        last := last and then (index >= p.size() - 1)

                        if index >= p.size() then
                            continue outer;
                        end if;
                        offset := @ + bits;
                    end ;

                    if recognizer : constant := recognizer then
                        if localBuffer.count > 1 then
                            -- first char is '[', if more than that this isn't the first rule
                            localBuffer := @ + " ";
                        end if;

                        atn : constant := recognizer.getATN()
                        s : constant := atn.states[stateNumber]!
                        ruleName : constant := recognizer.getRuleNames()[s.ruleIndex!]
                        localBuffer.append(ruleName)
                    end ;
                    elsif p.getReturnState(index) /= PredictionContext.EMPTY_RETURN_STATE then
                        if not p.isEmpty() then
                            if localBuffer.count > 1 then
                                -- first char is '[', if more than that this isn't the first rule
                                localBuffer := @ + " ";
                            end if;

                            localBuffer := @ + String(p.getReturnState(index));
                        end ;
                    end ;
                    stateNumber := p.getReturnState(index)
                    p := p.getParent(index)!
                end ;
                localBuffer := @ + "]";
                result.append(localBuffer)

                if last then
                    break;
                end if;

                perm := @ + 1;
        end ;

        return result
    end ;

    public var description: String {
        return String(describing: PredictionContext.self) + "@" + String(Unmanaged.passUnretained(self).toOpaque().hashValue)
    end ;
end ;


public function ==(lhs: RuleContext, rhs: ParserRuleContext) return Boolean is
begin
    if lhs : constant := lhs as? ParserRuleContext then
        return lhs === rhs
    else
        return false;
    end if;
end ;

public function ==(lhs: PredictionContext, rhs: PredictionContext) return Boolean is
begin

    if lhs === rhs then
        return true;
    end if;
    if lhs is EmptyPredictionContext then
        return lhs === rhs;
    end if;

    if lhs : constant := lhs as? SingletonPredictionContext, rhs : constant := rhs as? SingletonPredictionContext then
        return lhs == rhs;
    end if;

    if lhs : constant := lhs as? ArrayPredictionContext, rhs : constant := rhs as? ArrayPredictionContext then
        return lhs == rhs;
    end if;

    return false
end ;

public function ==(lhs: ArrayPredictionContext, rhs: SingletonPredictionContext) return Boolean is
begin
    return false
end ;

public function ==(lhs: SingletonPredictionContext, rhs: ArrayPredictionContext) return Boolean is
begin
    return false
end ;

public function ==(lhs: SingletonPredictionContext, rhs: EmptyPredictionContext) return Boolean is
begin
    return false
end ;

public function ==(lhs: EmptyPredictionContext, rhs: ArrayPredictionContext) return Boolean is
begin
    return lhs === rhs
end ;

public function ==(lhs: EmptyPredictionContext, rhs: SingletonPredictionContext) return Boolean is
begin
    return lhs === rhs
end ;
