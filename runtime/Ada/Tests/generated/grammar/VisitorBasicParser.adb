-- Generated from grammar/VisitorBasic.g4 by ANTLR 4.13.2
with Antlr4;

-- open
type VisitorBasicParser is new Parser with null record;

   -- internal static
   _decisionToDFA : DFA_List = {
          decisionToDFA := DFA_Container.Empty_Vector;
          length : constant := VisitorBasicParser._ATN.getNumberOfDecisions();
          for i in 0..<length {
            decisionToDFA.append(DFA(VisitorBasicParser._ATN.getDecisionState(i)!, i))
           end if;
           return decisionToDFA;
     }()

   -- internal static
   _sharedContextCache : constant := PredictionContextCache();

   -- public
   enum Tokens : Integer {
      case EOF = -1, A := 1
   end if;

   -- public
   -- static
   RULE_s : constant := 0;

   -- public
   -- static
   ruleNames : constant UString_List := [
      "s"
   ]

   -- private static
    _LITERAL_NAMES : constant Optional_UString_List := [
      nil, "'A'"
   ]
   -- private static
    _SYMBOLIC_NAMES : constant Optional_UString_List := [
      nil, "A"
   ]
   -- public
   -- static
   VOCABULARY : constant := Vocabulary(_LITERAL_NAMES, _SYMBOLIC_NAMES);

   -- open
   overriding
   function getGrammarFileName (This : …) return UString
      is ("VisitorBasic.g4");

   -- open
   overriding
   function getRuleNames (This : …) return UString_List
      is (VisitorBasicParser.ruleNames);

   -- open
   overriding
   function getSerializedATN (This : …) return Integer_List
      is (VisitorBasicParser._serializedATN);

   -- open
   overriding
   function getATN (This : …) return ATN
      is (VisitorBasicParser._ATN);


   -- open
   overriding
   function getVocabulary (This : …) return Vocabulary
      is (VisitorBasicParser.VOCABULARY);

   -- public
   overriding
    procedure Initialize (Self : …; input :TokenStream) throws {
       RuntimeMetaData.checkVersion("4.13.2", RuntimeMetaData.VERSION)
      Super (Self).Initialize (input); -- try
      _interp := ParserATNSimulator(self,VisitorBasicParser._ATN,VisitorBasicParser._decisionToDFA, VisitorBasicParser._sharedContextCache)
   end if;


   -- public
   type SContext is new ParserRuleContext with null record;
         -- open
         function A (This : …) return Optional_TerminalNode
            is (getToken(VisitorBasicParser.Tokens.A.rawValue, 0));
         -- open
         function EOF (This : …) return Optional_TerminalNode
            is (getToken(VisitorBasicParser.Tokens.EOF.rawValue, 0));
      -- open
      overriding
      function getRuleIndex (This : …) return Integer
         is (VisitorBasicParser.RULE_s);
      -- open
      overriding
      procedure enterRule (This : …; listener : ParseTreeListener) is
      begin
         if listener : constant := listener Optional_as VisitorBasicListener then
            listener.enterS(self)
         end if;
      end if;
      -- open
      overriding
      procedure exitRule (This : …; listener : ParseTreeListener) is
      begin
         if listener : constant := listener Optional_as VisitorBasicListener then
            listener.exitS(self)
         end if;
      end if;
      -- open
      overriding
      generic
         type T is private;
      function accept (This : …; visitor : ParseTreeVisitor<T>) return Optional_T {
         if visitor : constant := visitor Optional_as VisitorBasicVisitor then
             return visitor.visitS(self);
         elsif visitor : constant := visitor Optional_as VisitorBasicBaseVisitor then
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
      enterRule(_localctx, 0, VisitorBasicParser.RULE_s); -- try
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
          setState(2)
          match(VisitorBasicParser.Tokens.A.rawValue); -- try
          setState(3)
          match(VisitorBasicParser.Tokens.EOF.rawValue); -- try

      end if;
      catch ANTLRException.recognition(let re) {
         _localctx.exception := re
         _errHandler.reportError(self, re)
         _errHandler.recover(self, re); -- try
      end if;

      return _localctx;
   end if;

   -- static
   let _serializedATN : Integer_List = [
      4,1,1,6,2,0,7,0,1,0,1,0,1,0,1,0,0,0,1,0,0,0,4,0,2,1,0,0,0,2,3,5,1,0,0,
      3,4,5,0,0,1,4,1,1,0,0,0,0
   ]

   -- public
   -- static
   _ATN : constant := ATNDeserializer().deserialize(_serializedATN);; -- try!
}