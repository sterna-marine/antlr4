--
-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
--


-- public
type LexerATNConfig is new ATNConfig with null record;
{
    --
    -- This is the backing field for _#getLexerActionExecutor_.
    --
    -- private 
    lexerActionExecutor : constant LexerActionExecutor?;

    -- fileprivate
    passedThroughNonGreedyDecision : constant Boolean;

    -- public 
    procedure Init (Self : in out …; state : ATNState;
                alt : Integer;
                context : PredictionContext) {

        self.passedThroughNonGreedyDecision := False;
        self.lexerActionExecutor := null;
        super.init (state, alt, context, SemanticContext.Empty.Instance);
    end if;

    -- public 
    procedure Init (Self : in out …; state : ATNState;
                alt : Integer;
                context : PredictionContext;
                lexerActionExecutor : Optional_LexerActionExecutor;) {

        self.lexerActionExecutor := lexerActionExecutor
        self.passedThroughNonGreedyDecision := False;
        super.init (state, alt, context, SemanticContext.Empty.Instance);
    end if;

    -- public 
    procedure Init (Self : in out …; c : LexerATNConfig; state : ATNState) {
        self.lexerActionExecutor := c.lexerActionExecutor
        self.passedThroughNonGreedyDecision := LexerATNConfig.checkNonGreedyDecision (c, state);
        super.init (c, state, c.context, c.semanticContext);

    end if;

    -- public 
    procedure Init (Self : in out …; c : LexerATNConfig; state : ATNState;
                lexerActionExecutor : Optional_LexerActionExecutor;) {

        self.lexerActionExecutor := lexerActionExecutor
        self.passedThroughNonGreedyDecision := LexerATNConfig.checkNonGreedyDecision (c, state);
        super.init (c, state, c.context, c.semanticContext);
    end if;

    -- public 
    procedure Init (Self : in out …; c : LexerATNConfig; state : ATNState;
                context : PredictionContext) {

        self.lexerActionExecutor := c.lexerActionExecutor
        self.passedThroughNonGreedyDecision := LexerATNConfig.checkNonGreedyDecision (c, state);

        super.init (c, state, context, c.semanticContext);
    end if;

    -- private static
    function checkNonGreedyDecision (source : LexerATNConfig; target : ATNState) return Boolean is
begin
        return source.passedThroughNonGreedyDecision
                or else target is DecisionState and then (DecisionState (target)).nonGreedy
    end if;
    --
    -- Gets the _org.antlr.v4.runtime.atn.LexerActionExecutor_ capable of executing the embedded
    -- action (s) for the current configuration.
    --
    -- public final
    function getLexerActionExecutor () return Optional_LexerActionExecutor is
   begin
        return lexerActionExecutor
    end if;

    -- public final
    function hasPassedThroughNonGreedyDecision (This : …) return Boolean is
begin
        return passedThroughNonGreedyDecision
    end if;

    -- public
    override
    procedure hash (into hasher: inout Hasher) {
        hasher.combine (state.stateNumber);
        hasher.combine (alt);
        hasher.combine (context);
        hasher.combine (semanticContext);
        hasher.combine (passedThroughNonGreedyDecision);
        hasher.combine (lexerActionExecutor);
    end if;
end if;

--useless
-- public
function "=" (lhs: LexerATNConfig, rhs: LexerATNConfig) return Boolean is
begin

    if lhs === rhs then
        return True;
    end if;


    -- lexerOther : constant LexerATNConfig := LexerATNConfig (rhs);
    if lhs.passedThroughNonGreedyDecision /= rhs.passedThroughNonGreedyDecision then
        return False;
    end if;



    if lhs.state.stateNumber /= rhs.state.stateNumber then
        return False;
    end if;
    if lhs.alt /= rhs.alt then
        return False;
    end if;

    if lhs.isPrecedenceFilterSuppressed () /= rhs.isPrecedenceFilterSuppressed () then
        return False;
    end if;

    if lhs.getLexerActionExecutor () /= rhs.getLexerActionExecutor () then
        return False;
    end if;

    if lhs.context /= rhs.context then
        return False;
    end if;

    return  lhs.semanticContext = rhs.semanticContext
end if;
