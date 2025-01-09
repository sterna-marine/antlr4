-- €

package body ANTLR.Runtime.BaseErrorListeners is

   overriding
   procedure Initialize (Self : in out BaseErrorListener) is null;

   procedure syntaxError (This : BaseErrorListener;
                          recognizer : Recognizer_T,
                          offendingSymbol : Optional_AnyObject;
                          line : Integer;
                          charPositionInLine : Integer;
                          msg : UString;
                          e : Optional_AnyObject) is null;

   procedure reportAmbiguity (This : BaseErrorListener;
                              recognizer : Parser;
                              dfa : DFA;
                              startIndex : Integer;
                              stopIndex : Integer;
                              exact : Boolean;
                              ambigAlts : BitSet;
                              configs : ATNConfigSet) is null;

   procedure reportAttemptingFullContext (This : BaseErrorListener;
                                          recognizer : Parser;
                                          dfa : DFA;
                                          startIndex : Integer;
                                          stopIndex : Integer;
                                          conflictingAlts : Optional_BitSet;
                                          configs : ATNConfigSet) is null;

   procedure reportContextSensitivity (This : BaseErrorListener;
                                       recognizer : Parser;
                                       dfa : DFA;
                                       startIndex : Integer;
                                       stopIndex : Integer;
                                       prediction : Integer;
                                       configs : ATNConfigSet) is null;

end ANTLR.Runtime.BaseErrorListeners;
