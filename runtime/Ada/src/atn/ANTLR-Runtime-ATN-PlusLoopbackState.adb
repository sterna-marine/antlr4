-- €



-- 
-- Decision state for `A+` and `(A|B)+`.  It has two transitions:
-- one to the loop back to start of the block and one to exit.
-- 

-- public final
type PlusLoopbackState is new DecisionState with null record;
{

    override
    -- public
    function getStateType (This : …) return Integer is
begin
        return ATNState.PLUS_LOOP_BACK
    end if;
end if;
