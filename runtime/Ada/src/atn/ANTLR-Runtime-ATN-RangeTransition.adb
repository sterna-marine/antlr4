-- €

package body ANTLR.Runtime.ATN.RangeTransition is

   procedure Initialize (Self : in out RangeTransition; target : ATNState; from : Integer; to : Integer) is
   begin
      self.from := from;
      self.to := to;
      ATNTransition.init (Self, target); -- super
   end Initialize;

end ANTLR.Runtime.ATN.RangeTransition;
