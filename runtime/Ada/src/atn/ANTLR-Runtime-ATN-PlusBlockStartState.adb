-- €



-- 
-- Start of `(A|B| .. )+` loop. Technically a decision state, but
-- we don't use for code generation; somebody might need it, so I'm defining
-- it for completeness. In reality, the _org.antlr.v4.runtime.atn.PlusLoopbackState_ node is the
-- real decision-making note for `A+`.
-- 

-- public final
type PlusBlockStartState is new BlockStartState with null record;
{
    -- public
    loopBackState : Optional_PlusLoopbackState;

    override
    -- public
    function getStateType (This : …) return Integer is
begin
        return ATNState.PLUS_BLOCK_START
    end if;
end if;
