-- €

with Ada.Finalization;
with ANTLR.Runtime.ParseInfo;
with ANTLR.Runtime.VocabularySingle;
with ANTLR.Runtime.ATN;
with ANTLR.Runtime.ATN.ATNStates;
with ANTLR.Runtime.RecognizerProtocol;
with UString;

use ANTLR.Runtime.ParseInfo;
use ANTLR.Runtime.VocabularySingle;
use ANTLR.Runtime.ATN;
use ANTLR.Runtime.ATN.ATNStates;
use ANTLR.Runtime.RecognizerProtocol;
use UString;

generic
   type ATNInterpreter is ATNSimulator'Class;
package ANTLR.Runtime.Recognizers is

   --open
   type Recognizer is new Ada.Finalization.Controlled and RecognizerProtocol with
   record
      -- private
      _listeners : ANTLRErrorListener.Container.Vector := [ConsoleErrorListener.INSTANCE];

      -- public
      _interp : ATNInterpreter!;

      -- private
      _stateNumber : ATNStates.State := INVALID_STATE_NUMBER;

      -- public lazy
      tokenTypeMap : TokenID_Map;
   end record;

   subtype Object is Recognizer;
   type Class is access all Object;
   type Class_Wide is access all Object'Class;

   -- open
   function getRuleNames (This : Recognizer) return UString.Container.Vector;

   --
   -- Get the vocabulary used by the recognizer.
   --
   -- * Returns: A _org.antlr.v4.runtime.Vocabulary_ instance providing information about the
   -- vocabulary used by the grammar.
   --
   -- open
   function getVocabulary (This : Recognizer) return Vocabulary;

   --
   -- Get a map from token names to token types.
   --
   -- Used for XPath and tree pattern compilation.
   --
   -- public lazy
   function tokenTypeMap (This : Recognizer) return TokenID_Map;
   -- public
   function getTokenTypeMap (This : Recognizer) return TokenID_Map;

   --
   -- Get a map from rule names to rule indexes.
   --
   -- Used for XPath and tree pattern compilation.
   --
   -- public
   function getRuleIndexMap (This : Recognizer) return [String : Int]
      is (ruleIndexMap);

   -- public lazy
   function ruleIndexMap return TokenID_Map;

   -- public
   function getTokenType (This : Recognizer; tokenName : UString) return Integer
      is getTokenTypeMap ()[tokenName], Default => CommonToken.INVALID_TYPE;

   --
   -- If this recognizer was generated, it will have a serialized ATN
   -- representation of the grammar.
   --
   -- For interpreters, we don't know their serialized ATN despite having
   -- created the interpreter from it.
   --
   -- open
   function getSerializedATN (This : Recognizer) return Integer_List;

   -- For debugging and other purposes, might want the grammar name.
   -- Have ANTLR generate an implementation for this method.
   --
   -- open
   function getGrammarFileName (This : Recognizer) return UString;

   --
   -- Get the _org.antlr.v4.runtime.atn.ATN_ used by the recognizer for prediction.
   --
   -- * Returns: The _org.antlr.v4.runtime.atn.ATN_ used by the recognizer for prediction.
   --
   -- open
   function getATN (This : Recognizer) return ATN;

   --
   -- Get the ATN interpreter used by the recognizer for prediction.
   --
   -- * Returns: The ATN interpreter used by the recognizer for prediction.
   --
   -- open
   function getInterpreter (This : Recognizer) return ATNInterpreter
      is (This._interp);

   -- If profiling during the parse/lex, this will return DecisionInfo records
   -- for each decision in recognizer in a ParseInfo object.
   --
   -- open
   function getParseInfo (This : Recognizer) return Optional_ParseInfo
      is (Valid = False);

   --
   -- Set the ATN interpreter used by the recognizer for prediction.
   --
   -- * Parameter interpreter: The ATN interpreter used by the recognizer for
   -- prediction.
   --
   -- open
   procedure setInterpreter (This : Recognizer; interpreter : ATNInterpreter);

   --
   -- What is the error header, normally line/character position information?
   --
   -- open
   function getErrorHeader (This : Recognizer; e : RecognitionException) return UString;

   -- open
   procedure addErrorListener (This : Recognizer; listener : ANTLRErrorListener);

   -- open
   procedure removeErrorListener (This : Recognizer; listener : ANTLRErrorListener);

   -- open
   procedure removeErrorListeners (This : Recognizer);

   -- open
   function getErrorListeners (This : Recognizer) return ANTLRErrorListener.Container.Vector
      is (This._listeners);

   -- open
   function getErrorListenerDispatch (This : Recognizer) return ANTLRErrorListener
      is (ProxyErrorListener (getErrorListeners ()));

   -- subclass needs to override these if there are sempreds or actions
   -- that the ATN interp needs to execute
   -- open
   function sempred (This : Recognizer;
                     _localctx : Optional_RuleContext;
                     ruleIndex : Integer;
                     actionIndex : Integer)
                     return Boolean
      is (True);

   -- open
   function precpred (This : Recognizer;
                      localctx : Optional_RuleContext;
                      precedence : Integer)
                      return Boolean
      is (True);

   -- open
   procedure action (This : Recognizer;
                     _localctx : Optional_RuleContext;
                     ruleIndex : Integer;
                     actionIndex : Integer);

   -- public final
   function getState (This : Recognizer) return ATNStates.State
      is (This.stateNumber);

   -- Indicate that the recognizer has changed internal state that is
   -- consistent with the ATN state passed in.  This way we always know
   -- where we are in the ATN as the parser goes along. The rule
   -- context objects form a stack that lets us see the stack of
   -- invoking rules. Combine this and we have complete ATN
   -- configuration information.
   --
   -- public final
   procedure setState (This : Recognizer; atnState : ATStates.State);

   -- open
   function getInputStream (This : Recognizer) return Optional_IntStream;

   -- open
   procedure setInputStream (This : Recognizer; input : IntStream);

   -- open
   function getTokenFactory (This : Recognizer; This : Recognizer) return TokenFactory;

   -- open
   procedure setTokenFactory (This : Recognizer; input : TokenFactory);

end ANTLR.Runtime.Recognizers;
