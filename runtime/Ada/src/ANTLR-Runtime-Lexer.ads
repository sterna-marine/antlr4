-- €

package ANTLR.Runtime.Lexer is

   -- 
   -- A lexer is recognizer that draws input symbols from a character stream.
   -- lexer grammars result in a subclass of this object. A Lexer object
   -- uses simplified match () and error recovery mechanisms in the interest
   -- of speed.
   -- 

   type Lexer_Mode is new Natural;

   -- public static 
   DEFAULT_MODE : constant Lexer_Mode := 0;

   -- public static 
   EOF : constant Integer := -1
   -- public static 
   MORE : constant Integer := -2
   -- public static 
   SKIP : constant Integer := -3

   -- public static 
   DEFAULT_TOKEN_CHANNEL : constant Channel_Number := CommonToken.DEFAULT_CHANNEL;
   -- public static 
   HIDDEN : constant Channel_Number := CommonToken.HIDDEN_CHANNEL;
   -- public static 
   MIN_CHAR_VALUE : constant := Character.MIN_VALUE; --FIXME
   -- public static 
   MAX_CHAR_VALUE : constant := Character.MAX_VALUE; --FIXME

   -- open
   type Lexer is new Recognizer<LexerATNSimulator> and TokenSource with record
      -- public
      _input : Optional_CharStream;
      -- internal
      _tokenFactorySourcePair : TokenSourceAndStream;

      -- 
      -- How to create token objects
      -- 
      -- internal
      _factory := CommonTokenFactory.DEFAULT;

      -- 
      -- The goal of all lexer rules/methods is to create a token object.
      -- This is an instance variable as multiple rules may collaborate to
      -- create a single token.  nextToken will return this object after
      -- matching lexer rule (s).  If you subclass to allow multiple token
      -- emissions, then set this to the last token to be matched or
      -- something nonnull so that the auto token emit mechanism will not
      -- emit another token.
      -- 
      -- public
      _token : Optional_Token;

      -- 
      -- What character index in the stream did the current token start at?
      -- Needed, for example, to get the text for current token.  Set at
      -- the start of nextToken.
      -- 
      -- public
      _tokenStartCharIndex : Integer := -1;

      -- 
      -- The line on which the first character of the token resides
      -- 
      -- public
      _tokenStartLine : Integer := 0;

      -- 
      -- The character position of first character within the line
      -- 
      -- public
      _tokenStartCharPositionInLine : Integer := 0;

      -- 
      -- Once we see EOF on char stream, next token will be EOF.
      -- If you have DONE : EOF ; then you see DONE EOF.
      -- 
      -- public
      _hitEOF : Boolean := False;

      -- 
      -- The channel number for the current token
      -- 
      -- public
      _Channel : Channel_Number := DEFAULT_CHANNEL;

      -- 
      -- The token type for the current token
      -- 
      -- public
      _Token_Type : Token_Kind := CommonToken.INVALID_Type;

      -- public final 
      _modeStack := Stack<Lexer_Mode> ();
      -- public
      _mode : Lexer_Mode := DEFAULT_MODE;

      -- 
      -- You can set the text for the current token to override what is in
      -- the input char buffer.  Use setText () or can set this instance var.
      -- 
      -- public
      _text : Optional_String;

   end record;

   -- public
   override
   procedure Init (Self : Lexer) is

   -- public required 
   procedure Init (input : CharStream) is

   -- open
   procedure reset (This : Lexer) is

   -- 
   -- Return a token from this source; i.e., match a token on the char
   -- stream.
   -- 
   -- open
   function nextToken (This : Lexer) return Token is

   -- 
   -- Instruct the lexer to skip creating a token for current lexer rule
   -- and look for another token.  nextToken () knows to keep looking when
   -- a lexer rule finishes with token set to SKIP_TOKEN.  Recall that
   -- if token = null at end of any token rule, it creates one for you
   -- and emits it.
   -- 
   -- open
   procedure skip (This : Lexer) is

   -- open
   procedure more (This : Lexer) is

   -- open
   procedure mode (This : Lexer; m : Lexer_Mode) is

   -- open
   procedure pushMode (This : Lexer; m : Lexer_Mode) is

   -- @discardableResult
   -- open
   function popMode (This : Lexer) return Lexer_Mode is

   -- open
   override
   procedure setTokenFactory (This : Lexer; factory : TokenFactory) is

   --open
   override
   function getTokenFactory (This : Lexer) return TokenFactory
      is (This._factory);

   -- 
   -- Set the char stream and reset the lexer
   -- 
   -- open
   override
   procedure setInputStream (This : Lexer; input : IntStream) is

   -- open
   function getSourceName (This : Lexer) return String
      is (_input!.getSourceName ());

   -- open
   function getInputStream (This : Lexer) return Optional_CharStream
      is (This._input);

   -- 
   -- By default does not support multiple emits per nextToken invocation
   -- for efficiency reasons.  Subclass and override this method, nextToken,
   -- and getToken (to push tokens into a list and pull from that list
   -- rather than a single variable as this implementation does).
   -- 
   -- open
   procedure emit (This : Lexer; token : Token) is

   -- 
   -- The standard method called to automatically emit a token at the
   -- outermost lexical rule.  The token object should point into the
   -- char buffer start .. stop.  If there is a text override in 'text',
   -- use that to set the token's text.  Override this method to emit
   -- custom Token objects or provide a new factory.
   -- 
   -- @discardableResult
   -- open
   function emit (This : Lexer) return Token is

   -- @discardableResult
   -- open
   function emitEOF (This : Lexer) return Token is

   -- open
   function getLine (This : Lexer) return Integer
      is (getInterpreter ().getLine ());

   -- open
   function getCharPositionInLine (This : Lexer) return Integer
      is (getInterpreter ().getCharPositionInLine ());

   -- open
   procedure setLine (This : Lexer; line : Integer) is

   -- open
   procedure setCharPositionInLine (This : Lexer; charPositionInLine : Integer) is

   -- 
   -- What is the index of the current character of lookahead?
   -- 
   -- open
   function getCharIndex (This : Lexer) return Integer
      is (_input!.index ());

   -- 
   -- Return the text matched so far for the current token or any
   -- text override.
   -- 
   -- open
   function getText (This : Lexer) return String is

   -- 
   -- Set the complete text of this token; it wipes any previous
   -- changes to the text.
   -- 
   -- open
   procedure setText (This : Lexer; text : String) is

   -- 
   -- Override if emitting multiple tokens.
   -- 
   -- open
   function getToken (This : Lexer) return Token
      is (This._token!);

   -- open
   procedure setToken (This : Lexer; _token : Token) is

   -- open
   procedure setType (This : Lexer; tType : Token_Kind) is

   -- open
   function getType (This : Lexer) return Token_Kind
      is (This._Token_Type)

   -- open
   procedure setChannel (This : Lexer; Channel : Channel_Number) is

   -- open
   function getChannel (This : Lexer) return Channel_Number
      is (This._channel);

   -- open
   function getChannelNames (This : Lexer) return Channel.Container.Vector -- [String]?
      is (Channel.Container.Empty_Vector);

   -- open
   function getModeNames (This : Lexer) return Channel.Container.Vector -- [String]?
      is (Channel.Container.Empty_Vector);

   -- 
   -- Return a list of all Token objects in input char stream.
   -- Forces load of all tokens. Does not include EOF token.
   -- 
   -- open
   function getAllTokens (This : Lexer) return Token.Container.Vector is

   -- open
   procedure recover (This : Lexer; e : LexerNoViableAltException) is

   -- open
   generic
      type T is private;
   procedure notifyListeners (This : Lexer; e : LexerNoViableAltException; recognizer: Recognizer<T>) is

   -- open
   function getErrorDisplay (This : Lexer; s : String) return String is

   -- open
   function getErrorDisplay (This : Lexer; c : Character) return String is

   -- open
   function getCharErrorDisplay (This : Lexer; c : Character) return String
      is "'" & getErrorDisplay (c)'Image & "'";

   -- 
   -- Lexers can normally match any char in it's vocabulary after matching
   -- a token, so do the easy thing and just kill a character and hope
   -- it all works out.  You can instead use the rule invocation stack
   -- to do sophisticated error recovery if you are in a fragment rule.
   -- 
   -- open
   procedure recover (This : Lexer; re : AnyObject) is

end  ANTLR.Runtime.Lexer;
