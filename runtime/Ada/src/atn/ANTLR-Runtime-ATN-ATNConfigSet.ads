-- €

with Ada.Containers;
with ANTLR.Runtime.ATN.LookupDictionary;
with ANTLR.Runtime.ATN.ATNConfig;
with ANTLR.Runtime.Misc.DoubleKeyMap;
with ANTLR.Runtime.Misc.BitSet;

use ANTLR.Runtime.ATN;
use ANTLR.Runtime.ATN.LookupDictionary;
use ANTLR.Runtime.ATN.ATNConfig;
use ANTLR.Runtime.Misc.DoubleKeyMap;
use ANTLR.Runtime.Misc.BitSet;

package ANTLR.Runtime.ATN.ATNConfigSet is

   --
   -- Specialized _java.util.Set_`<`_org.antlr.v4.runtime.atn.ATNConfig_`>` that can track
   -- info about the set, with support for combining similar configurations using a
   -- graph-structured stack.
   --
   -- public final
   --
   -- The reason that we need this is because we don't want the hash map to use
   -- the standard hash code and equals. We need all configurations with the same
   -- `(s,i,_,semctx)` to be equal. Unfortunately, this key effectively doubles
   -- the number of objects associated with ATNConfigs. The other solution is to
   -- use a hash table that lets us specify the equals/hashcode operation.
   --
   type ATNConfigSet is new Hashable and CustomStringConvertible with
   record
      --
      -- Indicates that the set of configurations is read-only. Do not
      -- allow any code to manipulate the set; DFA states will point at
      -- the sets and they must not change. This does not protect the other
      -- fields; in particular, conflictingAlts is set after
      -- we've made this readonly.
      --
      -- private
      readonly : Boolean := False;

      --
      -- All configs but hashed by (s, i, _, pi) not including context. Wiped out
      -- when we go readonly as this set becomes a DFA state.
      --
      -- private
      configLookup : LookupDictionary;

      --
      -- Track the elements as they are added to the set; supports get (i);
      --
      -- public private (set);
      configs : ATNConfig.Container.Vector := ATNConfig.Container.Empty_Vector;

      -- TODO: these fields make me pretty uncomfortable but nice to pack up info together, saves recomputation
      -- TODO: can we track conflicts as they are added to save scanning configs later?
      -- public internal (set)
      uniqueAlt : Integer := ATN.INVALID_ALT_NUMBER;
      --TODO no default

      --
      -- Currently this is only used when we detect SLL conflict; this does
      -- not necessarily represent the ambiguous alternatives. In fact,
      -- I should also point out that this seems to include predicated alternatives
      -- that have predicates that evaluate to False. Computed in computeTargetState ().
      --
      -- internal
      conflictingAlts : Optional_BitSet;

      -- Used in parser and lexer. In lexer, it indicates we hit a pred
      -- while computing a closure operation.  Don't make a DFA state from this.
      -- public internal (set)
      hasSemanticContext : Boolean := False;
      --TODO no default
      -- public internal (set)
      dipsIntoOuterContext : Boolean := False;
      --TODO no default

      --
      -- Indicates that this configuration set is part of a full context
      -- LL prediction. It will be used to determine how to merge $. With SLL
      -- it's a wildcard whereas it is not for LL context merge.
      --
      -- public
      fullCtx : Boolean; -- constant

      -- private
      cachedHashCode : Ada.Containers.Hash_Type := -1;
   end record;

   -- public
   procedure Initialize (Self : in out ATNConfigSet;
                   fullCtx  : Boolean := True;
                   isOrdered : Boolean := False);

   overriding
   -- @discardableResult
   -- public
   function add (This : in out ATNConfigSet; config : ATNConfig) return Boolean;

   --
   -- Adding a new config means merging contexts with existing configs for
   -- `(s, i, pi, _)`, where `s` is the
   -- _org.antlr.v4.runtime.atn.ATNConfig#state_, `i` is the _org.antlr.v4.runtime.atn.ATNConfig#alt_, and
   -- `pi` is the _org.antlr.v4.runtime.atn.ATNConfig#semanticContext_. We use
   -- `(s,i,pi)` as key.
   --
   -- This method updates _#dipsIntoOuterContext_ and
   -- _#hasSemanticContext_ when necessary.
   --
   -- @discardableResult
   -- public
   function add (This : in out ATNConfigSet;
                 config : ATNConfig;
                 mergeCache : in out PredictionContext.Optional_DoubleKeyMap)
                 return Boolean;

   -- public
   function getOrAdd (This : ATNConfigSet; config : ATNConfig) return ATNConfig
      is (This.configLookup.getOrAdd (config));

   --
   -- Return a List holding list of configs
   --
   -- public
   function elements (This : ATNConfigSet) return ATNConfig.Container.Vector
      is (This.configs);


   function getStates (This : ATNConfigSet) return Set_of_ATNStates;

   --
   -- Gets the complete set of represented alternatives for the configuration
   -- set.
   --
   -- * returns: the set of represented alternatives in this configuration set
   --
   -- public
   function getAlts (This : ATNConfigSet) return BitSet;

   -- public
   function getPredicates (This : ATNConfigSet) return SemanticContext.Container.Vector;

   -- public
   function get (This : ATNConfigSet; i : Integer) return ATNConfig
      is (This.configs.Element (i));

   -- public
   procedure optimizeConfigs (This : ATNConfigSet; interpreter : ATNSimulator);

   -- @discardableResult
   -- public
   function addAll (This : ATNConfigSet; coll : ATNConfigSet) return Boolean;

   -- public
   procedure hash (This : ATNConfigSet; hasher : in out Hasher);

   -- private
   function configshashValue return Ada.Containers.Hash_Type;

   -- public
   function count (This : ATNConfigSet) return Ada.Containers.Count_Type
      is (This.configs.Length);

   -- public
   function size (This : ATNConfigSet) return Ada.Containers.Count_Type renames count;

   -- public
   function isEmpty (This : ATNConfigSet) return Boolean
      is (This.configs.is_Empty);

   -- public
   function contains (o : ATNConfig) return Boolean
      is (This.configLookup.contains (o));

   -- public
   procedure clear (This : ATNConfigSet);

   -- public
   function isReadonly (This : ATNConfigSet) return Boolean
      is (This.readonly);

   -- public
   procedure setReadonly (This : ATNConfigSet; readonly  : Boolean);

   -- public
   subtype Sink is Ada.Strings.Text_Buffers.Root_Buffer_Type;
   procedure Put_Image_ATNConfigSet (S : in out Sink'Class; X : ATNConfigSet);
   for ATNConfigSet'Put_Image use Put_Image_ATNConfigSet;
   function Description (This : ATNConfigSet) return UString;
      buf : UString; -- := "";

   --
   -- override
   -- public
   -- generic
   --    type T is private;
   -- function toArray (a : T.Container.Vector) return T.Container.Vector
   --    is (configLookup.toArray (a));
   --
   -- private
   function configHash (This : ATNConfigSet;
                        stateNumber : ATNStates.State;
                        context : Optional_PredictionContext)
                        return Ada.Containers.Hash_Type;

   -- public
   function getConflictingAltSubsets (This : ATNConfigSet) return BitSet_Map;

   -- public
   function getStateToAltMap (This : ATNConfigSet) return BitSet_Map;

   --for DFAState
   -- public
   function getAltSet (This : ATNConfigSet) return Set_of_Optional_Integers;

   --for DiagnosticErrorListener
   -- public
   function getAltBitSet (This : ATNConfigSet) return BitSet;
      result : constant := BitSet ();

   -- LexerATNSimulator
   -- public
   -- firstConfigWithRuleStopState : Optional_ATNConfig;
   function firstConfigWithRuleStopState return Optional_ATNConfig;

   --ParserATNSimulator
   -- public
   function getUniqueAlt (This : ATNConfigSet) return Integer;

   -- public
   function removeAllConfigsNotInRuleStopState (This : ATNConfigSet;
                                                mergeCache : in out PredictionContext.Optional_DoubleKeyMap;
                                                lookToEndOfRule : Boolean;
                                                atn : ATN)
                                                return ATNConfigSet;

   -- public
   function applyPrecedenceFilter (mergeCache : in out PredictionContext.Optional_DoubleKeyMap,parser : Parser;_outerContext : ParserRuleContext!) return ATNConfigSet;

   -- internal
   function getPredsForAmbigAlts (ambigAlts : BitSet; nalts : Integer) return Optional_SemanticContext_Container.Vector is -- ]?

   -- public
   function getAltThatFinishedDecisionEntryRule (This : ATNConfigSet) return Integer;

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

   -- public
   procedure splitAccordingToSemanticValidity (This : ATNConfigSet;
                                               outerContext : ParserRuleContext;
                                               evalSemanticContext : evalSemanticContext_Access) --TOFIX
                                               return (ATNConfigSet, ATNConfigSet) is --TOFIX

   -- public
   function dupConfigsWithoutSemanticPredicates (This : ATNConfigSet) return ATNConfigSet;

   -- public
   function hasConfigInRuleStopState (This : ATNConfigSet) return Boolean;

   -- public
   function allConfigsInRuleStopStates return Boolean;

   -- public
   function "=" (Lhs, Rhs : ATNConfigSet) return Boolean;

end ANTLR.Runtime.ATN.ATNConfigSet;
