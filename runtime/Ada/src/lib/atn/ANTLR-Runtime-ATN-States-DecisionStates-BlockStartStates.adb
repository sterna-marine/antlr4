-- €

with AdaForge.Crypto.MuRMuR_Hash3;

package body ANTLR.Runtime.ATN.States.DecisionStates.BlockStartStates is

   function Hash (Key : BlockStartState) return Ada.Containers.Hash_Type is
      package BlockStartState_Crypto is new AdaForge.Crypto.MuRMuR_Hash3 (BlockStartState);
   begin
      return BlockStartState_Crypto.Hash_32 (Key);
   end Hash;

end ANTLR.Runtime.ATN.States.DecisionStates.BlockStartStates;