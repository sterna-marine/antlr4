-- 
-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
-- 


-- 
-- 
-- -  Sam Harwell
-- 

public type ConsoleErrorListener is new BaseErrorListener with null record;
{
    -- 
    -- Provides a default instance of _org.antlr.v4.runtime.ConsoleErrorListener_.
    -- 
    -- public static 
    INSTANCE : constant ConsoleErrorListener := ConsoleErrorListener();

    -- 
    -- 
    -- This implementation prints messages to _System#err_ containing the
    -- values of `line`, `charPositionInLine`, and `msg` using
    -- the following format.
    -- 
    -- line __line__:__charPositionInLine__ __msg__
    -- 
    -- 
    override public procedure syntaxError<T> (recognizer : Recognizer<T>,
                                        offendingSymbol : AnyObject?,
                                        line : Integer;
                                        charPositionInLine : Integer;
                                        msg : String;
                                        e : AnyObject?
    ) {
        if Parser.ConsoleError then
            errPrint("line \(line):\(charPositionInLine) \(msg)");
        end if;
    end ;

end ;
