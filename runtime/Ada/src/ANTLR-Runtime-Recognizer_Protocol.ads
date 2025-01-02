-- €

with UString;

package ANTLR.Runtime.RecognizerProtocol is

-- public
   type RecognizerProtocol is interface;

   --
   -- Get the _org.antlr.v4.runtime.atn.ATN_ used by the recognizer for prediction.
   --
   -- * Returns: The _org.antlr.v4.runtime.atn.ATN_ used by the recognizer for prediction.
   --
   function getATN (This : RecognizerProtocol) return ATN is abstract;

   -- For debugging and other purposes, might want the grammar name.
   -- Have ANTLR generate an implementation for this method.
   --
   -- open
   function getGrammarFileName (This : RecognizerProtocol) return UString is abstract;

   -- If profiling during the parse/lex, this will return DecisionInfo records
   -- for each decision in recognizer in a ParseInfo object.
   --
   -- open
   function getParseInfo (This : RecognizerProtocol) return Optional_ParseInfo is abstract;

   -- open
   function getRuleNames (This : RecognizerProtocol) return UString.Container.Vector is abstract;

   --
   -- If this recognizer was generated, it will have a serialized ATN
   -- representation of the grammar.
   --
   -- For interpreters, we don't know their serialized ATN despite having
   -- created the interpreter from it.
   --
   -- open
   function getSerializedATN (This : RecognizerProtocol) return Integer_List is abstract;

   -- public final
   function getState (This : RecognizerProtocol) return Integer is abstract;

   --
   -- Get a map from token names to token types.
   --
   -- Used for XPath and tree pattern compilation.
   --
   -- public
   function getTokenType (This : RecognizerProtocol; tokenName : UString) return Integer is abstract;

   --
   -- Get the vocabulary used by the recognizer.
   --
   -- * Returns: A _org.antlr.v4.runtime.Vocabulary_ instance providing information about the
   -- vocabulary used by the grammar.
   --
   -- open
   function getVocabulary (This : RecognizerProtocol) return Vocabulary is abstract;

end ANTLR.Runtime.RecognizerProtocol;
