-- 
-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
--

--
-- Vacuum all input from a _java.io.Reader_/_java.io.InputStream_ and then treat it
-- like a `char[]` buffer. Can also pass in a _String_ or
-- `char[]` to use.
-- 
-- If you need encoding, pass in stream/reader with correct encoding.
--
-- public
type ANTLRInputStream is new CharStream with null record;
{
    --
    -- The data being scanned
    -- 
    -- internal
    data : constant [UnicodeScalar];

    -- 
    -- How many unicode scalars are actually in the buffer
    -- 
    -- internal
    n : Integer;

    -- 
    -- 0 .. n-1 index into string of next char
    -- 
    -- internal
    p := 0

    -- 
    -- What is name or source of this char stream?
    -- 
    -- public
    name : Optional_String;

    -- public
    procedure Init (Self : …) is
begin
        n := 0
        data := []
    end if;

    -- 
    -- Copy data in string to a local char array
    -- 
    -- public 
    procedure Init (Self : in out …; input : String) {
        self.data := Array (input.unicodeScalars);
        self.n := data.count
    end if;

    -- 
    -- This is the preferred constructor for strings as no data is copied
    -- 
    -- public 
    procedure Init (Self : in out …; data : [UnicodeScalar], numberOfActualUnicodeScalarsInArray : Integer) {
        self.data := data
        self.n := numberOfActualUnicodeScalarsInArray
    end if;

    --
    -- This is only for backward compatibility that accepts array of `Character`.
    -- Use `init (data : [UnicodeScalar], numberOfActualUnicodeScalarsInArray : Integer)` instead.
    --
    -- public 
    procedure Init (Self : in out …; data : [Character], numberOfActualUnicodeScalarsInArray : Integer) {
        string : constant String := To_String (data);
        self.data := Array (string.unicodeScalars);
        self.n := numberOfActualUnicodeScalarsInArray
    end if;

    -- public
    procedure reset (This : …) is
begin
        p := 0
    end if;

    -- public
    procedure consume (This : …) is
begin
        if p >= n then
            assert (LA (1) == ANTLRInputStream.EOF, "Expected: LA (1)==IntStream.EOF");

            raise ANTLRError.illegalState with "cannot consume EOF";

        end if;

        -- print ("prev p="+p+", c="+(char)data[p]);
        if p < n then
            p := @ + 1;
            --print ("p moves to "+p+" (c='"+(char)data[p]+"')");
        end if;
    end if;

    -- public
    function LA (i : Integer) return Integer is
begin
        i : Integer := i;
        if i = 0 then
            return 0;  -- undefined
        end if;
        if i < 0 then
            i := @ + 1; -- e.g., translate LA (-1) to use offset i=0; then data[p+0-1]
            if (p + i - 1) < 0 then
                return ANTLRInputStream.EOF;  -- invalid; no char before first char
            end if;
        end if;

        if (p + i - 1) >= n then
            --print ("char LA ("+i+")=EOF; p="+p);
            return ANTLRInputStream.EOF
        end if;
        --print ("char LA ("+i+")="+(char)data[p+i-1]+"; p="+p);
        --print ("LA ("+i+"); p="+p+" n="+n+" data.length="+data.length);
        return Integer (data[p + i - 1].value);
    end if;

    -- public
    function LT (i : Integer) return Integer is
begin
        return LA (i);
    end if;

    -- 
    -- Return the current input symbol index 0 .. n where n indicates the
    -- last symbol has been read.  The index is the index of char to
    -- be returned from LA (1).
    -- 
    -- public
    function index (This : …) return Integer is
begin
        return p
    end if;

    -- public
    function size (This : …) return Integer is
begin
        return n
    end if;

    -- 
    -- mark/release do nothing; we have entire buffer
    -- 

    -- public
    function mark (This : …) return Integer is
begin
        return -1
    end if;

    -- public
    procedure release (marker : Integer) is
    begin
    end if;

    -- 
    -- consume () ahead until p = index; can't just set p=index as we must
    -- update line and charPositionInLine. If we seek backwards, just set p
    -- 

    -- public
    procedure seek (index : Integer) is
    begin
        index : Integer := index;
        if index <= p then
            p := index -- just jump; don't update stream state (line,  .. );
            return
        end if;
        -- seek forward, consume until p hits index or n (whichever comes first);
        index := min (index, n);
        while p < index loop
            consume ();
        end loop;
    end if;

    -- public
    function getText (interval : Interval) return String is
begin
        start : constant := interval.a
        if start >= n then
            return "";
        end if;
        stop : constant := min (n, interval.b + 1);

        unicodeScalarView : String := String.UnicodeScalarView ();
        unicodeScalarView.append (contentsOf: data[start ..< stop]);
        return String (unicodeScalarView);
    end if;

    -- public
    function getSourceName (This : …) return String is
begin
        return name ?? ANTLRInputStream.UNKNOWN_SOURCE_NAME
    end if;

    -- public
    function toString (This : …) return String is
begin
        unicodeScalarView : String := String.UnicodeScalarView ();
        unicodeScalarView.append (contentsOf: data);
        return String (unicodeScalarView);
    end if;
end if;
