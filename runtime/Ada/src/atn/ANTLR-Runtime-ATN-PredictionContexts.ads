-- €

with Ada.Containers;
with Ada.Containers.Hashed_Maps;
with Ada.Containers.Vectors;
with Ada.Strings;
with ANTLR.Runtime.ATN.PredictionContexts.ArrayPredictionContexts;
with ANTLR.Runtime.ATN.States;
with ANTLR.Runtime.Misc.DoubleKeyMap;
with ANTLR.Runtime.RuleContexts;
with ANTLR.Runtime.RuleContexts.ParserRuleContexts;
with ANTLR.Runtime.Recognizers;
with Interfaces;
with Option;

use Ada;
use ANTLR.Runtime.ATN.PredictionContexts.ArrayPredictionContexts;
use ANTLR.Runtime.ATN.States;
use ANTLR.Runtime.Misc.DoubleKeyMap;
use ANTLR.Runtime.RuleContexts;
use ANTLR.Runtime.RuleContexts.ParserRuleContexts;
use ANTLR.Runtime.Recognizers;
use Option;

package ANTLR.Runtime.ATN.PredictionContexts is

   use ANTLR.Runtime;
   use ANTLR.Runtime.ATN;

   type Context_ID is new Natural;
   type Hash_Code  is new Interfaces.Unsigned_32;

   -- public static
   protected globalNodeCount  is
      procedure New_ID;
      function Last_ID return Context_ID;
   private
      ID : Context_ID := 0; -- ID starts at # 1 in Ada code !!
   end globalNodeCount;

   -- ----------------- --
   -- PredictionContext --
   -- ----------------- --
   -- public
   type PredictionContext is new Ada.Finalization.Controlled -- and Hashable
   with record
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
      -- private Hash_Code This.referenceHashCode {
      -- Hash_Code hash := _org.antlr.v4.runtime.misc.MurmurHash#initialize MurmurHash.initialize_ (_#INITIAL_HASH_);
      --
      -- for (int i := 0; i < _#size_; i++) loop
      -- hash := _org.antlr.v4.runtime.misc.MurmurHash#update MurmurHash.update_ (hash, _#getParent getParent_ (i));
      -- }
      --
      -- for (int i := 0; i < _#size_; i++) loop
      -- hash := _org.antlr.v4.runtime.misc.MurmurHash#update MurmurHash.update_ (hash, _#getReturnState getReturnState_ (i));
      -- }
      --
      -- hash := _org.antlr.v4.runtime.misc.MurmurHash#finish MurmurHash.finish_ (hash, 2 * _#size_);
      -- return hash;
      -- }
      --
      --
      -- public
      cachedHashCode : Hash_code; -- constant
   end record;

   function "=" (Left, Right : PredictionContext) return Boolean;

   -- public
   procedure hash (This : PredictionContext; hasher: in out Hasher);

   -- -------------------------------------- --
   -- PredictionContext_List --
   -- -------------------------------------- --
   package PredictionContext_Container is new Ada.Containers.Vectors (
      Index_Type => Natural,
      Element_Type => PredictionContext,
      "=" => "=");
   subtype PredictionContext_List is PredictionContext_Container.Vector;

   -- -------------------------- --
   -- Optional_PredictionContext --
   -- -------------------------- --
   package Option_PredictionContext is new Option (PredictionContext);
   subtype Optional_PredictionContext is Option_PredictionContext.Optional; -- renames

   -- -------------------------------------- --
   -- Optional_PredictionContext_List --
   -- -------------------------------------- --
   package Optional_PredictionContext_Container is new Ada.Containers.Vectors (
      Index_Type => Natural,
      Element_Type => Optional_PredictionContext,
      "=" => "=");
   subtype Optional_PredictionContext_List is Optional_PredictionContext_Container.Vector;

   -- ------------------------------------------------ --
   -- PredictionContext_Dictionary (PredictionContext) --
   -- ------------------------------------------------ --
   function Hash (Key : PredictionContext) return Ada.Containers.Hash_Type;
   function Equivalent_Keys (Left, Right : PredictionContext) return Boolean;
   package PredictionContext_2_Dictorary is new Ada.Containers.Hashed_Maps (
      Key_Type => PredictionContext,
      Element_Type => PredictionContext,
      Hash => Hash,
      Equivalent_Keys => Equivalent_Keys,
      "=" => "=");
   subtype PredictionContext_2_Map is PredictionContext_2_Dictorary.Map;

   -- -------------------------------------- --
   -- PredictionContext_Dictionary (Integer) --
   -- -------------------------------------- --
   function Hash (Key : Integer) return Ada.Containers.Hash_Type;
   function Equivalent_Keys (Left, Right : Integer) return Boolean;
   package Map is new Ada.Containers.Hashed_Maps (
      Key_Type => Integer,
      Element_Type => PredictionContext,
      Hash => Hash,
      Equivalent_Keys => Equivalent_Keys,
      "=" => "=");

   package DoubleKey_PredictionContext_Dictionary is new DoubleKeyMap (
      Key1 => Hash,
      Key2 => Hash,
      Value => PredictionContext,
      Optional_Value => Optional_PredictionContext);
   subtype PredictionContext_DoubleKeyMap is DoubleKey_PredictionContext_Dictionary.DoubleKeyMap;


   procedure Initialize (Self : PredictionContext; cachedHashCode : Hash_code);

   --
   -- Convert a _org.antlr.v4.runtime.RuleContext_ tree to a _org.antlr.v4.runtime.atn.PredictionContext_ graph.
   -- Return _#EMPTY_ if `outerContext` is empty or null.
   --
   -- public static
   function fromRuleContext (atn : ATN; outerContext : Optional_RuleContext) return PredictionContext;

   -- public
   function size (This : PredictionContext) return Integer with No_Return;

   -- public
   function getParent (This : PredictionContext; index : Integer) return Optional_PredictionContext with No_Return;

   -- public
   function getReturnState (This : PredictionContext; index : Integer) return State with No_Return;

   -- public
   function hasEmptyPath (This : PredictionContext) return Boolean
      is (getReturnState (Last_ID) = EMPTY_RETURN_STATE)

   -- static
   function calculateEmptyHashCode (This : PredictionContext) return Hash_Code;
      hash : constant Hash_Code := MurmurHash.initialize (INITIAL_HASH);

   -- static
   function calculateHashCode (parent : Optional_PredictionContext; returnState : State) return Hash_Code;

   -- static
   function calculateHashCode (parents : Optional_PredictionContext_List, returnStates : Integer_List) return Hash_Code;

   -- dispatch
   -- public static
   function merge (a : PredictionContext;
                   b : PredictionContext;
                   rootIsWildcard : Boolean;
                   mergeCache : in out PredictionContext_DoubleKeyMap) -- PredictionContext.Optional_DoubleKeyMap)
                   return PredictionContext;

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
                         mergeCache : in out PredictionContext_DoubleKeyMap) -- PredictionContext.Optional_DoubleKeyMap)
                         return PredictionContext;

   -- public static
   function toDOTString (context : Optional_PredictionContext) return UString;

   -- From Sam
   -- public static
   function getCachedContext (context : PredictionContext;
                              contextCache : PredictionContextCache;
                              visited : in out PredictionContext_2_Map)
                              return PredictionContext;

   -- ter's recursive version of Sam's This.getAllNodes;
   -- public static
   function getAllContextNodes (context : PredictionContext) return PredictionContext_List;

   -- private static
   procedure getAllContextNodes_2 (context : Optional_PredictionContext;
                                  nodes : in out PredictionContext_List,
                                  visited : in out PredictionContext_2_Map);

   subtype Sink is Ada.Strings.Text_Buffers.Root_Buffer_Type;
   procedure Put_Image_SingletonPredictionContext (S : in out Sink'Class; X : SingletonPredictionContext);
   for SingletonPredictionContext'Put_Image use Put_Image_SingletonPredictionContext;
   -- public
   function Description (This : PredictionContext) return UString
      is (PredictionContext'External_Tag) & '@' & UString (Unmanaged.passUnretained (self).toOpaque.hashValue);

   -- --------- --
   -- DoubleKey --
   -- --------- --

   type DoubleKey is record
      A, B : PredictionContext;
   end record;

   -- ------------ --
   -- Recognizer_T --
   -- ------------ --
   package Recognizers_T is new Recognizers (T);
   subtype Recognizer_T is Recognizers_T.Recognizer;

   package Option_Recognizer_T is new Option (Recognizer_T);
   subtype Optional_Recognizer_T is Option_Recognizer_T.Optional;

   -- ------------ --
   -- Recognizer_T --
   -- ------------ --
   package Recognizers_T is new Recognizers (T);
   subtype Recognizer_T is Recognizers_T.Recognizer;

   -- public
   generic
      type T is ;--TOFIX
   function toString (recog : Recognizer_T) return UString;

   -- public
   generic
      type T is ;--TOFIX
   function toStrings (recognizer : Recognizer_T; currentState : State) return UString_List;

   -- FROM SAM
   -- public
   generic
      type T is ;--TOFIX
   function toStrings (recognizer : Optional_Recognizer_T; stop : PredictionContext; currentState : State) return UString_List;

   -- ------------- --
   -- mergeCacheMap --
   -- ------------- --
   package mergeCacheMap is new DoubleKeyMap (
      Key1 => PredictionContext,
      Key2 => PredictionContext,
      Value => PredictionContext,
      Optional_Value => Optional_PredictionContext);

   -- ----------------- --
   --    RuleContext --
   -- ParserRuleContext --
   -- ----------------- --
   -- public
   function "=" (lhs: RuleContext; rhs: ParserRuleContext) return Boolean;

end ANTLR.Runtime.ATN.PredictionContexts;