-- €

with Ada.Containers;
with ANTLR.Runtime.Misc.Extensions.TokenExtensions;
with ANTLR.Runtime.Misc.Intervals;
with ANTLR.Runtime.Token_Protocol;
with ANTLR.Runtime.TokenSource_Protocol;
with ANTLR.Runtime.TokenStream_Protocol;

use Ada;
use ANTLR.Runtime.Misc.Extensions.TokenExtensions;
use ANTLR.Runtime.Misc.Intervals;
use ANTLR.Runtime.Token_Protocol;
use ANTLR.Runtime.TokenSource_Protocol;
use ANTLR.Runtime.TokenStream_Protocol;

package ANTLR.Runtime.BufferedTokenStreams is

   --
   -- This implementation of _org.antlr.v4.runtime.TokenStream_ loads tokens from a
   -- _org.antlr.v4.runtime.TokenSource_ on-demand, and places the tokens in a buffer to provide
   -- access to any previous token by index.
   --
   --
   -- This token stream ignores the value of _org.antlr.v4.runtime.Token#getChannel_. If your
   -- parser requires the token stream filter tokens to only those on a particular
   -- channel, such as _org.antlr.v4.runtime.Token#DEFAULT_CHANNEL_ or
   -- _org.antlr.v4.runtime.Token#HIDDEN_CHANNEL_, use a filtering token stream such a
   -- _org.antlr.v4.runtime.CommonTokenStream_.
   --

   type BufferedTokenStream_Base is tagged with null record;

   -- public
   type BufferedTokenStream is new BufferedTokenStream_Base and TokenStream with
   record
      --
      -- The _org.antlr.v4.runtime.TokenSource_ from which tokens for this stream are fetched.
      --
      -- internal
      tokenSource : TokenSource;

      --
      -- A collection of all tokens fetched from the token source. The list;
      -- considered a complete view of the input once _#fetchedEOF_ is set
      -- to `True`.
      --
      -- internal
      tokens : Token_List; -- := Token_Container.Empty_Vector;

      --
      -- The index into _#tokens_ of the current token (next token to
      -- _#consume_). _#tokens_`[`_#p_`]` should be
      -- _#LT LT (1)_.
      --
      -- This field is set to -1 when the stream is first constructed or when
      -- _#setTokenSource_ is called, indicating that the first token has
      -- not yet been fetched from the token source. For additional information,
      -- see the documentation of _org.antlr.v4.runtime.IntStream_ for a description of
      -- Initializing Methods.
      --
      -- internal
      p : Integer := -1;

      --
      -- Indicates whether the _org.antlr.v4.runtime.Token#EOF_ token has been fetched from
      -- _#tokenSource_ and added to _#tokens_. This field improves
      -- performance for the following cases:
      --
      -- * _#consume_: The lookahead check in _#consume_ to prevent
      -- consuming the EOF symbol is optimized by checking the values of
      -- _#fetchedEOF_ and _#p_ instead of calling _#LA_.
      --
      -- * _#fetch_: The check to prevent adding multiple EOF symbols into
      -- _#tokens_ is trivial with this field.
      --
      -- internal
      fetchedEOF : Boolean := False;
   end record;

   -- public
   procedure Initialize (Self : in out BufferedTokenStream; tokenSource : TokenSource);

   -- public
   function getTokenSource (This : BufferedTokenStream) return TokenSource
      is (This.tokenSource);

   -- public
   function index (This : BufferedTokenStream) return Integer
      is (This.p);

   -- public
   function mark (This : BufferedTokenStream) return Integer
      is (0);

   -- public
   procedure release (This : BufferedTokenStream; marker : Integer);

   -- public
   procedure reset (This : BufferedTokenStream);

   -- public
   procedure seek (This : BufferedTokenStream; index : Integer);

   -- public
   function size (This : BufferedTokenStream) return Ada.Containers.Count_Type
      is (This.tokens.Length);

   -- public
   procedure consume (This : BufferedTokenStream);
      skipEofCheck : Boolean;

   --
   -- Make sure index `i` in tokens has a token.
   --
   -- * returns: `True` if a token is located at index `i`, otherwise
   -- `False`.
   -- * seealso: #get (int i);
   --
   -- @discardableResult
   -- internal
   function sync (This : BufferedTokenStream; i : Integer) return Boolean;

   --
   -- Add `n` elements to buffer.
   --
   -- * returns: The actual number of elements added to the buffer.
   --
   -- internal
   function fetch (This : BufferedTokenStream; n : Integer) return Integer;

   -- public
   function get (This : BufferedTokenStream; i : Integer) return Token;

   --
   -- Get all tokens from start .. stop inclusively
   --
   -- public
   function get (This : BufferedTokenStream; start, stop : Integer) return Token_List;

   -- public
   function LA (This : BufferedTokenStream; i : Integer) return Integer
      is (Value (This.LT (i)).getType);

   -- internal
   function LB (This : BufferedTokenStream; k : Integer) return Optional_Token;

   -- public
   function LT (This : BufferedTokenStream; k : Integer) return Optional_Token;

   --
   -- Allowed derived classes to modify the behavior of operations which change
   -- the current stream position by adjusting the target token index of a seek
   -- operation. The default implementation simply returns `i`. If an
   -- exception is thrown in this method, the current stream index should not be
   -- changed.
   --
   -- For example, _org.antlr.v4.runtime.CommonTokenStream_ overrides this method to ensure that
   -- the seek target is always an on-channel token.
   --
   -- * parameter i: The target token index.
   -- * returns: The adjusted target token index.
   --
   -- internal
   function adjustSeekIndex (This : BufferedTokenStream;
                             i : Integer)
                             return Integer
      is (i);

   -- internal final
   procedure lazyInit (Self : BufferedTokenStream);

   -- internal
   procedure setup (This : BufferedTokenStream);

   --
   -- Reset this token stream by setting its token source.
   --
   -- public
   procedure setTokenSource (This : BufferedTokenStream; tokenSource : TokenSource);

   -- public
   function getTokens (This : BufferedTokenStream) return Token_List
      is (This.tokens);

   -- public
   function getTokens (This : BufferedTokenStream;
                       start, stop : Integer)
                       return Token_List
      is (getTokens (start, stop, types => Token_Kind_Container.Empty_Set));

   --
   -- Given a start and stop index, return a List of all tokens in
   -- the token type BitSet.  return (Valid => False) if no tokens were found.  This
   -- method looks at both on and off channel tokens.
   --
   -- public
   function getTokens (This : BufferedTokenStream;
                       start, stop : Integer;
                       types : Set_of_Token_Kind)
                       return Token_List;

   -- public
   function getTokens (This : BufferedTokenStream;
                       start, stop : Integer;
                       tType : Token_Kind)
                       return Token_List
      is (This.getTokens (start, stop, Token_Kind_Sets.To_Set (ttype)));

   --
   -- Given a starting index, return the index of the next token on channel.
   -- Return `i` if `tokens.Element (i)` is on channel. Return the index of
   -- the EOF token if there are no tokens on channel between `i` and
   -- EOF.
   --
   -- internal
   function nextTokenOnChannel (This : BufferedTokenStream;
                                i : Integer;
                                Channel : Channel_Number)
                                return Integer;

   --
   -- Given a starting index, return the index of the previous token on
   -- channel. Return `i` if `tokens.Element (i)` is on channel. Return -1
   -- if there are no tokens on channel between `i` and 0.
   --
   --
   -- If `i` specifies an index at or after the EOF token, the EOF token
   -- index is returned. This is due to the fact that the EOF token is treated
   -- as though it were on every channel.
   --
   -- internal
   function previousTokenOnChannel (This : BufferedTokenStream;
                                    i : Integer;
                                    Channel : Channel_Number)
                                    return Integer;

   --
   -- Collect all tokens on specified channel to the right of
   -- the current token up until we see a token on DEFAULT_TOKEN_CHANNEL or
   -- EOF. If channel is -1, find any non default channel token.
   --
   -- public
   function getHiddenTokensToRight (This : BufferedTokenStream;
                                    tokenIndex : Integer;
                                    Channel : Channel_Number := NON_DEFAULT_CHANNEL)
                                    return Token_List;

   --
   -- Collect all tokens on specified channel to the left of
   -- the current token up until we see a token on DEFAULT_TOKEN_CHANNEL.
   -- If channel is -1, find any non default channel token.
   --
   -- public
   function getHiddenTokensToLeft (This : BufferedTokenStream;
                                   tokenIndex : Integer;
                                   Channel : Channel_Number := NON_DEFAULT_CHANNEL)
                                   return Token_List;

   -- internal
   function filterForChannel (This : BufferedTokenStream;
                              from, to : Integer;
                              Channel : Channel_Number)
                              return Token_List;
      hidden : Token_List; -- := Token_Container.Empty_Vector;

   -- public
   function getSourceName (This : BufferedTokenStream) return UString
      is (This.tokenSource.getSourceName);

   --
   -- Get the text of all tokens in this buffer.
   --
   -- public
   function getText (This : BufferedTokenStream) return UString
      is (This.getText (Interval.Set (0, This.size - 1)));

   -- public
   function getText (This : BufferedTokenStream;
                     interval : Interval)
                     return UString;
      start : constant Integer := interval.a;

   -- public
   function getText (This : BufferedTokenStream;
                     ctx : RuleContext)
                     return UString
      is (This.getText (This : BufferedTokenStream; ctx.getSourceInterval));

   -- public
   function getText (This : BufferedTokenStream;
                     start, stop : Optional_Token)
                     return UString;

   --
   -- Get all tokens from lexer until EOF
   --
   -- public
   procedure fill (This : BufferedTokenStream);

end ANTLR.Runtime.BufferedTokenStreams;
