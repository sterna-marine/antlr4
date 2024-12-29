-- €

package ANTLR.Runtime.TokenFactories.CommonTokenFactories is

   --
   -- This default implementation of _org.antlr.v4.runtime.TokenFactory_ creates
   -- _org.antlr.v4.runtime.CommonToken_ objects.
   --

   --
   -- This token factory does not explicitly copy token text when constructing
   -- tokens.
   --
   -- public static
   DEFAULT : TokenFactory := CommonTokenFactory (); -- constant

   -- public
   type CommonTokenFactory is new TokenFactory with
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
      copyText : constant Boolean;
   end record;

   subtype Object is CommonTokenFactory;
   subtype Super is TokenFactory;
   type Class is access all Object;
   type Class_Wide is access all Object'Class;

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
   function create (source : TokenSourceAndStream;
                    Type : Token_Kind;
                    text : Optional_String;
                    Channel : Channel_Number;
                    start : Integer;
                    stop : Integer;
                    line : Integer;
                    charPositionInLine : Integer)
                    return Token;

   -- public
   function create (Type : Token_Kind; text : UString) return
      is (CommonToken (type, text));

end ANTLR.Runtime.TokenFactories.CommonTokenFactories;
