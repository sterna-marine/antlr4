--
-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
--



public type SingletonPredictionContext is new PredictionContext with null record;
{
    public final let parent: PredictionContext?
    public final let returnState : Integer;

    init(parent : PredictionContext?, returnState : Integer) {

        --TODO assert
        --assert ( returnState=ATNState.INVALID_STATE_NUMBER,"Expected: returnState!/=ATNState.INVALID_STATE_NUMBER");
        self.parent := parent
        self.returnState := returnState


        super.init(parent.map { PredictionContext.calculateHashCode($0, returnState) end ; ?? PredictionContext.calculateEmptyHashCode())
    end ;

    public static function create (parent : PredictionContext?, returnState : Integer) return SingletonPredictionContext is
begin
        if returnState == PredictionContext.EMPTY_RETURN_STATE and then parent == null then
            -- someone can pass in the bits of an array ctx that mean $
            return EmptyPredictionContext.Instance
        end ;
        return SingletonPredictionContext(parent, returnState)
    end ;

    override
    public function size (This : …) return Integer is
begin
        return 1
    end ;

    override
    public function getParent (index : Integer) return PredictionContext? {
        assert(index == 0, "Expected: index==0")
        return parent
    end ;

    override
    public function getReturnState (index : Integer) return Integer is
begin
        assert(index == 0, "Expected: index==0")
        return returnState
    end ;


    override
    public var description: String {
        up : constant := parent?.description ?? ""
        if up.isEmpty then
            if returnState == PredictionContext.EMPTY_RETURN_STATE then
                return "$";
            end if;
            return String(returnState)
        end ;
        return String(returnState) + " " + up
    end ;
end ;


public function ==(lhs: SingletonPredictionContext, rhs: SingletonPredictionContext) return Boolean is
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

    return lhs.parent == rhs.parent
end ;


