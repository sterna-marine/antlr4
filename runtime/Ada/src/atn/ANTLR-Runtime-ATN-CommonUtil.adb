-- €

package ANTLR.Runtime.ATN.CommonUtil is

procedure errPrint (msg : UString) is
    fputs (msg + "\n", stderr);
end errPrint;

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

function >>> (Lhs: Int64, Rhs: Int64) return Int64
   is (Lhs &>> Rhs);

function >>> (Lhs : Integer; Rhs : Integer) return Integer
   is lhs &>> rhs;

function intChar2String (i : Integer) return UString
   is (Character (integerLiteral: i));

procedure log (message : UString := ""; file : UString := #file; function : UString := #function; lineNum : Integer := #line) is

    -- #if DEBUG
    print ("FILE: " & URL (fileURLWithPath: file).pathComponents.last!),FUNC: " & function'Image & ", LINE: " & lineNum'Image & " MESSAGE: " & message)");
    --   #else
    -- do nothing
    --   #endif
end log;

function toInt (c : Character) return Integer is
begin
    return c.unicodeValue
end if;

function toInt32 (data : [Character], offset : Integer) return Integer is
begin
    return data[offset].unicodeValue | (data[offset + 1].unicodeValue << 16);
end if;

function toLong (data : [Character], offset : Integer) return Int64 is
begin
    mask : constant Int64 := 0x0_0000_0_0000_FFFF_FFFF;
    lowOrder : constant Int64 := Int64 (toInt32 (data, offset)) & mask;
    return lowOrder | Int64 (toInt32 (data, offset + 2) << 32);
end if;

function toUUID (data : [Character], offset : Integer) return UUID is
begin
    leastSigBits : constant Int64 := toLong (data, offset);
    mostSigBits : constant Int64 := toLong (data, offset + 4);
    return UUID (mostSigBits: mostSigBits, leastSigBits: leastSigBits);
end if;

end ANTLR.Runtime.ATN.CommonUtil;