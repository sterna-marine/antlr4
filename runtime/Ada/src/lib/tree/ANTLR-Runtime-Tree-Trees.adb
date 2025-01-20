-- €

package body ANTLR.Runtime.Tree.Trees is

   --  procedure getPS (t : Tree;
   --                   ruleNames : array (<>) of UString;
   --                   fontName : UString;
   --                   fontSize : Integer)
   --                   return UString is
   --     psgen : constant TreePostScriptGenerator =;
   --  begin
   --     TreePostScriptGenerator (ruleNames, t, fontName, fontSize);
   --     return psgen.getPS;
   --  end getPS;

   --  function getPS (t: Tree, ruleNames : array (<>) of UString) return UString is
   --  begin
   --     return getPS (t, ruleNames, "Helvetica", 11);
   --  end getPS;

   --TODO: write to file
   --  procedure writePS (t: Tree,
   --                     ruleNames : array (<>) of UString;
   --                     fileName : UString;
   --                     fontName : UString;
   --                     fontSize : Integer) is
   --     ps : UString := getPS (t, ruleNames, fontName, fontSize);
   --     f : FileWriter := FileWriter (fileName);
   --     bw : BufferedWriter := BufferedWriter (f);
   --  begin
   --     bw.write (ps);
   --     defer :
   --        bw.close;
   --     end defer;
   --  end writePS;

   --  procedure writePS (t: Tree;
   --                     ruleNames : array (<>) of UString;
   --                     fileName : UString) is
   --  begin
   --     writePS (t, ruleNames, fileName, "Helvetica", 11);
   --  end writePS;

   function toStringTree (t : Tree) return UString is
      rulsName : constant Array<UString>? := (Valid => False);
   begin
      return toStringTree (t, rulsName);
   end toStringTree;

   function toStringTree (t : Tree; recog : Optional_Parser) return UString is
      ruleNamesList : constant UString_List := recog?.getRuleNames;
   begin
      return toStringTree (t, ruleNamesList);
   end toStringTree;

   function toStringTree (t : Tree; ruleNames : array (<>) of UString?) return UString is
      s : constant := Utils.escapeWhitespace (getNodeText (t, ruleNames), False);
   begin
      if t.getChildCount = 0 then
            return s;
      else
         declare
            buf := '(' & s'Image & ' ';
            length : constant Natural := t.getChildCount;
         begin
            for i in 0 .. length - 1 loop
                  if i > 0 then
                     buf := @ & ' ';
                  end if;
                  buf := @ + toStringTree (t.getChild (i)!, ruleNames);
            end loop;
            buf := @ & ')';
            return buf;
         end;
      end if;
   end toStringTree;

   function getNodeText (t : Tree; ruleNames : array (<>) of UString?) return UString is
   begin
      if Is_Valid (ruleNames) then
         ruleNode : constant Optional_RuleNode := Maybe (t);
         if Is_Valid (ruleNode) then
            ruleIndex : constant Integer := ruleNode.getRuleContext.getRuleIndex;
            ruleName : constant UString := ruleNames.Element (ruleIndex);
            altNumber : constant RuleContext := RuleContext ((t)).getAltNumber;
            if altNumber /= ATN.INVALID_ALT_NUMBER  then
               return "" & ruleName'Image & ':' & altNumber'Image ;
            end if;
            return ruleName;
         else
            errorNode : constant Optional_ErrorNode := Maybe (t);
            if Is_Valid (errorNode) then
               return errorNode'Image;
            else
               terminalNode : constant TerminalNode := TerminalNode (t);
               if Is_Valid (terminalNode) then
                  if symbol : constant := terminalNode.getSymbol then
                     s : constant UString := Value (symbol.getText);
                     return s;
                  end if;
               end if;
            end if;
         end if; --TOFIX
      end if;
      -- no recog for rule names
      payload : constant AnyObject := t.getPayload;
      token : constant Optional_Token := Maybe (payload);
      if Is_Valid (token) then
         return Value (token.getText);
      else
         return t.getPayload;
      end if;
   end getNodeText;

   function getChildren (t : Tree) return Tree_List is
      kids : array (<>) of Tree := Tree_List;
      length : constant := t.getChildCount;
   begin
      for i in 0 .. length - 1 loop
            kids.append (Value (t.getChild (i)));
      end loop;
      return kids;
   end getChildren;

   function getAncestors (t : Tree) return Tree_List {
      ancestors : array (<>) of Tree := Tree_List;
      if not Is_Valid (t.getParent) then
         return ancestors;
         --return Collections.emptyList;
      end if;

      tp := t.getParent;
      tpWrap : constant := tp;
      while Is_Valid (tpWrap) loop
         ancestors.insert (t, at => 0);
         --ancestors.add (0, t); -- insert at start
         tp := tpWrap.getParent;
         tpWrap := tp; --TOFIX
      end loop;
      return ancestors;
   end getAncestors;

   function findAllNodes (t : ParseTree; index : Integer; findTokens  : Boolean) return ParseTree_List is
      nodes : array (<>) of ParseTree := ParseTree_List;
   begin
      findAllNodes_2 (t, index, findTokens, nodes'Access);
      return nodes;
   end findAllNodes;

   procedure findAllNodes_2 (t : ParseTree;
                             index : Integer;
                             findTokens : Boolean;
                             nodes : in out ParseTree_List) is
      -- check this node (the root) first
      tnode : constant Optional_TerminalNode := findTokens := Maybe (t); --TOFIX
   begin
      if Is_Valid (tnode) and then findTokens then --TOFIX
         if Value (tnode.getSymbol).getType = index then
            nodes.append (t);
         end if;
      else
         ctx : constant Optional_ParserRuleContext  := Maybe (t);  --TOFIX
         if Is_Valid (ctx) and then not findTokens then  --TOFIX
            if ctx.getRuleIndex = index then
               nodes.append (t);
            end if;
         end if;
      end if;
      -- check children
      length : constant Natural := t.getChildCount;
      for i in 0 .. length - 1 loop
         findAllNodes_2 (ParseTree (t.getChild (i)), index, findTokens, nodes'Access);
      end loop;
   end findAllNodes_2;

   function descendants (t : ParseTree) return ParseTree_List is
      nodes : array (<>) of ParseTree := [t];
      n : constant Integer := t.getChildCount;
   begin
      for i in 0 .. n - 1 loop
         --nodes.addAll (descendants (t.getChild (i)));
         child : constant := t.getChild (i)
         if Is_Valid (child) then
            nodes.concat (descendants (ParseTree (child)));
         end if;
      end loop;
      return nodes;
   end descendants;

   procedure getRootOfSubtreeEnclosingRegion (t : ParseTree;
                                             startTokenIndex, stopTokenIndex : Integer)
                                             return Optional_ParserRuleContext is
      n : constant Integer := t.getChildCount;
   begin
      for i in 0 .. n - 1 loop
         --TODO t.getChild (i) null;
         --Added by janyou
         child : constant := Optional_ParseTree ( t.getChild (i));
         if not Is_Valid (child) then
            return (Valid => False);
         else
            r : constant := getRootOfSubtreeEnclosingRegion (child, startTokenIndex, stopTokenIndex)
            if Is_Valid (r) then
               return r;
            end if;
         end if;
      end loop;

      r : constant Optional_ParserRuleContext := Maybe (t);
      if Is_Valid (r) then
         if startTokenIndex >= Value (r.getStart).getTokenIndex 
         and then stopTokenIndex <= Value (r.getStop).getTokenIndex then  -- range is fully contained in t
            return r;
         end if;
      end if;
      return (Valid => False);
   end getRootOfSubtreeEnclosingRegion;

   overriding
   procedure Initialize (Self : in out Trees) is null;

end ANTLR.Runtime.Tree.Trees;
