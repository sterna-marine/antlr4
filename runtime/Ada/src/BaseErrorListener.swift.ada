-- 
-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
-- 


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
                             offendingSymbol : AnyObject?,
                             line : Integer;
                             charPositionInLine : Integer;
                             msg : String;
                             e : AnyObject?
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
                                            conflictingAlts : BitSet?,
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
