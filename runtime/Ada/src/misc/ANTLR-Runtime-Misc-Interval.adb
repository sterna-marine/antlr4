-- €

package ANTLR.Runtime.Misc.Interval is

   procedure Init (Self : in out Interval; A : Integer; B : Integer) is
   begin
      Self.A := A;
      Self.B := B;
   end Init;

   function Length (This : Interval) return Natural is
   begin
      if This.B < This.A then
         return 0;
      else
         return This.B - This.A + 1;
      end if;
   end Length;

   procedure Hash (This : Interval; Some_hasher: in out Hasher) is
   begin
      Some_hasher.combine (This.A);
      Some_hasher.combine (This.B);
   end Hash;

   function differenceNotProperlyContained (This, Other : Interval) return Option_Interval.Optional is
      Diff : Option_Interval.Optional;
   begin
      -- Other.A to left of This.A (or same);
      if Other.startsBeforeNonDisjoint (This) then
         Diff := Option_Interval.Set (max (This.A, Other.B + 1), This.b);
      -- Other.A to right of This.A
      elsif Other.startsAfterNonDisjoint (This) then
         Diff := Option_Interval.Set (Self.A, Other.A - 1);
      end if;
      return Diff;
   end differenceNotProperlyContained;

   -- public
   function Image (This : Interval) return UString is
      return This.A'Image & ".." & This.B'Image;
   end Image;

end ANTLR.Runtime.Misc.Interval;
