-- Generated from grammar/LexerB.g4 by ANTLR 4.13.2
with Antlr4;

-- open
type LexerB is new Lexer with null record;

   -- internal static
   _decisionToDFA : DFA_List = {
          decisionToDFA := DFA_Container.Empty_Vector;
          length : constant := LexerB._ATN.getNumberOfDecisions();
          for i in 0..<length {
                 decisionToDFA.append(DFA(LexerB._ATN.getDecisionState(i)!, i))
          end if;
           return decisionToDFA;
     }()

   -- internal static
   _sharedContextCache : constant := PredictionContextCache();

   -- public
   -- static
   let ID := 1; INT := 2; SEMI := 3; MUL := 4; PLUS := 5; ASSIGN := 6; WS := 7;

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
      "ID", "INT", "SEMI", "MUL", "PLUS", "ASSIGN", "WS"
   ]

   -- private static
    _LITERAL_NAMES : constant Optional_UString_List := [
      nil, nil, nil, "';'", "'*'", "'+'", "'='"
   ]
   -- private static
    _SYMBOLIC_NAMES : constant Optional_UString_List := [
      nil, "ID", "INT", "SEMI", "MUL", "PLUS", "ASSIGN", "WS"
   ]
   -- public
   -- static
   VOCABULARY : constant := Vocabulary(_LITERAL_NAMES, _SYMBOLIC_NAMES);


   -- open
   overriding
   function getVocabulary (This : …) return Vocabulary
      is (LexerB.VOCABULARY);

   -- public
   required Initialize (Self : …; input : CharStream) {
       RuntimeMetaData.checkVersion("4.13.2", RuntimeMetaData.VERSION)
      Super (Self).Initialize (input)
      _interp := LexerATNSimulator(self, LexerB._ATN, LexerB._decisionToDFA, LexerB._sharedContextCache)
   end if;

   -- open
   overriding
   function getGrammarFileName (This : …) return UString
      is ("LexerB.g4");

   -- open
   overriding
   function getRuleNames (This : …) return UString_List
      is (LexerB.ruleNames);

   -- open
   overriding
   function getSerializedATN (This : …) return Integer_List
      is (LexerB._serializedATN);

   -- open
   overriding
   function getChannelNames (This : …) return UString_List
      is (LexerB.channelNames);

   -- open
   overriding
   function getModeNames (This : …) return UString_List
      is (LexerB.modeNames);

   -- open
   overriding
   function getATN (This : …) return ATN
      is (LexerB._ATN);

   -- static
   let _serializedATN : Integer_List = [
      4,0,7,38,6,-1,2,0,7,0,2,1,7,1,2,2,7,2,2,3,7,3,2,4,7,4,2,5,7,5,2,6,7,6,
      1,0,4,0,17,8,0,11,0,12,0,18,1,1,4,1,22,8,1,11,1,12,1,23,1,2,1,2,1,3,1,
      3,1,4,1,4,1,5,1,5,1,6,4,6,35,8,6,11,6,12,6,36,0,0,7,1,1,3,2,5,3,7,4,9,
      5,11,6,13,7,1,0,0,40,0,1,1,0,0,0,0,3,1,0,0,0,0,5,1,0,0,0,0,7,1,0,0,0,0,
      9,1,0,0,0,0,11,1,0,0,0,0,13,1,0,0,0,1,16,1,0,0,0,3,21,1,0,0,0,5,25,1,0,
      0,0,7,27,1,0,0,0,9,29,1,0,0,0,11,31,1,0,0,0,13,34,1,0,0,0,15,17,2,97,122,
      0,16,15,1,0,0,0,17,18,1,0,0,0,18,16,1,0,0,0,18,19,1,0,0,0,19,2,1,0,0,0,
      20,22,2,48,57,0,21,20,1,0,0,0,22,23,1,0,0,0,23,21,1,0,0,0,23,24,1,0,0,
      0,24,4,1,0,0,0,25,26,5,59,0,0,26,6,1,0,0,0,27,28,5,42,0,0,28,8,1,0,0,0,
      29,30,5,43,0,0,30,10,1,0,0,0,31,32,5,61,0,0,32,12,1,0,0,0,33,35,5,32,0,
      0,34,33,1,0,0,0,35,36,1,0,0,0,36,34,1,0,0,0,36,37,1,0,0,0,37,14,1,0,0,
      0,4,0,18,23,36,0
   ]

   -- public
   -- static
   _ATN : constant ATN := ATNDeserializer().deserialize(_serializedATN); -- try!
}