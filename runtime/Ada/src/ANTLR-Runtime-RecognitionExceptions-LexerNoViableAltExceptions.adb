-- €

package body ANTLR.Runtime.RecognitionExceptions.LexerNoViableAltExceptions is

   procedure Initialize (Self : in out LexerNoViableAltException;
                   lexer : Optional_Lexer;
                   input : CharStream;
                   startIndex : Integer;
                   deadEndConfigs : ATNConfigSet) is
      ctx : constant Optional_ParserRuleContext := (Valid => False);
   begin
      self.startIndex := startIndex;
      self.deadEndConfigs := deadEndConfigs;
      Super (Self).Initialize (lexer, input as IntStream, ctx); -- super
   end Initialize;

   function Description (This : LexerNoViableAltException) return UString is
      symbol : UString := "";
      charStream : constant := Optional_CharStream ( This.getInputStream);
   begin
      if Is_Valid (charStream)
      and then startIndex >= 0
      and then startIndex < charStream.size then
         interval : constant := Interval.Set (startIndex, startIndex);
         symbol := charStream.getText (interval); -- try!
         symbol := Utils.escapeWhitespace (symbol, False);
      end if;
      return LexerNoViableAltException'External_Tag & '(' & symbol'Image & ')'; --TOFIX
   end Description;

end ANTLR.Runtime.RecognitionExceptions.LexerNoViableAltExceptions;
