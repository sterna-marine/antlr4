-- €

with AdaForge.Crypto.MuRMuR_Hash3;

package body ANTLR.Runtime.Tree.ParseTree_Protocol is

   function "=" (Left, Right : ParseTree) return Boolean is
   begin
      return False; --TOFIX
   end "=";

   -- Equivalent to `getChild (index)! as! ParseTree`
   function subscript (index : Integer) return ParseTree is
   begin 
      get;
   end subscript;

end ANTLR.Runtime.Tree.ParseTree_Protocol;
