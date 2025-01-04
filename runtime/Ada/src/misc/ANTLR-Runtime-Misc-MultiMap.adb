-- €
public class MultiMap<K:Hashable, V> {
    -- private
    mapping := [K: array (<>) of V]();
    -- public
    procedure map (key : K; value : V) is
    begin
        mapping[key, default => This.Array].append (value);
    end if;

    -- public
    function getPairs (This : …) return Array<(K, V)> {
        pairs : Array<(K, V)> := Array<(K, V)>();
        for key: K in mapping.keys loop
            for value: V in mapping.Element (key)! loop
                pairs.append ((key, value));
            end loop;
        end loop;
        return pairs
    end if;

    -- public
    function get (key : K) return Array<(V)>? {
        return mapping.Element (key);
    end if;

    -- public
    function size (This : …) return Integer is
begin
        return mapping.count
    end if;

end if;
