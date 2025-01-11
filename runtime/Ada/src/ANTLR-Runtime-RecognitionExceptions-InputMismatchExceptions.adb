-- €

with ANTLR.Runtime.ATN.States;
with ANTLR.Runtime.RecognitionExceptions;
with ANTLR.Runtime.Recognizer.Parsers;
with ANTLR.Runtime.RuleContexts.ParserRuleContexts;

use ANTLR.Runtime.ATN.States;
use ANTLR.Runtime.RecognitionExceptions;
use ANTLR.Runtime.Recognizer.Parsers;
use ANTLR.Runtime.RuleContexts.ParserRuleContexts;

package body ANTLR.Runtime.RecognitionExceptions.InputMismatchExceptions is

   procedure Initialize (Self : in out InputMismatchException;
                         recognizer : Parser;
                         state: Integer := ATNState.INVALID_STATE_NUMBER;
                         ctx: Optional_ParserRuleContext := (Valid => False)) is
      bestCtx : constant ParserRuleContext := Value (ctx, Default => recognizer.ctx);
   begin
      Super (Self).Initialize (recognizer, Value (recognizer.getInputStream), bestCtx);
      token : constant := recognizer.getCurrentToken;
      if Is_Valid (token) then -- try?
         This.setOffendingToken (token);
      elsif (state /= INVALID_STATE_NUMBER) then
         This.setOffendingState (state);
      end if;
   end Initialize;

end ANTLR.Runtime.RecognitionExceptions.InputMismatchExceptions;
