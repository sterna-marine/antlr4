-- €

with Ada.Strings;
with ANTLR.Runtime.ATN.PredictionContext.ArrayPredictionContext;

use ANTLR.Runtime.ATN.PredictionContext;
use ANTLR.Runtime.ATN.PredictionContext.ArrayPredictionContext;

package ANTLR.Runtime.ATN.PredictionContext.SingletonPredictionContext is

   -- -------------------------- --
   -- SingletonPredictionContext --
   -- -------------------------- --
   -- public
   type SingletonPredictionContext is new PredictionContext with
   record
      -- public final
      parent : Optional_PredictionContext; -- constant
      -- public final
      returnState : Integer; -- constant
   end record;

   -- public
   function "=" (Lhs, Rhs : SingletonPredictionContext) return Boolean;

   procedure Initialize (Self : SingletonPredictionContext;
                   parent : Optional_PredictionContext;
                   returnState : ATStates.State);

   -- public static
   function create (parent : Optional_PredictionContext;
                    returnState : ATStates.State)
                    return SingletonPredictionContext;

   overriding
   -- public
   function size (This : SingletonPredictionContext) return Integer
      is (1);

   overriding
   -- public
   function getParent (This : SingletonPredictionContext;
                       index : Integer)
                       return Optional_PredictionContext;

   overriding
   -- public
   function getReturnState (This : SingletonPredictionContext;
                            index : Integer)
                            return Integer;

   subtype Sink is Ada.Strings.Text_Buffers.Root_Buffer_Type;
   procedure Put_Image_SingletonPredictionContext (S : in out Sink'Class; X : SingletonPredictionContext);
   for SingletonPredictionContext'Put_Image use Put_Image_SingletonPredictionContext;
   -- public
   overriding
   function Description (This : SingletonPredictionContext) return UString;

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
   -- * parameter a: the first _org.antlr.v4.runtime.atn.SingletonPredictionContext_
   -- * parameter b: the second _org.antlr.v4.runtime.atn.SingletonPredictionContext_
   -- * parameter rootIsWildcard: `True` if this is a local-context merge,
   -- otherwise False to indicate a full-context merge
   -- * parameter mergeCache:
   --
   -- public static
   function mergeSingletons (a : SingletonPredictionContext;
                             b : SingletonPredictionContext;
                             rootIsWildcard : Boolean;
                             mergeCache : in out PredictionContext.Optional_DoubleKeyMap)
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
   -- * parameter a: the first _org.antlr.v4.runtime.atn.SingletonPredictionContext_
   -- * parameter b: the second _org.antlr.v4.runtime.atn.SingletonPredictionContext_
   -- * parameter rootIsWildcard: `True` if this is a local-context merge,
   -- otherwise False to indicate a full-context merge
   --
   -- public static
   function mergeRoot (a : SingletonPredictionContext;
                       b : SingletonPredictionContext;
                       rootIsWildcard : Boolean)
                       return Optional_PredictionContext;

   -- ---------------------- --
   -- ArrayPredictionContext --
   -- ---------------------- --
   -- public
   function "=" (lhs: ArrayPredictionContext; rhs: SingletonPredictionContext) return Boolean
      is (False);

   -- public
   function "=" (lhs: SingletonPredictionContext; rhs: ArrayPredictionContext) return Boolean
      is (False);

end ANTLR.Runtime.ATN.PredictionContext.SingletonPredictionContext;
