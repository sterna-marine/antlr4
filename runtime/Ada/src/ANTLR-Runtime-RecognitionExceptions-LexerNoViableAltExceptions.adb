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
   begin
      symbol := "";
      if charStream : constant := Optional_CharStream ( getInputStream ()), startIndex >= 0 and then startIndex < charStream.size () then
         interval : constant := Interval.of (startIndex, startIndex);
         symbol := charStream.getText (interval); -- try!
         symbol := Utils.escapeWhitespace (symbol, False);
      end if;
      return LexerNoViableAltException.self & "('" & symbol'Image & "')";
   end Description;

end ANTLR.Runtime.RecognitionExceptions.LexerNoViableAltExceptions;
