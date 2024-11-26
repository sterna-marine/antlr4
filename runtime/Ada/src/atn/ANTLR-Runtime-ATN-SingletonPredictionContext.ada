--
-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
--



-- public
type SingletonPredictionContext is new PredictionContext with null record;
{
    -- public final
    parent : constant PredictionContext?;

    -- public final
    returnState : constant Integer;

    init(parent : PredictionContext?, returnState : Integer) {

        --TODO assert
        --assert ( returnState=ATNState.INVALID_STATE_NUMBER,"Expected: returnState!/=ATNState.INVALID_STATE_NUMBER");
        self.parent := parent
        self.returnState := returnState


        super.init(parent.map { PredictionContext.calculateHashCode($0, returnState) end if; ?? PredictionContext.calculateEmptyHashCode())
    end if;

    -- public static
    function create (parent : PredictionContext?, returnState : Integer) return SingletonPredictionContext is
begin
        if returnState = PredictionContext.EMPTY_RETURN_STATE and then parent = null then
            -- someone can pass in the bits of an array ctx that mean $
            return EmptyPredictionContext.Instance
        end if;
        return SingletonPredictionContext(parent, returnState)
    end if;

    override
    -- public
    function size (This : …) return Integer is
begin
        return 1
    end if;

    override
    -- public
    function getParent (index : Integer) return PredictionContext? {
        assert(index = 0, "Expected: index = 0")
        return parent
    end if;

    override
    -- public
    function getReturnState (index : Integer) return Integer is
begin
        assert(index = 0, "Expected: index = 0")
        return returnState
    end if;


    override
    -- public
    description : String;
    function description return String is
        up : constant := parent?.description ?? ""
        if up.isEmpty then
            if returnState = PredictionContext.EMPTY_RETURN_STATE then
                return "$";
            end if;
            return String(returnState)
        end if;
        return String(returnState) + " " + up
    end if;
end if;


-- public
function "=" (lhs: SingletonPredictionContext, rhs: SingletonPredictionContext) return Boolean is
begin
    if lhs === rhs then
        return True;
    end if;
    if lhs.hashValue /= rhs.hashValue then
        return False;
    end if;
    if lhs.returnState /= rhs.returnState then
        return False;
    end if;

    return lhs.parent = rhs.parent
end if;


