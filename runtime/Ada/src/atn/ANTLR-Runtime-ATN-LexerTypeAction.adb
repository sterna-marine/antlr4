-- €


-- 
-- Implements the `type` lexer action by calling _org.antlr.v4.runtime.Lexer#setType_
-- with the assigned type.
-- 


-- public
type LexerTypeAction is new LexerAction and CustomStringConvertible with null record;
{
    -- fileprivate
    type : constant Integer;

    -- 
    -- Constructs a new `type` action with the specified token type value.
    -- - parameter type: The type to assign to the token using _org.antlr.v4.runtime.Lexer#setType_.
    -- 
    -- public 
    procedure Init (Self : in out …; type : Integer) {
        self.type := type
    end if;

    -- 
    -- Gets the type to assign to a token created by the lexer.
    -- - returns: The type to assign to a token created by the lexer.
    -- 
    -- public
    function getType (This : …) return Integer is
begin
        return type
    end if;

    -- 
    -- 
    -- - returns: This method returns _org.antlr.v4.runtime.atn.LexerActionType#TYPE_.
    -- 

    --public
    override
    function getActionType (This : …) return LexerActionType is
begin
        return LexerActionType.type
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
    -- This action is implemented by calling _org.antlr.v4.runtime.Lexer#setType_ with the
    -- value provided by _#getType_.
    -- 

    -- public
    override
    procedure execute (lexer : Lexer) {
        lexer.setType (type);
    end if;


    -- public
    override
    procedure hash (into hasher: inout Hasher) {
        hasher.combine (type);
    end if;

    -- public
    description : String;
    function Image return UString is
        return "type (\(type))"
    end if;
end if;

-- public
function "=" (lhs: LexerTypeAction, rhs: LexerTypeAction) return Boolean is
begin
    if lhs === rhs then
        return True;
    end if;
    return lhs.type = rhs.type
end if;
