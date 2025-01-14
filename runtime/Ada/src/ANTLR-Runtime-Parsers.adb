-- €

with Ada.Wide_Wide_Text_IO;
with ANTLR.Runtime.ATN.ParseInfos;
with ANTLR.Runtime.Misc.Exceptions.Errors;
with ANTLR.Runtime.Simulators.Parsers.Profilings;
with AdaForge.Framework.Aspect;

use Ada;
use ANTLR.Runtime.ATN.ParseInfos;
use ANTLR.Runtime.Misc.Exceptions.Errors;
use ANTLR.Runtime.Simulators.Parsers.Profilings;
use AdaForge.Framework;
use AdaForge.Framework.Aspect;

package body ANTLR.Runtime.Parsers is

   -------------------
   -- TraceListener --
   -------------------

   procedure Initialize (Self : in out TraceListener; host : Parser) is
   begin
      self.host := host;
   end Initialize;

   procedure enterEveryRule (This : TraceListener; ctx : ParserRuleContext) is
      ruleName : constant := host.getRuleNames.Element (ctx.getRuleIndex);
      lt1 : constant := Value (Value (host.input.LT (1)).getText);
   begin
      Wide_Wide_Text_IO.Put_Line ("enter   " & ruleName'Image & ", LT (1)=" & lt1'Image);
   end enterEveryRule;

   procedure visitTerminal (This : TraceListener; node : TerminalNode) is
   begin
      Wide_Wide_Text_IO.Put_Line ("consume " & UString (describing => node.getSymbol) & " rule " & host.getRuleNames.Element (host.ctx!.getRuleIndex));
   end visitTerminal;

   procedure visitErrorNode (This : TraceListener; node : ErrorNode) is
   begin
      null;
   end visitErrorNode;

   procedure exitEveryRule (This : TraceListener; ctx : ParserRuleContext) is
      ruleName : constant := host.getRuleNames.Element (ctx.getRuleIndex);
      lt1 : constant := Value (Value (host.input.LT (1)).getText);
   begin
      Wide_Wide_Text_IO.Put_Line ("exit    " & ruleName'Image & ", LT (1)=" & lt1'Image);
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

   function precedenceStack return Stack<Int> is
   begin
      precedenceStack := Stack<Int>;
      precedenceStack.push (0);
      return precedenceStack;
   end precedenceStack;

   procedure Initialize (Self : in out Parser; input : TokenStream) is
   begin
      self.input := input
      This_Parser.Recognizer.Init (Self); -- super
      setInputStream (input);
   end Initialize;

   procedure reset (This : Parser) is
   begin
      This.getInputStream?.seek (0);
      This.errHandler.reset (self);
      This.ctx := (Valid => False);
      This.syntaxErrors := 0;
      setTrace (False);
      This.precedenceStack.clear;
      This.precedenceStack.push (0);

      --  This.getInterpreter;
      interpreter : ParserATNSimulator := This.interp; -- constant
      if Is_Valid (interpreter)  then
         interpreter.reset (This);
      end if;
   end reset;

   function match (This : Parser; tType : Token_Kind) return Token is
      t : Token := This.getCurrentToken;
   begin
      if t.getType = ttype then
         This.errHandler.reportMatch (self);
         This.consume;
      else
         t := This.errHandler.recoverInline (self);
         if This.buildParseTrees and then t.getTokenIndex = -1 then
               -- we must have conjured up a new token during single token insertion
               -- if it's not the current symbol
               Value (This.ctx).addErrorNode (createErrorNode (parent => Value (This.ctx), t => t));
         end if;
      end if;
      return t;
   end match;

   function matchWildcard (This : Parser) return Token is
      t := This.getCurrentToken;
   begin
      if t.getType > 0 then
         This.errHandler.reportMatch (self);
         This.consume;
      else
         t := This.errHandler.recoverInline (self);
         if This.buildParseTrees and then t.getTokenIndex = -1 then
               -- we must have conjured up a new token during single token insertion
               -- if it's not the current symbol
               Value (This.ctx).addErrorNode (createErrorNode (parent => Value (This.ctx), t => t));
         end if;
      end if;
      return t;
   end matchWildcard;

   procedure setBuildParseTree (This : Parser; buildParseTrees : Boolean) is
   begin
      This.buildParseTrees := buildParseTrees;
   end setBuildParseTree;

   procedure setTrimParseTree (This : Parser; trimParseTrees : Boolean) is
   begin
      if trimParseTrees then
         if This.getTrimParseTree then
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
         Param_0 === TrimToSizeListener.INSTANCE;
      end Closure;
   begin
      return (not This.getParseListeners.filter (Closure'Access).Is_Empty);
   end getTrimParseTree;

   function getParseListeners (This : …) return ParseTreeListener_List is
   begin
      if Is_Valid (parseListeners) then
         return This.parseListeners;
      else
         return ParseTreeListener.Container.Empty_Vector;
      end if;
   end getParseListeners;

   procedure addParseListener (This : Parser; listener : ParseTreeListener) is
   begin
      if not Is_Valid (parseListeners) then
         This.parseListeners := ParseTreeListener.Container.Empty_Vector;
      else
         Value (This.parseListeners).Append (listener);
      end if;
   end addParseListener;

   procedure removeParseListener (This : Parser; listener : Optional_ParseTreeListener) is
      function Closure (Param_0 : <>) is
      begin
         $Param_0 === listener;
      end Closure;
   begin
      if Is_Valid (This.parseListeners) then
         if not Value (This.parseListeners).filter (Closure'Access).Is_Empty then
            This.parseListeners := Value (This.parseListeners).filter (Closure'Access);
            if Value (This.parseListeners).Is_Empty then
               This.parseListeners := (Valid => False);
            end if;
         end if;
      end if;
   end removeParseListener;

   procedure removeParseListeners (This : Parser) is
   begin
      This.parseListeners := (Valid => False);
   end removeParseListeners;

   procedure triggerEnterRuleEvent (This : Parser) is
      parseListeners : constant  array (<>) of Optional_ParseTreeListener := This.parseListeners;
      ctx : constant := This.ctx;
   begin
      if Is_Valid (parseListeners) and then Is_Valid (ctx) then
         for listener: ParseTreeListener in parseListeners loop
            listener.enterEveryRule (ctx);
            This.ctx.enterRule (listener);
         end loop;
      end if;
   end triggerEnterRuleEvent;

   procedure triggerExitRuleEvent (This : Parser) is
   begin
      -- reverse order walk of listeners
      if Is_Valid (This.parseListeners) or Is_Valid (This.ctx) then
         for listener of This.parseListeners.reversed loop
            This.ctx.exitRule (listener);
            listener.exitEveryRule (This.ctx);
         end loop;
      end if;
   end triggerExitRuleEvent;

   overriding
   procedure setTokenFactory (This : Parser; factory : TokenFactory) is
   begin
      This.input.getTokenSource.setTokenFactory (factory);
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
               opts := This.ATNDeserializationOptions;
               result : Optional_ATN;
            begin
               opts.generateRuleBypassTransitions := True;
               result := ATNDeserializer (opts).deserialize (serializedAtn); -- try!
               This.bypassAltsAtnCache := result;
               return Value (This.bypassAltsAtnCache);
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
                                     pattern : UString;
                                     patternRuleIndex : Integer)
                                     return ParseTreePattern is
      tokenStream : constant Optional_Token := Maybe (getTokenStream);
   begin
      if Is_Valid (tokenStream) then
         tokenSource : constant := tokenStream.getTokenSource;
         lexer : constant Optional_Lexer := Maybe (tokenSource);
         if Is_Valid (lexer) then
               return compileParseTreePattern (pattern, patternRuleIndex, lexer);
         end if;
      end if;
      raise ANTLRError.unsupportedOperation
         with "Parser can't discover a lexer to use";
   end compileParseTreePattern;

   procedure compileParseTreePattern (This : Parser;
                                      pattern : UString;
                                      patternRuleIndex : Integer;
                                      lexer : Lexer)
                                      return ParseTreePattern is
      m : constant := ParseTreePatternMatcher (lexer, self);
   begin
      return m.compile (pattern, patternRuleIndex);
   end if;

   procedure setErrorHandler (This : Parser; handler : ANTLRErrorStrategy) is
   begin
      This.errHandler := handler;
   end setErrorHandler;

   overriding
   procedure setInputStream (This : Parser; input : IntStream) is
   begin
      setTokenStream (TokenStream (input));
   end setInputStream;

   procedure setTokenStream (This : Parser; input : TokenStream) is
   begin
      --TODO self.input := (Valid => False);
      This.input := (Valid => False);
      reset (This);
      This.input := input;
   end setTokenStream;

   procedure notifyErrorListeners (This : Parser; msg : UString) is
      token : constant := This.getCurrentToken; -- try?
   begin
      notifyErrorListeners (token, msg, null);
   end notifyErrorListeners;

   procedure notifyErrorListeners (This : Parser;
                                   offendingToken : Optional_Token;
                                   msg : UString;
                                   e : Optional_AnyObject) is
      listener : constant := This.getErrorListenerDispatch;
   begin
      This.syntaxErrors := @ + 1;
      This.line := -1;
      This.charPositionInLine := -1;
      offendingToken : Optional_Token := Maybe (offendingToken); -- constant
      if Is_Valid (offendingToken) then
         line := offendingToken.getLine;
         charPositionInLine := offendingToken.getCharPositionInLine;
      end if;

      listener.syntaxError (self, offendingToken, line, charPositionInLine, msg, e);
   end notifyErrorListeners;

   function consume (This : Parser) return Token is
      o : constant Token := This.getCurrentToken;
      hasListener : Boolean;
   begin
      if o.getType /= EOF then
         Value (This.getInputStream).consume;
      end if;
      if not Is_Valid (This.ctx) then
         return o;
      else
         hasListener := Is_Valid (This.parseListeners) and then not Value (This.parseListeners).Is_Empty;
         if This.buildParseTrees or else hasListener then
            if This.errHandler.inErrorRecoveryMode (self) then
               node : constant := createErrorNode (parent => This.ctx, t => o);
               This.ctx.addErrorNode (node);
               if This.parseListeners : constant := This.parseListeners then
                  for listener of This.parseListeners loop
                     listener.visitErrorNode (node);
                  end loop;
               end if;
            else
               node := createTerminalNode (parent => This.ctx, t => o); -- constant
               This.ctx.addChild (node);
               parseListeners : constant := This.parseListeners;
               if Is_Valid (parseListeners) then
                  for listener of parseListeners loop
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
      parent : constant ParserRuleContext := ParserRuleContext (This.ctx?.parent);
      if Is_Valid (parent) then
         parent.addChild (Value (This.ctx));
      end if;
   end addContextToParseTree;

   procedure enterRule (This : Parser;
                        localctx : ParserRuleContext;
                        state : Integer;
                        ruleIndex : Integer) is
   begin
      setState (state);
      This.ctx := localctx;
      Value (This.ctx).start := This.input.LT (1);
      if This.buildParseTrees then
         This.addContextToParseTree;
      end if;
   end enterRule;

   procedure exitRule (This : Parser) is
      ctx : ParserRuleContext := This.ctx;
   begin
      if not Is_Valid (ctx) then
         exit;
      end if;

      ctx.stop := This.input.LT (-1);
      -- trigger event on This.ctx, before it reverts to parent
      if Is_Valid (This.parseListeners then
         This.triggerExitRuleEvent;
      end if;
      setState (ctx.invokingState);
      This.ctx := Is_Valid (ctx.parent); -- as ParserRuleContext
   end exitRule;

   procedure enterOuterAlt (This : Parser; localctx : ParserRuleContext; altNum : Integer) is
   begin
      localctx.setAltNumber (altNum);
      -- if we have new localctx, make sure we replace existing ctx
      -- that is previous child of parse tree
      if This.buildParseTrees and then Value (This.ctx) !== localctx then
         parent : constant ParserRuleContext := ParserRuleContext (ctx?.parent);
         if Is_Valid (parent) then
            parent.removeLastChild;
            parent.addChild (localctx);
         end if;
      end if;
      This.ctx := localctx
      if Is_Valid (This.parseListeners) then
         This.triggerEnterRuleEvent;
      end if;
   end enterOuterAlt;

   function getPrecedence (This : Parser) return Integer is
   begin
      if This.precedenceStack.Is_Empty then
         return -1;
      else
         if Is_Valid (precedenceStack.peek) then
            return This.precedenceStack.peek;
         else
            return -1;
      end if;
   end getPrecedence;

   procedure enterRecursionRule (This : Parser; localctx : ParserRuleContext; ruleIndex : Integer) is
   --  Obsolete
   begin
      enterRecursionRule (localctx, This.getATN.ruleToStartState.Element (ruleIndex).stateNumber, ruleIndex, 0);
   end enterRecursionRule;

   procedure enterRecursionRule (This : Parser; localctx : ParserRuleContext; state : Integer; ruleIndex : Integer; precedence : Integer) is
   begin
      setState (state);
      This.precedenceStack.push (precedence);
      This.ctx := localctx;
      Value (This.ctx).start := This.input.LT (1);
      if Is_Valid (parseListeners) then
         This.triggerEnterRuleEvent; -- simulates rule enfor left-recursive rules;
      end if;
   end enterRecursionRule;

   procedure pushNewRecursionContext (This : Parser;
                                      localctx : ParserRuleContext;
                                      state : Integer;
                                      ruleIndex : Integer) is
      previous : constant := Value (This.ctx)
   begin
      previous.parent := localctx
      previous.invokingState := state
      previous.stop := This.input.LT (-1);

      This.ctx := localctx;
      Value (This.ctx).start := previous.start;
      if This.buildParseTrees then
         Value (This.ctx).addChild (previous);
      end if;

      if Is_Valid (This.parseListeners)xthen
         This.triggerEnterRuleEvent; -- simulates rule enfor left-recursive rules;
      end if;
   end pushNewRecursionContext;

   procedure unrollRecursionContexts (This : Parser; parentctx : Optional_ParserRuleContext) is
   begin
      This.precedenceStack.pop;
      Value (This.ctx).stop := This.input.LT (-1);
      retctx : constant := Value (This.ctx); -- save current ctx (return value);

      -- unroll so This.ctx is as it was before call to recursive method
      if Is_Valid (parseListeners) then
         ctxWrap : constant Optional_ParserRuleContext := Set (This.ctx);
         while Is_Valid (ctxWrap) and then ctxWrap /= parentctx loop
            This.triggerExitRuleEvent;
            This.ctx := Is_Valid (ctxWrap.parent); -- as ParserRuleContext
            ctxWrap := This.ctx; --TOFIX
         end loop;
      else
         This.ctx := parentctx;
      end if;

      -- hook into tree
      retctx.parent := parentctx;

      if This.buildParseTrees and then Is_Valid (parentctx) then
         -- add return ctx into invoking rule's tree
         Value (parentctx).addChild (retctx);
      end if;
   end unrollRecursionContexts;

   function getInvokingContext (This : Parser; ruleIndex : Integer) return Optional_ParserRuleContext is
      p := This.ctx;
      pWrap : constant := p;
   begin
      while Is_Valid (pWrap) loop
         if pWrap.getRuleIndex = ruleIndex then
            return pWrap;
         end if;
         p := Is_Valid (pWrap.parent); -- as ParserRuleContext
         pWrap := p; --FIXME
      end loop;
      return (Valid => False);
   end getInvokingContext;

   procedure setContext (This : Parser; ctx : ParserRuleContext) is
   begin
      This.ctx := ctx;
   end setContext;

   --  public class
   --  procedure getAmbiguousParseTrees (This : Parser;
   --                                    originalParser : Parser;
   --                                    ambiguityInfo : AmbiguityInfo;
   --                                    startRuleIndex : Integer)
   --                                    return ParserRuleContext_List  
   --     -- RecognitionException
   --     trees : ParserRuleContext_List;
   --     saveTokenInputPosition : Integer := originalParser.getTokenStream.index;
   --  begin
   --     -- Create a new parser interpreter to parse the ambiguous subphrase
   --     parser : ParserInterpreter;
   --     if originalParser'Tag = ParserInterpreter,Tag then
   --        parser := ParserInterpreter (ParserInterpreter (originalParser));
   --     else
   --        serializedAtn : Character_List := ATNSerializer.getSerializedAsChars (originalParser.getATN);
   --        deserialized : ATN := This.ATNDeserializer.deserialize (serializedAtn);
   --        parser := ParserInterpreter (originalParser.getGrammarFileName,
   --                                     originalParser.getVocabulary,
   --                                     originalParser.getRuleNames ,
   --                                     deserialized,
   --                                     originalParser.getTokenStream);
   --     end if;
   --     -- Make sure that we don't get any error messages from using this temporary parser
   --     parser.removeErrorListeners;
   --     parser.removeParseListeners;
   --     Value (parser.getInterpreter).setPredictionMode (PredictionModes.LL_EXACT_AMBIG_DETECTION);
   --     -- get ambig trees
   --     alt : Integer := ambiguityInfo.ambigAlts.firstSetBit;
   --     while  alt >= 0  loop
   --        -- re-parse entire input for all ambiguous alternatives
   --        -- (don't have to do first as it's been parsed, but do again for simplicity
   --        -- using this temp parser.);
   --        parser.reset;
   --        parser.getTokenStream.seek (0); -- rewind the input all the way for re-parsing
   --        parser.overrideDecision := ambiguityInfo.decision;
   --        parser.overrideDecisionInputIndex := ambiguityInfo.startIndex;
   --        parser.overrideDecisionAlt := alt;
   --        t : ParserRuleContext := parser.parse (startRuleIndex);
   --        ambigSubTree : ParserRuleContext :=
   --           Trees.getRootOfSubtreeEnclosingRegion (t, ambiguityInfo.startIndex, ambiguityInfo.stopIndex)!;
   --        trees.append (ambigSubTree);
   --        alt := ambiguityInfo.ambigAlts.nextSetBit (alt+1);
   --     end loop;
   --     DEFER:
   --        begin
   --           originalParser.getTokenStream.seek (saveTokenInputPosition);
   --        end DEFER;
   --     return trees;
   --  end getAmbiguousParseTrees;

   function isExpectedToken (This : Parser; symbol : Integer) return Boolean is
      atn : constant := This.getInterpreter.atn;
      ctx : Optional_ParserRuleContext := This.ctx;
      s : constant := Value (atn.states.Element (getState));
      following := atn.nextTokens (s);
   begin
      if following.contains (symbol) then
         return True;
      else
         if Is_Active (Aspect.DEBUG) then
            Wide_Wide_Text_IO.Put_Line ("following " & s & '=' & following);
         end if;
         if not following.contains (CommonToken.EPSILON) then
            return False;
         end if;

         ctxWrap : constant Optional_ParserRuleContext := ctx;
         while Is_Valid (ctxWrap)
            and then ctxWrap.invokingState >= 0
            and then following.contains (CommonToken.EPSILON) loop
            invokingState : constant := Value (atn.states.Element (ctxWrap.invokingState));
            rt : constant RuleTransition := RuleTransition (invokingState.transition (0));
            following := atn.nextTokens (rt.followState);
            if following.contains (symbol) then
               return True;
            end if;

            ctx := Is_Valid (ctxWrap.parent); -- as ParserRuleContext
            ctxWrap := ctx; --TOFIX
         end loop;

         if following.contains (CommonToken.EPSILON) and then symbol = EOF then
            return True;
         else
            return False;
         end if;
      end if;
   end isExpectedToken;

   function getExpectedTokensWithinCurrentRule (This : Parser) return IntervalSet is
      atn : constant := This.getInterpreter.atn;
      s : constant := Value (atn.states.Element (getState));
   begin
      return atn.nextTokens (s);
   end getExpectedTokensWithinCurrentRule;

   function getRuleInvocationStack (This : Parser; p : Optional_RuleContext) return UString_List is
      ruleNames : constant := This.getRuleNames;
      Stack : UString_List;
   begin
      p := p;
      pWrap : constant := p;
      while Is_Valid (pWrap) loop
         -- compute what follows who invoked us
         ruleIndex : constant := pWrap.getRuleIndex;
         if ruleIndex < 0 then
            stack.append ("n/a");
         else
            stack.append (ruleNames.Element (ruleIndex));
         end if;
         p := pWrap.parent;
         pWrap := p; --FIXME
      end loop;
      return stack;
   end getRuleInvocationStack;

   function getDFAStrings (This : Parser) return UString_List is
      function Closure (Param_0 : <>) return UString is
      begin
         return Param_0.toString (vocab);
      end Closure;
   begin
      if not Is_Valid (This.interp) then
         return UString.Container.Empty_Vector;
      else
         vocab : constant := This.getVocabulary;
         return This.interp.decisionToDFA.map (Closure'Access);
      end if;
   end getDFAStrings;

   procedure dumpDFA (This : Parser) is
   begin
      if not Is_Valid (interp) then
         exit;
      else
         seenOne := False;
         vocab : constant := This.getVocabulary;
         for dfa of This.interp.decisionToDFA loop
            if not dfa.states.Is_Empty then
               if seenOne then
                  Wide_Wide_Text_IO.Put_Line ("");
               end if;
               Wide_Wide_Text_IO.Put_Line ("Decision " & dfa.decision & ':');
               Wide_Wide_Text_IO.Put_Line (dfa.toString (vocab), terminator: "");
               seenOne := True;
            end if;
         end loop;
      end if;
   end dumpDFA;

   overriding
   function getParseInfo (This : Parser) return Optional_ParseInfo is
      interp : constant := This.getInterpreter;
      interp : constant Optional_ProfilingATNSimulator := Maybe (interp);
   begin
      if Is_Valid (interp) then
         return ParseInfo (interp);
      else
         return (Valid => False);
      end if;
   end getParseInfo;

   procedure setProfile (This : Parser; profile : Boolean) is
      interp : constant := This.getInterpreter;
      saveMode : constant PredictionMode := interp.getPredictionMode;
   begin
      if profile then
         if not (interp is ProfilingATNSimulator) then
            setInterpreter (ProfilingATNSimulator (self));
      elsif interp is ProfilingATNSimulator then
         sim : constant := ParserATNSimulator (self, This.getATN, interp.decisionToDFA, interp.getSharedContextCache);
         setInterpreter (sim);
      end if;
      This.getInterpreter.setPredictionMode (saveMode);
   end setProfile;

   procedure setTrace (This : Parser; trace : Boolean) is
   begin
      if not trace then
         removeParseListener (tracer);
         This.tracer := (Valid => False);
      else
         tracer : constant := This.tracer;
         if Is_Valid (tracer) then
            removeParseListener (tracer);
         else
            This.tracer := TraceListener (This);
         end if;
         addParseListener (Value (This.tracer));
      end if;
   end setTrace;

end ANTLR.Runtime.Parsers;
