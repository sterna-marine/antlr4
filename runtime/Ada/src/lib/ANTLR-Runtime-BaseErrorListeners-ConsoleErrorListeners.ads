-- €

with ANTLR.Runtime.ATN.ConfigSets;
with ANTLR.Runtime.DFA;
with ANTLR.Runtime.ErrorListener_Protocol;
with ANTLR.Runtime.Misc.BitSets;
with ANTLR.Runtime.Recognizer;
with ANTLR.Runtime.Parsers;

use ANTLR.Runtime.ATN.ConfigSets;
use ANTLR.Runtime.BaseErrorListeners;
use ANTLR.Runtime.DFA;
use ANTLR.Runtime.ErrorListener_Protocol;
use ANTLR.Runtime.Misc.BitSets;
use ANTLR.Runtime.Recognizer;
use ANTLR.Runtime.Parsers;

use ANTLR.Runtime.BaseErrorListeners;

package ANTLR.Runtime.BaseErrorListeners.ConsoleErrorListeners is

   --
   --
   -- *  Sam Harwell
   --

   -- public
   type ConsoleErrorListener;
   type ConsoleErrorListener is new BaseErrorListener with null record;

   --
   -- Provides a default instance of _org.antlr.v4.runtime.ConsoleErrorListener_.
   --
   -- public static
   INSTANCE : ConsoleErrorListener; -- constant

   --
   --
   -- This implementation prints messages to _System#err_ containing the
   -- values of `line`, `charPositionInLine`, and `msg` using
   -- the following format.
   --
   -- line __line__:__charPositionInLine__ __msg__
   --
   --

   package Recognizers_T is new Recognizers (T);
   subtype Recognizer_T is Recognizers_T.Recognizer;

   -- public
   overriding
   procedure syntaxError (This : ConsoleErrorListener;
                          recognizer : Recognizer_T;
                          offendingSymbol : Optional_AnyObject;
                          line : Integer;
                          charPositionInLine : Integer;
                          msg : UString;
                          e : Optional_AnyObject);

end ANTLR.Runtime.BaseErrorListeners.ConsoleErrorListeners;
