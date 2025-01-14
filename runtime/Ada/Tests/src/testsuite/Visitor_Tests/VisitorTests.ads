-- €

with AdaForge.DevTools.TestTools.UnitTest;
use AdaForge.DevTools.TestTools;

package VisitorTests is

   type Test is new UnitTest.Test_Case with null record;

   overriding
   procedure Initialize (T : in out Test);

private
      procedure testCalculatorVisitor;
      procedure testShouldNotVisitTerminal;
      procedure testShouldNotVisitEOF;
      procedure testVisitErrorNode;
      procedure testVisitTerminalNode;

end VisitorTests;