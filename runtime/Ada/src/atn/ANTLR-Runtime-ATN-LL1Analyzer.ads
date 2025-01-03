-- €

with Ada.Finalization;
with ANTLR.Runtime.ATN;
with ANTLR.Runtime.ATN.Configs;

use ANTLR.Runtime.ATN;
use ANTLR.Runtime.ATN.Configs;

package ANTLR.Runtime.ATN.LL1Analyzer is

   -- public
   type LL1Analyzer is new Ada.Finalization.Controlled record
      --
      -- Special value added to the lookahead sets to indicate that we hit
      -- a predicate during analysis if `seeThruPreds = False`.
      --
      -- public
      HIT_PRED : Integer := CommonToken.INVALID_TYPE; -- constant

      -- public
      atn : ATN; -- constant
   end record;

   -- public
   procedure Initialize (Self : in out LL1Analyzer; atn : ATN);

   --
   -- Calculates the SLL (1) expected lookahead set for each outgoing transition
   -- of an _org.antlr.v4.runtime.atn.ATNState_. The returned array has one element for each
   -- outgoing transition in `s`. If the closure from transition
   -- __i__ leads to a semantic predicate before matching a symbol, the
   -- element at index __i__ of the result will be `null`.
   --
   -- * parameter s: the ATN state
   -- * returns: the expected symbols for each outgoing transition of `s`.
   --
   -- public
   function getDecisionLookahead (This : LL1Analyzer; s : Optional_ATNState) return Optional_IntervalSet_List is --?]? 

   --
   -- Compute set of tokens that can follow `s` in the ATN in the
   -- specified `ctx`.
   --
   -- If `ctx` is `null` and the end of the rule containing
   -- `s` is reached, _org.antlr.v4.runtime.Token#EPSILON_ is added to the result set.
   -- If `ctx` is not `null` and the end of the outermost rule is
   -- reached, _org.antlr.v4.runtime.Token#EOF_ is added to the result set.
   --
   -- * parameter s: the ATN state
   -- * parameter ctx: the complete parser context, or `null` if the context
   -- should be ignored
   --
   -- * returns: The set of tokens that can follow `s` in the ATN in the
   -- specified `ctx`.
   --
   -- public
   function LOOK (This : LL1Analyzer; s : ATNState; ctx : Optional_RuleContext) return IntervalSet
      is LOOK (This, s, (Valid => False), ctx);

   --
   -- Compute set of tokens that can follow `s` in the ATN in the
   -- specified `ctx`.
   --
   -- If `ctx` is `null` and the end of the rule containing
   -- `s` is reached, _org.antlr.v4.runtime.Token#EPSILON_ is added to the result set.
   -- If `ctx` is not `null` and the end of the outermost rule is
   -- reached, _org.antlr.v4.runtime.Token#EOF_ is added to the result set.
   --
   -- * parameter s: the ATN state
   -- * parameter stopState: the ATN state to stop at. This can be a
   -- _org.antlr.v4.runtime.atn.BlockEndState_ to detect epsilon paths through a closure.
   -- * parameter ctx: the complete parser context, or `null` if the context
   -- should be ignored
   --
   -- * returns: The set of tokens that can follow `s` in the ATN in the
   -- specified `ctx`.
   --

   -- public
   function LOOK (This : LL1Analyzer;
                  s : ATNState;
                  stopState : Optional_ATNState;
                  ctx : Optional_RuleContext)
                  return IntervalSet;

   --
   -- Compute set of tokens that can follow `s` in the ATN in the
   -- specified `ctx`.
   --
   -- If `ctx` is `null` and `stopState` or the end of the
   -- rule containing `s` is reached, _org.antlr.v4.runtime.Token#EPSILON_ is added to
   -- the result set. If `ctx` is not `null` and `addEOF` is
   -- `True` and `stopState` or the end of the outermost rule is
   -- reached, _org.antlr.v4.runtime.Token#EOF_ is added to the result set.
   --
   -- * parameter s: the ATN state.
   -- * parameter stopState: the ATN state to stop at. This can be a
   -- _org.antlr.v4.runtime.atn.BlockEndState_ to detect epsilon paths through a closure.
   -- * parameter ctx: The outer context, or `null` if the outer context should
   -- not be used.
   -- * parameter look: The result lookahead set.
   -- * parameter lookBusy: A set used for preventing epsilon closures in the ATN
   -- from causing a stack overflow. Outside code should pass
   -- `new HashSet<ATNConfig>` for this argument.
   -- * parameter calledRuleStack: A set used for preventing left recursion in the
   -- ATN from causing a stack overflow. Outside code should pass
   -- `new BitSet ()` for this argument.
   -- * parameter seeThruPreds: `True` to True semantic predicates as
   -- implicitly `True` and "see through them", otherwise `False`
   -- to treat semantic predicates as opaque and add _#HIT_PRED_ to the
   -- result if one is encountered.
   -- * parameter addEOF: Add _org.antlr.v4.runtime.Token#EOF_ to the result if the end of the
   -- outermost context is reached. This parameter has no effect if `ctx`
   -- is `null`.
   --
   -- internal
   procedure This_LOOK (This : LL1Analyzer;
                        s : ATNState;
                        stopState : Optional_ATNState;
                        ctx : Optional_PredictionContext;
                        look : IntervalSet;
                        lookBusy : in out Set_of_ATNConfigs;
                        calledRuleStack : BitSet;
                        seeThruPreds : Boolean;
                        addEOF  : Boolean);

end ANTLR.Runtime.ATN.LL1Analyzer;
