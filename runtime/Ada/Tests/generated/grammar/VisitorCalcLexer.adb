-- Generated from grammar/VisitorCalc.g4 by ANTLR 4.13.2
with Antlr4;

-- open
type VisitorCalcLexer is new Lexer with null record;

   -- internal static
   _decisionToDFA : DFA_List = {
          decisionToDFA := DFA_Container.Empty_Vector;
          length : constant := VisitorCalcLexer._ATN.getNumberOfDecisions();
          for i in 0..<length {
                 decisionToDFA.append(DFA(VisitorCalcLexer._ATN.getDecisionState(i)!, i))
          end if;
           return decisionToDFA;
     }()

   -- internal static
   _sharedContextCache : constant := PredictionContextCache();

   -- public
   -- static
   let INT := 1; MUL := 2; DIV := 3; ADD := 4; SUB := 5; WS := 6;

   -- public
   -- static
   channelNames : constant UString_List := [
      "DEFAULT_TOKEN_CHANNEL", "HIDDEN"
   ]

   -- public
   -- static
   modeNames : constant UString_List := [
      "DEFAULT_MODE"
   ]

   -- public
   -- static
   ruleNames : constant UString_List := [
      "INT", "MUL", "DIV", "ADD", "SUB", "WS"
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
   function getVocabulary (This : …) return Vocabulary
      is (VisitorCalcLexer.VOCABULARY);

   -- public
   required Initialize (Self : …; input : CharStream) {
       RuntimeMetaData.checkVersion("4.13.2", RuntimeMetaData.VERSION)
      Super (Self).Initialize (input)
      _interp := LexerATNSimulator(self, VisitorCalcLexer._ATN, VisitorCalcLexer._decisionToDFA, VisitorCalcLexer._sharedContextCache)
   end if;

   -- open
   overriding
   function getGrammarFileName (This : …) return UString
      is ("VisitorCalc.g4");

   -- open
   overriding
   function getRuleNames (This : …) return UString_List
      is (VisitorCalcLexer.ruleNames);

   -- open
   overriding
   function getSerializedATN (This : …) return Integer_List
      is (VisitorCalcLexer._serializedATN);

   -- open
   overriding
   function getChannelNames (This : …) return UString_List
      is (VisitorCalcLexer.channelNames);

   -- open
   overriding
   function getModeNames (This : …) return UString_List
      is (VisitorCalcLexer.modeNames);

   -- open
   overriding
   function getATN (This : …) return ATN
      is (VisitorCalcLexer._ATN);

   -- static
   let _serializedATN : Integer_List = [
      4,0,6,33,6,-1,2,0,7,0,2,1,7,1,2,2,7,2,2,3,7,3,2,4,7,4,2,5,7,5,1,0,4,0,
      15,8,0,11,0,12,0,16,1,1,1,1,1,2,1,2,1,3,1,3,1,4,1,4,1,5,4,5,28,8,5,11,
      5,12,5,29,1,5,1,5,0,0,6,1,1,3,2,5,3,7,4,9,5,11,6,1,0,2,1,0,48,57,2,0,9,
      9,32,32,34,0,1,1,0,0,0,0,3,1,0,0,0,0,5,1,0,0,0,0,7,1,0,0,0,0,9,1,0,0,0,
      0,11,1,0,0,0,1,14,1,0,0,0,3,18,1,0,0,0,5,20,1,0,0,0,7,22,1,0,0,0,9,24,
      1,0,0,0,11,27,1,0,0,0,13,15,7,0,0,0,14,13,1,0,0,0,15,16,1,0,0,0,16,14,
      1,0,0,0,16,17,1,0,0,0,17,2,1,0,0,0,18,19,5,42,0,0,19,4,1,0,0,0,20,21,5,
      47,0,0,21,6,1,0,0,0,22,23,5,43,0,0,23,8,1,0,0,0,24,25,5,45,0,0,25,10,1,
      0,0,0,26,28,7,1,0,0,27,26,1,0,0,0,28,29,1,0,0,0,29,27,1,0,0,0,29,30,1,
      0,0,0,30,31,1,0,0,0,31,32,6,5,0,0,32,12,1,0,0,0,3,0,16,29,1,0,1,0
   ]

   -- public
   -- static
   _ATN : constant ATN := ATNDeserializer().deserialize(_serializedATN); -- try!
}