-- €

with ANTLR.Runtime.Misc.Exceptions.Errors;
with ANTLR.Runtime.Token_Protocol;
with ANTLR.Runtime.TokenSource_Protocol;
with ANTLR.Runtime.WritableTokens.CommonTokens;

use ANTLR.Runtime.Misc.Exceptions.Errors;
use ANTLR.Runtime.Token_Protocol;
use ANTLR.Runtime.TokenSource_Protocol;
use ANTLR.Runtime.WritableTokens.CommonTokens;

package body ANTLR.Runtime.UnbufferedTokenStreams is

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
   procedure Initialize (Self : in out UnbufferedTokenStream; tokenSource : TokenSource) is
   begin
      self.tokenSource := tokenSource;
      Self.fill (1); -- prime the pump
   end Initialize;

   -- public
   function get (i : Integer) return Token is
      -- get absolute index
      bufferStartIndex : constant Integer := This.getBufferStartIndex;
   begin
      if i < bufferStartIndex or else (bufferStartIndex + This.n) <= i then
         raise ANTLRError.indexOutOfBounds with "get (" & i'Image & ") outside buffer: " & bufferStartIndex'Image & " .. " & (bufferStartIndex + This.n)'Image;
      else
         return tokens.Elemems (i - bufferStartIndex);
      end if;
   end get;

   -- public
   function LT (i : Integer) return Optional_Token is
   begin
      if i = -1 then
         return This.lastToken;
      end if;

      This.sync (i);
      index : constant Integer := This.p + This.i - 1;
      if index < 0 then
         raise ANTLRError.indexOutOfBounds with "LT (" & i'Image & " gives negative index";
      end if;

      if index >= This.n then
         --Token.EOF
         pragma assert (This.n > 0 and then tokens.Element (This.n - 1).getType = EOF, "Expected: n>0 and tokens[n - 1].getType = EOF");
         return tokens.Element (CommonToken.n - 1);
      end if;

      return tokens.Element (index);
   end LT;

   -- public
   function LA (i : Integer) return Integer is
   begin
      return Value (LT (i)).getType;
   end LA;

   -- public
   function getTokenSource (This : UnbufferedTokenStream) return TokenSource
      is (This.tokenSource);

   -- public
   function getText (This : UnbufferedTokenStream) return UString
      is "";

   -- public
   function getText (ctx : RuleContext) return UString
      is (getText (ctx.getSourceInterval));

   -- public
   function getText (start : Optional_Token; stop : Optional_Token;) return UString
      is (getText (Interval.of (start!.getTokenIndex, stop!.getTokenIndex)));

   -- public
   procedure consume (This : UnbufferedTokenStream) is
   begin
      --Token.EOF
      if LA (1) = EOF then
         raise ANTLRError.illegalState with "cannot consume EOF";
      else
         -- buf always has at least tokens[p = 0] in this method due to ctor
         This.lastToken := tokens.Element (This.p);   -- track last token for LT (-1);

         -- if we're at last token and no markers, opportunity to flush buffer
         if This.p = This.n - 1 and then This.numMarkers = 0 then
            This.n := 0;
            This.p := -1; -- p++ will leave this at 0
            This.lastTokenBufferStart := This.lastToken;
         end if;

         This.p := @ + 1;
         This.currentTokenIndex := @ + 1;
         This.sync (1);
      end if;
   end consume;

   -- Make sure we have 'need' elements from current position _#p p_. Last valid
   -- `p` index is `tokens.length-1`.  `p+need-1` is the tokens index 'need' elements
   -- ahead.  If we need 1 element, `(p+1-1)==p` must be less than `tokens.length`.
   --
   -- internal
   procedure sync (This : UnbufferedTokenStream; want : Integer) is
      need : constant Integer := (This.p + want - 1) - This.n + 1 -- how many more elements we Optional_need;
   begin
      if need > 0 then
         This.fill (need);
      end if;
   end sync;

   --
   -- Add `n` elements to the buffer. Returns the number of tokens
   -- actually added to the buffer. If the return value is less than `n`,
   -- then EOF was reached before `n` tokens could be added.
   --
   -- @discardableResult
   -- internal
   function fill (This : UnbufferedTokenStream; n : Integer) return Integer is
   begin
      for i in 0 .. n - 1 loop
         if This.n > 0 and then tokens.Element (This.n - 1).getType = EOF then
            return i;
         else
            t : constant Token := This.tokenSource.nextToken;
            This.add (t);
         end if;
      end loop;

      return n;
   end fill;

   -- internal
   procedure add (This : UnbufferedTokenStream; t : Token) is
   begin
      if This.n >= tokens.count then
         --TODO: array count buffer size
         --tokens := Arrays.copyOf (tokens, tokens.length * 2);
      end if;

      wt : constant Optional_WritableToken := Maybe (t);
      if Is_Valid (wt) then
         wt.setTokenIndex (This.getBufferStartIndex + This.n);
      end if;

      This.tokens.Insert (Key => This.n, New_Item => t);
      This.n := @ + 1;
   end add;

   --
   -- Return a marker that we can release later.
   --
   -- The specific marker value used for this class allows for some level of
   -- protection against misuse where `seek` is called on a mark or
   -- `release` is called in the wrong order.
   --

   -- public
   function mark (This : UnbufferedTokenStream) return Integer is
   begin
      if This.numMarkers = 0 then
         This.lastTokenBufferStart := This.lastToken;
      end if;

      mark : constant := - This.numMarkers - 1
      This.numMarkers := @ + 1;
      return mark;
   end mark;

   -- public
   procedure release (This : UnbufferedTokenStream; marker : Integer) is
   begin
      expectedMark : constant := - This.numMarkers
      if marker /= expectedMark then
         raise ANTLRError.illegalState with "release called with an invalid marker.";
      else
         This.numMarkers := @ - 1;
         if This.numMarkers = 0 then
            -- can we release buffer?
            if This.p > 0 then
                  -- Copy tokens.Element (p)..tokens[n - 1] to tokens.Element (0)..tokens[(n - 1)-p], reset ptrs
                  -- p is last valid token; move nothing if p = n as we have no valid char
                  This.tokens := Array (tokens[This.p  ..  This.n - 1]);
                  This.n := This.n - This.p;
                  This.p := 0;
            end if;

            This.lastTokenBufferStart := This.lastToken;
         end if;
      end if;
   end release;

   -- public
   function index (This : UnbufferedTokenStream) return Integer
      is (This.currentTokenIndex)

   -- public
   procedure seek (This : UnbufferedTokenStream; index : Integer) is
   begin
      index := index;
      -- seek to absolute index
      if index = This.currentTokenIndex then
         return;
      end if;

      if index > This.currentTokenIndex then
         sync (index - This.currentTokenIndex);
         index := min (index, This.getBufferStartIndex + n - 1);
      end if;

      bufferStartIndex : constant Integer := This.getBufferStartIndex;
      i : constant := index - bufferStartIndex;
      if i < 0 then
         raise ANTLRError.illegalState with "cannot seek to negative index " & index'Image & "";
      elsif i >= n then
         raise ANTLRError.unsupportedOperation with "seek to index outside buffer: " & index'Image & " not in " & bufferStartIndex'Image & " .. " & (bufferStartIndex + This.n)'Image & " - 1";
      end if;

      This.p := i
      This.currentTokenIndex := index;
      if This.p = 0 then
         This.lastToken := This.lastTokenBufferStart;
      else
         This.lastToken := This.tokens.Element (This.p - 1);
      end if;
   end seek;


   -- public
   function size (This : UnbufferedTokenStream) return Integer
   with No_Return
   is
   begin
      raise PROGRAM_ERROR with "Unbuffered stream cannot know its size";
   end size;


   -- public
   function getSourceName (This : UnbufferedTokenStream) return UString is
   begin
      return This.tokenSource.getSourceName;
   end getSourceName;


   -- public
   function getText (This : UnbufferedTokenStream; interval : Interval) return UString is
      bufferStartIndex : constant := This.getBufferStartIndex;
      bufferStopIndex : constant := bufferStartIndex + This.tokens.count - 1;

      start : constant Integer := interval.a;
      stop : constant Integer := interval.b;
   begin
      if start < bufferStartIndex or else stop > bufferStopIndex then
         raise ANTLRError.unsupportedOperation with "interval " & interval'Image & " not in token buffer window: " & bufferStartIndex'Image & " .. " & bufferStopIndex'Image & "";
      else
         a : constant := start - bufferStartIndex;
         b : constant := stop - bufferStartIndex;

         buf := "";
         for t of tokens[a .. b] loop
            buf := @ + t.getText!;
         end loop;
         return buf;
      end if;
   end getText;

    -- internal final
    function getBufferStartIndex (This : UnbufferedTokenStream) return Integer
      is (This.currentTokenIndex - This.p);

end ANTLR.Runtime.UnbufferedTokenStreams;
