-- €

package body ANTLR.Runtime.BaseErrorListener.DiagnosticErrorListeners is

   overriding
   procedure Initialize (Self : in out DiagnosticErrorListener) is
   begin
      Self.Initialize (True);
   end Initialize;

   procedure Initialize (Self : in out DiagnosticErrorListener; exactOnly  : Boolean) is
   begin
      self.exactOnly := exactOnly;
   end Initialize;

   overriding
   procedure reportAmbiguity (This : DiagnosticErrorListener; 
                              recognizer : Parser;
                              dfa : DFA;
                              startIndex, stopIndex : Integer;
                              exact : Boolean;
                              ambigAlts : BitSet;
                              configs : ATNConfigSet) is
   begin
      if This.exactOnly and then not exact then
         return;
      else
         decision : constant := getDecisionDescription (recognizer, dfa);
         conflictingAlts : constant := getConflictingAlts (ambigAlts, configs);
         text : constant := getTextInInterval (recognizer, startIndex, stopIndex);
         message : constant := "reportAmbiguity d=" & decision'Image & ": ambigAlts=" & conflictingAlts'Image & ", input='" & text'Image & ''';
         recognizer.notifyErrorListeners (message);
      end if;
   end reportAmbiguity;

   overriding
   procedure reportAttemptingFullContext (This : DiagnosticErrorListener;
                                          recognizer : Parser;
                                          dfa : DFA;
                                          startIndex, stopIndex : Integer;
                                          conflictingAlts : Optional_BitSet;
                                          configs : ATNConfigSet) is
      decision : constant := getDecisionDescription (recognizer, dfa);
      text : constant := getTextInInterval (recognizer, startIndex, stopIndex);
      message : constant := "reportAttemptingFullContext d=" & decision'Image
                          & ", input='" & text'Image & ''';
   begin
      recognizer.notifyErrorListeners (message);
   end reportAttemptingFullContext;

   overriding
   procedure reportContextSensitivity (This : DiagnosticErrorListener;
                                       recognizer : Parser;
                                       dfa : DFA;
                                       startIndex, stopIndex : Integer;
                                       prediction : Integer;
                                       configs : ATNConfigSet) is
      decision : constant := getDecisionDescription (recognizer, dfa);
      text : constant := getTextInInterval (recognizer, startIndex, stopIndex);
      message : constant := "reportContextSensitivity d=" & decision'Image
                          & ", input='" & text'Image & ''';
   begin
      recognizer.notifyErrorListeners (message);
   end reportContextSensitivity;

   function getDecisionDescription (This : DiagnosticErrorListener;
                                    recognizer : Parser;
                                    dfa : DFA)
                                    return UString is
      decision : constant Integer := dfa.decision;
      ruleIndex : constant Integer := Value (dfa.atnStartState.ruleIndex);
      ruleNames : constant UString_List := recognizer.getRuleNames;
   begin
      if not ruleNames.indices.contains (ruleIndex) then
         return UString (decision);
      end if;

      ruleName : constant UString := ruleNames.Element (ruleIndex);
      --  if not Is_Valid (ruleName) or else ruleName.Is_Empty then
      if ruleName.Is_Empty then
         return UString (decision);
      else
         return decision'Image & " (" & ruleName'Image & ')';
      end if;
   end getDecisionDescription;

   function getConflictingAlts (This : DiagnosticErrorListener;
                                reportedAlts : Optional_BitSet;
                                configs : ATNConfigSet)
                                return BitSet is
   begin
      return Set (reportedAlts, Default => configs.getAltBitSet);
   end getConflictingAlts;

   function getTextInInterval (recognizer : Parser;
                               startIndex, stopIndex : Integer)
                               return UString is
   begin
      return Set (Value (recognizer.getTokenStream).getText (Interval.Set (startIndex, stopIndex)), Default => "<unknown>");
   exception
      when others =>
         return "<unknown>";
   end getTextInInterval;

end ANTLR.Runtime.BaseErrorListener.DiagnosticErrorListeners;
