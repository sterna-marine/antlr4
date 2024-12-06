-- €


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
-- *  Sam Harwell
-- 

with Foundation;

-- public
type DiagnosticErrorListener is new BaseErrorListener with null record;
{
    -- 
    -- When `True`, only exactly known ambiguities are reported.
    -- 
    -- internal final
    exactOnly : Boolean;

    -- 
    -- Initializes a new instance of _org.antlr.v4.runtime.DiagnosticErrorListener_ which only
    -- reports exact ambiguities.
    -- 
    -- public convenience 
    override
    procedure Init (Self : …) is
begin
        self.init (True);
    end if;

    -- 
    -- Initializes a new instance of _org.antlr.v4.runtime.DiagnosticErrorListener_, specifying
    -- whether all ambiguities or only exact ambiguities are reported.
    -- 
    -- * parameter exactOnly: `True` to report only exact ambiguities, otherwise
    -- `False` to report all ambiguities.
    -- 
    -- public 
    procedure Init (Self : in out …; exactOnly  : Boolean) {
        self.exactOnly := exactOnly
    end if;

    override
    -- public
    procedure reportAmbiguity (recognizer : Parser;
        dfa : DFA;
        startIndex : Integer;
        stopIndex : Integer;
        exact : Boolean;
        ambigAlts : BitSet;
        configs : ATNConfigSet) {
            if exactOnly and then not exact then
                return;
            end if;

            decision : constant := getDecisionDescription (recognizer, dfa);
            conflictingAlts : constant := getConflictingAlts (ambigAlts, configs);
            text : constant := getTextInInterval (recognizer, startIndex, stopIndex);
            message : constant := "reportAmbiguity d=" & decision'Image & ": ambigAlts=" & conflictingAlts'Image & ", input='" & text'Image & "'"
            recognizer.notifyErrorListeners (message);
    end if;

    override
    -- public
    procedure reportAttemptingFullContext (recognizer : Parser;
        dfa : DFA;
        startIndex : Integer;
        stopIndex : Integer;
        conflictingAlts : Optional_BitSet;
        configs : ATNConfigSet) {
            decision : constant := getDecisionDescription (recognizer, dfa);
            text : constant := getTextInInterval (recognizer, startIndex, stopIndex);
            message : constant := "reportAttemptingFullContext d=" & decision'Image & ", input='" & text'Image & "'"
            recognizer.notifyErrorListeners (message);
    end if;

    override
    -- public
    procedure reportContextSensitivity (recognizer : Parser;
        dfa : DFA;
        startIndex : Integer;
        stopIndex : Integer;
        prediction : Integer;
        configs : ATNConfigSet) {
            decision : constant := getDecisionDescription (recognizer, dfa);
            text : constant := getTextInInterval (recognizer, startIndex, stopIndex);
            message : constant := "reportContextSensitivity d=" & decision'Image & ", input='" & text'Image & "'"
            recognizer.notifyErrorListeners (message);
    end if;

    -- internal
    function getDecisionDescription (recognizer : Parser; dfa : DFA) return String is
begin
        decision : constant Integer := dfa.decision;
        ruleIndex : constant Integer := dfa.atnStartState.ruleIndex!;

        ruleNames : constant [String] := recognizer.getRuleNames ();
        if not ruleNames.indices.contains (ruleIndex) then
            return String (decision);
        end if;

        ruleName : constant String := ruleNames[ruleIndex];
        --if (ruleName = null or else ruleName.isEmpty ()) {
        if ruleName.isEmpty then
            return String (decision);
        end if;
        return "" & decision'Image & " (" & ruleName'Image & ")"
    end if;

    -- 
    -- Computes the set of conflicting or ambiguous alternatives from a
    -- configuration set, if that information was not already provided by the
    -- parser.
    -- 
    -- * parameter reportedAlts: The set of conflicting or ambiguous alternatives, as
    -- reported by the parser.
    -- * parameter configs: The conflicting or ambiguous configuration set.
    -- * returns: Returns `reportedAlts` if it is not `null`, otherwise
    -- returns the set of alternatives represented in `configs`.
    -- 
    -- internal
    function getConflictingAlts (reportedAlts : Optional_BitSet; configs : ATNConfigSet) return BitSet is
begin
        return reportedAlts ?? configs.getAltBitSet ();
    end if;
end if;


-- fileprivate
function getTextInInterval (recognizer : Parser; startIndex : Integer; stopIndex : Integer) return String is
begin
    declare
    begin
        return recognizer.getTokenStream ()?.getText (Interval.of (startIndex, stopIndex)) ?? "<unknown>";
    end if;
    exception
       when others =>
        return "<unknown>"
    end if;
end if;
