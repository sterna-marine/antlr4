-- 
-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
-- 


-- 
-- This implementation of _org.antlr.v4.runtime.ANTLRErrorListener_ can be used to identify
-- certain potential correctness and performance problems in grammars. "Reports"
-- are made by calling _org.antlr.v4.runtime.Parser#notifyErrorListeners_ with the appropriate
-- message.
-- 
-- * __Ambiguities__: These are cases where more than one path through the
-- grammar can match the input.
-- * __Weak context sensitivity__: These are cases where full-context
-- prediction resolved an SLL conflict to a unique alternative which equaled the
-- minimum alternative of the SLL conflict.
-- * __Strong (forced) context sensitivity__: These are cases where the
-- full-context prediction resolved an SLL conflict to a unique alternative,
-- __and__ the minimum alternative of the SLL conflict was found to not be
-- a truly viable alternative. Two-stage parsing cannot be used for inputs where
-- this situation occurs.
-- 
-- -  Sam Harwell
-- 

with Foundation;

public type DiagnosticErrorListener is new BaseErrorListener with null record;
{
    -- 
    -- When `true`, only exactly known ambiguities are reported.
    -- 
    internal final var exactOnly : Boolean;

    -- 
    -- Initializes a new instance of _org.antlr.v4.runtime.DiagnosticErrorListener_ which only
    -- reports exact ambiguities.
    -- 
    public convenience override procedure Init (This : …) is
begin
        self.init(true)
    end ;

    -- 
    -- Initializes a new instance of _org.antlr.v4.runtime.DiagnosticErrorListener_, specifying
    -- whether all ambiguities or only exact ambiguities are reported.
    -- 
    -- - parameter exactOnly: `true` to report only exact ambiguities, otherwise
    -- `false` to report all ambiguities.
    -- 
    public init(exactOnly  : Boolean) {
        self.exactOnly := exactOnly
    end ;

    override
    public procedure reportAmbiguity (recognizer : Parser;
        dfa : DFA;
        startIndex : Integer;
        stopIndex : Integer;
        exact : Boolean;
        ambigAlts : BitSet;
        configs : ATNConfigSet) {
            if exactOnly and then not exact then
                return;
            end if;

            decision : constant := getDecisionDescription(recognizer, dfa)
            conflictingAlts : constant := getConflictingAlts(ambigAlts, configs)
            text : constant := getTextInInterval(recognizer, startIndex, stopIndex)
            message : constant := "reportAmbiguity d=\(decision): ambigAlts=\(conflictingAlts), input='\(text)'"
            recognizer.notifyErrorListeners(message)
    end ;

    override
    public procedure reportAttemptingFullContext (recognizer : Parser;
        dfa : DFA;
        startIndex : Integer;
        stopIndex : Integer;
        conflictingAlts : BitSet?,
        configs : ATNConfigSet) {
            decision : constant := getDecisionDescription(recognizer, dfa)
            text : constant := getTextInInterval(recognizer, startIndex, stopIndex)
            message : constant := "reportAttemptingFullContext d=\(decision), input='\(text)'"
            recognizer.notifyErrorListeners(message)
    end ;

    override
    public procedure reportContextSensitivity (recognizer : Parser;
        dfa : DFA;
        startIndex : Integer;
        stopIndex : Integer;
        prediction : Integer;
        configs : ATNConfigSet) {
            decision : constant := getDecisionDescription(recognizer, dfa)
            text : constant := getTextInInterval(recognizer, startIndex, stopIndex)
            message : constant := "reportContextSensitivity d=\(decision), input='\(text)'"
            recognizer.notifyErrorListeners(message)
    end ;

    internal function getDecisionDescription (recognizer : Parser; dfa : DFA) return String is
begin
        let decision: Integer := dfa.decision
        let ruleIndex: Integer := dfa.atnStartState.ruleIndex!

        let ruleNames: [String] := recognizer.getRuleNames()
        guard ruleNames.indices.contains(ruleIndex) else {
            return String(decision)
        end ;

        let ruleName: String := ruleNames[ruleIndex]
        --if (ruleName == null or else ruleName.isEmpty()) {
        if ruleName.isEmpty then
            return String(decision);
        end if;
        return "\(decision) (\(ruleName))"
    end ;

    -- 
    -- Computes the set of conflicting or ambiguous alternatives from a
    -- configuration set, if that information was not already provided by the
    -- parser.
    -- 
    -- - parameter reportedAlts: The set of conflicting or ambiguous alternatives, as
    -- reported by the parser.
    -- - parameter configs: The conflicting or ambiguous configuration set.
    -- - returns: Returns `reportedAlts` if it is not `null`, otherwise
    -- returns the set of alternatives represented in `configs`.
    -- 
    internal function getConflictingAlts (reportedAlts : BitSet?, configs : ATNConfigSet) return BitSet is
begin
        return reportedAlts ?? configs.getAltBitSet()
    end ;
end ;


fileprivate function getTextInInterval (recognizer : Parser; startIndex : Integer; stopIndex : Integer) return String is
begin
    do {
        return try recognizer.getTokenStream()?.getText(Interval.of(startIndex, stopIndex)) ?? "<unknown>"
    end ;
    catch {
        return "<unknown>"
    end ;
end ;
