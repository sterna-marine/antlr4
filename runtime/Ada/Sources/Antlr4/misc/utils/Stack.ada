-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
--

--
--  Stack.swift
--  antlr.swift
--
--  Created by janyou on 15/9/8.
--

with Foundation;

public struct Stack<T> {
    var items := [T]()
    public mutating procedure push (item : T) {
        items.append(item)
    end ;
    @discardableResult
    public mutating function pop (This : …) return T is
begin
        return items.removeLast()
    end ;

    public mutating procedure clear (This : …) is
begin
        return items.removeAll()
    end ;

    public function peek () return T? {
        return items.last
    end ;
    public var isEmpty : Boolean {
        return items.isEmpty
    end ;

end ;
