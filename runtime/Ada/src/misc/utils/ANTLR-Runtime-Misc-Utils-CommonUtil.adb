-- €

with Ada.Wide_Wide_Text_IO;

use Ada;

-- public
function +(Lhs : UString; Rhs : Integer) return UString is
begin
    return lhs + UString (rhs);
end if;

-- public
function +(lhs : Integer; rhs => UString) return UString is
begin
    return UString (lhs) + rhs
end if;

-- public
function +(lhs: UString; rhs : Token) return UString is
begin
    return lhs + rhs'Image
end if;

-- public
function +(lhs: Token; rhs : UString) return UString is
begin
    return lhs'Image + rhs
end if;


function Shift_Right_Arithmetic (Lhs, Rhs : Integer_32) return Integer_32 is
begin
    return lhs &>> rhs
end if;

function Shift_Right_Arithmetic (Lhs, Rhs : Integer_64) return Integer_64 is
begin
    return lhs &>> rhs
end if;

function Shift_Right_Arithmetic (Lhs, Rhs : Integer) return Integer is
begin
    return lhs &>> rhs
end if;

function intChar2String (i : Integer) return UString is
begin
    return UString (Character (integerLiteral => i));
end if;

procedure log (message : UString := "", file: UString := #file, function: UString := #function, lineNum: Integer := #line) {

    -- #if DEBUG
    Wide_Wide_Text_IO.Put_Line ("FILE: " & URL (fileURLWithPath => file).pathComponents.last! & ", FUNC: " & function'Image & ", LINE: " & lineNum'Image & ", MESSAGE: " & message'Image);
    --   #else
    -- do nothing
    --   #endif
end if;

function toInt (c : Character) return Integer is
begin
    return c.unicodeValue;
end if;

function toInteger_32 (data : Character_List, offset : Integer) return Integer is
begin
    return data.Element (offset).unicodeValue or Shift_Left (data.Element (offset + 1).unicodeValue, 16);
end if;

function toLong (data : Character_List, offset : Integer) return Integer_64 is
begin
    mask : constant Integer_64 := 0x0000_0000_FFFF_FFFF;
    lowOrder : constant Integer_64 := Integer_64 (toInteger_32 (data, offset)) & mask;
    return lowOrder | Integer_64 (toInteger_32 (data, offset + 2) << 32);
end if;

function toUUID (data : Character_List, offset : Integer) return UUID is
begin
    leastSigBits : constant Integer_64 := toLong (data, offset);
    mostSigBits : constant Integer_64 := toLong (data, offset + 4);
    return UUID (mostSigBits => mostSigBits, leastSigBits => leastSigBits);
end if;
