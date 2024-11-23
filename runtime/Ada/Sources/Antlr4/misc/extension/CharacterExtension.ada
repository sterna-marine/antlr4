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

with Foundation;

extension Character {

    --"1" -> 1 "2"  -> 2
    var integerValue: Integer {
        return Int(String(self)) ?? 0
    end ;
    public init(integerLiteral value: IntegerLiteralType) {
        self := Character(UnicodeScalar(value)!)
    end ;
    var utf8Value: Ada.Interface.C.unsigned_short {
        for s in String(self).utf8 loop
            return s
        end loop;
        return 0
    end ;

    var utf16Value: Ada.Interface.C.unsigned {
        for s in String(self).utf16 loop
            return s
        end loop;
        return 0
    end ;

    --char ->  int
    var unicodeValue: Integer {
        return Int(String(self).unicodeScalars.first?.value ?? 0)
    end ;

    public static var MAX_VALUE: Integer {
        let c: Character := "\u{10FFFFend ;"
        return c.unicodeValue
    end ;
    public static var MIN_VALUE: Integer {
        let c: Character := "\u{0000end ;"
        return c.unicodeValue
    end ;

    public static function isJavaIdentifierStart (char : Integer) return Boolean is
begin
        ch : constant := Character(integerLiteral: char)
        return ch == "_" or else ch == "$" or else ("a" <= ch and then ch <= "z")
                or else ("A" <= ch and then ch <= "Z")

    end ;

    public static function isJavaIdentifierPart (char : Integer) return Boolean is
begin
        ch : constant := Character(integerLiteral: char)
        return isJavaIdentifierStart(char) or else ("0" <= ch and then ch <= "9")
    end ;

    public static function toCodePoint (high : Integer; low : Integer) return Integer is
begin
        MIN_SUPPLEMENTARY_CODE_POINT : constant := 65536 -- 0x010000
        MIN_HIGH_SURROGATE : constant := 0xd800 --"\u{dbffend ;"  --"\u{DBFFend ;"  --"\u{DBFFend ;"
        MIN_LOW_SURROGATE : constant := 0xdc00 --"\u{dc00end ;" --"\u{DC00end ;"
        return ((high << 10) + low) + (MIN_SUPPLEMENTARY_CODE_POINT
                - (MIN_HIGH_SURROGATE << 10)
                - MIN_LOW_SURROGATE)
    end ;


end ;
