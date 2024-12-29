-- €

package body ANTLR.Runtime.ATN.Transitions.EpsilonTransitions is

   overriding
   procedure Initialize (Self : in out EpsilonTransition;
                   target : ATNState) is
   begin
      Self.init (target, -1);
   end Initialize;

   procedure Initialize (Self : in out EpsilonTransition;
                   target : ATNState;
                   outermostPrecedenceReturn : Integer) is
   begin
      Self.outermostPrecedenceReturnInside := outermostPrecedenceReturn;
      Transition.init (target); -- Super
   end Initialize;

end ANTLR.Runtime.ATN.Transitions.EpsilonTransitions;
