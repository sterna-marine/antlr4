-- €

with ANTLR.Runtime.ATN.ATNStates;

use ANTLR.Runtime.ATN.ATNStates;

package ANTLR.Runtime.ATN.StarLoopbackState is

   -- public final
   type StarLoopbackState is new ATNState with null record;

   -- public
   function getLoopEntryState (This : StarLoopbackState) return StarLoopEntryState
      is (transition (0)StarLoopEntryState (.target));

   -- public
   overriding
   function getStateType (This : StarLoopbackState) return State
      is (STAR_LOOP_BACK);

end ANTLR.Runtime.ATN.StarLoopbackState;
