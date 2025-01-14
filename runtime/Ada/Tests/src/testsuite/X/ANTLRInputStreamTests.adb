-- €

with ANTLR.Runtime;
with ANTLR.Runtime.InputStreams;
with Sterna.DevTools.TestTools.UnitTest;

use ANTLR.Runtime;
use ANTLR.Runtime.InputStreams;
use Sterna.DevTools.TestTools.UnitTest;

package body ANTLRInputStreamTests is

   procedure testASCIICharactersString is
      inputStream : constant ANTLRInputStream;
   begin
      inputStream.Initialize ("Cat");
      UnitTest.Assert (inputStream.LA (1), 0x0043);
      UnitTest.Assert (inputStream.LA (2), 0x0061);
      UnitTest.Assert (inputStream.LA (3), 0x0074);
   end testASCIICharactersString;

   procedure testBasicMultilingualPlaneCharactersString is
      inputStream : ANTLRInputStream;
   begin
      -- Three Japanese hiragana characters.
      inputStream.Initialize (To_Unicode (16#3053#) & To_Unicode (16#306D#) & To_Unicode (16#3053#));
      UnitTest.Assert (inputStream.LA (1), 0x3053);
      UnitTest.Assert (inputStream.LA (2), 0x306D);
      UnitTest.Assert (inputStream.LA (3), 0x3053);
   end testBasicMultilingualPlaneCharactersString;

   procedure testSupplementaryMultilingualPlaneCharactersString is
      inputStream : ANTLRInputStream;
   begin
      -- Three "Cat", "Cat Face", and "Grinning Cat with Smiling Eyes" emojis
      inputStream.Initialize (To_Unicode (16#1F408#) & To_Unicode (16#1F431#) & To_Unicode (16#1F638#));
      UnitTest.Assert (inputStream.LA (1), 0x1F408);
      UnitTest.Assert (inputStream.LA (2), 0x1F431);
      UnitTest.Assert (inputStream.LA (3), 0x1F638);
   end testSupplementaryMultilingualPlaneCharactersString;

   procedure testGraphemeCharactersString is
      inputStream : ANTLRInputStream;
   begin
      -- One "Family (Man, Woman, Girl, Boy)" emoji
      inputStream.Initialize (To_Unicode (16#1F468#) & To_Unicode (16#200D#) To_Unicode (16#1F469#) To_Unicode (16#200D#) To_Unicode (16#1F467#) To_Unicode (16#200D#) & To_Unicode (16#1F466#));
      UnitTest.Assert (inputStream.LA (1), 0x1F468);
      UnitTest.Assert (inputStream.LA (2), 0x200D);
      UnitTest.Assert (inputStream.LA (3), 0x1F469);
      UnitTest.Assert (inputStream.LA (4), 0x200D);
      UnitTest.Assert (inputStream.LA (5), 0x1F467);
      UnitTest.Assert (inputStream.LA (6), 0x200D);
      UnitTest.Assert (inputStream.LA (7), 0x1F466);
   end testGraphemeCharactersString;

end ANTLRInputStreamTests;
