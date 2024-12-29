-- €

package body ANTLR.Runtime.ATN.Transitions.AtomTransitions is
--
-- TODO: make all transitions sets? no, should remove set edges
--

   procedure Initialize (Self : in out AtomTransition; Target : ATNState; Label : Integer) is
   begin
      Self.Label := Label;
      Transition.Init (Target); -- Super
    end Initialize;

end ANTLR.Runtime.ATN.Transitions.AtomTransitions;
