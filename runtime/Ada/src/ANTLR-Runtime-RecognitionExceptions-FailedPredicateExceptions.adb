-- €

with ANTLR.Runtime.ATN.States;
with ANTLR.Runtime.Recognizers.Parsers;
with ANTLR.Runtime.Token_Protocol;

use ANTLR.Runtime.ATN.States;
use ANTLR.Runtime.Recognizers.Parsers;
use ANTLR.Runtime.Token_Protocol;

package ANTLR.Runtime.RecognitionExceptions.FailedPredicateExceptions is

   --
   -- A semantic predicate failed during validation.  Validation of predicates
   -- occurs when normally parsing the alternative just like matching a token.
   -- Disambiguating predicate evaluation occurs when we test a predicate during
   -- prediction.
   --
   -- public
   type FailedPredicateException is new RecognitionException with
   record
      -- private let 
      ruleIndex : Integer;
      -- private let 
      predicateIndex : Integer;
      -- private let 
      predicate: Optional_UString;
   end record;

   subtype Object is FailedPredicateException;
   subtype Super is RecognitionException;
   type Class is access all Object;
   type Class_Wide is access all Object'Class;

   -- public
   procedure Initialize (Self : FailedPredicateException;
                         recognizer : Parser;
                         predicate : Optional_UString := (Valid => False);
                         message : Optional_UString := (Valid => False)) is
      s : constant ATNState := recognizer.getInterpreter.atn.states.Element (Value (recognizer.getState));
      trans : constant AbstractPredicateTransition := AbstractPredicateTransition (s.transition (0));
      predex : constant PredicateTransition := PredicateTransition (trans);
   begin
      if Is_Valid (predex) then
         self.ruleIndex := predex.ruleIndex;
         self.predicateIndex := predex.predIndex;
      else
         self.ruleIndex := 0;
         self.predicateIndex := 0;
      end if;

      self.predicate := predicate;

      Super (Self).Initialize (recognizer, Value (recognizer.getInputStream), recognizer.ctx, FailedPredicateException.formatMessage (predicate, message));
      token : constant Token := recognizer.getCurrentToken;
      if Is_Valid (token) then -- try?
         setOffendingToken (token);
      end if;
   end Initialize;

   -- public
   function getRuleIndex (This : FailedPredicateException) return Integer
      is (This.ruleIndex);

   -- public
   function getPredIndex (This : FailedPredicateException) return Integer
      is (This.predicateIndex);

   -- public
   function getPredicate (This : FailedPredicateException) return Optional_String
      is (This.predicate);

   -- private static
   function formatMessage (predicate : Optional_UString; message : Optional_String) return UString is
   begin
      if Is_Valid (message) then
         return message;
      end if;

      predstr : constant UString := Maybe (predicate, Default => "<unknown>")
      return "failed predicate: {" & predstr'Image & "}?"
   end formatMessage;

end ANTLR.Runtime.RecognitionExceptions.FailedPredicateExceptions;