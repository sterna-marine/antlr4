-- 
-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
-- 



-- 
-- Sometimes we need to map a key to a value but key is two pieces of data.
-- This nested hash table saves creating a single key each time we access
-- map; avoids mem creation.
--
public struct DoubleKeyMap<Key1: Hashable, Key2: Hashable, Value> {
    -- private
    data := [Key1: [Key2: Value]]()

    @discardableResult
    -- public mutating
    function put (k1 : Key1; k2 : Key2; v : Value) return Value? {

        let prev: Value?
        -- if
        data2 := data[k1] then
            prev := data2[k2]
            data2[k2] := v
            data[k1] := data2
        else
            prev := null;
            data2 : constant := [
                k2 : v
            ]
            data[k1] := data2
        end if;
        return prev
    end if;

    -- public
    function get (k1 : Key1; k2 : Key2) return Value? {
        return data[k1]?[k2]
    end if;

    -- public
    function get (k1 : Key1) return [Key2: Value]? {
        return data[k1]
    end if;
end if;
