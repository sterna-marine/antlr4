--
-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
--


-- public
type EmptyPredictionContext is new SingletonPredictionContext with null record;
{
    --
    -- Represents `$` in local context prediction, which means wildcard.
    -- `+x := *`.
    --
    -- public static 
    Instance : constant := EmptyPredictionContext()

    -- public
    procedure Init (Self : …) is
begin
        super.init(null, PredictionContext.EMPTY_RETURN_STATE)
    end if;

    override
    -- public
    function isEmpty (This : …) return Boolean is
begin
        return True;
    end if;

    override
    -- public
    function size (This : …) return Integer is
begin
        return 1
    end if;

    override
    -- public
    function getParent (index : Integer) return Optional_PredictionContext is
   begin
        return null;
    end if;

    override
    -- public
    function getReturnState (index : Integer) return Integer is
begin
        return returnState
    end if;


    override
    -- public
    description : String;
    function description return String is
        return "$"
    end if;
end if;


-- public
function "=" (lhs: EmptyPredictionContext, rhs: EmptyPredictionContext) return Boolean is
begin
    if lhs === rhs then
        return True;
    end if;

    return False;
end if;
