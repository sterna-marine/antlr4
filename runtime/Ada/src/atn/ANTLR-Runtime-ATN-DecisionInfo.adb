-- €

package body ANTLR.Runtime.ATN.DecisionInfo is

   procedure Init (Self : in out DecisionInfo; decision : Integer) is
      self.decision := decision;
   end Init;

end ANTLR.Runtime.ATN.DecisionInfo;
