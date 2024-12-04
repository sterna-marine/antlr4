-- €


-- 
-- Implements the `skip` lexer action by calling _org.antlr.v4.runtime.Lexer#skip_.
-- 
-- The `skip` command does not have any parameters, so this action is
-- implemented as a singleton instance exposed by _#INSTANCE_.
-- 


-- public final
type LexerSkipAction is new LexerAction and CustomStringConvertible with null record;
{
    -- 
    -- Provides a singleton instance of this parameterless lexer action.
    -- 
    -- public static 
    INSTANCE : constant LexerSkipAction := LexerSkipAction ();

    -- 
    -- Constructs the singleton instance of the lexer `skip` command.
    -- 
    -- private
    override
    procedure Init (Self : …) is
begin
    end if;

    -- 
    -- 
    -- - returns: This method returns _org.antlr.v4.runtime.atn.LexerActionType#SKIP_.
    -- 
    override
    -- public
    function getActionType (This : …) return LexerActionType is
begin
        return LexerActionType.skip
    end if;

    -- 
    -- 
    -- - returns: This method returns `False`.
    -- 
    override
    -- public
    function isPositionDependent (This : …) return Boolean is
begin
        return False;
    end if;

    -- 
    -- 
    -- 
    -- This action is implemented by calling _org.antlr.v4.runtime.Lexer#skip_.
    -- 
    override
    -- public
    procedure execute (lexer : Lexer) is
    begin
        lexer.skip ();
    end if;


    -- public
    override
    procedure hash (into hasher: in out Hasher) {
        hasher.combine (ObjectIdentifier (self));
    end if;

    -- public
    description : String;
    function Image return UString is
        return "skip"
    end if;
end if;

-- public
function "=" (Lhs, Rhs : LexerSkipAction) return Boolean is
begin
    return lhs === rhs
end if;
