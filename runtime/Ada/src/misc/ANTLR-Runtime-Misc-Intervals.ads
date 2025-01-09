-- €

with Ada.Strings;

package ANTLR.Runtime.Misc.Intervals is

   --
   -- An immutable inclusive interval a .. b
   --

   -- public
   type Interval is record -- and Hashable
      -- public
      A : Integer;
      -- public
      B : Integer;
   end record;

   package Option_Interval is new Option (Interval);
   subtype Optional_Interval is Option_Interval.Optional; -- renames

   function "=" (Left, Right : Interval) return Boolean;
   package Interval_Container is new Ada.Containers.Vectors (
      Index_Type => Natural,
      Element_Type => Interval,
      "=" => "=");
   subtype Interval_List is Interval_Container.Vector;

   -- public static
   Invalid : constant Interval := (-1, -2);

   -- public
   procedure Initialize (Self : in out Interval; A : Integer; B : Integer);

   --
   -- Interval objects are used readonly so share all with the
   -- same single value a = b up to some max size.  Use an array as a perfect hash.
   -- Return shared object for 0 .. INTERVAL_POOL_MAX_VALUE or a new
   -- Interval object with a .. a in it.  On Java.g4, 218623 IntervalSets
   -- have a .. a (set with 1 element).
   --
   -- public static
   function set (A : Integer; B : Integer) return Interval is (A, B);

   --
   -- return number of elements between a and b inclusively. x .. x is length 1.
   -- if b < a, then length is 0.  9 .. 10 has length 2.
   --
   -- public
   function Length (This : Interval) return Natural;

   -- public
   procedure Hash (This : Interval; Some_hasher: in out Hasher);

   --
   -- Does this start completely before other? Disjoint
   --
   -- public
   function startsBeforeDisjoint (This, Other : Interval) return Boolean
      is (This.A < Other.A and then Self.B < Other.A);

   --
   -- Does this start at or before other? Nondisjoint
   --
   -- public
   function startsBeforeNonDisjoint (This, Other : Interval) return Boolean
      is (This.A <= Other.A and then This.B >= Other.A);

   --
   -- Does this.a start after other.b? May or may not be disjoint
   --
   -- public
   function startsAfter (This, Other : Interval) return Boolean
      is (This.A > Other.A);

   --
   -- Does this start completely after other? Disjoint
   --
   -- public
   function startsAfterDisjoint (This, Other : Interval) return Boolean
      is (This.A > Other.B);

   --
   -- Does this start after other? NonDisjoint
   --
   -- public
   function startsAfterNonDisjoint (This, Other : Interval) return Boolean
      is (This.A > Other.A and then This.A <= Other.B); -- This.B >= Other.B implied

   --
   -- Are both ranges disjoint? I.e., no overlap?
   --
   -- public
   function disjoint (This, Other : Interval) return Boolean
      is (startsBeforeDisjoint (This, Other) or else startsAfterDisjoint (This, Other));

   --
   -- Are two intervals adjacent such as 0 .. 41 and 42 .. 42?
   --
   -- public
   function adjacent (This, Other : Interval) return Boolean
      is (This.A = Other.B + 1 or else This.B = Other.A - 1);

   -- public
   function properlyContains (This, Other : Interval) return Boolean
      is (Other.A >= This.A and then Other.B <= This.B);

   --
   -- Return the interval computed from combining this and other
   --
   -- public
   function union (This, Other : Interval) return Interval
      is (min (This.A, Other.A), max (This.B, Other.B));

   --
   -- Return the interval in common between this and o
   --
   -- public
   function intersection (This, Other : Interval) return Interval
      is (max (This.A, Other.A), min (This.B, Other.B));

   --
   -- Return the interval with elements from this not in other;
   -- other must not be totally enclosed (properly contained);
   -- within this, which would result in two disjoint intervals
   -- instead of the single one returned by this method.
   --
   -- public
   function differenceNotProperlyContained (This, Other : Interval) return Optional_Interval;

   subtype Sink is Ada.Strings.Text_Buffers.Root_Buffer_Type;
   procedure Put_Image_Interval (S : in out Sink'Class; X : Interval);
   for Interval'Put_Image use Put_Image_Interval;
   -- public
   function Description (This : Interval) return UString
       is (This.A'Image & " .. " & This.B'Image);

   -- public
   function "=" (Lhs, Rhs : Interval) return Boolean
      is (Lhs.A = Rhs.A and then Lhs.B = Rhs.B);

end ANTLR.Runtime.Misc.Intervals;
