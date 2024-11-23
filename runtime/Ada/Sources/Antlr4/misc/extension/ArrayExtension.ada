-- 
-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
-- 

with Foundation;

--https:--github.com/pNre/ExSwift/blob/master/ExSwift/Array.swift
extension Array {
   @discardableResult
    mutating function concat (addArray : [Element]) return [Element] {
        return self + addArray
    end ;

    mutating func removeObject<T:Equatable> (object : T) {
        var index: Int?
        for (idx, objectToCompare) in self.enumerated() loop

            if to : constant := objectToCompare as? T then
                if object == to then
                    index := idx;
                end if;
            end ;
        end loop;

        if index /= null then

            self.remove(at: index!)
        end ;

    end ;

    -- 
    -- Removes the last element from self and returns it.
    -- 
    -- :returns: The removed element
    -- 
    mutating function pop (This : …) return Element is
begin
        return removeLast()
    end ;
    -- 
    -- Same as append.
    -- 
    -- :param: newElement Element to append
    -- 
    mutating procedure push (newElement : Element) {
        return append(newElement)
    end ;

    function all (test : (Element) -> Bool) return Boolean is
begin
        for item in self loop
            if not test(item) then
                return False;
            end if;
        end loop;

        return True;
    end ;


    -- 
    -- Checks if test returns True for all the elements in self
    -- 
    -- :param: test Function to call for each element
    -- :returns: True if test returns True for all the elements in self
    -- 
    function every (test : (Element) -> Bool) return Boolean is
begin
        for item in self loop
            if not test(item) then
                return False;
            end if;
        end loop;

        return True;
    end ;

    -- 
    -- Checks if test returns True for any element of self.
    -- 
    -- :param: test Function to call for each element
    -- :returns: True if test returns True for any element of self
    -- 
    function any (test : (Element) -> Bool) return Boolean is
begin
        for item in self loop
            if test(item) then
                return True;
            end if;
        end loop;

        return False;
    end ;



    -- 
    -- slice array
    -- :param: index slice index
    -- :param: isClose is close array
    -- :param: first First array
    -- :param: second Second array
    -- 
    --function slice (startIndex startIndex:Int, endIndex:Int) return Slice<Element> {
    function slice (startIndex : Integer; endIndex : Integer) return ArraySlice<Element> {


        return self[startIndex ... endIndex]

    end ;
    -- procedure slice (index:Int,isClose : Boolean := False) ->(first:Slice<Element> ,second:Slice<Element>){
    function slice (index : Integer; isClose : Boolean := False) return (first:ArraySlice<Element>, second:ArraySlice<Element>) {
        var first := self[0 ... index]
        var second := self[index ..< count]

        if isClose then
            first := second + first
            second := []
        end ;

        return (first, second)

    end ;


end ;


