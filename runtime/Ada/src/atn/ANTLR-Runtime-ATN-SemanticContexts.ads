-- €

with Ada.Containers.Hashed_Sets;
with Ada.Containers.Vectors;
with Ada.Finalization;
with Ada.Strings;
with ANTLR.Runtime.RuleContexts;
with Option;

use ANTLR.Runtime.RuleContexts;

generic
   type T is private;
package ANTLR.Runtime.ATN.SemanticContexts is


   --
   -- A tree structure used to record the semantic context in which
   -- an ATN configuration is valid.  It's either a single predicate,
   -- a conjunction `p1 and p2`, or a sum of products `p1 or p2`.
   --
   -- I have scoped the _org.antlr.v4.runtime.atn.SemanticContext.AND_, _org.antlr.v4.runtime.atn.SemanticContext.OR_, and _org.antlr.v4.runtime.atn.SemanticContext.Predicate_ subclasses of
   -- _org.antlr.v4.runtime.atn.SemanticContext_ within the scope of this outer class.
   --

   -- --------------- --
   -- SemanticContext --
   -- --------------- --
   -- public
   type SemanticContext is tagged Ada.Finalization.Controlled with null record; -- and Hashable 
   
   subtype Object is SemanticContext;
   type Class is access all Object;
   type Class_Wide is access all Object'Class;

   function "=" (Left, Right : SemanticContext) return Boolean;

   --
   -- For context independent predicates, we evaluate them without a local
   -- context (i.e., null context). That way, we can evaluate them without
   -- having to create proper rule-specific context during prediction (as
   -- opposed to the parser, which creates them naturally). In a practical
   -- sense, this avoids a cast exception from RuleContext to myruleContext.
   --
   -- For context dependent predicates, we must pass in a local context so that
   -- references such as $arg evaluate properly as _localctx.arg. We only
   -- capture context dependent predicates in the context in which we begin
   -- prediction, so we passed in the outer context here in case of context
   -- dependent predicate evaluation.
   --

   function Hash (Element : SemanticContext) return Ada.Containers.Hash_Type;

   -- public
   procedure hash (This : SemanticContext; hasher : in out Hasher)
   with No_Return;

   function Equivalent_Elements (Left, Right : SemanticContext) return Boolean;

   subtype Sink is Ada.Strings.Text_Buffers.Root_Buffer_Type;
   procedure Put_Image_SemanticContext (S : in out Sink'Class; X : SemanticContext);
   for SemanticContext'Put_Image use Put_Image_SemanticContext;
   -- public
   function Description (This : SemanticContext) return UString;
   with No_Return;

   -- -------------------- --
   -- SemanticContext_List --
   -- -------------------- --
   package SemanticContext_Container is new Ada.Containers.Vectors
     (Index_Type   => Natural,
      Element_Type => SemanticContext,
      "="          => "=");
   subtype SemanticContext_List is SemanticContext_Container.Vector;

   subtype Sink is Ada.Strings.Text_Buffers.Root_Buffer_Type;
   procedure Put_Image_SemanticContext_List (S : in out Sink'Class; X : SemanticContext_List);
   for SemanticContext_List'Put_Image use Put_Image_SemanticContext_List;
   -- public
   overriding
   function Description (This : SemanticContext_List) return UString;

   -- ----------------------- --
   -- Set_Of_SemanticContexts --
   -- ----------------------- --
   -- public
   package SemanticContext_Sets is new Ada.Containers.Hashed_Sets (
      Element_Type => SemanticContext,
      Hash => Hash,
      Equivalent_Elements => Equivalent_Elements,
      "=" => "=");
   subtype Set_Of_SemanticContexts is SemanticContext_Sets.Set;

   -- -------------------- --
   -- SemanticContext_List --
   -- -------------------- --
   package SemanticContext_Container is new Ada.Containers.Vectors (
      Index_Type => Natural,
      Element_Type => SemanticContext,
      "=" => "=");
   subtype SemanticContext_List is SemanticContext_Container.Vector;

   -- ---------------------- --
   -- Option_SemanticContext --
   -- ---------------------- --
   package Option_SemanticContext is new Option (SemanticContext);
   subtype Optional_SemanticContext is Option_SemanticContext.Optional;

   function "=" (Left, Right : Optional_SemanticContext) return Boolean
      is (if Is_Valid (Left) and then Is_Valid (Right)
            then return Value (Left) = Value (Right)
            else return False);

   package Optional_SemanticContext_Container is new Ada.Containers.Vectors (
      Index_Type => Natural,
      Element_Type => Optional_SemanticContext,
      "=" => "=");
   subtype Optional_SemanticContext_List is Optional_SemanticContext_Container.Vector;

   -- ------------ --
   -- Recognizer_T --
   -- ------------ --
   package Recognizers_T is new Recognizers (T);
   subtype Recognizer_T is Recognizers_T.Recognizer;

   -- public
   function eval (This : SemanticContext;
                  parser : Recognizer_T;
                  parserCallStack : RuleContext)
                  return Boolean;
   with No_Return;

   --
   -- Evaluate the precedence predicates for the context and reduce the result.
   --
   -- * parameter parser: The parser instance.
   -- * parameter parserCallStack:
   -- * returns: The simplified semantic context after precedence predicates are
   -- evaluated, which will be one of the following values.
   -- * _#NONE_: if the predicate simplifies to `True` after
   -- precedence predicates are evaluated.
   -- * `null`: if the predicate simplifies to `False` after
   -- precedence predicates are evaluated.
   -- * `this`: if the semantic context is not changed as a result of
   -- precedence predicate evaluation.
   -- * A non-`null` _org.antlr.v4.runtime.atn.SemanticContext_: the new simplified
   -- semantic context after precedence predicates are evaluated.
   --
   -- public
   function evalPrecedence (This : SemanticContext; parser : Recognizer_T; parserCallStack : RuleContext) return Optional_SemanticContext;

   -- ----- --
   -- Empty --
   -- ----- --
   -- public
   type Empty is new SemanticContext with
   record
      --
      -- The default _org.antlr.v4.runtime.atn.SemanticContext_, which is semantically equivalent to
      -- a predicate of the form `{True?}.
      --
      -- public static
      Instance : constant Empty := This.Empty;
   end record;

   -- public
   overriding
   procedure hash (This : Empty; hasher : in out Hasher) is null;
      
   subtype Sink is Ada.Strings.Text_Buffers.Root_Buffer_Type;
   procedure Put_Image_Empty (S : in out Sink'Class; X : Empty);
   for Empty'Put_Image use Put_Image_Empty;
   -- public
   overriding
   function Description (This : Empty) return UString
      is ("{True}?");

   -- --------- --
   -- Predicate --
   -- --------- --
   -- public
   type Predicate is new SemanticContext with
   record
      -- public
      ruleIndex : Integer; -- constant
      -- public
      predIndex : Integer; -- constant
      -- public
      isCtxDependent : Boolean; -- constant
      -- e.g., $i ref in pred
   end record;

   overriding
   -- public
   overriding
   procedure Initialize (Self : in out Predicate);

   -- public
   procedure Initialize (Self : in out Predicate;
                   ruleIndex : Integer;
                   predIndex : Integer
                   isCtxDependent  : Boolean);

   overriding
   -- public
   function eval (This : Predicate;
                  parser : Recognizer_T;
                  parserCallStack : RuleContext)
                  return Boolean;

   -- public
   overriding
   procedure hash (This : Predicate; hasher : in out Hasher);

   subtype Sink is Ada.Strings.Text_Buffers.Root_Buffer_Type;
   procedure Put_Image_Predicate (S : in out Sink'Class; X : Predicate);
   for Predicate'Put_Image use Put_Image_Predicate;
   overriding
   -- public
   function Description (This : Predicate) return UString
      is ('{' & ruleIndex'Image & ':' & predIndex'Image & "}?");

   -- ------------------- --
   -- PrecedencePredicate --
   -- ------------------- --
   -- public
   type PrecedencePredicate is new SemanticContext with
   record
      -- public
      precedence : Integer; -- constant
   end record;

   package PrecedencePredicate_Container is new Ada.Containers.Vectors (
      Index_Type => Natural,
      Element_Type => PrecedencePredicate,
      "=" => "=");
   subtype PrecedencePredicate_List is PrecedencePredicate_Container.Vector;

   function filterPrecedencePredicates (collection : in out Set_Of_SemanticContexts) return PrecedencePredicate_Container.Vector;

   overriding
   procedure Initialize (Self : in out PrecedencePredicate);

   -- public
   procedure Initialize (Self : in out PrecedencePredicate; precedence : Integer);

   overriding
   -- public
   function eval (This : PrecedencePredicate;
                  parser : Recognizer_T;
                  parserCallStack : RuleContext)
                  return Boolean
      is (parser.precpred (parserCallStack, This.precedence));

   overriding
   -- public
   function evalPrecedence (This : PrecedencePredicate;
                            parser : Recognizer_T;
                            parserCallStack : RuleContext)
                            return Optional_SemanticContext;

   -- public
   overriding
   procedure hash (This : PrecedencePredicate; hasher : in out Hasher);

   subtype Sink is Ada.Strings.Text_Buffers.Root_Buffer_Type;
   procedure Put_Image_PrecedencePredicate (S : in out Sink'Class; X : PrecedencePredicate);
   for PrecedencePredicate'Put_Image use Put_Image_PrecedencePredicate;
   -- public
   overriding
   function Description (This : PrecedencePredicate) return UString
      is ('{' & This.precedence'Image & ">=prec}?");

   -- -------- --
   -- Operator --
   -- -------- --
   --
   -- This is the base class for semantic context "operators", which operate on
   -- a collection of semantic context "operands".
   --

   -- public
   type Operator is new SemanticContext with null record;
      --
      -- Gets the operands for the semantic context operator.
      --
      -- * returns: a collection of _org.antlr.v4.runtime.atn.SemanticContext_ operands for the
      -- operator.
      --

   -- public
   function getOperands (This : Operator) return SemanticContext_Array;
   with No_Return;

   -- ------------ --
   -- AND Operator --
   -- ------------ --
   --
   -- A semantic context which is True whenever none of the contained contexts
   -- is False.
   --

   -- public
   type AND is new Operator with
   record
      -- public
      opnds : SemanticContext_List; -- constant
      --TOFIX opnds : Set_Of_SemanticContexts;
   end record;

   package Option_AND is new Option (AND);
   subtype Optional_AND is Option_AND.Optional;

   -- public
   procedure Initialize (Self : in out AND; a, b : SemanticContext);

   overriding
   -- public
   function getOperands (This : AND) return SemanticContext_Container.Vector
      is (This.opnds);

   -- public
   overriding
   procedure hash (This : AND; hasher: in out Hasher);
   
   --
   -- The evaluation of predicates by this context is short-circuiting, but
   -- unordered.
   --
   overriding
   -- public
   function eval (This : AND; parser : Recognizer_T; parserCallStack : RuleContext) return Boolean;

   overriding
   -- public
   function evalPrecedence (This : AND; parser : Recognizer_T; parserCallStack : RuleContext) return Optional_SemanticContext;

   -- ----------- --
   -- OR Operator --
   -- ----------- --
   --
   -- A semantic context which is True whenever at least one of the contained
   -- contexts is True.
   --

   -- public
   type OR is new Operator with
   record
      -- public final
      opnds: SemanticContext_List
      --TOFIX opnds : Set_Of_SemanticContexts;
   end record;

   package Option_OR is new Option (OR);
   subtype Optional_OR is Option_OR.Optional;

   -- public
   procedure Initialize (Self : in out OR; a, b : SemanticContext);

   overriding
   -- public
   function getOperands (This : OR) return SemanticContext_Container.Vector
      is This.opnds

   -- public
   overriding
   procedure hash (This : OR; hasher: in out Hasher)

   --
   -- The evaluation of predicates by this context is short-circuiting, but
   -- unordered.
   --
   overriding
   -- public
   function eval (This : OR; parser : Recognizer_T; parserCallStack : RuleContext) return Boolean;
   
   overriding
   -- public
   function evalPrecedence (This : OR; parser : Recognizer_T; parserCallStack : RuleContext) return Optional_SemanticContext;

   -- --------- --

   -- public static
   function "and" (a, b : Optional_SemanticContext) return SemanticContext;

   --
   --
   -- * seealso: org.antlr.v4.runtime.atn.ParserATNSimulator#getPredsForAmbigAlts
   --
   -- public static
   function "or" (a, b : Optional_SemanticContext) return SemanticContext;
   
   -- private static
   function filterPrecedencePredicates (collection : in out Set_Of_SemanticContexts) return PrecedencePredicate_Container.Vector;

   -- public
   function "=" (Lhs, Rhs : SemanticContext) return Boolean;

   -- public
   function "=" (lhs, rhs : SemanticContext.Predicate) return Boolean;

   -- public
   function "=" (lhs, rhs : SemanticContext.PrecedencePredicate) return Boolean;


   -- public
   function "=" (lhs, rhs : SemanticContext_List) return Boolean;

   -- public
   function "=" (lhs, rhs : SemanticContext_List) return Boolean;

end ANTLR.Runtime.ATN.SemanticContexts;