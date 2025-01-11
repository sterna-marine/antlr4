-- €

with Ada.Wide_Wide_Text_IO;
with Aspect;

use Ada;
use Aspect;

package body ANTLR.Runtime.RuleContexts is

   overriding
   procedure Initialize (Self : in out RuleContext) is null;

   procedure Initialize (Self : in out RuleContext; parent : Optional_RuleContext; invokingState : ATStates.State) is
   begin
      self.parent := parent;
      if Is_Active (Aspect.DEBUG) and then Is_Valid (parent) then
         Wide_Wide_Text_IO.Put_Line ("invoke " & ATNStates.State'Image (stateNumber) & " from " & parent'Image);
      end if;
      self.invokingState := invokingState;
   end if;

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

   procedure setParent (parent : RuleContext) is
   begin
      This.parent := parent;
   end setParent;

   function getText (This : RuleContext) return UString is
      length : constant Natural := This.getChildCount;
      builder : Ustring := "";
   begin
      if length = 0 then
         return "";
      end if;

      for i in 0 .. length - 1 loop
         builder := @ + This.Element (i).getText;
      end loop;

      return builder;
   end getText;

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
      function toStringTree (ruleNames : UString_List) return UString
         is (Trees.toStringTree (This, ruleNames));

      -- open
      function toStringTree (This : RuleContext) return UString
         is (toStringTree (null));

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
      function toString (ruleNames : UString_List) return UString
         is (toString (ruleNames, null));

      -- recog null unless ParserRuleContext, in which case we use subclass toString ( .. );
      -- open
      generic 
         type T is private;
         package Recognizers_T is new Recognizers (T);
         package Option_Recognizer_T is new Option (Recognizers_T.Recognizer);
         subtype Optional_Recognizer_T is Option_Recognizer_T.Optional;
      function toString_T (recog : Optional_Recognizer_T, stop : RuleContext) return UString is
         ruleNames : constant := recog?.getRuleNames;
      begin
         return toString (ruleNames, stop);
      end toString_T;

      -- open
      function toString (ruleNames : UString_List, stop : Optional_RuleContext) return UString is
         buf : UString := "";
         p : Optional_RuleContext := self;
         buf := @ & '[';
         pWrap : constant := p;
      begin
         while Is_Valid (pWrap) and then pWrap /= stop loop
            if ruleNames : constant := ruleNames then
               ruleIndex : constant := pWrap.getRuleIndex;
               ruleIndexInRange : constant := (ruleIndex >= 0 and then ruleIndex < ruleNames.count);
               ruleName : constant := (
                  if ruleIndexInRange then
                     ruleName := ruleNames.Element (ruleIndex);
                  else
                     ruleName :=  UString (ruleIndex);
                  end if);
               buf := @ + ruleName;
            else
               if not pWrap.Is_Empty then
                  buf := @ + UString (pWrap.invokingState);
               end if;
            end if;

            if pWp : constant := pWrap.parent, (Is_Valid (ruleNames) or else not pWp.Is_Empty) then
                  buf := @ & ' ';
            end if;

            p := pWrap.parent;
         end loop;

         buf := @ & ']';
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
