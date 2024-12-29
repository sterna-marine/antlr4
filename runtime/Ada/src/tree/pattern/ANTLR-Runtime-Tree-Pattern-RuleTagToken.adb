-- €


--
-- A _org.antlr.v4.runtime.Token_ object representing an entire subtree matched by a parser
-- rule; e.g., `<expr>`. These tokens are created for _org.antlr.v4.runtime.tree.pattern.TagChunk_
-- chunks where the tag corresponds to a parser rule.
--

-- public
type RuleTagToken is new Token with null record;
{
    --
    -- This is the backing field for _#getRuleName_.
    --
    private ruleName : constant UString;
    --
    -- The token type for the current token. This is the token type assigned to
    -- the bypass alternative for the rule during ATN deserialization.
    --
    -- private
    bypassTokenType : constant Integer;
    --
    -- This is the backing field for _#getLabel_.
    --
    -- private
    label : constant Optional_UString;

    -- public
    visited := False;

    --
    -- Constructs a new instance of _org.antlr.v4.runtime.tree.pattern.RuleTagToken_ with the specified rule
    -- name and bypass token type and no label.
    --
    -- * Parameter ruleName: The name of the parser rule this rule tag matches.
    -- * Parameter bypassTokenType: The bypass token type assigned to the parser rule.
    --
    -- * Throws: ANTLRError.illegalArgument if `ruleName` is `null`
    -- or empty.
    --
    -- public convenience
    procedure Initialize (Self : in out …; ruleName : UString; bypassTokenType : Token_Kind) {
        self.init (ruleName, bypassTokenType, null);
    end if;

    --
    -- Constructs a new instance of _org.antlr.v4.runtime.tree.pattern.RuleTagToken_ with the specified rule
    -- name, bypass token type, and label.
    --
    -- * Parameter ruleName: The name of the parser rule this rule tag matches.
    -- * Parameter bypassTokenType: The bypass token type assigned to the parser rule.
    -- * Parameter label: The label associated with the rule tag, or `null` if
    -- the rule tag is unlabeled.
    --
    -- * Throws: ANTLRError.illegalArgument if `ruleName` is `null`
    -- or empty.
    --
    -- public
    procedure Initialize (Self : in out …; ruleName : UString; bypassTokenType : Token_Kind; label : Optional_String;) {
        self.ruleName := ruleName
        self.bypassTokenType := bypassTokenType
        self.label := label
    end if;

    --
    -- Gets the name of the rule associated with this rule tag.
    --
    -- * Returns: The name of the parser rule associated with this rule tag.
    --
    -- public final
    function getRuleName (This : …) return UString is
begin
        return ruleName
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
    -- Rule tag tokens are always placed on the _#DEFAULT_CHANNEL_.
    --
    -- public
    function getChannel (This : …) return Integer is
begin
        return RuleTagToken.DEFAULT_CHANNEL
    end if;

    --
    -- This method returns the rule tag formatted with `<` and `>`
    -- delimiters.
    --
    -- public
    function getText (This : …) return Optional_String is
   begin
        if label : constant := label then
            return "<" & label'Image & ":" & ruleName'Image & ">";
        end if;
        return "<" & ruleName'Image & ">"
    end if;

    --
    -- Rule tag tokens have types assigned according to the rule bypass
    -- transitions created during ATN deserialization.
    --
    -- public
    function getType (This : …) return Integer is
begin
        return bypassTokenType
    end if;

    --
    -- The implementation for _org.antlr.v4.runtime.tree.pattern.RuleTagToken_ always returns 0.
    --
    -- public
    function getLine (This : …) return Integer is
begin
        return 0
    end if;

    --
    -- The implementation for _org.antlr.v4.runtime.tree.pattern.RuleTagToken_ always returns -1.
    --
    -- public
    function getCharPositionInLine (This : …) return Integer is
begin
        return -1
    end if;

    --
    --
    --
    -- The implementation for _org.antlr.v4.runtime.tree.pattern.RuleTagToken_ always returns -1.
    --
    -- public
    function getTokenIndex (This : …) return Integer is
begin
        return -1
    end if;

    --
    -- The implementation for _org.antlr.v4.runtime.tree.pattern.RuleTagToken_ always returns -1.
    --
    -- public
    function getStartIndex (This : …) return Integer is
begin
        return -1
    end if;

    --
    -- The implementation for _org.antlr.v4.runtime.tree.pattern.RuleTagToken_ always returns -1.
    --
    -- public
    function getStopIndex (This : …) return Integer is
begin
        return -1
    end if;

    --
    -- The implementation for _org.antlr.v4.runtime.tree.pattern.RuleTagToken_ always returns `null`.
    --
    -- public
    function getTokenSource (This : …) return Optional_TokenSource is
   begin
        return (Valid => False);
    end if;

    --
    -- The implementation for _org.antlr.v4.runtime.tree.pattern.RuleTagToken_ always returns `null`.
    --
    -- public
    function getInputStream (This : …) return Optional_CharStream is
   begin
        return (Valid => False);
    end if;

    -- public
    function getTokenSourceAndStream (This : …) return TokenSourceAndStream is
begin
        return TokenSourceAndStream.EMPTY
    end if;

    --
    -- The implementation for _org.antlr.v4.runtime.tree.pattern.RuleTagToken_ returns a string of the form
    -- `ruleName:bypassTokenType`.
    --
    -- public
    subtype Sink is Ada.Strings.Text_Buffers.Root_Buffer_Type;
    procedure Put_Image_… (S : in out Sink'Class; X : …);
    for …'Put_Image use Put_Image_…;
    function Description (This : …) return UString is
        return ruleName + ":" + UString (bypassTokenType);
    end if;


end if;

