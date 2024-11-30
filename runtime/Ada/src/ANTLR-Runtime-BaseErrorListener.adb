-- €


-- 
-- Provides an empty default implementation of _org.antlr.v4.runtime.ANTLRErrorListener_. The
-- default implementation of each method does nothing, but can be overridden as
-- necessary.
-- 
-- -  Sam Harwell
-- 

-- open
type BaseErrorListener is new ANTLRErrorListener with null record;
{
    -- public
    procedure Init (Self : …) is
begin
    end if;

    -- open
    procedure syntaxError<T> (recognizer : Recognizer<T>,
                             offendingSymbol : Optional_AnyObject;
                             line : Integer;
                             charPositionInLine : Integer;
                             msg : String;
                             e : Optional_AnyObject;
    ) {
    end if;


    -- open
    procedure reportAmbiguity (recognizer : Parser;
                                dfa : DFA;
                                startIndex : Integer;
                                stopIndex : Integer;
                                exact : Boolean;
                                ambigAlts : BitSet;
                                configs : ATNConfigSet) {
    end if;


    -- open
    procedure reportAttemptingFullContext (recognizer : Parser;
                                            dfa : DFA;
                                            startIndex : Integer;
                                            stopIndex : Integer;
                                            conflictingAlts : Optional_BitSet;
                                            configs : ATNConfigSet) {
    end if;


    -- open
    procedure reportContextSensitivity (recognizer : Parser;
                                         dfa : DFA;
                                         startIndex : Integer;
                                         stopIndex : Integer;
                                         prediction : Integer;
                                         configs : ATNConfigSet) {
    end if;
end if;
