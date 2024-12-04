-- €

package body ANTLR.Runtime.ATN.AtomTransition is
-- 
-- TODO: make all transitions sets? no, should remove set edges
-- 

   procedure Init (Self : in out AtomTransition; Target : ATNState; Label : Integer) is
   begin
      Self.Label := Label;
      Transition.Init (Target); -- Super
    end Init;

end ANTLR.Runtime.ATN.AtomTransition;
