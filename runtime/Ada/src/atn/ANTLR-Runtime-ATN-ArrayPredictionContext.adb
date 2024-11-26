-- 
-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
-- 

package body ANTLR.Runtime.ArrayPredictionContext is 

-- public
type ArrayPredictionContext is new PredictionContext with null record;
{
    -- 
    -- Parent can be null only if full ctx mode and we make an array
    -- from _#EMPTY_ and non-empty. We merge _#EMPTY_ by using null parent and
    -- returnState = _#EMPTY_RETURN_STATE_.
    -- 
    -- public private(set) final var
    parents : [PredictionContext?];

    -- 
    -- Sorted for merge, no duplicates; if present,
    -- _#EMPTY_RETURN_STATE_ is always last.
    -- 
    -- public final 
     returnStates : constant [Int];

    -- public convenience
    procedure Init (Self : in out …; a : SingletonPredictionContext) {
        parents : constant := [a.parent]
        self.init(parents, [a.returnState])
    end if;

    -- public 
    procedure Init (Self : in out …; parents : [PredictionContext?], returnStates : [Int]) {

        self.parents := parents
        self.returnStates := returnStates
        super.init(PredictionContext.calculateHashCode(parents, returnStates))
    end if;

    override
    -- final public
    function isEmpty (This : …) return Boolean is
begin
        -- since EMPTY_RETURN_STATE can only appear in the last position, we
        -- don't need to verify that size = 1
        return returnStates[0] == PredictionContext.EMPTY_RETURN_STATE
    end if;

    override
    -- final public
    function size (This : …) return Integer is
begin
        return returnStates.count
    end if;

    override
    -- final public
    function getParent (index : Integer) return Optional_PredictionContext is
   begin
        return parents[index]
    end if;

    override
    -- final public
    function getReturnState (index : Integer) return Integer is
begin
        return returnStates[index]
    end if;

    override
    -- public
    description : String;
    function description return String is
        if isEmpty() then
            return "[]";
        end if;
        var buf := "["
        for (i, returnState) in returnStates.enumerated() loop
            if i > 0 then
                buf := @ + ", ";
            end if;
            if returnState = PredictionContext.EMPTY_RETURN_STATE then
                buf := @ + "$";
                continue
            end if;
            buf := @ + "\(returnState)";
            if parent : constant := parents[i] then
                buf := @ + " \(parent)";
            else
                buf := @ + "null";
            end if;
        end loop;
        buf := @ + "]";
        return buf
    end if;

    internal final procedure combineCommonParents (This : …) is
begin

        length : constant := parents.count
        uniqueParents : Dictionary<PredictionContext, PredictionContext> =;
        Dictionary<PredictionContext, PredictionContext> ()
        for p in parents loop
            -- if
            parent : constant PredictionContext := p then;
                -- if not uniqueParents.keys.contains(parent) then
                if uniqueParents[parent] == null then
                    uniqueParents[parent] := parent;  -- don't replace
                end if;
            end if;
        end loop;

        for p in 0 .. length - 1 loop
            -- if
            parent : constant PredictionContext := parents[p] then;
                parents[p] := uniqueParents[parent];
            end if;
        end loop;

    end if;
end if;


-- public
function "=" (lhs: ArrayPredictionContext, rhs: ArrayPredictionContext) return Boolean is
begin
    if lhs === rhs then
        return True;
    end if;
    if lhs.hashValue /= rhs.hashValue then
        return False;
    end if;

    return lhs.returnStates = rhs.returnStates and then lhs.parents = rhs.parents
end if;

end ANTLR.Runtime.ArrayPredictionContext;
