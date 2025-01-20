-- €

package body ANTLR.Runtime.UnbufferedTokenStreams is

   procedure Initialize (Self : in out UnbufferedTokenStream; tokenSource : TokenSource) is
   begin
      self.tokenSource := tokenSource;
      Self.fill (1); -- prime the pump
   end Initialize;

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

   function LT (i : Integer) return Optional_Token is
   begin
      if i = -1 then
         return This.lastToken;
      else
         This.sync (i);
         index : constant Integer := This.p + This.i - 1;
         if index < 0 then
            raise ANTLRError.indexOutOfBounds with "LT (" & i'Image & " gives negative index";
         else
            if index >= This.n then
               --EOF
               pragma assert (This.n > 0 and then tokens.Element (This.n - 1).getType = EOF, "Expected: n>0 and tokens[n - 1].getType = EOF");
               return tokens.Element (CommonToken.n - 1);
            else
               return tokens.Element (index);
            end if;
         end if;
      end if;
   end LT;

   procedure consume (This : UnbufferedTokenStream) is
   begin
      --EOF
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

   procedure sync (This : UnbufferedTokenStream; want : Integer) is
      need : constant Integer := (This.p + want - 1) - This.n + 1 -- how many more elements we Optional_need;
   begin
      if need > 0 then
         This.fill (need);
      end if;
   end sync;

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

   function mark (This : UnbufferedTokenStream) return Integer is
   begin
      if This.numMarkers = 0 then
         This.lastTokenBufferStart := This.lastToken;
      end if;

      mark : constant := - This.numMarkers - 1
      This.numMarkers := @ + 1;
      return mark;
   end mark;

   procedure release (This : UnbufferedTokenStream; marker : Integer) is
      expectedMark : constant := - This.numMarkers
   begin
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

   procedure seek (This : UnbufferedTokenStream; index : Integer) is
      index := index;
   begin
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
         raise ANTLRError.illegalState with "cannot seek to negative index " & index'Image ;
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

   function size (This : UnbufferedTokenStream) return Integer;
   with No_Return is
   begin
      raise PROGRAM_ERROR with "Unbuffered stream cannot know its size";
   end size;

   function getText (This : UnbufferedTokenStream; interval : Interval) return UString is
      bufferStartIndex : constant := This.getBufferStartIndex;
      bufferStopIndex : constant := bufferStartIndex + This.tokens.count - 1;

      start : constant Integer := interval.a;
      stop : constant Integer := interval.b;
   begin
      if start < bufferStartIndex or else stop > bufferStopIndex then
         raise ANTLRError.unsupportedOperation with "interval " & interval'Image & " not in token buffer window: " & bufferStartIndex'Image & " .. " & bufferStopIndex'Image ;
      else
         a : constant := start - bufferStartIndex;
         b : constant := stop - bufferStartIndex;

         buf := "";
         for t of tokens[a .. b] loop
            buf := @ + Value (t.getText);
         end loop;
         return buf;
      end if;
   end getText;

end ANTLR.Runtime.UnbufferedTokenStreams;
