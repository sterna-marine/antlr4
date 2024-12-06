-- €

package body ANTLR.Runtime.Parser is

   -------------------
   -- TraceListener --
   -------------------

   procedure Init (Self : in out TraceListener; host : Parser) is
   begin
      self.host := host;
   end Init;

   procedure enterEveryRule (This : TraceListener; ctx : ParserRuleContext) is
      ruleName : constant := host.getRuleNames ()[ctx.getRuleIndex ()];
      lt1 : constant := host._input.LT (1)!.getText ()!;
   begin
      print ("enter   " & ruleName'Image & ", LT (1)=" & lt1'Image);
   end enterEveryRule;

   procedure visitTerminal (This : TraceListener; node : TerminalNode) is
   begin
      print ("consume " & String (describing: node.getSymbol ()) & " rule " & host.getRuleNames ()[host._ctx!.getRuleIndex ()]);
   end visitTerminal;

   procedure visitErrorNode (This : TraceListener; node : ErrorNode) is
   begin
      null;
   end visitErrorNode;

   procedure exitEveryRule (This : TraceListener; ctx : ParserRuleContext) is
      ruleName : constant := host.getRuleNames ()[ctx.getRuleIndex ()];
      lt1 : constant := host._input.LT (1)!.getText ()!;
   begin
      print ("exit    " & ruleName'Image & ", LT (1)=" & lt1'Image);
   end exitEveryRule;

   ------------------------
   -- TrimToSizeListener --
   ------------------------

   -- procedure enterEveryRule (This : TrimToSizeListener; ctx : ParserRuleContext) is null;

   -- procedure visitTerminal (This : TrimToSizeListener; node : TerminalNode) is null;

   -- procedure visitErrorNode (This : TrimToSizeListener; node : ErrorNode) is null;

   -- procedure exitEveryRule (This : TrimToSizeListener; ctx : ParserRuleContext) is null;

   -------------------
   --     Parser    --
   -------------------

   function _precedenceStack return Stack<Int> is
   begin
      precedenceStack := Stack<Int> ();
      precedenceStack.push (0);
      return precedenceStack;
   end _precedenceStack;

   procedure Init (Self : in out Parser; input : TokenStream) is
   begin
      self._input := input
      This_Parser.Recognizer.Init (Self); -- super
      setInputStream (input);
   end Init;

   procedure reset (This : Parser) is
   begin
      getInputStream ()?.seek (0);
      This._errHandler.reset (self);
      This._ctx := null;
      This._syntaxErrors := 0;
      setTrace (False);
      This._precedenceStack.clear ();
      This._precedenceStack.push (0);

      --  getInterpreter ();
      interpreter : ParserATNSimulator := This._interp; -- constant
      if Is_Valid (interpreter)  then
         interpreter.reset (This);
      end if;
   end reset;

   function match (This : Parser; tType : Token_Kind) return Token is
      t : Token := getCurrentToken ();
   begin
      if t.getType () = ttype then
         This._errHandler.reportMatch (self);
         consume ();
      else
         t := This._errHandler.recoverInline (self);
         if This._buildParseTrees and then t.getTokenIndex () = -1 then
               -- we must have conjured up a new token during single token insertion
               -- if it's not the current symbol
               This._ctx!.addErrorNode (createErrorNode (parent: This._ctx!, t: t));
         end if;
      end if;
      return t;
   end match;

   function matchWildcard (This : Parser) return Token is
      t := getCurrentToken ();
   begin
      if t.getType () > 0 then
         This._errHandler.reportMatch (self);
         consume ();
      else
         t := This._errHandler.recoverInline (self);
         if This._buildParseTrees and then t.getTokenIndex () = -1 then
               -- we must have conjured up a new token during single token insertion
               -- if it's not the current symbol
               This._ctx!.addErrorNode (createErrorNode (parent: This._ctx!, t: t));
         end if;
      end if;

      return t;
   end matchWildcard;

   procedure setBuildParseTree (This : Parser; buildParseTrees : Boolean) is
   begin
      This._buildParseTrees := buildParseTrees;
   end setBuildParseTree;

   procedure setTrimParseTree (This : Parser; trimParseTrees : Boolean) is
   begin
      if trimParseTrees then
         if getTrimParseTree () then
               exit;
         end if;
         addParseListener (TrimToSizeListener.INSTANCE);
      else
         removeParseListener (TrimToSizeListener.INSTANCE);
      end if;
   end setTrimParseTree;

   function getTrimParseTree (This : Parser) return Boolean is
      function Closure (Param_0 : <>) is
      begin
         $Param_0 === TrimToSizeListener.INSTANCE;
      end Closure;
   begin
      return (not getParseListeners ().filter (Closure'Access).isEmpty);
   end getTrimParseTree;

   function getParseListeners () return ParseTreeListener.Container.Vector is
   begin
      if Is_Valid (_parseListeners) then
         return This._parseListeners;
      else
         return  ParseTreeListener.Container.Empty_Vector;
      end if;
   end getParseListeners;

   procedure addParseListener (This : Parser; listener : ParseTreeListener) is
   begin
      if not Is_Valid (_parseListeners) then
         This._parseListeners := ParseTreeListener.Container.Empty_Vector;
      else
         This._parseListeners!.Append (listener);
      end if;
   end addParseListener;

   procedure removeParseListener (This : Parser; listener : Optional_ParseTreeListener;) is
      function Closure (Param_0 : <>) is
      begin
         $Param_0 === listener;
      end Closure;
   begin
      if Is_Valid (This._parseListeners) then
         if not This._parseListeners!.filter (Closure'Access).isEmpty then
            This._parseListeners := This._parseListeners!.filter (Closure'Access);
            if This._parseListeners!.isEmpty then
               This._parseListeners := (Valid => False);
            end if;
         end if;
      end if;
   end removeParseListener;

   procedure removeParseListeners (This : Parser) is
   begin
      This._parseListeners := (Valid => False);
   end removeParseListeners;

   procedure triggerEnterRuleEvent (This : Parser) is
      _parseListeners : constant  array (<>) of Optional_ParseTreeListener := This._parseListeners;
      _ctx : constant := This._ctx;
   begin
      if Is_Valid (_parseListeners) and then Is_Valid (_ctx) then
         for listener: ParseTreeListener in _parseListeners loop
               listener.enterEveryRule (_ctx);
               This._ctx.enterRule (listener);
         end loop;
      end if;
   end triggerEnterRuleEvent;

   procedure triggerExitRuleEvent (This : Parser) is
   begin
      -- reverse order walk of listeners
      if Is_Valid (This._parseListeners) or Is_Valid (This._ctx) then
         for listener in This._parseListeners.reversed () loop
               This._ctx.exitRule (listener);
               listener.exitEveryRule (This._ctx);
         end loop;
      end if;
   end triggerExitRuleEvent;

   override
   procedure setTokenFactory (This : Parser; factory : TokenFactory) is
   begin
      This._input.getTokenSource ().setTokenFactory (factory);
   end setTokenFactory;

   function getATNWithBypassAlts (This : Parser) return ATN is

      serializedAtn : constant := getSerializedATN (This);

      function Closure return Optional_ATN is
         cachedResult : constant Optional_ATN := This.bypassAltsAtnCache;
      begin
         if Is_Valid (cachedResult) then
               return cachedResult;
         else
            declare
               opts := ATNDeserializationOptions ();
               result : Optional_ATN;
            begin
               opts.generateRuleBypassTransitions := True;
               result := ATNDeserializer (opts).deserialize (serializedAtn); -- try! 
               This.bypassAltsAtnCache := result;
               return This.bypassAltsAtnCache!;
            exception
               when others => null;
            end;
         end if;
      end Closure;
      Closure_Return_Value : Optional_ATN;
      function Synchronized_Closure is new Mutex.Gen_Closure (Closure => Closure, Result_Type => Optional_ATN);

   begin
      bypassAltsAtnCacheMutex.Run (Synchronized_Closure'Access, Closure_Return_Value);
      return Closure_Return_Value;
   end getATNWithBypassAlts;

   function compileParseTreePattern (This : Parser;
                                     pattern : String;
                                     patternRuleIndex : Integer)
                                     return ParseTreePattern is
      tokenStream : constant Optional_Token := Set (getTokenStream ());
   begin
      if Is_Valid (tokenStream) then
         tokenSource : constant := tokenStream.getTokenSource ();
         lexer : constant Optional_Lexer := Set (tokenSource);
         if Is_Valid (lexer) then
               return compileParseTreePattern (pattern, patternRuleIndex, lexer);
         end if;
      end if;
      raise ANTLRError.unsupportedOperation with "Parser can't discover a lexer to use";
   end compileParseTreePattern;

   procedure compileParseTreePattern (This : Parser;
                                      pattern : String;
                                      patternRuleIndex : Integer;
                                      lexer : Lexer)
                                      return ParseTreePattern is
      m : constant := ParseTreePatternMatcher (lexer, self);
   begin
      return m.compile (pattern, patternRuleIndex);
   end if;

   procedure setErrorHandler (This : Parser; handler : ANTLRErrorStrategy) is
   begin
      This._errHandler := handler;
   end setErrorHandler;

   override
   procedure setInputStream (This : Parser; input : IntStream) is
   begin
      setTokenStream (TokenStream (input));
   end setInputStream;

   procedure setTokenStream (This : Parser; input : TokenStream) is
   begin
      --TODO self._input := null;
      This._input := null;
      reset (This);
      This._input := input;
   end setTokenStream;

   procedure notifyErrorListeners (This : Parser; msg : String) is
      token : constant := getCurrentToken (); -- try?
   begin
      notifyErrorListeners (token, msg, null);
   end notifyErrorListeners;

   procedure notifyErrorListeners (This : Parser;
                                   offendingToken : Optional_Token;
                                   msg : String;
                                   e : Optional_AnyObject) is
      listener : constant := getErrorListenerDispatch ();
   begin
      This._syntaxErrors := @ + 1;
      This.line := -1;
      This.charPositionInLine := -1;
      offendingToken : Optional_Token := Set (offendingToken); -- constant
      if Is_Valid (offendingToken) then
         line := offendingToken.getLine ();
         charPositionInLine := offendingToken.getCharPositionInLine ();
      end if;

      listener.syntaxError (self, offendingToken, line, charPositionInLine, msg, e);
   end notifyErrorListeners;

   function consume (This : Parser) return Token is
      o : constant Token := getCurrentToken ();
      hasListener : Boolean;
   begin
      if o.getType () /= Parser.EOF then
         getInputStream ()!.consume ();
      end if;
      if not Is_Valid (This._ctx) then
         return o;
      else

         hasListener := Is_Valid (This._parseListeners) and then not This._parseListeners!.isEmpty

         if This._buildParseTrees or else hasListener then
            if This._errHandler.inErrorRecoveryMode (self) then
                  node : constant := createErrorNode (parent: This._ctx, t: o);
                  This._ctx.addErrorNode (node);
                  if This._parseListeners : constant := This._parseListeners then
                     for listener in This._parseListeners loop
                        listener.visitErrorNode (node);
                     end loop;
                  end if;
            else
                  node := createTerminalNode (parent => This._ctx, t => o); -- constant
                  This._ctx.addChild (node);
                  _parseListeners : constant := This._parseListeners;
                  if Is_Valid (_parseListeners) then
                     for listener in _parseListeners loop
                        listener.visitTerminal (node);
                     end loop;
                  end if;
            end if;
         end if;
         return o;
      end if;
   end consume;

   procedure addContextToParseTree (This : Parser) is
   begin
      -- add current context to parent if we have a parent
      parent : constant ParserRuleContext := ParserRuleContext (This._ctx?.parent);
      if Is_Valid (parent) then
         parent.addChild (This._ctx!);
      end if;
   end addContextToParseTree;

   procedure enterRule (This : Parser;
                        localctx : ParserRuleContext;
                        state : Integer;
                        ruleIndex : Integer) is
   begin
      setState (state);
      This._ctx := localctx;
      This._ctx!.start := This._input.LT (1);
      if This._buildParseTrees then
         addContextToParseTree ();
      end if;
   end enterRule;

   procedure exitRule (This : Parser) is
      ctx : ParserRuleContext := This._ctx;
   begin
      if not Is_Valid (ctx) then
         exit;
      end if;

      ctx.stop := This._input.LT (-1);
      -- trigger event on This._ctx, before it reverts to parent
      if Is_Valid (This._parseListeners then
         triggerExitRuleEvent ();
      end if;
      setState (ctx.invokingState);
      This._ctx := Is_Valid (ctx.parent); -- as ParserRuleContext
   end exitRule;

   procedure enterOuterAlt (This : Parser; localctx : ParserRuleContext; altNum : Integer) is
   begin
      localctx.setAltNumber (altNum);
      -- if we have new localctx, make sure we replace existing ctx
      -- that is previous child of parse tree
      if This._buildParseTrees and then This._ctx! !== localctx then
         parent : constant ParserRuleContext := ParserRuleContext (_ctx?.parent);
         if Is_Valid (parent) then
               parent.removeLastChild ();
               parent.addChild (localctx);
         end if;
      end if;
      This._ctx := localctx
      if Is_Valid (This._parseListeners) then
         triggerEnterRuleEvent ();
      end if;
   end enterOuterAlt;

   function getPrecedence (This : Parser) return Integer is
   begin
      if This._precedenceStack.isEmpty then
         return -1;
      else
         if Is_Valid (_precedenceStack.peek ()) then
            return This._precedenceStack.peek ()
         else
            return -1;
      end if;
   end getPrecedence;

   --  Obsolete
   --  procedure enterRecursionRule (This : Parser; localctx : ParserRuleContext; ruleIndex : Integer) is
   --  begin
   --     enterRecursionRule (localctx, getATN ().ruleToStartState[ruleIndex].stateNumber, ruleIndex, 0);
   --  end enterRecursionRule;

   procedure enterRecursionRule (This : Parser; localctx : ParserRuleContext; state : Integer; ruleIndex : Integer; precedence : Integer) is
   begin
      setState (state);
      This._precedenceStack.push (precedence);
      This._ctx := localctx;
      This._ctx!.start := This._input.LT (1);
      if Is_Valid (_parseListeners) then
         triggerEnterRuleEvent (); -- simulates rule enfor left-recursive rules;
      end if;
   end enterRecursionRule;

   procedure pushNewRecursionContext (This : Parser;
                                      localctx : ParserRuleContext;
                                      state : Integer;
                                      ruleIndex : Integer) is
      previous : constant := This._ctx!
   begin
      previous.parent := localctx
      previous.invokingState := state
      previous.stop := This._input.LT (-1);

      This._ctx := localctx;
      This._ctx!.start := previous.start;
      if This._buildParseTrees then
         This._ctx!.addChild (previous);
      end if;

      if Is_Valid (This._parseListeners)xthen
         triggerEnterRuleEvent (); -- simulates rule enfor left-recursive rules;
      end if;
   end pushNewRecursionContext;

   procedure unrollRecursionContexts (This : Parser; _parentctx : Optional_ParserRuleContext) is
   begin
      This._precedenceStack.pop ();
      This._ctx!.stop := This._input.LT (-1);
      retctx : constant := This._ctx!; -- save current ctx (return value);

      -- unroll so This._ctx is as it was before call to recursive method
      if Is_Valid (_parseListeners) then
         ctxWrap : constant := This_ctx;
         while Is_Valid (ctxWrap) and ctxWrap !== _parentctx loop
               triggerExitRuleEvent ();
               This._ctx := Is_Valid (ctxWrap.parent); -- as ParserRuleContext
         end loop;
      else
         This._ctx := _parentctx;
      end if;

      -- hook into tree
      retctx.parent := _parentctx;

      if This._buildParseTrees and then Is_Valid (_parentctx) then
         -- add return ctx into invoking rule's tree
         _parentctx!.addChild (retctx);
      end if;
   end unrollRecursionContexts;

   function getInvokingContext (This : Parser; ruleIndex : Integer) return Optional_ParserRuleContext is
   begin
      p := This._ctx;
      pWrap : constant := p;
      while Is_Valid (pWrap) loop
         if pWrap.getRuleIndex () = ruleIndex then
            return pWrap;
         end if;
         p := Is_Valid (pWrap.parent); -- as ParserRuleContext
         pWrap := p; --FIXME
      end loop;
      return (Valid => False);
   end getInvokingContext;

   procedure setContext (This : Parser; ctx : ParserRuleContext) is
   begin
      This._ctx := ctx;
   end setContext;

--	public class procedure getAmbiguousParseTrees (originalParser : Parser;
--																 _ ambiguityInfo : AmbiguityInfo;
--																 _ startRuleIndex : Integer) return Array<ParserRuleContext>  --; RecognitionException
--	{
--		trees : Array<ParserRuleContext> := Array<ParserRuleContext> ();
--		saveTokenInputPosition : Integer := originalParser.getTokenStream ().index ();
--		--{;
--			-- Create a new parser interpreter to parse the ambiguous subphrase
--			parser : ParserInterpreter;
--			if ( originalParser is ParserInterpreter ) {
--				parser := ParserInterpreter ( ParserInterpreter (originalParser));
--			}
--			else {
--				serializedAtn : [Character] := ATNSerializer.getSerializedAsChars (originalParser.getATN ());
--				deserialized : ATN := ATNDeserializer ().deserialize (serializedAtn);
--				parser := ParserInterpreter (originalParser.getGrammarFileName (),
--											   originalParser.getVocabulary (),
--											    originalParser.getRuleNames () ,
--											   deserialized,
--											   originalParser.getTokenStream ());
--			}
--
--			-- Make sure that we don't get any error messages from using this temporary parser
--			parser.removeErrorListeners ();
--			parser.removeParseListeners ();
--			parser.getInterpreter ()!.setPredictionMode (PredictionModes.LL_EXACT_AMBIG_DETECTION);
--
--			-- get ambig trees
--			alt : Integer := ambiguityInfo.ambigAlts.firstSetBit ();
--			while  alt>=0  loop
--				-- re-parse entire input for all ambiguous alternatives
--				-- (don't have to do first as it's been parsed, but do again for simplicity
--				--  using this temp parser.);
--				parser.reset ();
--				parser.getTokenStream ().seek (0); -- rewind the input all the way for re-parsing
--				parser.overrideDecision := ambiguityInfo.decision;
--				parser.overrideDecisionInputIndex := ambiguityInfo.startIndex;
--				parser.overrideDecisionAlt := alt;
--				t : ParserRuleContext := parser.parse (startRuleIndex);
--				ambigSubTree : ParserRuleContext =
--					Trees.getRootOfSubtreeEnclosingRegion (t, ambiguityInfo.startIndex, ambiguityInfo.stopIndex)!;
--				trees.append (ambigSubTree);
--				alt := ambiguityInfo.ambigAlts.nextSetBit (alt+1);
--			end loop;
--		--}
--		defer {
--			originalParser.getTokenStream ().seek (saveTokenInputPosition);
--		}
--
--		return trees;
--	}

   function isExpectedToken (This : Parser; symbol : Integer) return Boolean is
      atn : constant := getInterpreter ().atn;
   begin
      ctx : Optional_ParserRuleContext; := This._ctx;
      s : constant := atn.states[getState ()]!;
      following := atn.nextTokens (s);
      if following.contains (symbol) then
         return True;
      end if;
      -- Text_IO.Put_Line ("following " & s & "=" & following);
      if not following.contains (CommonToken.EPSILON) then
         return False;
      end if;

      ctxWrap : constant := ctx;
      while Is_Valid (ctxWrap)
         and then ctxWrap.invokingState >= 0
         and then following.contains (CommonToken.EPSILON) loop
         invokingState : constant := atn.states[ctxWrap.invokingState]!;
         rt : constant RuleTransition := RuleTransition (invokingState.transition (0));
         following := atn.nextTokens (rt.followState);
         if following.contains (symbol) then
            return True;
         end if;

         ctx := Is_Valid (ctxWrap.parent); -- as ParserRuleContext
         ctxWrap := ctx; --TOFIX
      end loop;

      if following.contains (CommonToken.EPSILON) and then symbol = CommonToken.EOF then
         return True;
      else
         return False;
      end if;
   end isExpectedToken;

   function getExpectedTokensWithinCurrentRule (This : Parser) return IntervalSet is
      atn : constant := getInterpreter ().atn;
      s : constant := atn.states[getState ()]!;
   begin
      return atn.nextTokens (s);
   end getExpectedTokensWithinCurrentRule;

   function getRuleInvocationStack (This : Parser; p : Optional_RuleContext;) return UString.Container.Vector is 
      ruleNames : constant := getRuleNames ();
      Stack : UString.Container.Vector;
   begin
      p := p;
      pWrap : constant := p;
      while Is_Valid (pWrap) loop
         -- compute what follows who invoked us
         ruleIndex : constant := pWrap.getRuleIndex ();
         if ruleIndex < 0 then
               stack.append ("n/a");
         else
               stack.append (ruleNames[ruleIndex]);
         end if;
         p := pWrap.parent;
         pWrap := p; --FIXME
      end loop;
      return stack
   end getRuleInvocationStack;

   function getDFAStrings (This : Parser) return UString.Container.Vector is
      function Closure (Param_0 : <>) return UString is
      begin
         return Param_0.toString (vocab);
      end Closure;
   begin
      if not Is_Valid (This._interp) then
         return UString.Container.Empty_Vector;
      else
         vocab : constant := getVocabulary ();
         return This._interp.decisionToDFA.map (Closure'Access);
      end if;
   end getDFAStrings;

   procedure dumpDFA (This : Parser) is
   begin
      if not Is_Valid (_interp) then
         exit;
      else
         seenOne := False;
         vocab : constant := getVocabulary ();
         for dfa in This._interp.decisionToDFA loop
            if not dfa.states.isEmpty then
                  if seenOne then
                     print ("");
                  end if;
                  print ("Decision " & dfa.decision & ":");
                  print (dfa.toString (vocab), terminator: "");
                  seenOne := True;
            end if;
         end loop;
      end if;
   end dumpDFA;

   override
   function getParseInfo (This : Parser) return Optional_ParseInfo is
      interp : constant := getInterpreter ();
      interp : constant Optional_ProfilingATNSimulator := Set (interp);
   begin
      if Is_Valid (interp) then
         return ParseInfo (interp);
      end if;
      return (Valid => False);
   end getParseInfo;

   procedure setProfile (This : Parser; profile : Boolean) is
      interp : constant := getInterpreter ();
      saveMode : constant PredictionMode := interp.getPredictionMode ();
   begin
      if profile then
         if not (interp is ProfilingATNSimulator) then
               setInterpreter (ProfilingATNSimulator (self));
         end if;
      elsif interp is ProfilingATNSimulator then
         sim : constant := ParserATNSimulator (self, getATN (), interp.decisionToDFA, interp.getSharedContextCache ());
         setInterpreter (sim);
      end if;
      getInterpreter ().setPredictionMode (saveMode);
   end setProfile;

   procedure setTrace (This : Parser; trace : Boolean) is
   begin
      if not trace then
         removeParseListener (_tracer);
         This._tracer := (Valid => False);
      else
         _tracer : constant := This._tracer;
         if Is_Valid (_tracer) then
               removeParseListener (_tracer);
         else
               This._tracer := TraceListener (This);
         end if;
         addParseListener (This._tracer!);
      end if;
   end setTrace;

end ANTLR.Runtime.Parser;
