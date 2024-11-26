-- 
-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
-- 

--
--  CharacterEextension.swift
--  Antlr.swift
--
--  Created by janyou on 15/9/4.
--

with Unicode;
use Unicode;


extension Character {

    --"1" -> 1 "2"  -> 2
    function integerValue (C : Character) return Integer is
    begin
      if C in '0' .. '9' then
         return Character'Pos (C) - 16#30#; -- ?? 0
      else
         return 0;
   end integerValue;
    
    -- public 
    procedure Init (Self : in out …; integerLiteral value: IntegerLiteralType) {
        self := Character(UnicodeScalar(value)!)
    end if;
    var utf8Value: Ada.Interface.C.unsigned_short {
        for s in String(self).utf8 loop
            return s
        end loop;
        return 0
    end if;

    var utf16Value: Ada.Interface.C.unsigned {
        for s in String(self).utf16 loop
            return s
        end loop;
        return 0
    end if;

    --char ->  int
    var unicodeValue: Integer {
        return Integer (String(self).unicodeScalars.first?.value ?? 0)
    end if;

    -- public static 
    var MAX_VALUE: Integer {
        let c: Character := To_Unicode (16#10FFFF#)
        return c.unicodeValue
    end if;
    -- public static 
    var MIN_VALUE: Integer {
        let c: Character := To_Unicode (16#0000#)
        return c.unicodeValue
    end if;

    -- public static
    function isJavaIdentifierStart (char : Integer) return Boolean is
begin
        ch : constant := Character(integerLiteral: char)
        return ch == "_" or else ch == "$" or else ("a" <= ch and then ch <= "z")
                or else ("A" <= ch and then ch <= "Z")

    end if;

    -- public static
    function isJavaIdentifierPart (char : Integer) return Boolean is
begin
        ch : constant := Character(integerLiteral: char)
        return isJavaIdentifierStart(char) or else ("0" <= ch and then ch <= "9")
    end if;

    -- public static
    function toCodePoint (high : Integer; low : Integer) return Integer is
begin
        MIN_SUPPLEMENTARY_CODE_POINT : constant := 65536 -- 0x010000
        MIN_HIGH_SURROGATE : constant Integer := 0xd800 --To_Unicode (16#dbff#)  --"To_Unicode (16#DBFF#)"  --"To_Unicode (16#DBFF#)";
        MIN_LOW_SURROGATE : constant Integer := 0xdc00 --"To_Unicode (16#dc00#)" --"To_Unicode (16#DC00#)";
        return ((high << 10) + low) + (MIN_SUPPLEMENTARY_CODE_POINT
                - (MIN_HIGH_SURROGATE << 10)
                - MIN_LOW_SURROGATE)
    end if;


end if;
