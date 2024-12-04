-- €

with Ada.Containers.Vectors;
with ANTLR.Runtime.ATN.ATNConfigSet;
with ANTLR.Runtime.ATN.ATNStates;
with ANTLR.Runtime.ATN.SemanticContext;
with ANTLR.Runtime.ATN.LexerAction;

use ANTLR.Runtime.ATN;

package body ANTLR.Runtime.ATN.DFAState is

   procedure Init (Self : in out PredPrediction; pred : SemanticContext; alt : Integer) is
   begin
         self.alt := alt;
         self.pred := pred;
   end Init;   

   procedure Init (Self : in out DFAState; configs : ATNConfigSet) is
   begin
      Self.configs := configs;
   end Init;

   procedure Hash (This : DFAState; into hasher: in out Hasher) is
   begin
      hasher.combine (This.configs);
   end Hash;

   function Image (This : DFAState) return UString is
      buf := ATNState.State'Image (This.stateNumber) & ":" & " & configs'Image & ";
   begin
        if This.isAcceptState then
            buf := @ & "=>";
            predicates : constant := This.predicates;
            if Is_Valid (predicates) then
                buf := @ & UString (describing: predicates); --TOFIX
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

end ANTLR.Runtime.ATN.DFAState;
