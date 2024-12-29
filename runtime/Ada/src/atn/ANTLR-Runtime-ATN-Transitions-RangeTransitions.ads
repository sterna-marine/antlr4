-- €

package ANTLR.Runtime.ATN.Transitions.RangeTransitions is

   use ANTLR.Runtime.ATN.Transitions;

   -- public final
   type RangeTransition is new ATNTransition with
   record
      -- public
      from : Integer; -- constant
      -- public
      to : Integer; -- constant
   end record;

   subtype Object is RangeTransition;
   subtype Super is ATNTransition;
   type Class is access all Object;
   type Class_Wide is access all Object'Class;

   -- public
   procedure Initialize (Self : in out RangeTransition; target : ATNState; from : Integer; to : Integer);

   -- public
   overriding
   function getSerializationType (This : RangeTransition) return Transition
      is (TRANSITION_RANGE);

   -- public
   overriding
   function labelIntervalSet (This : RangeTransition) return Optional_IntervalSet
      is (IntervalSet.of (This.from, This.to));

   -- public
   overriding
   function matches (This : RangeTransition; symbol : Integer; minVocabSymbol : Integer; maxVocabSymbol : Integer) return Boolean
      is (symbol >= This.from and then symbol <= This.to);

   -- public
   subtype Sink is Ada.Strings.Text_Buffers.Root_Buffer_Type;
   procedure Put_Image_RangeTransition (S : in out Sink'Class; X : RangeTransition);
   for RangeTransition'Put_Image use Put_Image_RangeTransition;
   function Description (This : RangeTransition) return UString
      is ("'" + UString (This.from) + "'..'" + UString (This.to) + "'");

end ANTLR.Runtime.ATN.Transitions.RangeTransitions;
