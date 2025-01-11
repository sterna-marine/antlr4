-- €

with Foundation;

--https:--github.com/pNre/ExSwift/blob/master/ExSwift/Array.swift
extension Array {
   @discardableResult
    -- mutating
    function concat (addArray : Element_List) return Element_Container.Vector is
        return self + addArray
    end if;

    mutating func removeObject<T:Equatable> (object : T) {
        index : Optional_Integer;
        for (idx, objectToCompare) in self.enumerated loop

            to : constant Optional_T := Maybe (objectToCompare);
            if Is_Valid (to) then
                if object = to then
                    index := idx;
                end if;
            end if;
        end loop;

        if Is_Valid (index) then

            self.remove (at => index!);
        end if;

    end if;

    --
    -- Removes the last element from self and returns it.
    --
    -- :returns: The removed element
    --
    -- mutating
    function pop (This : …) return Element is
begin
        return This.removeLast;
    end if;
    --
    -- Same as append.
    --
    -- :param: newElement Element to append
    --
    -- mutating
    procedure push (newElement : Element) is
    begin
        return append (newElement);
    end if;

    function all (test : (Element) -> Bool) return Boolean is
begin
        for item in self loop
            if not test (item) then
                return False;
            end if;
        end loop;

        return True;
    end if;


    --
    -- Checks if test returns True for all the elements in self
    --
    -- :param: test Function to call for each element
    -- :returns: True if test returns True for all the elements in self
    --
    function every (test : (Element) -> Bool) return Boolean is
begin
        for item in self loop
            if not test (item) then
                return False;
            end if;
        end loop;

        return True;
    end if;

    --
    -- Checks if test returns True for any element of self.
    --
    -- :param: test Function to call for each element
    -- :returns: True if test returns True for any element of self
    --
    function any (test : (Element) -> Bool) return Boolean is
begin
        for item in self loop
            if test (item) then
                return True;
            end if;
        end loop;

        return False;
    end if;



    --
    -- slice array
    -- :param: index slice index
    -- :param: isClose is close array
    -- :param: first First array
    -- :param: second Second array
    --
    --function slice (startIndex startIndex:Int, endIndex:Int) return Slice<Element> {
    function slice (startIndex : Integer; endIndex : Integer) return ArraySlice<Element> {


        return self[startIndex  ..  endIndex]

    end if;
    -- procedure slice (index:Int,isClose : Boolean := False) ->(first:Slice<Element> ,second:Slice<Element>){
    function slice (index : Integer; isClose : Boolean := False) return (first:ArraySlice<Element>, second:ArraySlice<Element>) {
        first := self[0  ..  index]
        second := self[index .. count - 1]

        if isClose then
            first := second + first
            second := []
        end if;

        return (first, second);

    end if;


end if;


