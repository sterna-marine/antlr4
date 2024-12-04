-- €

package ANTLR.Runtime.ATN.DecisionInfo is

   -- public
   type DecisionState is new ATNState with
   record
      -- public
      decision : Integer := -1
      -- public
      nonGreedy : Boolean := False;
   end record;

end ANTLR.Runtime.ATN.DecisionInfo;
