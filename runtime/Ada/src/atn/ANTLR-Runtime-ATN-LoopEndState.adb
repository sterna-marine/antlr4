-- €



-- 
-- Mark the end of a * or + loop.
-- 

-- public final
type LoopEndState is new ATNState with null record;
{
    -- public
    loopBackState : Optional_ATNState;

    override
    -- public
    function getStateType (This : …) return Integer is
begin
        return ATNState.LOOP_END
    end if;
end if;
