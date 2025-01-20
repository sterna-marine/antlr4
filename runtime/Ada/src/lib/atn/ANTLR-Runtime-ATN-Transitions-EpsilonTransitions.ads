-- €

with Ada.Strings;
with ANTLR.Runtime.ATN.States;

use ANTLR.Runtime.ATN.Transitions;
use ANTLR.Runtime.ATN.States;

package ANTLR.Runtime.ATN.Transitions.EpsilonTransitions is

   -- public final
   type EpsilonTransition is new ATNTransition with
   record
      -- private
      outermostPrecedenceReturnInside : Integer := -1; --  constant
   end record;

   subtype Object is EpsilonTransition;
   subtype Super is ATNTransition;
   type Class is access all Object;
   type Class_Wide is access all Object'Class;

   -- public convenience
   overriding
   procedure Initialize (Self : in out EpsilonTransition;
                   target : ATNState);

   -- public
   procedure Initialize (Self : in out EpsilonTransition;
                   target : ATNState;
                   outermostPrecedenceReturn : Integer);

   --
   -- * returns: the rule index of a precedence rule for which this transition is
   -- returning from, where the precedence value is 0; otherwise, -1.
   --
   -- * seealso: org.antlr.v4.runtime.atn.ATNConfig#isPrecedenceFilterSuppressed;
   -- * seealso: org.antlr.v4.runtime.atn.ParserATNSimulator#applyPrecedenceFilter (org.antlr.v4.runtime.atn.ATNConfigSet);
   --

   -- public
   function outermostPrecedenceReturn (This : EpsilonTransition) return Integer
      is (This.outermostPrecedenceReturnInside);

   overriding
   -- public
   function getSerializationType (This : EpsilonTransition) return Integer
      is (This.Transition.EPSILON);

   overriding
   -- public
   function isEpsilon (This : EpsilonTransition) return Boolean
      is (True);

   overriding
   -- public
   function matches (symbol : Integer; minVocabSymbol : Integer; maxVocabSymbol : Integer) return Boolean
      is (False);

   subtype Sink is Ada.Strings.Text_Buffers.Root_Buffer_Type;
   procedure Put_Image_EpsilonTransition (S : in out Sink'Class; X : EpsilonTransition);
   for EpsilonTransition'Put_Image use Put_Image_EpsilonTransition;
   -- public
   function Description (This : EpsilonTransition) return UString
      is ("epsilon");

end ANTLR.Runtime.ATN.Transitions.EpsilonTransitions;
