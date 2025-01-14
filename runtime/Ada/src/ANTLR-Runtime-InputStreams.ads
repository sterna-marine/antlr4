-- €

with Ada.Finalize
with Ada.Strings.Wide_Wide_Unbounded;
with ANTLR.Runtime.IntStream_Protocol.Extensions;
with ANTLR.Runtime.Misc.Exceptions.Errors;
with ANTLR.Runtime.Misc.Intervals;

use ANTLR.Runtime.IntStream_Protocol.Extensions;
use ANTLR.Runtime.Misc.Exceptions.Errors;
use ANTLR.Runtime.Misc.Intervals;

package ANTLR.Runtime.InputStreams is
   --
   -- Vacuum all input from a _java.io.Reader_/_java.io.InputStream_ and then treat it
   -- like a `char[]` buffer. Can also pass in a _String_ or
   -- `char[]` to use.
   --
   -- If you need encoding, pass in stream/reader with correct encoding.
   --
   -- public

   type ANTLRInputStream is new Ada.Finalize.Controlled and CharStream with
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
   procedure Initialize (Self : in out ANTLRInputStream);

   --
   -- Copy data in string to a local char array
   --
   -- public
   procedure Initialize (Self : in out ANTLRInputStream; input : UString);

   --
   -- This is the preferred constructor for strings as no data is copied
   --
   -- public
   procedure Initialize (Self : in out ANTLRInputStream; 
                         data : UString;
                         numberOfActualUnicodeScalarsInArray : Integer);

   --
   -- This is only for backward compatibility that accepts array of `Character`.
   -- Use `init (data : UString, numberOfActualUnicodeScalarsInArray : Integer)` instead.
   --
   -- public
   procedure Initialize (Self : in out ANTLRInputStream;
                         data : Character_List,
                         numberOfActualUnicodeScalarsInArray : Integer);

   -- public
   procedure reset (This : ANTLRInputStream);

   -- public
   procedure consume (This : ANTLRInputStream);

   -- public
   function LA (This : ANTLRInputStream; i : Integer) return Integer;

   -- public
   function LT (This : ANTLRInputStream; i : Integer) return Integer
      is (This.LA (i));

   --
   -- Return the current input symbol index 0 .. n where n indicates the
   -- last symbol has been read.  The index is the index of char to
   -- be returned from LA (1).
   --
   -- public
   function index (This : ANTLRInputStream) return Integer
      is (This.p);

   -- public
   function size (This : ANTLRInputStream) return Integer
      is (This.n);

   --
   -- mark/release do nothing; we have entire buffer
   --

   -- public
   function mark (This : ANTLRInputStream) return Integer
      is (-1);

   -- public
   procedure release (This : ANTLRInputStream; marker : Integer);

   --
   -- This.consume ahead until p = index; can't just set p=index as we must
   -- update line and charPositionInLine. If we seek backwards, just set p
   --

   -- public
   procedure seek (This : ANTLRInputStream; index : Integer);

   -- public
   function getText (This : ANTLRInputStream; interval : Interval) return UString;

   -- public
   function getSourceName (This : ANTLRInputStream) return UString
      is Set (name, Default => UNKNOWN_SOURCE_NAME);

   -- public
   function toString (This : ANTLRInputStream) return UString;

end ANTLRInputStream;
