-- €

with Ada.Wide_Wide_Text_IO;

use Ada;

package body ANTLR.Runtime.RuntimeMetaDatas is

   This_runtimeVersion : constant RuntimeMetaData;

   procedure checkVersion (generatingToolVersion : UString;
                           compileTimeVersion : UString) is
      runtimeVersion : constant UString   := This_runtimeVersion.VERSION;
      runtimeConflictsWithGeneratingTool  : Boolean := False;
      runtimeConflictsWithCompileTimeTool : Boolean := False;
   begin
      --if ( Is_Valid (generatingToolVersion) ) {
      runtimeConflictsWithGeneratingTool :=
               not (runtimeVersion = (generatingToolVersion)) and
               not (getMajorMinorVersion (runtimeVersion) = (getMajorMinorVersion (generatingToolVersion)));
      --}

      runtimeConflictsWithCompileTimeTool =
               not (runtimeVersion = (compileTimeVersion)) and
               not (getMajorMinorVersion (runtimeVersion) = (getMajorMinorVersion (compileTimeVersion)));

      if runtimeConflictsWithGeneratingTool then
         Wide_Wide_Text_IO.Put_Line ("ANTLR Tool version " & generatingToolVersion'Image & " used for code generation does not match the current runtime version " & runtimeVersion'Image);
      end if;
      if runtimeConflictsWithCompileTimeTool then
         Wide_Wide_Text_IO.Put_Line ("ANTLR Runtime version " & compileTimeVersion'Image & "used for parser compilation does not match the current runtime version " & runtimeVersion'Image);
      end if;
   end checkVersion;

   function getMajorMinorVersion (version : UString) return UString is
   begin
      return Version (1 ..1); --TOFIX
   end getMajorMinorVersion;

end TLR.Runtime.RuntimeMetaDatas;
