-- €

with ANTLR.Runtime.ATN.ATNSimulator;
with ANTLR.Runtime.DFA.DFAState;
with ANTLR.Runtime.Lexer;

use ANTLR.Runtime;
use ANTLR.Runtime.ATN;
use ANTLR.Runtime.ATN.ATNSimulator;
use ANTLR.Runtime.DFA.DFAState;

package ANTLR.Runtime.ATN.LexerATNSimulator is

   --
   -- "dup" of ParserInterpreter
   --

   --
   -- When we hit an accept state in either the DFA or the ATN, we
   -- have to notify the character stream to start buffering characters
   -- via _org.antlr.v4.runtime.IntStream#mark_ and record the current state. The current sim state
   -- includes the current index into the input, the current line,
   -- and current character position in that line. Note that the Lexer is
   -- tracking the starting line and characterization of the token. These
   -- variables track the "state" of the simulator when it hits an accept state.
   --
   -- We track these variables separately for the DFA and ATN simulation
   -- because the DFA simulation often has to fail over to the ATN
   -- simulation. If the ATN simulation fails, we need the DFA to fall
   -- back to its previously accepted state, if any. If the ATN succeeds,
   -- then the ATN does the accept and the DFA simulator that invoked it
   -- can simply return the predicted token type.
   --
   -- internal
   type SimState is private;

   -- public static
   debug :  constant Boolean := False;

   -- public static
   MIN_DFA_EDGE : constant Integer := 0;
   MAX_DFA_EDGE : constant Integer := 127;  -- forces unicode to stay in ATN

   -- open
   type LexerATNSimulator is new ATNSimulator with
   record

      -- public
      dfa_debug : constant Boolean := False;

      -- internal weak
      recog : Optional_Lexer;

      --
      -- The current token's starting index into the character stream.
      -- Shared across DFA to ATN simulation in case the ATN fails and the
      -- DFA did not have a previous accept state. In this case, we use the
      -- ATN-generated exception object.
      --
      -- internal
      startIndex : Integer := -1;

      --
      -- line number 1 .. n within the input
      --
      -- public
      line : Integer := 1;

      --
      -- The index of the character relative to the beginning of the line 0 .. n-1
      --
      -- public
      charPositionInLine : Integer := 0;

      -- public private (set) final var
      decisionToDFA : DFA.Container.Vector;

      -- internal
      mode : Lexer_Mode := Lexer.DEFAULT_MODE;

      --
      -- Used during DFA/ATN exec to record the most recent accept configuration info
      --

      -- internal final
      prevAccept : SimState;

   end record;


   -- public convenience
   procedure Initialize (Self : in out LexerATNSimulator;
                   atn : ATN;
                   decisionToDFA : DFA.Container.Vector;
                   sharedContextCache : PredictionContextCache);

   -- public
   procedure Initialize (Self : in out LexerATNSimulator;
                   recog : Optional_Lexer;
                   atn : ATN;
                   decisionToDFA : DFA.Container.Vector;
                   sharedContextCache : PredictionContextCache);

   -- open
   procedure copyState (This : LexerATNSimulator; simulator : LexerATNSimulator);

   -- open
   function match (This : LexerATNSimulator; input : CharStream; mode : Lexer_Mode) return Integer;

   overriding
   -- open
   procedure reset (This : LexerATNSimulator);

   overriding
   -- open
   procedure clearDFA (This : LexerATNSimulator);

   -- internal
   function matchATN (This : LexerATNSimulator; input : CharStream) return Integer;

   -- internal
   function execATN (This : LexerATNSimulator; input : CharStream; ds0 : DFAState) return Integer;

   --
   -- Get an existing target state for an edge in the DFA. If the target state
   -- for the edge has not yet been computed or is otherwise not available,
   -- this method returns `null`.
   --
   -- * parameter s: The current DFA state
   -- * parameter t: The next input symbol
   -- * returns: The existing target DFA state for the given input symbol
   -- `t`, or `null` if the target state for this edge is not
   -- already cached
   --
   -- internal
   function getExistingTargetState (This : LexerATNSimulator;
                                    s : DFAState;
                                    t : Integer)
                                    return Optional_DFAState;


   -- final
   function computeStartState (This : LexerATNSimulator;
                               input : CharStream;
                               p : ATNState)
                               return ATNConfigSet;

   --
   -- Since the alternatives within any lexer decision are ordered by
   -- preference, this method stops pursuing the closure as soon as an accept
   -- state is reached. After the first accept state is reached by depth-first
   -- search from `config`, all other (potentially reachable) states for
   -- this rule would have a lower priority.
   --
   -- * returns: `True` if an accept state is reached, otherwise
   -- `False`.
   --
   -- @discardableResult
   -- final
   function closure (This : LexerATNSimulator;
                     input : CharStream;
                     config : LexerATNConfig;
                     configs : ATNConfigSet;
                     currentAltReachedAcceptState : Boolean;
                     speculative : Boolean;
                     treatEofAsEpsilon : Boolean)
                     return Boolean;

   -- side-effect: can alter configs.hasSemanticContext

   -- final
   function getEpsilonTarget (This : LexerATNSimulator;
                              input : CharStream;
                              config : LexerATNConfig;
                              t : ATNTransition;
                              configs : ATNConfigSet;
                              speculative : Boolean;
                              treatEofAsEpsilon  : Boolean)
                              return Optional_LexerATNConfig;

   --
   -- Evaluate a predicate specified in the lexer.
   --
   -- If `speculative` is `True`, this method was called before
   -- _#consume_ for the matched character. This method should call
   -- _#consume_ before evaluating the predicate to ensure position
   -- sensitive values, including _org.antlr.v4.runtime.Lexer#getText_, _org.antlr.v4.runtime.Lexer#getLine_,
   -- and _org.antlr.v4.runtime.Lexer#getCharPositionInLine_, properly reflect the current
   -- lexer state. This method should restore `input` and the simulator
   -- to the original state before returning (i.e. undo the actions made by the
   -- call to _#consume_.
   --
   -- * parameter input: The input stream.
   -- * parameter ruleIndex: The rule containing the predicate.
   -- * parameter predIndex: The index of the predicate within the rule.
   -- * parameter speculative: `True` if the current index in `input` is
   -- one character before the predicate's location.
   --
   -- * returns: `True` if the specified predicate evaluates to
   -- `True`.
   --
   -- final
   function evaluatePredicate (This : LexerATNSimulator;
                               input : CharStream;
                               ruleIndex : Integer;
                               predIndex : Integer;
                               speculative  : Boolean)
                               return Boolean;

   -- private final
   function addDFAEdge (This : LexerATNSimulator;
                        from : DFAState;
                        t : Integer;
                        q : ATNConfigSet)
                        return DFAState;

   -- private final
   procedure addDFAEdge (This : LexerATNSimulator; p : DFAState; t : Integer; q : DFAState);

   --
   -- Add a new DFA state if there isn't one with this set of
   -- configurations already. This method also detects the first
   -- configuration containing an ATN rule stop state. Later, when
   -- traversing the DFA, we will know which rule to accept.
   --
   -- final
   function addDFAState (This : LexerATNSimulator; configs : ATNConfigSet) return DFAState;

   -- public final
   function getDFA (This : LexerATNSimulator; mode : Lexer_Mode) return DFA
      is (decisionToDFA.Element (mode));

   --
   -- Get the text matched so far for the current token.
   --

   -- public
   function getText (This : LexerATNSimulator; input : CharStream) return UString;

   -- public
   function getLine (This : LexerATNSimulator) return Integer
      is (This.line);

   -- public
   procedure setLine (This : LexerATNSimulator; line : Integer);

   -- public
   function getCharPositionInLine (This : LexerATNSimulator) return Integer
      is (This.charPositionInLine);

   -- public
   procedure setCharPositionInLine (This : LexerATNSimulator; charPositionInLine : Integer);

   -- public
   procedure consume (This : LexerATNSimulator; input : CharStream);

   -- public
   function getTokenName (This : LexerATNSimulator; t : Integer) return UString;

private
   type SimState is record
      -- internal
      index : Integer := -1;
      -- internal
      line : Integer := 0;
      -- internal
      charPos : Integer := -1;
      -- internal
      dfaState : Optional_DFAState;
   end record;

end ANTLR.Runtime.ATN.LexerATNSimulator;
