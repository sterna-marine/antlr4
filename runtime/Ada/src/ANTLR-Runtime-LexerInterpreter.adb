-- €

package body ANTLR.Runtime.LexerInterpreter is

   procedure Init (Self : in out LexerInterpreter;
                   grammarFileName : String;
                   vocabulary : Vocabulary;
                   ruleNames : array (<>) of UString;
                   channelNames : array (<>) of UString;
                   modeNames : array (<>) of UString;
                   atn : ATN;
                   input : CharStream) is
   begin
      self.grammarFileName := grammarFileName;
      self.atn := atn;
      self.ruleNames := ruleNames;
      self.channelNames := channelNames;
      self.modeNames := modeNames;
      self.vocabulary := vocabulary;
      self._decisionToDFA := [DFA]();

      for i in 0 ..< atn.getNumberOfDecisions () loop
         _decisionToDFA.append (DFA (atn.getDecisionState (i)!, i));
      end loop;

      Lexer.init (input); -- super
      self._interp := LexerATNSimulator (self, atn, _decisionToDFA, _sharedContextCache);

      if atn.grammarType /= ATNType.lexer then
         raise ANTLRError.illegalArgument with "The ATN must be a lexer ATN.";
      end if;
    end Init;

   procedure Init (input : CharStream) is
   begin
      raise PROGRAM_ERROR with "Use the other initializer";
   end Init;

end ANTLR.Runtime.LexerInterpreter;
