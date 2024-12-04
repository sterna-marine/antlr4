-- €

package ANTLR.Runtime.ATN.AtomTransition is
-- 
-- TODO: make all transitions sets? no, should remove set edges
-- 

   -- public final
   type AtomTransition is new Transition and CustomStringConvertible with 
   record
      -- 
      -- The token type or character value; or, signifies special label.
      -- 
      -- public
      Label : Integer; -- constant ?
   end record;

   -- public 
   procedure Init (Self : in out AtomTransition; Target : ATNState; Label : Integer);

   override
   -- public
   function getSerializationType (This : AtomTransition) return Integer
      is (This.Transition.ATOM);

   override
   -- public
   function labelIntervalSet (This : AtomTransition) return Optional_IntervalSet
      is (IntervalSet (This.Label));

   override
   -- public
   function matches (This : AtomTransition; Symbol : Integer; minVocabSymbol : Integer; maxVocabSymbol : Integer) return Boolean
      is (This.label = Symbol);

   -- public
   function Image return UString
      is (This.Label'Image);

end ANTLR.Runtime.ATN.AtomTransition;
