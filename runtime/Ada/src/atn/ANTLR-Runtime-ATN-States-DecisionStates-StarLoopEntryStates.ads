-- €

use ANTLR.Runtime.ATN.States;
use ANTLR.Runtime.ATN.DecisionState;

package ANTLR.Runtime.ATN.States.DecisionStates.StarLoopEntryStates is

   -- public final
   type StarLoopEntryState is new DecisionState with
   record
      -- public
      loopBackState : Optional_StarLoopbackState;

      --
      -- Indicates whether this state can benefit from a precedence DFA during SLL
      -- decision making.
      --
      -- This is a computed property that is calculated during ATN deserialization
      -- and stored for use in _org.antlr.v4.runtime.atn.ParserATNSimulator_ and
      -- _org.antlr.v4.runtime.ParserInterpreter_.
      --
      -- * seealso: org.antlr.v4.runtime.dfa.DFA#isPrecedenceDfa ();
      --
      -- public
      precedenceRuleDecision : Boolean := False;
   end record;

   subtype Object is StarLoopEntryState;
   subtype Super is DecisionState;
   type Class is access all Object;
   type Class_Wide is access all Object'Class;

    -- public
   overriding
   function getStateType (This : StarLoopEntryState) return State
      is (STAR_LOOP_ENTRY);

end ANTLR.Runtime.ATN.States.DecisionStates.StarLoopEntryStates;
