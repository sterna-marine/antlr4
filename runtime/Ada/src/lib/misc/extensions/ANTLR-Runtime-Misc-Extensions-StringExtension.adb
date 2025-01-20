-- €

package ANTLR.Runtime.Misc.Extensions.StringExtension is

   use ANTLR.Runtime;

   -- extension UString
   function lastIndex (This : UString; target => UString) return UString.Optional_Index is
   begin
      if target.Is_Empty then
         return (Valid => False);
      end if;
      result : UString.Index? := (Valid => False);
      substring := This ( .. 'Last);
      loop
         targetRange : constant := substring.range (of => target);
         if not Is_Valid (targetRange) then
               return result;
         end if;
         result := targetRange.lowerBound;
         nextChar : constant := substring.index (after => targetRange.lowerBound);
         substring := This (nextChar .. 'Last);
      end loop;
   end lastIndex;

   function subscript (integerRange => Range<Int>) return UString is
      start : constant := index (startIndex, offsetBy => integerRange.lowerBound);
      end : constant := index (startIndex, offsetBy => integerRange.upperBound);
      range : constant := start .. end - 1;
   begin
      return UString (self.Element (range));
   end subscript;


   -- Implement Substring.hasPrefix, which is not currently in the Linux stdlib.
   -- https:--bugs.swift.org/browse/SR-5627
   -- #if os (Linux);
   -- extension Substring
   function hasPrefix (This : UString; prefix : UString) return Boolean is
   begin
         return UString (This).hasPrefix (prefix);
   end hasPrefix;
   -- #endif

end ANTLR.Runtime.Misc.Extensions-StringExtension;