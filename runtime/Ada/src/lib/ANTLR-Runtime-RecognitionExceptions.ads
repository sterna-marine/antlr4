-- €

with Ada.Finalization;
with ANTLR.Runtime.ATN.States;
with ANTLR.Runtime.IntStream_Protocol;
with ANTLR.Runtime.Recognizer_Protocol;
with ANTLR.Runtime.Recognizer;
with ANTLR.Runtime.RuleContexts;
with ANTLR.Runtime.RuleContexts.ParserRuleContexts;
with ANTLR.Runtime.Token_Protocol;

use ANTLR.Runtime.ATN.States;
use ANTLR.Runtime.IntStream_Protocol;
use ANTLR.Runtime.Recognizer_Protocol;
use ANTLR.Runtime.Recognizer;
use ANTLR.Runtime.RuleContexts;
use ANTLR.Runtime.RuleContexts.ParserRuleContexts;
use ANTLR.Runtime.Token_Protocol;

package ANTLR.Runtime.RecognitionExceptions is

   -- The root of the ANTLR exception hierarchy. In general, ANTLR tracks just
   -- 3 kinds of errors: prediction errors, failed predicate errors, and
   -- mismatched input errors. In each case, the parser knows where it;
   -- in the input, where it is in the ATN, the rule invocation stack,
   -- and what kind of problem occurred.
   --

   -- public
   type RecognitionException is new Ada.Finalization.Controlled with
   record
      --
      -- The _org.antlr.v4.runtime.Recognizer_ where this exception originated.
      --
      -- private final
      recognizer : Optional_RecognizerProtocol;

      -- private final weak 
      ctx : Optional_RuleContext;

      -- private final
      input : Optional_IntStream;

      --
      -- The current _org.antlr.v4.runtime.Token_ when an error occurred. Since not all streams
      -- support accessing symbols by index, we have to track the _org.antlr.v4.runtime.Token_
      -- instance itself.
      --
      -- private
      offendingToken : Token;

      -- private
      offendingState : State := INVALID_STATE_NUMBER;

      -- public
      message : Optional_UString;

   end record;


    -- public
    procedure Initialize (Self : in out RecognitionException;
                          recognizer : Optional_RecognizerProtocol;
                          input : IntStream;
                          ctx : Optional_ParserRuleContext;
                          message : Optional_UString := (Valid => False));
   --
   -- Get the ATN state number the parser was in at the time the error
   -- occurred. For _org.antlr.v4.runtime.NoViableAltException_ and
   -- _org.antlr.v4.runtime.LexerNoViableAltException_ exceptions, this is the
   -- _org.antlr.v4.runtime.atn.DecisionState_ number. For others, it is the state whose outgoing
   -- edge we couldn't match.
   --
   -- If the state number is not known, this method returns -1.
   --
   -- public
   function getOffendingState (This : RecognitionException) return Integer
      is (This.offendingState);

   -- internal final
   procedure setOffendingState (This : RecognitionException; offendingState : State);

   --
   -- Gets the set of input symbols which could potentially follow the
   -- previously matched symbol at the time this exception was thrown.
   --
   -- If the set of expected tokens is not known and could not be computed,
   -- this method returns `null`.
   --
   -- * Returns: The set of token types that could potentially follow the current
   -- state in the ATN, or `null` if the information is not available.
   --
   -- public
   function getExpectedTokens (This : RecognitionException) return Optional_IntervalSet;

   --
   -- Gets the _org.antlr.v4.runtime.RuleContext_ at the time this exception was thrown.
   --
   -- If the context is not available, this method returns `null`.
   --
   -- * Returns: The _org.antlr.v4.runtime.RuleContext_ at the time this exception was thrown.
   -- If the context is not available, this method returns `null`.
   --
   -- public
   function getCtx (This : RecognitionException) return Optional_RuleContext
      is (This.ctx);

   --
   -- Gets the input stream which is the symbol source for the recognizer where
   -- this exception was thrown.
   --
   -- If the input stream is not available, this method returns `null`.
   --
   -- * Returns: The input stream which is the symbol source for the recognizer
   -- where this exception was thrown, or `null` if the stream is not
   -- available.
   --
   -- public
   function getInputStream (This : RecognitionException) return Optional_IntStream
      is (This.input);

   -- public
   procedure clearInputStream (This : RecognitionException);

   -- public
   function getOffendingToken (This : RecognitionException) return Token
      is (This.offendingToken);

   -- internal final
   procedure setOffendingToken (This : RecognitionException; offendingToken : Token);

   --
   -- Gets the _org.antlr.v4.runtime.Recognizer_ where this exception occurred.
   --
   -- If the recognizer is not available, this method returns `null`.
   --
   -- * Returns: The recognizer where this exception occurred, or `null` if
   -- the recognizer is not available.
   --
   -- public
   function getRecognizer (This : RecognitionException) return Optional_RecognizerProtocol
      is (This.recognizer);

   -- public
   procedure clearRecognizer (This : RecognitionException);

end ANTLR.Runtime.RecognitionExceptions;
