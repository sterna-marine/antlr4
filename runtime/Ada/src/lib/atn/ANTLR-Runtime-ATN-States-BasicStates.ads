-- €

package ANTLR.Runtime.ATN.States.BasicStates is

-- public final
type BasicState is new ATNState with null record;

   overriding
   -- public
   function getStateType (This : BasicState) return Integer
      is (This.ATNState.BASIC);

end ANTLR.Runtime.ATN.States.BasicStates;
