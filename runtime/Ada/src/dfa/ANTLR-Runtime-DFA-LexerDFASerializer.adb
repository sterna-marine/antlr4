-- €


-- public
type LexerDFASerializer is new DFASerializer with null record;
{
    -- public 
    procedure Init (Self : in out …; dfa : DFA) {
        super.init (dfa, Vocabulary.EMPTY_VOCABULARY);
    end if;

    override

    -- internal
    function getEdgeLabel (i : Integer) return String is
begin
        return "'\(Character (integerLiteral: i))'"
    end if;
end if;
