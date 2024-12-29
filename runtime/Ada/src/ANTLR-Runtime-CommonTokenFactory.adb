-- €

package body ANTLR.Runtime.CommonTokenFactory is

   procedure Initialize (Self : in out CommonTokenFactory; copyText : Boolean) is
   begin
      self.copyText := copyText;
   end Initialize;

   overriding
   procedure Initialize (Self : in out CommonTokenFactory) is
   begin
      Self.init (False);
   end Initialize;

   function create (source : TokenSourceAndStream;
                    Type : Token_Kind;
                    text : Optional_String;
                    Channel : Channel_Number;
                    start : Integer;
                    stop : Integer;
                    line : Integer;
                    charPositionInLine : Integer)
                    return Token is
      t : constant Token := CommonToken (source, type, channel, start, stop);
   begin
      t.setLine (line);
      t.setCharPositionInLine (charPositionInLine);
      text : constant Optional_Text := Maybe (text);
         if Is_Valid (text) then
            t.setText (text);
      elsif cStream : constant := source.stream, copyText then
            t.setText (try! cStream.getText (Interval.of (start, stop)));
      end if;

      return t
      exception
         when others => null;
   end create;

end ANTLR.Runtime.CommonTokenFactory;
