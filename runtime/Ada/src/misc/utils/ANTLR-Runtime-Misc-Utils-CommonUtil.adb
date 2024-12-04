-- €
-- --------------------------------------------
--  CommonUtil.swift
--   antlr.swift

with Foundation;

procedure errPrint (msg : String) {
    fputs (msg + "\n", stderr);
end if;

-- public
function +(Lhs : String; Rhs : Integer) return String is
begin
    return lhs + String (rhs);
end if;

-- public
function +(lhs : Integer; rhs: String) return String is
begin
    return String (lhs) + rhs
end if;

-- public
function +(lhs: String; rhs : Token) return String is
begin
    return lhs + rhs.description
end if;

-- public
function +(lhs: Token; rhs : String) return String is
begin
    return lhs.description + rhs
end if;

infix operator >>> : BitwiseShiftPrecedence

function >>> (Lhs, Rhs : Int32) return Int32 is
begin
    return lhs &>> rhs
end if;

function >>> (Lhs, Rhs : Int64) return Int64 is
begin
    return lhs &>> rhs
end if;

function >>> (lhs : Integer; rhs : Integer) return Integer is
begin
    return lhs &>> rhs
end if;

function intChar2String (i : Integer) return String is
begin
    return String (Character (integerLiteral: i));
end if;

procedure log (message : UString := "", file: UString := #file, function: UString := #function, lineNum: Integer := #line) {

    -- #if DEBUG
    print ("FILE: \(URL (fileURLWithPath: file).pathComponents.last!),FUNC: " & function'Image & ", LINE: " & lineNum'Image & " MESSAGE: " & message'Image);
    --   #else
    -- do nothing
    --   #endif
end if;

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
    mask : constant Int64 := 0x0000_0000_FFFF_FFFF;
    lowOrder : constant Int64 := Int64 (toInt32 (data, offset)) & mask;
    return lowOrder | Int64 (toInt32 (data, offset + 2) << 32);
end if;

function toUUID (data : [Character], offset : Integer) return UUID is
begin
    leastSigBits : constant Int64 := toLong (data, offset);
    mostSigBits : constant Int64 := toLong (data, offset + 4);
    return UUID (mostSigBits: mostSigBits, leastSigBits: leastSigBits);
end if;
