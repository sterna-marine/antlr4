-- €

with UString;
with ANTLR.Runtime.DFA;
with ANTLR.Runtime.Lexer;

use UString;
use ANTLR.Runtime.DFA;
use ANTLR.Runtime.Lexer;

package ANTLR.Runtime.Lexers.Interpreters is

   -- public
   type LexerInterpreter is new Lexer with
   record
      -- internal
      grammarFileName : UString; -- constant

      -- internal
      atn : ATN; -- constant

      -- internal
      ruleNames : UString_List; -- constant
      -- internal
      channelNames : UString_List; -- constant
      -- internal
      modeNames : UString_List; -- constant

      -- private
      vocabulary : Optional_Vocabulary; -- constant

      -- internal final
      _decisionToDFA : DFA_List;

      -- internal
      _sharedContextCache : := This.PredictionContextCache; -- constant

   end record;

   subtype Object is LexerInterpreter;
   subtype Super is Lexer;
   type Class is access all Object;
   type Class_Wide is access all Object'Class;

   -- public
   procedure Initialize (Self : in out LexerInterpreter;
                   grammarFileName : UString;
                   vocabulary : Vocabulary;
                   ruleNames : array (<>) of UString;
                   channelNames : array (<>) of UString;
                   modeNames : array (<>) of UString;
                   atn : ATN;
                   input : CharStream);

   -- public required
   procedure Initialize (input : CharStream);

   overriding
   -- public
   function getATN (This : LexerInterpreter) return ATN
      is (This.atn);

   overriding
   -- public
   function getGrammarFileName (This : LexerInterpreter) return UString
      is (This.grammarFileName);

   overriding
   -- public
   function getRuleNames (This : LexerInterpreter) return UString_List
      is (This.ruleNames);

   overriding
   -- public
   function getChannelNames (This : LexerInterpreter) return UString_List
      is (This.channelNames);

   overriding
   -- public
   function getModeNames (This : LexerInterpreter) return UString_List
      is (This.modeNames);

   overriding
   -- public
   function getVocabulary (This : LexerInterpreter) return Vocabulary
      is (Is_Valid (This.vocabulary) return This.vocabulary
         else return Lexer.getVocabulary (This));

end ANTLR.Runtime.Lexers.Interpreters;
