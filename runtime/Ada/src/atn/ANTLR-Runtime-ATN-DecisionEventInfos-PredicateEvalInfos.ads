-- €

with ANTLR.Runtime.ATN.SemanticContext;

use ANTLR.Runtime.ATN;
use ANTLR.Runtime.ATN.DecisionEventInfo;
use ANTLR.Runtime.ATN.SemanticContext;
use ANTLR.Runtime.ATN.PredicateEvalInfo;

package ANTLR.Runtime.ATN.DecisionEventInfos.PredicateEvalInfos is

   --
   -- This class represents profiling event information for semantic predicate
   -- evaluations which occur during prediction.
   --
   -- * seealso: org.antlr.v4.runtime.atn.ParserATNSimulator#evalSemanticContext
   --

   -- public
   type PredicateEvalInfo is new DecisionEventInfo with private;

   subtype Object is PredicateEvalInfo;
   subtype Super is DecisionEventInfo;
   type Class is access all Object;
   type Class_Wide is access all Object'Class;

   --
   -- Constructs a new instance of the _org.antlr.v4.runtime.atn.PredicateEvalInfo_ class with the
   -- specified detailed predicate evaluation information.
   --
   -- * parameter decision: The decision number
   -- * parameter input: The input token stream
   -- * parameter startIndex: The start index for the current prediction
   -- * parameter stopIndex: The index at which the predicate evaluation was
   --   triggered. Note that the input stream may be reset to other positions for
   --   the actual evaluation of individual predicates.
   -- * parameter semctx: The semantic context which was evaluated
   -- * parameter evalResult: The results of evaluating the semantic context
   -- * parameter predictedAlt: The alternative number for the decision which is
   --   guarded by the semantic context `semctx`. See _#predictedAlt_
   --   for more information.
   -- * parameter fullCtx: `True` if the semantic context was
   --   evaluated during LL prediction; otherwise, `False` if the semantic
   --   context was evaluated during SLL prediction
   --
   -- * seealso: org.antlr.v4.runtime.atn.ParserATNSimulator#evalSemanticContext (org.antlr.v4.runtime.atn.SemanticContext, org.antlr.v4.runtime.ParserRuleContext, int, boolean);
   -- * seealso: org.antlr.v4.runtime.atn.SemanticContext#eval (org.antlr.v4.runtime.Recognizer, org.antlr.v4.runtime.RuleContext);
   --
   -- public
   procedure Initialize (Self : in out PredicateEvalInfo; decision : State;
                   input : TokenStream;
                   startIndex : Integer;
                   stopIndex : Integer;
                   semctx : SemanticContext;
                   evalResult : Boolean;
                   predictedAlt : Integer;
                   fullCtx  : Boolean);

private

   type PredicateEvalInfo is new DecisionEventInfo with
   record
      --
      -- The semantic context which was evaluated.
      --
      -- public private (set);
      semctx : SemanticContext;
      --
      -- The alternative number for the decision which is guarded by the semantic
      -- context _#semctx_. Note that other ATN
      -- configurations may predict the same alternative which are guarded by
      -- other semantic contexts and/or _org.antlr.v4.runtime.atn.SemanticContext#NONE_.
      --
      -- public private (set);
      predictedAlt : Integer;
      --
      -- The result of evaluating the semantic context _#semctx_.
      --
      -- public private (set);
      evalResult : Boolean;
   end record;

end package ANTLR.Runtime.ATN.DecisionEventInfos.PredicateEvalInfos;
