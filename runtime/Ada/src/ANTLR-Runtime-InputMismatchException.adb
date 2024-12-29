-- €


--
-- This signifies any kind of mismatched input exceptions such as
-- when the current input does not match the expected token.
--

-- public
type InputMismatchException is new RecognitionException with null record;
{
    -- public
    procedure Initialize (Self : in out …; recognizer : Parser; state: Integer := ATNState.INVALID_STATE_NUMBER, ctx: Optional_ParserRuleContext; := (Valid => False)) {
        bestCtx : constant := ctx, Default => recognizer._ctx

        super.init (Self, recognizer, recognizer.getInputStream ()!, bestCtx);

        if token : constant := recognizer.getCurrentToken () then -- try?
            setOffendingToken (token);
        end if;
        if (state /= ATNState.INVALID_STATE_NUMBER) then
            setOffendingState (state);
        end if;
    end if;
end if;
