-- €

package ANTLR.Runtime.ATN.Transitions.AtomTransitions is

   use ANTLR.Runtime.ATN.Transitions;

   -- public final
   type AtomTransition is new ATNTransition with
   record
      --
      -- The token type or character value; or, signifies special label.
      --
      -- public
      Label : Integer; -- constant ?
   end record;

   subtype Object is AtomTransition;
   subtype Super is ATNTransition;
   type Class is access all Object;
   type Class_Wide is access all Object'Class;

   -- public
   procedure Initialize (Self : in out AtomTransition; Target : ATNState; Label : Integer);

   overriding
   -- public
   function getSerializationType (This : AtomTransition) return Integer
      is (This.Transition.ATOM);

   overriding
   -- public
   function labelIntervalSet (This : AtomTransition) return Optional_IntervalSet
      is (IntervalSet (This.Label));

   overriding
   -- public
   function matches (This : AtomTransition; Symbol : Integer; minVocabSymbol : Integer; maxVocabSymbol : Integer) return Boolean
      is (This.label = Symbol);

   -- public
   subtype Sink is Ada.Strings.Text_Buffers.Root_Buffer_Type;
   procedure Put_Image_AtomTransition (S : in out Sink'Class; X : AtomTransition);
   for AtomTransition'Put_Image use Put_Image_AtomTransition;
   function Description (This : AtomTransition) return UString
      is (This.Label'Image);

end ANTLR.Runtime.ATN.Transitions.AtomTransitions;
