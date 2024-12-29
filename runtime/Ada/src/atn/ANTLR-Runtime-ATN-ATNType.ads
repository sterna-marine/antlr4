-- €

package ANTLR.Runtime.ATN.ATNType is

-- Represents the type of recognizer an ATN applies to.

   type ATNType is (lexer, parser);
   for ATNType use (
      lexer  => 0,   -- A lexer grammar.
      parser => 1);  -- A parser grammar.
   for ATNType'Size use Integer'Size;

end ANTLR.Runtime.ATN.ATNType;
