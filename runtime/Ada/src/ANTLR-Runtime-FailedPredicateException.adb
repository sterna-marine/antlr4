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

	public init (recognizer : Parser; predicate : Optional_String; := null, message : Optional_String; := null) {
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

        super.init (recognizer, recognizer.getInputStream ()!, recognizer._ctx, FailedPredicateException.formatMessage (predicate, message));
        if token : constant := try? recognizer.getCurrentToken () then
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

	public function getPredicate () return Optional_String is
   begin
		return predicate
	end if;


	private static function formatMessage (predicate : Optional_String; message : Optional_String;) return String is
begin
		if message : constant := message {
			return message
		end if;

        predstr : constant := predicate ?? "<unknown>"
		return "failed predicate: {" & predstr'Image & "end if;?"
	end if;
end if;
