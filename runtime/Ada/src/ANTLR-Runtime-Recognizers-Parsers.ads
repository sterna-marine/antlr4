-- €

with Ada.Containers.Vectors;
with ANTLR.Runtime.ATN.ParseInfos;
with ANTLR.Runtime.ATN.PredictionModes;
with ANTLR.Runtime.Misc.Utils.Mutex;
with ANTLR.Runtime.Tree.ParseTreeListener;

use ANTLR.Runtime.ATN.ParseInfos;
use ANTLR.Runtime.ATN.PredictionModes;
use ANTLR.Runtime.Misc.Utils.Mutex;
use ANTLR.Runtime.Tree.ParseTreeListener;

package ANTLR.Runtime.Recognizers.Parsers is

   --
   -- This is all the parsing support code essentially; most of it is error recovery stuff.
   --

   -- public static
   ConsoleError : Boolean := True;

   -- public static
   INSTANCE : TrimToSizeListener; -- constant

   package Integer_Container is new Ada.Containers.Vectors (
      Index_Type => Natural,
      Element_Type => Integer,
      "=" => "=");
   subtype Integer_Stack is Integer_Container.Vector;
   -------------------
   -- TraceListener --
   -------------------
   -- public
   type TraceListener is new ParseTreeListener with record
      host : Parser;
   end record;

   procedure Initialize (Self : in out TraceListener; host : Parser);

   -- public
   procedure enterEveryRule (This : TraceListener; ctx : ParserRuleContext);

   -- public
   procedure visitTerminal (This : TraceListener; node : TerminalNode);

   -- public
   procedure visitErrorNode (This : TraceListener; node : ErrorNode);

   -- public
   procedure exitEveryRule (This : TraceListener; ctx : ParserRuleContext);

   ------------------------
   -- TrimToSizeListener --
   ------------------------
   -- public
   type TrimToSizeListener is new ParseTreeListener with null record;

   -- public
   procedure enterEveryRule (This : TrimToSizeListener; ctx : ParserRuleContext) is null;

   -- public
   procedure visitTerminal (This : TrimToSizeListener; node : TerminalNode) is null;

   -- public
   procedure visitErrorNode (This : TrimToSizeListener; node : ErrorNode) is null;

   -- public
   procedure exitEveryRule (This : TrimToSizeListener; ctx : ParserRuleContext) is null;
      -- TODO: Print exit info.

   -------------------
   --     Parser    --
   -------------------
   package This_Parser is new Recognizer (ParserATNSimulator);
   -- open
   type Parser is new This_Parser.Recognizer with record

      TraceListener : TraceListener;

      TrimToSizeListener : TrimToSizeListener;

      --
      -- The error handling strategy for the parser. The default value is a new
      -- instance of _org.antlr.v4.runtime.DefaultErrorStrategy_.
      --
      -- * SeeAlso: #getErrorHandler
      -- * SeeAlso: #setErrorHandler
      --
      -- public
      errHandler : ANTLRErrorStrategy := DefaultErrorStrategy.Init;

      --
      -- The input stream.
      --
      -- * SeeAlso: #getInputStream
      -- * SeeAlso: #setInputStream
      --
      -- public
      input : TokenStream; -- !

      -- internal
      precedenceStack : Integer_Stack;


      --
      -- The _org.antlr.v4.runtime.ParserRuleContext_ object for the currently executing rule.
      -- This is always non-null during the parsing process.
      --
      -- public
      ctx : Optional_ParserRuleContext;

      --
      -- Specifies whether or not the parser should construct a parse tree during
      -- the parsing process. The default value is `True`.
      --
      -- * SeeAlso: #getBuildParseTree
      -- * SeeAlso: #setBuildParseTree
      --
      -- internal
      buildParseTrees : Boolean := True;

      --
      -- When _#setTrace_`(True)` is called, a reference to the
      -- _org.antlr.v4.runtime.Parser.TraceListener_ is stored here so it can be easily removed in a
      -- later call to _#setTrace_`(False)`. The listener itself is
      -- implemented as a parser listener so this field is not directly used by
      -- other parser methods.
      --
      -- private
      tracer : Optional_TraceListener;

      --
      -- The list of _org.antlr.v4.runtime.tree.ParseTreeListener_ listeners registered to receive
      -- events during the parse.
      --
      -- * SeeAlso: #addParseListener
      --
      -- public
      parseListeners : ParseTreeListener_List;

      --
      -- The number of syntax errors reported during parsing. This value is
      -- incremented each time _#notifyErrorListeners_ is called.
      --
      -- internal
      syntaxErrors : Integer := 0;
   end record;

   subtype Object is Parser;
   subtype Super is This_Parser.Recognizer;
   type Class is access all Object;
   type Class_Wide is access all Object'Class;

   function precedenceStack return Integer_Stack;

   -- public
   procedure Initialize (Self : in out Parser; input : TokenStream);

   -- reset the parser's state
   -- public
   procedure reset (This : Parser);

   --
   -- Match current input symbol against `ttype`. If the symbol type
   -- matches, _org.antlr.v4.runtime.ANTLRErrorStrategy#reportMatch_ and _#consume_ are
   -- called to complete the match process.
   --
   -- If the symbol type does not match,
   -- _org.antlr.v4.runtime.ANTLRErrorStrategy#recoverInline_ is called on the current error
   -- strategy to attempt recovery. If _#getBuildParseTree_ is
   -- `True` and the token index of the symbol returned by
   -- _org.antlr.v4.runtime.ANTLRErrorStrategy#recoverInline_ is -1, the symbol is added to
   -- the parse tree by calling _#createErrorNode (ParserRuleContext, Token)_ then
   -- _ParserRuleContext#addErrorNode (ErrorNode)_.
   --
   -- * Parameter ttype: the token type to match
   -- * Throws: org.antlr.v4.runtime.RecognitionException if the current input symbol did not match
   -- `ttype` and the error strategy could not recover from the
   -- mismatched symbol
   -- * Returns: the matched symbol
   --
   -- @discardableResult
   -- public
   function match (This : Parser; tType : Token_Kind) return Token;

   --
   -- Match current input symbol as a wildcard. If the symbol type matches
   -- (i.e. has a value greater than 0), _org.antlr.v4.runtime.ANTLRErrorStrategy#reportMatch_
   -- and _#consume_ are called to complete the match process.
   --
   -- If the symbol type does not match,
   -- _org.antlr.v4.runtime.ANTLRErrorStrategy#recoverInline_ is called on the current error
   -- strategy to attempt recovery. If _#getBuildParseTree_ is
   -- `True` and the token index of the symbol returned by
   -- _org.antlr.v4.runtime.ANTLRErrorStrategy#recoverInline_ is -1, the symbol is added to
   -- the parse tree by calling _#createErrorNode (ParserRuleContext, Token)_ then
   -- _ParserRuleContext#addErrorNode (ErrorNode)_.
   --
   -- * Throws: org.antlr.v4.runtime.RecognitionException if the current input symbol did not match
   -- a wildcard and the error strategy could not recover from the mismatched
   -- symbol
   -- * Returns: the matched symbol
   --
   -- @discardableResult
   -- public
   function matchWildcard (This : Parser) return Token;

   --
   -- Track the _org.antlr.v4.runtime.ParserRuleContext_ objects during the parse and hook
   -- them up using the _org.antlr.v4.runtime.ParserRuleContext#children_ list so that it
   -- forms a parse tree. The _org.antlr.v4.runtime.ParserRuleContext_ returned from the start
   -- rule represents the root of the parse tree.
   --
   -- Note that if we are not building parse trees, rule contexts only point
   -- upwards. When a rule exits, it returns the context but that gets garbage
   -- collected if nobody holds a reference. It points upwards but nobody
   -- points at it.
   --
   -- When we build parse trees, we are adding all of these contexts to
   -- _org.antlr.v4.runtime.ParserRuleContext#children_ list. Contexts are then not candidates
   -- for garbage collection.
   --
   -- public
   procedure setBuildParseTree (This : Parser; buildParseTrees : Boolean);

   --
   -- Gets whether or not a complete parse tree will be constructed while
   -- parsing. This property is `True` for a newly constructed parser.
   --
   -- * Returns: `True` if a complete parse tree will be constructed while
   -- parsing, otherwise `False`
   --
   -- public
   function getBuildParseTree (This : Parser) return Boolean
      is (This.buildParseTrees);

   --
   -- Trim the internal lists of the parse tree during parsing to conserve memory.
   -- This property is set to `False` by default for a newly constructed parser.
   --
   -- * Parameter trimParseTrees: `True` to trim the capacity of the _org.antlr.v4.runtime.ParserRuleContext#children_
   -- list to its size after a rule is parsed.
   --
   -- public
   procedure setTrimParseTree (This : Parser; trimParseTrees : Boolean);

   --
   -- * Returns: `True` if the _org.antlr.v4.runtime.ParserRuleContext#children_ list is trimmed
   -- using the default _org.antlr.v4.runtime.Parser.TrimToSizeListener_ during the parse process.
   --
   -- public
   function getTrimParseTree (This : Parser) return Boolean;

   -- public
   function getParseListeners (This : Parser) return ParseTreeListener_List;

   --
   -- Registers `listener` to receive events during the parsing process.
   --
   -- To support output-preserving grammar transformations (including but not
   -- limited to left-recursion removal, automated left-factoring, and
   -- optimized code generation), calls to listener methods during the parse
   -- may differ substantially from calls made by
   -- _org.antlr.v4.runtime.tree.ParseTreeWalker#DEFAULT_ used after the parse is complete. In
   -- particular, rule enand exit events may occur in a different order;
   -- during the parse than after the parser. In addition, calls to certain
   -- rule enmethods may be omitted.;
   --
   -- With the following specific exceptions, calls to listener events are
   -- __deterministic__, i.e. for identical input the calls to listener
   -- methods will be the same.
   --
   -- * Alterations to the grammar used to generate code may change the
   -- behavior of the listener calls.
   -- * Alterations to the command line options passed to ANTLR 4 when
   -- generating the parser may change the behavior of the listener calls.
   -- * Changing the version of the ANTLR Tool used to generate the parser
   -- may change the behavior of the listener calls.
   --
   -- * Parameter listener: the listener to add
   --
   -- public
   procedure addParseListener (This : Parser; listener : ParseTreeListener);

   --
   -- Remove `listener` from the list of parse listeners.
   --
   -- If `listener` is `null` or has not been added as a parse
   -- listener, this method does nothing.
   --
   -- * SeeAlso: #addParseListener
   --
   -- * Parameter listener: the listener to remove
   --

   -- public
   procedure removeParseListener (This : Parser; listener : Optional_ParseTreeListener);

   --
   -- Remove all parse listeners.
   --
   -- * SeeAlso: #addParseListener
   --
   -- public
   procedure removeParseListeners (This : Parser);

   --
   -- Notify any parse listeners of an enter rule event.
   --
   -- * SeeAlso: #addParseListener
   --
   -- public
   procedure triggerEnterRuleEvent (This : Parser);

   --
   -- Notify any parse listeners of an exit rule event.
   --
   -- * SeeAlso: #addParseListener
   --
   -- public
   procedure triggerExitRuleEvent (This : Parser);

   --
   -- Gets the number of syntax errors reported during parsing. This value is
   -- incremented each time _#notifyErrorListeners_ is called.
   --
   -- * SeeAlso: #notifyErrorListeners
   --
   -- public
   function getNumberOfSyntaxErrors (This : Parser) return Integer
      is (This.syntaxErrors);

   overriding
   -- open
   function getTokenFactory (This : Parser) return TokenFactory
      is (This.input.getTokenSource.getTokenFactory);

   -- Tell our token source and error strategy about a new way to create tokens.
   overriding
   -- open
   procedure setTokenFactory (This : Parser; factory : TokenFactory);

   --
   -- The ATN with bypass alternatives is expensive to create so we create it
   -- lazily.
   --
   -- public
   function getATNWithBypassAlts (This : Parser) return ATN;

   --
   -- The preferred method of getting a tree pattern. For example, here's a
   -- sample use:
   --
   --
   -- ParseTree t := parser.expr ();
   -- ParseTreePattern p := parser.compileParseTreePattern ("<ID>+0", MyParser.RULE_expr);
   -- ParseTreeMatch m := p.match (t);
   -- UString id := m.get ("ID");
   --
   --
   -- public
   function compileParseTreePattern (This : Parser;
                                     pattern : UString;
                                     patternRuleIndex : Integer)
                                     return ParseTreePattern;

   --
   -- The same as _#compileParseTreePattern (String, int)_ but specify a
   -- _org.antlr.v4.runtime.Lexer_ rather than trying to deduce it from this parser.
   --
   -- public
   function compileParseTreePattern (This : Parser;
                                      pattern : UString;
                                      patternRuleIndex : Integer;
                                      lexer : Lexer)
                                      return ParseTreePattern;

   -- public
   function getErrorHandler (This : Parser) return ANTLRErrorStrategy
      is (This.errHandler);

   -- public
   procedure setErrorHandler (This : Parser; handler : ANTLRErrorStrategy);

   overriding
   -- open
   function getInputStream (This : Parser) return Optional_IntStream
      is (This.getTokenStream);

   overriding
   -- public final
   procedure setInputStream (This : Parser; input : IntStream);

   -- public
   function getTokenStream (This : Parser) return Optional_TokenStream
      is (This.input);

   -- Set the token stream and reset the parser.
   -- public
   procedure setTokenStream (This : Parser; input : TokenStream);

   -- Match needs to return the current input symbol, which gets put
   -- into the label for the associated token ref; e.g., x=ID.
   --

   -- public
   function getCurrentToken (This : Parser) return Token
      is (Value (input.LT (1)));

   -- public final
   procedure notifyErrorListeners (This : Parser; msg : UString);

   -- public
   procedure notifyErrorListeners (This : Parser;
                                   offendingToken : Optional_Token;
                                   msg : UString;
                                   e : Optional_AnyObject);

   --
   -- Consume and return the |: #getCurrentToken current symbol:|.
   --
   -- E.g., given the following input with `A` being the current
   -- lookahead symbol, this function moves the cursor to `B` and returns
   -- `A`.
   --
   --
   -- A B
   -- ^
   --
   --
   -- If the parser is not in error recovery mode, the consumed symbol is added
   -- to the parse tree using _ParserRuleContext#addChild (TerminalNode)_, and
   -- _org.antlr.v4.runtime.tree.ParseTreeListener#visitTerminal_ is called on any parse listeners.
   -- If the parser __is__ in error recovery mode, the consumed symbol is
   -- added to the parse tree using _#createErrorNode (ParserRuleContext, Token)_ then
   -- _ParserRuleContext#addErrorNode (ErrorNode)_ and
   -- _org.antlr.v4.runtime.tree.ParseTreeListener#visitErrorNode_ is called on any parse
   -- listeners.
   --
   -- @discardableResult
   -- public
   function consume (This : Parser) return Token;

   -- How to create a token leaf node associated with a parent.
   -- Typically, the terminal node to create is not a function of the parent.
   --
   -- public
   function createTerminalNode (This : Parser; parent: ParserRuleContext; t: Token) return TerminalNode
      is (TerminalNodeImpl (t));

   -- How to create an error node, given a token, associated with a parent.
   -- Typically, the error node to create is not a function of the parent.
   --
   -- public
   function createErrorNode (This : Parser; parent: ParserRuleContext; t: Token) return ErrorNode
      is (ErrorNode (t));


   --
   -- Always called by generated parsers upon ento a rule. Access field;
   -- _#_ctx_ get the current context.
   --
   -- public
   procedure enterRule (This : Parser;
                        localctx : ParserRuleContext;
                        state : Integer;
                        ruleIndex : Integer);

   -- public
   procedure exitRule (This : Parser);
      ctx : ParserRuleContext := This.ctx;

   -- public
   procedure enterOuterAlt (This : Parser; localctx : ParserRuleContext; altNum : Integer);

   --
   -- Get the precedence level for the top-most precedence rule.
   --
   -- * Returns: The precedence level for the top-most precedence rule, or -1 if
   -- the parser context is not nested within a precedence rule.
   --
   -- public final
   function getPrecedence (This : Parser) return Integer;

   --
   --
   --
   --
   -- public
   procedure enterRecursionRule (This : Parser; localctx : ParserRuleContext; ruleIndex : Integer);
   pragma Obsolescent ("Use 'enterRecursionRule (org.antlr.v4.runtime.ParserRuleContext, Integer, Integer, Integer)' instead.");

   -- public
   procedure enterRecursionRule (This : Parser; localctx : ParserRuleContext; state : Integer; ruleIndex : Integer; precedence : Integer);

   -- Like _#enterRule_ but for recursive rules.
   -- Make the current context the child of the incoming localctx.
   --
   -- public
   procedure pushNewRecursionContext (This : Parser;
                                      localctx : ParserRuleContext;
                                      state : Integer;
                                      ruleIndex : Integer);

   -- public
   procedure unrollRecursionContexts (This : Parser; parentctx : Optional_ParserRuleContext);

   -- public
   function getInvokingContext (This : Parser; ruleIndex : Integer) return Optional_ParserRuleContext;

   -- public
   function getContext (This : Parser) return Optional_ParserRuleContext
      is (This.ctx);

   -- public
   procedure setContext (This : Parser; ctx : ParserRuleContext);

   overriding
   -- open
   function precpred (This : Parser; localctx : Optional_RuleContext; precedence : Integer) return Boolean
      is (precedence >= Value (This.precedenceStack.peek));

   -- public
   function inContext (This : Parser; context : UString) return Boolean
      is (False); -- TODO: useful in parser?

   -- Given an AmbiguityInfo object that contains information about an
   -- ambiguous decision event, return the list of ambiguous parse trees.
   -- An ambiguity occurs when a specific token sequence can be recognized
   -- in more than one way by the grammar. These ambiguities are detected only
   -- at decision points.
   --
   -- The list of trees includes the actual interpretation (that for
   -- the minimum alternative number) and all ambiguous alternatives.
   -- The actual interpretation is always first.
   --
   -- This method reuses the same physical input token stream used to
   -- detect the ambiguity by the original parser in the first place.
   -- This method resets/seeks within but does not alter originalParser.
   -- The input position is restored upon exit from this method.
   -- Parsers using a _org.antlr.v4.runtime.UnbufferedTokenStream_ may not be able to
   -- perform the necessary save This.index / seek (saved_index) operation.
   --
   -- The trees are rooted at the node whose start .. stop token indices
   -- include the start and stop indices of this ambiguity event. That is,
   -- the trees returns will always include the complete ambiguous subphrase
   -- identified by the ambiguity event.
   --
   -- Be aware that this method does NOT notify error or parse listeners as
   -- it would trigger duplicate or otherwise unwanted events.
   --
   -- This uses a temporary ParserATNSimulator and a ParserInterpreter
   -- so we don't mess up any statistics, event lists, etc ..
   -- The parse tree constructed while identifying/making ambiguityInfo is
   -- not affected by this method as it creates a new parser interp to
   -- get the ambiguous interpretations.
   --
   -- Nodes in the returned ambig trees are independent of the original parse
   -- tree (constructed while identifying/creating ambiguityInfo).
   --
   -- * Since: 4.5.1
   --
   -- * Parameter originalParser: The parser used to create ambiguityInfo; it
   -- is not modified by this routine and can be either
   -- a generated or interpreted parser. It's token
   -- stream *is* reset/seek ()'d.
   -- * Parameter ambiguityInfo:  The information about an ambiguous decision event
   -- for which you want ambiguous parse trees.
   -- * Parameter startRuleIndex: The start rule for the entire grammar, not
   -- the ambiguous decision. We re-parse the entire input
   -- and so we need the original start rule.
   --
   -- * Throws: org.antlr.v4.runtime.RecognitionException upon syntax error while matching
   -- ambig input.
   -- * Returns:               The list of all possible interpretations of
   -- the input for the decision in ambiguityInfo.
   -- The actual interpretation chosen by the parser
   -- is always given first because this method
   -- retests the input in alternative order and
   -- ANTLR always resolves ambiguities by choosing
   -- the first alternative that matches the input.
   --
   --
