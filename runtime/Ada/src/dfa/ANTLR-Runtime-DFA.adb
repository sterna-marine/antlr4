-- €

with Ada.Finalization;
with Ada.Containers.Vectors;
with ANTLR.Runtime.ATN.DFAState;
with ANTLR.Runtime.ATN.DecisionState;
with ANTLR.Runtime.Misc.Utils.Mutex;
with ANTLR.Runtime.VocabularySingle;

use ANTLR.Runtime;
use ANTLR.Runtime.ATN;
use ANTLR.Runtime.ATN.DFAState;
use ANTLR.Runtime.ATN.DecisionState;
use ANTLR.Runtime.Misc;
use ANTLR.Runtime.Misc.Utils;

package body ANTLR.Runtime.ATN.DFA is

   -- public
   type DFA is new Ada.Finalization.Controlled with
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
      --
      -- public
      atnStartState : DecisionState; -- constant

      --
      -- `True` if this DFA is for a precedence decision; otherwise,
      -- `False`. This is the backing field for _#isPrecedenceDfa_.
      --
      -- private
      precedenceDfa : Boolean; -- constant

      --
      -- mutex for states changes.
      --
      -- internal private (set);
      statesMutex : Mutex.Synchronized;

   end record;

   subtype Object is DFA;
   type Class is access all Object;
   type Class_Wide is access all Object'Class;

   package body Container is new Ada.Containers.Vectors;

   -- public convenience
   procedure Initialize (Self : in out DFA; atnStartState : DecisionState) is
   begin
      self.init (atnStartState, 0);
   end Initialize;

   -- public
   procedure Initialize (Self : in out DFA; atnStartState : DecisionState; decision : Integer) is
   begin
      self.atnStartState := atnStartState;
      self.decision := decision;

      starLoopState : constant Optional_StarLoopEntryState;
      if Is_Valid (starLoopState) then
         declare
            precedenceState : DFAState := DFAState (ATNConfigSet ()); -- constant
         begin
            starLoopState.precedenceRuleDecision := Maybe (Self.atnStartState);
            precedenceState.edges := DFAState.Container.Empty_Vector;
            precedenceState.isAcceptState := False;
            precedenceState.requiresFullContext := False;
            Self.precedenceDfa := True;
            Self.s0 := precedenceState;
         end;
      else
         Self.precedenceDfa := False;
         Self.s0 := (Valid => False);
      end if;
   end Initialize;

   --
   -- Gets whether this DFA is a precedence DFA. Precedence DFAs use a special
   -- start state _#s0_ which is not stored in _#states_. The
   -- _org.antlr.v4.runtime.dfa.DFAState#edges_ array for this start state contains outgoing edges
   -- supplying individual start states corresponding to specific precedence
   -- values.
   --
   -- * returns: `True` if this is a precedence DFA; otherwise,
   -- `False`.
   -- * seealso: org.antlr.v4.runtime.Parser#getPrecedence ();
   --
   -- public final
   function isPrecedenceDfa (This : DFA) return Boolean
      is (This.precedenceDfa);

   --
   -- Get the start state for a specific precedence value.
   --
   -- * parameter precedence: The current precedence.
   -- * returns: The start state corresponding to the specified precedence, or
   -- `null` if no start state exists for the specified precedence.
   --
   -- * throws: _ANTLRError.illegalState_ if this is not a precedence DFA.
   -- * seealso: #isPrecedenceDfa ();
   --
   -- public final
   function getPrecedenceStartState (This : DFA; precedence : Integer) return Optional_DFAState is
   begin
      if not isPrecedenceDfa () then
         raise ANTLRError.illegalState with "Only precedence DFAs may contain a precedence start state.";
      end if;

      if not Is_Valid (This.s0)
         or not Is_Valid (This.s0.edges)
         or not precedence >= 0
         or not precedence < edges.count then
         return Optional_DFAState (Valid => False);
      else
         return Element (edges, precedence);
      end if;
   end getPrecedenceStartState;

   --
   -- Set the start state for a specific precedence value.
   --
   -- * parameter precedence: The current precedence.
   -- * parameter startState: The start state corresponding to the specified
   -- precedence.
   --
   -- * throws: _ANTLRError.illegalState_ if this is not a precedence DFA.
   -- * seealso: #isPrecedenceDfa ();
   --
   -- public final
   procedure setPrecedenceStartState (This : DFA; precedence : Integer; startState : DFAState) is

      function Closure return … is
      begin
         -- s0.edges is never null for a precedence DFA
         if precedence >= edges.count then
            increase : constant := [DFAState?](repeating => null, count: (precedence + 1 - edges.count));
            s0.edges := edges + increase;
         else
            DFAState.Container.Insert (Key => s0.edges, precedence, New_Item => startState);
         end if;
      end Closure;
      Closure_Return_Value : …;
      function Synchronized_Closure is new Mutex.Gen_Closure (Closure => Closure, Result_Type => …);

   begin
      if not isPrecedenceDfa () then
         raise ANTLRError.illegalState with "Only precedence DFAs may contain a precedence start state.";
      end if;

      if not Is_Valid (s0)
         or not Is_Valid (s0.edges)
         or not precedence >= 0 then
         exit;
      else
         -- synchronization on s0 here is ok. when the DFA is turned into a
         -- precedence DFA, s0 will be initialized once and not updated again
         s0.Mutex.Run (Synchronized_Closure'Access, Closure_Return_Value);
         --TOFIX return Closure_Return_Value;
      end if;

   end setPrecedenceStartState;

   --
   -- Return a list of all states in this DFA, ordered by state number.
   --
   -- public
   function getStates (This : DFA) return DFAState.Container.Vector is
      result : DFAState.Container.Vector := [DFAState](states.keys);

      function "<" (Left, Right : DFAState) return Boolean
         is (Left.stateNumber < Right.stateNumber);

       package body DFAState_Sorting is new DFAState.Container.Generic_Sorting ("<");

   begin
      DFAState_Sorting.Sort (result);
      return result;
   end getStates;

   -- public
   subtype Sink is Ada.Strings.Text_Buffers.Root_Buffer_Type;
   procedure Put_Image_DFA (S : in out Sink'Class; X : DFA);
   for DFA'Put_Image use Put_Image_DFA;
   function Description (This : DFA) return UString
      is toString (VocabularySingle.EMPTY_VOCABULARY);

   -- public
   function toString (This : DFA, vocabulary : Vocabulary) return UString is
   begin
      if not Is_Valid (This.s0) then
         return "";
      else
         declare
            serializer : constant := DFASerializer (This, vocabulary);
         begin
            return serializer'Image;
         end;
      end if;
   end toString;

   -- public
   function toLexerString (This : DFA) return UString is
   begin
      if not Is_Valid (This.s0) then
         return "";
      else
         declare
            serializer : constant := LexerDFASerializer (This);
         begin
            return serializer'Image;
         end
      end if;
   end toLexerString;

end ANTLR.Runtime.ATN.DFA;
