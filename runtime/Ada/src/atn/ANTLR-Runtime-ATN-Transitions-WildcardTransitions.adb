-- €

package body ANTLR.Runtime.ATN.Transitions.WildcardTransitions is

   overriding
   procedure Initialize (Self : in out WildcardTransition; target : ATNState) is
   begin
      Super (Self).Initialize (target); -- super
   end Initialize;

   procedure Put_Image_WildcardTransition (S : in out Sink'Class; X : WildcardTransition) is
   begin
      S := Description (X);
   end Put_Image_WildcardTransition;

end ANTLR.Runtime.ATN.Transitions.WildcardTransitions;
