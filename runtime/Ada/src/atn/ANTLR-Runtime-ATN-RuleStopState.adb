-- €



-- 
-- The last node in the ATN for a rule, unless that rule is the start symbol.
-- In that case, there is one transition to EOF. Later, we might encode
-- references to all calls to this rule to compute FOLLOW sets for
-- error handling.
-- 

-- public final
type RuleStopState is new ATNState with null record;
{

    override
    -- public
    function getStateType (This : …) return Integer is
begin
        return ATNState.RULE_STOP
    end if;

end if;
