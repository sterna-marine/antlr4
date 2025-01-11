-- €

package body ANTLR.Runtime.ProxyErrorListeners is

   procedure Initialize (Self : in out ProxyErrorListener; delegates : ANTLRErrorListener_List) is
   begin
      self.delegates := delegates;
   end Initialize;

   procedure syntaxError (This : ProxyErrorListener;
                          recognizer : Recognizer_T;
                          offendingSymbol : Optional_AnyObject;
                          line : Integer;
                          charPositionInLine : Integer;
                          msg : UString;
                          e : Optional_AnyObject) is
   begin
      for listener of This.delegates loop
         listener.syntaxError (recognizer, offendingSymbol, line, charPositionInLine, msg, e);
      end loop;
   end syntaxError;

   procedure reportAmbiguity (This : ProxyErrorListener;
                              recognizer : Parser;
                              dfa : DFA;
                              startIndex : Integer;
                              stopIndex : Integer;
                              exact : Boolean;
                              ambigAlts : BitSet;
                              configs : ATNConfigSet) is
   begin
      for listener of This.delegates loop
         listener.reportAmbiguity (recognizer, dfa, startIndex, stopIndex, exact, ambigAlts, configs);
      end loop;
   end reportAmbiguity;

   procedure reportAttemptingFullContext (recognizer : Parser;
                                          dfa : DFA;
                                          startIndex : Integer;
                                          stopIndex : Integer;
                                          conflictingAlts : Optional_BitSet;
                                          configs : ATNConfigSet) is
   begin
      for listener of This.delegates loop
         listener.reportAttemptingFullContext (recognizer, dfa, startIndex, stopIndex, conflictingAlts, configs);
      end loop;
   end reportAttemptingFullContext;

   procedure reportContextSensitivity (recognizer : Parser;
                                       dfa : DFA;
                                       startIndex : Integer;
                                       stopIndex : Integer;
                                       prediction : Integer;
                                       configs : ATNConfigSet) is
   begin
      for listener of This.delegates loop
         listener.reportContextSensitivity (recognizer, dfa, startIndex, stopIndex, prediction, configs);
      end loop;
   end reportContextSensitivity;

end ANTLR.Runtime.ProxyErrorListener;
