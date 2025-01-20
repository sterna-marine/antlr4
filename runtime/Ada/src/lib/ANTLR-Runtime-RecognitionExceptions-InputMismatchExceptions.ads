-- €

with ANTLR.Runtime.ATN.States;
with ANTLR.Runtime.RecognitionExceptions;
with ANTLR.Runtime.Recognizer.Parsers;
with ANTLR.Runtime.RuleContexts.ParserRuleContexts;

use ANTLR.Runtime.ATN.States;
use ANTLR.Runtime.RecognitionExceptions;
use ANTLR.Runtime.Recognizer.Parsers;
use ANTLR.Runtime.RuleContexts.ParserRuleContexts;

package ANTLR.Runtime.RecognitionExceptions.InputMismatchExceptions is

   --
   -- This signifies any kind of mismatched input exceptions such as
   -- when the current input does not match the expected token.
   --

   -- public
   type InputMismatchException is new RecognitionException with null record;

   subtype Object is InputMismatchException;
   subtype Super is RecognitionException;
   type Class is access all Object;
   type Class_Wide is access all Object'Class;

   -- public
   procedure Initialize (Self : in out InputMismatchException;
                         recognizer : Parser;
                         state: Integer := INVALID_STATE_NUMBER;
                         ctx: Optional_ParserRuleContext := (Valid => False));
end ANTLR.Runtime.RecognitionExceptions.InputMismatchExceptions;
