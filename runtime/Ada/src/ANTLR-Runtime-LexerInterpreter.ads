-- €

with UString;
with ANTLR.Runtime.DFA;
with ANTLR.Runtime.Lexer;

use UString;
use ANTLR.Runtime.DFA;
use ANTLR.Runtime.Lexer;

package ANTLR.Runtime.LexerInterpreter is

   -- public
   type LexerInterpreter is new Lexer with
   record
      -- internal
      grammarFileName : String; -- constant

      -- internal
      atn : ATN; -- constant

      -- internal
      ruleNames : UString.Container.Vector; -- constant
      -- internal
      channelNames : UString.Container.Vector; -- constant
      -- internal
      modeNames : UString.Container.Vector; -- constant

      -- private 
      vocabulary : Optional_Vocabulary; -- constant

      -- internal final
      _decisionToDFA : DFA.Container.Vector;

      -- internal
      _sharedContextCache : := PredictionContextCache (); -- constant
   
   end record;

   -- public 
   procedure Init (Self : in out LexerInterpreter;
                   grammarFileName : String;
                   vocabulary : Vocabulary;
                   ruleNames : array (<>) of UString;
                   channelNames : array (<>) of UString;
                   modeNames : array (<>) of UString;
                   atn : ATN;
                   input : CharStream);

   -- public required 
   procedure Init (input : CharStream);

   override
   -- public
   function getATN (This : LexerInterpreter) return ATN
      is (This.atn);

   override
   -- public
   function getGrammarFileName (This : LexerInterpreter) return String
      is (This.grammarFileName);

   override
   -- public
   function getRuleNames (This : LexerInterpreter) return UString.Container.Vector
      is (This.ruleNames);

   override
   -- public
   function getChannelNames (This : LexerInterpreter) return UString.Container.Vector
      is (This.channelNames);

   override
   -- public
   function getModeNames (This : LexerInterpreter) return UString.Container.Vector
      is (This.modeNames);

   override
   -- public
   function getVocabulary (This : LexerInterpreter) return Vocabulary
      is (Is_Valid (This.vocabulary) return This.vocabulary 
         else return Lexer.getVocabulary (This));

end ANTLR.Runtime.LexerInterpreter;
