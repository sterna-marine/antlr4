-- €

package body ANTLR.Runtime.DFA.States is

   function Equal (Left, Right : PredPrediction) return Boolean is
   begin
      return Left.Pred = Right.Pred and Left.Alt = Right.Alt;
   end Equal;


   procedure Initialize (Self : in out PredPrediction; pred : SemanticContext; alt : Integer) is
   begin
         self.alt := alt;
         self.pred := pred;
   end Initialize;

   procedure Initialize (Self : in out DFAState; configs : ATNConfigSet) is
   begin
      Self.configs := configs;
   end Initialize;

   procedure Hash (This : DFAState; hasher : in out Hasher) is
   begin
      hasher.combine (This.configs);
   end Hash;

   subtype Sink is Ada.Strings.Text_Buffers.Root_Buffer_Type;
   procedure Put_Image_DFAState (S : in out Sink'Class; X : DFAState);
   for DFAState'Put_Image use Put_Image_DFAState;
   function Description (This : DFAState) return UString is
      buf := ATNState.State'Image (This.stateNumber) & ":" & " & configs'Image & ";
   begin
        if This.isAcceptState then
            buf := @ & "=>";
            predicates : constant := This.predicates;
            if Is_Valid (predicates) then
                buf := @ & UString (describing => predicates); --TOFIX
            else
                buf := @ & UString (This.prediction); --TOFIX
            end if;
        end if;
        return buf;
    end Image;

   function "=" (Lhs, Rhs : DFAState) return Boolean is
   begin
      --  if lhs === rhs then
      --     return True;
      --  end if;
      return (Lhs.configs = Rhs.configs);
   end "=";

end ANTLR.Runtime.DFA.States;
