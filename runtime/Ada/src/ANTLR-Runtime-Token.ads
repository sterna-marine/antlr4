-- €

package ANTLR.Runtime.Token is

   -- A token has properties: text, type, line, character position in the line
   -- (so we can ignore tabs), token channel, index, and source from which
   -- we obtained this token.
   --
   type Token_Kind is new Integer;

   subtype Token_String is UString;
   subtype hashed_Token is Ada.Containers.Hash_Type;
   subtype Token_ID is Integer;

   type TokenID_Item is record
      Token : Token_String;
      ID    : Token_ID;
   end record;

   function Hash (Key : Token_String) return Hashed_Token;
   function Equivalent_Keys (Left, Right : Token_String) return Boolean;
   function Equal (Left, Right : Token_ID) return Boolean;

   package TokenID_Container is new Ada.Containers.Map (
      Key_Type => Token_String,
      Element_Type => Token_ID,
      Hash => Hash,
      Equivalent_Keys => Equivalent_Keys,
      "=" => Equal);

   -- public
   type Token is interface and CustomStringConvertible;

   --INVALID_TYPE : constant : Token_Kind := 0;

   -- During lookahead operations, this "token" signifies we hit rule end ATN state
   -- and did not follow it despite needing to.
   --
   --EPSILON : constant : Token_Kind := -2;

   --MIN_USER_TOKEN_TYPE : constant : Token_Kind := 1;

   --EOF : constant : Token_Kind := IntStream.EOF;

   -- All tokens go to the parser (unless skip () is called in that rule);
   -- on a particular "channel".  The parser tunes to a particular channel
   -- so that whitespace etc ..  can go to the parser on a "hidden" channel.
   --
   --DEFAULT_CHANNEL : constant : Channel_Number := 0;

   -- Anything on different channel than DEFAULT_CHANNEL is not parsed
   -- by parser.
   --
   --HIDDEN_CHANNEL : constant : Channel_Number := 1;

   --
   -- This is the minimum constant value which can be assigned to a
   -- user-defined token channel.
   --
   --
   -- The non-negative numbers less than _#MIN_USER_CHANNEL_VALUE_ are
   -- assigned to the predefined channels _#DEFAULT_CHANNEL_ and
   -- _#HIDDEN_CHANNEL_.
   --
   -- * SeeAlso: org.antlr.v4.runtime.Token#getChannel ();
   --
   --MIN_USER_CHANNEL_VALUE : constant : Channel_Number := 2;

   --
   -- Get the text of the token.
   --
   function getText (This : Token) return UString_Optional;

   -- Get the token type of the token
   function getType (This : Token) return Token_Kind;

   -- The line number on which the 1st character of this token was matched,
   -- line=1 .. n
   --
   function getLine (This : Token) return Integer;

   -- The index of the first character of this token relative to the
   -- beginning of the line at which it occurs, 0 .. n-1
   --
   function getCharPositionInLine (This : Token) return Integer;

   -- Return the channel this token. Each token can arrive at the parser
   -- on a different channel, but the parser only "tunes" to a single channel.
   -- The parser ignores everything not on DEFAULT_CHANNEL.
   --
   function getChannel (This : Token) return Channel_Number;

   -- An index from 0 .. n-1 of the token object in the input stream.
   -- This must be valid in order to print token streams and
   -- use TokenRewriteStream.
   --
   -- Return -1 to indicate that this token was conjured up since
   -- it doesn't have a valid index.
   --
   function getTokenIndex (This : Token) return Integer;

   -- The starting character index of the token
   -- This method is optional; return -1 if not implemented.
   --
   function getStartIndex (This : Token) return Integer;

   -- The last character index of the token.
   -- This method is optional; return -1 if not implemented.
   --
   function getStopIndex (This : Token) return Integer;

   -- Gets the _org.antlr.v4.runtime.TokenSource_ which created this token.
   --
   function getTokenSource (This : Token) return TokenSource_Optional;

   --
   -- Gets the _org.antlr.v4.runtime.CharStream_ from which this token was derived.
   --
   function getInputStream (This : Token) return CharStream_Optional;

   function getTokenSourceAndStream (This : Token) return TokenSourceAndStream;

   function get (is_visited : Boolean);

   procedure set (is_visited : Boolean);

end ANTLR.Runtime.Token;
