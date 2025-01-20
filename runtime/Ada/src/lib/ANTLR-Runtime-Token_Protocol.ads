-- €

with Ada.Containers;
with Ada.Containers.Hashed_Maps;
with Ada.Containers.Hashed_Sets;
with ANTLR.Runtime.Misc.Extensions.TokenExtensions;

use ANTLR.Runtime.Misc.Extensions.TokenExtensions;

package ANTLR.Runtime.Token_Protocol is

   -- A token has properties: text, type, line, character position in the line
   -- (so we can ignore tabs), token channel, index, and source from which
   -- we obtained this token.
   --
   type Token_Kind is new Integer range -2 .. Integer'Last;

   -- During lookahead operations, this "token" signifies we hit rule end ATN state
   -- and did not follow it despite needing to.
   --
   EPSILON : constant Token_Kind := -2;

   -- public static
   EOF : constant Token_Kind := -1;
   -- EOF : constant Token_Kind := EOF;

   INVALID_TYPE : constant Token_Kind := 0;

   MIN_USER_TOKEN_TYPE : constant Token_Kind := 1;

   type User_Token_Kind is new Integer range MIN_USER_TOKEN_TYPE .. Integer'Last;

   function Hash (Element : Token_Kind) return Ada.Containers.Hash_Type;
   function Equivalent_Elements (Left, Right : Token_Kind) return Boolean
      is (Hash (Left) = Hash (Right));

   package Token_Kind_Container is new Ada.Containers.Hashed_Sets (
      Element_Type  => Token_Kind,
      Hash => Hash,
      Equivalent_Elements => Equivalent_Elements,
      "=" => "=");
   subtype Set_of_Token_Kind is Token_Kind_Container.Set;

   -- All tokens go to the parser (unless This.skip is called in that rule);
   -- on a particular "channel".  The parser tunes to a particular channel
   -- so that whitespace etc ..  can go to the parser on a "hidden" channel.
   --

   subtype Token_String is UString;
   subtype Token_ID is Integer;

   type TokenID_Item is record
      Token : Token_String;
      ID    : Token_ID;
   end record;

   function "=" (Left, Right : Token_ID) return Boolean;

   function Hash (Key : Token_String) return Ada.Containers.Hash_Type;
   function Equivalent_Keys (Left, Right : Token_String) return Boolean;

   package TokenID_Container is new Ada.Containers.Hashed_Maps (
      Key_Type => Token_String,
      Element_Type => Token_ID,
      Hash => Hash,
      Equivalent_Keys => Equivalent_Keys,
      "=" => "=");
   subtype TokenID_Map is TokenID_Container.Map;

   -- public
   type Token is interface;

   -- public
   function "=" (Left, Right : Token) return Boolean;

   -- public
   procedure hash (This : Token; hasher : in out Hasher);

   package Token_Container is new Ada.Containers.Vectors (
      Index_Type => Natural,
      Element_Type => Token,
      "=" => "=");
   subtype Token_list is Token_Container.Vector;

   --
   -- Get the text of the token.
   --
   function getText (This : Token) return Optional_UString;

   -- Get the token type of the token
   function getType (This : Token) return Token_Kind;

   -- The line number on which the 1st character of this token was matched,
   -- line=1 .. n
   --
   function getLine (This : Token) return Integer;

   -- The index of the first character of this token relative to the
   -- beginning of the line at which it occurs, 0 .. n - 1
   --
   function getCharPositionInLine (This : Token) return Integer;

   -- Return the channel this token. Each token can arrive at the parser
   -- on a different channel, but the parser only "tunes" to a single channel.
   -- The parser ignores everything not on DEFAULT_CHANNEL.
   --
   function getChannel (This : Token) return Channel_Number;

   -- An index from 0 .. n - 1 of the token object in the input stream.
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

   protected Visited is
      function Was_Visited return Boolean; --TOFIX for This : Token 
      procedure Set_as_Visited (is_visited : Boolean); --TOFIX for This : Token 
   private  
      Has_Been_Visited : Boolean := False;
   end Visited;

end ANTLR.Runtime.Token_Protocol;
