-- €

with Ada.Finalization;
with ANTLR.Runtime.ATN.ATNStates;
with Ada.Containers.Hashed_Maps;
with Ada.Containers.Hashed_Sets;
with AdaForge.MurMur3_Hash;
with Ada.Strings.Unbounded;

use ANTLR.Runtime.ATN.ATNStates;

package ANTLR.Runtime.ATN.Configs is
   --
   -- A tuple: (ATN state, predicted alt, syntactic, semantic context).
   -- The syntactic context is a graph-structured stack node whose
   -- path (s) to the root is the rule invocation (s);
   -- chain used to arrive at the state.  The semantic context;
   -- the tree of semantic predicates encountered before reaching
   -- an ATN state.
   --

   -- private static let
   SUPPRESS_PRECEDENCE_FILTER : constant Integer := 16#4000_0000#;
   -- This field stores the bit mask for implementing the
   -- _#isPrecedenceFilterSuppressed_ property as a bit within the
   -- existing _#reachesIntoOuterContext_ field.

   -- public
   type ATNConfig is new Ada.Finalization.Controlled -- and Hashable
   record
      -- public final let
      state : ATNState;
      -- The ATN state associated with this configuration

      -- public final let
      alt : Integer;
      -- What alt (or lexer rule) is predicted by this configuration

      -- public internal (set) final
      context : Optional_PredictionContext;
      -- The stack of invoking states leading to the rule/states associated
      -- with this config.  We track only those contexts pushed during
      -- execution of the ATN simulator.
      --
      -- We cannot execute predicates dependent upon local context unless
      -- we know for sure we are in the correct context. Because there;
      -- no way to do this efficiently, we simply cannot evaluate
      -- dependent predicates unless we are in the rule that initially
      -- invokes the ATN simulator.
      --
      --
      -- closure () tracks the depth of how far we dip into the outer context:
      -- depth > 0.  Note that it may not be totally accurate depth since I
      -- don't ever decrement. TODO: make it a boolean then
      --
      --
      -- For memory efficiency, the _#isPrecedenceFilterSuppressed_ method
      -- is also backed by this field. Since the field is publicly accessible, the
      -- highest bit which would not cause the value to become negative is used to
      -- store this field. This choice minimizes the risk that code which only
      -- compares this value to 0 would be affected by the new purpose of the
      -- flag. It also ensures the performance of the existing _org.antlr.v4.runtime.atn.ATNConfig_
      -- constructors as well as certain operations like
      -- _org.antlr.v4.runtime.atn.ATNConfigSet#add (org.antlr.v4.runtime.atn.ATNConfig, DoubleKeyMap)_ method are
      -- __completely__ unaffected by the change.
      --
      -- public internal (set) final var
      reachesIntoOuterContext : Integer := 0;

      -- public final let
      semanticContext : SemanticContext;
   end record;

   subtype Object is ATNConfig;
   type Class is access all Object;
   type Class_Wide is access all Object'Class;

   subtype hash_Type is Ada.Containers.Hash_Type; --TOFIX
   subtype Key_Type is Integer; --TOFIX
   function MurMur3_Hash (Key : Key_Type) return Hash_Type;
   function Equivalent_Keys (Left, Right : Key_Type) return Boolean
      is Left = Right; --TOFIX
   function "=" (Left, Right : Element_Type) return Boolean
      is Left = Right; --TOFIX
   package ATNConfig_Container is new Ada.Containers.Hashed_Maps (
      Key_Type => Key_Type,
      Element_Type =>
      Hash => MurMur3_Hash,
      Equivalent_Keys => Equivalent_Keys,
      "=" => "=");

   function Hash (Key : ATNConfig) return Ada.Container.Hash_Type;
   function Equivalent_Elements (Left, Right : ATNConfig) return Boolean
      is Hash (Left) = Hash (Right); --TOFIX
   function "=" (Left, Right : ATNConfig) return Boolean
      is Left = Right; --TOFIX
   package ATNConfig_Sets is new Ada.Containers.Hashed_Sets (
      Element_Type => ATNConfig
      Hash => Hash,
      Equivalent_Elements => Equivalent_Elements,
      "=" => "=");
   subtype Set_of_ATNConfigs is ATNConfig_Sets.Set;
   

   -- public
   procedure Initialize (Self : in out ATNConfig;
                   state : ATNState;
                   alt : Integer;
                   context : Optional_PredictionContext;
                   semanticContext : SemanticContext := SemanticContext.Empty.Instance);

-- public convenience
   procedure Initialize (Self : in out ATNConfig;
                   c : ATNConfig;
                   state : ATNState);

-- public convenience
   procedure Initialize (Self : in out ATNConfig;
                   c : ATNConfig;
                   state : ATNState;
                   semanticContext : SemanticContext);

-- public convenience
   procedure Initialize (Self : in out ATNConfig;
                   c : ATNConfig;
                   semanticContext : SemanticContext);

-- public convenience
   procedure Initialize (Self : in out ATNConfig;
                   c : ATNConfig;
                   state : ATNState;
                   context : Optional_PredictionContext);

-- public
   procedure Initialize (Self : in out ATNConfig;
                   c : ATNConfig;
                   state : ATNState;
                   context : Optional_PredictionContext;
                   semanticContext : SemanticContext);

    --
    -- This method gets the value of the _#reachesIntoOuterContext_ field
    -- as it existed prior to the introduction of the
    -- _#isPrecedenceFilterSuppressed_ method.
    --
   -- public final
   function getOuterContextDepth (This : ATNConfig) return Integer
      is (This.reachesIntoOuterContext and not SUPPRESS_PRECEDENCE_FILTER);

   -- public final
   function isPrecedenceFilterSuppressed (This : ATNConfig) return Boolean
      is ((This.reachesIntoOuterContext and SUPPRESS_PRECEDENCE_FILTER) /= 0);

   -- public final
   procedure setPrecedenceFilterSuppressed (This : in out ATNConfig; value : Boolean);

   -- public
   procedure hash (This : ATNConfig;
                   The_hasher : in out Hasher);

-- public
   subtype Sink is Ada.Strings.Text_Buffers.Root_Buffer_Type;
   procedure Put_Image_ATNConfig (S : in out Sink'Class; X : ATNConfig);
   for ATNConfig'Put_Image use Put_Image_ATNConfig;
   function Description (This : ATNConfig) return UString
      is toString (null, True);

-- public
   generic
      T :
   function toString (This : ATNConfig; recog : Recognizer<T>?; showAlt : Boolean) return UString;

   --
   -- An ATN configuration is equal to another if both have
   -- the same state, they predict the same alternative, and
   -- syntactic/semantic contexts are the same.
   --
   -- public
   function "=" (Lhs, Rhs : ATNConfig) return Boolean;

end ANTLR.Runtime.ATN.Configs;
