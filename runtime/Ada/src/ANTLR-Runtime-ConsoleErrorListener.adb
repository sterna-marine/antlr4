-- €


-- 
-- 
-- -  Sam Harwell
-- 

-- public
type ConsoleErrorListener is new BaseErrorListener with null record;
{
    -- 
    -- Provides a default instance of _org.antlr.v4.runtime.ConsoleErrorListener_.
    -- 
    -- public static 
    INSTANCE : constant ConsoleErrorListener := ConsoleErrorListener ();

    -- 
    -- 
    -- This implementation prints messages to _System#err_ containing the
    -- values of `line`, `charPositionInLine`, and `msg` using
    -- the following format.
    -- 
    -- line __line__:__charPositionInLine__ __msg__
    -- 
    -- 
    -- public
    override
    procedure syntaxError<T> (recognizer : Recognizer<T>,
                                        offendingSymbol : Optional_AnyObject;
                                        line : Integer;
                                        charPositionInLine : Integer;
                                        msg : String;
                                        e : Optional_AnyObject;
    ) {
        if Parser.ConsoleError then
            errPrint ("line " & line'Image & ":" & charPositionInLine'Image & " " & msg'Image);
        end if;
    end if;

end if;
