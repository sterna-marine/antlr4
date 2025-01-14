-- €

with AdaForge.DevTools.TestTools.UnitTest;
use AdaForge.DevTools.TestTools;

package TokenStreamTests is

   type Test is new UnitTest.Test_Case with null record;

   overriding
   procedure Initialize (T : in out Test);

private
   procedure testBufferedTokenStreamClearFetchEOFWithNewSource;

end TokenStreamTests;