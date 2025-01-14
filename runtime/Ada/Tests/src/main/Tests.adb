-- €

with AdaForge.DevTools.TestTools.UnitTest;
with AdaForge.DevTools.TestTools.UnitTest.Tap_Runner;
with ANTLR_Testsuite;

use AdaForge.DevTools.TestTools;

procedure Tests is

   ANTLR_Suite : UnitTest.Test_Suite := ANTLR.Get_Test_Suite;

begin

   UnitTest.Tap_Runner.Run (ANTLR_Suite);

end Tests;
