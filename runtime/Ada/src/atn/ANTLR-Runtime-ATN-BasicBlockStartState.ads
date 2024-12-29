-- €

package ANTLR.Runtime.ATN.BasicBlockStartState is

-- public final
type BasicBlockStartState is new BlockStartState with null record;

   overriding
   -- public
   function getStateType (This : BasicBlockStartState) return Integer
      is This.BlockStartState.BLOCK_START;

end ANTLR.Runtime.ATN.BasicBlockStartState;
