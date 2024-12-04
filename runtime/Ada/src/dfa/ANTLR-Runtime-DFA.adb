-- €

with Ada.Containers.Vector;
with ANTLR.Runtime.ATN.DFAState;
with ANTLR.Runtime.ATN.DecisionState;
with ANTLR.Runtime.Misc.Utils.Mutex;

use ANTLR.Runtime.ATN;
use ANTLR.Runtime.ATN.DFAState;
use ANTLR.Runtime.ATN.DecisionState;
use with ANTLR.Runtime.Misc;
use ANTLR.Runtime.Misc.Utils;

package body ANTLR.Runtime.ATN.DFA is 

   -- public
   type DFA is tagged with
   record
      -- 
      -- A set of all DFA states.
      -- 
      -- public
      states : DFAState.Container.Vector;

      -- public
      s0 : DFAState.Option_DFAState.Optional;

      -- public
      decision : Integer; -- constant

      -- 
      -- From which ATN state did we create this DFA?
      -- --------------------------------------------
      -- public 
      atnStartState : DecisionState; -- constant

      -- 
      -- `True` if this DFA is for a precedence decision; otherwise,
      -- `False`. This is the backing field for _#isPrecedenceDfa_.
      -- 
      -- private
      precedenceDfa : Boolean; -- constant
      
      -- --------------------------------------------
      -- mutex for states changes.
      -- --------------------------------------------
      -- internal private (set);
      statesMutex : Mutex.Synchronized;

   end record;

   package Container is new Ada.Containers.Vector;

   -- public convenience
   procedure Init (Self : in out DFA; atnStartState : DecisionState) is
   begin
      self.init (atnStartState, 0);
   end Init;

   -- public 
   procedure Init (Self : in out DFA; atnStartState : DecisionState; decision : Integer) is
   begin
      self.atnStartState := atnStartState;
      self.decision := decision;

      starLoopState : constant Optional_StarLoopEntryState;
      if Is_Valid (starLoopState) then
         declare
            precedenceState : DFAState := DFAState (ATNConfigSet ()); -- constant
         begin
            starLoopState.precedenceRuleDecision := Set (Self.atnStartState);
            precedenceState.edges := DFAState.Container.Empty_Vector;
            precedenceState.isAcceptState := False;
            precedenceState.requiresFullContext := False;
            Self.precedenceDfa := True;
            Self.s0 := precedenceState;
         end;
      else
         Self.precedenceDfa := False;
         Self.s0 := null;
      end if;
   end Init;

   -- 
   -- Gets whether this DFA is a precedence DFA. Precedence DFAs use a special
   -- start state _#s0_ which is not stored in _#states_. The
   -- _org.antlr.v4.runtime.dfa.DFAState#edges_ array for this start state contains outgoing edges
   -- supplying individual start states corresponding to specific precedence
   -- values.
   -- 
   -- - returns: `True` if this is a precedence DFA; otherwise,
   -- `False`.
   -- - seealso: org.antlr.v4.runtime.Parser#getPrecedence ();
   -- 
   -- public final
   function isPrecedenceDfa (This : DFA) return Boolean
      is (This.precedenceDfa);

   -- 
   -- Get the start state for a specific precedence value.
   -- 
   -- - parameter precedence: The current precedence.
   -- - returns: The start state corresponding to the specified precedence, or
   -- `null` if no start state exists for the specified precedence.
   -- 
   -- - throws: _ANTLRError.illegalState_ if this is not a precedence DFA.
   -- - seealso: #isPrecedenceDfa ();
   -- 
   -- public final
   function getPrecedenceStartState (This : DFA; precedence : Integer) return Optional_DFAState is
   begin
      if not isPrecedenceDfa () then
         raise ANTLRError.illegalState with "Only precedence DFAs may contain a precedence start state."; 
      end if;

      if not Is_Valid (This.s0) or not Is_Valid (This.s0.edges) or not precedence >= 0 or not precedence < edges.count then
         return Optional_DFAState (Valid => False);
      end if;

      return Element (edges, precedence);
   end getPrecedenceStartState;

   -- 
   -- Set the start state for a specific precedence value.
   -- 
   -- - parameter precedence: The current precedence.
   -- - parameter startState: The start state corresponding to the specified
   -- precedence.
   -- 
   -- - throws: _ANTLRError.illegalState_ if this is not a precedence DFA.
   -- - seealso: #isPrecedenceDfa ();
   -- 
   -- public final
   procedure setPrecedenceStartState (This : DFA; precedence : Integer; startState : DFAState) is

      function Closure return … is
      begin
         -- s0.edges is never null for a precedence DFA
         if precedence >= edges.count then
            increase : constant := [DFAState?](repeating: null, count: (precedence + 1 - edges.count));
            s0.edges := edges + increase
         else
            DFAState.Container.Element (s0.edges, precedence) := startState
         end if;
      end Closure;
      Closure_Return_Value : …;
      function Synchronized_Closure is new Mutex.Gen_Closure (Closure => Closure, Result_Type => …);

   begin
      if not isPrecedenceDfa () then
         raise ANTLRError.illegalState with "Only precedence DFAs may contain a precedence start state.";
      end if;

      if not Is_Valid (s0) or not Is_Valid (s0.edges) or not precedence >= 0 then
         return null;
      end if;

      -- synchronization on s0 here is ok. when the DFA is turned into a
      -- precedence DFA, s0 will be initialized once and not updated again
      s0.Mutex.Run (Synchronized_Closure'Access, Closure_Return_Value);
      --TOFIX return Closure_Return_Value;

   end setPrecedenceStartState;

   -- --------------------------------------------
   -- Return a list of all states in this DFA, ordered by state number.
   -- 
   -- public
   function getStates (This : DFA) return [DFAState]
      is [DFAState](states.keys);

   -- closure
   function "<" (This : DFA; Lhs, Rhs : ) return True is
   begin
      (lhs < rhs);
      result := result.sorted {$0.stateNumber < $1.stateNumber};
      return result
   end "<";

   -- public
   function Image (This : DFA) return UString
      is toString (Vocabulary.EMPTY_VOCABULARY);

   -- public
   function toString (This : DFA, vocabulary : Vocabulary) return String is
   begin
      if s0 = null then
         return "";
   end toString;

   serializer : constant := DFASerializer (self, vocabulary);
      return serializer.description
   end if;

   -- public
   function toLexerString (This : DFA) return UString is
   begin
      if s0 = null then
         return "";
      end if;
      serializer : constant := LexerDFASerializer (self);
      return serializer.description
   end toLexerString;

end ANTLR.Runtime.ATN.DFA;
