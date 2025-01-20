-- €

package body ANTLR.Runtime.RecognitionExceptions.FailedPredicateExceptions is

   procedure Initialize (Self : FailedPredicateException;
                         recognizer : Parser;
                         predicate : Optional_UString := (Valid => False);
                         message : Optional_UString := (Valid => False)) is
      s : constant ATNState := recognizer.getInterpreter.atn.states.Element (Value (recognizer.getState));
      trans : constant AbstractPredicateTransition := AbstractPredicateTransition (s.transition (0));
      predex : constant PredicateTransition := PredicateTransition (trans);
   begin
      if Is_Valid (predex) then
         self.ruleIndex := predex.ruleIndex;
         self.predicateIndex := predex.predIndex;
      else
         self.ruleIndex := 0;
         self.predicateIndex := 0;
      end if;

      self.predicate := predicate;

      Super (Self).Initialize (recognizer => recognizer,
                               input      => Value (recognizer.getInputStream),
                               ctx        => recognizer.ctx,
                               message    => FailedPredicateException.formatMessage (predicate, message));
      token : constant Token := recognizer.getCurrentToken;
      if Is_Valid (token) then -- try?
         setOffendingToken (token);
      end if;
   end Initialize;

   function formatMessage (predicate : Optional_UString; message : Optional_UString) return UString is
   begin
      if Is_Valid (message) then
         return message;
      else
         predstr : constant UString := Value (predicate, Default => "<unknown>");
         return "failed predicate: {" & predstr'Image & "}?";
      end if;
   end formatMessage;

end ANTLR.Runtime.RecognitionExceptions.FailedPredicateExceptions;