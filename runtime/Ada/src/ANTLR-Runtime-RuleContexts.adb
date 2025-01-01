-- €

with Ada.Finalization;
with ANTLR.Runtime.ATN;
with ANTLR.Runtime.ATN.States;
with ANTLR.Runtime.Misc.Intervals;
with ANTLR.Runtime.RuleContexts.ParserRuleContexts
with ANTLR.Runtime.Recognizers.Parsers;
with ANTLR.Runtime.Tree.ParseTreeVisitors;
with ANTLR.Runtime.Tree.RuleNode_Protocol;

use ANTLR.Runtime.ATN;
use ANTLR.Runtime.ATN.States;
use ANTLR.Runtime.Misc.Intervals;
use ANTLR.Runtime.RuleContexts.ParserRuleContexts
use ANTLR.Runtime.Recognizers.Parsers;
use ANTLR.Runtime.Tree.ParseTreeVisitors;
use ANTLR.Runtime.Tree.RuleNode_Protocol;

package ANTLR.Runtime.RuleContexts is

   -- A rule context is a record of a single rule invocation.
   --
   -- We form a stack of these context objects using the parent
   -- pointer. A parent pointer of null indicates that the current
   -- context is the bottom of the stack. The ParserRuleContext subclass
   -- as a children list so that we can turn this data structure into a
   -- tree.
   --
   -- The root node always has a null pointer and invokingState of ATNState.INVALID_STATE_NUMBER.
   --
   -- Upon ento parsing, the first invoked rule function creates a;
   -- context object (asubclass specialized for that rule such as
   -- SContext) and makes it the root of a parse tree, recorded by field
   -- Parser._ctx.
   --
   -- public final SContext s () RecognitionException {
   -- SContext _localctx := new SContext (_ctx, getState ()); <-- create new node
   -- enterRule (_localctx, 0, RULE_s);                     <-- push it
   -- RuleContext
   -- exitRule ();                                          <-- pop back to _localctx
   -- return _localctx;
   -- end;
   --
   -- A subsequent rule invocation of r from the start rule s pushes a
   -- new context object for r whose parent points at s and use invoking
   -- state is the state with r emanating as edge label.
   --
   -- The invokingState fields from a context object to the root
   -- together form a stack of rule indication states where the root
   -- (bottom of the stack) has a -1 sentinel value. If we invoke start
   -- symbol s then call r1, which calls r2, the  would look like
   -- this:
   --
   -- SContext[-1]   <- root node (bottom of the stack);
   -- R1Context.Element (p)   <- p in rule s called r1
   -- R2Context.Element (q)   <- q in rule r1 called r2
   --
   -- So the top of the stack, _ctx, represents a call to the current
   -- rule and it holds the return address from another rule that invoke
   -- to this rule. To invoke a rule, we must always have a current context.
   --
   -- The parent contexts are useful for computing lookahead sets and
   -- getting error information.
   --
   -- These objects are used during parsing and prediction.
   -- For the special case of parsers, we use the subclass
   -- ParserRuleContext.
   --
   -- * SeeAlso: org.antlr.v4.runtime.ParserRuleContext
   --

   type RuleContext_Root is new Ada.Finalization.Controlled with null record;

   -- open
   type RuleContext is new RuleContext_Root and RuleNode with
   record
      -- What context invoked this rule?
      -- public weak
      parent : Optional_RuleContext;

      -- What state invoked the rule associated with this context?
      -- The "return address" is the followState of invokingState
      -- If parent is null, this should be ATNState.INVALID_STATE_NUMBER
      -- this context object represents the start rule.
      --
      -- public
      invokingState : State := INVALID_STATE_NUMBER;
   end record;

   package Option_RuleContext is new Option (RuleContext);
   subtype Optional_RuleContext is Option_RuleContext.Optional;

   -- public
   overriding
   procedure Initialize (Self : in out RuleContext) is null;

   -- public
   procedure Initialize (Self : in out RuleContext; parent : Optional_RuleContext; invokingState : ATStates.State) is
   begin
      self.parent := parent;
      -- if Is_Valid (parent) then
      -- Text_IO.Put_Line ("invoke " & ATNStates.State'Image (stateNumber) & " from " & parent);
      -- }
      self.invokingState := invokingState;
   end if;

   -- open
   function depth (This : RuleContext) return Integer is
      p : Optional_RuleContext := Set (This);
      n : Natural := 0;
   begin
      while Is_Valid (p) loop
         p := p.parent;
         n := @ + 1;
      end loop;
      return n;
   end depth;

   -- A context is empty if there is no invoking state; meaning nobody called
   -- current context.
   --
   -- open
   function isEmpty (This : RuleContext) return Boolean
      is (This.invokingState = INVALID_STATE_NUMBER);

   -- satisfy the ParseTree / SyntaxTree interface

   -- open
   function getSourceInterval (This : RuleContext) return Interval
      is (INVALID);

   -- open
   function getRuleContext (This : RuleContext) return RuleContext
      is (This);
   
   -- open
   function getParent (This : RuleContext) return Optional_Tree
      is (This.parent);

   -- open
   procedure setParent (parent : RuleContext) is
   begin
      This.parent := parent;
   end setParent;

   -- open
   function getPayload (This : RuleContext) return AnyObject
      is (This);

   -- Return the combined text of all child nodes. This method only considers
   -- tokens which have been added to the parse tree.
   --
   -- Since tokens on hidden channels (e.g. whitespace or comments) are not
   -- added to the parse trees, they will not appear in the output of this
   -- method.
   --

   -- open
   function getText (This : RuleContext) return UString is
      length : constant Natural := This.getChildCount;
      builder : Ustring := "";
   begin
      if length = 0 then
         return "";
      end if;

      for i in 0 .. length - 1 loop
         builder := @ + This.Element (i).getText ();
      end loop;

      return builder
   end getText;

   -- open
   function getRuleIndex (This : RuleContext) return Integer
      is (-1);

   -- open
   function getAltNumber (This : RuleContext) return Integer
      is (INVALID_ALT_NUMBER);

   -- open
   procedure setAltNumber (This : RuleContext; altNumber : Integer) is

      -- open
      function getChild (i : Integer) return Optional_Tree
         is (Valid => False);

      -- open
      function getChildCount (This : RuleContext) return Natural
         is (0);


      -- open
      subscript (index : Integer) return ParseTree is
      begin
         preconditionFailure ("Index out of range (RuleContext never has children, though its subclasses may).");
      end subscript;


      -- open
      generic 
         type T is private;
         package ParseTreeVisitors_T is new ParseTreeVisitors (T);
         package Option_T is new Option (T);
         subtype Optional_T is Option_T.Optional;
      function accept_T (visitor : ParseTreeVisitors_T.ParseTreeVisitor) return Optional_T 
         is (visitor.visitChildren (This));


      -- Print out a whole tree, not just a node, in LISP format
      -- (root child1 .. childN). Print just a node if this is a leaf.
      -- We have to know the recognizer so we can get rule names.
      --
      -- open
      function toStringTree (recog : Parser) return UString
         is (Trees.toStringTree (This, recog));

      -- Print out a whole tree, not just a node, in LISP format
      -- (root child1 .. childN). Print just a node if this is a leaf.
      --
      -- public
      function toStringTree (ruleNames : UString.Container.Vector) return UString
         is (Trees.toStringTree (This, ruleNames));

      -- open
      function toStringTree (This : RuleContext) return UString
         is (toStringTree (null));

      -- open
      subtype Sink is Ada.Strings.Text_Buffers.Root_Buffer_Type;
      procedure Put_Image_RuleContext (S : in out Sink'Class; X : RuleContext);
      for RuleContext'Put_Image use Put_Image_RuleContext;
      function Description (This : RuleContext) return UString
         is toString (UString.Container.Empty_Vector, Option_RuleContext.Unset);

      -- open
      function debugDescription (This : RuleContext) return UString
         is (Description (This));

      -- public final
      generic 
         type T is private;
         package ParseTreeVisitors_T is new ParseTreeVisitors (T);
         package Option_T is new Option (T);
         subtype Optional_T is Option_T.Optional;
      function toString_T (recog : Recognizer_T) return UString
         is (toString (recog, ParserRuleContexts.EMPTY));

      -- public final
      function toString (ruleNames : UString.Container.Vector) return UString
         is toString (ruleNames, null);

      -- recog null unless ParserRuleContext, in which case we use subclass toString ( .. );
      -- open
      generic 
         type T is private;
         package Recognizers_T is new Recognizers (T);
         package Option_Recognizer_T is new Option (Recognizers_T.Recognizer);
         subtype Optional_Recognizer_T is Option_Recognizer_T.Optional;
      function toString_T (recog : Optional_Recognizer_T, stop : RuleContext) return UString is
         ruleNames : constant := recog?.getRuleNames ();
      begin
         return toString (ruleNames, stop);
      end toString_T;

      -- open
      function toString (ruleNames : UString.Container.Vector, stop : Optional_RuleContext;) return UString is
         buf : UString := "";
      begin
         p : Optional_RuleContext := self;
         buf := @ & "[";
         while pWrap : constant := p, pWrap !== stop loop
            if ruleNames : constant := ruleNames then
               ruleIndex : constant := pWrap.getRuleIndex ();
               ruleIndexInRange : constant := (ruleIndex >= 0 and then ruleIndex < ruleNames.count);
               ruleName : constant := (
                  if ruleIndexInRange then
                     ruleName := ruleNames.Element (ruleIndex);
                  else
                     ruleName :=  UString (ruleIndex);
                  end if);
               buf := @ + ruleName;
            else
               if not pWrap.isEmpty () then
                  buf := @ + UString (pWrap.invokingState);
               end if;
            end if;

            if pWp : constant := pWrap.parent, (Is_Valid (ruleNames) or else not pWp.isEmpty ()) then
                  buf := @ & " ";
            end if;

            p := pWrap.parent;
         end loop;

         buf := @ & "]";
         return buf;
      end toString;

      -- open
      generic
         type T is private;
      function castdown_T (subType : T.Type) return T is
      begin
         return T (This);
      end castdown_T;

   begin
      null;
   end setAltNumber; --TOFIX

end ANTLR.Runtime.RuleContexts;
