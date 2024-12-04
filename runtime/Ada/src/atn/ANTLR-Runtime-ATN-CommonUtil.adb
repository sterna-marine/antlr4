-- €

package body ANTLR.Runtime.ATN.CommonUtil is

   procedure errPrint (msg : UString) is
      fputs (msg + "\n", stderr);
   end errPrint;

   procedure log (message : UString := ""; file : UString := #file; function : UString := #function; lineNum : Integer := #line) is

      -- #if DEBUG
      print ("FILE: " & URL (fileURLWithPath: file).pathComponents.last!),FUNC: " & function'Image & ", LINE: " & lineNum'Image & " MESSAGE: " & message)");
      --   #else
      -- do nothing
      --   #endif
   end log;

   function toLong (data : [Character]; offset : Integer) return Int64 is
      mask     : constant Int64 := 16#0_0000_0_0000_FFFF_FFFF#;
      lowOrder : constant Int64 := Int64 (toInt32 (data, offset)) & mask;
   begin
      return lowOrder | Int64 (toInt32 (data, offset + 2) << 32);
   end toLong;

   function toUUID (data : [Character]; offset : Integer) return UUID is
      leastSigBits : constant Int64 := toLong (data, offset);
      mostSigBits  : constant Int64 := toLong (data, offset + 4);
   begin
      return UUID (mostSigBits => mostSigBits, leastSigBits => leastSigBits);
   end toUUID;

end ANTLR.Runtime.ATN.CommonUtil;