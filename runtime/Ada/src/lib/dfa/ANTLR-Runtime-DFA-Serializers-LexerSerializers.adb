-- €

package ANTLR.Runtime.DFA.Serializers.LexerSerializers is

   overriding
   procedure Initialize (Self : in out LexerDFASerializer; dfa : DFA) is
   begin
      Super (Self).Initialize (dfa, Vocabulary.EMPTY_VOCABULARY);
   end Initialize;

   overriding
   function getEdgeLabel (i : Integer) return UString
      is ("'" & Character (integerLiteral => i) & '''); --TOFIX

end ANTLR.Runtime.DFA.Serializers.LexerSerializers;
