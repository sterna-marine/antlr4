-- €

with AdaForge.Crypto.MuRMuR_Hash3;

package body ANTLR.Runtime.Token_Protocol is

   visited : Boolean; --TOFIX Multi-process ?

   function Hash (Element : Token_Kind) return Ada.Containers.Hash_Type is
      package Token_Kind_Crypto is new AdaForge.Crypto.MuRMuR_Hash3 (Token_Kind);
   begin
      return Token_Kind_Crypto.Hash_32 (Element);
   end Hash;

   -- public
   function "=" (Left, Right : Token) return Boolean is
   begin
      return False; --TOFIX
   end "=";

   -- public
   procedure hash (This : Token; hasher : in out Hasher) is null; --TOFIX

   function get (is_visited : Boolean) is
   begin
      return visited;
   end get;

   procedure set (is_visited : Boolean) is
   begin
      visited := is_visited;
   end set;

   function Hash (Key : Token_String) return Hashed_Token is
      package Token_Kind_Crypto is new AdaForge.Crypto.MuRMuR_Hash3 (Token_String);
   begin
      return Token_String_Crypto.Hash_32 (Key);
   end Hash;

   function Equivalent_Keys (Left, Right : Token_String) is
   begin
      return Hash (Left) = Hash (Right);
   end Equivalent_Keys;

   function "=" (Left, Right : Token_ID) is
   begin
      return Left = Right;
   end "=";

end ANTLR.Runtime.Token_Protocol;
