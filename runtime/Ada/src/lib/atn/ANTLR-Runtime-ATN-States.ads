-- €

with Ada.Containers;
with Ada.Containers.Vectors;
with Ada.Containers.Hashed_Sets;
with Ada.Strings;
with ANTLR.Runtime.ATN.States;
with ANTLR.Runtime.ATN.Transitions;
with ANTLR.Runtime.Misc.IntervalSets;
with AdaForge.Utils.Optionals;
use AdaForge.Utils;

use ANTLR.Runtime.ATN;
use ANTLR.Runtime.ATN.Transitions;
use ANTLR.Runtime.Misc.IntervalSets;

package ANTLR.Runtime.ATN.States is

   --
   --
   -- The following images show the relation of states and
   -- _org.antlr.v4.runtime.atn.ATNState#transitions_ for various grammar constructs.
   --
   --
   -- * Solid edges marked with an &#0949; indicate a required
   -- _org.antlr.v4.runtime.atn.EpsilonTransition_.
   --
   -- * Dashed edges indicate locations where any transition derived from
   -- _org.antlr.v4.runtime.atn.Transition_ might appear.
   --
   -- * Dashed nodes are place holders for either a sequence of linked
   -- _org.antlr.v4.runtime.atn.BasicState_ states or the inclusion of a block representing a nested
   -- construct in one of the forms below.
   --
   -- * Nodes showing multiple outgoing alternatives with a ` ... ` support
   -- any number of alternatives (one or more). Nodes without the ` ... ` only
   -- support the exact number of alternatives shown in the diagram.
   --
   --
   -- ## Basic Blocks
   --
   -- ### Rule
   --
   --
   --
   -- ## Block of 1 or more alternatives
   --
   --
   --
   -- ## Greedy Loops
   --
   -- ### Greedy Closure: `( ATNState )*`
   --
   --
   --
   -- ### Greedy Positive Closure: `( ATNState )+`
   --
   --
   --
   -- ### Greedy Optional: `( ATNState )?`
   --
   --
   --
   -- ## Non-Greedy Loops
   --
   -- ### Non-Greedy Closure: `( ATNState )*?`
   --
   --
   --
   -- ### Non-Greedy Positive Closure: `( ATNState )+?`
   --
   --
   --
   -- ### Non-Greedy Optional: `( ATNState )??`
   --
   --
   --
   --

   type State is (
      INVALID_STATE_NUMBER,
      INVALID,
      BASIC,
      RULE_START,
      BLOCK_START,
      PLUS_BLOCK_START,
      STAR_BLOCK_START,
      TOKEN_START,
      RULE_STOP,
      BLOCK_END,
      STAR_LOOP_BACK,
      STAR_LOOP_ENTRY,
      PLUS_LOOP_BACK,
      LOOP_END,
      EMPTY_RETURN_STATE);
   for State use (
      INVALID_STATE_NUMBER => -1,
      INVALID => 0,
      BASIC => 1,
      RULE_START => 2,
      BLOCK_START => 3,
      PLUS_BLOCK_START => 4,
      STAR_BLOCK_START => 5,
      TOKEN_START => 6,
      RULE_STOP => 7,
      BLOCK_END => 8,
      STAR_LOOP_BACK => 9,
      STAR_LOOP_ENTRY => 10,
      PLUS_LOOP_BACK => 11,
      LOOP_END => 12,
      EMPTY_RETURN_STATE => Integer'Last);
   for State'size use Integer'Size;

   package State_Container is new Ada.Containers.Vectors (
      Index_Type => Natural,
      Element_Type => State,
      "=" => "=");
   subtype State_List is State_Container.Vector;

   -- Optionals
   package Option_State is new AdaForge.Util.Optionals (State);
   subtype Optional_State is Option_State.Optional; -- renames

   -- public
   type ATNState is new Ada.Finalization.Controlled -- and Hashable
   with record
      -- Which ATN are we in?
      --
      -- public final
      atn : Optional_ATN;

      -- public internal (set) final var
      StateNumber : State := INVALID_STATE_NUMBER;

      -- public internal (set) final var
      ruleIndex: Optional_Integer;
      -- at runtime, we don't have Rule objects

      -- public private (set) final var
      epsilonOnlyTransitions : Boolean := False;

      --
      -- Track the transitions emanating from this ATN state.
      --
      -- internal private (set) final
      transitions : Transitions_List := Transitions.Container.Empty_Vector;

      --
      -- Used to cache lookahead during parsing, not used during construction
      --
      -- public internal (set) final var
      nextTokenWithinRule: Option_IntervalSet.Optional;
   end record;

   subtype Object is ATNState;
   type Class is access all Object;
   type Class_Wide is access all Object'Class;

   function "=" (Left, Right : ATNState) return Boolean;
   package ATNState_Container is new Ada.Containers.Vectors (
      Index_Type => Natural,
      Element_Type => ATNState,
      "=" => "=");
   subtype ATNState_List is ATNState_Container.Vector;

   -- Optionals
   package Option_ATNState is new AdaForge.Util.Optionals (ATNState);
   subtype Optional_ATNState is Option_ATNState.Optional; -- renames

   package Optional_ATNState_Container is new Ada.Containers.Vectors (
      Index_Type => Natural,
      Element_Type => Optional_ATNState,
      "=" => "=");
   subtype Optional_ATNState_List is Optional_ATNState_Container.Vector;

   function Hash (Element : ATNState) return Ada.Containers.Hash_Type;
   function Equivalent_Elements (Left, Right : ATNState) return Boolean;
   -- public
   package Set_Container is new Ada.Containers.Hashed_Sets (
      Element_Type => ATNState,
      Hash => Hash,
      Equivalent_Elements => Equivalent_Elements,
      "=" => "=");
   subtype Set_of_ATNStates is Set_Container.Set;

   -- public
   procedure hash (This : ATNState; Some_Hasher : in out Hasher);

   -- public
   function isNonGreedyExitState (This : ATNState) return Boolean
      is (False);

   subtype Sink is Ada.Strings.Text_Buffers.Root_Buffer_Type;
   procedure Put_Image_ATNState (S : in out Sink'Class; X : ATNState);
   for ATNState'Put_Image use Put_Image_ATNState;
   -- public
   function Description (This : ATNState) return UString;
      --return "MyClass " & string'Image & ""
      is (stateNumber'Image);

   -- public final
   function getTransitions (This : ATNState) return Transitions_List
      is (This.transitions);

   -- public final
   function getNumberOfTransitions (This : ATNState) return Ada.Containers.Count_Type
      is (This.Transitions.Length);

   -- public final
   procedure addTransition (This : ATNState; e : ATNTransition'Class);

   function transition (This : ATNState; i : Transitions.Container_Index) return Transition
      is (Transitions.Container.Element (Container => This.transitions, Index => i));

   -- public final
   procedure setTransition (This : ATNState; i : Transitions.Container_Index; e : ATNTransition);

   -- public final
   function removeTransition (This : ATNState; Index : Transitions.Container_Index) return Transition;

    -- public
   function getStateType (This : ATNState) return Integer;

    -- public final
   function onlyHasEpsilonTransitions (This : ATNState) return Boolean
      is (This.epsilonOnlyTransitions);

    -- public final
    procedure setRuleIndex (This : ATNState; ruleIndex : Integer);

   -- public
   function "=" (Lhs, Rhs : ATNState) return Boolean;

end ANTLR.Runtime.ATN.States;