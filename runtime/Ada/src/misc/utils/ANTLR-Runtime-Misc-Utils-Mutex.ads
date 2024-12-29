-- €

package ANTLR.Runtime.Misc.Utils.Mutex is

   --
   -- Running the supplied closure synchronously.
   --
   -- * Parameter closure: the closure to run
   -- * Returns: the value returned by the closure
   --

   generic
      type Result_Type is (<>);
      function Closure return Result_Type;
   function Gen_Closure (Run_This : Closure'Access) return Result_Type;

   protected type Synchronized is
      procedure Run (Run_This : Synchronized'Access; Result : in out Result_Type);
   end Synchronized;

end ANTLR.Runtime.Misc.Utils.Mutex;
