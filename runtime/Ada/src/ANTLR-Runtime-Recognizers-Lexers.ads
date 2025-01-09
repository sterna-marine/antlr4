-- €

with ANTLR.Runtime.ATN.Simulators.LexerSimulators;
with ANTLR.Runtime.TokenSource_Protocol;

use ANTLR.Runtime.ATN.Simulators.LexerSimulators;
use ANTLR.Runtime.TokenSource_Protocol;

package ANTLR.Runtime.Recognizers.Lexers is

   --
   -- A lexer is recognizer that draws input symbols from a character stream.
   -- lexer grammars result in a subclass of this object. A Lexer object
   -- uses simplified This.match and error recovery mechanisms in the interest
   -- of speed.
   --

   type Lexer_Mode is new Integer;

   package Lexer_Mode_Container is new Ada.Containers.Vectors (
      Index_Type => Natural,
      Item_Type  => Integer,
      "=" => "=");
   subtype Lexer_Mode_Stack is Lexer_Mode_Container.Vector;

   -- public static
   DEFAULT_MODE : constant Lexer_Mode := 0;

   -- public static
   MORE : constant Integer := -2;
   -- public static
   SKIP : constant Integer := -3;

   -- public static
   DEFAULT_TOKEN_CHANNEL : constant Channel_Number := CommonToken.DEFAULT_CHANNEL;
   -- public static
   HIDDEN : constant Channel_Number := CommonToken.HIDDEN_CHANNEL;
   -- public static
   MIN_CHAR_VALUE : constant := Character.MIN_VALUE; --FIXME
   -- public static
   MAX_CHAR_VALUE : constant := Character.MAX_VALUE; --FIXME

   package Lexer_Recognizers is new ANTLR.Runtime.Recognizers.Recognizer (LexerATNSimulator);

   -- open
   type Lexer is new Lexer_Recognizers.Recognizer and TokenSource with record
      -- public
      input : Optional_CharStream;
      -- internal
      tokenFactorySourcePair : TokenSourceAndStream;

      --
      -- How to create token objects
      --
      -- internal
      factory : TOFIX := CommonTokenFactory.DEFAULT;

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
      token : Optional_Token;

      --
      -- What character index in the stream did the current token start at?
      -- Needed, for example, to get the text for current token.  Set at
      -- the start of nextToken.
      --
      -- public
      tokenStartCharIndex : Integer := -1;

      --
      -- The line on which the first character of the token resides
      --
      -- public
      tokenStartLine : Integer := 0;

      --
      -- The character position of first character within the line
      --
      -- public
      tokenStartCharPositionInLine : Integer := 0;

      --
      -- Once we see EOF on char stream, next token will be EOF.
      -- If you have DONE : EOF ; then you see DONE EOF.
      --
      -- public
      hitEOF : Boolean := False;

      --
      -- The channel number for the current token
      --
      -- public
      Channel : Channel_Number := DEFAULT_CHANNEL;

      --
      -- The token type for the current token
      --
      -- public
      Token_Type : Token_Kind := CommonToken.INVALID_Type;

      -- public final
      modeStack : TOFIX := Lexer_Mode_Stack;
      -- public
      mode : Lexer_Mode := DEFAULT_MODE;

      --
      -- You can set the text for the current token to override what is in
      -- the input char buffer.  Use This.setText or can set this instance var.
      --
      -- public
      text : Optional_UString;
   end record;

   subtype Object is Lexer;
   subtype Super is Recognizer;
   type Class is access all Object;
   type Class_Wide is access all Object'Class;

   -- public
   overriding
   procedure Initialize (Self : Lexer);

   -- public required
   procedure Initialize (input : CharStream);

   -- open
   procedure reset (This : Lexer);

   --
   -- Return a token from this source; i.e., match a token on the char
   -- stream.
   --
   -- open
   function nextToken (This : Lexer) return Token;

   --
   -- Instruct the lexer to skip creating a token for current lexer rule
   -- and look for another token.  This.nextToken knows to keep looking when
   -- a lexer rule finishes with token set to SKIP_TOKEN.  Recall that
   -- if token = (Valid => False) at end of any token rule, it creates one for you
   -- and emits it.
   --
   -- open
   procedure skip (This : Lexer);

   -- open
   procedure more (This : Lexer);

   -- open
   procedure mode (This : Lexer; m : Lexer_Mode);

   -- open
   procedure pushMode (This : Lexer; m : Lexer_Mode);

   -- @discardableResult
   -- open
   function popMode (This : Lexer) return Lexer_Mode;

   -- open
   overriding
   procedure setTokenFactory (This : Lexer; Some_factory : TokenFactory);

   --open
   overriding
   function getTokenFactory (This : Lexer) return TokenFactory
      is (This.factory);

   --
   -- Set the char stream and reset the lexer
   --
   -- open
   overriding
   procedure setInputStream (This : Lexer; Some_input : IntStream);

   -- open
   function getSourceName (This : Lexer) return UString
      is (Value (input).getSourceName);

   -- open
   function getInputStream (This : Lexer) return Optional_CharStream
      is (This.input);

   --
   -- By default does not support multiple emits per nextToken invocation
   -- for efficiency reasons.  Subclass and override this method, nextToken,
   -- and getToken (to push tokens into a list and pull from that list
   -- rather than a single variable as this implementation does).
   --
   -- open
   procedure emit (This : Lexer; Some_token : Token);

   --
   -- The standard method called to automatically emit a token at the
   -- outermost lexical rule.  The token object should point into the
   -- char buffer start .. stop.  If there is a text override in 'text',
   -- use that to set the token's text.  Override this method to emit
   -- custom Token objects or provide a new factory.
   --
   -- @discardableResult
   -- open
   function emit (This : Lexer) return Token;

   -- @discardableResult
   -- open
   function emitEOF (This : Lexer) return Token;

   -- open
   function getLine (This : Lexer) return Integer
      is (getInterpreter.getLine);

   -- open
   function getCharPositionInLine (This : Lexer) return Integer
      is (getInterpreter.getCharPositionInLine);

   -- open
   procedure setLine (This : Lexer; line : Integer);

   -- open
   procedure setCharPositionInLine (This : Lexer; charPositionInLine : Integer);

   --
   -- What is the index of the current character of lookahead?
   --
   -- open
   function getCharIndex (This : Lexer) return Integer
      is (Value (input).index);

   --
   -- Return the text matched so far for the current token or any
   -- text override.
   --
   -- open
   function getText (This : Lexer) return UString;

   --
   -- Set the complete text of this token; it wipes any previous
   -- changes to the text.
   --
   -- open
   procedure setText (This : Lexer; text : UString);

   --
   -- Override if emitting multiple tokens.
   --
   -- open
   function getToken (This : Lexer) return Token
      is (Value (This.token));

   -- open
   procedure setToken (This : Lexer; Some_token : Token);

   -- open
   procedure setType (This : Lexer; tType : Token_Kind);

   -- open
   function getType (This : Lexer) return Token_Kind
      is (This.Token_Type);

   -- open
   procedure setChannel (This : Lexer; Some_Channel : Channel_Number);

   -- open
   function getChannel (This : Lexer) return Channel_Number
      is (This.channel);

   -- open
   function getChannelNames (This : Lexer) return Channel_List -- [UString]?
      is (Channel.Container.Empty_Vector);

   -- open
   function getModeNames (This : Lexer) return Channel_List -- [UString]?
      is (Channel.Container.Empty_Vector);

   --
   -- Return a list of all Token objects in input char stream.
   -- Forces load of all tokens. Does not include EOF token.
   --
   -- open
   function getAllTokens (This : Lexer) return Token_List;

   -- open
   procedure recover (This : Lexer; e : LexerNoViableAltException);


   -- open
   generic
      type T is private;
      package Recognizers_T is new ANTLR.Runtime.Recognizers.Recognizer (T);
      subtype Recognizer_T is Recognizers_T.Recognizer;
   procedure notifyListeners (This : Lexer; e : LexerNoViableAltException; recognizer: Recognizer_T);

   -- open
   function getErrorDisplay (This : Lexer; s : UString) return UString;

   -- open
   function getErrorDisplay (This : Lexer; c : Character) return UString;

   -- open
   function getCharErrorDisplay (This : Lexer; c : Character) return UString
      is (''' & getErrorDisplay (c)'Image & ''');

   --
   -- Lexers can normally match any char in it's vocabulary after matching
   -- a token, so do the easy thing and just kill a character and hope
   -- it all works out.  You can instead use the rule invocation stack
   -- to do sophisticated error recovery if you are in a fragment rule.
   --
   -- open
   procedure recover (This : Lexer; re : AnyObject);

end  ANTLR.Runtime.Recognizers.Lexers;
