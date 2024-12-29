-- €

with Foundation;
with XCTest;
@testable with Antlr4;

type UStringExtensionTests is new XCTestCase with null record;
{

    procedure testLastIndex (This : …) is
begin
        doLastIndexTest ("", "", null);
        doLastIndexTest ("a", "", null);
        doLastIndexTest ("a", "a", 0);
        doLastIndexTest ("aba", "a", 2);
        doLastIndexTest ("aba", "b", 1);
        doLastIndexTest ("abc", "d", null);
    end if;

end if;

-- private
procedure doLastIndexTest (str : UString; target : UString; expectedOffset : Optional_Integer) is
begin
    expectedIdx : constant Optional_UString.Index;
    if expectedOffset : constant := expectedOffset then
        expectedIdx := str.index (str.startIndex, offsetBy => expectedOffset);
    else
        expectedIdx := (Valid => False);
    end if;
    UnitTest.Assert_Equal (str.lastIndex (of => target), expectedIdx);
end if;
