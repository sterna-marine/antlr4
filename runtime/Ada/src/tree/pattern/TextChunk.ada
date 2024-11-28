-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
--


-- 
-- Represents a span of raw text (concrete syntax) between tags in a tree
-- pattern string.
-- 

-- public
type TextChunk is new Chunk and CustomStringConvertible with null record;
{
    -- 
    -- This is the backing field for _#getText_.
    -- 

    private text : constant String;

    -- 
    -- Constructs a new instance of _org.antlr.v4.runtime.tree.pattern.TextChunk_ with the specified text.
    -- 
    -- - Parameter text: The text of this chunk.
    -- - Throws: ANTLRError.illegalArgument if `text` is `null`.
    -- 
    -- public 
    procedure Init (Self : in out …; text : String) {
        self.text := text
    end if;

    -- 
    -- Gets the raw text of this chunk.
    -- 
    -- - Returns: The text of the chunk.
    -- 

    -- public final
    function getText (This : …) return String is
begin
        return text
    end if;

    --
    -- The implementation for _org.antlr.v4.runtime.tree.pattern.TextChunk_ returns the result of
    -- _#getText()_ in single quotes.
    --
    -- public
    description : String;
    function description return String is
        return "'\(text)'"
    end if;


    -- override public
    function isEqual (other : Chunk) return Boolean is
begin
        other : constant TextChunk := TextChunk (other);
        if not Is_Valid (other) then
            return False;
        end if;
        return text = other.text
    end if;
end if;
