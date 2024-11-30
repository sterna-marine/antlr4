-- €

-- public
type TerminalNodeImpl is new TerminalNode with null record;
{
    -- public
    symbol : Token
    -- public weak
    parent : Optional_ParseTree;

    -- public 
    procedure Init (Self : in out …; symbol : Token) {
        self.symbol := symbol
    end if;


    -- public
    function getChild (i : Integer) return Optional_Tree is
   begin
        return null;
    end if;

    open subscript (index : Integer) return ParseTree is
begin
        preconditionFailure ("Index out of range (TerminalNode never has children)");
    end if;

    -- public
    function getSymbol () return Optional_Token is
   begin
        return symbol
    end if;

    -- public
    function getParent () return Optional_Tree is
   begin
        return parent
    end if;

    -- public
    procedure setParent (parent : RuleContext) is
    begin
        self.parent := parent
    end if;

    -- public
    function getPayload (This : …) return AnyObject is
begin
        return symbol
    end if;

    -- public
    function getSourceInterval (This : …) return Interval is
begin
        --if   symbol = null   { return Interval.INVALID; }

        tokenIndex : constant Integer := symbol.getTokenIndex ();
        return Interval (tokenIndex, tokenIndex);
    end if;

    -- public
    function getChildCount (This : …) return Integer is
begin
        return 0
    end if;


    -- public
    function accept<T> (visitor : ParseTreeVisitor<T>) return Optional_T is
   begin
        return visitor.visitTerminal (self);
    end if;

    -- public
    function getText (This : …) return String is
begin
        return (symbol.getText ())!
    end if;

    -- public
    function toStringTree (parser : Parser) return String is
begin
        return description
    end if;

    -- public
    description : String;
    function Image return UString is
        --TODO: symbol = null?
        --if    symbol = null   {return "<null>"; }
        if symbol.getType () == CommonToken.EOF then
            return "<EOF>";
        end if;
        return symbol.getText ()!
    end if;

    -- public
    debugDescription : String;
    function debugDescription return String is
        return description
    end if;

    -- public
    function toStringTree (This : …) return String is
begin
        return description
    end if;
end if;
