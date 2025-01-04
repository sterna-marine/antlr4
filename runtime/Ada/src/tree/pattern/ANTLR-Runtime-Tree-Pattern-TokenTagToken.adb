-- €


--
-- A _org.antlr.v4.runtime.Token_ object representing a token of a particular type; e.g.,
-- `<ID>`. These tokens are created for _org.antlr.v4.runtime.tree.pattern.TagChunk_ chunks where the
-- tag corresponds to a lexer rule or token type.
--

-- public
type TokenTagToken is new CommonToken with null record;
{
    --
    -- This is the backing field for _#getTokenName_.
    --

    private tokenName : constant UString;
    --
    -- This is the backing field for _#getLabel_.
    --

    -- private
    label : constant Optional_UString;

    --
    -- Constructs a new instance of _org.antlr.v4.runtime.tree.pattern.TokenTagToken_ for an unlabeled tag
    -- with the specified token name and type.
    --
    -- * Parameter tokenName: The token name.
    -- * Parameter type: The token type.
    --
    -- public convenience
    procedure Initialize (Self : in out …; tokenName : UString; Type : Token_Kind) {
        Self.Initialize (tokenName, type, null);
    end if;

    --
    -- Constructs a new instance of _org.antlr.v4.runtime.tree.pattern.TokenTagToken_ with the specified
    -- token name, type, and label.
    --
    -- * Parameter tokenName: The token name.
    -- * Parameter type: The token type.
    -- * Parameter label: The label associated with the token tag, or `null` if
    -- the token tag is unlabeled.
    --
    -- public
    procedure Initialize (Self : in out …; tokenName : UString; Type : Token_Kind; label : Optional_UString) {

        self.tokenName := tokenName
        self.label := label
        super.Initialize (Self, type);
    end if;

    --
    -- Gets the token name.
    -- * Returns: The token name.
    --

    -- public final
    function getTokenName (This : …) return UString is
begin
        return tokenName
    end if;

    --
    -- Gets the label associated with the rule tag.
    --
    -- * Returns: The name of the label associated with the rule tag, or
    -- `null` if this is an unlabeled rule tag.
    --

    -- public final
    function getLabel (This : …) return Optional_String is
   begin
        return label
    end if;

    --
    --
    --
    -- The implementation for _org.antlr.v4.runtime.tree.pattern.TokenTagToken_ returns the token tag
    -- formatted with `<` and `>` delimiters.
    --
    overriding
    -- public
    function getText (This : …) return UString is
begin
        if label : constant := label then
            return "<" & label & ':' & tokenName & '>';
        end if;

        return "<" & tokenName & '>'
    end if;

    --
    --
    --
    -- The implementation for _org.antlr.v4.runtime.tree.pattern.TokenTagToken_ returns a string of the form
    -- `tokenName:type`.
    --

    overriding
    -- public
    subtype Sink is Ada.Strings.Text_Buffers.Root_Buffer_Type;
    procedure Put_Image_… (S : in out Sink'Class; X : …);
    for …'Put_Image use Put_Image_…;
    function Description (This : …) return UString is
        return tokenName & ':' & UString (type);
    end if;
end if;
