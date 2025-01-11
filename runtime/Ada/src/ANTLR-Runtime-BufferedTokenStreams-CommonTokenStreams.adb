-- €

package ANTLR.Runtime.BufferedTokenStreams.CommonTokenStreams is

   overriding
   procedure Initialize (Self : in out CommonTokenStream; tokenSource : TokenSource) is
   begin
      Super (Self).Initialize (tokenSource);
   end Initialize;

   procedure Initialize (Self : in out CommonTokenStream;
                         tokenSource : TokenSource;
                         Channel : Channel_Number) is
   begin
      Self.Initialize (tokenSource);
      self.channel := channel;
   end Initialize;

   overriding
   function LB (This : CommonTokenStream;
                k : Integer)
                return Optional_Token is
   begin
      if k = 0 or else (This.p - k) < 0 then
         return (Valid => False);
      end if;

      i : Integer := This.p;
      n : Positive := 1;
      -- find k good tokens looking backwards
      while n <= k loop
         -- skip off-channel tokens
         i := This.previousTokenOnChannel (i - 1, This.channel);
         n := @ + 1;
      end loop;
      if i < 0 then
         return (Valid => False);
      else
         return This.tokens.Element (i);
      end if;
   end LB;

   overriding
   function LT (This : CommonTokenStream;
                k : Integer)
                return Optional_Token is
   begin
      -- Ada.Wide_Wide_Text_IO.Put_Line ("enter LT (" & k'Image & ')');
      This.lazyInit;
      if k = 0 then
         return (Valid => False);
      elsif
         if k < 0 then
            return This.LB (-k);
         else
            i : Integer := This.p;
            n : Positive := 1; -- we know tokens.Element (p) is a good one
            -- find k good tokens
            while n < k loop
               -- skip off-channel tokens, but make sure to not look past EOF
               if This.sync (i + 1) then
                     i := nextTokenOnChannel (i + 1, channel);
               end if;
               n := @ + 1;
            end loop;
             -- if ( i>range ) range := i;
            return tokens.Element (i);
         end if;
      end if;
   end LT;

   function getNumberOfOnChannelTokens (This : CommonTokenStream) return Natural is
      n : Natural := 0;
   begin
      This.fill;
      for t of tokens loop
         if t.getChannel = This.channel then
               n := @ + 1;
         end if;
         exit when t.getType = EOF;
      end loop;
      return n;
   end getNumberOfOnChannelTokens;

end ANTLR.Runtime.BufferedTokenStreams.CommonTokenStreams;
