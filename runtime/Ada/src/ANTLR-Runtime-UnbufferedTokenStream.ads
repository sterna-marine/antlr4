-- €

with ANTLR.Runtime.Misc.Exceptions.Errors;
with ANTLR.Runtime.Token_Protocol;
with ANTLR.Runtime.TokenSource_Protocol;
with ANTLR.Runtime.TokenStream_Protocol;
with ANTLR.Runtime.WritableTokens.CommonTokens;

use ANTLR.Runtime.Misc.Exceptions.Errors;
use ANTLR.Runtime.Token_Protocol;
use ANTLR.Runtime.TokenSource_Protocol;
use ANTLR.Runtime.TokenStream_Protocol;
use ANTLR.Runtime.WritableTokens.CommonTokens;

package ANTLR.Runtime.UnbufferedTokenStreams is

   -- public
   type UnbufferedTokenStream is new TokenStream with
   record
      -- internal
      tokenSource : TokenSource;

      --
      -- A moving window buffer of the data being scanned. While there's a marker,
      -- we keep adding to buffer. Otherwise, _#consume This.consume_ resets so
      -- we start filling at index 0 again.
      --
      -- internal
      tokens : Token_List;

      --
      -- The number of tokens currently in `self.tokens`.
      --
      -- This is not the buffer capacity, that's `self.tokens.count`.
      --
      -- internal
      n : Integer := 0;

      --
      -- `0 .. n - 1` index into `self.tokens` of next token.
      --
      -- The `LT (1)` token is `tokens.Element (p)`. If `p = n`, we are
      -- out of buffered tokens.
      --
      -- internal
      p : Integer := 0;

      --
      -- Count up with _#mark This.mark_ and down with
      -- _#release This.release_. When we `release` the last mark,
      -- `numMarkers` reaches 0 and we reset the buffer. Copy
      -- `tokens.Element (p)..tokens[n - 1]` to `tokens.Element (0)..tokens[(n - 1)-p]`.
      --
      -- internal
      numMarkers : Integer := 0;

      --
      -- This is the `LT (-1)` token for the current position.
      --
      -- internal
      lastToken : Token;

      --
      -- When `numMarkers > 0`, this is the `LT (-1)` token for the
      -- first token in _#tokens_. Otherwise, this is `null`.
      --
      -- internal
      lastTokenBufferStart : Token;

      --
      -- Absolute token index. It's the index of the token about to be read via
      -- `LT (1)`. Goes from 0 to the number of tokens in the entire stream,
      -- although the stream size is unknown before the end is reached.
      --
      -- This value is used to set the token indexes if the stream provides tokens
      -- that implement _org.antlr.v4.runtime.WritableToken_.
      --
      -- internal
      currentTokenIndex : Integer := 0;
   end record;

   -- public
   procedure Initialize (Self : in out UnbufferedTokenStream; tokenSource : TokenSource);

   -- public
   function get (i : Integer) return Token;

   -- public
   function LT (i : Integer) return Optional_Token;

   -- public
   function LA (i : Integer) return Integer
      is (Value (LT (i)).getType);

   -- public
   function getTokenSource (This : UnbufferedTokenStream) return TokenSource
      is (This.tokenSource);

   -- public
   function getText (This : UnbufferedTokenStream) return UString
      is ("");

   -- public
   function getText (ctx : RuleContext) return UString
      is (getText (ctx.getSourceInterval));

   -- public
   function getText (start : Optional_Token; stop : Optional_Token) return UString
      is (getText (Interval.of (Value (start).getTokenIndex, Value (stop).getTokenIndex)));

   -- public
   procedure consume (This : UnbufferedTokenStream);

   -- Make sure we have 'need' elements from current position _#p p_. Last valid
   -- `p` index is `tokens.length-1`.  `p+need-1` is the tokens index 'need' elements
   -- ahead.  If we need 1 element, `(p+1-1)==p` must be less than `tokens.length`.
   --
   -- internal
   procedure sync (This : UnbufferedTokenStream; want : Integer);

   --
   -- Add `n` elements to the buffer. Returns the number of tokens
   -- actually added to the buffer. If the return value is less than `n`,
   -- then EOF was reached before `n` tokens could be added.
   --
   -- @discardableResult
   -- internal
   function fill (This : UnbufferedTokenStream; n : Integer) return Integer;

   -- internal
   procedure add (This : UnbufferedTokenStream; t : Token);

   --
   -- Return a marker that we can release later.
   --
   -- The specific marker value used for this class allows for some level of
   -- protection against misuse where `seek` is called on a mark or
   -- `release` is called in the wrong order.
   --

   -- public
   function mark (This : UnbufferedTokenStream) return Integer;

   -- public
   procedure release (This : UnbufferedTokenStream; marker : Integer);

   -- public
   function index (This : UnbufferedTokenStream) return Integer
      is (This.currentTokenIndex);

   -- public
   procedure seek (This : UnbufferedTokenStream; index : Integer);

   -- public
   function size (This : UnbufferedTokenStream) return Integer
   with No_Return;

   -- public
   function getSourceName (This : UnbufferedTokenStream) return UString
      is (This.tokenSource.getSourceName);

   -- public
   function getText (This : UnbufferedTokenStream; interval : Interval) return UString;

    -- internal final
    function getBufferStartIndex (This : UnbufferedTokenStream) return Integer
      is (This.currentTokenIndex - This.p);

end ANTLR.Runtime.UnbufferedTokenStreams;
