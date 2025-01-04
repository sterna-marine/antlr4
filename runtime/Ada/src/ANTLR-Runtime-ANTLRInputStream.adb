-- €

with Ada.Strings.Wide_Wide_Unbounded;
with Ada.Wide_Wide_Text_IO;
with ANTLR.Runtime.IntStream_Protocol.Extensions;
with Aspect;

use Ada;
use ANTLR.Runtime.IntStream_Protocol.Extensions;
use Aspect;

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

   type ANTLRInputStream is new CharStream with
   record
      --
      -- The data being scanned
      --
      -- internal
      data : constant UString;

      --
      -- How many unicode scalars are actually in the buffer
      --
      -- internal
      n : Integer := 0;

      --
      -- 0 .. n - 1 index into string of next char
      --
      -- internal
      p : Integer := 0;

      --
      -- What is name or source of this char stream?
      --
      -- public
      name : Optional_UString;
   end record;

   -- public
   overriding
   procedure Initialize (Self : in out …) is
   begin
      Self.n := 0;
      Self.data := ""
   end Initialize;

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
   procedure Initialize (Self : in out …; data : Character_List, numberOfActualUnicodeScalarsInArray : Integer) {
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
      if Is_Active (Aspect.DEBUG) then
         Wide_Wide_Text_IO.Put_Line ("prev p=" & p & ", c=" & (char)data.Element (p));
      end if;
      if p < n then
         p := @ + 1;
         if Is_Active (Aspect.DEBUG) then
            Wide_Wide_Text_IO.Put_Line ("p moves to " & p & " (c='" & (char)data.Element (p) & "')");
         end if;
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
         if Is_Active (Aspect.DEBUG) then
            Wide_Wide_Text_IO.Put_Line ("char LA (" & i & ")=EOF; p=" & p);
         end if;
         return ANTLRInputStream.EOF
      end if;
      if Is_Active (Aspect.DEBUG) then
         Wide_Wide_Text_IO.Put_Line ("char LA (" & i & ")=" & (char)data[p+i-1] & "; p=" & p);
         Wide_Wide_Text_IO.Put_Line ("LA (" & i & "); p=" & p & " n=" & n & " data.length=" & data.length);
      end if;
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
   -- This.consume ahead until p = index; can't just set p=index as we must
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
         This.consume;
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
      return name, Default => UNKNOWN_SOURCE_NAME
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
