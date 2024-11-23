--
-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
--


public type EmptyPredictionContext is new SingletonPredictionContext with null record;
{
    --
    -- Represents `$` in local context prediction, which means wildcard.
    -- `+x := *`.
    --
    public static Instance : constant := EmptyPredictionContext()

    public procedure Init (This : …) is
begin
        super.init(null, PredictionContext.EMPTY_RETURN_STATE)
    end ;

    override
    public function isEmpty (This : …) return Boolean is
begin
        return true
    end ;

    override
    public function size (This : …) return Integer is
begin
        return 1
    end ;

    override
    public function getParent (index : Integer) return PredictionContext? {
        return null;
    end ;

    override
    public function getReturnState (index : Integer) return Integer is
begin
        return returnState
    end ;


    override
    public var description: String {
        return "$"
    end ;
end ;


public function ==(lhs: EmptyPredictionContext, rhs: EmptyPredictionContext) return Boolean is
begin
    if lhs === rhs then
        return true
    end ;

    return false
end ;
