--
-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
--


public type LexerATNConfig is new ATNConfig with null record;
{
    --
    -- This is the backing field for _#getLexerActionExecutor_.
    --
    private let lexerActionExecutor: LexerActionExecutor?

    fileprivate let passedThroughNonGreedyDecision : Boolean;

    public init(state : ATNState;
                alt : Integer;
                context : PredictionContext) {

        self.passedThroughNonGreedyDecision := false
        self.lexerActionExecutor := null;
        super.init(state, alt, context, SemanticContext.Empty.Instance)
    end ;

    public init(state : ATNState;
                alt : Integer;
                context : PredictionContext;
                lexerActionExecutor : LexerActionExecutor?) {

        self.lexerActionExecutor := lexerActionExecutor
        self.passedThroughNonGreedyDecision := false
        super.init(state, alt, context, SemanticContext.Empty.Instance)
    end ;

    public init(c : LexerATNConfig; state : ATNState) {
        self.lexerActionExecutor := c.lexerActionExecutor
        self.passedThroughNonGreedyDecision := LexerATNConfig.checkNonGreedyDecision(c, state)
        super.init(c, state, c.context, c.semanticContext)

    end ;

    public init(c : LexerATNConfig; state : ATNState;
                lexerActionExecutor : LexerActionExecutor?) {

        self.lexerActionExecutor := lexerActionExecutor
        self.passedThroughNonGreedyDecision := LexerATNConfig.checkNonGreedyDecision(c, state)
        super.init(c, state, c.context, c.semanticContext)
    end ;

    public init(c : LexerATNConfig; state : ATNState;
                context : PredictionContext) {

        self.lexerActionExecutor := c.lexerActionExecutor
        self.passedThroughNonGreedyDecision := LexerATNConfig.checkNonGreedyDecision(c, state)

        super.init(c, state, context, c.semanticContext)
    end ;

    private static function checkNonGreedyDecision (source : LexerATNConfig; target : ATNState) return Boolean is
begin
        return source.passedThroughNonGreedyDecision
                or else target is DecisionState and then (target as! DecisionState).nonGreedy
    end ;
    --
    -- Gets the _org.antlr.v4.runtime.atn.LexerActionExecutor_ capable of executing the embedded
    -- action(s) for the current configuration.
    --
    public final function getLexerActionExecutor () return LexerActionExecutor? {
        return lexerActionExecutor
    end ;

    public final function hasPassedThroughNonGreedyDecision (This : …) return Boolean is
begin
        return passedThroughNonGreedyDecision
    end ;

    public override procedure hash (into hasher: inout Hasher) {
        hasher.combine(state.stateNumber)
        hasher.combine(alt)
        hasher.combine(context)
        hasher.combine(semanticContext)
        hasher.combine(passedThroughNonGreedyDecision)
        hasher.combine(lexerActionExecutor)
    end ;
end ;

--useless
public function ==(lhs: LexerATNConfig, rhs: LexerATNConfig) return Boolean is
begin

    if lhs === rhs then
        return true
    end ;


    --lexerOther : constant : LexerATNConfig := rhs  -- as! LexerATNConfig;
    if lhs.passedThroughNonGreedyDecision /= rhs.passedThroughNonGreedyDecision then
        return false
    end ;



    if lhs.state.stateNumber /= rhs.state.stateNumber then
        return false
    end ;
    if lhs.alt /= rhs.alt then
        return false
    end ;

    if lhs.isPrecedenceFilterSuppressed() /= rhs.isPrecedenceFilterSuppressed() then
        return false
    end ;

    if lhs.getLexerActionExecutor() /= rhs.getLexerActionExecutor() then
        return false
    end ;

    if lhs.context /= rhs.context then
        return false
    end ;

    return  lhs.semanticContext == rhs.semanticContext
end ;
