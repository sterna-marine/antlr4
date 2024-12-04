-- €

with ANTLR.Runtime.ATN.ATNStates;
with Interfaces;

use ANTLR.Runtime.ATN;

package ANTLR.Runtime.ATN.PredictionContext is 

   type Context_ID is new Natural;
   type Hash_Code  is new Interfaces.Unsigned_32;

   -- public static 
   protected globalNodeCount  is
      procedure New_ID;
      function Last_ID return Context_ID;
   private
      ID : Context_ID := 0; -- ID starts at # 1 in Ada code !!
   end globalNodeCount;

   -- public
   type PredictionContext is new Hashable and CustomStringConvertible with
   record
      --
      -- Represents `$` in an array in full context mode, when `$`
      -- doesn't mean wildcard: `$ + x := [$,x]`. Here,
      -- `$` := _#EMPTY_RETURN_STATE_.
      --


      -- public final
      id : Context_ID := 0; -- constant

      --
      -- Stores the computed hash code of this _org.antlr.v4.runtime.atn.PredictionContext_. The hash
      -- code is computed in parts to match the following reference algorithm.
      --
      --
      -- private Hash_Code referenceHashCode () {
      -- Hash_Code hash := _org.antlr.v4.runtime.misc.MurmurHash#initialize MurmurHash.initialize_ (_#INITIAL_HASH_);
      --
      -- for (int i := 0; i &lt; _#size ()_; i++) loop
      -- hash := _org.antlr.v4.runtime.misc.MurmurHash#update MurmurHash.update_ (hash, _#getParent getParent_ (i));
      -- }
      --
      -- for (int i := 0; i &lt; _#size ()_; i++) loop
      -- hash := _org.antlr.v4.runtime.misc.MurmurHash#update MurmurHash.update_ (hash, _#getReturnState getReturnState_ (i));
      -- }
      --
      -- hash := _org.antlr.v4.runtime.misc.MurmurHash#finish MurmurHash.finish_ (hash, 2 * _#size ()_);
      -- return hash;
      -- }
      --
      --
      -- public
      cachedHashCode : Hash_code; -- constant
   end record;

   procedure Init (Self : PredictionContext; cachedHashCode : Hash_code);

   --
   -- Convert a _org.antlr.v4.runtime.RuleContext_ tree to a _org.antlr.v4.runtime.atn.PredictionContext_ graph.
   -- Return _#EMPTY_ if `outerContext` is empty or null.
   --
   -- public static
   function fromRuleContext (atn : ATN; outerContext : Optional_RuleContext) return PredictionContext;

   -- public
   function size (This : PredictionContext) return Integer;

   -- public
   function getParent (This : PredictionContext; index : Integer) return Optional_PredictionContext;

   -- public
   function getReturnState (This : PredictionContext; index : Integer) return ATNStates.State;

   --
   -- This means only the _#EMPTY_ context is in set.
   --
   -- public
   function isEmpty (This : PredictionContext) return Boolean
      is This === EmptyPredictionContext.Instance;

   -- public
   function hasEmptyPath (This : PredictionContext) return Boolean
      is (getReturnState (Last_ID) == PredictionContext.EMPTY_RETURN_STATE)

   -- public
   procedure hash (This : PredictionContext; hasher: in out Hasher);

   -- static
   function calculateEmptyHashCode (This : PredictionContext) return Hash_Code;
      hash : constant Hash_Code := MurmurHash.initialize (INITIAL_HASH);

   -- static
   function calculateHashCode (parent : Optional_PredictionContext; returnState : ATStates.State) return Hash_Code;

   -- static
   function calculateHashCode (parents : [PredictionContext?], returnStates : [Int]) return Hash_Code;

   -- dispatch
   -- public static 
   function merge (a : PredictionContext;
                   b : PredictionContext;
                   rootIsWildcard : Boolean;
                   mergeCache : in out DoubleKeyMap<PredictionContext, PredictionContext, PredictionContext>?)
                   return PredictionContext;

   --
   -- Merge two _org.antlr.v4.runtime.atn.SingletonPredictionContext_ instances.
   --
   -- Stack tops equal, parents merge is same; return left graph.
   --
   --
   -- Same stack top, parents differ; merge parents giving array node, then
   -- remainders of those graphs. A new root node is created to point to the
   -- merged parents.
   --
   --
   -- Different stack tops pointing to same parent. Make array node for the
   -- root where both element in the root point to the same (original);
   -- parent.
   --
   --
   -- Different stack tops pointing to different parents. Make array node for
   -- the root where each element points to the corresponding original
   -- parent.
   --
   --
   -- - parameter a: the first _org.antlr.v4.runtime.atn.SingletonPredictionContext_
   -- - parameter b: the second _org.antlr.v4.runtime.atn.SingletonPredictionContext_
   -- - parameter rootIsWildcard: `True` if this is a local-context merge,
   -- otherwise False to indicate a full-context merge
   -- - parameter mergeCache:
   --
   -- public static 
   function mergeSingletons (a : SingletonPredictionContext;
                             b : SingletonPredictionContext;
                             rootIsWildcard : Boolean;
                             mergeCache : inxout DoubleKeyMap<PredictionContext, PredictionContext, PredictionContext>?)
                             return PredictionContext;

   --
   -- Handle case where at least one of `a` or `b`;
   -- _#EMPTY_. In the following diagrams, the symbol `$` is used
   -- to represent _#EMPTY_.
   --
   -- Local-Context Merges
   --
   -- These local-context merge operations are used when `rootIsWildcard`
   -- is True.
   --
   -- _#EMPTY_ is superset of any graph; return _#EMPTY_.
   --
   --
   -- _#EMPTY_ and anything is `#EMPTY`, so merged parent;
   -- `#EMPTY`; return left graph.
   --
   --
   -- Special case of last merge if local context.
   --
   --
   -- Full-Context Merges
   --
   -- These full-context merge operations are used when `rootIsWildcard`
   -- is False.
   --
   --
   --
   -- Must keep all contexts; _#EMPTY_ in array is a special value (and
   -- null parent).
   --
   --
   --
   --
   -- - parameter a: the first _org.antlr.v4.runtime.atn.SingletonPredictionContext_
   -- - parameter b: the second _org.antlr.v4.runtime.atn.SingletonPredictionContext_
   -- - parameter rootIsWildcard: `True` if this is a local-context merge,
   -- otherwise False to indicate a full-context merge
   --
   -- public static 
   function mergeRoot (a : SingletonPredictionContext;
                       b : SingletonPredictionContext;
                       rootIsWildcard : Boolean)
                       return Optional_PredictionContext;

   --
   -- Merge two _org.antlr.v4.runtime.atn.ArrayPredictionContext_ instances.
   --
   -- Different tops, different parents.
   --
   --
   -- Shared top, same parents.
   --
   --
   -- Shared top, different parents.
   --
   --
   -- Shared top, all shared parents.
   --
   --
   -- Equal tops, merge parents and reduce top to
   -- _org.antlr.v4.runtime.atn.SingletonPredictionContext_.
   --
   --
   -- public static 
   function mergeArrays (a : ArrayPredictionContext;
                         b : ArrayPredictionContext;
                         rootIsWildcard : Boolean;
                         mergeCache : in out DoubleKeyMap<PredictionContext, PredictionContext, PredictionContext>?)
                         return PredictionContext;

   -- public static
   function toDOTString (context : Optional_PredictionContext) return String;
   begin

   -- From Sam
   -- public static 
   function getCachedContext (context : PredictionContext;
                              contextCache : PredictionContextCache;
                              visited : in out [PredictionContext: PredictionContext])
                              return PredictionContext;

   -- ter's recursive version of Sam's getAllNodes ();
   -- public static
   function getAllContextNodes (context : PredictionContext) return [PredictionContext];
      nodes := [PredictionContext]();
      visited := [PredictionContext: PredictionContext]();

   -- private static
   procedure getAllContextNodes_ (context : Optional_PredictionContext;
                                  nodes : in out [PredictionContext],
                                  visited : in out [PredictionContext: PredictionContext]);

   -- public
   generic
      type T is ;--TOFIX
   function toString<T> (recog : Recognizer<T>) return String;

   -- public
   generic
      type T is ;--TOFIX
   function toStrings<T> (recognizer : Recognizer<T>, currentState : ATStates.State) return [String];

   -- FROM SAM
   -- public
   generic
      type T is ;--TOFIX
   function toStrings<T> (recognizer : Recognizer<T>?, stop : PredictionContext; currentState : ATStates.State) return [String];

   -- public
   function Image return UString
      is (describing: PredictionContext.self) + "@" + String (Unmanaged.passUnretained (self).toOpaque ().hashValue);

   -- public
   function "=" (lhs: RuleContext; rhs: ParserRuleContext) return Boolean;

   -- public
   function "=" (lhs: PredictionContext; rhs: PredictionContext) return Boolean;

   -- public
   function "=" (lhs: ArrayPredictionContext; rhs: SingletonPredictionContext) return Boolean
      is (False);

   -- public
   function "=" (lhs: SingletonPredictionContext; rhs: ArrayPredictionContext) return Boolean
      is (False);

   -- public
   function "=" (lhs: SingletonPredictionContext; rhs: EmptyPredictionContext) return Boolean
      is (False);

   -- public
   function "=" (lhs: EmptyPredictionContext; rhs: ArrayPredictionContext) return Boolean
      is (lhs === rhs);

   -- public
   function "=" (lhs: EmptyPredictionContext; rhs: SingletonPredictionContext) return Boolean
      is (lhs === rhs);

end ANTLR.Runtime.ATN.PredictionContext;