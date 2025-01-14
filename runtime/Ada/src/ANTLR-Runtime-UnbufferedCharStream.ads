-- €

with Ada.Finalization;
with ANTLR.Runtime.CharStream_Protocol;
with ANTLR.Runtime.InputStream;
with ANTLR.Runtime.Misc.Exceptions.Errors;
with ANTLR.Runtime.Misc.Intervals;
with ANTLR.Runtime.Token_Protocol;
with ANTLR.Runtime.TokenSource_Protocol;
with ANTLR.Runtime.WritableTokens.CommonTokens;
with Interfaces;

use ANTLR.Runtime.CharStream_Protocol;
use ANTLR.Runtime.InputStream;
use ANTLR.Runtime.Misc.Exceptions.Errors;
use ANTLR.Runtime.Misc.Intervals;
use ANTLR.Runtime.Token_Protocol;
use ANTLR.Runtime.TokenSource_Protocol;
use ANTLR.Runtime.WritableTokens.CommonTokens;
use Interfaces;

package ANTLR.Runtime.UnbufferedCharStream is

   -- -------------------- --
   -- UnbufferedCharStream --
   -- -------------------- --
   -- Do not buffer up the entire char stream. It does keep a small buffer
   -- for efficiency and also buffers while a mark exists (set by the
   -- lookahead prediction in parser). "Unbuffered" here refers to fact
   -- that it doesn't buffer all data, not that's it's on demand loading of char.
   --
   -- Before 4.7, this class used the default environment encoding to convert
   -- bytes to UTF-16, and held the UTF-16 bytes in the buffer as chars.
   --
   -- As of 4.7, the class uses UTF-8 by default, and the buffer holds Unicode
   -- code points in the buffer as ints.
   --

   -- private static
   bufferSize : constant Positive := 1024;

   -- open
   type UnbufferedCharStream is new CharStream with
   record
      -- private
      bufferSize : Positive; -- constant

      --
      -- A moving window buffer of the data being scanned. While there's a marker,
      -- we keep adding to buffer. Otherwise, {@link #consume This.consume} resets so
      -- we start filling at index 0 again.
      --
      -- internal
      data : Integer_List;

      --
      -- The number of characters currently in {@link #data data{}}.
      --
      -- <p>This is not the buffer capacity, that's {@code data.length}.</p>
      --
      -- internal
      n : Integer := 0;

      --
      -- 0 .. n - 1 index into {@link #data data} of next character.
      --
      -- <p>The {@code LA (1)}; character is {@code data.Element (p)}. if then@code p = n}, we are
      -- out of buffered characters.</p>
      --
      -- internal
      p : Integer := 0;

      --
      -- Count up with {@link #mark This.mark} and down with
      -- {@link #release This.release}. When we {@code This.release} the last mark,
      -- {@code numMarkers} reaches 0 and we reset the buffer. Copy
      -- {@code data.Element (p)..data[n - 1]} to {@code data.Element (0)..data[(n - 1)-p]}.
      --
      -- internal
      numMarkers : Integer := 0;

      --
      -- This is the {@code LA (-1)} character for the current position.
      --
      -- internal
      lastChar : Integer := -1;

      --
      -- When {@code numMarkers > 0}, this is the {@code LA (-1)} character for the
      -- first character in {@link #data data}. Otherwise, this is unspecified.
      --
      -- internal
      lastCharBufferStart : Integer := 0;

      --
      -- Absolute character index. It's the index of the character about to be
      -- read via {@code LA (1)}. Goes from 0 to the number of characters in the
      -- entire stream, although the stream size is unknown before the end is
      -- reached.
      --
      -- internal
      currentCharIndex : Integer := 0;

      -- internal
      input : InputStream; -- constant
      -- private
      unicodeIterator : UnicodeScalarStreamIterator;

      -- The name or source of this char stream.--
      -- public
      name : UString := "";
   end record;

   -- public
   procedure Initialize (Self : in out UnbufferedCharStream;
                        input : InputStream;
                        bufferSize : Integer := 256);

   -- public
   procedure consume (This : UnbufferedCharStream);

   --
   -- Make sure we have 'need' elements from current position {@link #p p}.
   -- Last valid {@code p} index is {@code data.length-1}. {@code p+need-1} is
   -- the char index 'need' elements ahead. If we need 1 element,
   -- {@code (p+1-1)==p} must be less than {@code data.length}.
   --
   -- internal
   procedure sync (This : UnbufferedCharStream; want : Integer);

   --
   -- Add {@code n} characters to the buffer. Returns the number of characters
   -- actually added to the buffer. if the return value is less than then@code n},
   -- then EOF was reached before {@code n} characters could be added.
   --
   -- @discardableResult
   -- internal
   function fill (This : UnbufferedCharStream; toAdd : Integer) return Integer;

   --
   -- Override to provide different source of characters than
   -- {@link #input input}.
   --
   -- internal
   function nextChar (This : UnbufferedCharStream) return Optional_Integer;

   -- internal
   procedure add (This : UnbufferedCharStream; c : Integer);

   -- public
   function LA (This : UnbufferedCharStream; i : Integer) return Integer;

   --
   -- Return a marker that we can release later.
   --
   -- <p>The specific marker value used for this class allows for some level of
   -- protection against misuse where {@code This.seek} is called on a mark or
   -- {@code This.release} is called in the wrong order.</p>
   --
   -- public
   function mark (This : UnbufferedCharStream) return Integer;

   -- Decrement number of markers, resetting buffer if we hit 0.
   -- @param marker
   --
   -- public
   procedure release (This : UnbufferedCharStream; marker : Integer);

   -- public
   function index (This : UnbufferedCharStream) return Integer
      is (This.(currentCharIndex));

   -- Seek to absolute character index, which might not be in the current
   --  sliding window.  Move {@code p} to {@code index-bufferStartIndex}.
   --
   -- public
   procedure seek (This : UnbufferedCharStream; index_to_seek : Integer);

   -- public
   function size (This : UnbufferedCharStream) return Integer
      is (This.preconditionFailure ("Unbuffered stream cannot know its size"));

   -- public
   function getSourceName (This : UnbufferedCharStream) return UString
      is (This.name);

   -- public
   function getText (This : UnbufferedCharStream; interval : Interval) return UString;

   -- internal
   function getBufferStartIndex (This : UnbufferedCharStream) return Integer
      is (This.currentCharIndex - This.p);

   -- ------------------------ --
   -- Unsigned_8StreamIterator --
   -- ------------------------ --
   package IndexingIterator_ArraySlice is new ArraySlice (Unsigned_8); --TOFIX
   subtype IndexingIterator is IndexingIterator_ArraySlice;

   -- fileprivate 
   type Unsigned_8StreamIterator is new Ada.Finalization.Controlled -- and  IteratorProtocol
   with record
      -- private
      stream : constant InputStream;
      -- private
      buffer : Unsigned_8_List := Unsigned_8.Container.To_Vector (repeating => 0, count => Unsigned_8StreamIterator.bufferSize);
      -- private
      buffGen : IndexingIterator;

      hasErrorOccurred := False;
   end record;

   procedure Initialize (Self : Unsigned_8StreamIterator; stream : InputStream);

   -- mutating
   function next (This : Unsigned_8StreamIterator) return Optional_unsigned_short;

   -- --------------------------- --
   -- UnicodeScalarStreamIterator --
   -- --------------------------- --
   -- fileprivate
   type UnicodeScalarStreamIterator is new Ada.Finalization.Controlled -- and IteratorProtocol
   with record
      -- private
      streamIterator : Unsigned_8StreamIterator;
      -- private
      codec : Unicode.UTF8;

      hasErrorOccurred := False;
   end record:

   procedure Initialize (Self : UnicodeScalarStreamIterator; streamIterator : Unsigned_8StreamIterator);

   -- mutating
   function next (This : UnicodeScalarStreamIterator) return Unicode.Optional_Scalar;

end ANTLR.Runtime.UnbufferedCharStream;
