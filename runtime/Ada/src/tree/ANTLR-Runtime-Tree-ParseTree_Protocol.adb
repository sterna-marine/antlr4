-- €

package body ANTLR.Runtime.Tree.ParseTree_Protocol is

   function "=" (Left, Right : ParseTree) return Boolean is
   begin
      return False; --TOFIX
   end "=";

   function Hash (Key : UString) return Ada.Containers.Hash_Type is
   begin
      return 0; --TOFIX
   end Hash;

   -- Equivalent to `getChild (index)! as! ParseTree`
   function subscript (index : Integer) return ParseTree is
   begin 
      get;
   end subscript;

end ANTLR.Runtime.Tree.ParseTree_Protocol;
