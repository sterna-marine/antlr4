-- €

with Ada.Containers;
with Ada.Containers.Hashed_Maps;
with Ada.Environment_Variables;
--TOFIX with AdaForge.MurMur3_Hash;
with ANTLR.Runtime.ATN.ConfigSets;
with ANTLR.Runtime.ATN.PredictionModes;
with ANTLR.Runtime.ATN.States;
with ANTLR.Runtime.ATN.States.PredictionContexts;
with ANTLR.Runtime.ATN.TokenStream_Protocol;
with ANTLR.Runtime.ATN.Transitions;
with ANTLR.Runtime.DFA;
with ANTLR.Runtime.Misc.BitSets;
with ANTLR.Runtime.Parsers;
with ANTLR.Runtime.RuleContexts.ParserRuleContexts;
with ANTLR.Runtime.Token_Protocol;

use Ada;
--  use ANTLR.Runtime;
use ANTLR.Runtime.ATN;
use ANTLR.Runtime.ATN.ConfigSets;
use ANTLR.Runtime.ATN.Simulators;
use ANTLR.Runtime.ATN.PredictionModes;
use ANTLR.Runtime.ATN.States;
use ANTLR.Runtime.ATN.States.PredictionContexts;
use ANTLR.Runtime.ATN.Transitions;
use ANTLR.Runtime.ATN.TokenStream_Protocol;
use ANTLR.Runtime.DFA;
use ANTLR.Runtime.Misc.BitSets;
use ANTLR.Runtime.Parsers;
use ANTLR.Runtime.RuleContexts.ParserRuleContexts;
use ANTLR.Runtime.Token_Protocol;

