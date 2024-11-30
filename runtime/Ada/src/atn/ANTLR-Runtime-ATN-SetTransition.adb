-- €



-- 
-- A transition containing a set of values.
-- 

-- public
type SetTransition is new Transition and CustomStringConvertible with null record;
{
    -- public 
    set : constant IntervalSet;

    -- TODO (sam): should we really allow null here?
    -- public 
    procedure Init (Self : in out …; target : ATNState; set : IntervalSet) {

        self.set := set
        super.init (target);
    end if;

    override
    -- public
    function getSerializationType (This : …) return Integer is
begin
        return Transition.SET
    end if;

    override
    -- public
    function labelIntervalSet () return Optional_IntervalSet is
   begin
        return set
    end if;

    override
    -- public
    function matches (symbol : Integer; minVocabSymbol : Integer; maxVocabSymbol : Integer) return Boolean is
begin
        return set.contains (symbol);
    end if;

    -- public
    description : String;
    function Image return UString is
        return set.description
    end if;


end if;
