-- €

with Sterna.DevTools.TestTools.UnitTest;
with Antlr4.Runtime;
with Antlr4.Runtime.InputStreams;

use Antlr4.Runtime;
use Antlr4.Runtime.InputStreams;
use Sterna.DevTools.TestTools.UnitTest;

package ANTLRInputStreamTests is

   procedure testASCIICharactersString;

   procedure testBasicMultilingualPlaneCharactersString;

   procedure testSupplementaryMultilingualPlaneCharactersString;

   procedure testGraphemeCharactersString;

end ANTLRInputStreamTests;
