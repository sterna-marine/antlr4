-- €

with ATNState;
with Ada.Containers.Hashed_Maps;
with AdaForge.MurMur3_Hash;
with Ada.Strings.Unbounded;

package body ANTLR.Runtime.ATN.ATNConfig is
-- --------------------------------------------
-- A tuple: (ATN state, predicted alt, syntactic, semantic context).
-- The syntactic context is a graph-structured stack node whose
-- path (s) to the root is the rule invocation (s);
-- chain used to arrive at the state.  The semantic context is
-- the tree of semantic predicates encountered before reaching
-- an ATN state.
-- --------------------------------------------

-- private static let 
   SUPPRESS_PRECEDENCE_FILTER : constant Integer := 16#4000_0000#;
   -- This field stores the bit mask for implementing the
   -- _#isPrecedenceFilterSuppressed_ property as a bit within the
   -- existing _#reachesIntoOuterContext_ field.

   subtype Hash_Type is Integer; --TOFIX
   subtype Key_Type is Integer; --TOFIX

   function MurMur3_Hash (Key : Key_Type) return Hash_Type is
   begin
      return 0; --TOFIX
   end MurMur3_Hash;

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

-- public 
   type ATNConfig is new Hashable with
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
      -- --------------------------------------------
      -- We cannot execute predicates dependent upon local context unless
      -- we know for sure we are in the correct context. Because there is
      -- no way to do this efficiently, we simply cannot evaluate
      -- dependent predicates unless we are in the rule that initially
      -- invokes the ATN simulator.
      -- --------------------------------------------
      -- --------------------------------------------
      -- closure () tracks the depth of how far we dip into the outer context:
      -- depth > 0.  Note that it may not be totally accurate depth since I
      -- don't ever decrement. TODO: make it a boolean then
      -- --------------------------------------------
      -- --------------------------------------------
      -- For memory efficiency, the _#isPrecedenceFilterSuppressed_ method
      -- is also backed by this field. Since the field is publicly accessible, the
      -- highest bit which would not cause the value to become negative is used to
      -- store this field. This choice minimizes the risk that code which only
      -- compares this value to 0 would be affected by the new purpose of the
      -- flag. It also ensures the performance of the existing _org.antlr.v4.runtime.atn.ATNConfig_
      -- constructors as well as certain operations like
      -- _org.antlr.v4.runtime.atn.ATNConfigSet#add (org.antlr.v4.runtime.atn.ATNConfig, DoubleKeyMap)_ method are
      -- __completely__ unaffected by the change.
      -- --------------------------------------------
      -- public internal (set) final var
      reachesIntoOuterContext : Integer := 0;

      -- public final let 
      semanticContext : SemanticContext;
   end record;

   -- public
   procedure Init (Self : in out ATNConfig;
                   state : ATNState;
                   alt : Integer;
                   context : Optional_PredictionContext;
                   semanticContext : SemanticContext := SemanticContext.Empty.Instance) is
        self.state := state
        self.alt := alt
        self.context := context
        self.semanticContext := semanticContext
    end Init;

-- public convenience
   procedure Init (Self : in out ATNConfig;
                   c : ATNConfig;
                   state : ATNState) is
   begin
        Init (Self, state, c.alt, c.context, c.semanticContext);
   end Init;

-- public convenience
   procedure Init (Self : in out ATNConfig;
                   c : ATNConfig;
                   state : ATNState;
                   semanticContext : SemanticContext) is
   begin
        Init (Self, state, c.alt, c.context, semanticContext);
   end Init;

-- public convenience
   procedure Init (Self : in out ATNConfig;
                   c : ATNConfig;
                   semanticContext : SemanticContext) is
        Init (Self, c.state, c.alt, c.context, semanticContext);
    end Init;

-- public convenience
   procedure Init (Self : in out ATNConfig;
                   c : ATNConfig;
                   state : ATNState;
                   context : Optional_PredictionContext;) {
        Init (Self, state, c.alt, context, c.semanticContext);
    end Init;

-- public
   procedure Init (Self : in out ATNConfig;
                   c : ATNConfig;
                   state : ATNState;
                   context : Optional_PredictionContext;
                   semanticContext : SemanticContext) is
   begin
        self.state := state;
        self.alt := c.alt;
        self.context := context;
        self.semanticContext := semanticContext;
        self.reachesIntoOuterContext := c.reachesIntoOuterContext;
   end Init;

    -- --------------------------------------------
    -- This method gets the value of the _#reachesIntoOuterContext_ field
    -- as it existed prior to the introduction of the
    -- _#isPrecedenceFilterSuppressed_ method.
    -- --------------------------------------------
-- public final 
   function getOuterContextDepth (This : ATNConfig) return Integer
      is This.reachesIntoOuterContext and not SUPPRESS_PRECEDENCE_FILTER;

-- public final
   function isPrecedenceFilterSuppressed (This : ATNConfig) return Boolean
      is (This.reachesIntoOuterContext and SUPPRESS_PRECEDENCE_FILTER) /= 0;

-- public final
   procedure setPrecedenceFilterSuppressed (This : in out ATNConfig; value : Boolean) is
   begin
      if value then
         This.reachesIntoOuterContext := @ or SUPPRESS_PRECEDENCE_FILTER;
      else
         This.reachesIntoOuterContext := @ and not SUPPRESS_PRECEDENCE_FILTER;
      end if;
   end setPrecedenceFilterSuppressed;

-- public
   procedure hash (This : ATNConfig;
                   The_hasher : in out Hasher) is
   begin
        The_hasher.combine (This.state.stateNumber);
        The_hasher.combine (This.alt);
        The_hasher.combine (This.context);
        The_hasher.combine (This.semanticContext);
    end hash;

-- public
   function Image (This : ATNConfig) return String is
        return toString (null, True);
   end Image;

-- public
   generic 
      T : 
   function toString (This : ATNConfig; recog : Recognizer<T>?; showAlt : Boolean) return String is

      package VString renames Ada.Strings.Unbounded.Unbounded_String;
      buf : VString.Unbounded_String;
      outerDepth : constant Integer := getOuterContextDepth (This);

   begin
      VString.Append (buf, "(" & This.State'Image);
      if showAlt then
         VString.Append (buf, ',' & This.alt'Image);
      end if;
      if context : constant := context then
         VString.Append (buf, ",[" & This.context'Image & ']');
      end if;
      if semanticContext /= SemanticContext.Empty.Instance then
         VString.Append (buf, ',' & This.semanticContext'Image);
      end if;
      if outerDepth > 0 then
         VString.Append (buf, ",up=" & outerDepth'Image);
      end if;
         VString.Append (buf, ")");
      return VString.To_String (buf);
    end toString;

-- --------------------------------------------
-- An ATN configuration is equal to another if both have
-- the same state, they predict the same alternative, and
-- syntactic/semantic contexts are the same.
-- --------------------------------------------
-- public 
   function "=" (Lhs, Rhs : ATNConfig) return Boolean is
   begin

    if lhs === rhs then
        return True;
    end if;

    l : constant Optional_LexerATNConfig := Set (lhs);
    r : constant Optional_LexerATNConfig := Set (rhs);
    if Is_Valid (l) and Is_Valid (r) then
        return l = r
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

    if lhs.context /= rhs.context then
        return False;
    end if;

    return lhs.semanticContext = rhs.semanticContext;
   end "=";

end ANTLR.Runtime.ATN.ATNConfig;
