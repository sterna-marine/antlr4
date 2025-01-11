-- €

with ANTLR.Runtime.ATN.ConfigSets;
with ANTLR.Runtime.IntStream_Protocol;
with ANTLR.Runtime.Recognizers.Parsers;
with ANTLR.Runtime.RuleContexts.ParserRuleContexts;
with ANTLR.Runtime.Token_Protocol;

use ANTLR.Runtime.ATN.ConfigSets;
use ANTLR.Runtime.IntStream_Protocol;
use ANTLR.Runtime.RecognitionExceptions;
use ANTLR.Runtime.Recognizers.Parsers;
use ANTLR.Runtime.RuleContexts.ParserRuleContexts;
use ANTLR.Runtime.Token_Protocol;

package ANTLR.Runtime.RecognitionExceptions.NoViableAltExceptions is

   -- Indicates that the parser could not decide which of two or more paths
   -- to take based upon the remaining input. It tracks the starting token
   -- of the offending input and also knows where the parser was
   -- in the various paths when the error. Reported by This.reportNoViableAlternative;
   --

   -- public
   type NoViableAltException is new RecognitionException with
   record -- Which configurations did we at input.index that couldn't match input.LT (1)?;

      -- private
      deadEndConfigs : Optional_ATNConfigSet; -- constant

      -- The token object at the start index; the input stream might
      -- not be buffering tokens so get a reference to it. (At the
      -- time the error occurred, of course the stream needs to keep a
      -- buffer all of the tokens but later we might not have access to those.);
      --
      -- private
      startToken : Token; -- constant
   end record;

    -- public convenience
    procedure Initialize (Self : in out NoViableAltException; recognizer : Parser);

    -- public
    procedure Initialize (Self : in out NoViableAltException;
                          recognizer : Optional_Parser;
                          input : IntStream;
                          startToken : Token;
                          offendingToken : Optional_Token;
                          deadEndConfigs : Optional_ATNConfigSet;
                          ctx : Optional_ParserRuleContext);

   -- public
   function getStartToken (This : NoViableAltException) return Token
      is (This.startToken);

   -- public
   function getDeadEndConfigs (This : NoViableAltException) return Optional_ATNConfigSet
      is (This.deadEndConfigs);

end ANTLR.Runtime.RecognitionExceptions.NoViableAltExceptions;
