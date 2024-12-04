-- €

package body ANTLR.Runtime.ATN.EpsilonTransition is

   override
   procedure Init (Self : in out EpsilonTransition;
                   target : ATNState) is
   begin
      Self.init (target, -1);
   end Init;

   procedure Init (Self : in out EpsilonTransition;
                   target : ATNState;
                   outermostPrecedenceReturn : Integer) is
   begin
      Self.outermostPrecedenceReturnInside := outermostPrecedenceReturn;
      Transition.init (target); -- Super
   end Init;

end ANTLR.Runtime.ATN.EpsilonTransition;
