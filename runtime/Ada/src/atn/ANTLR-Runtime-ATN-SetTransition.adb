-- €

package body ANTLR.Runtime.ATN.SetTransition is

   -- TODO (sam): should we really allow null here?
   procedure Initialize (Self : in out SetTransition; target : ATNState; set : IntervalSet) is
   begin
      self.set := set;
      ATNTransition.init (Self, target); -- super
   end Initialize;

end ANTLR.Runtime.ATN.SetTransition;
