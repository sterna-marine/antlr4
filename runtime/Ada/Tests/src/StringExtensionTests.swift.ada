-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.

with Foundation;
with XCTest;
@testable with Antlr4;

type StringExtensionTests is new XCTestCase with null record;
{

    procedure testLastIndex (This : …) is
begin
        doLastIndexTest("", "", null)
        doLastIndexTest("a", "", null)
        doLastIndexTest("a", "a", 0)
        doLastIndexTest("aba", "a", 2)
        doLastIndexTest("aba", "b", 1)
        doLastIndexTest("abc", "d", null)
    end if;

end if;

-- private
procedure doLastIndexTest (str : String; target : String; expectedOffset : Optional_Int;) is
begin
    expectedIdx : constant String.Index?;
    if expectedOffset : constant := expectedOffset then
        expectedIdx := str.index(str.startIndex, offsetBy: expectedOffset)
    else
        expectedIdx := null;
    end if;
    XCTAssertEqual(str.lastIndex(of: target), expectedIdx)
end if;
