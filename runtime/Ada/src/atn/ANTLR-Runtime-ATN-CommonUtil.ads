-- €

package  ANTLR.Runtime.ATN.CommonUtil is

   procedure errPrint (msg : UString);

   -- public
   function "+" (Lhs: UString; Rhs : Integer) Return UString
      is (lhs + String (rhs));

   -- public
   function "+" (Lhs : Integer; Rhs: UString) return UString
      is (String (lhs) + rhs);

   -- public
   function "+" (Lhs : UString; Rhs : Token) return UString
      is (Lhs + Image (Rhs);

   -- public
   function "+" (lhs : Token; rhs: String) return UString
      is (Lhs.Description + Rhs);

   infix operator >>> : BitwiseShiftPrecedence

   function >>> (Lhs : Int32; Rhs: Int32) return Int32
      is (Lhs &>> Rhs);

   function >>> (Lhs: Int64; rhs : Int64) return Int64
      is (Lhs &>> Rhs);

   function >>> (Lhs : Integer; Rhs : Integer) return Integer
      is lhs &>> rhs;

   function intChar2String (i : Integer) return UString
      is (Character (integerLiteral: i));

   procedure log (message : UString := ""; file : UString := #file; function : UString := #function; lineNum : Integer := #line);

   function toInt (c : Character) return Integer
      is (c.unicodeValue);

   function toInt32 (data : [Character]; offset : Integer) return Integer
      is  (data[offset].unicodeValue | (data[offset + 1].unicodeValue << 16));

   function toLong (data : [Character]; offset : Integer) return Int64;

   function toUUID (data : [Character]; offset : Integer) return UUID;

end ANTLR.Runtime.ATN.CommonUtil;