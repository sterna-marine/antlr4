-- €

package body ANTLR.Runtime.ListTokenSources is

   procedure Initialize (Self : in out ListTokenSource; tokens : Token_List) is
   begin
      Self.Initialize (tokens, (Valid => False));
   end Initialize;

   procedure Initialize (Self : in out ListTokenSource;
                        tokens : Token_List;
                        sourceName : Optional_String) is
   begin
      self.tokens := tokens;
      self.sourceName := sourceName;
   end Initialize;

   function getCharPositionInLine (This : ListTokenSource) return Integer is
   begin
      if This.i < This.tokens.Length then
         return This.tokens.Element (This.i).getCharPositionInLine;
      elsif Is_Valid (This.eofToken) then
         return This.eofToken.getCharPositionInLine;
      elsif not This.tokens.Is_Empty then
         -- have to calculate the result from the line/column of the previous
         -- token, along with the text of the token.
         lastToken : constant Token := This.tokens.Last_Element;

         tokenText : constant Optional_Token := Maybe (lastToken.getText);
            if Is_Valid (tokenText) then
               if lastNewLine : constant := tokenText.lastIndex ("\n") then --TOFIX
                  return tokenText.distance (from => lastNewLine, to => tokenText.endIndex) - 1;
               end if;
         end if;
         return (lastToken.getCharPositionInLine +
                  lastToken.getStopIndex -
                  lastToken.getStartIndex + 1);
      else
         -- only reach this if tokens is empty, meaning EOF occurs at the first
         -- position in the input
         return 0;
      end if;
   end getCharPositionInLine;

   function nextToken (This : ListTokenSource) return Token is
   begin
      if This.i >= This.tokens.Length then
         if not Is_Valid (This.eofToken) then
            start := -1;
            if This.tokens.Length > 0 then
               previousStop : constant := This.tokens.Element (This.tokens.Length - 1).getStopIndex;
               if previousStop /= -1 then
                  start := previousStop + 1;
               end if;
            end if;

            stop : constant := max (-1, start - 1);
            source : constant := TokenSourceAndStream (This, getInputStream);
            eofToken := This.factory.create (
                  source => source,
                  Token_Kind => EOF,
                  text => "EOF",
                  Channel => DEFAULT_CHANNEL,
                  start => start,
                  stop => stop,
                  line => getLine,
                  charPositionInLine => getCharPositionInLine);
         end if;

         return Value (eofToken);
      end if;

      t : constant := This.tokens.Element (i);
      if This.i = (This.tokens.Length - 1) and then t.getType = EOF then
         This.eofToken := t;
      end if;

      This.i := @ + 1;
      return t;
   end nextToken;

   function getLine (This : ListTokenSource) return Integer is
   begin
      if This.i < This.tokens.Length then
         return This.tokens.Element (This.i).getLine;
      elsif Is_Valid (This.eofToken) then
         return This.eofToken.getLine;
      elsif not This.tokens.Is_Empty then
         -- have to calculate the result from the line/column of the previous
         -- token, along with the text of the token.
         lastToken : constant Token := This.tokens.Last_Element;
         line := lastToken.getLine;

         tokenText : constant Optional_Token := Maybe (lastToken.getText);
         if Is_Valid (tokenText) then
            for c of tokenText loop
               if c = "\n" then
                  line := @ + 1;
               end if;
            end loop;
         end if;

         -- if no text is available, assume the token did not contain any newline characters.
         return line;
      else
         -- only reach this if tokens is empty, meaning EOF occurs at the first
         -- position in the input
         return 1;
      end if;
   end getLine;

   function getInputStream (This : ListTokenSource) return Optional_CharStream is
   begin
      if This.i < tokens.count then
         return This.tokens.Element (i).getInputStream;
      elsif Is_Valud (eofToken) then
         return This.eofToken.getInputStream;
      elsif not This.tokens.Is_Empty then
         return This.tokens.Last_Element.getInputStream;
      end getInputStream;

      -- no input stream information is available
      return (Valid => False);
   end getInputStream;

   function getSourceName (This : ListTokenSource) return UString is
   begin
      if Is_Valid (This.sourceName) then
         return This.sourceName;
      else
         inputStream : constant := This.getInputStream
         if Is_Valid (inputStream) then
            return inputStream.getSourceName;
         else
            return "List";
         end if;
      end if;
   end getSourceName;

   procedure setTokenFactory (This : ListTokenSource; factory : TokenFactory) is
   begin
      This.factory := factory;
   end setTokenFactory;

end ANTLR.Runtime.ListTokenSources;
