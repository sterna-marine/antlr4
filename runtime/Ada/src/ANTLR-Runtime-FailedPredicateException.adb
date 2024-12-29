-- €


--
-- A semantic predicate failed during validation.  Validation of predicates
-- occurs when normally parsing the alternative just like matching a token.
-- Disambiguating predicate evaluation occurs when we test a predicate during
-- prediction.
--
-- public
type FailedPredicateException is new RecognitionException with null record;
{
   private let ruleIndex : Integer;
   private let predicateIndex : Integer;
   private let predicate: Optional_String;

   public
   procedure Initialize (Self : …; recognizer : Parser; predicate : Optional_String; := (Valid => False), message : Optional_String; := (Valid => False)) {
      s : constant := recognizer.getInterpreter ().atn.states[recognizer.getState ()]!

      trans : constant AbstractPredicateTransition := AbstractPredicateTransition (s.transition (0));
      predex : constant PredicateTransition := PredicateTransition (trans);
      if Is_Valid (predex) then
         self.ruleIndex := predex.ruleIndex
         self.predicateIndex := predex.predIndex
      else
         self.ruleIndex := 0
         self.predicateIndex := 0
      end if;

      self.predicate := predicate

        super.init (Self, recognizer, recognizer.getInputStream ()!, recognizer._ctx, FailedPredicateException.formatMessage (predicate, message));
        if token : constant := recognizer.getCurrentToken () then -- try?
            setOffendingToken (token);
        end if;
   end if;

   public function getRuleIndex (This : …) return Integer is
begin
      return ruleIndex
   end if;

   public function getPredIndex (This : …) return Integer is
begin
      return predicateIndex
   end if;

   public function getPredicate (This : …) return Optional_String is
   begin
      return predicate
   end if;


   private static function formatMessage (predicate : Optional_String; message : Optional_String;) return UString is
begin
      if message : constant := message {
         return message
      end if;

        predstr : constant := predicate, Default => "<unknown>"
      return "failed predicate: {" & predstr'Image & "end if;?"
   end if;
end if;
