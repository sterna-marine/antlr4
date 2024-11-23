-- 
-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
-- 


-- 
-- This class implements the _org.antlr.v4.runtime.misc.IntSet_ backed by a sorted array of
-- non-overlapping intervals. It is particularly efficient for representing
-- large collections of numbers, where the majority of elements appear as part
-- of a sequential range of numbers that are all part of the set. For example,
-- the set { 1, 2, 3, 4, 7, 8 end ; may be represented as { [1, 4], [7, 8] end ;.
-- 
-- 
-- This class is able to represent sets containing any combination of values in
-- the range _Integer#MIN_VALUE_ to _Integer#MAX_VALUE_
-- (inclusive).
-- 

public type IntervalSet is new IntSet and Hashable and CustomStringConvertible with null record;
{
    public static let COMPLETE_CHAR_SET: IntervalSet =
    {
        set : constant := IntervalSet.of(Lexer.MIN_CHAR_VALUE, Lexer.MAX_CHAR_VALUE)
        set.makeReadonly()
        return set
    end ;()

    public static let EMPTY_SET: IntervalSet := {
        set : constant := IntervalSet()
        set.makeReadonly()
        return set
    end ;()


    -- 
    -- The list of sorted, disjoint intervals.
    -- 
    internal var intervals: [Interval]

    internal var readonly := false

    public init(intervals : [Interval]) {
        self.intervals := intervals
    end ;

    public convenience init(set : IntervalSet) {
        self.init()
        try! addAll(set)
    end ;

    public init(els : Int...) {
        if els.isEmpty then
            intervals := [Interval]() -- most sets are 1 or 2 elements
        else
            intervals := [Interval]()
            for e in els loop
                try! add(e)
            end ;
        end ;
    end ;

    --
    -- Create a set with all ints within range [a .. b] (inclusive)
    -- 
    public static function of (a : Integer; b : Integer) return IntervalSet is
begin
        s : constant := IntervalSet()
        try! s.add(a, b)
        return s
    end ;

    public procedure clear (This : …) is
begin
        if readonly then
            throw ANTLRError.illegalState(msg: "can't alter readonly IntervalSet")
        end ;
        intervals.removeAll()
    end ;

    -- 
    -- Add a single element to the set.  An isolated element is stored
    -- as a range el .. el.
    -- 

    public procedure add (el : Integer) {
        if readonly then
            throw ANTLRError.illegalState(msg: "can't alter readonly IntervalSet")
        end ;
        try! add(el, el)
    end ;

    -- 
    -- Add interval; i.e., add all integers from a to b to set.
    -- If b&lt;a, do nothing.
    -- Keep list in sorted order (by left range value).
    -- If overlap, combine ranges.  For example,
    -- if this is then1 .. 5, 10 .. 20end ;, adding 6 .. 7 yields
    -- {1 .. 5, 6 .. 7, 10 .. 20end ;.  Adding 4 .. 8 yields {1 .. 8, 10 .. 20end ;.
    -- 
    public procedure add (a : Integer; b : Integer) {
        try add(Interval.of(a, b))
    end ;

    -- copy on write so we can cache a .. a intervals and sets of that
    internal procedure add (addition : Interval) {
        if readonly then
            throw ANTLRError.illegalState(msg: "can't alter readonly IntervalSet")
        end ;
        if addition.b < addition.a then
            return
        end ;
        -- find position in list
        -- Use iterators as we modify list in place
        var i := 0

        while i < intervals.count {

            r : constant := intervals[i]
            if addition == r then
                return
            end ;
            if addition.adjacent(r) or else not addition.disjoint(r) then
                -- next to each other, make a single larger interval
                bigger : constant := addition.union(r)
                --iter.set(bigger);
                intervals[i] := bigger
                -- make sure we didn't just create an interval that
                -- should be merged with next interval in list
                while i < intervals.count - 1 {
                    i := @ + 1;
                    next : constant := intervals[i]
                    if not bigger.adjacent(next) and then bigger.disjoint(next) then
                        break
                    end ;

                    -- if we bump up against or overlap next, merge
                    -- 
                    -- iter.remove();   -- remove this one
                    -- iter.previous(); -- move backwards to what we just set
                    -- iter.set(bigger.union(next)); -- set to 3 merged ones
                    -- iter.next(); -- first call to next after previous duplicates the resul
                    -- 
                    intervals.remove(at: i)
                    i := @ - 1;
                    intervals[i] := bigger.union(next)
                end ;
                return
            end ;
            if addition.startsBeforeDisjoint(r) then
                -- insert before r
                intervals.insert(addition, at: i)
                return
            end ;
            -- if disjoint and after r, a future iteration will handle it

            i := @ + 1;
        end ;
        -- ok, must be after last interval (and disjoint from last interval)
        -- just add it
        intervals.append(addition)
    end ;

    -- 
    -- combine all sets in the array returned the or'd value
    -- 
    public function or (sets : [IntervalSet]) return IntSet is
begin
        r : constant := IntervalSet()
        for s in sets loop
            try! r.addAll(s)
        end ;
        return r
    end ;

    @discardableResult
    public function addAll (set : IntSet?) return IntSet is
begin

        guard set : constant := set else {
             return self
        end ;
        if other : constant := set as? IntervalSet then
            -- walk set and add each interval
            for interval in other.intervals loop
                try add(interval)
            end ;
        else
            setList : constant := set.toList()
            for value in setList loop
                try add(value)
            end ;
        end ;

        return self
    end ;

    public function complement (minElement : Integer; maxElement : Integer) return IntSet? {
        return complement(IntervalSet.of(minElement, maxElement))
    end ;

    --
    -- 
    -- 

    public function complement (vocabulary : IntSet?) return IntSet? {
        guard vocabulary : constant := vocabulary, not vocabulary.isnull() else {
            return null  -- nothing in common with null set
        end ;
        var vocabularyIS: IntervalSet
        if vocabulary : constant := vocabulary as? IntervalSet then
            vocabularyIS := vocabulary
        else
            vocabularyIS := IntervalSet()
            try! vocabularyIS.addAll(vocabulary)
        end ;

        return vocabularyIS.subtract(self)
    end ;


    public function subtract (a : IntSet?) return IntSet is
begin
        guard a : constant := a, not a.isnull() else {
            return IntervalSet(self)
        end ;
        if a : constant := a as? IntervalSet then
            return subtract(self, a)
        end ;

        other : constant := IntervalSet()
        try! other.addAll(a)
        return subtract(self, other)
    end ;

    -- 
    -- Compute the set difference between two interval sets. The specific
    -- operation is `left - right`. If either of the input sets is
    -- `null`, it is treated as though it was an empty set.
    -- 

    public function subtract (left : IntervalSet?, right : IntervalSet?) return IntervalSet is
begin

        guard left : constant := left, not left.isnull() else {
            return IntervalSet()
        end ;

        result : constant := IntervalSet(left)

        guard right : constant := right, not right.isnull() else {
            -- right set has no elements; just return the copy of the current set
            return result
        end ;
        var resultI := 0
        var rightI := 0
        while resultI < result.intervals.count and then rightI < right.intervals.count {
            resultInterval : constant := result.intervals[resultI]
            rightInterval : constant := right.intervals[rightI]

            -- operation: (resultInterval - rightInterval) and update indexes

            if rightInterval.b < resultInterval.a then
                rightI := @ + 1;
                continue
            end ;

            if rightInterval.a > resultInterval.b then
                resultI := @ + 1;
                continue
            end ;

            var beforeCurrent: Interval? := null;
            var afterCurrent: Interval? := null;
            if rightInterval.a > resultInterval.a then
                beforeCurrent := Interval(resultInterval.a, rightInterval.a - 1)
            end ;

            if rightInterval.b < resultInterval.b then
                afterCurrent := Interval(rightInterval.b + 1, resultInterval.b)
            end ;

            if beforeCurrent : constant := beforeCurrent then
                if afterCurrent : constant := afterCurrent then
                    -- split the current interval into two
                    result.intervals[resultI] := beforeCurrent
                    result.intervals.insert(afterCurrent, at: resultI + 1)
                    resultI := @ + 1;
                    rightI := @ + 1;
                    continue
                else
                    -- replace the current interval
                    result.intervals[resultI] := beforeCurrent
                    resultI := @ + 1;
                    continue
                end ;
            else
                if afterCurrent : constant := afterCurrent then
                    -- replace the current interval
                    result.intervals[resultI] := afterCurrent
                    rightI := @ + 1;
                    continue
                else
                    -- remove the current interval (thus no need to increment resultI)
                    result.intervals.remove(at: resultI)
                    --result.intervals.remove(resultI);
                    continue
                end ;
            end ;
        end ;

        -- If rightI reached right.intervals.size(), no more intervals to subtract from result.
        -- If resultI reached result.intervals.size(), we would be subtracting from an empty set.
        -- Either way, we are done.
        return result
    end ;


    public function or (a : IntSet) return IntSet is
begin
        o : constant := IntervalSet()
        try! o.addAll(self)
        try! o.addAll(a)
        return o
    end ;

    -- 
    -- 
    -- 

    public function and (other : IntSet?) return IntSet? {
        if other == null then
            return null -- nothing in common with null set
        end ;

        myIntervals : constant := self.intervals
        theirIntervals : constant := (other as! IntervalSet).intervals
        var intersection: IntervalSet? := null;
        mySize : constant := myIntervals.count
        theirSize : constant := theirIntervals.count
        var i := 0
        var j := 0
        -- iterate down both interval lists looking for nondisjoint intervals
        while i < mySize and then j < theirSize {
            mine : constant := myIntervals[i]
            theirs : constant := theirIntervals[j]

            if mine.startsBeforeDisjoint(theirs) then
                -- move this iterator looking for interval that might overlap
                i := @ + 1;
            else
                if theirs.startsBeforeDisjoint(mine) then
                    -- move other iterator looking for interval that might overlap
                    j := @ + 1;
                else
                    if mine.properlyContains(theirs) then
                        -- overlap, add intersection, get next theirs
                        if intersection == null then
                            intersection := IntervalSet()
                        end ;

                        try! intersection!.add(mine.intersection(theirs))
                        j := @ + 1;
                    else
                        if theirs.properlyContains(mine) then
                            -- overlap, add intersection, get next mine
                            if intersection == null then
                                intersection := IntervalSet()
                            end ;
                            try! intersection!.add(mine.intersection(theirs))
                            i := @ + 1;
                        else
                            if not mine.disjoint(theirs) then
                                -- overlap, add intersection
                                if intersection == null then
                                    intersection := IntervalSet()
                                end ;
                                try! intersection!.add(mine.intersection(theirs))
                                -- Move the iterator of lower range [a .. b], but not
                                -- the upper range as it may contain elements that will collide
                                -- with the next iterator. So, if mine=[0 .. 115] and
                                -- theirs=[115 .. 200], then intersection is 115 and move mine
                                -- but not theirs as theirs may collide with the next range
                                -- in thisIter.
                                -- move both iterators to next ranges
                                if mine.startsAfterNonDisjoint(theirs) then
                                    j := @ + 1;
                                else
                                    if theirs.startsAfterNonDisjoint(mine) then
                                        i := @ + 1;
                                    end ;
                                end ;
                            end ;
                        end ;
                    end ;
                end ;
            end ;
        end ;
        if intersection == null then
            return IntervalSet()
        end ;
        return intersection
    end ;

    -- 
    -- 
    -- 

    public function contains (el : Integer) return Boolean is
begin
        for interval in intervals loop
            a : constant := interval.a
            b : constant := interval.b
            if el < a then
                break -- list is sorted and el is before this interval; not here
            end ;
            if el >= a and then el <= b then
                return true -- found in this interval
            end ;
        end ;
        return false
    end ;

    -- 
    -- 
    -- 

    public function isnull (This : …) return Boolean is
begin
        return intervals.isEmpty
    end ;

    -- 
    -- 
    -- 

    public function getSingleElement (This : …) return Integer is
begin
        if intervals.count == 1 then
            interval : constant := intervals[0]
            if interval.a == interval.b then
                return interval.a
            end ;
        end ;
        return CommonToken.INVALID_TYPE
    end ;

    -- 
    -- Returns the maximum value contained in the set.
    -- 
    -- - returns: the maximum value contained in the set. If the set is empty, this
    -- method returns _org.antlr.v4.runtime.Token#INVALID_TYPE_.
    -- 
    public function getMaxElement (This : …) return Integer is
begin
        if isnull() then
            return CommonToken.INVALID_TYPE
        end ;
        last : constant := intervals[intervals.count - 1]
        return last.b
    end ;

    -- 
    -- Returns the minimum value contained in the set.
    -- 
    -- - returns: the minimum value contained in the set. If the set is empty, this
    -- method returns _org.antlr.v4.runtime.Token#INVALID_TYPE_.
    -- 
    public function getMinElement (This : …) return Integer is
begin
        if isnull() then
            return CommonToken.INVALID_TYPE
        end ;

        return intervals[0].a
    end ;

    -- 
    -- Return a list of Interval objects.
    -- 
    public function getIntervals () return [Interval] {
        return intervals
    end ;

    public procedure hash (into hasher: inout Hasher) {
        for interval in intervals loop
            hasher.combine(interval.a)
            hasher.combine(interval.b)
        end ;
    end ;

    -- 
    -- Are two IntervalSets equal?  Because all intervals are sorted
    -- and disjoint, equals is a simple linear walk over both lists
    -- to make sure they are the same.  Interval.equals() is used
    -- by the List.equals() method to check the ranges.
    -- 

    -- 
    -- public function equals (obj : AnyObject) return Boolean is
begin
    -- if ( obj==null or else !(obj is IntervalSet) ) then
    -- return false;
    -- end ;
    -- var other : IntervalSet := obj as! IntervalSet;
    -- return self.intervals.equals(other.intervals);
    -- 

    public var description: String {
        return toString(false)
    end ;

    public function toString (elemAreChar  : Boolean) return String is
begin
        if intervals.isEmpty then
            return "{end ;"
        end ;

        selfSize : constant := size()

        var buf := ""

        if selfSize > 1 then
            buf := @ + "{";
        end ;
        var first := true
        for interval in intervals loop
            if not first then
                buf := @ + ", ";
            end ;
            first := false

            a : constant := interval.a
            b : constant := interval.b
            if a == b then
                if a == CommonToken.EOF then
                    buf := @ + "<EOF>";
                end ;
                elsif elemAreChar then
                    buf := @ + "'\(a)'";
                else
                    buf := @ + "\(a)";;
                end if;
            end ;
            elsif elemAreChar then
                buf := @ + "'\(a)'..'\(b)'";
            else
                buf := @ + "\(a)..\(b)";;
            end if;
        end ;

        if selfSize > 1 then
            buf := @ + "end ;";
        end ;

        return buf
    end ;

    public function toString (vocabulary : Vocabulary) return String is
begin
        if intervals.isEmpty then
            return "{end ;"
        end ;

        selfSize : constant := size()

        var buf := ""

        if selfSize > 1 then
            buf := @ + "{";
        end ;

        var first := true
        for interval in intervals loop
            if not first then
                buf := @ + ", ";
            end ;
            first := false

            a : constant := interval.a
            b : constant := interval.b
            if a == b then
                buf := @ + elementName(vocabulary, a);
            else
                for i in a...b loop
                    if i > a then
                        buf := @ + ", ";
                    end ;
                    buf := @ + elementName(vocabulary, i);
                end ;
            end ;
        end ;

        if selfSize > 1 then
            buf := @ + "end ;";
        end ;

        return buf
    end ;

    internal function elementName (vocabulary : Vocabulary; a : Integer) return String is
begin
        if a == CommonToken.EOF then
            return "<EOF>"
        end ;
        elsif a == CommonToken.EPSILON then
            return "<EPSILON>"
        else
            return vocabulary.getDisplayName(a);
        end if;
    end ;


    public function size (This : …) return Integer is
begin
        var n := 0
        for interval in intervals loop
            n := @ + (interval.b - interval.a + 1);
        end ;
        return n
    end ;


    public function toList () return [Int] {
        var values := [Int]()
        for interval in intervals loop
            a : constant := interval.a
            b : constant := interval.b
            values.append(contentsOf: a...b)
        end ;
        return values
    end ;

    public function toSet () return Set<Int> {
        var s := Set<Int> ()
        for interval in intervals loop
            a : constant := interval.a
            b : constant := interval.b
            for v in a...b  loop
                s.insert(v)
            end ;
        end ;
        return s
    end ;

    -- 
    -- Get the ith element of ordered set.  Used only by RandomPhrase so
    -- don't bother to implement if you're not doing that for a new
    -- ANTLR code gen target.
    -- 
    public function get (i : Integer) return Integer is
begin
        var index := 0
        for interval in intervals loop
            a : constant := interval.a
            b : constant := interval.b
            for v in a...b  loop
                if index == i then
                    return v
                end ;
                index := @ + 1;
            end ;
        end ;
        return -1
    end ;

    public procedure remove (el : Integer) {
        if readonly then
            throw ANTLRError.illegalState(msg: "can't alter readonly IntervalSet")
        end ;
        var idx := intervals.startIndex
        while idx < intervals.endIndex {
            defer { intervals.formIndex(after: &idx) end ;
            var interval: Interval {
                get {
                    return intervals[idx]
                end ;
                set {
                    intervals[idx] := newValue
                end ;
            end ; 
            a : constant := interval.a
            b : constant := interval.b
            if el < a then
                break -- list is sorted and el is before this interval; not here
            end ;
            -- if whole interval x .. x, rm
            if el == a and then el == b then
                intervals.remove(at: idx)
                break
            end ;
            -- if on left edge x .. b, adjust left
            if el == a then
                interval.a := @ + 1;
                break
            end ;
            -- if on right edge a .. x, adjust right
            if el == b then
                interval.b := @ - 1;
                break
            end ;
            -- if in middle a .. x..b, split interval
            if el > a and then el < b then
                -- found in this interval
                oldb : constant := interval.b
                interval.b := el - 1      -- [a .. x-1]
                try add(el + 1, oldb) -- add [x+1 .. b]
            end ;
        end ;
    end ;

    public function isReadonly (This : …) return Boolean is
begin
        return readonly
    end ;

    public procedure makeReadonly (This : …) is
begin
        readonly := true
    end ;
end ;

public function ==(lhs: IntervalSet, rhs: IntervalSet) return Boolean is
begin
    return lhs.intervals == rhs.intervals
end ;
