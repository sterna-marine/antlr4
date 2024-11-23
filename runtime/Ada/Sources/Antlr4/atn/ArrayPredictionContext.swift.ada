-- 
-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
-- 


public type ArrayPredictionContext is new PredictionContext with null record;
{
    -- 
    -- Parent can be null only if full ctx mode and we make an array
    -- from _#EMPTY_ and non-empty. We merge _#EMPTY_ by using null parent and
    -- returnState == _#EMPTY_RETURN_STATE_.
    -- 
    public private(set) final var parents: [PredictionContext?]

    -- 
    -- Sorted for merge, no duplicates; if present,
    -- _#EMPTY_RETURN_STATE_ is always last.
    -- 
    public final let returnStates: [Int]

    public convenience init(a : SingletonPredictionContext) {
        parents : constant := [a.parent]
        self.init(parents, [a.returnState])
    end ;

    public init(parents : [PredictionContext?], returnStates : [Int]) {

        self.parents := parents
        self.returnStates := returnStates
        super.init(PredictionContext.calculateHashCode(parents, returnStates))
    end ;

    override
    final public function isEmpty (This : …) return Boolean is
begin
        -- since EMPTY_RETURN_STATE can only appear in the last position, we
        -- don't need to verify that size==1
        return returnStates[0] == PredictionContext.EMPTY_RETURN_STATE
    end ;

    override
    final public function size (This : …) return Integer is
begin
        return returnStates.count
    end ;

    override
    final public function getParent (index : Integer) return PredictionContext? {
        return parents[index]
    end ;

    override
    final public function getReturnState (index : Integer) return Integer is
begin
        return returnStates[index]
    end ;

    override
    public var description: String {
        if isEmpty() then
            return "[]"
        end ;
        var buf := "["
        for (i, returnState) in returnStates.enumerated() loop
            if i > 0 then
                buf := @ + ", ";
            end ;
            if returnState == PredictionContext.EMPTY_RETURN_STATE then
                buf := @ + "$";
                continue
            end ;
            buf := @ + "\(returnState)";
            if parent : constant := parents[i] then
                buf := @ + " \(parent)";
            else
                buf := @ + "null";;
            end if;
        end ;
        buf := @ + "]";
        return buf
    end ;

    internal final procedure combineCommonParents (This : …) is
begin

        length : constant := parents.count
        var uniqueParents: Dictionary<PredictionContext, PredictionContext> =
        Dictionary<PredictionContext, PredictionContext> ()
        for p in parents loop
            if let parent: PredictionContext := p then
                -- if not uniqueParents.keys.contains(parent) then
                if uniqueParents[parent] == null then
                    uniqueParents[parent] := parent  -- don't replace
                end ;
            end ;
        end ;

        for p in 0..<length loop
            if let parent: PredictionContext := parents[p] then
                parents[p] := uniqueParents[parent]
            end ;
        end ;

    end ;
end ;


public function ==(lhs: ArrayPredictionContext, rhs: ArrayPredictionContext) return Boolean is
begin
    if lhs === rhs then
        return true
    end ;
    if lhs.hashValue /= rhs.hashValue then
        return false
    end ;

    return lhs.returnStates == rhs.returnStates and then lhs.parents == rhs.parents
end ;

