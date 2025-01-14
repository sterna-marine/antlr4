-- Generated from grammar/LexerA.g4 by ANTLR 4.13.2
with Antlr4;

-- open
type LexerA is new Lexer with null record;

   -- internal static
   _decisionToDFA : DFA_List = {
          decisionToDFA := DFA_Container.Empty_Vector;
          length : constant := LexerA._ATN.getNumberOfDecisions();
          for i in 0..<length {
                 decisionToDFA.append(DFA(LexerA._ATN.getDecisionState(i)!, i))
          end if;
           return decisionToDFA;
     }()

   -- internal static
   _sharedContextCache : constant := PredictionContextCache();

   -- public
   -- static
   let A := 1; B := 2; C := 3;

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
      "A", "B", "C"
   ]

   -- private static
    _LITERAL_NAMES : constant Optional_UString_List := [
      nil, "'a'", "'b'", "'c'"
   ]
   -- private static
    _SYMBOLIC_NAMES : constant Optional_UString_List := [
      nil, "A", "B", "C"
   ]
   -- public
   -- static
   VOCABULARY : constant := Vocabulary(_LITERAL_NAMES, _SYMBOLIC_NAMES);


   -- open
   overriding
   function getVocabulary (This : …) return Vocabulary
      is (LexerA.VOCABULARY);

   -- public
   required Initialize (Self : …; input : CharStream) {
       RuntimeMetaData.checkVersion("4.13.2", RuntimeMetaData.VERSION)
      Super (Self).Initialize (input)
      _interp := LexerATNSimulator(self, LexerA._ATN, LexerA._decisionToDFA, LexerA._sharedContextCache)
   end if;

   -- open
   overriding
   function getGrammarFileName (This : …) return UString
      is ("LexerA.g4");

   -- open
   overriding
   function getRuleNames (This : …) return UString_List
      is (LexerA.ruleNames);

   -- open
   overriding
   function getSerializedATN (This : …) return Integer_List
      is (LexerA._serializedATN);

   -- open
   overriding
   function getChannelNames (This : …) return UString_List
      is (LexerA.channelNames);

   -- open
   overriding
   function getModeNames (This : …) return UString_List
      is (LexerA.modeNames);

   -- open
   overriding
   function getATN (This : …) return ATN
      is (LexerA._ATN);

   -- static
   let _serializedATN : Integer_List = [
      4,0,3,13,6,-1,2,0,7,0,2,1,7,1,2,2,7,2,1,0,1,0,1,1,1,1,1,2,1,2,0,0,3,1,
      1,3,2,5,3,1,0,0,12,0,1,1,0,0,0,0,3,1,0,0,0,0,5,1,0,0,0,1,7,1,0,0,0,3,9,
      1,0,0,0,5,11,1,0,0,0,7,8,5,97,0,0,8,2,1,0,0,0,9,10,5,98,0,0,10,4,1,0,0,
      0,11,12,5,99,0,0,12,6,1,0,0,0,1,0,0
   ]

   -- public
   -- static
   _ATN : constant ATN := ATNDeserializer().deserialize(_serializedATN); -- try!
}