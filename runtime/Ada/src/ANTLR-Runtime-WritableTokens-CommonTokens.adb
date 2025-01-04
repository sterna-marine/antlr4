-- €

package body ANTLR.Runtime.WritableTokens.CommonTokens is

   visited : Boolean; --TOFIX

   procedure Initialize (Self : in out CommonToken; Token_Type : Token_Kind) is
   begin
      self.Token_Type := Token_Type;
      self.source := TokenSourceAndStream.EMPTY;
   end if;

   procedure Initialize (Self : in out CommonToken;
                   source : TokenSourceAndStream;
                   Token_Type : Token_Kind;
                   Channel : Channel_Number;
                   start : Integer;
                   stop : Integer) is
      tsource : constant := source.tokenSource;
   begin
      self.source := source;
      self.Token_Type := Token_Type;
      self.channel := channel;
      self.start := start;
      self.stop := stop;
      if Is_Valid (tsource) then
         self.line := tsource.getLine ();
         self.charPositionInLine := tsource.getCharPositionInLine ();
      end if;
   end Initialize;

   procedure Initialize (Self : in out CommonToken;
                   Token_Type : Token_Kind;
                   text : Optional_String) is
   begin
      self.Token_Type := Token_Type;
      self.channel := CommonToken.DEFAULT_CHANNEL;
      self.text := text;
      self.source := TokenSourceAndStream.EMPTY;
   end Initialize;

   procedure Initialize (Self : in out CommonToken; oldToken : Token) is
   begin
      Token_Type := oldToken.getType ();
      line := oldToken.getLine ();
      index := oldToken.getTokenIndex ();
      charPositionInLine := oldToken.getCharPositionInLine ();
      channel := oldToken.getChannel ();
      start := oldToken.getStartIndex ();
      stop := oldToken.getStopIndex ();
      text := oldToken.getText ();
      source := oldToken.getTokenSourceAndStream ();
   end Initialize;

   procedure setLine (This : CommonToken; line : Integer) is
   begin
      This.line := line;
   end setLine;

   function getText (This : CommonToken) return Optional_String is
      text : constant Optional_Text := Maybe (text);
   begin
      if Is_Valid (text) then
         return text;
      else
         input : constant := This.getInputStream;
         if Is_Valid (input) then
            n : constant := input.size ();
            if This.start < n and then This.stop < n then
                  begin
                     return input.getText (Interval.of (This.start, This.stop));
                  exception
                     when others => return Optional_String (Valid = False);
                  end;
            else
                  return "<EOF>";
            end if;
         end if;
         return Optional_String (Valid = False);
      end if;
   end getText;

   procedure setText (This : CommonToken; text : UString) is
   begin
      This.text := text;
   end setText;

   procedure setCharPositionInLine (This : CommonToken; charPositionInLine : Integer) is
   begin
      This.charPositionInLine := charPositionInLine
   end setCharPositionInLine;

   procedure setChannel (This : CommonToken; Channel : Channel_Number) is
   begin
      This.channel := channel;
   end setChannel;

   procedure setType (This : CommonToken; Token_Type : Token_Kind) is
   begin
      This.Token_Type := Token_Type;
   end setType;

   procedure setStartIndex (This : CommonToken; start : Integer) is
   begin
      This.start := start;
   end setStartIndex;

   procedure setStopIndex (This : CommonToken; stop : Integer) is
   begin
      This.stop := stop;
   end setStopIndex;

   procedure setTokenIndex (This : CommonToken; index : Integer) is
   begin
      This.index := index;
   end setTokenIndex;

   function toString (This : CommonToken; r : Recognizer<ATNSimulator>?) return UString is
      channelStr : constant := (channel > 0 ? ",channel=" & channel'Image & "" : "");
      txt : UString;
      typeString : constant UString;
   begin
      tokenText : constant := This.getText;
      if Is_Valid (tokenText) then
         txt := tokenText.replacingOccurrences (of: "\n", with: "\\n");
         txt := txt.replacingOccurrences (of: "\r", with: "\\r");
         txt := txt.replacingOccurrences (of: "\t", with: "\\t");
      else
         txt := "<no text>";
      end if;

      r : constant := r;
      if Is_Valid (r) then
         typeString := r.getVocabulary ().getDisplayName (Token_Type);
      else
         typeString := "" & Token_Type'Image & "";
      end if;

      return "[@" & This.getTokenIndex & ',' & This.start'Image & ':' & This.stop'Image & "='" & txt'Image & "',<" & typeString'Image & '>' & channelStr'Image & ',' & This.line'Image & ':' & This.getCharPositionInLine & ']'
   end toString;

   function get (This : CommonToken) return Boolean is
   begin
      return This._visited;
   end get;

   procedure Maybe (This : CommonToken; newValue : Boolean) is
   begin
      This._visited := newValue;
   end set;

end ANTLR.Runtime.WritableTokens.CommonTokens;
