-- €

with Ada.Finalization;
with ANTLR.Runtime.ATN.ParseInfos;
with ANTLR.Runtime.ATN.Simulators;
with ANTLR.Runtime.Vocabularies;
with ANTLR.Runtime.ATN;
with ANTLR.Runtime.ATN.States;
with ANTLR.Runtime.Recognizer_Protocol;
with UString;

use ANTLR.Runtime.ATN.ParseInfos;
use ANTLR.Runtime.ATN.Simulators;
use ANTLR.Runtime.Vocabularies;
use ANTLR.Runtime.ATN;
use ANTLR.Runtime.ATN.States;
use ANTLR.Runtime.Recognizer_Protocol;
use UString;

-- open class Recognizer<ATNInterpreter: ATNSimulator>: RecognizerProtocol {

-- `ATNSimulator` subclasses are:
-- * `LexerATNSimulator`
-- * `ParserATNSimulator`

-- `Recognizer` subclasses are:
-- * `Lexer: Recognizer<LexerATNSimulator>`
-- * `Parser: Recognizer<ParserATNSimulator>`

-- generic `Recognizer<T>` is used by:
-- * in SemanticContext : 
--`func syntaxError` in `ANTLRErrorListener`, `BaseErrorListener`, `ConsoleErrorListener`, `ProxyErrorListener`


-- * `func toString` in  classes : `CommonToken`. RuleContext, ATNConfig, PredictionContext
-- * `func toStrings` in  classes : PredictionContext

-- generic `func eval<T>` / `evalPrecedence<T>` is used by
-- * SemanticContext
-- * PrecedencePredicate
-- * Predicate
-- * AND
-- * OR

-- generic func syntaxError<T>
-- * VisitorTests


   --  type Recognizer is new Ada.Finalization.Controlled and RecognizerProtocol with
   --     with Type_Invariant'Class => Recognizer'Class'Tag = ATNSimulator'Tag;

   --  type ATNInterpreter is private

generic
   type ATNSimulator is private;
package ANTLR.Runtime.Recognizers is

   subtype ATNInterpreter is new ATNSimulator with null record;
   --open
   type Recognizer is new Ada.Finalization.Controlled and RecognizerProtocol with
   record
      -- private
      listeners : ANTLRErrorListener_List := [ConsoleErrorListener.INSTANCE];

      -- public
      interp : ATNSimulator'Class; -- !

      -- private
      stateNumber : ATNStates.State := INVALID_STATE_NUMBER;

      -- public lazy
      tokenTypeMap : TokenID_Map;

      -- public lazy
      ruleIndexMap : Rules_Map;
   end record;

   subtype Object is Recognizer;
   type Class is access all Object;
   type Class_Wide is access all Object'Class;

   -- open
   function getRuleNames (This : Recognizer) return UString_List;

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
   -- public lazy var
   function tokenTypeMap (This : Recognizer) return TokenID_Map;
   -- public
   function getTokenTypeMap (This : Recognizer) return TokenID_Map;


   function Hash (Key : UString) return Ada.Containers.Hash_Type;

   function Equivalent_Keys (Left, Right : UString) return Boolean
      is (Hash (Left) = Hash (Right)); --TOFIX

   package Rules_Dictionary is new Ada.Containers.Hashed_Maps (
      Key_Type => UString,
      Element_Type => Integer,
      Hash => Hash,
      Equivalent_Keys => Equivalent_Keys,
      "=" => "=");
   subtype Rules_Map is Rules_Dictionary.Map;

   --
   -- Get a map from rule names to rule indexes.
   --
   -- Used for XPath and tree pattern compilation.
   --
   -- public
   function getRuleIndexMap (This : Recognizer) return Rules_Map
      is (ruleIndexMap);

   -- public lazy
   function ruleIndexMap (This : Recognizer) return Rules_Map;

   -- public
   function getTokenType (This : Recognizer; tokenName : UString) return Integer
      is (Value (This.getTokenTypeMap.Element (tokenName), Default => CommonToken.INVALID_TYPE));

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
      is (This.interp);

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
   function getErrorListeners (This : Recognizer) return ANTLRErrorListener_List
      is (This.listeners);

   -- open
   function getErrorListenerDispatch (This : Recognizer) return ANTLRErrorListener
      is (ProxyErrorListener (This.getErrorListeners));

   -- subclass needs to override these if there are sempreds or actions
   -- that the ATN interp needs to execute
   -- open
   function sempred (This : Recognizer;
                     localctx : Optional_RuleContext;
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
                     localctx : Optional_RuleContext;
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
