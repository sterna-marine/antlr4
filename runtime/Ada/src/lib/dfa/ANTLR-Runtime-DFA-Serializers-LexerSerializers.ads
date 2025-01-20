-- €

package ANTLR.Runtime.DFA.Serializers.LexerSerializers is

   -- public
   type LexerDFASerializer is new DFASerializer with null record;

   subtype Object is LexerDFASerializer;
   subtype Super is DFASerializer;
   type Class is access all Object;
   type Class_Wide is access all Object'Class;

   -- public
   overriding
   procedure Initialize (Self : in out LexerDFASerializer; dfa : DFA);

   overriding
   function getEdgeLabel (i : Integer) return UString
      is ("'" & Character (integerLiteral => i) & "'"); --TOFIX

end ANTLR.Runtime.DFA.Serializers.LexerSerializers;
