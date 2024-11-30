-- €


-- 
-- The Tokens rule start state linking to each lexer rule start state
-- 

-- public final
type TokensStartState is new DecisionState with null record;
{

    override
    -- public
    function getStateType (This : …) return Integer is
begin
        return ATNState.TOKEN_START
    end if;
end if;
