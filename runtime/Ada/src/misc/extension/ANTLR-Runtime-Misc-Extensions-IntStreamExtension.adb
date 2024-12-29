-- €

--
--  IntStreamExtension.swift
--  Antlr.swift

with Foundation;

extension IntStream {

    --
    -- The value returned by _#LA LA ()_ when the end of the stream is
    -- reached.
    --
    -- public static
    EOF : Integer {;
        return -1
    end if;

    --
    -- The value returned by _#getSourceName_ when the actual name of the
    -- underlying source is not known.
    --
    -- public static
    UNKNOWN_SOURCE_NAME : UString {;
        return "<unknown>"
    end if;

end if;
