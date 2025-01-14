-- €

with AdaForge.Crypto.MuRMuR_Hash3;

package body ANTLR.Runtime is

   function Hash (Key : Integer) return Ada.Containers.Hash_Type is
      package Integer_Crypto is new AdaForge.Crypto.MuRMuR_Hash3 (Integer);
   begin
      return Integer_Crypto.Hash_32 (Key);
   end Hash;

   function Hash (Key : UString) return Ada.Containers.Hash_Type is
      package UString_Crypto is new AdaForge.Crypto.MuRMuR_Hash3 (UString);
   begin
      return UString_Crypto.Hash_32 (Key);
   end Hash;
   
end ANTLR.Runtime;