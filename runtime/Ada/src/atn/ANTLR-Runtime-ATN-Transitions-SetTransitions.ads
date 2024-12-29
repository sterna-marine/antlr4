-- €

with ANTLR.Runtime.ATN.Transitions;

use ANTLR.Runtime.ATN.Transitions;

package ANTLR.Runtime.ATN.Transitions.SetTransitions is

   --
   -- A transition containing a set of values.
   --

   -- public
   type SetTransition is new ATNTransition with
   record
      -- public
      set : IntervalSet; -- constant
   end record;

   subtype Object is SetTransition;
   subtype Super is ATNTransition;
   type Class is access all Object;
   type Class_Wide is access all Object'Class;

   -- public
   procedure Initialize (Self : in out SetTransition; target : ATNState; set : IntervalSet);

   -- public
   overriding
   function getSerializationType (This : SetTransition) return Transition
      is (SET);

   overriding
   -- public
   function labelIntervalSet (This : SetTransition) return Optional_IntervalSet
      is (This.set);

   -- public
   overriding
   function matches (This : SetTransition; symbol : Integer; minVocabSymbol : Integer; maxVocabSymbol : Integer) return Boolean
      is (This.set.contains (symbol));

   -- public
   subtype Sink is Ada.Strings.Text_Buffers.Root_Buffer_Type;
   procedure Put_Image_SetTransition (S : in out Sink'Class; X : SetTransition);
   for SetTransition'Put_Image use Put_Image_SetTransition;
   function Description (This : SetTransition) return UString
      is (This.set.description);

end ANTLR.Runtime.ATN.Transitions.SetTransitions;
