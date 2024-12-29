-- €

-- public
type TerminalNodeImpl is new TerminalNode with null record;
{
    -- public
    symbol : Token
    -- public weak
    parent : Optional_ParseTree;

    -- public
    procedure Initialize (Self : in out …; symbol : Token) {
        self.symbol := symbol
    end if;


    -- public
    function getChild (i : Integer) return Optional_Tree is
   begin
        return (Valid => False);
    end if;

    open subscript (index : Integer) return ParseTree is
begin
        preconditionFailure ("Index out of range (TerminalNode never has children)");
    end if;

    -- public
    function getSymbol (This : …) return Optional_Token is
   begin
        return symbol
    end if;

    -- public
    function getParent (This : …) return Optional_Tree is
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
        --if   not Is_Valid (symbol)   { return Interval.INVALID; }

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
    function getText (This : …) return UString is
begin
        return (symbol.getText ())!
    end if;

    -- public
    function toStringTree (parser : Parser) return UString is
begin
        return description
    end if;

    -- public
    subtype Sink is Ada.Strings.Text_Buffers.Root_Buffer_Type;
    procedure Put_Image_… (S : in out Sink'Class; X : …);
    for …'Put_Image use Put_Image_…;
    function Description (This : …) return UString is
        --TODO: not Is_Valid (symbol)?
        --if    not Is_Valid (symbol)   {return "<null>"; }
        if symbol.getType () == CommonToken.EOF then
            return "<EOF>";
        end if;
        return symbol.getText ()!
    end if;

    -- public
    function debugDescription (This : …) return UString
      is (Description (This));

    -- public
    function toStringTree (This : …) return UString is
begin
        return description
    end if;
end if;
