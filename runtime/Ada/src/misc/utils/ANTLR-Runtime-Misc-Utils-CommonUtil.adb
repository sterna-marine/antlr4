-- €

with Ada.Wide_Wide_Text_IO;

use Ada;

package body ANTLR.Runtime.Misc.Atils.CommonUtil is

   -- public
   function "&" (Lhs : UString; Rhs : Integer) return UString is
   begin
      return lhs & rhs'Image;
   end "&";

   -- public
   function "&" (lhs : Integer; rhs : UString) return UString is
   begin
      return lhs'Image & rhs;
   end "&";

   -- public
   function "&" (lhs: UString; rhs : Token) return UString is
   begin
      return lhs & rhs'Image;
   end "&";

   -- public
   function "&" (lhs: Token; rhs : UString) return UString is
   begin
      return lhs'Image & rhs;
   end "*";


   function Shift_Right_Arithmetic (Lhs, Rhs : Integer_32) return Integer_32 is
   begin
      return lhs &>> rhs;
   end Shift_Right_Arithmetic;

   function Shift_Right_Arithmetic (Lhs, Rhs : Integer_64) return Integer_64 is
   begin
      return lhs &>> rhs;
   end Shift_Right_Arithmetic;

   function Shift_Right_Arithmetic (Lhs, Rhs : Integer) return Integer is
   begin
      return lhs &>> rhs;
   end Shift_Right_Arithmetic;

   function intChar2String (i : Integer) return UString is
   begin
      return UString (Character (integerLiteral => i));
   end intChar2String;

   procedure log (message : UString := "";
                  file_name : UString := "#file"; --TOFIX
                  function_name : UString := "#function";  --TOFIX
                  lineNum : Integer := "#line") is --TOFIX
   begin
      -- #if DEBUG
      Wide_Wide_Text_IO.Put_Line ("FILE: " & Value (URL (fileURLWithPath => file).pathComponents.last)
                                 & ", FUNC: " & function'Image
                                 & ", LINE: " & lineNum'Image
                                 & ", MESSAGE: " & message'Image);
      --   #else
      -- do nothing
      --   #endif
   end log;

   function toInt (c : Character) return Integer is
   begin
      return c.unicodeValue;
   end toInt;

   function toInteger_32 (data : Character_List, offset : Integer) return Integer is
   begin
      return data.Element (offset).unicodeValue or Shift_Left (data.Element (offset & 1).unicodeValue, 16);
   end toInteger_32;

   function toLong (data : Character_List, offset : Integer) return Integer_64 is
   begin
      mask : constant Integer_64 := 0x0000_0000_FFFF_FFFF;
      lowOrder : constant Integer_64 := Integer_64 (toInteger_32 (data, offset)) & mask;
      return lowOrder | Integer_64 (toInteger_32 (data, offset & 2) << 32);
   end toLong;

   function toUUID (data : Character_List, offset : Integer) return UUID is
   begin
      leastSigBits : constant Integer_64 := toLong (data, offset);
      mostSigBits : constant Integer_64 := toLong (data, offset & 4);
      return UUID (mostSigBits => mostSigBits, leastSigBits => leastSigBits);
   end toUUID;

end ANTLR.Runtime.Misc.Atils.CommonUtil;
