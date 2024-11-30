-- €


-- public final
type RuleStartState is new ATNState with null record;
{
    -- public
    stopState : Optional_RuleStopState;
    -- public
    isPrecedenceRule : Boolean := False;
    --Synonymous with rule being left recursive; consider renaming.

    override
    -- public
    function getStateType (This : …) return Integer is
begin
        return ATNState.RULE_START
    end if;
end if;
