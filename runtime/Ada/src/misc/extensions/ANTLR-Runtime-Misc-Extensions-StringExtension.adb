-- €

with Foundation;

extension UString {
    function lastIndex (of target => UString) return UString.Optional_Index is
   begin
        if target.Is_Empty then
            return (Valid => False);
        end if;
        result : UString.Index? := (Valid => False);
        substring := self[ .. ]
        loop
            targetRange : constant := substring.range (of => target);
            if not Is_Valid (targetRange) then
                return result;
            end if;
            result := targetRange.lowerBound
            nextChar : constant := substring.index (after => targetRange.lowerBound);
            substring := self[nextChar .. ]
        end loop;
    end if;

    subscript (integerRange => Range<Int>) return UString is
begin
        start : constant := index (startIndex, offsetBy => integerRange.lowerBound);
        end : constant := index (startIndex, offsetBy => integerRange.upperBound);
        range : constant := start .. end - 1
        return UString (self.Element (range));
    end if;
end if;


-- Implement Substring.hasPrefix, which is not currently in the Linux stdlib.
-- https:--bugs.swift.org/browse/SR-5627
#if os (Linux);
extension Substring {
    function hasPrefix (prefix : UString) return Boolean is
begin
        return UString (self).hasPrefix (prefix);
    end if;
end if;
#endif
