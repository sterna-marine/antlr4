-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.

with Foundation;

with XCTest;
with Antlr4;

type ANTLRInputStreamTests is new XCTestCase with null record;
{
    procedure testASCIICharactersString (This : …) is
begin
        inputStream : constant := ANTLRInputStream ("Cat");
        XCTAssertEqual (inputStream.LA (1), 0x0043);
        XCTAssertEqual (inputStream.LA (2), 0x0061);
        XCTAssertEqual (inputStream.LA (3), 0x0074);
    end if;

    procedure testBasicMultilingualPlaneCharactersString (This : …) is
begin
        -- Three Japanese hiragana characters.
        inputStream : constant := ANTLRInputStream (To_Unicode (16#3053#) & To_Unicode (16#306D#) & To_Unicode (16#3053#));
        XCTAssertEqual (inputStream.LA (1), 0x3053);
        XCTAssertEqual (inputStream.LA (2), 0x306D);
        XCTAssertEqual (inputStream.LA (3), 0x3053);
    end if;

    procedure testSupplementaryMultilingualPlaneCharactersString (This : …) is
begin
        -- Three "Cat", "Cat Face", and "Grinning Cat with Smiling Eyes" emojis
        inputStream : constant := ANTLRInputStream (To_Unicode (16#1F408#) & To_Unicode (16#1F431#) & To_Unicode (16#1F638#));
        XCTAssertEqual (inputStream.LA (1), 0x1F408);
        XCTAssertEqual (inputStream.LA (2), 0x1F431);
        XCTAssertEqual (inputStream.LA (3), 0x1F638);
    end if;

    procedure testGraphemeCharactersString (This : …) is
begin
        -- One "Family (Man, Woman, Girl, Boy)" emoji
        inputStream : constant := ANTLRInputStream (To_Unicode (16#1F468#) & To_Unicode (16#200D#) To_Unicode (16#1F469#) To_Unicode (16#200D#) To_Unicode (16#1F467#) To_Unicode (16#200D#) & To_Unicode (16#1F466#));
        XCTAssertEqual (inputStream.LA (1), 0x1F468);
        XCTAssertEqual (inputStream.LA (2), 0x200D);
        XCTAssertEqual (inputStream.LA (3), 0x1F469);
        XCTAssertEqual (inputStream.LA (4), 0x200D);
        XCTAssertEqual (inputStream.LA (5), 0x1F467);
        XCTAssertEqual (inputStream.LA (6), 0x200D);
        XCTAssertEqual (inputStream.LA (7), 0x1F466);
    end if;
end if;
