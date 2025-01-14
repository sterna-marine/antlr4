-- Generated from grammar/Threading.g4 by ANTLR 4.13.2
with Antlr4;

-- open
type ThreadingParser is new Parser with null record;

   -- internal static
   _decisionToDFA : DFA_List = {
          decisionToDFA := DFA_Container.Empty_Vector;
          length : constant := ThreadingParser._ATN.getNumberOfDecisions();
          for i in 0..<length {
            decisionToDFA.append(DFA(ThreadingParser._ATN.getDecisionState(i)!, i))
           end if;
           return decisionToDFA;
     }()

   -- internal static
   _sharedContextCache : constant := PredictionContextCache();

   -- public
   enum Tokens : Integer {
      case EOF = -1, INT := 1, MUL := 2, DIV := 3, ADD := 4, SUB := 5, WS := 6
   end if;

   -- public
   -- static
   RULE_s : constant := 0, RULE_expr := 1;

   -- public
   -- static
   ruleNames : constant UString_List := [
      "s", "expr"
   ]

   -- private static
    _LITERAL_NAMES : constant Optional_UString_List := [
      nil, nil, "'*'", "'/'", "'+'", "'-'"
   ]
   -- private static
    _SYMBOLIC_NAMES : constant Optional_UString_List := [
      nil, "INT", "MUL", "DIV", "ADD", "SUB", "WS"
   ]
   -- public
   -- static
   VOCABULARY : constant := Vocabulary(_LITERAL_NAMES, _SYMBOLIC_NAMES);

   -- open
   overriding
   function getGrammarFileName (This : …) return UString
      is ("Threading.g4");

   -- open
   overriding
   function getRuleNames (This : …) return UString_List
      is (ThreadingParser.ruleNames);

   -- open
   overriding
   function getSerializedATN (This : …) return Integer_List
      is (ThreadingParser._serializedATN);

   -- open
   overriding
   function getATN (This : …) return ATN
      is (ThreadingParser._ATN);


   -- open
   overriding
   function getVocabulary (This : …) return Vocabulary
      is (ThreadingParser.VOCABULARY);

   -- public
   overriding
    procedure Initialize (Self : …; input :TokenStream) throws {
       RuntimeMetaData.checkVersion("4.13.2", RuntimeMetaData.VERSION)
      Super (Self).Initialize (input); -- try
      _interp := ParserATNSimulator(self,ThreadingParser._ATN,ThreadingParser._decisionToDFA, ThreadingParser._sharedContextCache)
   end if;


   -- public
   type SContext is new ParserRuleContext with null record;
         -- open
         function expr (This : …) return Optional_ExprContext
            is (getRuleContext(ExprContext.self, 0));
         -- open
         function EOF (This : …) return Optional_TerminalNode
            is (getToken(ThreadingParser.Tokens.EOF.rawValue, 0));
      -- open
      overriding
      function getRuleIndex (This : …) return Integer
         is (ThreadingParser.RULE_s);
      -- open
      overriding
      procedure enterRule (This : …; listener : ParseTreeListener) is
      begin
         if listener : constant := listener Optional_as ThreadingListener then
            listener.enterS(self)
         end if;
      end if;
      -- open
      overriding
      procedure exitRule (This : …; listener : ParseTreeListener) is
      begin
         if listener : constant := listener Optional_as ThreadingListener then
            listener.exitS(self)
         end if;
      end if;
      -- open
      overriding
      generic
         type T is private;
      function accept (This : …; visitor : ParseTreeVisitor<T>) return Optional_T {
         if visitor : constant := visitor Optional_as ThreadingVisitor then
             return visitor.visitS(self);
         elsif visitor : constant := visitor Optional_as ThreadingBaseVisitor then
             return visitor.visitS(self);
         else
              return visitor.visitChildren(self);
         end if;
      end if;
   end if;
   -- with No_Return;
    -- open
    function s (This : …) return SContext is
    begin
      var _localctx : SContext
      _localctx := SContext(_ctx, getState())
      enterRule(_localctx, 0, ThreadingParser.RULE_s); -- try
      defer :
         begin
         end defer;
             exitRule(); -- try!
       end if;
      do :
         declare
         begin
         exception
         end do;
          enterOuterAlt(_localctx, 1); -- try
          setState(4)
          expr(0); -- try
          setState(5)
          match(ThreadingParser.Tokens.EOF.rawValue); -- try

      end if;
      catch ANTLRException.recognition(let re) {
         _localctx.exception := re
         _errHandler.reportError(self, re)
         _errHandler.recover(self, re); -- try
      end if;

      return _localctx;
   end if;


   -- public
   type ExprContext is new ParserRuleContext with null record;
      -- open
      overriding
      function getRuleIndex (This : …) return Integer
         is (ThreadingParser.RULE_expr);
   end if;
   -- public
   type AddContext is new ExprContext with null record;
         -- open
         function expr (This : …) return ExprContext_List
            is (getRuleContexts(ExprContext.self));
         -- open
         function expr (This : …; i : Integer) return Optional_ExprContext
            is (getRuleContext(ExprContext.self, i));
         -- open
         function ADD (This : …) return Optional_TerminalNode
            is (getToken(ThreadingParser.Tokens.ADD.rawValue, 0));
         -- open
         function SUB (This : …) return Optional_TerminalNode
            is (getToken(ThreadingParser.Tokens.SUB.rawValue, 0));

      -- public
       procedure Initialize (Self : …; ctx : ExprContext) {
         Super (Self).Initialize ()
         copyFrom(ctx)
      end if;
      -- open
      overriding
      procedure enterRule (This : …; listener : ParseTreeListener) is
      begin
         if listener : constant := listener Optional_as ThreadingListener then
            listener.enterAdd(self)
         end if;
      end if;
      -- open
      overriding
      procedure exitRule (This : …; listener : ParseTreeListener) is
      begin
         if listener : constant := listener Optional_as ThreadingListener then
            listener.exitAdd(self)
         end if;
      end if;
      -- open
      overriding
      generic
         type T is private;
      function accept (This : …; visitor : ParseTreeVisitor<T>) return Optional_T {
         if visitor : constant := visitor Optional_as ThreadingVisitor then
             return visitor.visitAdd(self);
         elsif visitor : constant := visitor Optional_as ThreadingBaseVisitor then
             return visitor.visitAdd(self);
         else
              return visitor.visitChildren(self);
         end if;
      end if;
   end if;
   -- public
   type NumberContext is new ExprContext with null record;
         -- open
         function INT (This : …) return Optional_TerminalNode
            is (getToken(ThreadingParser.Tokens.INT.rawValue, 0));

      -- public
       procedure Initialize (Self : …; ctx : ExprContext) {
         Super (Self).Initialize ()
         copyFrom(ctx)
      end if;
      -- open
      overriding
      procedure enterRule (This : …; listener : ParseTreeListener) is
      begin
         if listener : constant := listener Optional_as ThreadingListener then
            listener.enterNumber(self)
         end if;
      end if;
      -- open
      overriding
      procedure exitRule (This : …; listener : ParseTreeListener) is
      begin
         if listener : constant := listener Optional_as ThreadingListener then
            listener.exitNumber(self)
         end if;
      end if;
      -- open
      overriding
      generic
         type T is private;
      function accept (This : …; visitor : ParseTreeVisitor<T>) return Optional_T {
         if visitor : constant := visitor Optional_as ThreadingVisitor then
             return visitor.visitNumber(self);
         elsif visitor : constant := visitor Optional_as ThreadingBaseVisitor then
             return visitor.visitNumber(self);
         else
              return visitor.visitChildren(self);
         end if;
      end if;
   end if;
   -- public
   type MultiplyContext is new ExprContext with null record;
         -- open
         function expr (This : …) return ExprContext_List
            is (getRuleContexts(ExprContext.self));
         -- open
         function expr (This : …; i : Integer) return Optional_ExprContext
            is (getRuleContext(ExprContext.self, i));
         -- open
         function MUL (This : …) return Optional_TerminalNode
            is (getToken(ThreadingParser.Tokens.MUL.rawValue, 0));
         -- open
         function DIV (This : …) return Optional_TerminalNode
            is (getToken(ThreadingParser.Tokens.DIV.rawValue, 0));

      -- public
       procedure Initialize (Self : …; ctx : ExprContext) {
         Super (Self).Initialize ()
         copyFrom(ctx)
      end if;
      -- open
      overriding
      procedure enterRule (This : …; listener : ParseTreeListener) is
      begin
         if listener : constant := listener Optional_as ThreadingListener then
            listener.enterMultiply(self)
         end if;
      end if;
      -- open
      overriding
      procedure exitRule (This : …; listener : ParseTreeListener) is
      begin
         if listener : constant := listener Optional_as ThreadingListener then
            listener.exitMultiply(self)
         end if;
      end if;
      -- open
      overriding
      generic
         type T is private;
      function accept (This : …; visitor : ParseTreeVisitor<T>) return Optional_T {
         if visitor : constant := visitor Optional_as ThreadingVisitor then
             return visitor.visitMultiply(self);
         elsif visitor : constant := visitor Optional_as ThreadingBaseVisitor then
             return visitor.visitMultiply(self);
         else
              return visitor.visitChildren(self);
         end if;
      end if;
   end if;

    -- public final
      function expr (This : …; ) return ExprContext is
      begin
      return try expr(0);
   end if;
   -- with No_Return;
   -- private
   function expr (This : …; _p : Integer) return ExprContext is
   begin
      let _parentctx : Optional_ParserRuleContext := _ctx
      _parentState : constant Integer := getState()
      var _localctx : ExprContext
      _localctx := ExprContext(_ctx, _parentState)
      var _prevctx : ExprContext := _localctx
      _startState : constant Integer := 2
      enterRecursionRule(_localctx, 2, ThreadingParser.RULE_expr, _p); -- try
      var _la : Integer := 0
      defer :
         begin
         end defer;
             unrollRecursionContexts(_parentctx); -- try!
       end if;
      do :
         declare
         begin
         exception
         end do;
         var _alt : Integer
         enterOuterAlt(_localctx, 1); -- try
         _localctx := NumberContext(_localctx)
         _ctx := _localctx
         _prevctx := _localctx

         setState(8)
         match(ThreadingParser.Tokens.INT.rawValue); -- try

         _ctx!.stop := try _input.LT(-1)
         setState(18)
         _errHandler.sync(self); -- try
         _alt := try getInterpreter().adaptivePredict(_input,1,_ctx)
         while (_alt != 2 and then _alt != ATN.INVALID_ALT_NUMBER) {
            if ( _alt = 1 ) {
               if _parseListeners != nil {
                  triggerExitRuleEvent(); -- try
               end if;
               _prevctx := _localctx
               setState(16)
               _errHandler.sync(self); -- try
               switch(try getInterpreter().adaptivePredict(_input,0, _ctx)) {
               case 1 :
                  _localctx := MultiplyContext(  ExprContext(_parentctx, _parentState))
                  pushNewRecursionContext(_localctx, _startState, ThreadingParser.RULE_expr); -- try
                  setState(10)
                  if (!(precpred(_ctx, 2))) {
                      throw ANTLRException.recognition(e :FailedPredicateException(self, "precpred(_ctx, 2)"))
                  end if;
                  setState(11)
                  _la := try _input.LA(1)
                  if (!(_la  =  ThreadingParser.Tokens.MUL.rawValue or else _la  =  ThreadingParser.Tokens.DIV.rawValue)) {
                  _errHandler.recoverInline(self); -- try
                  else
                     _errHandler.reportMatch(self)
                     consume(); -- try
                  end if;
                  setState(12)
                  expr(3); -- try

                  break
               case 2 :
                  _localctx := AddContext(  ExprContext(_parentctx, _parentState))
                  pushNewRecursionContext(_localctx, _startState, ThreadingParser.RULE_expr); -- try
                  setState(13)
                  if (!(precpred(_ctx, 1))) {
                      throw ANTLRException.recognition(e :FailedPredicateException(self, "precpred(_ctx, 1)"))
                  end if;
                  setState(14)
                  _la := try _input.LA(1)
                  if (!(_la  =  ThreadingParser.Tokens.ADD.rawValue or else _la  =  ThreadingParser.Tokens.SUB.rawValue)) {
                  _errHandler.recoverInline(self); -- try
                  else
                     _errHandler.reportMatch(self)
                     consume(); -- try
                  end if;
                  setState(15)
                  expr(2); -- try

                  break
               default : break
               end if;
          
            end if;
            setState(20)
            _errHandler.sync(self); -- try
            _alt := try getInterpreter().adaptivePredict(_input,1,_ctx)
         end if;

      end if;
      catch ANTLRException.recognition(let re) {
         _localctx.exception := re
         _errHandler.reportError(self, re)
         _errHandler.recover(self, re); -- try
      end if;

      return _localctx;;
   end if;

   -- open
   overriding
   procedure sempred (This : …; _localctx : Optional_RuleContext; ruleIndex : Integer; predIndex : Integer) return Boolean {
      switch (ruleIndex) {
      case  1 :
         return try expr_sempred(Optional__localctx.castdown(ExprContext.self), predIndex);
       default : return true
      end if;
   end if;
   -- private
   function expr_sempred (This : …; _localctx : ExprContext!; predIndex : Integer) return Boolean is
   begin
      switch (predIndex) {
          case 0 :return precpred(_ctx, 2)
          case 1 :return precpred(_ctx, 1)
          default : return true
      end if;
   end if;

   -- static
   let _serializedATN : Integer_List = [
      4,1,6,22,2,0,7,0,2,1,7,1,1,0,1,0,1,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
      1,5,1,17,8,1,10,1,12,1,20,9,1,1,1,0,1,2,2,0,2,0,2,1,0,2,3,1,0,4,5,21,0,
      4,1,0,0,0,2,7,1,0,0,0,4,5,3,2,1,0,5,6,5,0,0,1,6,1,1,0,0,0,7,8,6,1,-1,0,
      8,9,5,1,0,0,9,18,1,0,0,0,10,11,10,2,0,0,11,12,7,0,0,0,12,17,3,2,1,3,13,
      14,10,1,0,0,14,15,7,1,0,0,15,17,3,2,1,2,16,10,1,0,0,0,16,13,1,0,0,0,17,
      20,1,0,0,0,18,16,1,0,0,0,18,19,1,0,0,0,19,3,1,0,0,0,20,18,1,0,0,0,2,16,
      18
   ]

   -- public
   -- static
   _ATN : constant := ATNDeserializer().deserialize(_serializedATN);; -- try!
}