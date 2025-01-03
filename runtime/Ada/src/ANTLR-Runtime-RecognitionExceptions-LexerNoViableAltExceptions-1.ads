-- €

with ANTLR.Runtime.ATN.ConfigSets;
with ANTLR.Runtime.RecognitionExceptions;
with ANTLR.Runtime.ParserRuleContexts;

use ANTLR.Runtime.ATN.ConfigSets;
use ANTLR.Runtime.RecognitionExceptions;
use ANTLR.Runtime.ParserRuleContexts;

package ANTLR.Runtime.RecognitionExceptions.LexerNoViableAltExceptions is

   -- public
   type LexerNoViableAltException is new RecognitionException with
   record
      --
      -- Matching attempted at what input index?
      --
      -- private
      startIndex : Integer; -- constant

      --
      -- Which configurations did we at input.index () that couldn't match input.LA (1)?;
      --
      -- private
      deadEndConfigs : ATNConfigSet; -- constant
   end record;

   subtype Object is LexerNoViableAltException;
   subtype Super is RecognitionException;
   type Class is access all Object;
   type Class_Wide is access all Object'Class;

   -- public
   procedure Initialize (Self : in out LexerNoViableAltException;
                   lexer : Optional_Lexer;
                   input : CharStream;
                   startIndex : Integer;
                   deadEndConfigs : ATNConfigSet);

   -- public
   function getStartIndex (This : LexerNoViableAltException) return Integer
      is (This.startIndex);

   -- public
   function getDeadEndConfigs (This : LexerNoViableAltException) return ATNConfigSet
      is (This.deadEndConfigs);

   -- public
   subtype Sink is Ada.Strings.Text_Buffers.Root_Buffer_Type;
   procedure Put_Image_LexerNoViableAltException (S : in out Sink'Class; X : LexerNoViableAltException);
   for LexerNoViableAltException'Put_Image use Put_Image_LexerNoViableAltException;
   function Description (This : LexerNoViableAltException) return UString;

end ANTLR.Runtime.RecognitionExceptions.LexerNoViableAltExceptions;
