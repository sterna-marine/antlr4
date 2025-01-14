with Antlr4.Runtime;
with Antlr4.Runtime.BufferedCommonTokenStreams.CommonTokenStreams;
with Antlr4.Runtime.InputStreams;
with Antlr4.Runtime.Lexers;
with Sterna.DevTools.TestTools.UnitTest;

use Antlr4.Runtime;
use Antlr4.Runtime.BufferedCommonTokenStreams.CommonTokenStreams;
use Antlr4.Runtime.InputStreams;
use Antlr4.Runtime.Lexers;
use Sterna.DevTools.TestTools.UnitTest;

package InterpreterDataTests is

   -- https:--stackoverflow.com/a/57713176
   sourceDir : constant := URL (fileURLWithPath:#file).deletingLastPathComponent;

   procedure testLexerA;

   procedure testLexerB;

   procedure testCalculator;

end InterpreterDataTests;