package ANTLR.Runtime.ATN.Simulators.Parsers is

   --
   -- The embodiment of the adaptive LL (*), ALL (*), parsing strategy.
   --
   --
   -- The basic complexity of the adaptive strategy makes it harder to understand.
   -- We begin with ATN simulation to build paths in a DFA. Subsequent prediction
   -- requests go through the DFA first. If they reach a state without an edge for
   -- the current symbol, the algorithm fails over to the ATN simulation to
   -- complete the DFA path for the current input (until it finds a conflict state
   -- or uniquely predicting state).
   --
   --
   -- All of that is done without using the outer context because we want to create
   -- a DFA that is not dependent upon the rule invocation stack when we do a
   -- prediction. One DFA works in all contexts. We avoid using context not
   -- necessarily because it's slower, although it can be, but because of the DFA
   -- caching problem. The closure routine only considers the rule invocation stack
   -- created during prediction beginning in the decision rule. For example, if
   -- prediction occurs without invoking another rule's ATN, there are no context
   -- stacks in the configurations. When lack of context leads to a conflict, we
   -- don't know if it's an ambiguity or a weakness in the strong LL (*) parsing
   -- strategy (versus full LL (*)).
   --
   --
   -- When SLL yields a configuration set with conflict, we rewind the input and
   -- rethe ATN simulation, this time using full outer context without adding;
   -- to the DFA. Configuration context stacks will be the full invocation stacks
   -- from the start rule. If we get a conflict using full context, then we can
   -- definitively say we have a True ambiguity for that input sequence. If we
   -- don't get a conflict, it implies that the decision is sensitive to the outer
   -- context. (It is not context-sensitive in the sense of context-sensitive
   -- grammars.);
   --
   --
   -- The next time we reach this DFA state with an SLL conflict, through DFA
   -- simulation, we will again rethe ATN simulation using full context mode.;
   -- This is slow because we can't save the results and have to "interpret" the
   -- ATN each time we get that input.
   --
   --
   -- __CACHING FULL CONTEXT PREDICTIONS__
   --
   --
   -- We could cache results from full context to predicted alternative easily and
   -- that saves a lot of time but doesn't work in presence of predicates. The set
   -- of visible predicates from the ATN start state changes depending on the
   -- context, because closure can fall off the end of a rule. I tried to cache
   -- tuples (stack context, semantic context, predicted alt) but it was slower
   -- than interpreting and much more complicated. Also required a huge amount of
   -- memory. The goal is not to create the world's fastest parser anyway. I'd like
   -- to keep this algorithm simple. By launching multiple threads, we can improve
   -- the speed of parsing across a large number of files.
   --
   --
   -- There is no strict ordering between the amount of input used by SLL vs LL,
   -- which makes it really hard to build a cache for full context. Let's say that
   -- we have input A B C that leads to an SLL conflict with full context X. That
   -- implies that using X we might only use A B but we could also use A B C D to
   -- resolve conflict. Input A B C D could predict alternative 1 in one position
   -- in the input and A B C E could predict alternative 2 in another position in
   -- input. The conflicting SLL configurations could still be non-unique in the
   -- full context prediction, which would lead us to requiring more input than the
   -- original A B C.   To make a   prediction cache work, we have to track   the exact
   -- input   used during the previous prediction. That amounts to a cache that maps
   -- X to a specific DFA for that context.
   --
   --
   -- Something should be done for left-recursive expression predictions. They are
   -- likely LL (1) + pred eval. Easier to do the whole SLL unless error and retry
   -- with full LL thing Sam does.
   --
   --
   -- __AVOIDING FULL CONTEXT PREDICTION__
   --
   --
   -- We avoid doing full context rewhen the outer context is empty, we did not;
   -- dip into the outer context by falling off the end of the decision state rule,
   -- or when we force SLL mode.
   --
   --
   -- As an example of the not dip into outer context case, consider as super
   -- constructor calls versus function calls. One grammar might look like
   -- this:
   --
   --
   -- ctorBody
   -- : '{' superCall? stat* '}'
   -- ;
   --
   --
   --
   -- Or, you might see something like
   --
   --
   -- stat
   -- : superCall ';'
   -- | expression ';'
   -- |  ..
   -- ;
   --
   --
   --
   -- In both cases I believe that no closure operations will dip into the outer
   -- context. In the first case ctorBody in the worst case will stop at the '}'.
   -- In the 2nd case it should stop at the ';'. Both cases should stay within the
   -- enrule and not dip into the outer context.;
   --
   --
   -- __PREDICATES__
   --
   --
   -- Predicates are always evaluated if present in either SLL or LL both. SLL and
   -- LL simulation deals with predicates differently. SLL collects predicates as
   -- it performs closure operations like ANTLR v3 did. It delays predicate
   -- evaluation until it reaches and accept state. This allows us to cache the SLL
   -- ATN simulation whereas, if we had evaluated predicates on-the-fly during
   -- closure, the DFA state configuration sets would be different and we couldn't
   -- build up a suitable DFA.
   --
   --
   -- When building a DFA accept state during ATN simulation, we evaluate any
   -- predicates and return the sole semantically valid alternative. If there;
   -- more than 1 alternative, we report an ambiguity. If there are 0 alternatives,
   -- we raise an exception. Alternatives without predicates act like they have
   -- True predicates. The simple way to think about it is to strip away all
   -- alternatives with False predicates and choose the minimum alternative that
   -- remains.
   --
   --
   -- When we start in the DFA and reach an accept state that's predicated, we test
   -- those and return the minimum semantically viable alternative. If no
   -- alternatives are viable, we raise an exception.
   --
   --
   -- During full LL ATN simulation, closure always evaluates predicates and
   -- on-the-fly. This is crucial to reducing the configuration set size during
   -- closure. It hits a landmine when parsing with the Java grammar, for example,
   -- without this on-the-fly evaluation.
   --
   --
   -- __SHARING DFA__
   --
   --
   -- All instances of the same parser share the same decision DFAs through a
   -- static field. Each instance gets its own ATN simulator but they share the
   -- same _#decisionToDFA_ field. They also share a
   -- _org.antlr.v4.runtime.atn.PredictionContextCache_ object that makes sure that all
   -- _org.antlr.v4.runtime.atn.PredictionContext_ objects are shared among the DFA states. This makes
   -- a big size difference.
   --
   --
   -- __THREAD SAFETY__
   --
   --
   -- The _org.antlr.v4.runtime.atn.ParserATNSimulator_ locks on the _#decisionToDFA_ field when
   -- it adds a new DFA object to that array. _#addDFAEdge_
   -- locks on the DFA for the current decision when setting the
   -- _org.antlr.v4.runtime.DFA.States#edges_ field. _#addDFAState_ locks on
   -- the DFA for the current decision when looking up a DFA state to see if it
   -- already exists. We must make sure that all requests to add DFA states that
   -- are equivalent result in the same shared DFA object. This is because lots of
   -- threads will be trying to update the DFA at once. The
   -- _#addDFAState_ method also locks inside the DFA lock
   -- but this time on the shared context cache when it rebuilds the
   -- configurations' _org.antlr.v4.runtime.atn.PredictionContext_ objects using cached
   -- subgraphs/nodes. No other locking occurs, even during DFA simulation. This;
   -- safe as long as we can guarantee that all threads referencing
   -- `s.edge.Element (t)` get the same physical target _org.antlr.v4.runtime.DFA.States_, or
   -- ` (Valid => False)`. Once into the DFA, the DFA simulation does not reference the
   -- _org.antlr.v4.runtime.dfa.DFA#states_ map. It follows the _org.antlr.v4.runtime.DFA.States#edges_ field to new
   -- targets. The DFA simulator will either find _org.antlr.v4.runtime.DFA.States#edges_ to be
   -- ` (Valid => False)`, to be non-` (Valid => False)` and `DFAState.Container.Element (dfa.edges, t)`  (Valid => False), or
   -- `DFAState.Container.Element (dfa.edges, t)` to be non- (Valid => False). The
   -- _#addDFAEdge_ method could be racing to set the field
   -- but in either case the DFA simulator works; if ` (Valid => False)`, and requests ATN
   -- simulation. It could also race trying to get `DFAState.Container.Element (dfa.edges, t)`, but either
   -- way it will work because it's not doing a test and set operation.
   --
   --
   -- __Starting with SLL then failing to combined SLL/LL (Two-Stage
   -- Parsing)__
   --
   --
   -- Sam pointed out that if SLL does not give a syntax error, then there is no
   -- point in doing full LL, which is slower. We only have to LL if we get a;
   -- syntax error. For maximum speed, Sam starts the parser set to pure SLL
   -- mode with the _org.antlr.v4.runtime.BailErrorStrategy_:
   --
   --
   -- parser._org.antlr.v4.runtime.Parser#getInterpreter This.getInterpreter_._#setPredictionMode setPredictionMode_`(`_PredictionMode#SLL_`)`;
   -- parser._org.antlr.v4.runtime.Parser#setErrorHandler setErrorHandler_ (new _org.antlr.v4.runtime.BailErrorStrategy_);
   --
   --
   --
   -- If it does not get a syntax error, then we're done. If it does get a syntax
   -- error, we need to rewith the combined SLL/LL strategy.;
   --
   --
   -- The reason this works is as follows. If there are no SLL conflicts, then the
   -- grammar is SLL (at least for that input set). If there is an SLL conflict,
   -- the full LL analysis must yield a set of viable alternatives which is a
   -- subset of the alternatives reported by SLL. If the LL set is a singleton,
   -- then the grammar is LL but not SLL. If the LL set is the same size as the SLL
   -- set, the decision is SLL. If the LL set has size > 1, then that decision
   -- is truly ambiguous on the current input. If the LL set is smaller, then the
   -- SLL conflict resolution might choose an alternative that the full LL would
   -- rule out as a possibility based upon better context information. If that's
   -- the case, then the SLL parse will definitely get an error because the full LL
   -- analysis says it's not viable. If SLL conflict resolution chooses an
   -- alternative within the LL set, them both SLL and LL would choose the same
   -- alternative because they both choose the minimum of multiple conflicting
   -- alternatives.
   --
   --
   -- Let's say we have a set of SLL conflicting alternatives `{1, 2, 3`} and
   -- a smaller LL set called __s__. if __s__ is `then2, 3`}, then SLL
   -- parsing will get an error because SLL will pursue alternative 1. If
   -- __s__ is `{1, 2`} or `{1, 3`} then both SLL and LL will
   -- choose the same alternative because alternative one is the minimum of either
   -- set. if __s__ is `{2`} or `then3`} then SLL will get a syntax
   -- error. if __s__ is `then1`} then SLL will succeed.
   --
   --
   -- Of course, if the input is invalid, then we will get an error for sure in
   -- both SLL and LL parsing. Erroneous input will therefore require 2 passes over
   -- the input.
   --

   -- ------------- --
   -- DoubleKey_Map --
   -- ------------- --

   function MurMur3_Hash (Key : DoubleKey) return Ada.Containers.Hash_Type;

   function Equivalent_DoubleKeys (Left, Right : DoubleKey) return Boolean
      is (MurMur3_Hash (Left) = MurMur3_Hash (Right)
      or else MurMur3_Hash ((Left.B, Left.B)) = MurMur3_Hash (Right)); --TOFIX

   function "=" (Left, Right : DoubleKey) return Boolean;
   -- PredictionContext.Optional_DoubleKeyMap;
   package DoubleKey_Dictiorary is new Ada.Containers.Hashed_Maps (
      Key_Type => DoubleKey,
      Element_Type => PredictionContext, --TOFIX
      Hash => MurMur3_Hash,
      Equivalent_Keys => Equivalent_DoubleKeys,
      "=" => "=");
   subtype DoubleKey_Map is DoubleKey_Dictiorary.Map;

   -- ------------------ --
   -- ParserATNSimulator --
   -- ------------------ --
   -- open
   type ParserATNSimulator is new ATNSimulator with
   record
      -- public
      debug : Boolean := False; -- constant
      -- public
      trace_atn_sim : Boolean := False; -- constant
      -- public
      dfa_debug : Boolean := False; -- constant
      -- public
      retry_debug : Boolean := False; -- constant

      -- internal final unowned
      parser : Parser; -- constant

      -- public private (set) final
      decisionToDFA : DFA_List;

      --
      -- SLL, LL, or LL + exact ambig detection?
      --

      -- private
      mode : PredictionMode := LL;

      --
      -- Each prediction operation uses a cache for merge of prediction contexts.
      -- Don't keep around as it wastes huge amounts of memory. DoubleKeyMap
      -- isn't synchronized but we're ok since two threads shouldn't reuse same
      -- parser/atnsim object because it can only handle one input at a time.
      -- This maps graphs a and b to merged result c. (a,b)->c. We can avoid
      -- the merge if we ever see a and b again.  Note that (b,a)->c should
      -- also be examined during cache lookup.
      --
      -- internal final
      mergeCache : DoubleKey_Map; -- <PredictionContext, PredictionContext, PredictionContext>?;

      -- LAME globals to avoid parameters!!!!! I need these down deep in predTransition
      -- internal
      input : TokenStream; -- !
      -- internal
      startIndex : Integer := 0;
      -- internal
      outerContext : ParserRuleContext; -- !
      -- internal
      dfa : Optional_DFA;
   end record;

   subtype Object is ParserATNSimulator;
   subtype Super is ATNSimulator;
   type Class is access all Object;
   type Class_Wide is access all Object'Class;

   --
   -- Just in case this optimization is bad, add an ENV variable to turn it off
   --
   -- public static
   function Turn_Off_LR_Loop_Entry_Branch_Opt return Boolean; -- constant  --TOFIX

   --  Testing only!
   --  public convenience
   --  procedure Initialize (Self : ParserATNSimulator;
   --                 atn : ATN;
   --                 decisionToDFA : DFA_List;
   --                 sharedContextCache : PredictionContextCache);

   -- public
   procedure Initialize (Self : in out ParserATNSimulator;
                         parser : Parser;
                         atn : ATN;
                         decisionToDFA : DFA_List;
                         sharedContextCache : PredictionContextCache);

   -- open
   overriding
   procedure reset (This : ParserATNSimulator);

   -- open
   overriding
   procedure clearDFA (This : ParserATNSimulator);

   -- open
   function adaptivePredict (This : ParserATNSimulator;
                             input : TokenStream;
                             decision : State;
                             outerContext : Optional_ParserRuleContext)
                             return Integer;

   --
   -- Performs ATN simulation to compute a predicted alternative based
   -- upon the remaining input, but also updates the DFA cache to avoid
   -- having to traverse the ATN again for the same input sequence.
   --
   -- There are some key conditions we're looking for after computing a new
   -- set of ATN configs (proposed DFA state):
   -- if the set is empty, there is no viable alternative for current symbol
   -- does the state uniquely predict an alternative?
   -- does the state have a conflict that would prevent us from
   -- putting it on the work list?
   --
   -- We also have some key operations to do:
   -- add an edge from previous DFA state to potentially new DFA state, D,
   -- upon current symbol but only if adding to work list, which means in all
   -- cases except no viable alternative (and possibly non-greedy decisions?);
   -- collecting predicates and adding semantic context to DFA accept states
   -- adding rule context to context-sensitive DFA accept states
   -- consuming an input symbol
   -- reporting a conflict
   -- reporting an ambiguity
   -- reporting a context sensitivity
   -- reporting insufficient predicates
   --
   -- cover these cases:
   -- dead end
   -- single alt
   -- single alt + preds
   -- conflict
   -- conflict + preds
   --
   -- final
   function execATN (This : ParserATNSimulator;
                     dfa : DFA;
                     s0 : DFAState;
                     input : TokenStream;
                     startIndex : Integer;
                     outerContext : ParserRuleContext)
                     return Integer;

   --
   -- Get an existing target state for an edge in the DFA. If the target state
   -- for the edge has not yet been computed or is otherwise not available,
   -- this method returns ` (Valid => False)`.
   --
   -- * parameter previousD: The current DFA state
   -- * parameter t: The next input symbol
   -- * returns: The existing target DFA state for the given input symbol
   -- `t`, or ` (Valid => False)` if the target state for this edge is not
   -- already cached
   --
   function getExistingTargetState (This : ParserATNSimulator; previousD : DFAState; t : Integer) return Optional_DFAState;

   --
   -- Compute a target state for an edge in the DFA, and attempt to add the
   -- computed state and corresponding edge to the DFA.
   --
   -- * parameter dfa: The DFA
   -- * parameter previousD: The current DFA state
   -- * parameter t: The next input symbol
   --
   -- * returns: The computed target DFA state for the given input symbol
   -- `t`. If `t` does not lead to a valid DFA state, this method
   -- returns _#ERROR_.
   --
   function computeTargetState (This : ParserATNSimulator; dfa : DFA; previousD : DFAState; t : Integer) return DFAState;

   -- final
   procedure predicateDFAState (This : ParserATNSimulator; dfaState : DFAState; decisionState : DecisionState);

   -- comes back with reach.uniqueAlt set to a valid alt
   -- final
   function execATNWithFullContext (This : ParserATNSimulator;
                                    dfa : DFA;
                                    D : DFAState; -- how far we got in SLL DFA before failing over
                                    s0 : ATNConfigSet;
                                    input : TokenStream;
                                    startIndex : Integer;
                                    outerContext : ParserRuleContext)
                                    return Integer;

   function computeReachSet (This : ParserATNSimulator;
                             closureConfigSet : ATNConfigSet;
                             t : Integer;
                             fullCtx : Boolean)
                             return Optional_ATNConfigSet;

   --
   -- Return a configuration set containing only the configurations from
   -- `configs` which are in a _org.antlr.v4.runtime.atn.RuleStopState_. If all
   -- configurations in `configs` are already in a rule stop state, this
   -- method simply returns `configs`.
   --
   -- When `lookToEndOfRule` is True, this method uses
   -- _org.antlr.v4.runtime.atn.ATN#nextTokens_ for each configuration in `configs` which;
   -- not already in a rule stop state to see if a rule stop state is reachable
   -- from the configuration via epsilon-only transitions.
   --
   -- * parameter configs: the configuration set to update
   -- * parameter lookToEndOfRule: when True, this method checks for rule stop states
   -- reachable by epsilon-only transitions from each configuration in
   -- `configs`.
   --
   -- * returns: `configs` if all configurations in `configs` are in a
   -- rule stop state, otherwise return a new configuration set containing only
   -- the configurations from `configs` which are in a rule stop state
   --
   -- final
   function removeAllConfigsNotInRuleStopState (This : ParserATNSimulator; configs : ATNConfigSet; lookToEndOfRule : Boolean) return ATNConfigSet
      is (configs.removeAllConfigsNotInRuleStopState (This.mergeCache,lookToEndOfRule,atn));

   -- final
   function computeStartState (This : ParserATNSimulator;
                               p : ATNState;
                               ctx : RuleContext;
                               fullCtx : Boolean)
                               return ATNConfigSet;

   --
   -- parrt internal source braindump that doesn't mess up
   -- external API spec.
   --
   -- applyPrecedenceFilter is an optimization to avoid highly
   -- nonlinear prediction of expressions and other left recursive
   -- rules. The precedence predicates such as {3>=prec}? Are highly
   -- context-sensitive in that they can only be properly evaluated
   -- in the context of the proper prec argument. Without pruning,
   -- these predicates are normal predicates evaluated when we reach
   -- conflict state (or unique prediction). As we cannot evaluate
   -- these predicates out of context, the resulting conflict leads
   -- to full LL evaluation and nonlinear prediction which shows up
   -- very clearly with fairly large expressions.
   --
   -- Example grammar:
   --
   -- e : e '*' e
   -- | e '+' e
   -- | INT
   -- ;
   --
   -- We convert that to the following:
   --
   -- e[int prec]
   -- :   INT
   -- ( {3>=prec}? '*' e.Element (4);
   -- | {2>=prec}? '+' e.Element (3);
   -- )*
   -- ;
   --
   -- The (..)* loop has a decision for the inner block as well as
   -- an enter or exit decision, which is what concerns us here. At
   -- the 1st + of input 1+2+3, the loop ensees both predicates;
   -- and the loop exit also sees both predicates by falling off the
   -- edge of e.  This is because we have no stack information with
   -- SLL and find the follow of e, which will hit the return states;
   -- inside the loop after e.Element (4) and e.Element (3), which brings it back to
   -- the enter or exit decision. In this case, we know that we
   -- cannot evaluate those predicates because we have fallen off
   -- the edge of the stack and will in general not know which prec
   -- parameter is the right one to use in the predicate.
   --
   -- Because we have special information, that these are precedence
   -- predicates, we can resolve them without failing over to full
   -- LL despite their context sensitive nature. We make an
   -- assumption that prec[-1] <= prec.Element (0), meaning that the current
   -- precedence level is greater than or equal to the precedence
   -- level of recursive invocations above us in the stack. For
   -- example, if predicate then3>=prec}? is True of the current prec,
   -- then one option is to enter the loop to match it now. The
   -- other option is to exit the loop and the left recursive rule
   -- to match the current operator in rule invocation further up
   -- the stack. But, we know that all of those prec are lower or
   -- the same value and so we can decide to enter the loop instead
   -- of matching it later. That means we can strip out the other
   -- configuration for the exit branch.
   --
   -- So imagine we have (14,1,$,{2>=prec}?) and then
   -- (14,2,$-dipsIntoOuterContext,{2>=prec}?). The optimization
   -- allows us to collapse these two configurations. We know that
   -- if then2>=prec}? is True for the current prec parameter, it will
   -- also be True for any prec from an invoking e call, indicated
   -- by dipsIntoOuterContext. As the predicates are both True, we
   -- have the option to evaluate them early in the decision start
   -- state. We do this by stripping both predicates and choosing to
   -- enter the loop as it is consistent with the notion of operator
   -- precedence. It's also how the full LL conflict resolution
   -- would work.
   --
   -- The solution requires a different DFA start state for each
   -- precedence level.
   --
   -- The basic filter mechanism is to remove configurations of the
   -- form (p, 2, pi) if (p, 1, pi) exists for the same p and pi. In
   -- other words, for the same ATN state and predicate context,
   -- remove any configuration associated with an exit branch if
   -- there is a configuration associated with the enter branch.
   --
   -- It's also the case that the filter evaluates precedence
   -- predicates and resolves conflicts according to precedence
   -- levels. For example, for input 1+2+3 at the first +, we see
   -- prediction filtering
   --
   -- [(11,1,[$],{3>=prec}?), (14,1,[$],{2>=prec}?), (5,2,[$],up=1),
   -- (11,2,[$],up=1), (14,2,[$],up=1)],hasSemanticContext=True,dipsIntoOuterContext
   --
   -- to
   --
   -- [(11,1,[$]), (14,1,[$]), (5,2,[$],up=1)],dipsIntoOuterContext
   --
   -- This filters because {3>=prec}? evals to True and collapses
   -- (11,1,[$],{3>=prec}?) and (11,2,[$],up=1) since early conflict
   -- resolution based upon rules of operator precedence fits with
   -- our usual match first alt upon conflict.
   --
   -- We noticed a problem where a recursive call resets precedence
   -- to 0. Sam's fix: each config has flag indicating if it has
   -- returned from an expr.Element (0) call. then just don't filter any
   -- config with that flag set. flag is carried along in
   -- This.closure. so to avoid adding field, set bit just under sign
   -- bit of dipsIntoOuterContext (SUPPRESS_PRECEDENCE_FILTER).
   -- With the change you filter "unless (p, 2, pi) was reached
   -- after leaving the rule stop state of the LR rule containing
   -- state p, corresponding to a rule invocation with precedence
   -- level 0"
   --

   --
   -- This method transforms the start state computed by
   -- _#computeStartState_ to the special start state used by a
   -- precedence DFA for a particular precedence value. The transformation
   -- process applies the following changes to the start state's configuration
   -- set.
   --
   -- * Evaluate the precedence predicates for each configuration using
   -- _org.antlr.v4.runtime.atn.SemanticContext#evalPrecedence_.
   -- * When _org.antlr.v4.runtime.atn.ATNConfig#isPrecedenceFilterSuppressed_ is `False`,
   -- remove all configurations which predict an alternative greater than 1,
   -- for which another configuration that predicts alternative 1 is in the
   -- same ATN state with the same prediction context. This transformation;
   -- valid for the following reasons:
   --
   -- * The closure block cannot contain any epsilon transitions which bypass
   -- the body of the closure, so all states reachable via alternative 1 are
   -- part of the precedence alternatives of the transformed left-recursive
   -- rule.
   -- * The "primary" portion of a left recursive rule cannot contain an
   -- epsilon transition, so the only way an alternative other than 1 can exist
   -- in a state that is also reachable via alternative 1 is by nesting calls
   -- to the left-recursive rule, with the outer calls not being at the
   -- preferred precedence level. The
   -- _org.antlr.v4.runtime.atn.ATNConfig#isPrecedenceFilterSuppressed_ property marks ATN
   -- configurations which do not meet this condition, and therefore are not
   -- eligible for elimination during the filtering process.
   --
   -- The prediction context must be considered by this filter to address
   -- situations like the following.
   -- ```
   -- grammar TA;
   -- prog: statement* EOF;
   -- statement: letterA | statement letterA 'b' ;
   -- letterA: 'a';
   -- ```
   -- If the above grammar, the ATN state immediately before the token
   -- reference `'a'` in `letterA` is reachable from the left edge
   -- of both the primary and closure blocks of the left-recursive rule
   -- `statement`. The prediction context associated with each of these
   -- configurations distinguishes between them, and prevents the alternative
   -- which stepped out to `prog` (and then back in to `statement`
   -- from being eliminated by the filter.
   --
   -- * parameter configs: The configuration set computed by
   -- _#computeStartState_ as the start state for the DFA.
   -- * returns: The transformed configuration set representing the start state
   -- for a precedence DFA at a particular precedence level (determined by
   -- calling _org.antlr.v4.runtime.Parser#getPrecedence_).
   --
   -- final internal
   function applyPrecedenceFilter (This : ParserATNSimulator; configs : ATNConfigSet) return ATNConfigSet
      is (configs.applyPrecedenceFilter (This.mergeCache,parser,This.outerContext));

   -- final internal
   function getReachableTarget (This : ParserATNSimulator; trans : ATNTransition; tType : Token_Kind) return Optional_ATNState;

   -- final internal
   function getPredsForAmbigAlts (This : ParserATNSimulator;
                                  ambigAlts : BitSet;
                                  configs : ATNConfigSet;
                                  nalts : Integer)
                                  return SemanticContext_List;

   -- final internal
   function getPredicatePredictions (This : ParserATNSimulator;
                                     ambigAlts : Optional_BitSet;
                                     altToPred : SemanticContext_List)
                                     return DFAState.PredPrediction.Vector;

   --
   -- This method is used to improve the localization of error messages by
   -- choosing an alternative rather than throwing a
   -- _org.antlr.v4.runtime.NoViableAltException_ in particular prediction scenarios where the
   -- _#ERROR_ state was reached during ATN simulation.
   --
   -- The default implementation of this method uses the following
   -- algorithm to identify an ATN configuration which successfully parsed the
   -- decision enrule. Choosing such an alternative ensures that the;
   -- _org.antlr.v4.runtime.ParserRuleContext_ returned by the calling rule will be complete
   -- and valid, and the syntax error will be reported later at a more
   -- localized location.
   --
   -- * If a syntactically valid path or paths reach the end of the decision rule and
   -- they are semantically valid if predicated, return the min associated alt.
   -- * Else, if a semantically invalid but syntactically valid path exist
   -- or paths exist, return the minimum associated alt.
   -- * Otherwise, return _org.antlr.v4.runtime.atn.ATN#INVALID_ALT_NUMBER_.
   --
   -- In some scenarios, the algorithm described above could predict an
   -- alternative which will result in a _org.antlr.v4.runtime.FailedPredicateException_ in
   -- the parser. Specifically, this could occur if the __only__ configuration
   -- capable of successfully parsing to the end of the decision rule;
   -- blocked by a semantic predicate. By choosing this alternative within
   -- _#adaptivePredict_ instead of throwing a
   -- _org.antlr.v4.runtime.NoViableAltException_, the resulting
   -- _org.antlr.v4.runtime.FailedPredicateException_ in the parser will identify the specific
   -- predicate which is preventing the parser from successfully parsing the
   -- decision rule, which helps developers identify and correct logic errors
   -- in semantic predicates.
   --
   -- * parameter configs: The ATN configurations which were valid immediately before
   -- the _#ERROR_ state was reached
   -- * parameter outerContext: The is the \gamma_0 initial parser context from the paper
   -- or the parser stack at the instant before prediction commences.
   --
   -- * returns: The value to return from _#adaptivePredict_, or
   -- _org.antlr.v4.runtime.atn.ATN#INVALID_ALT_NUMBER_ if a suitable alternative was not
   -- identified and _#adaptivePredict_ should report an error instead.
   --
   -- final internal
   function getSynValidOrSemInvalidAltThatFinishedDecisionEntryRule (This : ParserATNSimulator; 
                                                                     configs : ATNConfigSet;
                                                                     outerContext : ParserRuleContext)
                                                                     return Integer;

   --
   -- Walk the list of configurations and split them according to
   -- those that have preds evaluating to True/False.  If no pred, assume
   -- True pred and include in succeeded set.  Returns Pair of sets.
   --
   -- Create a new set so as not to alter the incoming parameter.
   --
   -- Assumption: the input stream has been restored to the starting point
   -- prediction, which is where predicates need to evaluate.
   --
   -- final internal
   function splitAccordingToSemanticValidity (This : ParserATNSimulator;
                                              configs : ATNConfigSet;
                                              outerContext : ParserRuleContext)
                                              return Splitted_ConfigSets
      is (configs.splitAccordingToSemanticValidity (outerContext, evalSemanticContext'Access));

   --
   -- Look through a list of predicate/alt pairs, returning alts for the
   -- pairs that win. A `NONE` predicate indicates an alt containing an
   -- unpredicated config which behaves as "always True." If not complete
   -- then we stop at the first predicate that evaluates to True. This
   -- includes pairs with  (Valid => False) predicates.
   --
   -- final internal
   function evalSemanticContext (This : ParserATNSimulator;
                                 predPredictions : PredPrediction_List;
                                 outerContext : ParserRuleContext;
                                 complete : Boolean)
                                 return BitSet;

   --
   -- Evaluate a semantic context within a specific parser context.
   --
   -- This method might not be called for every semantic context evaluated
   -- during the prediction process. In particular, we currently do not
   -- evaluate the following but it may change in the future:
   --
   -- * Precedence predicates (represented by
   -- _org.antlr.v4.runtime.atn.SemanticContext.PrecedencePredicate_) are not currently evaluated
   -- through this method.
   -- * Operator predicates (represented by _org.antlr.v4.runtime.atn.SemanticContext.AND_ and
   -- _org.antlr.v4.runtime.atn.SemanticContext.OR_) are evaluated as a single semantic
   -- context, rather than evaluating the operands individually.
   -- Implementations which require evaluation results from individual
   -- predicates should override this method to explicitly handle evaluation of
   -- the operands within operator predicates.
   --
   -- * parameter pred: The semantic context to evaluate
   -- * parameter parserCallStack: The parser context in which to evaluate the
   -- semantic context
   -- * parameter alt: The alternative which is guarded by `pred`
   -- * parameter fullCtx: `True` if the evaluation is occurring during LL
   -- prediction; otherwise, `False` if the evaluation is occurring
   -- during SLL prediction
   --
   -- * since: 4.3
   --
   -- internal
   function evalSemanticContext (This : ParserATNSimulator;
                                 pred : SemanticContext;
                                 parserCallStack : ParserRuleContext;
                                 alt : Integer;
                                 fullCtx : Boolean)
                                 return Boolean
      is (pred.eval (parser, parserCallStack));

   --
   -- TODO: If we are doing predicates, there is no point in pursuing
   -- closure operations if we reach a DFA state that uniquely predicts
   -- alternative. We will not be caching that DFA state and it is a
   -- waste to pursue the closure. Might have to advance when we do
   -- ambig detection thought :(
   --
   -- final internal
   procedure closure (This : ParserATNSimulator;
                      config : ATNConfig;
                      configs : ATNConfigSet;
                      closureBusy : in out Set_of_ATNConfigs;
                      collectPredicates : Boolean;
                      fullCtx : Boolean;
                      treatEofAsEpsilon : Boolean);

   -- final internal
   procedure closureCheckingStopState (This : ParserATNSimulator;
                                       config : ATNConfig;
                                       configs : ATNConfigSet;
                                       closureBusy : in out Set_of_ATNConfigs;
                                       collectPredicates : Boolean;
                                       fullCtx : Boolean;
                                       depth : Integer;
                                       treatEofAsEpsilon : Boolean);

   --
   -- Do the actual work of walking epsilon edges
   --
   -- final internal
   procedure closure_2 (This : ParserATNSimulator; 
                        config : ATNConfig;
                        configs : ATNConfigSet;
                        closureBusy : in out Set_of_ATNConfigs;
                        collectPredicates : Boolean;
                        fullCtx : Boolean;
                        depth : Integer;
                        treatEofAsEpsilon : Boolean);

   --
   -- Implements first-edge (loop entry) elimination as an optimization
   -- during closure operations.  See antlr/antlr4#1398.
   --
   -- The optimization is to avoid adding the loop enconfig when;
   -- the exit path can only lead back to the same
   -- StarLoopEntryState after popping context at the rule end state
   -- (traversing only epsilon edges, so we're still in closure, in
   -- this same rule).
   --
   -- We need to detect any state that can reach loop enon;
   -- epsilon w/o exiting rule. We don't have to look at FOLLOW
   -- links, just ensure that all stack tops for config refer to key
   -- states in LR rule.
   --
   -- To verify we are in the right situation we must first check
   -- closure is at a StarLoopEntryState generated during LR removal.
   -- Then we check that each stack top of context is a return state;
   -- from one of these cases:
   --
   -- 1. 'not' expr, '(' type ')' expr. The return state points at loop enstate;
   -- 2. expr op expr. The return state is the block end of internal block of ( .. )*
   -- 3. 'between' expr 'and' expr. The return state of 2nd expr reference.
   -- That state points at block end of internal block of ( .. )*.
   -- 4. expr '?' expr ':' expr. The return state points at block end,
   -- which points at loop enstate.;
   --
   -- If any is True for each stack top, then closure does not add a
   -- config to the current config set for edge.Element (0), the loop enbranch.;
   --
   -- Conditions fail if any context for the current config is:
   --
   -- a. empty (we'd fall out of expr to do a global FOLLOW which could
   -- even be to some weird spot in expr) or,
   -- b. lies outside of expr or,
   -- c. lies within expr but at a state not the BlockEndState
   -- generated during LR removal
   --
   -- Do we need to evaluate predicates ever in closure for this case?
   --
   -- No. Predicates, including precedence predicates, are only
   -- evaluated when computing a DFA start state. I.e., only before
   -- the lookahead (but not parser) consumes a token.
   --
   -- There are no epsilon edges allowed in LR rule alt blocks or in
   -- the "primary" part (ID here). If closure is in
   -- StarLoopEntryState any lookahead operation will have consumed a
   -- token as there are no epsilon-paths that lead to
   -- StarLoopEntryState. We do not have to evaluate predicates
   -- therefore if we are in the generated StarLoopEntryState of a LR
   -- rule. Note that when making a prediction starting at that
   -- decision point, decision d=2, compute-start-state performs
   -- closure starting at edges.Element (0), edges.Element (1) emanating from
   -- StarLoopEntryState. That means it is not performing closure on
   -- StarLoopEntryState during compute-start-state.
   --
   -- How do we know this always gives same prediction answer?
   --
   -- Without predicates, loop enand exit paths are ambiguous;
   -- upon remaining input +b (in, say, a+b). Either paths lead to
   -- valid parses. Closure can lead to consuming + immediately or by
   -- falling out of this call to expr back into expr and loop back
   -- again to StarLoopEntryState to match +b. In this special case,
   -- we choose the more efficient path, which is to take the bypass
   -- path.
   --
   -- The lookahead language has not changed because closure chooses
   -- one path over the other. Both paths lead to consuming the same
   -- remaining input during a lookahead operation. If the next token
   -- is an operator, lookahead will enter the choice block with
   -- operators. If it is not, lookahead will exit expr. Same as if
   -- closure had chosen to enter the choice block immediately.
   --
   -- Closure is examining one config (some loopentrystate, some alt,
   -- context) which means it is considering exactly one alt. Closure
   -- always copies the same alt to any derived configs.
   --
   -- How do we know this optimization doesn't mess up precedence in
   -- our parse trees?
   --
   -- Looking through expr from left edge of stat only has to confirm
   -- that an input, say, a+b+c; begins with any valid interpretation
   -- of an expression. The precedence actually doesn't matter when
   -- making a decision in stat seeing through expr. It is only when
   -- parsing rule expr that we must use the precedence to get the
   -- right interpretation and, hence, parse tree.
   --
   -- internal
   function canDropLoopEntryEdgeInLeftRecursiveRule (This : ParserATNSimulator; config : ATNConfig) return Boolean;

   -- open
   function getRuleName (This : ParserATNSimulator; index : Integer) return UString;

   -- final
   function getEpsilonTarget (This : ParserATNSimulator;
                              config : ATNConfig;
                              t : ATNTransition;
                              collectPredicates : Boolean;
                              inContext : Boolean;
                              fullCtx : Boolean;
                              treatEofAsEpsilon : Boolean)
                              return Optional_ATNConfig;

   -- final
   function actionTransition (This : ParserATNSimulator;
                              config : ATNConfig;
                              t : ActionTransition)
                              return ATNConfig;

   -- final
   function precedenceTransition (This : ParserATNSimulator;config : ATNConfig;
                                  pt : PrecedencePredicateTransition;
                                  collectPredicates : Boolean;
                                  inContext : Boolean;
                                  fullCtx : Boolean) return Optional_ATNConfig;

   -- final
   function predTransition (This : ParserATNSimulator;config : ATNConfig;
                              pt : PredicateTransition;
                              collectPredicates : Boolean;
                              inContext : Boolean;
                              fullCtx : Boolean) return Optional_ATNConfig;

   -- final
   function ruleTransition (This : ParserATNSimulator; config : ATNConfig; t : RuleTransition) return ATNConfig;

   --
   -- Gets a _java.util.BitSet_ containing the alternatives in `configs`
   -- which are part of one or more conflicting alternative subsets.
   --
   -- * parameter configs: The _org.antlr.v4.runtime.atn.ATNConfigSet_ to analyze.
   -- * returns: The alternatives in `configs` which are part of one or more
   -- conflicting alternative subsets. If `configs` does not contain any
   -- conflicting subsets, this method returns an empty _java.util.BitSet_.
   --
   -- final
   function getConflictingAlts (This : ParserATNSimulator; configs : ATNConfigSet) return BitSet;

   --
   -- Sam pointed out a problem with the previous definition, v3, of
   -- ambiguous states. If we have another state associated with conflicting
   -- alternatives, we should keep going. For example, the following grammar
   --
   -- s : (ID | ID ID?) ';' ;
   --
   -- When the ATN simulation reaches the state before ';', it has a DFA
   -- state that looks like: [12|1|[], 6|2|[], 12|2|[]]. Naturally
   -- 12|1|[] and 12|2|[] conflict, but we cannot stop processing this node
   -- because alternative to has another way to continue, via [6|2|[]].
   -- The key is that we have a single state that has config's only associated
   -- with a single alternative, 2, and crucially the state transitions
   -- among the configurations are all non-epsilon transitions. That means
   -- we don't consider any conflicts that include alternative 2. So, we
   -- ignore the conflict between alts 1 and 2. We ignore a set of
   -- conflicting alts when there is an intersection with an alternative
   -- associated with a single alt state in the state>config-list map.
   --
   -- It's also the case that we might have two conflicting configurations but
   -- also a 3rd nonconflicting configuration for a different alternative:
   -- [1|1|[], 1|2|[], 8|3|[]]. This can come about from grammar:
   --
   -- a : A | A | A B ;
   --
   -- After matching input A, we reach the stop state for rule A, state 1.
   -- State 8 is the state right before B. Clearly alternatives 1 and 2
   -- conflict and no amount of further lookahead will separate the two.
   -- However, alternative 3 will be able to continue and so we do not
   -- stop working on this state. In the previous example, we're concerned
   -- with states associated with the conflicting alternatives. Here alt
   -- 3 is not associated with the conflicting configs, but since we can continue
   -- looking for input reasonably, I don't declare the state done. We
   -- ignore a set of conflicting alts when we have an alternative
   -- that we still need to pursue.
   --
   -- final
   function getConflictingAltsOrUniqueAlt (This : ParserATNSimulator; configs : ATNConfigSet) return BitSet;

   -- public final
   function getTokenName (This : ParserATNSimulator; t : Integer) return UString;

   -- public final
   function getLookaheadName (This : ParserATNSimulator; input : TokenStream) return UString
      is (getTokenName (input.LA (1)));

   --
   -- Used for debugging in adaptivePredict around execATN but I cut
   -- it out for clarity now that alg. works well. We can leave this
   -- "dead" code for a bit.
   --
   -- public final
   procedure dumpDeadEndConfigs (This : ParserATNSimulator; nvae : NoViableAltException);

   -- final
   function noViableAlt (This : ParserATNSimulator;
                         input : TokenStream;
                         outerContext : ParserRuleContext;
                         configs : ATNConfigSet;
                         startIndex : Integer)
                         return NoViableAltException;

   -- internal static
   function getUniqueAlt (configs : ATNConfigSet) return Integer
      is (This.configs.getUniqueAlt);

   --
   -- Add an edge to the DFA, if possible. This method calls
   -- _#addDFAState_ to ensure the `to` state is present in the
   -- DFA. If `from` is ` (Valid => False)`, or if `t` is outside the
   -- range of edges that can be represented in the DFA tables, this method
   -- returns without adding the edge to the DFA.
   --
   -- If `to` is ` (Valid => False)`, this method returns ` (Valid => False)`.
   -- Otherwise, this method returns the _org.antlr.v4.runtime.DFA.States_ returned by calling
   -- _#addDFAState_ for the `to` state.
   --
   -- * parameter dfa: The DFA
   -- * parameter from: The source state for the edge
   -- * parameter t: The input symbol
   -- * parameter to: The target state for the edge
   --
   -- * returns: the result of calling _#addDFAState_ on `to`
   --
   -- @discardableResult
   -- private final
   function addDFAEdge (This : ParserATNSimulator;
                        dfa : DFA;
                        from : DFAState;
                        t : Integer;
                        to : DFAState)
                        return DFAState;

   --
   -- Add state `D` to the DFA if it is not already present, and return
   -- the actual instance stored in the DFA. If a state equivalent to `D`
   -- is already in the DFA, the existing state is returned. Otherwise this
   -- method returns `D` after adding it to the DFA.
   --
   -- If `D` is _#ERROR_, this method returns _#ERROR_ and
   -- does not change the DFA.
   --
   -- * parameter dfa: The dfa
   -- * parameter D: The DFA state to add
   -- * returns: The state stored in the DFA. This will be either the existing
   -- state if `D` is already in the DFA, or `D` itself if the
   -- state was not already present.
   --
   -- private final
   function addDFAState (This : ParserATNSimulator; dfa : DFA; D : DFAState) return DFAState;

   procedure reportAttemptingFullContext (This : ParserATNSimulator;
                                          dfa : DFA;
                                          conflictingAlts : Optional_BitSet;
                                          configs : ATNConfigSet;
                                          startIndex, stopIndex : Integer);

   procedure reportContextSensitivity (This : ParserATNSimulator;
                                       dfa : DFA;
                                       prediction : Integer;
                                       configs : ATNConfigSet;
                                       startIndex, stopIndex : Integer);

   --
   -- If context sensitive parsing, we know it's ambiguity not conflict
   --
   -- configs that LL not SLL considered conflictin
   -- internal
   procedure reportAmbiguity (This : ParserATNSimulator;
                              dfa : DFA;
                              D : DFAState; -- the DFA state from This.execATN that had SLL conflicts
                              startIndex, stopIndex : Integer;
                              exact : Boolean;
                              ambigAlts : BitSet;
                              configs : ATNConfigSet);

   -- private
   function getTextInInterval (This : ParserATNSimulator;
                               startIndex, stopIndex : Integer)
                              return UString;

   -- public final
   procedure setPredictionMode (This : ParserATNSimulator; mode : PredictionMode);

   -- public final
   function getPredictionMode (This : ParserATNSimulator) return PredictionMode
      is (This.mode);

   -- public final
   function getParser (This : ParserATNSimulator) return Parser
      is (parser);

end ANTLR.Runtime.ATN.Simulators.Parsers;
