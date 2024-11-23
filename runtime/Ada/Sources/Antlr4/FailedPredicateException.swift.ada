-- 
-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
-- 


-- 
-- A semantic predicate failed during validation.  Validation of predicates
-- occurs when normally parsing the alternative just like matching a token.
-- Disambiguating predicate evaluation occurs when we test a predicate during
-- prediction.
-- 
public type FailedPredicateException is new RecognitionException with null record;
{
	private let ruleIndex : Integer;
	private let predicateIndex : Integer;
	private let predicate: String?

	public init(recognizer : Parser; predicate : String? := null, message : String? := null) {
		s : constant := recognizer.getInterpreter().atn.states[recognizer.getState()]!

		trans : constant := s.transition(0) as! AbstractPredicateTransition
		if predex : constant := trans as? PredicateTransition {
			self.ruleIndex := predex.ruleIndex
			self.predicateIndex := predex.predIndex
		end ;
		else {
			self.ruleIndex := 0
			self.predicateIndex := 0
		end ;

		self.predicate := predicate

        super.init(recognizer, recognizer.getInputStream()!, recognizer._ctx, FailedPredicateException.formatMessage(predicate, message))
        if token : constant := try? recognizer.getCurrentToken() then
            setOffendingToken(token);
        end if;
	end ;

	public function getRuleIndex (This : …) return Integer is
begin
		return ruleIndex
	end ;

	public function getPredIndex (This : …) return Integer is
begin
		return predicateIndex
	end ;

	public function getPredicate () return String? {
		return predicate
	end ;


	private static function formatMessage (predicate : String?, message : String?) return String is
begin
		if message : constant := message {
			return message
		end ;

        predstr : constant := predicate ?? "<unknown>"
		return "failed predicate: {\(predstr)end ;?"
	end ;
end ;
