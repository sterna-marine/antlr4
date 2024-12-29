-- €

package body ANTLR.Runtime.Recognizers.Lexers.Interpreters.LexerInterpreters is

   procedure Initialize (Self : in out LexerInterpreter;
                   grammarFileName : UString;
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
      self._decisionToDFA := DFA.Container.Empty_Vector;

      for i in 0 ..< atn.getNumberOfDecisions () loop
         _decisionToDFA.append (DFA (atn.getDecisionState (i)!, i));
      end loop;

      Lexer.init (input); -- super
      self._interp := LexerATNSimulator (self, atn, _decisionToDFA, _sharedContextCache);

      if atn.grammarType /= ATNType.lexer then
         raise ANTLRError.illegalArgument with "The ATN must be a lexer ATN.";
      end if;
    end Initialize;

   procedure Initialize (input : CharStream) is
   begin
      raise PROGRAM_ERROR with "Use the other initializer";
   end Initialize;

end ANTLR.Runtime.Recognizers.Lexers.Interpreters.LexerInterpreters;
