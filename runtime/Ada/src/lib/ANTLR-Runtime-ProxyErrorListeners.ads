-- €

with ANTLR.Runtime.ATN.ConfigSets;
with ANTLR.Runtime.ErrorListener_Protocol;
with ANTLR.Runtime.Misc.BitSets;
with ANTLR.Runtime.Parsers;

use ANTLR.Runtime.ATN.ConfigSets;
use ANTLR.Runtime.ErrorListener_Protocol;
use ANTLR.Runtime.Misc.BitSets;
use ANTLR.Runtime.Parsers;

package ANTLR.Runtime.ProxyErrorListeners is
   --
   -- This implementation of _org.antlr.v4.runtime.ANTLRErrorListener_ dispatches all calls to a
   -- collection of delegate listeners. This reduces the effort required to support multiple
   -- listeners.
   --
   -- * Author: Sam Harwell
   --

   -- public
   type ProxyErrorListener is new ANTLRErrorListener with
   record
      -- private final
      delegates : ANTLRErrorListener_List;
   end record;

   -- public
   procedure Initialize (Self : in out ProxyErrorListener; delegates : ANTLRErrorListener_List);
   begin
      self.delegates := delegates;
   end Initialize;

   package Recognizers_T is new Recognizers (T);
   subtype Recognizer_T is Recognizers_T.Recognizer;

   -- public
   procedure syntaxError (This : ProxyErrorListener;
                          recognizer : Recognizer_T;
                          offendingSymbol : Optional_AnyObject;
                          line : Integer;
                          charPositionInLine : Integer;
                          msg : UString;
                          e : Optional_AnyObject);

   -- public
   procedure reportAmbiguity (This : ProxyErrorListener;
                              recognizer : Parser;
                              dfa : DFA;
                              startIndex, stopIndex : Integer;
                              exact : Boolean;
                              ambigAlts : BitSet;
                              configs : ATNConfigSet);

   -- public
   procedure reportAttemptingFullContext (recognizer : Parser;
                                          dfa : DFA;
                                          startIndex, stopIndex : Integer;
                                          conflictingAlts : Optional_BitSet;
                                          configs : ATNConfigSet);

   -- public
   procedure reportContextSensitivity (recognizer : Parser;
                                       dfa : DFA;
                                       startIndex, stopIndex : Integer;
                                       prediction : Integer;
                                       configs : ATNConfigSet);

end ANTLR.Runtime.ProxyErrorListener;
