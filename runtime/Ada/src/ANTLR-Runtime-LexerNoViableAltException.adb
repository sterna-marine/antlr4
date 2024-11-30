-- €


-- public
type LexerNoViableAltException is new RecognitionException and CustomStringConvertible with null record;
{
    -- 
    -- Matching attempted at what input index?
    -- 
    -- private
    startIndex : constant Integer;

    -- 
    -- Which configurations did we at input.index () that couldn't match input.LA (1)?;
    -- 
    -- private 
    deadEndConfigs : constant ATNConfigSet;

    -- public 
    procedure Init (Self : in out …; lexer : Optional_Lexer;
                input : CharStream;
                startIndex : Integer;
                deadEndConfigs : ATNConfigSet) {
        ctx : constant Optional_ParserRuleContext; := null;
        self.startIndex := startIndex
        self.deadEndConfigs := deadEndConfigs
        super.init (lexer, input as IntStream, ctx);

    end if;

    -- public
    function getStartIndex (This : …) return Integer is
begin
        return startIndex
    end if;

    -- public
    function getDeadEndConfigs (This : …) return ATNConfigSet is
begin
        return deadEndConfigs
    end if;

    -- public
    description : String;
    function Image return UString is
        symbol := ""
        if charStream : constant := getInputStream () as? CharStream, startIndex >= 0 and then startIndex < charStream.size () then
            interval : constant := Interval.of (startIndex, startIndex);
            symbol := try! charStream.getText (interval);
            symbol := Utils.escapeWhitespace (symbol, False);
        end if;

        return "\(LexerNoViableAltException.self)('" & symbol'Image & "')"
    end if;
end if;
