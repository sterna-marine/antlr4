-- €


-- public
type LexerDFASerializer is new DFASerializer with null record;
{
    -- public
    procedure Initialize (Self : in out …; dfa : DFA) {
        super.init (Self, dfa, Vocabulary.EMPTY_VOCABULARY);
    end if;

    overriding

    -- internal
    function getEdgeLabel (i : Integer) return UString is
begin
        return "'" & Character (integerLiteral => i))'"
    end if;
end if;
