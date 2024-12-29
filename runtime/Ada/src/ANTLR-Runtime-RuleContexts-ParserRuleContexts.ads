-- €

package ANTLR.Runtime.RuleContexts.ParserRuleContexts is

   use ANTLR.Runtime.RuleContext;
   -- A rule invocation record for parsing.
   --
   -- Contains all of the information about the current rule not stored in the
   -- RuleContext. It handles parse tree children list, Any ATN state
   -- tracing, and the default values available for rule invocations:
   -- start, stop, rule index, current alt number.
   --
   -- Subclasses made for each rule and grammar track the parameters,
   -- return values, locals, and labels specific to that rule. These
   -- are the objects that are returned from rules.
   --
   -- Note text is not an actual field of a rule return value; it is computed
   -- from start and stop using the input stream's toString () method.  I
   -- could add a ctor to this so that we can pass in and store the input
   -- stream, but I'm not sure we want to do that.  It would seem to be undefined
   -- to get the .text property anyway if the rule matches tokens from multiple
   -- input streams.
   --
   -- I do not use getters for fields of objects that are used simply to
   -- group values such as this aggregate.  The getters/setters are there to
   -- satisfy the superclass interface.
   --

   -- open
   type ParserRuleContext is new RuleContext with
   record

      -- public
      visited : Boolean := False;

      -- If we are debugging or building a parse tree for a visitor,
      -- we need to track all of the tokens and rule invocations associated
      -- with this rule's context. This is empty for parsing w/o tree constr.
      -- operation because we don't the need to track the details about
      -- how we parse this rule.
      --
      -- public
      children : ParseTree.Container.Vector;

      -- For debugging/tracing purposes, we want to track all of the nodes in
      -- the ATN traversed by the parser for a particular rule.
      -- This list indicates the sequence of ATN nodes used to match
      -- the elements of the children list. This list does not include
      -- ATN nodes and other rules used to match rule invocations. It
      -- traces the rule invocation node itself but nothing inside that
      -- other rule's ATN submachine.
      --
      -- There is NOT a one-to-one correspondence between the children and
      -- states list. There are typically many nodes in the ATN traversed
      -- for each element in the children list. For example, for a rule
      -- invocation there is the invoking state and the following state.
      --
      -- The parser setState () method updates field s and adds it to this list
      -- if we are debugging/tracing.
      --
      -- This does not trace states visited during prediction.
      --
      -- public
      start, stop: Optional_Token;

      --
      -- The exception that forced this rule to return. If the rule successfully
      -- completed, this is `null`.
      --
      -- public
      Recognition_Exception : Optional_RecognitionException;
   end record;

   subtype Object is ParserRuleContext;
   subtype Super is RuleContext;
   type Class is access all Object;
   type Class_Wide is access all Object'Class;

   -- public static
   EMPTY : constant ParserRuleContext := ParserRuleContext ();

   -- public
   overriding
   procedure Initialize (Self : ParserRuleContext);

   -- public
   procedure Initialize (Self : in out ParserRuleContext; parent : Optional_ParserRuleContext; invokingStateNumber : ATNStates.State);

   -- COPY a ctx (I'm deliberately not using copy constructor) to avoid
   -- confusion with creating node with parent. Does not copy children.
   --
   -- This is used in the generated parser code to flip a generic XContext
   -- node for rule X to a YContext for alt label Y. In that sense, it;
   -- not really a generic copy function.
   --
   -- If we do an error sync () at start of a rule, we might add error nodes
   -- to the generic XContext so this function must copy those nodes to
   -- the YContext as well else they are lost!
   --
   -- open
   procedure copyFrom (This : ParserRuleContext; ctx : ParserRuleContext);

   -- Double dispatch methods for listeners

   -- open
   procedure enterRule (This : ParserRuleContext; listener : ParseTreeListener) is null;

   -- open
   procedure exitRule (This : ParserRuleContext; listener : ParseTreeListener) is null;

   -- Add a parse tree node to this as a child.  Works for
   -- internal and leaf nodes. Does not set parent link;
   -- other add methods must do that. Other addChild methods
   -- call this.
   --
   -- We cannot set the parent pointer of the incoming node
   -- because the existing interfaces do not have a setParent ();
   -- method and I don't want to break backward compatibility for this.
   --
   -- open
   procedure addAnyChild (This : ParserRuleContext; t : ParseTree);

   -- open
   procedure addChild (This : ParserRuleContext; ruleInvocation : RuleContext);

   -- Add a token leaf node child and force its parent to be this node.
   -- open
   procedure addChild (This : ParserRuleContext; t : TerminalNode);

   -- Add an error node child and force its parent to be this node.
   -- open
   procedure addErrorNode (This : ParserRuleContext; errorNode : ErrorNode);

   -- Used by enterOuterAlt to toss out a RuleContext previously added as
   -- we entered a rule. If we have # label, we will need to remove
   -- generic ruleContext object.
   --
   -- open
   procedure removeLastChild (This : ParserRuleContext);

   overriding
   -- open
   function getChild (This : ParserRuleContext; i : Integer) return Optional_Tree;

   -- open
   generic
      type T is ParseTree'Class;
      subtype Optional_T is Option_ParseTree.Optional;
   function getChild (This : ParserRuleContext; ctxType : T.Type; i : Integer) return Optional_T;

   -- open
   function getToken (This : ParserRuleContext; tType : Token_Kind; i : Integer) return Optional_TerminalNode;

   -- open
   function getTokens (This : ParserRuleContext; tType : Token_Kind) return TerminalNode.Container.Vector;

   -- open
   generic
      type T is ParserRuleContext'Class;
      subtype Optional_T is Option_ParserRuleContext.Optional;
   function getRuleContext (This : ParserRuleContext; ctxType : T.Type, i : Integer) return Optional_T;

   -- open
   generic
      type T is ParserRuleContext'Class;
      subtype Optional_T is Option_ParserRuleContext.Optional;
   function getRuleContexts (This : ParserRuleContext; ctxType : T.Type) return T.Container.Vector;

   overriding
   -- open
   function getChildCount (This : ParserRuleContext) return Integer
      is (Value (This.children.Length, Default => 0)); --TOFIX

   overriding
   -- open
   subscript (This : ParserRuleContext; index : Integer) return ParseTree
      is (Maybe (This.children.Element (index))); --TOFIX

   overriding
   -- open
   function getSourceInterval (This : ParserRuleContext) return Interval;

   --
   -- Get the initial token in this context.
   -- Note that the range from start to stop is inclusive, so for rules that do not consume anything
   -- (for example, zero length or error productions) this token may exceed stop.
   --
   -- open
   function getStart (This : ParserRuleContext) return Optional_Token
      is This.start;

   --
   -- Get the final token in this context.
   -- Note that the range from start to stop is inclusive, so for rules that do not consume anything
   -- (for example, zero length or error productions) this token may precede start.
   --
   -- open
   function getStop (This : ParserRuleContext) return Optional_Token
      is This.stop;

   -- Used for rule context info debugging during parse-time, not so much for ATN debugging
   -- open
   function toInfoString (This : ParserRuleContext; recognizer : Parser) return UString;

end ANTLR.Runtime.RuleContexts.ParserRuleContexts;
