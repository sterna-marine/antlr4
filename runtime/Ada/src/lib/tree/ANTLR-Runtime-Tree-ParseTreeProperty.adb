-- €

with AdaForge.Crypto.MuRMuR_Hash3;

package body ANTLR.Runtime.Tree.ParseTreeProperty is

   function Hash (Key : ObjectIdentifier) return Ada.Containers.Hash_Type is
      package ObjectIdentifier_Crypto is new AdaForge.Crypto.MuRMuR_Hash3 (ObjectIdentifier);
   begin
      return ObjectIdentifier_Crypto.Hash_32 (Key);
   end Hash;

   overriding
   procedure Initialize (Self : in out ParseTreeProperty) is null;

   procedure put (This : ParseTreeProperty; node : ParseTree; value : V) is
   begin
      annotations.Element (ObjectIdentifier (node)) := value;
   end put;

   procedure removeFrom (This : ParseTreeProperty; node : ParseTree) is
   begin 
      annotations.removeValue (forKey => ObjectIdentifier (node));
   end removeFrom;

end ANTLR.Runtime.Tree.ParseTreeProperty;
