-- €

with Ada.Wide_Wide_Text_IO;

use Ada;

package body ANTLR.Runtime.ATN.CommonUtil is

   procedure log (message : UString;
                  file : UString := "#file";
                  This_function : UString := "#function";
                  lineNum : Integer := 0) is
      -- #if DEBUG
      Wide_Wide_Text_IO.Put_Line ("FILE: " & URL (fileURLWithPath => file).pathComponents.last & ", FUNC: " & This_function & ", LINE: " & lineNum'Image & ", MESSAGE: " & message);
      --   #else
      -- do nothing
      --   #endif
   end log;

   function toLong (data : Character_List; offset : Integer) return Integer_64 is --TOFIX
      mask     : constant Integer_64 := 16#0_0000_0_0000_FFFF_FFFF#;
      lowOrder : constant Integer_64 := Integer_64 (toInteger_32 (data, offset)) & mask;
   begin
      return lowOrder | Integer_64 (toInteger_32 (data, offset + 2) << 32);
   end toLong;

   function toUUID (data : Character_List; offset : Integer) return UUID is --TOFIX
      leastSigBits : constant Integer_64 := toLong (data, offset);
      mostSigBits  : constant Integer_64 := toLong (data, offset + 4);
   begin
      return UUID (mostSigBits => mostSigBits, leastSigBits => leastSigBits);
   end toUUID;

end ANTLR.Runtime.ATN.CommonUtil;