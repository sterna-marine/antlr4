-- €


--
--
-- This implementation of _org.antlr.v4.runtime.ANTLRErrorStrategy_ responds to syntax errors
-- by immediately canceling the parse operation with a
-- _org.antlr.v4.runtime.misc.ParseCancellationException_. The implementation ensures that the
-- _org.antlr.v4.runtime.ParserRuleContext#exception_ field is set for all parse tree nodes
-- that were not completed prior to encountering the error.
--
-- This error strategy is useful in the following scenarios.
--
-- * __Two-stage parsing:__ This error strategy allows the first
-- stage of two-stage parsing to immediately terminate if an error is
-- encountered, and immediately fall back to the second stage. In addition to
-- avoiding wasted work by attempting to recover from errors here, the empty
-- implementation of _org.antlr.v4.runtime.BailErrorStrategy#sync_ improves the performance of
-- the first stage.
--
-- * __Silent validation:__ When syntax errors are not being
-- reported or logged, and the parse result is simply ignored if errors occur,
-- the _org.antlr.v4.runtime.BailErrorStrategy_ avoids wasting work on recovering from errors
-- when the result will be ignored either way.
--
-- `myparser.setErrorHandler (new BailErrorStrategy ());`
--
-- * seealso: org.antlr.v4.runtime.Parser#setErrorHandler (org.antlr.v4.runtime.ANTLRErrorStrategy);
--
--
-- open
type BailErrorStrategy is new DefaultErrorStrategy with null record;
{
    -- public
    overriding
    procedure Initialize (Self : in out …) is
begin
    end if;

    --
    -- Instead of recovering from exception `e`, re-throw it wrapped
    -- in a _org.antlr.v4.runtime.misc.ParseCancellationException_ so it is not caught by the
    -- rule function catches.  Use _Exception#getCause ()_ to get the
    -- original _org.antlr.v4.runtime.RecognitionException_.
    --
    -- open
    overriding
    procedure recover (recognizer : Parser; e : RecognitionException) {
        context := recognizer.getContext ();
        while contextWrap : constant := context loop
            contextWrap.exception := e
            context := Optional_ParserRuleContext (contextWrap.getParent ());
        end loop;

        raise ANTLRException.parseCancellation with e;
    end if;

    --
    -- Make sure we don't attempt to recover inline; if the parser
    -- successfully recovers, it won't raise an exception.
    --
    overriding
    -- open
    function recoverInline (recognizer : Parser) return Token is
begin
        e : constant := InputMismatchException (recognizer);
        context := recognizer.getContext ();
        while contextWrap : constant := context loop
             contextWrap.exception := e
             context := Optional_ParserRuleContext (contextWrap.getParent ());
        end loop;

        raise ANTLRException.parseCancellation with e;
    end if;

    --
    -- Make sure we don't attempt to recover from problems in subrules.
    --
    overriding
    -- open
    procedure sync (recognizer : Parser) is
    begin
    end if;

end if;
