-- €

package body ANTLR.Runtime.Misc.Utils.Mutex is

   protected body Synchronized is
      procedure Run (Run_This : Gen_Closure'Access; Result : in out R) is
      begin
         Result := Run_This.all;
      end Run;
   end Synchronized;

end ANTLR.Runtime.Misc.Utils.Mutex;
