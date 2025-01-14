-- Generated from grammar/VisitorBasic.g4 by ANTLR 4.13.2
with Antlr4;

-- open
type VisitorBasicLexer is new Lexer with null record;

   -- internal static
   _decisionToDFA : DFA_List = {
          decisionToDFA := DFA_Container.Empty_Vector;
          length : constant := VisitorBasicLexer._ATN.getNumberOfDecisions();
          for i in 0..<length {
                 decisionToDFA.append(DFA(VisitorBasicLexer._ATN.getDecisionState(i)!, i))
          end if;
           return decisionToDFA;
     }()

   -- internal static
   _sharedContextCache : constant := PredictionContextCache();

   -- public
   -- static
   let A := 1;

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
      "A"
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
   function getVocabulary (This : …) return Vocabulary
      is (VisitorBasicLexer.VOCABULARY);

   -- public
   required Initialize (Self : …; input : CharStream) {
       RuntimeMetaData.checkVersion("4.13.2", RuntimeMetaData.VERSION)
      Super (Self).Initialize (input)
      _interp := LexerATNSimulator(self, VisitorBasicLexer._ATN, VisitorBasicLexer._decisionToDFA, VisitorBasicLexer._sharedContextCache)
   end if;

   -- open
   overriding
   function getGrammarFileName (This : …) return UString
      is ("VisitorBasic.g4");

   -- open
   overriding
   function getRuleNames (This : …) return UString_List
      is (VisitorBasicLexer.ruleNames);

   -- open
   overriding
   function getSerializedATN (This : …) return Integer_List
      is (VisitorBasicLexer._serializedATN);

   -- open
   overriding
   function getChannelNames (This : …) return UString_List
      is (VisitorBasicLexer.channelNames);

   -- open
   overriding
   function getModeNames (This : …) return UString_List
      is (VisitorBasicLexer.modeNames);

   -- open
   overriding
   function getATN (This : …) return ATN
      is (VisitorBasicLexer._ATN);

   -- static
   let _serializedATN : Integer_List = [
      4,0,1,5,6,-1,2,0,7,0,1,0,1,0,0,0,1,1,1,1,0,0,4,0,1,1,0,0,0,1,3,1,0,0,0,
      3,4,5,65,0,0,4,2,1,0,0,0,1,0,0
   ]

   -- public
   -- static
   _ATN : constant ATN := ATNDeserializer().deserialize(_serializedATN); -- try!
}