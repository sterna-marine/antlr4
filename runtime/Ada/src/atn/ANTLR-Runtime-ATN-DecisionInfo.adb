-- €

package body ANTLR.Runtime.ATN.DecisionInfo is

   procedure Initialize (Self : in out DecisionInfo; decision : Integer) is
      self.decision := decision;
   end Initialize;

end ANTLR.Runtime.ATN.DecisionInfo;
