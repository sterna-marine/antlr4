-- €

with Ada.Finalization;
with ANTLR.Runtime.TokenFactory_Protocol,
with ANTLR.Runtime.Token_Protocol,

use ANTLR.Runtime.TokenFactory_Protocol;
use ANTLR.Runtime.Token_Protocol,

package ANTLR.Runtime.CommonTokenFactories is

   --
   -- This default implementation of _org.antlr.v4.runtime.TokenFactory_ creates
   -- _org.antlr.v4.runtime.CommonToken_ objects.
   --

   type CommonTokenFactory_Base is new Ada.Finalization.Controlled  with null record;

   -- public
   type CommonTokenFactory is new CommonTokenFactory_Base and TokenFactory with
   record
      --
      -- The default _org.antlr.v4.runtime.CommonTokenFactory_ instance.
      --

      --
      -- Indicates whether _org.antlr.v4.runtime.CommonToken#setText_ should be called after
      -- constructing tokens to explicitly set the text. This is useful for cases
      -- where the input stream might not be able to provide arbitrary substrings
      -- of text from the input after the lexer creates a token (e.g. the
      -- implementation of _org.antlr.v4.runtime.CharStream#getText_ in
      -- _org.antlr.v4.runtime.UnbufferedCharStream_ an
      -- _UnsupportedOperationException_). Explicitly setting the token text
      -- allows _org.antlr.v4.runtime.Token#getText_ to be called at any time regardless of the
      -- input stream implementation.
      --
      --
      -- The default value is `False` to avoid the performance and memory
      -- overhead of copying text for every token unless explicitly requested.
      --
      -- internal
      copyText : constant Boolean := False;
   end record;

   subtype Object is CommonTokenFactory;
   type Class is access all Object;
   type Class_Wide is access all Object'Class;

   --
   -- This token factory does not explicitly copy token text when constructing
   -- tokens.
   --
   -- public static
   DEFAULT :  constant CommonTokenFactory;

   --
   -- Constructs a _org.antlr.v4.runtime.CommonTokenFactory_ with the specified value for
   -- _#copyText_.
   --
   --
   -- When `copyText` is `False`, the _#DEFAULT_ instance
   -- should be used instead of constructing a new instance.
   --
   -- * parameter copyText: The value for _#copyText_.
   --
   -- public
   procedure Initialize (Self : in out CommonTokenFactory; copyText : Boolean);

   --
   -- Constructs a _org.antlr.v4.runtime.CommonTokenFactory_ with _#copyText_ set to
   -- `False`.
   --
   --
   -- The _#DEFAULT_ instance should be used instead of calling this
   -- directly.
   --
   -- public convenience
   overriding
   procedure Initialize (Self : in out CommonTokenFactory);


   -- public
   function create (This : CommonTokenFactory;
                    source : TokenSourceAndStream;
                    Token_Kind : Token_Kind;
                    text : Optional_String;
                    Channel : Channel_Number;
                    start : Integer;
                    stop : Integer;
                    line : Integer;
                    charPositionInLine : Integer)
                    return Token;

   -- public
   function create (This : CommonTokenFactory;
                    Token_Kind : Token_Kind;
                    text : UString) return Token
      is (CommonToken (type, text));

end ANTLR.Runtime.CommonTokenFactories;
