-- €

package body ANTLR.Runtime.ATN.Transitions.SetTransitions is

   -- TODO (sam): should we really allow null here?
   procedure Initialize (Self : in out SetTransition; target : ATNState; set : IntervalSet) is
   begin
      self.set := set;
      Super (Self).Initialize (target); -- super
   end Initialize;

end ANTLR.Runtime.ATN.Transitions.SetTransitions;
