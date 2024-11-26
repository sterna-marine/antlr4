-- 
-- 
-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
-- 
-- 

with Foundation;

--
-- This field maps from the serialized ATN string to the deserialized _org.antlr.v4.runtime.atn.ATN_ with
-- bypass alternatives.
--
-- - SeeAlso: `ATNDeserializationOptions.generateRuleBypassTransitions`
--
-- private
bypassAltsAtnCache : Optional_ATN; := null;

--
-- mutex for bypassAltsAtnCache updates
--
private bypassAltsAtnCacheMutex : constant := Mutex()


--
-- This is all the parsing support code essentially; most of it is error recovery stuff.
-- 

    -- public
    type TraceListener is new ParseTreeListener with record
        host: Parser
      end record;

        procedure Init(Self : in out TraceListener; host : Parser) {
            self.host := host
        end Init;

        -- public
        procedure enterEveryRule (This : TraceListener; ctx : ParserRuleContext) is
        begin
            ruleName : constant := host.getRuleNames()[ctx.getRuleIndex()]
            lt1 : constant := host._input.LT(1)!.getText()!;
            print("enter   \(ruleName), LT(1)=\(lt1)")
        end if;

        -- public
        procedure visitTerminal (This :TraceListener; node : TerminalNode) is
        begin
            print("consume \(String(describing: node.getSymbol())) rule \(host.getRuleNames()[host._ctx!.getRuleIndex()])")
        end if;

        -- public
        procedure visitErrorNode (This :TraceListener; node : ErrorNode) is
        begin
         null;
        end if;

        -- public
        procedure exitEveryRule (This :TraceListener; ctx : ParserRuleContext) is
        begin
            ruleName : constant := host.getRuleNames()[ctx.getRuleIndex()]
            lt1 : constant := host._input.LT(1)!.getText()!;
            print("exit    \(ruleName), LT(1)=\(lt1)")
        end if;
    end if;

    -- public
    type TrimToSizeListener is new ParseTreeListener with record

        -- public static 
        INSTANCE : constant := TrimToSizeListener()
   end record;

        -- public
        procedure enterEveryRule (This : TrimToSizeListener; ctx : ParserRuleContext) is
        begin
         null;
        end if;

        -- public
        procedure visitTerminal (This : TrimToSizeListener; node : TerminalNode) is
        begin
         null;
        end if;

        -- public
        procedure visitErrorNode (This : TrimToSizeListener; node : ErrorNode) is
        begin
         null;
        end if;

        -- public
        procedure exitEveryRule (This : TrimToSizeListener; ctx : ParserRuleContext) is
        begin
            null; -- TODO: Print exit info.
        end if;
   
-- open
type Parser is new Recognizer<ParserATNSimulator> with record
    -- public static 
    EOF : constant := -1
    -- public static 
    var ConsoleError := True;

    TraceListener : TraceListener;
   end record;

   TrimToSizeListener : TrimToSizeListener;
    
    -- 
    -- The error handling strategy for the parser. The default value is a new
    -- instance of _org.antlr.v4.runtime.DefaultErrorStrategy_.
    -- 
    -- - SeeAlso: #getErrorHandler
    -- - SeeAlso: #setErrorHandler
    -- 
    -- public
    _errHandler : ANTLRErrorStrategy := DefaultErrorStrategy()

    -- 
    -- The input stream.
    -- 
    -- - SeeAlso: #getInputStream
    -- - SeeAlso: #setInputStream
    -- 
    -- public
    _input : TokenStream!

    -- internal
    _precedenceStack : Stack<Int> := {
        var precedenceStack := Stack<Int> ()
        precedenceStack.push(0)
        return precedenceStack
    end if;()


    -- 
    -- The _org.antlr.v4.runtime.ParserRuleContext_ object for the currently executing rule.
    -- This is always non-null during the parsing process.
    -- 
    -- public
    _ctx : Optional_ParserRuleContext; := null;

    -- 
    -- Specifies whether or not the parser should construct a parse tree during
    -- the parsing process. The default value is `True`.
    -- 
    -- - SeeAlso: #getBuildParseTree
    -- - SeeAlso: #setBuildParseTree
    -- 
    -- internal
    _buildParseTrees : Boolean := True;

    -- 
    -- When _#setTrace_`(True)` is called, a reference to the
    -- _org.antlr.v4.runtime.Parser.TraceListener_ is stored here so it can be easily removed in a
    -- later call to _#setTrace_`(False)`. The listener itself is
    -- implemented as a parser listener so this field is not directly used by
    -- other parser methods.
    -- 
    -- private
    _tracer : Optional_TraceListener;

    -- 
    -- The list of _org.antlr.v4.runtime.tree.ParseTreeListener_ listeners registered to receive
    -- events during the parse.
    -- 
    -- - SeeAlso: #addParseListener
    -- 
    -- public
    _parseListeners : Array<ParseTreeListener>?

    -- 
    -- The number of syntax errors reported during parsing. This value is
    -- incremented each time _#notifyErrorListeners_ is called.
    -- 
    -- internal
    _syntaxErrors : Integer := 0
end record;

    -- public 
    procedure Init (Self : in out Parser; input : TokenStream) {
        self._input := input
        super.init()
        setInputStream(input);
    end if;

    -- reset the parser's state
    -- public
    procedure reset (This : Parser) is
begin
        getInputStream()?.seek(0);
        _errHandler.reset(self)
        _ctx := null;
        _syntaxErrors := 0
        setTrace(False)
        _precedenceStack.clear()
        _precedenceStack.push(0)

        --  getInterpreter();
        if interpreter : constant := _interp then
            interpreter.reset();
        end if;
    end if;

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
    -- the parse tree by calling _#createErrorNode(ParserRuleContext, Token)_ then
    -- _ParserRuleContext#addErrorNode(ErrorNode)_.
    -- 
    -- - Parameter ttype: the token type to match
    -- - Throws: org.antlr.v4.runtime.RecognitionException if the current input symbol did not match
    -- `ttype` and the error strategy could not recover from the
    -- mismatched symbol
    -- - Returns: the matched symbol
    -- 
    @discardableResult
    -- public
    function match (This : Parser; ttype : Integer) return Token is
begin
        var t := getCurrentToken();
        if t.getType() == ttype then
            _errHandler.reportMatch(self)
            consume();
        else
            t := _errHandler.recoverInline(self);
            if _buildParseTrees and then t.getTokenIndex() == -1 then
                -- we must have conjured up a new token during single token insertion
                -- if it's not the current symbol
                _ctx!.addErrorNode(createErrorNode(parent: _ctx!, t: t));
            end if;
        end if;
        return t
    end if;

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
    -- the parse tree by calling _#createErrorNode(ParserRuleContext, Token)_ then
    -- _ParserRuleContext#addErrorNode(ErrorNode)_.
    -- 
    -- - Throws: org.antlr.v4.runtime.RecognitionException if the current input symbol did not match
    -- a wildcard and the error strategy could not recover from the mismatched
    -- symbol
    -- - Returns: the matched symbol
    -- 
    @discardableResult
    -- public
    function matchWildcard (This : Parser) return Token is
begin
        var t := getCurrentToken();
        if t.getType() > 0 then
            _errHandler.reportMatch(self)
            consume();
        else
            t := _errHandler.recoverInline(self);
            if _buildParseTrees and then t.getTokenIndex() == -1 then
                -- we must have conjured up a new token during single token insertion
                -- if it's not the current symbol
                _ctx!.addErrorNode(createErrorNode(parent: _ctx!, t: t));
            end if;
        end if;

        return t
    end if;

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
    procedure setBuildParseTree (This : Parser; buildParseTrees  : Boolean) is
    begin
        self._buildParseTrees := buildParseTrees
    end if;

    -- 
    -- Gets whether or not a complete parse tree will be constructed while
    -- parsing. This property is `True` for a newly constructed parser.
    -- 
    -- - Returns: `True` if a complete parse tree will be constructed while
    -- parsing, otherwise `False`
    -- 
    -- public
    function getBuildParseTree (This : Parser) return Boolean is
begin
        return _buildParseTrees
    end if;

    -- 
    -- Trim the internal lists of the parse tree during parsing to conserve memory.
    -- This property is set to `False` by default for a newly constructed parser.
    -- 
    -- - Parameter trimParseTrees: `True` to trim the capacity of the _org.antlr.v4.runtime.ParserRuleContext#children_
    -- list to its size after a rule is parsed.
    -- 
    -- public
    procedure setTrimParseTree (This : Parser; trimParseTrees  : Boolean) is
    begin
        if trimParseTrees then
            if getTrimParseTree() then
                return;
            end if;
            addParseListener(TrimToSizeListener.INSTANCE)
        else
            removeParseListener(TrimToSizeListener.INSTANCE);
        end if;
    end if;

    -- 
    -- - Returns: `True` if the _org.antlr.v4.runtime.ParserRuleContext#children_ list is trimmed
    -- using the default _org.antlr.v4.runtime.Parser.TrimToSizeListener_ during the parse process.
    -- 
    -- public
    function getTrimParseTree (This : Parser) return Boolean is
begin
        return not getParseListeners().filter({ $0 === TrimToSizeListener.INSTANCE end if;).isEmpty
    end if;

    -- public
    function getParseListeners () return [ParseTreeListener] {
        return _parseListeners ?? [ParseTreeListener]()
    end if;

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
    -- - Parameter listener: the listener to add
    -- 
    -- public
    procedure addParseListener (This : Parser; listener : ParseTreeListener) is
    begin
        if _parseListeners = null then
            _parseListeners := [ParseTreeListener]();
        end if;

        _parseListeners!.append(listener)
    end if;

    -- 
    -- Remove `listener` from the list of parse listeners.
    -- 
    -- If `listener` is `null` or has not been added as a parse
    -- listener, this method does nothing.
    -- 
    -- - SeeAlso: #addParseListener
    -- 
    -- - Parameter listener: the listener to remove
    -- 

    -- public
    procedure removeParseListener (This : Parser; listener : Optional_ParseTreeListener;) is
    begin
        if _parseListeners /= null then
            if not _parseListeners!.filter({ $0 === listener end if;).isEmpty then
                _parseListeners := _parseListeners!.filter({
                    $0 !== listener
                end if;)
                if _parseListeners!.isEmpty then
                    _parseListeners := null;
                end if;
            end if;
        end if;
    end if;

    -- 
    -- Remove all parse listeners.
    -- 
    -- - SeeAlso: #addParseListener
    -- 
    -- public
    procedure removeParseListeners (This : Parser) is
begin
        _parseListeners := null;
    end if;

    -- 
    -- Notify any parse listeners of an enter rule event.
    -- 
    -- - SeeAlso: #addParseListener
    -- 
    -- public
    procedure triggerEnterRuleEvent (This : Parser; ) is
begin
        if _parseListeners : constant := _parseListeners, _ctx : constant := _ctx then
            for listener: ParseTreeListener in _parseListeners loop
                listener.enterEveryRule(_ctx);
                _ctx.enterRule(listener)
            end loop;
        end if;
    end if;

    -- 
    -- Notify any parse listeners of an exit rule event.
    -- 
    -- - SeeAlso: #addParseListener
    -- 
    -- public
    procedure triggerExitRuleEvent (This : Parser; ) is
begin
        -- reverse order walk of listeners
        if _parseListeners : constant := _parseListeners, _ctx : constant := _ctx then
            for listener in _parseListeners.reversed() loop
                _ctx.exitRule(listener)
                listener.exitEveryRule(_ctx);
            end loop;
        end if;
    end if;

    -- 
    -- Gets the number of syntax errors reported during parsing. This value is
    -- incremented each time _#notifyErrorListeners_ is called.
    -- 
    -- - SeeAlso: #notifyErrorListeners
    -- 
    -- public
    function getNumberOfSyntaxErrors (This : Parser) return Integer is
begin
        return _syntaxErrors
    end if;

    override
    -- open
    function getTokenFactory (This : Parser; ) return TokenFactory is
begin
        return _input.getTokenSource().getTokenFactory()
    end if;

    -- Tell our token source and error strategy about a new way to create tokens.
    override
    -- open
    procedure setTokenFactory (This : Parser; factory : TokenFactory) is
    begin
        _input.getTokenSource().setTokenFactory(factory)
    end if;

    -- 
    -- The ATN with bypass alternatives is expensive to create so we create it
    -- lazily.
    --
    -- public
    function getATNWithBypassAlts (TThis : Parser; ) return ATN is
begin
        serializedAtn : constant := getSerializedATN()

        return bypassAltsAtnCacheMutex.synchronized {
            if cachedResult : constant := bypassAltsAtnCache then
                return cachedResult;
            end if;

            var opts := ATNDeserializationOptions()
            opts.generateRuleBypassTransitions := True;
            result : constant := try! ATNDeserializer(opts).deserialize(serializedAtn)
            bypassAltsAtnCache := result
            return bypassAltsAtnCache!
        end if;
    end if;

    -- 
    -- The preferred method of getting a tree pattern. For example, here's a
    -- sample use:
    -- 
    -- 
    -- ParseTree t := parser.expr();
    -- ParseTreePattern p := parser.compileParseTreePattern("&lt;ID&gt;+0", MyParser.RULE_expr);
    -- ParseTreeMatch m := p.match(t);
    -- String id := m.get("ID");
    -- 
    -- 
    -- public
    function compileParseTreePattern (This : Parser; pattern : String; patternRuleIndex : Integer) return ParseTreePattern is
begin
        if tokenStream : constant Token := getTokenStream() then;
            tokenSource : constant := tokenStream.getTokenSource()
            if lexer : constant := tokenSource as? Lexer then
                return compileParseTreePattern(pattern, patternRuleIndex, lexer);
            end if;
        end if;
        raise ANTLRError.unsupportedOperation with "Parser can't discover a lexer to use";
    end if;

    -- 
    -- The same as _#compileParseTreePattern(String, int)_ but specify a
    -- _org.antlr.v4.runtime.Lexer_ rather than trying to deduce it from this parser.
    -- 
    -- public
    procedure compileParseTreePattern (This : Parser; pattern : String; patternRuleIndex : Integer;
                                        lexer : Lexer) return ParseTreePattern is
begin
        m : constant := ParseTreePatternMatcher(lexer, self)
        return m.compile(pattern, patternRuleIndex);
    end if;


    -- public
    function getErrorHandler (This : Parser; ) return ANTLRErrorStrategy is
begin
        return _errHandler
    end if;

    -- public
    procedure setErrorHandler (This : Parser; handler : ANTLRErrorStrategy) is
    begin
        self._errHandler := handler
    end if;

    override
    -- open
    function getInputStream (This : Parser) return Optional_IntStream is
   begin
        return getTokenStream()
    end if;

    override
    -- public final
    procedure setInputStream (This : Parser; input : IntStream) is
    begin
        setTokenStream(input as! TokenStream);
    end if;

    -- public
    function getTokenStream (This : Parser) return Optional_TokenStream is
   begin
        return _input
    end if;

    -- Set the token stream and reset the parser.
    -- public
    procedure setTokenStream (This : Parser; input : TokenStream) is
    begin
        --TODO self._input := null;
        self._input := null;
        reset();
        self._input := input
    end if;

    -- Match needs to return the current input symbol, which gets put
    -- into the label for the associated token ref; e.g., x=ID.
    -- 

    -- public
    function getCurrentToken (This : Parser) return Token is
begin
        return _input.LT(1)!;
    end if;

    -- public final
    procedure notifyErrorListeners (This : Parser; msg : String) is
    begin
        token : constant := try? getCurrentToken()
        notifyErrorListeners(token, msg, null)
    end if;

    -- public
    procedure notifyErrorListeners (This : Parser; offendingToken : Optional_Token; msg : String; e : Optional_AnyObject;) is
    begin
        _syntaxErrors := @ + 1;
        var line := -1
        var charPositionInLine := -1
        if offendingToken : constant Token := offendingToken then;
            line := offendingToken.getLine()
            charPositionInLine := offendingToken.getCharPositionInLine()
        end if;

        listener : constant := getErrorListenerDispatch()
        listener.syntaxError(self, offendingToken, line, charPositionInLine, msg, e)
    end if;

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
    -- to the parse tree using _ParserRuleContext#addChild(TerminalNode)_, and
    -- _org.antlr.v4.runtime.tree.ParseTreeListener#visitTerminal_ is called on any parse listeners.
    -- If the parser __is__ in error recovery mode, the consumed symbol is
    -- added to the parse tree using _#createErrorNode(ParserRuleContext, Token)_ then
    -- _ParserRuleContext#addErrorNode(ErrorNode)_ and
    -- _org.antlr.v4.runtime.tree.ParseTreeListener#visitErrorNode_ is called on any parse
    -- listeners.
    -- 
    @discardableResult
    -- public
    function consume (This : Parser; ) return Token is
begin
        o : constant Token := getCurrentToken();
        if o.getType() /= Parser.EOF then
            getInputStream()!.consume();
        end if;
        guard _ctx : constant := _ctx else {
            return o
        end if;
        hasListener : constant := _parseListeners /= null and then not _parseListeners!.isEmpty

        if _buildParseTrees or else hasListener then
            if _errHandler.inErrorRecoveryMode(self) then
                node : constant := createErrorNode(parent: _ctx, t: o)
                _ctx.addErrorNode(node)
                if _parseListeners : constant := _parseListeners then
                    for listener in _parseListeners loop
                        listener.visitErrorNode(node)
                    end loop;
                end if;
            else
                node : constant := createTerminalNode(parent: _ctx, t: o)
                _ctx.addChild(node)
                if _parseListeners : constant := _parseListeners then
                    for listener in _parseListeners loop
                        listener.visitTerminal(node)
                    end loop;
                end if;
            end if;
        end if;
        return o
    end if;

    -- How to create a token leaf node associated with a parent.
    -- Typically, the terminal node to create is not a function of the parent.
    -- 
    -- - Since: 4.7
    -- 
    -- public
    function createTerminalNode (This : Parser; parent: ParserRuleContext, t: Token) return TerminalNode is
begin
        return TerminalNodeImpl(t)
    end if;

    -- How to create an error node, given a token, associated with a parent.
    -- Typically, the error node to create is not a function of the parent.
    -- 
    -- - Since: 4.7
    -- 
    -- public
    function createErrorNode (This : Parser; parent: ParserRuleContext, t: Token) return ErrorNode is
begin
        return ErrorNode(t)
    end if;

    -- internal
    procedure addContextToParseTree (This : Parser) is
begin

        -- add current context to parent if we have a parent
        if parent : constant := _ctx?.parent as? ParserRuleContext then
            parent.addChild(_ctx!);
        end if;
    end if;

    -- 
    -- Always called by generated parsers upon ento a rule. Access field;
    -- _#_ctx_ get the current context.
    -- 
    -- public
    procedure enterRule (This : Parser; localctx : ParserRuleContext; state : Integer; ruleIndex : Integer) is
    begin
        setState(state)
        _ctx := localctx
        _ctx!.start := _input.LT(1);
        if _buildParseTrees then
            addContextToParseTree();
        end if;
    end if;

    -- public
    procedure exitRule (This : Parser) is
begin
        guard ctx : constant := _ctx else {
            return
        end if;
        ctx.stop := _input.LT(-1);
        -- trigger event on _ctx, before it reverts to parent
        if _parseListeners /= null then
            triggerExitRuleEvent();
        end if;
        setState(ctx.invokingState)
        _ctx := ctx.parent as? ParserRuleContext
    end if;

    -- public
    procedure enterOuterAlt (This : Parser; localctx : ParserRuleContext; altNum : Integer) is
    begin
        localctx.setAltNumber(altNum)
        -- if we have new localctx, make sure we replace existing ctx
        -- that is previous child of parse tree
        if _buildParseTrees and then _ctx! !== localctx then
            if parent : constant := _ctx?.parent as? ParserRuleContext then
                parent.removeLastChild()
                parent.addChild(localctx)
            end if;
        end if;
        _ctx := localctx
        if _parseListeners /= null then
            triggerEnterRuleEvent();
        end if;
    end if;

    -- 
    -- Get the precedence level for the top-most precedence rule.
    -- 
    -- - Returns: The precedence level for the top-most precedence rule, or -1 if
    -- the parser context is not nested within a precedence rule.
    -- 
    -- public final
    function getPrecedence (This : Parser) return Integer is
begin
        if _precedenceStack.isEmpty then
            return -1;
        end if;

        return _precedenceStack.peek() ?? -1
    end if;

    -- 
    -- Use
    -- _#enterRecursionRule(org.antlr.v4.runtime.ParserRuleContext, int, int, int)_ instead.
    -- 
    -- 
    -- /@Deprecated
    -- 
    -- public
    procedure enterRecursionRule (This : Parser; localctx : ParserRuleContext; ruleIndex : Integer) is
    begin
        enterRecursionRule(localctx, getATN().ruleToStartState[ruleIndex].stateNumber, ruleIndex, 0);
    end if;

    -- public
    procedure enterRecursionRule (This : Parser; localctx : ParserRuleContext; state : Integer; ruleIndex : Integer; precedence : Integer) is
    begin
        setState(state)
        _precedenceStack.push(precedence)
        _ctx := localctx
        _ctx!.start := _input.LT(1);
        if _parseListeners /= null then
            triggerEnterRuleEvent(); -- simulates rule enfor left-recursive rules;
        end if;
    end if;

    -- Like _#enterRule_ but for recursive rules.
    -- Make the current context the child of the incoming localctx.
    -- 
    -- public
    procedure pushNewRecursionContext (This : Parser; localctx : ParserRuleContext; state : Integer; ruleIndex : Integer) is
    begin
        previous : constant := _ctx!
        previous.parent := localctx
        previous.invokingState := state
        previous.stop := _input.LT(-1);

        _ctx := localctx
        _ctx!.start := previous.start
        if _buildParseTrees then
            _ctx!.addChild(previous);
        end if;

        if _parseListeners /= null then
            triggerEnterRuleEvent(); -- simulates rule enfor left-recursive rules;
        end if;
    end if;

    -- public
    procedure unrollRecursionContexts (This : Parser; _parentctx : Optional_ParserRuleContext;) is
    begin
        _precedenceStack.pop()
        _ctx!.stop := _input.LT(-1);
        retctx : constant := _ctx! -- save current ctx (return value)

        -- unroll so _ctx is as it was before call to recursive method
        if _parseListeners /= null then
            while ctxWrap : constant := _ctx, ctxWrap !== _parentctx loop
                triggerExitRuleEvent();
                _ctx := ctxWrap.parent as? ParserRuleContext
            end loop;
        else
            _ctx := _parentctx;
        end if;

        -- hook into tree
        retctx.parent := _parentctx

        if _buildParseTrees and then _parentctx /= null then
            -- add return ctx into invoking rule's tree
            _parentctx!.addChild(retctx)
        end if;
    end if;

    -- public
    function getInvokingContext (This : Parser; ruleIndex : Integer) return Optional_ParserRuleContext is
   begin
        var p := _ctx
        while pWrap : constant := p loop
            if pWrap.getRuleIndex() == ruleIndex then
                return pWrap;
            end if;
            p := pWrap.parent as? ParserRuleContext
        end loop;
        return null;
    end if;

    -- public
    function getContext (This : Parser) return Optional_ParserRuleContext is
   begin
        return _ctx
    end if;

    -- public
    procedure setContext (This : Parser; ctx : ParserRuleContext) is
    begin
        _ctx := ctx
    end if;

    override
    -- open
    function precpred (This : Parser; localctx : Optional_RuleContext; precedence : Integer) return Boolean is
begin
        return precedence >= _precedenceStack.peek()!
    end if;

    -- public
    function inContext (This : Parser; context : String) return Boolean is
begin
        -- TODO: useful in parser?
        return False;
    end if;

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
    -- perform the necessary save index() / seek(saved_index) operation.
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
    -- - Since: 4.5.1
    -- 
    -- - Parameter originalParser: The parser used to create ambiguityInfo; it
    -- is not modified by this routine and can be either
    -- a generated or interpreted parser. It's token
    -- stream *is* reset/seek()'d.
    -- - Parameter ambiguityInfo:  The information about an ambiguous decision event
    -- for which you want ambiguous parse trees.
    -- - Parameter startRuleIndex: The start rule for the entire grammar, not
    -- the ambiguous decision. We re-parse the entire input
    -- and so we need the original start rule.
    -- 
    -- - Throws: org.antlr.v4.runtime.RecognitionException upon syntax error while matching
    -- ambig input.
    -- - Returns:               The list of all possible interpretations of
    -- the input for the decision in ambiguityInfo.
    -- The actual interpretation chosen by the parser
    -- is always given first because this method
    -- retests the input in alternative order and
    -- ANTLR always resolves ambiguities by choosing
    -- the first alternative that matches the input.
    -- 
    -- 
--	public class procedure getAmbiguousParseTrees (originalParser : Parser;
--																 _ ambiguityInfo : AmbiguityInfo;
--																 _ startRuleIndex : Integer) return Array<ParserRuleContext>  --; RecognitionException
--	{
--		var trees : Array<ParserRuleContext> := Array<ParserRuleContext> ();
--		var saveTokenInputPosition : Integer := originalParser.getTokenStream().index();
--		--{;
--			-- Create a new parser interpreter to parse the ambiguous subphrase
--			var parser : ParserInterpreter;
--			if ( originalParser is ParserInterpreter ) {
--				parser := ParserInterpreter( originalParser as! ParserInterpreter);
--			}
--			else {
--				var serializedAtn : [Character] := ATNSerializer.getSerializedAsChars(originalParser.getATN());
--				var deserialized : ATN := ATNDeserializer().deserialize(serializedAtn);
--				parser := ParserInterpreter(originalParser.getGrammarFileName(),
--											   originalParser.getVocabulary(),
--											    originalParser.getRuleNames() ,
--											   deserialized,
--											   originalParser.getTokenStream());
--			}
--
--			-- Make sure that we don't get any error messages from using this temporary parser
--			parser.removeErrorListeners();
--			parser.removeParseListeners();
--			parser.getInterpreter()!.setPredictionMode(PredictionMode.LL_EXACT_AMBIG_DETECTION);
--
--			-- get ambig trees
--			var alt : Integer := ambiguityInfo.ambigAlts.firstSetBit();
--			while  alt>=0  loop
--				-- re-parse entire input for all ambiguous alternatives
--				-- (don't have to do first as it's been parsed, but do again for simplicity
--				--  using this temp parser.)
--				parser.reset();
--				parser.getTokenStream().seek(0); -- rewind the input all the way for re-parsing
--				parser.overrideDecision := ambiguityInfo.decision;
--				parser.overrideDecisionInputIndex := ambiguityInfo.startIndex;
--				parser.overrideDecisionAlt := alt;
--				var t : ParserRuleContext := parser.parse(startRuleIndex);
--				var ambigSubTree : ParserRuleContext =
--					Trees.getRootOfSubtreeEnclosingRegion(t, ambiguityInfo.startIndex, ambiguityInfo.stopIndex)!;
--				trees.append(ambigSubTree);
--				alt := ambiguityInfo.ambigAlts.nextSetBit(alt+1);
--			end loop;
--		--}
--		defer {
--			originalParser.getTokenStream().seek(saveTokenInputPosition);
--		}
--
--		return trees;
--	}

    -- 
    -- Checks whether or not `symbol` can follow the current state in the
    -- ATN. The behavior of this method is equivalent to the following, but is
    -- implemented such that the complete context-sensitive follow set does not
    -- need to be explicitly constructed.
    -- 
    -- 
    -- return getExpectedTokens().contains(symbol);
    -- 
    -- 
    -- - Parameter symbol: the symbol type to check
    -- - Returns: `True` if `symbol` can follow the current state in
    -- the ATN, otherwise `False`.
    -- 
    -- public
    function isExpectedToken (This : Parser; symbol : Integer) return Boolean is
begin
        atn : constant := getInterpreter().atn
        ctx : Optional_ParserRuleContext; := _ctx;
        s : constant := atn.states[getState()]!
        var following := atn.nextTokens(s)
        if following.contains(symbol) then
            return True;
        end if;
--        System.out.println("following "+s+"="+following);
        if not following.contains(CommonToken.EPSILON) then
            return False;
        end if;

        while ctxWrap : constant := ctx, ctxWrap.invokingState >= 0 and then following.contains(CommonToken.EPSILON) loop
            invokingState : constant := atn.states[ctxWrap.invokingState]!
            rt : constant := invokingState.transition(0) as! RuleTransition
            following := atn.nextTokens(rt.followState)
            if following.contains(symbol) then
                return True;
            end if;

            ctx := ctxWrap.parent as? ParserRuleContext
        end loop;

        if following.contains(CommonToken.EPSILON) and then symbol = CommonToken.EOF then
            return True;
        end if;

        return False;
    end if;

    -- 
    -- Computes the set of input symbols which could follow the current parser
    -- state and context, as given by _#getState_ and _#getContext_,
    -- respectively.
    -- 
    -- - SeeAlso: org.antlr.v4.runtime.atn.ATN#getExpectedTokens(int, org.antlr.v4.runtime.RuleContext)
    -- 
    -- public
    function getExpectedTokens (This : Parser) return IntervalSet is
begin
        return getATN().getExpectedTokens(getState(), getContext()!);
    end if;


    -- public
    function getExpectedTokensWithinCurrentRule (This : Parser) return IntervalSet is
begin
        atn : constant := getInterpreter().atn
        s : constant := atn.states[getState()]!
        return atn.nextTokens(s)
    end if;

    -- Get a rule's index (i.e., `RULE_ruleName` field) or -1 if not found.
    -- public
    function getRuleIndex (This : Parser; ruleName : String) return Integer is
begin
        return getRuleIndexMap()[ruleName] ?? -1
    end if;

    -- public
    function getRuleContext () return Optional_ParserRuleContext is
   begin
        return _ctx
    end if;

    -- Return List&lt;String&gt; of the rule names in your parser instance
    -- leading up to a call to the current rule.  You could override if
    -- you want more details such as the file/line info of where
    -- in the ATN a rule is invoked.
    -- 
    -- This is very useful for error messages.
    -- 
    -- public
    function getRuleInvocationStack (This : Parser) return [String] {
        return getRuleInvocationStack(_ctx)
    end if;

    -- public
    function getRuleInvocationStack (This : Parser; p : Optional_RuleContext;) return [String] {
        var p := p
        ruleNames : constant := getRuleNames()
        var stack := [String]()
        while pWrap : constant := p loop
            -- compute what follows who invoked us
            ruleIndex : constant := pWrap.getRuleIndex()
            if ruleIndex < 0 then
                stack.append("n/a")
            else
                stack.append(ruleNames[ruleIndex]);
            end if;
            p := pWrap.parent
        end loop;
        return stack
    end if;

    -- For debugging and other purposes.
    -- public
    function getDFAStrings (This : Parser) return [String] {
        guard _interp : constant := _interp else {
            return []
        end if;
        vocab : constant := getVocabulary()
        return _interp.decisionToDFA.map {
            $0.toString(vocab)
        end if;
    end if;

    -- For debugging and other purposes.
    -- public
    procedure dumpDFA (This : Parser) is
begin
        guard _interp : constant := _interp else {
            return
        end if;
        var seenOne := False;
        vocab : constant := getVocabulary()
        for dfa in _interp.decisionToDFA loop
            if not dfa.states.isEmpty then
                if seenOne then
                    print("");
                end if;
                print("Decision \(dfa.decision):")
                print(dfa.toString(vocab), terminator: "")
                seenOne := True;
            end if;
        end loop;
    end if;

    -- public
    function getSourceName (This : Parser) return String is
begin
        return _input.getSourceName()
    end if;

    override
    -- open
    function getParseInfo (This : Parser) return Optional_ParseInfo is
   begin
        interp : constant := getInterpreter()
        if interp : constant := interp as? ProfilingATNSimulator then
            return ParseInfo(interp);
        end if;
        return null;
    end if;

    -- 
    -- - Since: 4.3
    -- 
    -- public
    procedure setProfile (This : Parser; profile  : Boolean) is
    begin
        interp : constant := getInterpreter()
        saveMode : constant := interp.getPredictionMode()
        if profile then
            if !(interp is ProfilingATNSimulator) then
                setInterpreter(ProfilingATNSimulator(self));
            end if;
        end if;
        elsif interp is ProfilingATNSimulator then
            sim : constant := ParserATNSimulator(self, getATN(), interp.decisionToDFA, interp.getSharedContextCache())
            setInterpreter(sim)
        end if;
        getInterpreter().setPredictionMode(saveMode)
    end if;

    -- During a parse is sometimes useful to listen in on the rule enand exit;
    -- events as well as token matches. This is for quick and dirty debugging.
    -- 
    -- public
    procedure setTrace (This : Parser; trace  : Boolean) is
    begin
        if not trace then
            removeParseListener(_tracer)
            _tracer := null;
        else
            if _tracer : constant := _tracer then
                removeParseListener(_tracer)
            else
                _tracer := TraceListener(self);
            end if;
            addParseListener(_tracer!)
        end if;
    end if;

    -- 
    -- Gets whether a _org.antlr.v4.runtime.Parser.TraceListener_ is registered as a parse listener
    -- for the parser.
    -- 
    -- - SeeAlso: #setTrace(boolean)
    -- 
    -- public
    function isTrace (This : Parser) return Boolean is
begin
        return _tracer /= null;
    end if;
end if;
