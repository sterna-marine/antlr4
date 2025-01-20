-- €

with Interfaces;

use Ada;
use ANTLR.Runtime;

package ANTLR.Runtime.Misc.Atils.CommonUtil is

   -- public
   function "&" (Lhs : UString; Rhs : Integer) return UString;

   -- public
   function "&" (lhs : Integer; rhs : UString) return UString;

   -- public
   function "&" (lhs: UString; rhs : Token) return UString;

   -- public
   function "&" (lhs: Token; rhs : UString) return UString;

   function Shift_Right_Arithmetic (Lhs, Rhs : Integer_32) return Integer_32;

   function Shift_Right_Arithmetic (Lhs, Rhs : Integer_64) return Integer_64;

   function Shift_Right_Arithmetic (Lhs, Rhs : Integer) return Integer;

   function intChar2String (i : Integer) return UString;

   procedure log (message : UString := "";
                  file_name : UString := "#file"; --TOFIX
                  function_name : UString := "#function";  --TOFIX
                  lineNum : Integer := "#line"); --TOFIX

   function toInt (c : Character) return Integer;

   function toInteger_32 (data : Character_List, offset : Integer) return Integer;

   function toLong (data : Character_List, offset : Integer) return Integer_64;

   function toUUID (data : Character_List, offset : Integer) return UUID;

end ANTLR.Runtime.Misc.Atils.CommonUtil;
