-- €

package body ANTLR.Runtime.ATN.DecisionInfos is

   procedure Initialize (Self : in out DecisionInfo; decision : Integer) is
      self.decision := decision;
   end Initialize;

end ANTLR.Runtime.ATN.DecisionInfos;
