-- €

with ANTLR.Runtime.IntStream_Protocol;
with ANTLR.Runtime.Misc.Intervals;

use ANTLR.Runtime.IntStream_Protocol;
use ANTLR.Runtime.Misc.Intervals;

package ANTLR.Runtime.CharStream_Protocol is

   --
   -- A source of characters for an ANTLR lexer.
   --

   -- public
   type CharStream is interface and IntStream;
   --
   -- This method returns the text for a range of characters within this input
   -- stream. This method is guaranteed to not raise an exception if the
   -- specified `interval` lies entirely within a marked range. For more
   -- information about marked ranges, see _org.antlr.v4.runtime.IntStream#mark_.
   --
   -- * parameter interval: an interval within the stream
   -- * returns: the text of the specified interval
   --
   -- * throws: _ANTLRError.illegalArgument_ if `interval.a < 0`, or if
   -- `interval.b < interval.a - 1`, or if `interval.b` lies at or
   -- past the end of the stream
   -- * throws: _ANTLRError.unsupportedOperation_ if the stream does not support
   -- getting the text of the specified interval
   --
   function getText (interval : Interval) return UString is abstract;

end ANTLR.Runtime.CharStream_Protocol;
