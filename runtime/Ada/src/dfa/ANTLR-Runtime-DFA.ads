-- €

with Ada.Finalization;
with Ada.Containers.Vectors;
with ANTLR.Runtime.ATN.DFAState;
with ANTLR.Runtime.ATN.DecisionState;
with ANTLR.Runtime.Misc.Utils.Mutex;
with ANTLR.Runtime.Vocabularies;

use ANTLR.Runtime;
use ANTLR.Runtime.ATN;
use ANTLR.Runtime.ATN.DFAState;
use ANTLR.Runtime.ATN.DecisionState;
use ANTLR.Runtime.Misc;
use ANTLR.Runtime.Misc.Utils;

package ANTLR.Runtime.ATN.DFA is

   -- public
   type DFA is new Ada.Finalization.Controlled with
   record
      --
      -- A set of all DFA states.
      --
      -- public
      states : DFAState_List;

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
      statesMutex : Mutex.Synchronised;

   end record;

   subtype Object is DFA;
   type Class is access all Object;
   type Class_Wide is access all Object'Class;

   package DFA_Container is new Ada.Containers.Vectors (
      Index_Type => Natural,
      Item_Type => DFA,
      "=" => "=");
   subtype DFA_List is DFA_Container.Vector;

   -- public convenience
   procedure Initialize (Self : in out DFA; atnStartState : DecisionState);

   -- public
   procedure Initialize (Self : in out DFA; atnStartState : DecisionState; decision : Integer);

   --
   -- Gets whether this DFA is a precedence DFA. Precedence DFAs use a special
   -- start state _#s0_ which is not stored in _#states_. The
   -- _org.antlr.v4.runtime.DFA.States#edges_ array for this start state contains outgoing edges
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
   function getPrecedenceStartState (This : DFA; precedence : Integer) return Optional_DFAState;

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
   procedure setPrecedenceStartState (This : DFA; precedence : Integer; startState : DFAState);

   --
   -- Return a list of all states in this DFA, ordered by state number.
   --
   -- public
   function getStates (This : DFA) return DFAState_List;

   -- public
   subtype Sink is Ada.Strings.Text_Buffers.Root_Buffer_Type;
   procedure Put_Image_DFA (S : in out Sink'Class; X : DFA);
   for DFA'Put_Image use Put_Image_DFA;
   function Description (This : DFA) return UString
      is (toString (Vocabularies.EMPTY_VOCABULARY));

   -- public
   function toString (This : DFA; vocabulary : Vocabulary) return UString;

   -- public
   function toLexerString (This : DFA) return UString;

end ANTLR.Runtime.ATN.DFA;
