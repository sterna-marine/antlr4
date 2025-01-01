-- €

package body ANTLR.Runtime.RuleContexts.ParserRuleContexts is

   overriding
   procedure Initialize (Self : ParserRuleContext) is
   begin
      RuleContext.init (Self); -- Super
   end Initialize;

   procedure Initialize (Self : in out ParserRuleContext; parent : Optional_ParserRuleContext; invokingStateNumber : ATNStates.State) is
   begin
      Super (Self).Initialize (parent, invokingStateNumber); -- Super
   end Initialize;

   procedure copyFrom (This : ParserRuleContext; ctx : ParserRuleContext) is
      errNode : Optional_ErrorNode;
      -- copy any error nodes to alt label node
      ctxChildren : constant ParseTree.Container.Vector := ctx.children;
   begin
      This.parent := ctx.parent;
      This.invokingState := ctx.invokingState;
      This.start := ctx.start;
      This.stop := ctx.stop;

      if Is_Valid (ctxChildren) then
            This.children := ParseTree.Container.Empty_Vector;
            -- reset parent pointer for any error nodes
            for child in ctxChildren loop
               errNode := Maybe (child); --TOFIX: let errNode = child as? ErrorNode
               if Is_Valid (errNode) then
                  addChild (errNode);
               end if;
            end loop;
      end if;
   end copyFrom;

   procedure enterRule (This : ParserRuleContext; listener : ParseTreeListener) is null;

   procedure exitRule (This : ParserRuleContext; listener : ParseTreeListener) is null;

   procedure addAnyChild (This : ParserRuleContext; t : ParseTree) is
   begin
      if not Is_Valid (children) then
            children := ParseTree.Container.Empty_Vector;
      end if;
      children!.append (t);
   end addAnyChild;

   procedure addChild (This : ParserRuleContext; ruleInvocation : RuleContext) is
   begin
      This.addAnyChild (ruleInvocation);
   end addChild;

   procedure addChild (This : ParserRuleContext; t : TerminalNode) is
   begin
      t.setParent (This);
      This.addAnyChild (t);
   end addChild;

   procedure addErrorNode (This : ParserRuleContext; errorNode : ErrorNode) is
   begin
      errorNode.setParent (This);
      This.addAnyChild (errorNode);
   end addErrorNode;

   procedure removeLastChild (This : ParserRuleContext) is
   begin
      set (This.children).removeLast ();
   end removeLastChild;

   overriding
   function getChild (This : ParserRuleContext; i : Integer) return Optional_Tree is
   begin
      if not Is_Valid (This.children)
         or else not i >= 0
         or else not i < children.count then
            return (Valid => False);
      else
         return children.Element (i);
      end if;
   end getChild;

   generic
      type T is ParseTree'Class;
      subtype Optional_T is Option_ParseTree.Optional;
   function getChild (This : ParserRuleContext; ctxType : T.Type; i : Integer) return Optional_T is
   begin
      if not Is_Valid (This.children)
         or else not i >= 0
         or else not i < children.count then
            return (Valid => False);
      end if;
      j := -1; -- what element have we found with ctxType?
      for o in children loop
            o : constant Optional_T := Maybe (o);
            if Is_Valid (o) then
               j := @ + 1;
               if j = i then
                  return o;
               end if;
            end if;
      end loop;

      return (Valid => False);
   end getChild;

   function getToken (This : ParserRuleContext; tType : Token_Kind; i : Integer) return Optional_TerminalNode is
   begin
      if not Is_Valid (children)
         or else not i >= 0
         or else not i < children.count then
            return (Valid => False);
      end if;
      j := -1; -- what token with ttype have we found?
      for o in children loop
            tnode : constant Optional_TerminalNode := Maybe (o);
            if Is_Valid (tnode) then
               symbol : constant := tnode.getSymbol ()!;
               if symbol.getType () = ttype then
                  j := @ + 1;
                  if j = i then
                        return tnode;
                  end if;
               end if;
            end if;
      end loop;

      return (Valid => False);
   end getToken;

   function getTokens (This : ParserRuleContext; tType : Token_Kind) return TerminalNode.Container.Vector is

      procedure CompactMap (At_Cursor : TerminalNode.Container.Cursor) is
         tnode : constant TerminalNode := TerminalNode (At_Cursor);
         symbol : constant := tnode.getSymbol ();
      begin
            if Is_Valid (tnode)
               and then Is_Valid (symbol)
               and then symbol.getType () = ttype then
               return tnode; --TOFIX
            else
               return (Valid => False); --TOFIX
            end if;
      end compactMap;

   begin
      if not Is_Valid (This.children) then
            return TerminalNode.Container.Empty_Vector;
      end if;

      This.children.Iterate (CompactMap'Access); --TOFIX
      return This.children; --TOFIX
   end getTokens;

   generic
      type T is ParserRuleContext'Class;
      subtype Optional_T is Option_ParserRuleContext.Optional;
   function getRuleContext (This : ParserRuleContext; ctxType : T.Type, i : Integer) return Optional_T is
   begin
      return This.getChild (ctxType, i => i);
   end getRuleContext;

   generic
      type T is ParserRuleContext'Class;
      subtype Optional_T is Option_ParserRuleContext.Optional;
   function getRuleContexts (This : ParserRuleContext; ctxType : T.Type) return T.Container.Vector is

      procedure Compact_Map (At_Cursor : T.Container.Cursor) is
      begin
         Optional_T (Element (At_Cursor)); -- as? T
      end Compact_Map;

   begin
      if not Is_Valid (children) then
         return T.Container.Empty_Vector;
      else
         Children.Iterate (CompactMap'Access);
         recurn --TOFIX
      end if;
   end getRuleContexts;

   overriding
   function getSourceInterval (This : ParserRuleContext) return Interval is
   begin
      if not Is_Valid (This.start)
         or else not Is_Valid (This.stop) then
            return Interval.INVALID;
      end if;
      return Interval.of (This.start.getTokenIndex (), This.stop.getTokenIndex ());
   end getSourceInterval;

   function toInfoString (This : ParserRuleContext; recognizer : Parser) return UString is
      rules : constant := Array (recognizer.getRuleInvocationStack (This).reversed ());
      startStr : constant := Value (This.start.Image, "<unknown>");
      stopStr : constant := Value (This.stop.Image, "<unknown>");
   begin
      return "ParserRuleContext" & rules'Image & "{start=" & startStr'Image & "), stop=" & stopStr'Image & "}"
   end toInfoString;

end ANTLR.Runtime.RuleContexts.ParserRuleContexts;
