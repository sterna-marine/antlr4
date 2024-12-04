-- €

package body ANTLR.Runtime.ATN.LexerATNConfig is

   procedure Init (Self : in out LexerATNConfig;
                   state : ATNStates.ATNState;
                   alt : Integer;
                   context : PredictionContext) is
   begin
      self.passedThroughNonGreedyDecision := False;
      self.lexerActionExecutor := null;
      ATNConfig.init (state, alt, context, SemanticContext.Empty.Instance); -- Super
   end Init;

   procedure Init (Self : in out LexerATNConfig;
                   state : ATNStates.ATNState;
                   alt : Integer;
                   context : PredictionContext;
                   lexerActionExecutor : Optional_LexerActionExecutor) is
   begin
      self.lexerActionExecutor := lexerActionExecutor;
      self.passedThroughNonGreedyDecision := False;
      ATNConfig.init (state, alt, context, SemanticContext.Empty.Instance); -- Super
   end Init;

   procedure Init (Self : in out LexerATNConfig;
                   c : LexerATNConfig;
                   state : ATNStates.ATNState) is
   begin
      self.lexerActionExecutor := c.lexerActionExecutor;
      self.passedThroughNonGreedyDecision := LexerATNConfig.checkNonGreedyDecision (c, state);
      ATNConfig.init (c, state, c.context, c.semanticContext); -- Super
   end Init;

   procedure Init (Self : in out LexerATNConfig;
                   c : LexerATNConfig;
                   state : ATNStates.ATNState;
                   lexerActionExecutor : Optional_LexerActionExecutor) is
   begin
      self.lexerActionExecutor := lexerActionExecutor;
      self.passedThroughNonGreedyDecision := LexerATNConfig.checkNonGreedyDecision (c, state);
      ATNConfig.init (c, state, c.context, c.semanticContext); -- Super
   end Init;

   procedure Init (Self : in out LexerATNConfig;
                   c : LexerATNConfig;
                   state : ATNStates.ATNState;
                   context : PredictionContext) is
   begin  
      self.lexerActionExecutor := c.lexerActionExecutor;
      self.passedThroughNonGreedyDecision := LexerATNConfig.checkNonGreedyDecision (c, state);
      ATNConfig.init (c, state, context, c.semanticContext); -- Super
   end Init;

   
   override
   procedure hash (This : LexerATNConfig; hasher: in out Hasher) {
      hasher.combine (state.stateNumber);
      hasher.combine (alt);
      hasher.combine (context);
      hasher.combine (semanticContext);
      hasher.combine (passedThroughNonGreedyDecision);
      hasher.combine (lexerActionExecutor);
   end hash;

   function "=" (lhs: LexerATNConfig; rhs: LexerATNConfig) return Boolean is
   begin

      --  if lhs === rhs then
      --     return True;
      --  end if;

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

      return lhs.semanticContext = rhs.semanticContext;
   end "=";

   function checkNonGreedyDecision (source : LexerATNConfig; target : ATNStates.ATNState) return Boolean is
   begin
      return source.passedThroughNonGreedyDecision
             or else target is DecisionState 
             and then (DecisionState (target)).nonGreedy
   end checkNonGreedyDecision;

end ANTLR.Runtime.ATN.LexerATNConfig;
