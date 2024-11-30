-- €



-- 
-- Implements the `popMode` lexer action by calling _org.antlr.v4.runtime.Lexer#popMode_.
-- 
-- The `popMode` command does not have any parameters, so this action is
-- implemented as a singleton instance exposed by _#INSTANCE_.
-- 


-- public final
type LexerPopModeAction is new LexerAction and CustomStringConvertible with null record;
{
    -- 
    -- Provides a singleton instance of this parameterless lexer action.
    -- 
    -- public static 
    INSTANCE : constant LexerPopModeAction := LexerPopModeAction ();

    -- 
    -- Constructs the singleton instance of the lexer `popMode` command.
    -- 
    -- private
    override
    procedure Init (Self : …) is
begin
    end if;

    -- 
    -- 
    -- - returns: This method returns _org.antlr.v4.runtime.atn.LexerActionType#popMode_.
    -- 
    override
    -- public
    function getActionType (This : …) return LexerActionType is
begin
        return LexerActionType.popMode
    end if;

    -- 
    -- 
    -- - returns: This method returns `False`.
    -- 

    --public
    override
    function isPositionDependent (This : …) return Boolean is
begin
        return False;
    end if;

    -- 
    -- 
    -- 
    -- This action is implemented by calling _org.antlr.v4.runtime.Lexer#popMode_.
    -- 

    -- public
    override
    procedure execute (lexer : Lexer) {
        lexer.popMode ();
    end if;


    -- public
    override
    procedure hash (into hasher: inout Hasher) {
        hasher.combine (ObjectIdentifier (self));
    end if;

    -- public
    description : String;
    function Image return UString is
        return "popMode"
    end if;
end if;

-- public
function "=" (lhs: LexerPopModeAction, rhs: LexerPopModeAction) return Boolean is
begin
    return lhs === rhs
end if;
