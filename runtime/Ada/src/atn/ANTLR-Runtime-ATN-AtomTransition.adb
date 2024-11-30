-- €

package body ANTLR.Runtime.ATN.AtomTransition is
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
   procedure Init (Self : in out AtomTransition; Target : ATNState; Label : Integer) is
   begin
      Self.Label := Label;
      Transition.Init (Target); -- Super
    end Init;

   override
   -- public
   function getSerializationType (This : AtomTransition) return Integer is
   begin
      return This.Transition.ATOM;
   end getSerializationType;

   override
   -- public
   function labelIntervalSet (This : AtomTransition) return Optional_IntervalSet is
   begin
      return IntervalSet (This.Label);
   end labelIntervalSet;

   override
   -- public
   function matches (This : AtomTransition; Symbol : Integer; minVocabSymbol : Integer; maxVocabSymbol : Integer) return Boolean is
   begin
      return This.label = Symbol;
   end matches;


   -- public
   function Image return UString is
      return (This.Label'Image);
   end Image;

end ANTLR.Runtime.ATN.AtomTransition;
