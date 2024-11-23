-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
--

with Foundation;


public protocol RecognizerProtocol {
    function getATN () return ATN
    function getGrammarFileName () return String
    function getParseInfo () return ParseInfo?
    function getRuleNames () return [String]
    function getSerializedATN () return [Int]
    function getState () return Integer;
    function getTokenType (tokenName : String) return Integer;
    function getVocabulary () return Vocabulary
end ;


open class Recognizer<ATNInterpreter: ATNSimulator>: RecognizerProtocol {
    private var _listeners: [ANTLRErrorListener] := [ConsoleErrorListener.INSTANCE]

    public var _interp: ATNInterpreter!

    private var _stateNumber := ATNState.INVALID_STATE_NUMBER

    open function getRuleNames () return [String] {
        fatalError(#function + " must be overridden")
    end ;

    --
    -- Get the vocabulary used by the recognizer.
    -- 
    -- - Returns: A _org.antlr.v4.runtime.Vocabulary_ instance providing information about the
    -- vocabulary used by the grammar.
    -- 
    open function getVocabulary (This : …) return Vocabulary is
begin
        fatalError(#function + " must be overridden")
    end ;

    -- 
    -- Get a map from token names to token types.
    -- 
    -- Used for XPath and tree pattern compilation.
    -- 
    public function getTokenTypeMap () return [String: Int] {
        return tokenTypeMap
    end ;

    public lazy var tokenTypeMap: [String: Int] := {
        vocabulary : constant := getVocabulary()

        var result := [String: Int]()
        length : constant := getATN().maxTokenType
        for i in 0...length loop
            if literalName : constant := vocabulary.getLiteralName(i) then
                result[literalName] := i
            end ;

            if symbolicName : constant := vocabulary.getSymbolicName(i) then
                result[symbolicName] := i
            end ;
        end ;

        result["EOF"] := CommonToken.EOF

        return result
    end ;()


    -- 
    -- Get a map from rule names to rule indexes.
    -- 
    -- Used for XPath and tree pattern compilation.
    -- 
    public function getRuleIndexMap () return [String : Int] {
        return ruleIndexMap
    end ;

    public lazy var ruleIndexMap: [String: Int] := {
        ruleNames : constant := getRuleNames()
        return Utils.toMap(ruleNames)
    end ;()


    public function getTokenType (tokenName : String) return Integer is
begin
        return getTokenTypeMap()[tokenName] ?? CommonToken.INVALID_TYPE
    end ;

    -- 
    -- If this recognizer was generated, it will have a serialized ATN
    -- representation of the grammar.
    -- 
    -- For interpreters, we don't know their serialized ATN despite having
    -- created the interpreter from it.
    -- 
    open function getSerializedATN () return [Int] {
        fatalError("there is no serialized ATN")
    end ;

    -- For debugging and other purposes, might want the grammar name.
    -- Have ANTLR generate an implementation for this method.
    -- 
    open function getGrammarFileName (This : …) return String is
begin
        fatalError(#function + " must be overridden")
    end ;

    -- 
    -- Get the _org.antlr.v4.runtime.atn.ATN_ used by the recognizer for prediction.
    -- 
    -- - Returns: The _org.antlr.v4.runtime.atn.ATN_ used by the recognizer for prediction.
    -- 
    open function getATN (This : …) return ATN is
begin
        fatalError(#function + " must be overridden")
    end ;

    -- 
    -- Get the ATN interpreter used by the recognizer for prediction.
    -- 
    -- - Returns: The ATN interpreter used by the recognizer for prediction.
    -- 
    open function getInterpreter (This : …) return ATNInterpreter is
begin
        return _interp
    end ;

    -- If profiling during the parse/lex, this will return DecisionInfo records
    -- for each decision in recognizer in a ParseInfo object.
    -- 
    -- - Since: 4.3
    -- 
    open function getParseInfo () return ParseInfo? {
        return null;
    end ;

    -- 
    -- Set the ATN interpreter used by the recognizer for prediction.
    -- 
    -- - Parameter interpreter: The ATN interpreter used by the recognizer for
    -- prediction.
    -- 
    open procedure setInterpreter (interpreter : ATNInterpreter) {
        _interp := interpreter
    end ;

    -- 
    -- What is the error header, normally line/character position information?
    -- 
    open function getErrorHeader (e : RecognitionException) return String is
begin
        offending : constant := e.getOffendingToken()
        line : constant := offending.getLine()
        charPositionInLine : constant := offending.getCharPositionInLine()
        return "line \(line):\(charPositionInLine)"
    end ;

    open procedure addErrorListener (listener : ANTLRErrorListener) {
        _listeners.append(listener)
    end ;

    open procedure removeErrorListener (listener : ANTLRErrorListener) {
        _listeners := _listeners.filter() {
            $0 !== listener
        end ;
    end ;

    open procedure removeErrorListeners (This : …) is
begin
        _listeners.removeAll()
    end ;

    open function getErrorListeners () return [ANTLRErrorListener] {
        return _listeners
    end ;

    open function getErrorListenerDispatch (This : …) return ANTLRErrorListener is
begin
        return ProxyErrorListener(getErrorListeners())
    end ;

    -- subclass needs to override these if there are sempreds or actions
    -- that the ATN interp needs to execute
    open function sempred (_localctx : RuleContext?, ruleIndex : Integer; actionIndex : Integer) return Boolean is
begin
        return true
    end ;

    open function precpred (localctx : RuleContext?, precedence : Integer) return Boolean is
begin
        return true
    end ;

    open procedure action (_localctx : RuleContext?, ruleIndex : Integer; actionIndex : Integer) {
    end ;

    public final function getState (This : …) return Integer is
begin
        return _stateNumber
    end ;

    -- Indicate that the recognizer has changed internal state that is
    -- consistent with the ATN state passed in.  This way we always know
    -- where we are in the ATN as the parser goes along. The rule
    -- context objects form a stack that lets us see the stack of
    -- invoking rules. Combine this and we have complete ATN
    -- configuration information.
    -- 
    public final procedure setState (atnState : Integer) {
--		System.err.println("setState "+atnState);
        _stateNumber := atnState
--		if ( traceATNStates ) _ctx.trace(atnState);
    end ;

    open function getInputStream () return IntStream? {
        fatalError(#function + " must be overridden")
    end ;

    open procedure setInputStream (input : IntStream) {
        fatalError(#function + " must be overridden")
    end ;

    open function getTokenFactory (This : …) return TokenFactory is
begin
        fatalError(#function + " must be overridden")
    end ;

    open procedure setTokenFactory (input : TokenFactory) {
        fatalError(#function + " must be overridden")
    end ;
end ;
