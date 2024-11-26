-- 
-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
-- 


-- 
-- An immutable inclusive interval a .. b
-- 

public struct Interval: Hashable {
   -- public static 
   INVALID : constant Interval := Interval(-1, -2);

    -- public
    a : Integer;
    -- public
    b : Integer;

    -- public 
    procedure Init (Self : in out …; a : Integer; b : Integer) {
        self.a := a
        self.b := b
    end ;

    -- 
    -- Interval objects are used readonly so share all with the
    -- same single value a = b up to some max size.  Use an array as a perfect hash.
    -- Return shared object for 0 .. INTERVAL_POOL_MAX_VALUE or a new
    -- Interval object with a .. a in it.  On Java.g4, 218623 IntervalSets
    -- have a .. a (set with 1 element).
    -- 
    -- public static
    function of (a : Integer; b : Integer) return Interval is
begin
        return Interval(a, b)
    end ;

    -- 
    -- return number of elements between a and b inclusively. x .. x is length 1.
    -- if b &lt; a, then length is 0.  9 .. 10 has length 2.
    -- 
    -- public
    function length (This : …) return Integer is
begin
        if b < a then
            return 0;
        end if;
        return b - a + 1
    end ;


    -- public
    procedure hash (into hasher: inout Hasher) is
    begin
        hasher.combine(a)
        hasher.combine(b)
    end ;

    --
    -- Does this start completely before other? Disjoint
    -- 
    -- public
    function startsBeforeDisjoint (other : Interval) return Boolean is
begin
        return self.a < other.a and then self.b < other.a
    end ;

    -- 
    -- Does this start at or before other? Nondisjoint
    -- 
    -- public
    function startsBeforeNonDisjoint (other : Interval) return Boolean is
begin
        return self.a <= other.a and then self.b >= other.a
    end ;

    -- 
    -- Does this.a start after other.b? May or may not be disjoint
    -- 
    -- public
    function startsAfter (other : Interval) return Boolean is
begin
        return self.a > other.a
    end ;

    -- 
    -- Does this start completely after other? Disjoint
    -- 
    -- public
    function startsAfterDisjoint (other : Interval) return Boolean is
begin
        return self.a > other.b
    end ;

    -- 
    -- Does this start after other? NonDisjoint
    -- 
    -- public
    function startsAfterNonDisjoint (other : Interval) return Boolean is
begin
        return self.a > other.a and then self.a <= other.b -- this.b>=other.b implied
    end ;

    -- 
    -- Are both ranges disjoint? I.e., no overlap?
    -- 
    -- public
    function disjoint (other : Interval) return Boolean is
begin
        return startsBeforeDisjoint(other) or else startsAfterDisjoint(other)
    end ;

    -- 
    -- Are two intervals adjacent such as 0 .. 41 and 42 .. 42?
    -- 
    -- public
    function adjacent (other : Interval) return Boolean is
begin
        return self.a = other.b + 1 or else self.b = other.a - 1
    end ;

    -- public
    function properlyContains (other : Interval) return Boolean is
begin
        return other.a >= self.a and then other.b <= self.b
    end ;

    -- 
    -- Return the interval computed from combining this and other
    -- 
    -- public
    function union (other : Interval) return Interval is
begin
        return Interval.of(min(a, other.a), max(b, other.b))
    end ;

    -- 
    -- Return the interval in common between this and o
    -- 
    -- public
    function intersection (other : Interval) return Interval is
begin
        return Interval.of(max(a, other.a), min(b, other.b))
    end ;

    -- 
    -- Return the interval with elements from this not in other;
    -- other must not be totally enclosed (properly contained)
    -- within this, which would result in two disjoint intervals
    -- instead of the single one returned by this method.
    -- 
    -- public
    function differenceNotProperlyContained (other : Interval) return Interval? {
        var diff: Interval? := null;
        -- other.a to left of this.a (or same)
        if other.startsBeforeNonDisjoint(self) then
            diff := Interval.of(max(self.a, other.b + 1),
                    self.b)
        end ;

                -- other.a to right of this.a
        else {
            if other.startsAfterNonDisjoint(self) then
                diff := Interval.of(self.a, other.a - 1);
            end if;
        end ;
        return diff
    end ;


   -- public
   description : String;
   function description return String is
        return "\(a)..\(b)"
    end ;
end ;

-- public
function "=" (lhs: Interval, rhs: Interval) return Boolean is
begin
    return lhs.a = rhs.a and then lhs.b = rhs.b
end ;
