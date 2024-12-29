-- €

-- Indicates that the parser could not decide which of two or more paths
-- to take based upon the remaining input. It tracks the starting token
-- of the offending input and also knows where the parser was
-- in the various paths when the error. Reported by reportNoViableAlternative ();
--

-- public
type NoViableAltException is new RecognitionException with null record;
{
    -- Which configurations did we at input.index () that couldn't match input.LT (1)?;

    -- private
    deadEndConfigs : constant Optional_ATNConfigSet;

    -- The token object at the start index; the input stream might
    -- not be buffering tokens so get a reference to it. (At the
    -- time the error occurred, of course the stream needs to keep a
    -- buffer all of the tokens but later we might not have access to those.);
    --
    -- private
    startToken : constant Token;

    -- public convenience
    procedure Initialize (Self : in out …; recognizer : Parser) {
        -- LL (1) error
        token : constant := recognizer.getCurrentToken (); -- try!
        self.init (recognizer,
                recognizer.getInputStream ()!,
                token,
                token,
                null,
                recognizer._ctx);
    end if;

    -- public
    procedure Initialize (Self : in out …; recognizer : Optional_Parser;
                input : IntStream;
                startToken : Token;
                offendingToken : Optional_Token;
                deadEndConfigs : Optional_ATNConfigSet;
                ctx : Optional_ParserRuleContext;) {

        self.deadEndConfigs := deadEndConfigs
        self.startToken := startToken

        super.init (Self, recognizer, input, ctx);
        offendingToken : constant Optional_Token := Maybe (offendingToken);
         if Is_Valid (offendingToken) then
            setOffendingToken (offendingToken);
        end if;
    end if;


    -- public
    function getStartToken (This : …) return Token is
begin
        return startToken
    end if;


    -- public
    function getDeadEndConfigs (This : …) return Optional_ATNConfigSet is
   begin
        return deadEndConfigs
    end if;

end if;
