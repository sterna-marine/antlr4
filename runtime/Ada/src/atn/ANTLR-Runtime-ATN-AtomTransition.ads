-- €

package ANTLR.Runtime.ATN.AtomTransition is
--
-- TODO: make all transitions sets? no, should remove set edges
--

   -- public final
   type AtomTransition is new ATNTransition and CustomStringConvertible with
   record
      --
      -- The token type or character value; or, signifies special label.
      --
      -- public
      Label : Integer; -- constant ?
   end record;

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

end ANTLR.Runtime.ATN.AtomTransition;
