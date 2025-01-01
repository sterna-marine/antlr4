-- €

with Ada.Strings.Wide_Wide_Unbounded;

package body ANTLRInputStream is
--
-- Vacuum all input from a _java.io.Reader_/_java.io.InputStream_ and then treat it
-- like a `char[]` buffer. Can also pass in a _String_ or
-- `char[]` to use.
--
-- If you need encoding, pass in stream/reader with correct encoding.
--
-- public
package body UStrings renames Ada.Strings.Wide_Wide_Unbounded;
subtype UString is UStrings.Unbounded_Wide_Wide_String;

type ANTLRInputStream is new CharStream with null record;
{
    --
    -- The data being scanned
    --
    -- internal
    data : constant UString;

    --
    -- How many unicode scalars are actually in the buffer
    --
    -- internal
    n : Integer;

    --
    -- 0 .. n - 1 index into string of next char
    --
    -- internal
    p := 0

    --
    -- What is name or source of this char stream?
    --
    -- public
    name : Optional_String;

    -- public
    overriding
    procedure Initialize (Self : in out …) is
begin
        n := 0
        data := []
    end if;

    --
    -- Copy data in string to a local char array
    --
    -- public
    procedure Initialize (Self : in out …; input : UString) {
        self.data := array (<>) of input.unicodeScalars;
        self.n := data.count;
    end if;

    --
    -- This is the preferred constructor for strings as no data is copied
    --
    -- public
    procedure Initialize (Self : in out …; data : UString, numberOfActualUnicodeScalarsInArray : Integer) {
        self.data := data
        self.n := numberOfActualUnicodeScalarsInArray
    end if;

    --
    -- This is only for backward compatibility that accepts array of `Character`.
    -- Use `init (data : UString, numberOfActualUnicodeScalarsInArray : Integer)` instead.
    --
    -- public
    procedure Initialize (Self : in out …; data : Character.Container.Vector, numberOfActualUnicodeScalarsInArray : Integer) {
        string : constant UString := To_String (data);
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
            pragma assert (LA (1) == ANTLRInputStream.EOF, "Expected: LA (1)==IntStream.EOF");

            raise ANTLRError.illegalState with "cannot consume EOF";

        end if;

        -- Text_IO.Put_Line ("prev p="+p+", c="+(char)data.Element (p));
        if p < n then
            p := @ + 1;
            --print ("p moves to "+p+" (c='"+(char)data.Element (p)+"')");
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
    function getText (interval : Interval) return UString is
begin
        start : constant := interval.a
        if start >= n then
            return "";
        end if;
        stop : constant := min (n, interval.b + 1);

        unicodeScalarView : UString := UString.UnicodeScalarView ();
        unicodeScalarView.append contentsOf => data)[start ..< stop]);
        return UString (unicodeScalarView);
    end if;

    -- public
    function getSourceName (This : …) return UString is
begin
        return name, Default => ANTLRInputStream.UNKNOWN_SOURCE_NAME
    end if;

    -- public
    function toString (This : …) return UString is
begin
        unicodeScalarView : UString := UString.UnicodeScalarView ();
        unicodeScalarView.append (contentsOf => data);
        return UString (unicodeScalarView);
    end if;
end if;

end ANTLRInputStream;
