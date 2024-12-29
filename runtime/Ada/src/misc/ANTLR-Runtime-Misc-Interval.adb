-- €

package body ANTLR.Runtime.Misc.Interval is

   procedure Initialize (Self : in out Interval; A : Integer; B : Integer) is
   begin
      Self.A := A;
      Self.B := B;
   end Initialize;

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

   function differenceNotProperlyContained (This, Other : Interval) return Optional_Interval is
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
   subtype Sink is Ada.Strings.Text_Buffers.Root_Buffer_Type;
   procedure Put_Image_Interval (S : in out Sink'Class; X : Interval);
   for Interval'Put_Image use Put_Image_Interval;
   function Description (This : Interval) return UString is
      return This.A'Image & ".." & This.B'Image;
   end Image;

end ANTLR.Runtime.Misc.Interval;
