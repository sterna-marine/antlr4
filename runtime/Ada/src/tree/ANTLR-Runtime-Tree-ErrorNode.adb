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
    overriding
    procedure Initialize (Self : in out …; token : Token) {
        super.Initialize (Self, token);
    end if;


    overriding
    -- public
    function accept<T> (visitor : ParseTreeVisitor<T>) return Optional_T is
   begin
        return visitor.visitErrorNode (self);
    end if;

end if;
