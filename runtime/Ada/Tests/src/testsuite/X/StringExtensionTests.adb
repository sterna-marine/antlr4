-- €

with ANTLR.Runtime;
with ANTLR.Runtime.InputStreams;
with ANTLR.Runtime.Misc.Extensions.StringExtension;
with Sterna.DevTools.TestTools.UnitTest;


package body UStringExtensionTests is

   -- private
   procedure doLastIndexTest (str : UString; target : UString; expectedOffset : Optional_Integer) is
      expectedIdx : constant Optional_UString.Index;
   begin
      if Is_Valid (expectedOffset) then
         expectedIdx := str.index (str.startIndex, offsetBy => expectedOffset);
      else
         null; -- expectedIdx := (Valid => False);
      end if;
      UnitTest.Assert_Equal (ANTLR.Runtime.Misc.Extensions.StringExtension.lastIndex (str, target), expectedIdx); --TOFIX
   end doLastIndexTest;

   procedure testLastIndex is
   begin
      doLastIndexTest ("", "", null);
      doLastIndexTest ("a", "", null);
      doLastIndexTest ("a", "a", 0);
      doLastIndexTest ("aba", "a", 2);
      doLastIndexTest ("aba", "b", 1);
      doLastIndexTest ("abc", "d", null);
   end testLastIndex;

end UStringExtensionTests;
