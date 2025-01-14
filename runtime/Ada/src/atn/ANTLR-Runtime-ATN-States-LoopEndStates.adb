-- €

with AdaForge.Crypto.MuRMuR_Hash3;

package body ANTLR.Runtime.ATN.States.LoopEndStates is

   function Hash (Key : LoopEndState) return Ada.Containers.Hash_Type is
      package LoopEndState_Crypto is new AdaForge.Crypto.MuRMuR_Hash3 (LoopEndState);
   begin
      return LoopEndState_Crypto.Hash_32 (Key);
   end Hash;

end ANTLR.Runtime.ATN.States.LoopEndStates;
