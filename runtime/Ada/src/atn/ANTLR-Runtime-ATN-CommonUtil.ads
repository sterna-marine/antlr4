-- €

with Interfaces;

use Interfaces;

package ANTLR.Runtime.ATN.CommonUtil is

   -- public
   function "&" (Lhs: UString; Rhs : Integer) Return UString
      is (lhs & rhs'Image);

   -- public
   function "&" (Lhs : Integer; Rhs: UString) return UString
      is (lhs'Image & rhs);

   -- public
   function "&" (Lhs : UString; Rhs : Token) return UString
      is (Lhs & Image (Rhs));

   -- public
   function "&" (lhs : Token; rhs: UString) return UString
      is (Image (Lhs) & Rhs);

   function Shift_Right_Arithmetic (Lhs, Rhs : Integer_32) return Integer_32
      is (Interfaces.Shift_Right_Arithmetic (Lhs, Rhs));

   function Shift_Right_Arithmetic (Lhs, Rhs : Integer_64) return Integer_64
      is (Interfaces.Shift_Right_Arithmetic (Lhs, Rhs));

   function Shift_Right_Arithmetic (Lhs, Rhs : Integer) return Integer
      is (Interfaces.Shift_Right_Arithmetic (Lhs, Rhs));

   function intChar2String (i : Integer) return UString
      is (Character'Val (i));  --TOFIX

   procedure log (message : UString;
                  file : UString := "#file";
                  This_function : UString := "#function";
                  lineNum : Integer := 0);

   function toInt (c : Character) return Integer
      is (c'Pos);  --TOFIX

   function toInteger_32 (data : Character_List; offset : Integer) return Integer
      is  (data.Element (offset).unicodeValue or Shift_Left (data.Element (offset + 1).unicodeValue, 16));  --TOFIX

   function toLong (data : Character_List; offset : Integer) return Integer_64;

   function toUUID (data : Character_List; offset : Integer) return UUID;

end ANTLR.Runtime.ATN.CommonUtil;