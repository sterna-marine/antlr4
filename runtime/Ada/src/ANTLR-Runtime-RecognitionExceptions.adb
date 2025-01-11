-- €

package ANTLR.Runtime.RecognitionExceptions is

   procedure Initialize (Self : in out RecognitionException;
                         recognizer : Optional_RecognizerProtocol;
                         input : IntStream;
                         ctx : Optional_ParserRuleContext;
                         message : Optional_UString := (Valid => False)) is
   begin
      self.recognizer := recognizer;
      self.input := input;
      self.ctx := ctx;
      self.message := message;
      if Is_Valid (recognizer) then
         self.offendingState := recognizer.getState;
      end if;
   end Initialize;

   procedure setOffendingState (This : RecognitionException; offendingState : State) is
   begin
      This.offendingState := offendingState;
   end setOffendingState;

   function getExpectedTokens (This : RecognitionException) return Optional_IntervalSet is
   begin
      if Is_Valid (This.recognizer) then
         return This.recognizer.getATN.getExpectedTokens (This.offendingState, Value (This.ctx)); -- try?
      else
         return (Valid => False);
      end if;
   end getExpectedTokens;

   procedure clearInputStream (This : RecognitionException) is
   begin
      This.input := (Valid => False);
   end clearInputStream;

   procedure setOffendingToken (This : RecognitionException; offendingToken : Token) is
   begin
      This.offendingToken := offendingToken;
   end setOffendingToken;

   procedure clearRecognizer (This : RecognitionException) is
   begin
      This.recognizer := (Valid => False);
   end clearRecognizer;

end ANTLR.Runtime.RecognitionExceptions;
