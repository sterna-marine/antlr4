-- €

with Ada.Containers.Vectors;
with Ada.Finalization;
with Ada.Strings;
with ANTLR.Runtime.ATN.ConfigSets;
with ANTLR.Runtime.ATN.States;
with ANTLR.Runtime.ATN.SemanticContext;
with ANTLR.Runtime.ATN.LexerAction;

use ANTLR.Runtime.ATN.ConfigSets;
use ANTLR.Runtime.ATN.States;
use ANTLR.Runtime.ATN.SemanticContext;
use ANTLR.Runtime.ATN.LexerAction;

package ANTLR.Runtime.DFA.States is

   --
   -- A DFA state represents a set of possible ATN configurations.
   -- As Aho, Sethi, Ullman p. 117 says "The DFA uses its state
   -- to keep track of all possible states the ATN can be in after
   -- reading each input symbol.  That is to say, after reading
   -- input a1a2 .. an, the DFA is in a state that represents the
   -- subset T of the states of the ATN that are reachable from the
   -- ATN's start state along some path labeled a1a2 .. an."
   -- In conventional NFA>DFA conversion, therefore, the subset T
   -- would be a bitset representing the set of states the
   -- ATN could be in.  We need to track the alt predicted by each
   -- state as well, however.  More importantly, we need to maintain
   -- a stack of states, tracking the closure operations as they
   -- jump from rule to rule, emulating rule invocations (method calls).
   -- I have to add a stack to simulate the proper lookahead sequences for
   -- the underlying LL grammar from which the ATN was derived.
   --
   -- I use a set of ATNConfig objects not simple states.  An ATNConfig
   -- is both a state (ala normal conversion) and a RuleContext describing
   -- the chain of rules (if any) followed to arrive at that state.
   --
   -- A DFA state may have multiple references to a particular state,
   -- but with different ATN contexts (with same or different alts);
   -- meaning that state was reached via a different set of rule invocations.
   --

   -- public final
   type PredPrediction is new Ada.Finalization.Controlled with
   record
      -- public
      pred : SemanticContext; -- constant -- never null; at least SemanticContext.Empty.Instance

      -- public
      alt : Integer; -- constant
   end record;

   function "=" (Left, Right : PredPrediction) return Boolean;

   package PredPrediction_Container is new Ada.Containers.Vectors (
      Index_Type => Natural,
      Item_Type  => PredPrediction,
      "=" => "=");
   subtype PredPrediction_List is PredPrediction_Container.Vector;

   subtype Sink is Ada.Strings.Text_Buffers.Root_Buffer_Type;
   procedure Put_Image_PredPrediction (S : in out Sink'Class; X : PredPrediction);
   for PredPrediction'Put_Image use Put_Image_PredPrediction;
   -- public
   function Description (This : PredPrediction) return UString
      is ('(' & This.pred'Image & ',' & This.alt'Image & ')');

   -- public
   procedure Initialize (Self : in out PredPrediction; pred : SemanticContext; alt : Integer);

   -- public final
   type DFAState is new Ada.Finalization.Controlled -- and Hashable
   with
   record
      -- public internal (set);
      stateNumber : State := INVALID_STATE_NUMBER;

      -- public internal (set)
      configs : ATNConfigSet;

      --
      -- `DFAStati.Container.Element (Edges, symbol)` points to target of symbol. Shift up by 1 so (-1);
      -- _org.antlr.v4.runtime.Token#EOF_ maps to `DFAStati.Container.Element (Edges, 0)`.
      --
      -- public internal (set)
      edges : DFAState_List;

      -- public internal (set)
      isAcceptState : Boolean := False;

      --
      -- if accept state, what ttype do we match or alt do we predict?
      -- This is set to _org.antlr.v4.runtime.atn.ATN#INVALID_ALT_NUMBER_ when _#predicates_`!=null` or
      -- _#requiresFullContext_.
      --
      -- public internal (set)
      prediction : Integer := INVALID_ALT_NUMBER;

      -- public internal (set)
      lexerActionExecutor : LexerActionExecutor.Option_LexerActionExecutor.Optional;

      --
      -- Indicates that this state was created during SLL prediction that
      -- discovered a conflict between the configurations in the state. Future
      -- _org.antlr.v4.runtime.atn.ParserATNSimulator#execATN_ invocations immediately jumped doing
      -- full context prediction if this field is True.
      --
      -- public internal (set)
      requiresFullContext : Boolean := False;

      --
      -- During SLL parsing, this is a list of predicates associated with the
      -- ATN configurations of the DFA state. When we have predicates,
      -- _#requiresFullContext_ is `False` since full context prediction evaluates predicates
      -- on-the-fly. If this is not null, then _#prediction_;
      -- _org.antlr.v4.runtime.atn.ATN#INVALID_ALT_NUMBER_.
      --
      -- We only use these for non-_#requiresFullContext_ but conflicting states. That
      -- means we know from the context (it's $ or we don't dip into outer
      -- context) that it's an ambiguity not a conflict.
      --
      -- This list is computed by _org.antlr.v4.runtime.atn.ParserATNSimulator#predicateDFAState_.
      --

      -- public internal (set)
      predicates : PredPrediction_List;

      --
      -- mutex for states changes.
      --
      -- internal private (set);
      mutex : TOFIX := Mutex.Synchronised;

      --
      -- Map a predicate to a predicted alternative.
      --
      PredPrediction : PredPrediction;

   end record;

   subtype Object is DFAState;
   type Class is access all Object;
   type Class_Wide is access all Object'Class;

   -- public
   procedure Initialize (Self : in out DFAState; configs : ATNConfigSet);

   --
   -- Get the set of all alts mentioned by all ATN configurations in this
   -- DFA state.
   --
   -- public
   function getAltSet (This : DFAState) return Set_of_Optional_Integers --TOFIX
      is (This.configs.getAltSet);

   -- public
   procedure Hash (This : DFAState; hasher : in out Hasher);

   subtype Sink is Ada.Strings.Text_Buffers.Root_Buffer_Type;
   procedure Put_Image_DFAState (S : in out Sink'Class; X : DFAState);
   for DFAState'Put_Image use Put_Image_DFAState;
   -- public
   function Description (This : DFAState) return UString;

   --
   -- Two _org.antlr.v4.runtime.DFA.States_ instances are equal if their ATN configuration sets
   -- are the same. This method is used to see if a state already exists.
   --
   -- Because the number of alternatives and number of ATN configurations are
   -- finite, there is a finite number of DFA states that can be processed.
   -- This is necessary to show that the algorithm terminates.
   --
   -- Cannot test the DFA state numbers here because in
   -- _org.antlr.v4.runtime.atn.ParserATNSimulator#addDFAState_ we need to know if any other state
   -- exists that has this exact set of ATN configurations. The
   -- _#stateNumber_ is irrelevant.
   --
   -- public
   function "=" (Lhs, Rhs : DFAState) return Boolean;

end ANTLR.Runtime.DFA.States;
