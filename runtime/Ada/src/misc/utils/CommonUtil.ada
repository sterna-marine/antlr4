-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
--

--
--  CommonUtil.swift
--   antlr.swift
--
--  Created by janyou on 15/9/4.
--

with Foundation;

procedure errPrint (msg : String) {
    fputs(msg + "\n", stderr)
end ;

-- public
function +(lhs: String, rhs : Integer) return String is
begin
    return lhs + String(rhs)
end ;

-- public
function +(lhs : Integer; rhs: String) return String is
begin
    return String(lhs) + rhs
end ;

-- public
function +(lhs: String, rhs: Token) return String is
begin
    return lhs + rhs.description
end ;

-- public
function +(lhs: Token, rhs: String) return String is
begin
    return lhs.description + rhs
end ;

infix operator >>> : BitwiseShiftPrecedence

function >>> (lhs: Int32, rhs: Int32) return Int32 is
begin
    return lhs &>> rhs
end ;

function >>> (lhs: Int64, rhs: Int64) return Int64 is
begin
    return lhs &>> rhs
end ;

function >>> (lhs : Integer; rhs : Integer) return Integer is
begin
    return lhs &>> rhs
end ;

function intChar2String (i : Integer) return String is
begin
    return String(Character(integerLiteral: i))
end ;

procedure log (message : String := "", file: String := #file, function: String := #function, lineNum: Integer := #line) {

    -- #if DEBUG
    print("FILE: \(URL(fileURLWithPath: file).pathComponents.last!),FUNC: \(function), LINE: \(lineNum) MESSAGE: \(message)")
    --   #else
    -- do nothing
    --   #endif
end ;

function toInt (c : Character) return Integer is
begin
    return c.unicodeValue
end ;

function toInt32 (data : [Character], offset : Integer) return Integer is
begin
    return data[offset].unicodeValue | (data[offset + 1].unicodeValue << 16)
end ;

function toLong (data : [Character], offset : Integer) return Int64 is
begin
    let mask: Int64 := 0x00000000FFFFFFFF
    let lowOrder: Int64 := Int64(toInt32(data, offset)) & mask
    return lowOrder | Int64(toInt32(data, offset + 2) << 32)
end ;

function toUUID (data : [Character], offset : Integer) return UUID is
begin
    let leastSigBits: Int64 := toLong(data, offset)
    let mostSigBits: Int64 := toLong(data, offset + 4)
    return UUID(mostSigBits: mostSigBits, leastSigBits: leastSigBits)
end ;
