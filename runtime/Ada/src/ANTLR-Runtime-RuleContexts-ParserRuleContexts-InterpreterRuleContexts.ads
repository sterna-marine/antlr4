-- €

package ANTLR.Runtime.RuleContexts.ParserRuleContexts.InterpreterRuleContexts is

   --
   -- This class extends _org.antlr.v4.runtime.ParserRuleContext_ by allowing the value of
   -- _#getRuleIndex_ to be explicitly set for the context.
   --
   --
   -- _org.antlr.v4.runtime.ParserRuleContext_ does not include field storage for the rule index
   -- since the context classes created by the code generator override the
   -- _#getRuleIndex_ method to return the correct value for that context.
   -- Since the parser interpreter does not use the context classes generated for a
   -- parser, this class (with slightly more memory overhead per node) is used to
   -- provide equivalent functionality.
   --

   -- public
   type InterpreterRuleContext is new ParserRuleContext with
   record
      --
      -- This is the backing field for _#getRuleIndex_.
      --
      -- private
      ruleIndex : Integer := -1;
   end record;

   subtype Object is InterpreterRuleContext;
   subtype Super is ParserRuleContext;
   type Class is access all Object;
   type Class_Wide is access all Object'Class;

   -- public
   overriding
   procedure Initialize (Self : in out InterpreterRuleContext);

   --
   -- Constructs a new _org.antlr.v4.runtime.InterpreterRuleContext_ with the specified
   -- parent, invoking state, and rule index.
   --
   -- * parameter parent: The parent context.
   -- * parameter invokingStateNumber: The invoking state number.
   -- * parameter ruleIndex: The rule index for the current context.
   --
   -- public
   procedure Initialize (Self : in out InterpreterRuleContext;
                         parent : Optional_ParserRuleContext;
                         invokingStateNumber : ATNStates.State;
                         ruleIndex : Integer);

   -- public
   overriding
   function getRuleIndex (This : InterpreterRuleContext) return Integer
      is (This.ruleIndex);

   --
   -- Copy a _org.antlr.v4.runtime.ParserRuleContext_ or _org.antlr.v4.runtime.InterpreterRuleContext_
   -- stack to a _org.antlr.v4.runtime.InterpreterRuleContext_ tree.
   -- Return _null_ if `ctx` is null.
   --
   -- public static
   function fromParserRuleContext (ctx : Optional_ParserRuleContext) return Optional_InterpreterRuleContext;

end ANTLR.Runtime.RuleContexts.ParserRuleContexts.InterpreterRuleContexts;
