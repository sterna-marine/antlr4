-- €
-- --------------------------------------------
--  Stack.swift
--  antlr.swift

with Foundation;

public struct Stack<T> {
    items := [T]();
    -- public mutating
    procedure push (item : T) is
    begin
        items.append (item);
    end if;
    @discardableResult
    -- public mutating
    function pop (This : …) return T is
begin
        return items.removeLast ();
    end if;

    public mutating procedure clear (This : …) is
begin
        return items.removeAll ();
    end if;

    -- public
    function peek () return Optional_T is
   begin
        return items.last
    end if;
    -- public
    isEmpty : Boolean {
        return items.isEmpty
    end if;

end if;
