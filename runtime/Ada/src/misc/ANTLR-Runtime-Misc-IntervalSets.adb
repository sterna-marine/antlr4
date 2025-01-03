-- €

package body ANTLR.Runtime.Misc.IntervalSets is

   function Equal (Left, Right : IntervalSet) return Boolean is
   begin
      return Left = Right; --TOFIX
   end Equal;

   procedure Initialize (Self : in out IntervalSet; intervals : Interval_List) is
   begin
      self.intervals := intervals;
   end Initialize;

   procedure Initialize (Self : in out IntervalSet; set : IntervalSet) is
   begin
      Self.Initialize;
      Self.addAll (set); -- try!
   end Initialize;

   procedure Initialize (Self : in out IntervalSet; els : array (<>) of Integer) is --TOFIX
   begin
      Self.intervals := Interval_Container.Empty_Vector;
      if els'Length > 0 then
         for i in els loop
            Self.intervals.add (els (i)); -- try  --TOFIX
         end loop;
      end if;
   end Initialize;

   function Set (a, b : Integer) return IntervalSet is
   begin
      return s : IntervalSet do
         s.add (a, b); -- try!
      end return;
   end Set;

   procedure clear (This : in out IntervalSet) is
   begin
      if This.readonly then
         raise ANTLRError.illegalState with "can't alter readonly IntervalSet";
      end if;
      This.intervals.Clear;
   end clear;

   procedure add (This : in out IntervalSet; el : Integer) is
   begin
      if This.readonly then
         raise ANTLRError.illegalState with "can't alter readonly IntervalSet";
      end if;
      This.add (el, el); -- try!
   end add;

   procedure add (This : in out IntervalSet; a, b : Integer) is
   begin
      This.add (This.Set (a, b));
   end add;

   procedure add (This : in out IntervalSet; addition : Interval) is
   begin
      if This.readonly then
         raise ANTLRError.illegalState with "can't alter readonly IntervalSet";
      end if;
      if addition.b < addition.a then
         return; --TOFIX raise ???
      end if;

      -- find position in list
      -- Use iterators as we modify list in place
      while i in 0 .. This.intervals.Length - 1 loop

         r : constant := This.intervals.Element (i);
         if addition = r then
               return;
         end if;
         if addition.adjacent (r) or else not addition.disjoint (r) then
            -- next to each other, make a single larger interval
            bigger : constant := addition.union (r);
            --iter.set (bigger);
            This.intervals.Insert (Key => i, New_Item => bigger);
            -- make sure we didn't just create an interval that
            -- should be merged with next interval in list
            while i < This.intervals.Length - 1 loop
               i := @ + 1;
               next : constant := This.intervals.Element (i);
               exit when not bigger.adjacent (next) and then bigger.disjoint (next);

               -- if we bump up against or overlap next, merge
               --
               -- iter.remove ();   -- remove this one
               -- iter.previous (); -- move backwards to what we just set
               -- iter.set (bigger.union (next)); -- set to 3 merged ones
               -- iter.next (); -- first call to next after previous duplicates the resul
               --
               This.intervals.delete (Index => i);
               i := @ - 1;
               This.intervals.Insert (Key => i, New_Item => bigger.union (next));
            end loop;
            return;
         end if;
         if addition.startsBeforeDisjoint (r) then
            -- insert before r
            This.intervals.insert (addition, Index => i);
            return;
         end if;
         -- if disjoint and after r, a future iteration will handle it
         i := @ + 1;
      end loop;
      -- ok, must be after last interval (and disjoint from last interval);
      -- just add it
      This.intervals.append (addition);
   end add;

   function "or" (This : in out IntervalSet; sets : IntervalSet_List) return Integer_Set is
      r : constant IntervalSet;
   begin
      for s of sets loop
         r.addAll (s); -- try!
      end loop;
      return r;
   end "or";

   function addAll (This : in out IntervalSet; set : Optional_Integer_Set) return IntervalSet is
   begin
      if not Is_Valid (set) then
         return This;
      else
         other : constant Optional_IntervalSet := Maybe (set); --TOFIX IntervalSet (Set)
         if Is_Valid (other) then
            -- walk set and add each interval
            for interval of other.intervals loop
               This.add (interval);
            end loop;
         else
            setList : constant := set.toList;
            for value of setList loop
               This.add (value); --TOFIX
            end loop;
         end if;
         return This;
      end if;
   end addAll;

   function complement (This : in out IntervalSet; minElement : Integer; maxElement : Integer) return Optional_Integer_Set
      is (complement (IntervalSet.Set (minElement, maxElement)));

   function complement (This : in out IntervalSet; vocabulary : Optional_Integer_Set) return Optional_Integer_Set is
   begin
      if not Is_Valid (vocabulary) or vocabulary.isnull () then
         return (Valid => False);  -- nothing in common with null set
      end if;
      vocabularyIS : IntervalSet;
      vocabulary : constant Optional_IntervalSet := Maybe (vocabulary);
      if Is_Valid (vocabulary) then
         vocabularyIS := vocabulary;
      else
         vocabularyIS := IntervalSet ();
         vocabularyIS.addAll (vocabulary); -- try!
      end if;

      return vocabularyIS.subtract (self);
   end complement;

   function subtract (This : in out IntervalSet; a : Optional_Integer_Set) return Integer_Set is
   begin
      if not Is_Valid (a) or a.isnull () then
         return IntervalSet (self);
      end if;
      a : constant Optional_IntervalSet := Maybe (a);
      if Is_Valid (a) then
         return subtract (self, a);
      end if;

      other : constant := IntervalSet ();
      other.addAll (a); -- try!
      return subtract (self, other);
   end subtract;

   function subtract (This : in out IntervalSet; left, right : Optional_IntervalSet) return IntervalSet is
   begin
      if not Is_Valid (left) or left.isnull () then
         return IntervalSet ();
      end if;

      result : constant := IntervalSet (left);

      if not Is_Valid (right) or right.isnull () then
         -- right set has no elements; just return the copy of the current set
         return result;
      end if;
      resultI := 0;
      rightI := 0;
      while resultI < result.intervals.count and then rightI < right.intervals.count loop
         resultInterval : constant := result.intervals.Element (resultI);
         rightInterval : constant := right.intervals.Element (rightI);

         -- operation: (resultInterval - rightInterval) and update indexes

         if rightInterval.b < resultInterval.a then
            rightI := @ + 1;
            goto CONTINUE;
         end if;

         if rightInterval.a > resultInterval.b then
            resultI := @ + 1;
            goto CONTINUE;
         end if;

         beforeCurrent : Optional_Interval; := (Valid => False);
         afterCurrent : Optional_Interval; := (Valid => False);
         if rightInterval.a > resultInterval.a then
            beforeCurrent := Interval (resultInterval.a, rightInterval.a - 1);
         end if;

         if rightInterval.b < resultInterval.b then
            afterCurrent := Interval (rightInterval.b + 1, resultInterval.b);
         end if;

         if beforeCurrent : constant := beforeCurrent then
            if afterCurrent : constant := afterCurrent then
               -- split the current interval into two
               result.intervals.Insert (Key => resultI, New_Item => beforeCurrent);
               result.intervals.insert (afterCurrent, Index => resultI + 1);
               resultI := @ + 1;
               rightI := @ + 1;
               goto CONTINUE;
            else
               -- replace the current interval
               result.intervals.Insert (Key => resultI, New_Item => beforeCurrent);
               resultI := @ + 1;
               goto CONTINUE;
            end if;
         else
            if afterCurrent : constant := afterCurrent then
               -- replace the current interval
               result.intervals.Insert (Key => resultI, New_Item => afterCurrent);
               rightI := @ + 1;
               goto CONTINUE;
            else
               -- remove the current interval (thus no need to increment resultI);
               result.intervals.remove (at => resultI);
               --result.intervals.remove (resultI);
               goto CONTINUE;
            end if;
         end if;
         <<CONTINUE>>
      end loop;
      -- If rightI reached right.intervals.size (), no more intervals to subtract from result.
      -- If resultI reached result.intervals.size (), we would be subtracting from an empty set.
      -- Either way, we are done.
      return result
   end subtract;

   function "or" (This : in out IntervalSet; a : Integer_Set) return Integer_Set is
      o : constant IntervalSet;
   begin
      o.addAll (This); -- try!
      o.addAll (a); -- try!
      return o;
   end "or";

   function "and" (This : in out IntervalSet; other : Optional_Integer_Set) return Optional_Integer_Set is
   begin
      if not Is_Valid (other) then
         return (Valid => False);  -- nothing in common with null set
      end if;

      myIntervals : constant := self.intervals
      theirIntervals : constant IntervalSet := IntervalSet ((other)).intervals
      intersection : Optional_IntervalSet; := (Valid => False);
      mySize : constant := myIntervals.count
      theirSize : constant := theirIntervals.count
      i := 0
      j := 0
      -- iterate down both interval lists looking for nondisjoint intervals
      while i < mySize and then j < theirSize loop
         mine : constant := myIntervals.Element (i);
         theirs : constant := theirIntervals.Element (j);

         if mine.startsBeforeDisjoint (theirs) then
            -- move this iterator looking for interval that might overlap
            i := @ + 1;
         else
            if theirs.startsBeforeDisjoint (mine) then
               -- move other iterator looking for interval that might overlap
               j := @ + 1;
            else
               if mine.properlyContains (theirs) then
                  -- overlap, add intersection, get next theirs
                  if not Is_Valid (intersection) then
                     intersection := IntervalSet ();
                  end if;

                  intersection!.add (mine.intersection (theirs)); -- try!
                  j := @ + 1;
               else
                  if theirs.properlyContains (mine) then
                     -- overlap, add intersection, get next mine
                     if not Is_Valid (intersection) then
                        intersection := IntervalSet ();
                     end if;
                     intersection!.add (mine.intersection (theirs)); -- try!
                     i := @ + 1;
                  else
                     if not mine.disjoint (theirs) then
                        -- overlap, add intersection
                        if not Is_Valid (intersection) then
                           intersection := IntervalSet ();
                        end if;
                        intersection!.add (mine.intersection (theirs)); -- try!
                        -- Move the iterator of lower range [a .. b], but not
                        -- the upper range as it may contain elements that will collide
                        -- with the next iterator. So, if mine=[0 .. 115] and
                        -- theirs=[115 .. 200], then intersection is 115 and move mine
                        -- but not theirs as theirs may collide with the next range
                        -- in thisIter.
                        -- move both iterators to next ranges
                        if mine.startsAfterNonDisjoint (theirs) then
                           j := @ + 1;
                        else
                           if theirs.startsAfterNonDisjoint (mine) then
                              i := @ + 1;
                           end if;
                        end if;
                     end if;
                  end if;
               end if;
            end if;
         end if;
      end loop;
      if not Is_Valid (intersection) then
         return IntervalSet ();
      else
         return intersection;
      end if;
   end "and";

   function contains (This : in out IntervalSet; el : Integer) return Boolean is
   begin
      for interval of This.intervals loop
         exit when el < interval.a; -- list is sorted and el is before this interval; not here
         if el >= interval.a and then el <= interval.b then
            return True;  -- found in this interval
         end if;
      end loop;
      return False;
   end contains;

   function isnull (This : IntervalSet) return Boolean is
   begin
      return This.intervals.isEmpty;
   end isnull;

   function getSingleElement (This : IntervalSet) return Integer is
   begin
      if This.intervals.Length = 1 then
         interval : constant := This.intervals.Element (0);
         if interval.a = interval.b then
               return interval.a;
         end if;
      end if;
      return INVALID_TYPE;
   end getSingleElement;

   function getMaxElement (This : IntervalSet) return Integer is
   begin
      if This.isnull then
         return INVALID_TYPE;
      else
         last : constant := This.intervals.Element (This.intervals.Length - 1);
         return last.b;
      end if;
   end getMaxElement;

   function getMinElement (This : IntervalSet) return Integer is
   begin
      if This.isnull then
         return CommonToken.INVALID_TYPE;
      else
         return This.intervals.Element (0).a
      end if;
   end getMinElement;

   function getIntervals (This : IntervalSet) return Interval_List
      is (This.intervals);

   procedure hash (hasher: in out Hasher) is
   begin
      for interval of This.intervals loop
         hasher.combine (interval.a);
         hasher.combine (interval.b);
      end loop;
   end hash;

   function Description (This : IntervalSet) return UString
      is (toString (False));

   function toString (This : in out IntervalSet; elemAreChar  : Boolean) return UString is
   begin
      if This.intervals.isEmpty then
         return "{}";
      end if;

      selfSize : constant Natural := This.Size;

      buf : UString := "";

      if selfSize > 1 then
         buf := @ & "{";
      end if;
      first := True;
      for interval in intervals loop
         if not first then
            buf := @ & ", ";
         end if;
         first := False;

         if interval.A = interval.B then
            if interval.A = EOF then
               buf := @ & "<EOF>";
            elsif elemAreChar then
               buf := @ & "'" & interval.A'Image & "'";
            else
               buf := @ & "" & interval.A'Image & "";
            end if;
         end if;
         elsif elemAreChar then
            buf := @ & "'" & interval.A'Image & "'..'" & interval.B'Image & "'";
         else
            buf := @ & interval.A'Image & ".." & interval.B'Image;
         end if;
      end loop;

      if selfSize > 1 then
         buf := @ & "}";
      end if;

      return buf;
   end toString;

   function toString (This : in out IntervalSet; vocabulary : Vocabulary) return UString is
      selfSize : constant Natural := This.Size;
      buf : UString := "";
      first : Boolean := True;
   begin
      if This.intervals.isEmpty then
         return "{}";
      end if;

      if selfSize > 1 then
         buf := @ & "{";
      end if;

      for interval of This.intervals loop
         if not first then
            buf := @ & ", ";
         end if;
         first := False;

         if interval.a = interval.b then
            buf := @ + elementName (vocabulary, interval.a);
         else
            for i in interval.a .. interval.b loop
               if i > interval.a then
                  buf := @ & ", ";
               end if;
               buf := @ & elementName (vocabulary, i);
            end loop;
         end if;
      end loop;

      if selfSize > 1 then
         buf := @ & "}";
      end if;

      return buf;
   end toString;

   function elementName (This : in out IntervalSet; vocabulary : Vocabulary; a : Integer) return UString is
   begin
      if a = EOF then
         return "<EOF>";
      elsif a = EPSILON then
         return "<EPSILON>"
      else
         return vocabulary.getDisplayName (a);
      end if;
   end elementName;

   function size (This : IntervalSet) return Natural is
   begin
      n := 0
      for interval of This.intervals loop
         n := @ + (interval.b - interval.a + 1);
      end loop;
      return n;
   end size;

   function toList (This : IntervalSet) return Integer_List is
      values : Integer_List; -- := Integer_Container.Empty_Vector;
   begin
      for interval of This.intervals loop
         values.append (contentsOf => interval.a .. interval.b);
      end loop;
      return values;
   end toList;

   function toSet (This : IntervalSet) return Set_of_Optional_Integers is
   begin
      s := Set_of_Optional_Integers ();
      for interval in This.intervals loop
         for v in interval.a .. interval.b  loop
            s.insert (v);
         end loop;
      end loop;
      return s
   end toSet;

   function get (This : in out IntervalSet; i : Integer) return Integer is
      index : integer := 0;
   begin
      for interval of intervals loop
         for v in interval.a .. interval.b  loop
            if index = i then
               return v;
            end if;
            index := @ + 1;
         end loop;
      end loop;
      return -1;
   end get;

   procedure remove (This : in out IntervalSet; el : Integer) is
   begin
      if readonly then
         raise ANTLRError.illegalState with "can't alter readonly IntervalSet";
      end if;

      idx := intervals.startIndex;
      while idx < This.intervals.endIndex loop
         interval : Interval_T;

         function get (intervals : array (<>) of interval_T) return Interval_T
            is (intervals.Element (idx));

         procedure set (intervals : in out array (<>) of interval; newValue : Interval_T) is
         begin
            intervals.Insert (Key => idx, New_Item => newValue);
         end set;

         exit when el < interval.a;  -- list is sorted and el is before this interval; not here

         -- if whole interval x .. x, rm
         if el = interval.a and then el = interval.b then
            intervals.remove (Index => idx);
            exit;
         end if;
         -- if on left edge x .. b, adjust left
         if el = interval.a then
            interval.a := @ + 1;
            exit;
         end if;
         -- if on right edge a .. x, adjust right
         if el = interval.b then
            interval.b := @ - 1;
            exit;
         end if;
         -- if in middle a .. x..b, split interval
         if el > interval.a and then el < interval.b then
            -- found in this interval
            oldb : constant := interval.b
            interval.b := el - 1      -- [a .. x-1]
            This.add (el + 1, oldb); -- add [x+1 .. b]
         end if;
      end loop;
      defer :
         begin
            intervals.formIndex (after => idx);
         end defer;
   end remove;

   -- public
   function isReadonly (This : IntervalSet) return Boolean
      is (This.readonly);

   -- public
   procedure makeReadonly (This : IntervalSet) is
   begin
      This.readonly := True;
   end makeReadonly;

   -- public
   function "=" (Lhs, Rhs : IntervalSet) return Boolean
      is (lhs.intervals = rhs.intervals);

end ANTLR.Runtime.Misc.IntervalSets;