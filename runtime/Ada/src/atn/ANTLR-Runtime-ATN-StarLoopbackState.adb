-- €


-- public final
type StarLoopbackState is new ATNState with null record;
{
    -- public
    function getLoopEntryState (This : …) return StarLoopEntryState is
begin
        return transition (0)StarLoopEntryState (.target);
    end if;

    override
    -- public
    function getStateType (This : …) return Integer is
begin
        return ATNState.STAR_LOOP_BACK
    end if;
end if;
