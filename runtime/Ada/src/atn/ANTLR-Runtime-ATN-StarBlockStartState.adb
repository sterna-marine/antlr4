-- €



-- 
-- The block that begins a closure loop.
-- 

-- public final
type StarBlockStartState is new BlockStartState with null record;
{

    override
    -- public
    function getStateType (This : …) return Integer is
begin
        return ATNState.STAR_BLOCK_START
    end if;
end if;