--   public class procedure getAmbiguousParseTrees (originalParser : Parser;
--                                                 _ ambiguityInfo : AmbiguityInfo;
--                                                 _ startRuleIndex : Integer) return Array<ParserRuleContext>  --; RecognitionException
--   {
--      trees : array (<>) of ParserRuleContext := Array<ParserRuleContext> ();
--      saveTokenInputPosition : Integer := originalParser.getTokenStream ().index ();
--      --{;
--         -- Create a new parser interpreter to parse the ambiguous subphrase
--         parser : ParserInterpreter;
--         if ( originalParser is ParserInterpreter ) {
--            parser := ParserInterpreter ( ParserInterpreter (originalParser));
--         }
--         else {
--            serializedAtn : Character_List := ATNSerializer.getSerializedAsChars (originalParser.getATN ());
--            deserialized : ATN := This.ATNDeserializer.deserialize (serializedAtn);
--            parser := ParserInterpreter (originalParser.getGrammarFileName (),
--                                    originalParser.getVocabulary (),
--                                     originalParser.getRuleNames () ,
--                                    deserialized,
--                                    originalParser.getTokenStream ());
--         }
--
--         -- Make sure that we don't get any error messages from using this temporary parser
--         parser.removeErrorListeners ();
--         parser.removeParseListeners ();
--         parser.getInterpreter ()!.setPredictionMode (PredictionModes.LL_EXACT_AMBIG_DETECTION);
--
--         -- get ambig trees
--         alt : Integer := ambiguityInfo.ambigAlts.firstSetBit ();
--         while  alt>=0  loop
--            -- re-parse entire input for all ambiguous alternatives
--            -- (don't have to do first as it's been parsed, but do again for simplicity
--            --  using this temp parser.);
--            parser.reset ();
--            parser.getTokenStream ().seek (0); -- rewind the input all the way for re-parsing
--            parser.overrideDecision := ambiguityInfo.decision;
--            parser.overrideDecisionInputIndex := ambiguityInfo.startIndex;
--            parser.overrideDecisionAlt := alt;
--            t : ParserRuleContext := parser.parse (startRuleIndex);
--            ambigSubTree : ParserRuleContext =
--               Trees.getRootOfSubtreeEnclosingRegion (t, ambiguityInfo.startIndex, ambiguityInfo.stopIndex)!;
--            trees.append (ambigSubTree);
--            alt := ambiguityInfo.ambigAlts.nextSetBit (alt+1);
--         end loop;
--      --}
--      defer {
--         originalParser.getTokenStream ().seek (saveTokenInputPosition);
--      }
--
--      return trees;
--   }

   --
   -- Checks whether or not `symbol` can follow the current state in the
   -- ATN. The behavior of this method is equivalent to the following, but is
   -- implemented such that the complete context-sensitive follow set does not
   -- need to be explicitly constructed.
   --
   --
   -- return This.getExpectedTokens.contains (symbol);
   --
   --
   -- * Parameter symbol: the symbol type to check
   -- * Returns: `True` if `symbol` can follow the current state in
   -- the ATN, otherwise `False`.
   --
   -- public
   function isExpectedToken (This : Parser; symbol : Integer) return Boolean;

   --
   -- Computes the set of input symbols which could follow the current parser
   -- state and context, as given by _#getState_ and _#getContext_,
   -- respectively.
   --
   -- * SeeAlso: org.antlr.v4.runtime.atn.ATN#getExpectedTokens (int, org.antlr.v4.runtime.RuleContext);
   --
   -- public
   function getExpectedTokens (This : Parser) return IntervalSet
      is (This.getATN.getExpectedTokens (This.getState, Value (This.getContext)));

   -- public
   function getExpectedTokensWithinCurrentRule (This : Parser) return IntervalSet;

   -- Get a rule's index (i.e., `RULE_ruleName` field) or -1 if not found.
   -- public
   function getRuleIndex (This : Parser; ruleName : UString) return Integer
      is (Value (This.getRuleIndexMap.Element (ruleName), Default => -1));

   -- public
   function getRuleContext (This : Parser) return Optional_ParserRuleContext
      is (This.ctx);

   -- Return List<UString> of the rule names in your parser instance
   -- leading up to a call to the current rule.  You could override if
   -- you want more details such as the file/line info of where
   -- in the ATN a rule is invoked.
   --
   -- This is very useful for error messages.
   --
   -- public
   function getRuleInvocationStack (This : Parser) return UString_List
      is (getRuleInvocationStack (This.ctx));

   -- public
   function getRuleInvocationStack (This : Parser; p : Optional_RuleContext) return UString_List;

   -- For debugging and other purposes.
   -- public
   function getDFAStrings (This : Parser) return UString_List;

   -- For debugging and other purposes.
   -- public
   procedure dumpDFA (This : Parser);

   -- public
   function getSourceName (This : Parser) return UString
      is (This.input.getSourceName);

   overriding
   -- open
   function getParseInfo (This : Parser) return Optional_ParseInfo;

   -- public
   procedure setProfile (This : Parser; profile : Boolean);

   -- During a parse is sometimes useful to listen in on the rule enand exit;
   -- events as well as token matches. This is for quick and dirty debugging.
   --
   -- public
   procedure setTrace (This : Parser; trace : Boolean);

   --
   -- Gets whether a _org.antlr.v4.runtime.Parser.TraceListener_ is registered as a parse listener
   -- for the parser.
   --
   -- * SeeAlso: #setTrace (boolean);
   --
   -- public
   function isTrace (This : Parser) return Boolean
      is (Is_Valid (tracer));

private
   --
   -- This field maps from the serialized ATN string to the deserialized _org.antlr.v4.runtime.atn.ATN_ with
   -- bypass alternatives.
   --
   -- * SeeAlso: `ATNDeserializationOptions.generateRuleBypassTransitions`
   --
   -- private
   bypassAltsAtnCache : Optional_ATN;

   --
   -- mutex for bypassAltsAtnCache updates
   --
   -- private
   bypassAltsAtnCacheMutex : constant := Mutex.Synchronised;

end ANTLR.Runtime.Recognizers.Parsers;
