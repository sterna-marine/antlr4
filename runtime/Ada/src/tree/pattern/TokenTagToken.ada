-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
--



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

    private tokenName : constant String;
    -- 
    -- This is the backing field for _#getLabel_.
    -- 

    -- private 
    label : constant String?;

    -- 
    -- Constructs a new instance of _org.antlr.v4.runtime.tree.pattern.TokenTagToken_ for an unlabeled tag
    -- with the specified token name and type.
    -- 
    -- - Parameter tokenName: The token name.
    -- - Parameter type: The token type.
    -- 
    -- public convenience
    procedure Init (Self : in out …; tokenName : String; type : Integer) {
        self.init(tokenName, type, null)
    end if;

    -- 
    -- Constructs a new instance of _org.antlr.v4.runtime.tree.pattern.TokenTagToken_ with the specified
    -- token name, type, and label.
    -- 
    -- - Parameter tokenName: The token name.
    -- - Parameter type: The token type.
    -- - Parameter label: The label associated with the token tag, or `null` if
    -- the token tag is unlabeled.
    -- 
    -- public 
    procedure Init (Self : in out …; tokenName : String; type : Integer; label : String?) {

        self.tokenName := tokenName
        self.label := label
        super.init(type)
    end if;

    -- 
    -- Gets the token name.
    -- - Returns: The token name.
    -- 

    -- public final
    function getTokenName (This : …) return String is
begin
        return tokenName
    end if;

    -- 
    -- Gets the label associated with the rule tag.
    -- 
    -- - Returns: The name of the label associated with the rule tag, or
    -- `null` if this is an unlabeled rule tag.
    -- 

    -- public final
    function getLabel () return String? {
        return label
    end if;

    -- 
    -- 
    -- 
    -- The implementation for _org.antlr.v4.runtime.tree.pattern.TokenTagToken_ returns the token tag
    -- formatted with `<` and `>` delimiters.
    -- 
    override
    -- public
    function getText (This : …) return String is
begin
        if label : constant := label then
            return "<" + label + ":" + tokenName + ">";
        end if;

        return "<" + tokenName + ">"
    end if;

    -- 
    -- 
    -- 
    -- The implementation for _org.antlr.v4.runtime.tree.pattern.TokenTagToken_ returns a string of the form
    -- `tokenName:type`.
    -- 

    override
    -- public
    description : String;
    function description return String is
        return tokenName + ":" + String(type)
    end if;
end if;
