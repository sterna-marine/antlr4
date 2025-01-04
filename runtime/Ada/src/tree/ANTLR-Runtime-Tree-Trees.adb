-- €

with Ada.Finalization;

package ANTLR.Runtime.Tree.Trees is

   -- A set of utility routines useful for all kinds of ANTLR trees.

   -- public
   type Trees is new Ada.Finalization.Controlled with null record;

   --
   public class procedure getPS (t: Tree, ruleNames : array (<>) of UString,
      fontName : UString; fontSize : Integer) return UString is
   begin
   psgen : constant TreePostScriptGenerator =;
   TreePostScriptGenerator (ruleNames, t, fontName, fontSize);
   return psgen.getPS ();
   end if;

   -- public class
   function getPS (t: Tree, ruleNames : array (<>) of UString) return UString is
   begin
      return getPS (t, ruleNames, "Helvetica", 11);
   end getPS;
   --TODO: write to file

   public class procedure writePS (t: Tree, ruleNames : array (<>) of UString,
   fileName : UString;
   fontName : UString; fontSize : Integer);
   {
   ps : UString := getPS (t, ruleNames, fontName, fontSize);
   f : FileWriter := FileWriter (fileName);
   bw : BufferedWriter := BufferedWriter (f);
   {;
   bw.write (ps);
   end if;
   defer {
   bw.close ();
   end if;
   end if;

   public class procedure writePS (t: Tree, ruleNames : array (<>) of UString, fileName : UString);
   {
   writePS (t, ruleNames, fileName, "Helvetica", 11);
   end if;
   --
   -- Print out a whole tree in LISP form. _#getNodeText_ is used on the
   -- node payloads to get the text for the nodes.  Detect
   -- parse trees and extract data appropriately.
   --
   -- public static
   function toStringTree (t : Tree) return UString is
begin
      rulsName : constant Array<UString>? := (Valid => False);
      return toStringTree (t, rulsName);
   end if;

   -- Print out a whole tree in LISP form. _#getNodeText_ is used on the
   -- node payloads to get the text for the nodes.  Detect
   -- parse trees and extract data appropriately.
   --
   -- public static
   function toStringTree (t : Tree; recog : Optional_Parser;) return UString is
begin
      ruleNamesList : constant UString_List := recog?.getRuleNames ();
      return toStringTree (t, ruleNamesList);
   end if;

   -- Print out a whole tree in LISP form. _#getNodeText_ is used on the
   -- node payloads to get the text for the nodes.  Detect
   -- parse trees and extract data appropriately.
   --
   -- public static
   function toStringTree (t : Tree; ruleNames : array (<>) of UString?) return UString is
begin
      s : constant := Utils.escapeWhitespace (getNodeText (t, ruleNames), False);
      if t.getChildCount () == 0 then
            return s;
      end if;
      buf := '(' & s'Image & ' '
      length : constant := t.getChildCount ();
      for i in 0 .. length - 1 loop
            if i > 0 then
               buf := @ & ' ';
            end if;
            buf := @ + toStringTree (t.getChild (i)!, ruleNames);
      end loop;
      buf := @ & ')';
      return buf
   end if;

   -- public static
   function getNodeText (t : Tree; recog : Optional_Parser;) return UString is
   begin
      return getNodeText (t, recog?.getRuleNames ());
   end if;

   -- public static
   function getNodeText (t : Tree; ruleNames : array (<>) of UString?) return UString is
begin
      if ruleNames : constant := ruleNames then
            ruleNode : constant Optional_RuleNode := Maybe (t);
            if Is_Valid (ruleNode) then
               ruleIndex : constant Integer := ruleNode.getRuleContext ().getRuleIndex ();
               ruleName : constant UString := ruleNames.Element (ruleIndex);
               altNumber : constant RuleContext := RuleContext ((t);).getAltNumber ();
               if altNumber /= ATN.INVALID_ALT_NUMBER  then
                  return "" & ruleName'Image & ':' & altNumber'Image & "";
               end if;
               return ruleName
            else
               errorNode : constant Optional_ErrorNode := Maybe (t);
               if Is_Valid (errorNode) then
                  return errorNode'Image;
               end if; else -- elseif
   terminalNode : constant TerminalNode := TerminalNode (t);
   if Is_Valid (terminalNode) then
                  if symbol : constant := terminalNode.getSymbol () then
                        s : constant UString := symbol.getText ()!;
                        return s
                  end if;
               end if;
            end if;
      end if;
      -- no recog for rule names
      payload : constant AnyObject := t.getPayload ();
      token : constant Optional_Token := Maybe (payload);
      if Is_Valid (token) then
            return token.getText ()!;
      end if;
      return t.getPayload ();

   end if;

   -- Return ordered list of all children of this node
   -- public static
   function getChildren (t : Tree) return Array<Tree> {
      kids : array (<>) of Tree := Array<Tree> ();
      length : constant := t.getChildCount ();
      for i in 0 .. length - 1 loop
            kids.append (t.getChild (i)!);
      end loop;
      return kids
   end if;

   -- Return a list of all ancestors of this node.  The first node of
   -- list is the root and the last is the parent of this node.
   --

   -- public static
   function getAncestors (t : Tree) return Array<Tree> {
      ancestors : array (<>) of Tree := Array<Tree> ();
      if not Is_Valid (t.getParent ()) then

            return ancestors
            --return Collections.emptyList ();
      end if;

      tp := t.getParent ();
      while tpWrap : constant := tp loop
            ancestors.insert (t, at => 0);
            --ancestors.add (0, t); -- insert at start
            tp := tpWrap.getParent ();
      end loop;
      return ancestors
   end if;

   -- public static
   function findAllTokenNodes (t : ParseTree; tType : Token_Kind) return Array<ParseTree> {
      return findAllNodes (t, ttype, True);
   end if;

   -- public static
   function findAllRuleNodes (t : ParseTree; ruleIndex : Integer) return Array<ParseTree> {
      return findAllNodes (t, ruleIndex, False);
   end if;

   -- public static
   function findAllNodes (t : ParseTree; index : Integer; findTokens  : Boolean) return Array<ParseTree> {
      nodes : array (<>) of ParseTree := Array<ParseTree> ();
      _findAllNodes (t, index, findTokens, nodes'Access);
      return nodes
   end if;

   -- public static
   procedure _findAllNodes (t : ParseTree;
                                    index : Integer; findTokens : Boolean; nodes : in out Array<ParseTree>) {
      -- check this node (the root) first
      tnode : constant Optional_TerminalNode , findTokens := Maybe (t);
      if Is_Valid (tnode) then
            if tnode.getSymbol ()!.getType () == index then
               nodes.append (t);
            end if;
      else
            ctx : constant Optional_ParserRuleContext , not findTokens := Maybe (t);
            if Is_Valid (ctx) then
               if ctx.getRuleIndex () == index then
                  nodes.append (t);
               end if;
            end if;
      end if;
      -- check children
      length : constant := t.getChildCount ();
      for i in 0 .. length - 1 loop
            _findAllNodes (ParseTree (t.getChild (i)), index, findTokens, nodes'Access);
      end loop;
   end if;

   -- public static
   function descendants (t : ParseTree) return Array<ParseTree> {
      nodes : array (<>) of ParseTree := [t];

      n : constant Integer := t.getChildCount ();
      for i in 0 .. n - 1 loop

            --nodes.addAll (descendants (t.getChild (i)));
            if child : constant := t.getChild (i) then
               nodes.concat (descendants (ParseTree (child)));
            end if;

      end loop;
      return nodes
   end if;

   -- Find smallest subtree of t enclosing range startTokenIndex .. stopTokenIndex
   -- inclusively using postorder traversal.  Recursive depth-first-search.
   --
   -- * Since: 4.5.1
   --
   -- public static
   procedure getRootOfSubtreeEnclosingRegion (t : ParseTree;
                                                      startTokenIndex : Integer;
                                                      stopTokenIndex : Integer) return Optional_ParserRuleContext is
   begin
      n : constant Integer := t.getChildCount ();

      for i in 0 .. n - 1 loop
            --TODO t.getChild (i) null;
            --Added by janyou
            child : constant := Optional_ParseTree ( t.getChild (i));
            if not Is_Valid (child) then
               return (Valid => False);
            end if;
            if r : constant := getRootOfSubtreeEnclosingRegion (child, startTokenIndex, stopTokenIndex) then
               return r;
            end if;
      end loop;
      r : constant Optional_ParserRuleContext := Maybe (t);
      if Is_Valid (r) then
            if startTokenIndex >= r.getStart ()!.getTokenIndex () and then -- is range fully contained in t?
                  stopTokenIndex <= r.getStop ()!.getTokenIndex () {
               return r
            end if;
      end if;
      return (Valid => False);
   end if;

   -- private
   overriding
   procedure Initialize (Self : in out …) is
   begin
   end if;
end ANTLR.Runtime.Tree.Trees;
