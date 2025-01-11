-- €

with ANTLR.Runtime.Parsers;
with ANTLR.Runtime.Misc.Exceptions;
with ANTLR.Runtime.RecognitionExceptions;
with ANTLR.Runtime.RuleContexs.ParserRuleContexs;
with ANTLR.Runtime.RecognitionExceptions.InputMismatchExceptions;
with ANTLR.Runtime.Token_Protocol;

use ANTLR.Runtime.DefaultErrorStrategies;
use ANTLR.Runtime.Misc.Exceptions;
use ANTLR.Runtime.Parsers;
use ANTLR.Runtime.RecognitionExceptions;
use ANTLR.Runtime.RuleContexs.ParserRuleContexs;
use ANTLR.Runtime.RecognitionExceptions.InputMismatchExceptions;
use ANTLR.Runtime.Token_Protocol;

package ANTLR.Runtime.DefaultErrorStrategies.BailErrorStrategies is

   --
   --
   -- This implementation of _org.antlr.v4.runtime.ANTLRErrorStrategy_ responds to syntax errors
   -- by immediately canceling the parse operation with a
   -- _org.antlr.v4.runtime.misc.ParseCancellationException_. The implementation ensures that the
   -- _org.antlr.v4.runtime.ParserRuleContext#exception_ field is set for all parse tree nodes
   -- that were not completed prior to encountering the error.
   --
   -- This error strategy is useful in the following scenarios.
   --
   -- * __Two-stage parsing:__ This error strategy allows the first
   -- stage of two-stage parsing to immediately terminate if an error is
   -- encountered, and immediately fall back to the second stage. In addition to
   -- avoiding wasted work by attempting to recover from errors here, the empty
   -- implementation of _org.antlr.v4.runtime.BailErrorStrategy#sync_ improves the performance of
   -- the first stage.
   --
   -- * __Silent validation:__ When syntax errors are not being
   -- reported or logged, and the parse result is simply ignored if errors occur,
   -- the _org.antlr.v4.runtime.BailErrorStrategy_ avoids wasting work on recovering from errors
   -- when the result will be ignored either way.
   --
   -- `myparser.setErrorHandler (new This.BailErrorStrategy);`
   --
   -- * seealso: org.antlr.v4.runtime.Parser#setErrorHandler (org.antlr.v4.runtime.ANTLRErrorStrategy);
   --
   --
   -- open
   type BailErrorStrategy is new DefaultErrorStrategy with null record;

   -- public
   overriding
   procedure Initialize (Self : in out BailErrorStrategy);

   --
   -- Instead of recovering from exception `e`, re-throw it wrapped
   -- in a _org.antlr.v4.runtime.misc.ParseCancellationException_ so it is not caught by the
   -- rule function catches.  Use _Exception#getCause_ to get the
   -- original _org.antlr.v4.runtime.RecognitionException_.
   --
   -- open
   overriding
   procedure recover (This : BailErrorStrategy;
                      recognizer : Parser;
                      e : RecognitionException);

   --
   -- Make sure we don't attempt to recover inline; if the parser
   -- successfully recovers, it won't raise an exception.
   --
   -- open
   overriding
   function recoverInline (This : BailErrorStrategy; recognizer : Parser) return Token;

   --
   -- Make sure we don't attempt to recover from problems in subrules.
   --
   -- open
   overriding
   procedure sync (This : BailErrorStrategy; recognizer : Parser);

end ANTLR.Runtime.DefaultErrorStrategies.BailErrorStrategies;
