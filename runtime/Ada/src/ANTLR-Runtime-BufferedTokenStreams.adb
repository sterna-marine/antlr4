-- €

with Aspect;
with Ada.Wide_Wide_Text_IO;

use Ada;
use Aspect;

package body ANTLR.Runtime.BufferedTokenStreams is

   procedure Initialize (Self : in out BufferedTokenStream; tokenSource : TokenSource) is
   begin
      self.tokenSource := tokenSource;
   end Initialize;

   procedure release (This : BufferedTokenStream; marker : Integer) is
   begin
      null;
      -- no resources to release
   end release;

   procedure reset (This : BufferedTokenStream) is
   begin
      This.seek (0);
   end reset;

   procedure seek (This : BufferedTokenStream; index : Integer) is
   begin
      This.lazyInit;
      This.p := This.adjustSeekIndex (index);
   end seek;

   procedure consume (This : BufferedTokenStream) is
      skipEofCheck : Boolean;
   begin
      if This.p >= 0 then
         if This.fetchedEOF then
               -- the last token in tokens is EOF. skip check if p indexes any
               -- fetched token except the last.
               skipEofCheck := This.p < This.tokens.Length - 1;
         else
               -- no EOF token in tokens. skip check if p indexes a fetched token.
               skipEofCheck := This.p < This.tokens.Length;
         end if;
      else
         -- not yet initialized
         skipEofCheck := False;
      end if;

      if not skipEofCheck and then This.LA (1) = EOF then
         raise ANTLRError.illegalState 
            with "cannot consume EOF";
      else
         if This.sync (This.p + 1) then
            This.p := This.adjustSeekIndex (This.p + 1);
         end if;
      end if;
   end consume;

   function sync (This : BufferedTokenStream; i : Integer) return Boolean is
   begin
      pragma assert (i >= 0, "Expected: i>=0");
      n : constant := i -  This.tokens.Length + 1; -- how many more elements we need?
      if Is_Active (Aspect.DEBUG) then
         Wide_Wide_Text_IO.Put_Line ("sync (" & i'Image & ") needs " & n'Image);
      end if;
      if n > 0 then
         fetched : constant Integer := This.fetch (n);
         return fetched >= n;
      else
         return True;
      end if;
   end sync;

   function fetch (This : BufferedTokenStream; n : Integer) return Integer is
   begin
      if This.fetchedEOF then
         return 0;
      else
         for i in 0 .. n - 1 loop
            t : constant := tokenSource.nextToken;
            wt : constant Optional_WritableToken := Maybe (t);
            if Is_Valid (wt) then
                  wt.setTokenIndex (This.tokens.Length);
            end if;

            This.tokens.append (t);
            if t.getType = EOF then
                  This.fetchedEOF := True;
                  return i + 1;
            end if;
         end loop;
         return n;
      end if;
   end fetch;

   function get (This : BufferedTokenStream; i : Integer) return Token is
   begin
      if not This.tokens.Has_Element (This.tokens.To_Cursor (i)) then
         raise ANTLRError.indexOutOfBounds
            with "token index " & i'Image & " out of range 0 .. " & (This.tokens.Length - 1)'Image;
      else
         return This.tokens.Element (i);
      end if;
   end get;

   function get (This : BufferedTokenStream; start, stop : Integer) return Token_List is
      subset : Token_List; -- := Token_Container.Empty_Vector;
   begin
      Some_stop : Integer := stop;
      if This.start < 0 or else This.stop < 0 then
         return (Valid => False);
      end if;
      This.lazyInit;
      if This.stop >= This.tokens.Length then
         Some_stop := This.tokens.Length - 1;
      end if;

      for i in This.start .. Some_stop loop
         t : constant Token := This.tokens.Element (i);
         exit when t.getType = EOF;
         subset.append (t);
      end if;
      return subset;
   end get;

   function LB (This : BufferedTokenStream; k : Integer) return Optional_Token is
   begin
      if (This.p - k) < 0 then
         return (Valid => False);
      else
         return This.tokens.Element (This.p - k);
      end if;
   end LB;

   function LT (This : BufferedTokenStream; k : Integer) return Optional_Token is
   begin
      This.lazyInit;
      if k = 0 then
         return (Valid => False);
      else
         if k < 0 then
            return This.LB (-k);
         end if;

         i : constant := This.p + k - 1
         This.sync (i);
         if i >= This.tokens.Length then
            -- return EOF token
            -- EOF must be last token
            return Value (This.tokens.last);
         else
            return This.tokens.Element (i);
         end if;
      end if;
   end LT;

   procedure lazyInit (Self : BufferedTokenStream) is
   begin
      if This.p = -1 then
         This.setup;
      end if;
   end lazyInit;

   procedure setup (This : BufferedTokenStream) is
   begin
      This.sync (0);
      This.p := This.adjustSeekIndex (0);
   end setup;

   procedure setTokenSource (This : BufferedTokenStream; tokenSource : TokenSource) is
   begin
      This.tokenSource := tokenSource;
      This.tokens.Clear;
      This.p := -1;
      This.fetchedEOF := False;
   end setTokenSource;

   function getTokens (This : BufferedTokenStream;
                       start, stop : Integer;
                       types : Set_of_Token_Kind)
                       return Token_List is
   begin
      This.lazyInit;
      if not This.tokens.Has_Element (This.tokens.To_Cursor (start))
      or else not This.tokens.Has_Element (This.tokens.To_Cursor (stop)) then
         raise ANTLRError.indexOutOfBounds
            with "start " & start'Image & " or stop " & stop'Image & " not in 0 .. " & (This.tokens.Length - 1)'Image;
      elsif start > stop then
            return (Valid => False);
      else
         filteredTokens := Token_Container.Empty_Vector;
         for i in start .. stop loop
            t : constant := This.tokens.Element (i);
            if types.Is_Empty or types.Contains (t.getType) then --TOFIX
               filteredTokens.append (t);
            end if;
         end loop;

         if filteredTokens.Is_Empty then
            return (Valid => False);
         else
            return filteredTokens;
         end if;
      end if;
   end getTokens;

   function getTokens (This : BufferedTokenStream;
                       start, stop : Integer;
                       tType : Token_Kind)
                       return Token_List
      is (This.getTokens (start, stop, Token_Kind_Sets.To_Set (ttype)));

   function nextTokenOnChannel (This : BufferedTokenStream;
                                i : Integer;
                                Channel : Channel_Number)
                                return Integer is
      Actual_i : Integer := i;
   begin
      This.sync (i);
      if i >= This.size then
         return This.size - 1;
      else
         token := This.tokens.Element (i);
         while token.getChannel /= channel loop
            if token.getType = EOF then
               return i;
            else
               Actual_i := @ + 1;
               This.sync (Some_i);
               token := This.tokens.Element (Actual_i);
            end if;
         end loop;
         return Actual_i;
      end if;
   end nextTokenOnChannel;

   function previousTokenOnChannel (This : BufferedTokenStream;
                                    i : Integer;
                                    Channel : Channel_Number)
                                    return Integer is
      Actual_i : Integer := i;
   begin
      This.sync (i);
      if i >= This.size then
         -- the EOF token is on every channel
         return This.size - 1;
      else
         while Actual_i >= 0 loop
            token : constant := This.tokens.Element (Actual_i);
            if token.getType = EOF or else token.getChannel = channel then
               return Actual_i;
            else
               Actual_i := @ - 1;
            end if;
         end loop;
         return Actual_i;
      end if;
   end previousTokenOnChannel;

   function getHiddenTokensToRight (This : BufferedTokenStream;
                                    tokenIndex : Integer;
                                    Channel : Channel_Number := NON_DEFAULT_CHANNEL)
                                    return Token_List is
   begin
      This.lazyInit;
      if not This.tokens.Has_Element (This.tokens.To_Cursor (tokenIndex)) then
         raise ANTLRError.indexOutOfBounds
            with tokenIndex'Image & " not in 0 .. " & (This.tokens.Length - 1)'Image;
      else
         nextOnChannel : constant Token := nextTokenOnChannel (tokenIndex + 1, DEFAULT_TOKEN_CHANNEL);
         from : constant Integer := tokenIndex + 1;
         to : Integer;
         -- if none onchannel to right, nextOnChannel=-1 so set to := last token
         if nextOnChannel = NON_DEFAULT_CHANNEL then
            to := This.size - 1;
         else
            to := nextOnChannel;
         end if;
         return filterForChannel (from, to, channel);
      end if;
   end getHiddenTokensToRight;

   function getHiddenTokensToLeft (This : BufferedTokenStream;
                                   tokenIndex : Integer;
                                   Channel : Channel_Number := NON_DEFAULT_CHANNEL)
                                   return Token_List is
   begin
      This.lazyInit;
      if not This.tokens.Has_Element (This.tokens.To_Cursor (tokenIndex)) then
         raise ANTLRError.indexOutOfBounds
            with tokenIndex'Image & " not in 0 .. " & (This.tokens.Length - 1)'Image;
      else
         if tokenIndex = 0 then
            -- obviously no tokens can appear before the first token
            return (Valid => False);
         else
            prevOnChannel : constant Token := previousTokenOnChannel (tokenIndex - 1, DEFAULT_TOKEN_CHANNEL);
            if prevOnChannel = tokenIndex - 1 then
               return (Valid => False);
            else
               -- if none onchannel to left, prevOnChannel=-1 then from=0
               from : constant := prevOnChannel + 1;
               to : constant := tokenIndex - 1;
               return filterForChannel (from, to, channel);
            end if;
         end if;
      end if;
   end getHiddenTokensToLeft;

   function filterForChannel (This : BufferedTokenStream;
                              from, to : Integer;
                              Channel : Channel_Number)
                              return Token_List is
      hidden : Token_List; -- := Token_Container.Empty_Vector;
   begin
      for t of This.tokens[from .. to] loop
         if channel = NON_DEFAULT_CHANNEL then
            if t.getChannel /= DEFAULT_TOKEN_CHANNEL then
               hidden.append (t);
            end if;
         else
            if t.getChannel = channel then
               hidden.append (t);
            end if;
         end if;
      end loop;
      if hidden.Is_Empty then
         return Token_Container.Empty_Vector;
      else
         return hidden;
      end if;
   end filterForChannel;

   function getText (This : BufferedTokenStream;
                     interval : Interval)
                     return UString is
      start : constant Integer := interval.a;
   begin
      if start < 0 then
         return "";
      else
         This.fill;
         stop : constant := min (This.tokens.Length, interval.b + 1);
         buf := "";
         for t of tokens [start .. stop - 1] loop
            exit when t.getType = EOF;
            buf := @ + Value (t.getText);
         end loop;
         return buf;
      end if;
   end getText;

   function getText (This : BufferedTokenStream;
                     start, stop : Optional_Token)
                     return UString is
   begin
      if Is_Valid (start) and then Is_Valid (stop) then
         return This.getText (Interval.Set (start.getTokenIndex, stop.getTokenIndex));
      else
         return "";
      end if;
   end getText;

   procedure fill (This : BufferedTokenStream) is
      blockSize : constant Integer := 1_000;
   begin
      This.lazyInit;
      loop --TOFIX
         fetched : constant Integer := This.fetch (blockSize);
         if fetched < blockSize then
            return;
         end if;
      end loop;
   end fill;

end ANTLR.Runtime.BufferedTokenStreams;
