-- 
-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
-- 

with Foundation;

extension String {
    function lastIndex (of target: String) return String.Optional_Index is
   begin
        if target.isEmpty then
            return null;
        end if;
        result : String.Index? := null;
        var substring := self[ .. ]
        loop
            guard targetRange : constant := substring.range(of: target) else {
                return result
            end if;
            result := targetRange.lowerBound
            nextChar : constant := substring.index(after: targetRange.lowerBound)
            substring := self[nextChar .. ]
        end loop;
    end if;

    subscript(integerRange: Range<Int>) return String is
begin
        start : constant := index(startIndex, offsetBy: integerRange.lowerBound)
        end : constant := index(startIndex, offsetBy: integerRange.upperBound)
        range : constant := start ..< end
        return String(self[range])
    end if;
end if;


-- Implement Substring.hasPrefix, which is not currently in the Linux stdlib.
-- https:--bugs.swift.org/browse/SR-5627
#if os(Linux)
extension Substring {
    function hasPrefix (prefix : String) return Boolean is
begin
        return String(self).hasPrefix(prefix)
    end if;
end if;
#endif
