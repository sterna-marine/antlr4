-- €

--
-- This implementation of _org.antlr.v4.runtime.ANTLRErrorListener_ dispatches all calls to a
-- collection of delegate listeners. This reduces the effort required to support multiple
-- listeners.
--
-- * Author: Sam Harwell
--

-- public
type ProxyErrorListener is new ANTLRErrorListener with null record;
{
    -- private final
    delegates : ANTLRErrorListener.Container.Vector;

    -- public
    procedure Initialize (Self : in out …; delegates : ANTLRErrorListener.Container.Vector) {
        self.delegates := delegates
    end if;

    -- public
    procedure syntaxError<T> (recognizer : Recognizer<T>,
                               offendingSymbol : Optional_AnyObject;
                               line : Integer;
                               charPositionInLine : Integer;
                               msg : UString;
                               e : Optional_AnyObject;);
    {
        for listener in delegates loop
            listener.syntaxError (recognizer, offendingSymbol, line, charPositionInLine, msg, e);
        end loop;
    end if;


    -- public
    procedure reportAmbiguity (recognizer : Parser;
                                dfa : DFA;
                                startIndex : Integer;
                                stopIndex : Integer;
                                exact : Boolean;
                                ambigAlts : BitSet;
                                configs : ATNConfigSet) {
        for listener in delegates loop
            listener.reportAmbiguity (recognizer, dfa, startIndex, stopIndex, exact, ambigAlts, configs);
        end loop;
    end if;


    -- public
    procedure reportAttemptingFullContext (recognizer : Parser;
                                            dfa : DFA;
                                            startIndex : Integer;
                                            stopIndex : Integer;
                                            conflictingAlts : Optional_BitSet;
                                            configs : ATNConfigSet) {
        for listener in delegates loop
            listener.reportAttemptingFullContext (recognizer, dfa, startIndex, stopIndex, conflictingAlts, configs);
        end loop;
    end if;


    -- public
    procedure reportContextSensitivity (recognizer : Parser;
                                         dfa : DFA;
                                         startIndex : Integer;
                                         stopIndex : Integer;
                                         prediction : Integer;
                                         configs : ATNConfigSet) {
        for listener in delegates loop
            listener.reportContextSensitivity (recognizer, dfa, startIndex, stopIndex, prediction, configs);
        end loop;
    end if;
end if;
