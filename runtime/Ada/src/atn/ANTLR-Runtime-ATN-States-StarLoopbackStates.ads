-- €

use ANTLR.Runtime.ATN.ATNStates;

package ANTLR.Runtime.ATN.States.StarLoopbackStates is

   -- public final
   type StarLoopbackState is new ATNState with null record;

   subtype Object is StarLoopbackState;
   subtype Super is ATNState;
   type Class is access all Object;
   type Class_Wide is access all Object'Class;

   -- public
   function getLoopEntryState (This : StarLoopbackState) return StarLoopEntryState
      is (transition (0)StarLoopEntryState (.target));

   -- public
   overriding
   function getStateType (This : StarLoopbackState) return State
      is (STAR_LOOP_BACK);

end ANTLR.Runtime.ATN.States.StarLoopbackStates;
