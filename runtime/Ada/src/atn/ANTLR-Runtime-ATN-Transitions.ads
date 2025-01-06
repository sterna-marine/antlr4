-- €

package ANTLR.Runtime.ATN.Transitions is

   --
   -- An ATN transition between any two ATN states.  Subclasses define
   -- atom, set, epsilon, action, predicate, rule transitions.
   --
   -- This is a one way link.  It emanates from a state (usually via a list of
   -- transitions) and has a target state.
   --
   -- Since we never have to change the ATN transitions once we construct it,
   -- we can fix these transitions as specific classes. The DFA transitions
   -- on the other hand need to update the labels as it adds transitions to
   -- the states. We'll use the term Edge for the DFA to distinguish them from
   -- ATN transitions.
   --

   type ATNTransition is abstract tagged record
      -- public internal (set) final var
      target : ATNState;
   end record;

   function Equal (Left, Right : ATNTransition) return Boolean;

   -- public
   type Transition is (
      INVALID,
      EPSILON,
      TRANSITION_RANGE,
      RULE,      -- e.g., {isType (input.LT (1))}?
      PREDICATE,
      ATOM,
      ACTION,    -- not (A|B) or not atom, wildcard, which convert to next 2
      SET,
      NOT_SET,
      WILDCARD,
      PRECEDENCE);

   -- constants for serialization
   -- public static
   for Transition use (
      INVALID           => 0,
      EPSILON           => 1,
      TRANSITION_RANGE  => 2,
      RULE              => 3,
      PREDICATE         => 4,
      ATOM              => 5,
      ACTION            => 6,
      SET               => 7,
      NOT_SET           => 8,
      WILDCARD          => 9,
      PRECEDENCE        => 10);

   subtype Container_Index is Natural;
   package ATNTransition_Container is new Ada.Cantainers.Vectors (
      Index_Type => Container_Index,
      Element_Type => ATNTransition,
      "=" => Equal);
   subtype ATNTransition_List is ATNTransition_Container.Vector;

      -- public static
   type serializationTypes is array (Transition range EPSILON .. PRECEDENCE) of UString;

   function serializationTypes_Image (This : ATNTransition) return UString;

   --
   -- The target of this transition.
   --

   procedure Initialize (Self : in out ATNTransition; target : ATNState);

   -- public
   function getSerializationType (This : ATNTransition'Class) return Integer;

   --
   -- Determines if the transition is an "epsilon" transition.
   --
   -- The default implementation returns `False`.
   --
   -- * returns: `True` if traversing this transition in the ATN does not
   -- consume an input symbol; otherwise, `False` if traversing this
   -- transition consumes (matches) an input symbol.
   --
   -- public
   function isEpsilon (This : ATNTransition'Class) return Boolean
      is (False);

   -- public
   function labelIntervalSet (This : ATNTransition'Class) return Optional_IntervalSet
      is (Optional_IntervalSet (Valid => False));

   -- public
   function matches (This : ATNTransition'Class; symbol : Integer; minVocabSymbol : Integer; maxVocabSymbol : Integer) return Boolean;

end ANTLR.Runtime.ATN.Transitions;
