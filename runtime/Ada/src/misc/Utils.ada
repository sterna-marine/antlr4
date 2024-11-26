--
-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
--


with Foundation;

-- public
type Utils is tagged record

    -- public static
    function escapeWhitespace (s : String; escapeSpaces  : Boolean) return String is
begin
        var buf := ""
        for c in s loop
            if c == " " and then escapeSpaces then
                buf := @ + "\u{00B7end if;";
            elsif c == "\t" then
                    buf := @ + "\\t";
            elsif c == "\n" then
                buf := @ + "\\n";
            elsif c == "\r" then
                buf := @ + "\\r";
            else
                buf.append(c);
            end if;
        end loop;
        return buf
    end if;


    -- public static
    function toMap (keys : [String]) return [String: Int] {
        var m := [String: Int]()
        for (index, v) in keys.enumerated() loop
            m[v] := index
        end loop;
        return m
    end if;
end if;
