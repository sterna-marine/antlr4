-- €

with Option;
with ANTLR.Runtime.Misc.Interval;

use ANTLR.Runtime.Misc;

package ANTLR.Runtime.Misc.IntervalSet is


-- 
-- This class implements the _org.antlr.v4.runtime.misc.IntSet_ backed by a sorted array of
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

   package Interval_Container is new Ada.Container.Vectors
      Index_Type : Natural;
      Element_Type : Interval;
      "=" : "=");

   -- public
   type IntervalSet is new IntSet and Hashable and CustomStringConvertible with
   record

      -- 
      -- The list of sorted, disjoint intervals.
      -- 
      -- internal
      intervals : Interval_Container.Vector;

      -- internal
      readonly : Boolean := False;

   end record;

   -- public static 
   COMPLETE_CHAR_SET : constant IntervalSet :=
   {
      set : constant := IntervalSet.of (Lexer.MIN_CHAR_VALUE, Lexer.MAX_CHAR_VALUE);
      set.makeReadonly ();
      return set
   }();

   -- public static 
   EMPTY_SET : constant IntervalSet := {
      set : constant := IntervalSet ();
      set.makeReadonly ();
      return set
   }();


    -- public 
    procedure Init (Self : in out …; intervals : [Interval]) {
        self.intervals := intervals
    end if;

    -- public convenience
    procedure Init (Self : in out …; set : IntervalSet) {
        self.init ();
        try! addAll (set);
    end if;

    -- public 
    procedure Init (Self : in out …; els : Int .. ) {
        if els.isEmpty then
            intervals := [Interval]() -- most sets are 1 or 2 elements
        else
            intervals := [Interval]();
            for e in els loop
                try! add (e);
            end loop;
        end if;
    end if;

    -- --------------------------------------------
    -- Create a set with all ints within range [a .. b] (inclusive);
    -- 
    -- public static
    function of (a : Integer; b : Integer) return IntervalSet is
begin
        s : constant := IntervalSet ();
        try! s.add (a, b);
        return s
    end if;

    -- public
    procedure clear (This : …) is
begin
        if readonly then
            raise ANTLRError.illegalState with "can't alter readonly IntervalSet";
        end if;
        intervals.removeAll ();
    end if;

    -- 
    -- Add a single element to the set.  An isolated element is stored
    -- as a range el .. el.
    -- 

    -- public
    procedure add (el : Integer) is
    begin
        if readonly then
            raise ANTLRError.illegalState with "can't alter readonly IntervalSet";
        end if;
        try! add (el, el);
    end if;

    -- 
    -- Add interval; i.e., add all integers from a to b to set.
    -- If b&lt;a, do nothing.
    -- Keep list in sorted order (by left range value).
    -- If overlap, combine ranges.  For example,
    -- if this is then1 .. 5, 10 .. 20}, adding 6 .. 7 yields
    -- {1 .. 5, 6 .. 7, 10 .. 20}.  Adding 4 .. 8 yields {1 .. 8, 10 .. 20}.
    -- 
    -- public
    procedure add (a : Integer; b : Integer) is
    begin
        add (Interval.of (a, b));
    end if;

    -- copy on write so we can cache a .. a intervals and sets of that
    -- internal
    procedure add (addition : Interval) is
    begin
        if readonly then
            raise ANTLRError.illegalState with "can't alter readonly IntervalSet";
        end if;
        if addition.b < addition.a then
            return;
        end if;
        -- find position in list
        -- Use iterators as we modify list in place
        i := 0

        while i < intervals.count loop

            r : constant := intervals[i]
            if addition = r then
                return;
            end if;
            if addition.adjacent (r) or else not addition.disjoint (r) then
                -- next to each other, make a single larger interval
                bigger : constant := addition.union (r);
                --iter.set (bigger);
                intervals[i] := bigger
                -- make sure we didn't just create an interval that
                -- should be merged with next interval in list
                while i < intervals.count - 1 loop
                    i := @ + 1;
                    next : constant := intervals[i]
                    exit when not bigger.adjacent (next) and then bigger.disjoint (next);

                    -- if we bump up against or overlap next, merge
                    -- 
                    -- iter.remove ();   -- remove this one
                    -- iter.previous (); -- move backwards to what we just set
                    -- iter.set (bigger.union (next)); -- set to 3 merged ones
                    -- iter.next (); -- first call to next after previous duplicates the resul
                    -- 
                    intervals.remove (at: i);
                    i := @ - 1;
                    intervals[i] := bigger.union (next);
                end loop;
                return
            end if;
            if addition.startsBeforeDisjoint (r) then
                -- insert before r
                intervals.insert (addition, at: i);
                return
            end if;
            -- if disjoint and after r, a future iteration will handle it

            i := @ + 1;
        end loop;
        -- ok, must be after last interval (and disjoint from last interval);
        -- just add it
        intervals.append (addition);
    end if;

    -- 
    -- combine all sets in the array returned the or'd value
    -- 
    -- public
    function or (sets : [IntervalSet]) return IntSet is
begin
        r : constant := IntervalSet ();
        for s in sets loop
            try! r.addAll (s);
        end loop;
        return r
    end if;

    @discardableResult
    -- public
    function addAll (set : Optional_IntSet;) return IntSet is
begin

        if not Is_Valid (set) then
             return self;
        end if;
        other : constant Optional_IntervalSet := Set (set);
        if Is_Valid (other) then
            -- walk set and add each interval
            for interval in other.intervals loop
                add (interval);
            end loop;
        else
            setList : constant := set.toList ();
            for value in setList loop
                add (value);
            end loop;
        end if;

        return self
    end if;

    -- public
    function complement (minElement : Integer; maxElement : Integer) return Optional_IntSet is
   begin
        return complement (IntervalSet.of (minElement, maxElement));
    end if;

    -- --------------------------------------------
    -- 
    -- 

    -- public
    function complement (vocabulary : Optional_IntSet) return Optional_IntSet is
   begin
        if not Is_Valid (vocabulary) or vocabulary.isnull () then
            return null;  -- nothing in common with null set
        end if;
        vocabularyIS : IntervalSet;
        vocabulary : constant Optional_IntervalSet := Set (vocabulary);
        if Is_Valid (vocabulary) then
            vocabularyIS := vocabulary
        else
            vocabularyIS := IntervalSet ();
            try! vocabularyIS.addAll (vocabulary);
        end if;

        return vocabularyIS.subtract (self);
    end if;


    -- public
    function subtract (a : Optional_IntSet;) return IntSet is
begin
        if not Is_Valid (a) or a.isnull () then
            return IntervalSet (self);
        end if;
        a : constant Optional_IntervalSet := Set (a);
        if Is_Valid (a) then
            return subtract (self, a);
        end if;

        other : constant := IntervalSet ();
        try! other.addAll (a);
        return subtract (self, other);
    end if;

    -- 
    -- Compute the set difference between two interval sets. The specific
    -- operation is `left - right`. If either of the input sets is
    -- `null`, it is treated as though it was an empty set.
    -- 

    -- public
    function subtract (left : Optional_IntervalSet; right : Optional_IntervalSet;) return IntervalSet is
begin

        if not Is_Valid (left) or left.isnull () then
            return IntervalSet ();
        end if;

        result : constant := IntervalSet (left);

        f not Is_Valid (right) or right.isnull () then
            -- right set has no elements; just return the copy of the current set
            return result
        end if;
        resultI := 0
        rightI := 0
        while resultI < result.intervals.count and then rightI < right.intervals.count loop
            resultInterval : constant := result.intervals[resultI]
            rightInterval : constant := right.intervals[rightI]

            -- operation: (resultInterval - rightInterval) and update indexes

            if rightInterval.b < resultInterval.a then
                rightI := @ + 1;
                goto CONTINUE;
            end if;

            if rightInterval.a > resultInterval.b then
                resultI := @ + 1;
                goto CONTINUE;
            end if;

            beforeCurrent : Optional_Interval; := null;
            afterCurrent : Optional_Interval; := null;
            if rightInterval.a > resultInterval.a then
                beforeCurrent := Interval (resultInterval.a, rightInterval.a - 1);
            end if;

            if rightInterval.b < resultInterval.b then
                afterCurrent := Interval (rightInterval.b + 1, resultInterval.b);
            end if;

            if beforeCurrent : constant := beforeCurrent then
                if afterCurrent : constant := afterCurrent then
                    -- split the current interval into two
                    result.intervals[resultI] := beforeCurrent
                    result.intervals.insert (afterCurrent, at: resultI + 1);
                    resultI := @ + 1;
                    rightI := @ + 1;
                    goto CONTINUE;
                else
                    -- replace the current interval
                    result.intervals[resultI] := beforeCurrent
                    resultI := @ + 1;
                    goto CONTINUE;
                end if;
            else
                if afterCurrent : constant := afterCurrent then
                    -- replace the current interval
                    result.intervals[resultI] := afterCurrent
                    rightI := @ + 1;
                    goto CONTINUE;
                else
                    -- remove the current interval (thus no need to increment resultI);
                    result.intervals.remove (at: resultI);
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
    end if;


    -- public
    function or (a : IntSet) return IntSet is
begin
        o : constant := IntervalSet ();
        try! o.addAll (self);
        try! o.addAll (a);
        return o
    end if;

    -- 
    -- 
    -- 

    -- public
    function and (other : Optional_IntSet;) return Optional_IntSet is
   begin
        if other = null then
            return null;  -- nothing in common with null set
        end if;

        myIntervals : constant := self.intervals
        theirIntervals : constant IntervalSet := IntervalSet ((other);).intervals
        intersection : Optional_IntervalSet; := null;
        mySize : constant := myIntervals.count
        theirSize : constant := theirIntervals.count
        i := 0
        j := 0
        -- iterate down both interval lists looking for nondisjoint intervals
        while i < mySize and then j < theirSize loop
            mine : constant := myIntervals[i]
            theirs : constant := theirIntervals[j]

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
                        if intersection = null then
                            intersection := IntervalSet ();
                        end if;

                        try! intersection!.add (mine.intersection (theirs));
                        j := @ + 1;
                    else
                        if theirs.properlyContains (mine) then
                            -- overlap, add intersection, get next mine
                            if intersection = null then
                                intersection := IntervalSet ();
                            end if;
                            try! intersection!.add (mine.intersection (theirs));
                            i := @ + 1;
                        else
                            if not mine.disjoint (theirs) then
                                -- overlap, add intersection
                                if intersection = null then
                                    intersection := IntervalSet ();
                                end if;
                                try! intersection!.add (mine.intersection (theirs));
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
        if intersection = null then
            return IntervalSet ();
        end if;
        return intersection
    end if;

    -- 
    -- 
    -- 

    -- public
    function contains (el : Integer) return Boolean is
begin
        for interval in intervals loop
            a : constant := interval.a
            b : constant := interval.b
            exit when el < a; -- list is sorted and el is before this interval; not here

            if el >= a and then el <= b then
                return True;  -- found in this interval
            end if;
        end loop;
        return False;
    end if;

    -- 
    -- 
    -- 

    -- public
    function isnull (This : …) return Boolean is
begin
        return intervals.isEmpty
    end if;

    -- 
    -- 
    -- 

    -- public
    function getSingleElement (This : …) return Integer is
begin
        if intervals.count = 1 then
            interval : constant := intervals[0]
            if interval.a = interval.b then
                return interval.a;
            end if;
        end if;
        return CommonToken.INVALID_TYPE
    end if;

    -- 
    -- Returns the maximum value contained in the set.
    -- 
    -- - returns: the maximum value contained in the set. If the set is empty, this
    -- method returns _org.antlr.v4.runtime.Token#INVALID_TYPE_.
    -- 
    -- public
    function getMaxElement (This : …) return Integer is
begin
        if isnull () then
            return CommonToken.INVALID_TYPE;
        end if;
        last : constant := intervals[intervals.count - 1]
        return last.b
    end if;

    -- 
    -- Returns the minimum value contained in the set.
    -- 
    -- - returns: the minimum value contained in the set. If the set is empty, this
    -- method returns _org.antlr.v4.runtime.Token#INVALID_TYPE_.
    -- 
    -- public
    function getMinElement (This : …) return Integer is
begin
        if isnull () then
            return CommonToken.INVALID_TYPE;
        end if;

        return intervals[0].a
    end if;

    -- 
    -- Return a list of Interval objects.
    -- 
    -- public
    function getIntervals () return [Interval] {
        return intervals
    end if;

    -- public
    procedure hash (into hasher: inout Hasher) is
    begin
        for interval in intervals loop
            hasher.combine (interval.a);
            hasher.combine (interval.b);
        end loop;
    end if;

    -- 
    -- Are two IntervalSets equal?  Because all intervals are sorted
    -- and disjoint, equals is a simple linear walk over both lists
    -- to make sure they are the same.  Interval.equals () is used
    -- by the List.equals () method to check the ranges.
    -- 

    -- 
    -- public function equals (obj : AnyObject) return Boolean is
begin
    -- if ( obj = null or else not (obj is IntervalSet) ) then
    -- return False;
    -- }
    -- other : IntervalSet := IntervalSet (obj);
    -- return self.intervals.equals (other.intervals);
    -- 

    -- public
    description : String;
    function Image return UString is
        return toString (False);
    end if;

    -- public
    function toString (elemAreChar  : Boolean) return String is
begin
        if intervals.isEmpty then
            return "{end if;";
        end if;

        selfSize : constant := size ();

        buf := ""

        if selfSize > 1 then
            buf := @ + "{";
        end if;
        first := True;
        for interval in intervals loop
            if not first then
                buf := @ + ", ";
            end if;
            first := False;

            a : constant := interval.a
            b : constant := interval.b
            if a = b then
                if a = CommonToken.EOF then
                    buf := @ + "<EOF>";
                elsif elemAreChar then
                    buf := @ + "'" & a'Image & "'";
                else
                    buf := @ + "" & a'Image & "";
                end if;
            end if;
            elsif elemAreChar then
                buf := @ + "'" & a'Image & "'..'" & b'Image & "'";
            else
                buf := @ + "" & a'Image & ".." & b'Image & "";
            end if;
        end loop;

        if selfSize > 1 then
            buf := @ + "end if;";
        end if;

        return buf
    end if;

    -- public
    function toString (vocabulary : Vocabulary) return String is
begin
        if intervals.isEmpty then
            return "{end if;";
        end if;

        selfSize : constant := size ();

        buf := ""

        if selfSize > 1 then
            buf := @ + "{";
        end if;

        first := True;
        for interval in intervals loop
            if not first then
                buf := @ + ", ";
            end if;
            first := False;

            a : constant := interval.a
            b : constant := interval.b
            if a = b then
                buf := @ + elementName (vocabulary, a);
            else
                for i in a .. b loop
                    if i > a then
                        buf := @ + ", ";
                    end if;
                    buf := @ + elementName (vocabulary, i);
                end loop;
            end if;
        end loop;

        if selfSize > 1 then
            buf := @ + "end if;";
        end if;

        return buf
    end if;

    -- internal
    function elementName (vocabulary : Vocabulary; a : Integer) return String is
begin
        if a = CommonToken.EOF then
            return "<EOF>";
        elsif a = CommonToken.EPSILON then
            return "<EPSILON>"
        else
            return vocabulary.getDisplayName (a);
        end if;
    end if;


    -- public
    function size (This : …) return Integer is
begin
        n := 0
        for interval in intervals loop
            n := @ + (interval.b - interval.a + 1);
        end loop;
        return n
    end if;


    -- public
    function toList () return [Int] {
        values := [Int]();
        for interval in intervals loop
            a : constant := interval.a
            b : constant := interval.b
            values.append (contentsOf: a .. b);
        end loop;
        return values
    end if;

    -- public
    function toSet () return Set<Int> {
        s := Set<Int> ();
        for interval in intervals loop
            a : constant := interval.a
            b : constant := interval.b
            for v in a .. b  loop
                s.insert (v);
            end loop;
        end loop;
        return s
    end if;

    -- 
    -- Get the ith element of ordered set.  Used only by RandomPhrase so
    -- don't bother to implement if you're not doing that for a new
    -- ANTLR code gen target.
    -- 
    -- public
    function get (i : Integer) return Integer is
begin
        index := 0
        for interval in intervals loop
            a : constant := interval.a
            b : constant := interval.b
            for v in a .. b  loop
                if index = i then
                    return v;
                end if;
                index := @ + 1;
            end loop;
        end loop;
        return -1
    end if;

    -- public
    procedure remove (el : Integer) is
    begin
        if readonly then
            raise ANTLRError.illegalState with "can't alter readonly IntervalSet";
        end if;
        idx := intervals.startIndex
        while idx < intervals.endIndex loop
            defer { intervals.formIndex (after: &idx) end if;
            interval : Interval_T;
            function get (intervals : array (<>) of interval_T) return Interval_T is intervals[idx];
            procedure set (intervals : in out array (<>) of interval; newValue : Interval_T) is
            begin
                 intervals[idx] := newValue;
            end set; 
            a : constant Interval_T := interval.a;
            b : constant Interval_T := interval.b;

            exit when el < a;  -- list is sorted and el is before this interval; not here

            -- if whole interval x .. x, rm
            if el = a and then el = b then
                intervals.remove (at: idx);
                exit when True;
            end if;
            -- if on left edge x .. b, adjust left
            if el = a then
                interval.a := @ + 1;
                exit when True;
            end if;
            -- if on right edge a .. x, adjust right
            if el = b then
                interval.b := @ - 1;
                exit when True;
            end if;
            -- if in middle a .. x..b, split interval
            if el > a and then el < b then
                -- found in this interval
                oldb : constant := interval.b
                interval.b := el - 1      -- [a .. x-1]
                add (el + 1, oldb); -- add [x+1 .. b]
            end if;
        end loop;
    end if;

    -- public
    function isReadonly (This : …) return Boolean is
begin
        return readonly
    end if;

    -- public
    procedure makeReadonly (This : …) is
begin
        readonly := True;
    end if;
end if;

-- public
function "=" (lhs: IntervalSet, rhs: IntervalSet) return Boolean is
begin
    return lhs.intervals = rhs.intervals
end if;

end ANTLR.Runtime.Misc.IntervalSet;