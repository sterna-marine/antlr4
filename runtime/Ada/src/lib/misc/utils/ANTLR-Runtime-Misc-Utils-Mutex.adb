-- €

package body ANTLR.Runtime.Misc.Utils.Mutex is

   protected body Synchronised is
      procedure Run (Run_This : Gen_Closure'Access; Result : in out R) is
      begin
         Result := Run_This.all;
      end Run;
   end Synchronised;

end ANTLR.Runtime.Misc.Utils.Mutex;
