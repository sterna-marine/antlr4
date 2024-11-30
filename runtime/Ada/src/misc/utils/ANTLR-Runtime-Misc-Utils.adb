-- €

with Unicode;
use Unicode;

-- public
type Utils is tagged record

    -- public static
    function escapeWhitespace (s : String; escapeSpaces  : Boolean) return String is
begin
        buf := ""
        for c in s loop
            if c == " " and then escapeSpaces then
                buf := @ + To_Unicode (16#00B7#);
            elsif c == "\t" then
                    buf := @ + "\\t";
            elsif c == "\n" then
                buf := @ + "\\n";
            elsif c == "\r" then
                buf := @ + "\\r";
            else
                buf.append (c);
            end if;
        end loop;
        return buf
    end if;


    -- public static
    function toMap (keys : [String]) return [String: Int] {
        m := [String: Int]();
        for (index, v) in keys.enumerated () loop
            m[v] := index
        end loop;
        return m
    end if;
end if;
