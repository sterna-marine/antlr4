-- €

with ANTLR.Runtime.Token_Protocol;
with ANTLR.Runtime.Misc.Extensions.TokenExtensions;

use ANTLR.Runtime;
use ANTLR.Runtime.Token_Protocol;

package ANTLR.Runtime.Tree.Pattern.RuleTagTokens is

   --
   -- A _org.antlr.v4.runtime.Token_ object representing an entire subtree matched by a parser
   -- rule; e.g., `<expr>`. These tokens are created for _org.antlr.v4.runtime.tree.pattern.TagChunk_
   -- chunks where the tag corresponds to a parser rule.
   --

   -- public
   type RuleTagToken is new Token with
   record
      --
      -- This is the backing field for _#getRuleName_.
      --
      -- private
      ruleName : UString; -- constant
      --
      -- The token type for the current token. This is the token type assigned to
      -- the bypass alternative for the rule during ATN deserialization.
      --
      -- private
      bypassTokenType : Integer; -- constant
      --
      -- This is the backing field for _#getLabel_.
      --
      -- private
      label : Optional_UString; -- constant

      -- public
      visited : Boolean := False;
   end record;

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
   procedure Initialize (Self : in out RuleTagToken;
                         ruleName : UString;
                         bypassTokenType : Token_Kind);

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
   procedure Initialize (Self : in out RuleTagToken;
                         ruleName : UString;
                         bypassTokenType : Token_Kind;
                         label : Optional_UString);

   --
   -- Gets the name of the rule associated with this rule tag.
   --
   -- * Returns: The name of the parser rule associated with this rule tag.
   --
   -- public final
   function getRuleName (This : RuleTagToken) return UString
      is (This.ruleName);

   --
   -- Gets the label associated with the rule tag.
   --
   -- * Returns: The name of the label associated with the rule tag, or
   -- `null` if this is an unlabeled rule tag.
   --
   -- public final
   function getLabel (This : RuleTagToken) return Optional_UString
      is (This.label);

   --
   -- Rule tag tokens are always placed on the _#DEFAULT_CHANNEL_.
   --
   -- public
   function getChannel (This : RuleTagToken) return Channel_Number
      is (DEFAULT_CHANNEL);

   --
   -- This method returns the rule tag formatted with `<` and `>`
   -- delimiters.
   --
   -- public
   function getText (This : RuleTagToken) return Optional_UString;

   --
   -- Rule tag tokens have types assigned according to the rule bypass
   -- transitions created during ATN deserialization.
   --
   -- public
   function getType (This : RuleTagToken) return Integer
      is (This.bypassTokenType);

   --
   -- The implementation for _org.antlr.v4.runtime.tree.pattern.RuleTagToken_ always returns 0.
   --
   -- public
   function getLine (This : RuleTagToken) return Integer
      is (0);

   --
   -- The implementation for _org.antlr.v4.runtime.tree.pattern.RuleTagToken_ always returns -1.
   --
   -- public
   function getCharPositionInLine (This : RuleTagToken) return Integer
      is (-1);

   --
   --
   --
   -- The implementation for _org.antlr.v4.runtime.tree.pattern.RuleTagToken_ always returns -1.
   --
   -- public
   function getTokenIndex (This : RuleTagToken) return Integer
      is (-1);

   --
   -- The implementation for _org.antlr.v4.runtime.tree.pattern.RuleTagToken_ always returns -1.
   --
   -- public
   function getStartIndex (This : RuleTagToken) return Integer
      is (-1);

   --
   -- The implementation for _org.antlr.v4.runtime.tree.pattern.RuleTagToken_ always returns -1.
   --
   -- public
   function getStopIndex (This : RuleTagToken) return Integer
      is (-1);

   --
   -- The implementation for _org.antlr.v4.runtime.tree.pattern.RuleTagToken_ always returns `null`.
   --
   -- public
   function getTokenSource (This : RuleTagToken) return Optional_TokenSource
      is (Valid => False);

   --
   -- The implementation for _org.antlr.v4.runtime.tree.pattern.RuleTagToken_ always returns `null`.
   --
   -- public
   function getInputStream (This : RuleTagToken) return Optional_CharStream
      is (Valid => False);

   -- public
   function getTokenSourceAndStream (This : RuleTagToken) return TokenSourceAndStream
      is (This.TokenSourceAndStream.EMPTY);

   --
   -- The implementation for _org.antlr.v4.runtime.tree.pattern.RuleTagToken_ returns a string of the form
   -- `ruleName:bypassTokenType`.
   --
   subtype Sink is Ada.Strings.Text_Buffers.Root_Buffer_Type;
   procedure Put_Image_RuleTagToken (S : in out Sink'Class; X : RuleTagToken);
   for RuleTagToken'Put_Image use Put_Image_RuleTagToken;
   -- public
   function Description (This : RuleTagToken) return UString
      is (ruleName & ':' & bypassTokenType'Image);

end ANTLR.Runtime.Tree.Pattern.RuleTagTokens;
