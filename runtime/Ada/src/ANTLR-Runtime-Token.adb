-- €

package body ANTLR.Runtime.Token is

   visited : Boolean; --TOFIX Multi-process ?

   function get (is_visited : Boolean) is
   begin
      return visited;
   end get;

   procedure set (is_visited : Boolean) is
   begin
      visited := is_visited;
   end set;

   function Hash (Key : Token_String) return Hashed_Token is
   begin
      return 0; --TOFIX
   end Hash;

   function Equivalent_Keys (Left, Right : Token_String) is
   begin
      return Hash (Left) = Hash (Right);
   end Equivalent_Keys;

   function Equal (Left, Right : Token_ID) is
   begin
      return Left = Right;
   end Equal;

end ANTLR.Runtime.Token;
