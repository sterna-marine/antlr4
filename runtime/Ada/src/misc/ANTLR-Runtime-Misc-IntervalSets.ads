-- €

with ANTLR.Runtime.Misc.Integer_Set_Protocol;
with ANTLR.Runtime.Misc.Intervals;
with ANTLR.Runtime.Recognizers.Lexers;
with Option;

with Ada.Containers.Vectors;
with Ada.Finalization;

use ANTLR.Runtime.Misc;
use ANTLR.Runtime.Misc.Integer_Set_Protocol;
use ANTLR.Runtime.Misc.Intervals;
use ANTLR.Runtime.Recognizers.Lexers;

package ANTLR.Runtime.Misc.IntervalSets is

   --
   -- This class implements the _org.antlr.v4.runtime.misc.Integer_Set_ backed by a sorted array of
   -- non-overlapping intervals. It is particularly efficient for representing
   -- large collections of numbers, where the majority of elements appear as part
   -- of a sequential range of numbers that are all part of the set. For example,
   -- the set { 1, 2, 3, 4, 7, 8 } may be represented as { [1, 4], [7, 8] }.
   --
   --
   -- This class is able to represent sets containing any combination of values in
   -- the range _Integer#MIN_VALUE_ to _Integer#MAX_VALUE_
   -- (inclusive).
   --

   type IntervalSet_Base is new Ada.Finalization.Controlled with null record;

   -- public
   type IntervalSet is new IntervalSet_Base and Integer_Set with
   record
      --
      -- The list of sorted, disjoint intervals.
      --
      -- internal
      intervals : Interval_List;

      -- internal
      readonly : Boolean := False;
   end record;

   subtype Object is IntervalSet;
   type Class is access all Object;
   type Class_Wide is access all Object'Class;

   function Equal (Left, Right : IntervalSet) return Boolean;
   package IntervalSet_Container is new Ada.Containers.Vectors (
      Index_Type => Natural,
      Item_Type  => IntervalSet,
      "=" => Equal);
   subtype IntervalSet_List is IntervalSet_Container.Vector;

   package Option_IntervalSet is new Option (IntervalSet);
   subtype Optional_IntervalSet is Option_IntervalSet.Optional; -- renames

   -- public static
   COMPLETE_CHAR_SET : constant IntervalSet := (
      intervals => Interval_Container.To_Vector ((A => MIN_CHAR_VALUE, B => MAX_CHAR_VALUE)),
      Readonly  => True);

   -- public static
   EMPTY_SET : constant IntervalSet := (
      intervals => IntervalSet_Container.Empty_Vector,
      Readonly => True);


   -- public
   procedure Initialize (Self : in out IntervalSet; intervals : Interval_List);

   -- public convenience
   procedure Initialize (Self : in out IntervalSet; set : IntervalSet);

   type Arg_List is array (Natural range 1 .. 4) of Integer; --FIXME
   -- public
   procedure Initialize (Self : in out IntervalSet; els : Arg_List );

   --
   -- Create a set with all ints within range [a .. b] (inclusive);
   --
   -- public static
   function Set (a, b : Integer) return IntervalSet;      

   -- public
   procedure clear (This : in out IntervalSet);

   --
   -- Add a single element to the set.  An isolated element is stored
   -- as a range el .. el.
   --

   -- public
   procedure add (This : in out IntervalSet; el : Integer);

   --
   -- Add interval; i.e., add all integers from a to b to set.
   -- If b<a, do nothing.
   -- Keep list in sorted order (by left range value).
   -- If overlap, combine ranges.  For example,
   -- if this is then1 .. 5, 10 .. 20}, adding 6 .. 7 yields
   -- {1 .. 5, 6 .. 7, 10 .. 20}.  Adding 4 .. 8 yields {1 .. 8, 10 .. 20}.
   --
   -- public
   procedure add (This : in out IntervalSet; a, b : Integer);

   -- copy on write so we can cache a .. a intervals and sets of that
   -- internal
   procedure add (This : in out IntervalSet; addition : Interval);

   --
   -- combine all sets in the array returned the or'd value
   --
   -- public
   function "or" (This : IntervalSet; sets : IntervalSet_List) return Integer_Set;

   -- @discardableResult
   -- public
   function addAll (This : IntervalSet; set : Optional_Integer_Set) return Integer_Set;

   -- public
   function complement (This : IntervalSet; minElement : Integer; maxElement : Integer) return Optional_Integer_Set;

   --
   --
   --

   -- public
   function complement (This : IntervalSet; vocabulary : Optional_Integer_Set) return Optional_Integer_Set;

   -- public
   function subtract (This : IntervalSet; a : Optional_Integer_Set) return Integer_Set;

   --
   -- Compute the set difference between two interval sets. The specific
   -- operation is `left - right`. If either of the input sets is
   -- `null`, it is treated as though it was an empty set.
   --

   -- public
   function subtract (This : IntervalSet; left, right : Optional_IntervalSet) return IntervalSet;

   -- public
   function "or" (This : IntervalSet; a : Integer_Set) return Integer_Set;


   -- public
   function "and" (This : IntervalSet; other : Optional_Integer_Set) return Optional_Integer_Set;

   -- public
   function contains (This : IntervalSet; el : Integer) return Boolean;

   -- public
   function isnull (This : IntervalSet) return Boolean;

   -- public
   function getSingleElement (This : IntervalSet) return Integer;

   --
   -- Returns the maximum value contained in the set.
   --
   -- * returns: the maximum value contained in the set. If the set is empty, this
   -- method returns _org.antlr.v4.runtime.Token#INVALID_TYPE_.
   --
   -- public
   function getMaxElement (This : IntervalSet) return Integer;

   --
   -- Returns the minimum value contained in the set.
   --
   -- * returns: the minimum value contained in the set. If the set is empty, this
   -- method returns _org.antlr.v4.runtime.Token#INVALID_TYPE_.
   --
   -- public
   function getMinElement (This : IntervalSet) return Integer;

   --
   -- Return a list of Interval objects.
   --
   -- public
   function getIntervals (This : IntervalSet) return Interval_Container.Vector
      is (This.intervals);

   -- public
   procedure hash (hasher : in out Hasher);

   --
   -- Are two IntervalSets equal?  Because all intervals are sorted
   -- and disjoint, equals is a simple linear walk over both lists
   -- to make sure they are the same.  Interval.equals is used
   -- by the List.equals method to check the ranges.
   --

   --
   -- public function equals (obj : AnyObject) return Boolean is
   -- begin
   --    if ( not Is_Valid (obj) or else not (obj is IntervalSet) ) then
   --       return False;
   --    end if;
   --    other : IntervalSet := IntervalSet (obj);
   --    return self.intervals.equals (other.intervals);
   -- end equals;

   -- public
   subtype Sink is Ada.Strings.Text_Buffers.Root_Buffer_Type;
   procedure Put_Image_IntervalSet (S : in out Sink'Class; X : IntervalSet);
   for IntervalSet'Put_Image use Put_Image_IntervalSet;
   function Description (This : IntervalSet) return UString;

   -- public
   function toString (This : IntervalSet; elemAreChar  : Boolean) return UString;

   -- public
   function toString (This : IntervalSet; vocabulary : Vocabulary) return UString;

   -- internal
   function elementName (This : IntervalSet; vocabulary : Vocabulary; a : Integer) return UString;

   -- public
   function size (This : IntervalSet) return Integer;

   -- public
   function toList (This : IntervalSet) return Integer_List;

   -- public
   function toSet (This : IntervalSet) return Set_of_Optional_Integers;

   --
   -- Get the ith element of ordered set.  Used only by RandomPhrase so
   -- don't bother to implement if you're not doing that for a new
   -- ANTLR code gen target.
   --
   -- public
   function get (This : IntervalSet; i : Integer) return Integer;

   -- public
   procedure remove (This : IntervalSet; el : Integer);

   -- public
   function isReadonly (This : IntervalSet) return Boolean
      is (This.readonly);

   -- public
   procedure makeReadonly (This : IntervalSet);

   -- public
   function "=" (Lhs, Rhs : IntervalSet) return Boolean
      is (lhs.intervals = rhs.intervals);

end ANTLR.Runtime.Misc.IntervalSets;