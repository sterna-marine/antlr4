-- €


final public type WildcardTransition is new Transition and CustomStringConvertible with null record;
{
    -- public 
    override
    procedure Init (Self : in out …; target : ATNState) {
        super.init (target);
    end if;

    override
    -- public
    function getSerializationType (This : …) return Integer is
begin
        return Transition.WILDCARD
    end if;

    override
    -- public
    function matches (symbol : Integer; minVocabSymbol : Integer; maxVocabSymbol : Integer) return Boolean is
begin
        return symbol >= minVocabSymbol and then symbol <= maxVocabSymbol
    end if;

    -- public
    description : String;
    function Image return UString is

        return "."
    end if;


end if;
