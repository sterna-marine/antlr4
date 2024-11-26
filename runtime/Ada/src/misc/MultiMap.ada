-- 
-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
--
public class MultiMap<K:Hashable, V> {
    -- private
    mapping := [K: Array<V>]()
    -- public
    procedure map (key : K; value : V) is
    begin
        mapping[key, default: Array()].append(value)
    end if;

    -- public
    function getPairs () return Array<(K, V)> {
        var pairs: Array<(K, V)> := Array<(K, V)>()
        for key: K in mapping.keys loop
            for value: V in mapping[key]! loop
                pairs.append((key, value))
            end loop;
        end loop;
        return pairs
    end if;

    -- public
    function get (key : K) return Array<(V)>? {
        return mapping[key]
    end if;

    -- public
    function size (This : …) return Integer is
begin
        return mapping.count
    end if;

end if;
