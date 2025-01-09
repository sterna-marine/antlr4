-- €

with ANTLR.Runtime.ATN.ConfigSets;
with ANTLR.Runtime.DFA;
with ANTLR.Runtime.ErrorListener_Protocol;
with ANTLR.Runtime.Misc.BitSets;
with ANTLR.Runtime.Recognizers;
with ANTLR.Runtime.Recognizers.Parsers;

use ANTLR.Runtime.ATN.ConfigSets;
use ANTLR.Runtime.DFA;
use ANTLR.Runtime.ErrorListener_Protocol;
use ANTLR.Runtime.Misc.BitSets;
use ANTLR.Runtime.Recognizers;
use ANTLR.Runtime.Recognizers.Parsers;

package ANTLR.Runtime.BaseErrorListeners is

   --
   -- Provides an empty default implementation of _org.antlr.v4.runtime.ANTLRErrorListener_. The
   -- default implementation of each method does nothing, but can be overridden as
   -- necessary.
   --
   -- *  Sam Harwell
   --

   -- open
   type BaseErrorListener is new ANTLRErrorListener with null record;

   -- public
   overriding
   procedure Initialize (Self : in out BaseErrorListener);

   -- open
   generic
      type T is private;
      package Recognizers_T is new Recognizers (T);  --TOFIX
      subtype Recognizer_T is Recognizers_T.Recognizer; --TOFIX
   procedure syntaxError (This : BaseErrorListener;
                          recognizer : Recognizer_T,
                          offendingSymbol : Optional_AnyObject;
                          line : Integer;
                          charPositionInLine : Integer;
                          msg : UString;
                          e : Optional_AnyObject);

   -- open
   procedure reportAmbiguity (This : BaseErrorListener;
                              recognizer : Parser;
                              dfa : DFA;
                              startIndex : Integer;
                              stopIndex : Integer;
                              exact : Boolean;
                              ambigAlts : BitSet;
                              configs : ATNConfigSet);

   -- open
   procedure reportAttemptingFullContext (This : BaseErrorListener;
                                          recognizer : Parser;
                                          dfa : DFA;
                                          startIndex : Integer;
                                          stopIndex : Integer;
                                          conflictingAlts : Optional_BitSet;
                                          configs : ATNConfigSet);

   -- open
   procedure reportContextSensitivity (This : BaseErrorListener;
                                       recognizer : Parser;
                                       dfa : DFA;
                                       startIndex : Integer;
                                       stopIndex : Integer;
                                       prediction : Integer;
                                       configs : ATNConfigSet);

end ANTLR.Runtime.BaseErrorListeners;
