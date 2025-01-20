-- €

package body ANTLR.Runtime.Tree.Pattern.ParseTreeMatchs is

   function "=" (Left, Right : Element_Type) return Boolean is
   begin
      return False; --TOFIX
   end "=";

   procedure Initialize (Self : in out ParseTreeMatch;
                         tree : ParseTree;
                         pattern : ParseTreePattern;
                         labels : ParseTree_MultiMap;
                         mismatchedNode : Optional_ParseTree) is
   begin
      self.tree := tree;
      self.pattern := pattern;
      self.labels := labels;
      self.mismatchedNode := mismatchedNode;
   end Initialize;

   function get (This : ParseTreeMatch; label : UString) return Optional_ParseTree is
      parseTrees : constant ParseTree_MultiMap := This.labels.get (label);
   begin
      if Is_Valid (parseTrees) and then parseTrees.Length > 0 then
         return parseTrees.Element (parseTrees.Length - 1);   -- return last if multiple
      else
         return (Valid => False);
      end if;
   end get;

   function Description (This : ParseTreeMatch) return UString is
      info : constant UString := "failed";
   begin
      if This.succeeded then
         info := "succeeded";
      end if;
      return "Match " & info & "; found " & This.getLabels.size'Image & "labels";
   end Description;

end ANTLR.Runtime.Tree.Pattern.ParseTreeMatchs;
