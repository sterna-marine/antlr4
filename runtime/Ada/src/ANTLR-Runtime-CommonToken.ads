-- €

with ANTLR.Runtime.Misc.Extensions.TokenExtension;
with ANTLR.Runtime.WritableToken;

use ANTLR.Runtime;
use ANTLR.Runtime.Misc.Extensions.TokenExtension;

package ANTLR.Runtime.CommonToken is

   visited : Boolean; --TOFIX

   -- public
   type CommonToken is new WritableToken with
   record
      --
      -- This is the backing field for _#getType_ and _#setType_.
      --
      -- internal
      Token_Type : Token_Kind;

      --
      -- This is the backing field for _#getLine_ and _#setLine_.
      --
      -- internal
      line : Integer := 0;

      --
      -- This is the backing field for _#getCharPositionInLine_ and
      -- _#setCharPositionInLine_.
      --
      -- internal
      charPositionInLine : Integer := -1;
      -- set to invalid position

      --
      -- This is the backing field for _#getChannel_ and
      -- _#setChannel_.
      --
      -- internal
      channel : Channel_Number:= DEFAULT_CHANNEL;

      --
      -- This is the backing field for _#getTokenSource_ and
      -- _#getInputStream_.
      --
      --
      -- These properties share a field to reduce the memory footprint of
      -- _org.antlr.v4.runtime.CommonToken_. Tokens created by a _org.antlr.v4.runtime.CommonTokenFactory_ from
      -- the same source and input stream share a reference to the same
      -- _org.antlr.v4.runtime.misc.Pair_ containing these values.
      --

      -- internal
      source : TokenSourceAndStream; -- constant

      --
      -- This is the backing field for _#getText_ when the token text is
      -- explicitly set in the constructor or via _#setText_.
      --
      -- * seealso: #getText ();
      --
      -- internal
      text : Optional_String;

      --
      -- This is the backing field for _#getTokenIndex_ and
      -- _#setTokenIndex_.
      --
      -- internal
      index : Integer := -1;

      --
      -- This is the backing field for _#getStartIndex_ and
      -- _#setStartIndex_.
      --
      -- internal
      start : Integer := 0;

      --
      -- This is the backing field for _#getStopIndex_ and
      -- _#setStopIndex_.
      --
      -- internal
      stop : Integer := 0;

      --
      -- Constructs a new _org.antlr.v4.runtime.CommonToken_ with the specified token type.
      --
      -- * parameter Token_Type: The token type.
      --

      -- private
      _visited : Boolean := False;

   end record;

   subtype Object is CommonToken;
   subtype Super is WritableToken;
   type Class is access all Object;
   type Class_Wide is access all Object'Class;

   -- public
   procedure Initialize (Self : in out CommonToken; Token_Type : Token_Kind);

   -- public
   procedure Initialize (Self : in out CommonToken;
                   source : TokenSourceAndStream;
                   Token_Type : Token_Kind;
                   Channel : Channel_Number;
                   start : Integer;
                   stop : Integer) is

   --
   -- Constructs a new _org.antlr.v4.runtime.CommonToken_ with the specified token type and
   -- text.
   --
   -- * parameter Token_Type: The token type.
   -- * parameter text: The text of the token.
   --
   -- public
   procedure Initialize (Self : in out CommonToken;
                   Token_Type : Token_Kind;
                   text : Optional_String) is

   --
   -- Constructs a new _org.antlr.v4.runtime.CommonToken_ as a copy of another _org.antlr.v4.runtime.Token_.
   --
   -- * parameter oldToken: The token to copy.
   --
   -- public
   procedure Initialize (Self : in out CommonToken; oldToken : Token);

   -- public
   function getType (This : CommonToken) return Token_Kind
      is (This.Token_Type);

   -- public
   procedure setLine (This : CommonToken; line : Integer);


   -- public
   function getText (This : CommonToken) return Optional_String;

   --
   -- Explicitly set the text for this token. if thencode text} is not
   -- `null`, then _#getText_ will return this value rather than
   -- extracting the text from the input.
   --
   -- * parameter text: The explicit text of the token, or `null` if the text
   -- should be obtained from the input along with the start and stop indexes
   -- of the token.
   --

   -- public
   procedure setText (This : CommonToken; text : UString);

   -- public
   function getLine (This : CommonToken) return Integer
      is (This.line);

   -- public
   function getCharPositionInLine (This : CommonToken) return Integer
      is This.charPositionInLine;

   -- public
   procedure setCharPositionInLine (This : CommonToken; charPositionInLine : Integer);

   -- public
   function getChannel (This : CommonToken) return Channel_Number
      is This.channel;

   -- public
   procedure setChannel (This : CommonToken; Channel : Channel_Number);

   -- public
   procedure setType (This : CommonToken; Token_Type : Token_Kind);

   -- public
   function getStartIndex (This : CommonToken) return Integer
      is (This.start)

   -- public
   procedure setStartIndex (This : CommonToken; start : Integer);

   -- public
   function getStopIndex (This : CommonToken) return Integer
      is (This.stop);

   -- public
   procedure setStopIndex (This : CommonToken; stop : Integer);

   -- public
   function getTokenIndex (This : CommonToken) return Integer
      is (This.index);

   -- public
   procedure setTokenIndex (This : CommonToken; index : Integer);

   -- public
   function getTokenSource (This : CommonToken) return Optional_TokenSource
      is (This.source.tokenSource);

   -- public
   function getInputStream (This : CommonToken) return Optional_CharStream
      is (This.source.stream);

   -- public
   function getTokenSourceAndStream (This : CommonToken) return TokenSourceAndStream
      is (This.source);

   -- public
   subtype Sink is Ada.Strings.Text_Buffers.Root_Buffer_Type;
   procedure Put_Image_CommonToken (S : in out Sink'Class; X : CommonToken);
   for CommonToken'Put_Image use Put_Image_CommonToken;
   function Description (This : CommonToken) return UString
      is (toString (null));

   -- public
   function toString (This : CommonToken; r : Recognizer<ATNSimulator>?) return UString;

   -- public
   function get (This : CommonToken) return Boolean;

   procedure Maybe (This : CommonToken; newValue : Boolean);

end ANTLR.Runtime.CommonToken;
