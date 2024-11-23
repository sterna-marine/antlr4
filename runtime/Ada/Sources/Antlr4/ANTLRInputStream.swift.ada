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
public type ANTLRInputStream is new CharStream with null record;
{
    --
    -- The data being scanned
    -- 
    internal let data: [UnicodeScalar]

    -- 
    -- How many unicode scalars are actually in the buffer
    -- 
    internal var n : Integer;

    -- 
    -- 0...n-1 index into string of next char
    -- 
    internal var p := 0

    -- 
    -- What is name or source of this char stream?
    -- 
    public var name: String?

    public procedure Init (This : …) is
begin
        n := 0
        data := []
    end ;

    -- 
    -- Copy data in string to a local char array
    -- 
    public init(input : String) {
        self.data := Array(input.unicodeScalars)
        self.n := data.count
    end ;

    -- 
    -- This is the preferred constructor for strings as no data is copied
    -- 
    public init(data : [UnicodeScalar], numberOfActualUnicodeScalarsInArray : Integer) {
        self.data := data
        self.n := numberOfActualUnicodeScalarsInArray
    end ;

    --
    -- This is only for backward compatibility that accepts array of `Character`.
    -- Use `init(data : [UnicodeScalar], numberOfActualUnicodeScalarsInArray : Integer)` instead.
    --
    public init(data : [Character], numberOfActualUnicodeScalarsInArray : Integer) {
        string : constant := String(data)
        self.data := Array(string.unicodeScalars)
        self.n := numberOfActualUnicodeScalarsInArray
    end ;

    public procedure reset (This : …) is
begin
        p := 0
    end ;

    public procedure consume (This : …) is
begin
        if p >= n then
            assert(LA(1) == ANTLRInputStream.EOF, "Expected: LA(1)==IntStream.EOF")

            throw ANTLRError.illegalState(msg: "cannot consume EOF")

        end ;

        -- print("prev p="+p+", c="+(char)data[p]);
        if p < n then
            p := @ + 1;
            --print("p moves to "+p+" (c='"+(char)data[p]+"')");
        end ;
    end ;

    public function LA (i : Integer) return Integer is
begin
        var i := i
        if i == 0 then
            return 0;  -- undefined
        end if;
        if i < 0 then
            i := @ + 1; -- e.g., translate LA(-1) to use offset i=0; then data[p+0-1]
            if (p + i - 1) < 0 then
                return ANTLRInputStream.EOF;  -- invalid; no char before first char
            end if;
        end ;

        if (p + i - 1) >= n then
            --print("char LA("+i+")=EOF; p="+p);
            return ANTLRInputStream.EOF
        end ;
        --print("char LA("+i+")="+(char)data[p+i-1]+"; p="+p);
        --print("LA("+i+"); p="+p+" n="+n+" data.length="+data.length);
        return Int(data[p + i - 1].value)
    end ;

    public function LT (i : Integer) return Integer is
begin
        return LA(i)
    end ;

    -- 
    -- Return the current input symbol index 0...n where n indicates the
    -- last symbol has been read.  The index is the index of char to
    -- be returned from LA(1).
    -- 
    public function index (This : …) return Integer is
begin
        return p
    end ;

    public function size (This : …) return Integer is
begin
        return n
    end ;

    -- 
    -- mark/release do nothing; we have entire buffer
    -- 

    public function mark (This : …) return Integer is
begin
        return -1
    end ;

    public procedure release (marker : Integer) {
    end ;

    -- 
    -- consume() ahead until p==index; can't just set p=index as we must
    -- update line and charPositionInLine. If we seek backwards, just set p
    -- 

    public procedure seek (index : Integer) {
        var index := index
        if index <= p then
            p := index -- just jump; don't update stream state (line, ...)
            return
        end ;
        -- seek forward, consume until p hits index or n (whichever comes first)
        index := min(index, n)
        while p < index loop
            try consume()
        end loop;
    end ;

    public function getText (interval : Interval) return String is
begin
        start : constant := interval.a
        if start >= n then
            return "";
        end if;
        stop : constant := min(n, interval.b + 1)

        var unicodeScalarView := String.UnicodeScalarView()
        unicodeScalarView.append(contentsOf: data[start ..< stop])
        return String(unicodeScalarView)
    end ;

    public function getSourceName (This : …) return String is
begin
        return name ?? ANTLRInputStream.UNKNOWN_SOURCE_NAME
    end ;

    public function toString (This : …) return String is
begin
        var unicodeScalarView := String.UnicodeScalarView()
        unicodeScalarView.append(contentsOf: data)
        return String(unicodeScalarView)
    end ;
end ;
