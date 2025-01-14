-- €

with Antlr4.Runtime;
with Antlr4.Runtime.InputStreams;
with Antlr4.Runtime.RuntimeMetaDatas;
with Sterna.DevTools.TestTools.UnitTest;


package body RuntimeMetaDataTests is

   -- private
   procedure doGetMajorMinorVersionTest (input : UString; expected : UString) is
   begin
      UnitTest.Assert_Equal (Antlr4.Runtime.RuntimeMetaDatas.getMajorMinorVersion (input), expected);
   end doGetMajorMinorVersionTest;

   procedure testGetMajorMinorVersion is
   begin
      doGetMajorMinorVersionTest ("", "");
      doGetMajorMinorVersionTest ("4", "4");
      doGetMajorMinorVersionTest ("4.", "4.");
      doGetMajorMinorVersionTest ("4.7", "4.7");
      doGetMajorMinorVersionTest ("4.7.1", "4.7");
      doGetMajorMinorVersionTest ("4.7.2", "4.7");
      doGetMajorMinorVersionTest ("4.8", "4.8");
      doGetMajorMinorVersionTest ("4.9", "4.9");
      doGetMajorMinorVersionTest ("4.9.1", "4.9");
      doGetMajorMinorVersionTest ("4.9.2", "4.9");
      doGetMajorMinorVersionTest ("4.9.3", "4.9");
      doGetMajorMinorVersionTest ("4-SNAPSHOT", "4");
      doGetMajorMinorVersionTest ("4.-SNAPSHOT", "4.");
      doGetMajorMinorVersionTest ("4.7-SNAPSHOT", "4.7");
      doGetMajorMinorVersionTest ("4.7.1-SNAPSHOT", "4.7");
      doGetMajorMinorVersionTest ("4.7.2-SNAPSHOT", "4.7");
      doGetMajorMinorVersionTest ("4.9.1-SNAPSHOT", "4.9");
      doGetMajorMinorVersionTest ("4.9.2-SNAPSHOT", "4.9");
      doGetMajorMinorVersionTest ("4.9.3-SNAPSHOT", "4.9");
      doGetMajorMinorVersionTest ("4.10-SNAPSHOT", "4.10");
      doGetMajorMinorVersionTest ("4.10.1", "4.10");
      doGetMajorMinorVersionTest ("4.11.0", "4.11");
      doGetMajorMinorVersionTest ("4.11.1", "4.11");
      doGetMajorMinorVersionTest ("4.11.0-SNAPSHOT", "4.11");
      doGetMajorMinorVersionTest ("4.11.1-SNAPSHOT", "4.11");
      doGetMajorMinorVersionTest ("4.12.0-SNAPSHOT", "4.12");
      doGetMajorMinorVersionTest ("4.12.0", "4.12");
      doGetMajorMinorVersionTest ("4.13.0-SNAPSHOT", "4.13");
      doGetMajorMinorVersionTest ("4.13.0", "4.13");
      doGetMajorMinorVersionTest ("4.13.1", "4.13");
   end testGetMajorMinorVersion;

end RuntimeMetaDataTests;
