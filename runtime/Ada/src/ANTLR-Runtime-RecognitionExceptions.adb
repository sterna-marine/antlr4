-- €

with Ada.Finalization;
with ANTLR.Runtime.ATN.States;
with ANTLR.Runtime.IntStream_Protocol;
with ANTLR.Runtime.Recognizer_Protocol;
with ANTLR.Runtime.Recognizers;
with ANTLR.Runtime.RuleContexts;
with ANTLR.Runtime.RuleContexts.ParserRuleContexts;
with ANTLR.Runtime.Token_Protocol;

use ANTLR.Runtime.ATN.States;
use ANTLR.Runtime.IntStream_Protocol;
use ANTLR.Runtime.Recognizer_Protocol;
use ANTLR.Runtime.Recognizers;
use ANTLR.Runtime.RuleContexts;
use ANTLR.Runtime.RuleContexts.ParserRuleContexts;
use ANTLR.Runtime.Token_Protocol;

package ANTLR.Runtime.RecognitionExceptions is

   -- The root of the ANTLR exception hierarchy. In general, ANTLR tracks just
   -- 3 kinds of errors: prediction errors, failed predicate errors, and
   -- mismatched input errors. In each case, the parser knows where it is
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
                          message : Optional_UString := (Valid => False)) {
        self.recognizer := recognizer
        self.input := input
        self.ctx := ctx
        self.message := message
        if recognizer : constant := recognizer then
            self.offendingState := recognizer.getState;
        end if;
    end if;

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
    function getOffendingState (This : RecognitionException) return Integer is
begin
        return offendingState;
    end if;

    -- internal final
    procedure setOffendingState (offendingState : ATStates.State) is
    begin
        self.offendingState := offendingState
    end if;

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
    function getExpectedTokens (This : RecognitionException) return Optional_IntervalSet is
   begin
        if recognizer : constant := recognizer then
            return recognizer.getATN.getExpectedTokens (offendingState, ctx!); -- try?
        end if;
        return (Valid => False);
    end if;

    --
    -- Gets the _org.antlr.v4.runtime.RuleContext_ at the time this exception was thrown.
    --
    -- If the context is not available, this method returns `null`.
    --
    -- * Returns: The _org.antlr.v4.runtime.RuleContext_ at the time this exception was thrown.
    -- If the context is not available, this method returns `null`.
    --
    -- public
    function getCtx (This : RecognitionException) return Optional_RuleContext is
   begin
        return ctx;
    end if;

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
    function getInputStream (This : RecognitionException) return Optional_IntStream is
   begin
        return input;
    end if;

    -- public
    procedure clearInputStream (This : RecognitionException) is
begin
        input := (Valid => False);
    end if;

    -- public
    function getOffendingToken (This : RecognitionException) return Token is
begin
        return offendingToken;
    end if;

    -- internal final
    procedure setOffendingToken (offendingToken : Token) is
    begin
        self.offendingToken := offendingToken
    end if;

    --
    -- Gets the _org.antlr.v4.runtime.Recognizer_ where this exception occurred.
    --
    -- If the recognizer is not available, this method returns `null`.
    --
    -- * Returns: The recognizer where this exception occurred, or `null` if
    -- the recognizer is not available.
    --
    -- public
    function getRecognizer (This : RecognitionException) return Optional_RecognizerProtocol is
   begin
        return recognizer;
    end if;

    -- public
    procedure clearRecognizer (This : RecognitionException) is
begin
        self.recognizer := (Valid => False);
    end if;
end if;
