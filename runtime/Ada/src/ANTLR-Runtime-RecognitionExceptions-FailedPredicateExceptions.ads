-- €

with ANTLR.Runtime.ATN.States;
with ANTLR.Runtime.Parsers;
with ANTLR.Runtime.Token_Protocol;

use ANTLR.Runtime.ATN.States;
use ANTLR.Runtime.Parsers;
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
                         message : Optional_UString := (Valid => False));

   -- public
   function getRuleIndex (This : FailedPredicateException) return Integer
      is (This.ruleIndex);

   -- public
   function getPredIndex (This : FailedPredicateException) return Integer
      is (This.predicateIndex);

   -- public
   function getPredicate (This : FailedPredicateException) return Optional_UString
      is (This.predicate);

   -- private static
   function formatMessage (predicate : Optional_UString; message : Optional_UString) return UString;

end ANTLR.Runtime.RecognitionExceptions.FailedPredicateExceptions;