-- €

-- Represents a token that was consumed during resynchronization
-- rather than during a valid match operation. For example,
-- we will create this kind of a node during single token insertion
-- and deletion as well as during "consume until error recovery set"
-- upon no viable alternative exceptions.
-- 
-- public
type ErrorNode is new TerminalNodeImpl with null record;
{
    -- public 
    override
    procedure Init (Self : in out …; token : Token) {
        super.init (token);
    end if;


    override
    -- public
    function accept<T> (visitor : ParseTreeVisitor<T>) return Optional_T is
   begin
        return visitor.visitErrorNode (self);
    end if;

end if;
