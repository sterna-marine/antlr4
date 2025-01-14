-- €

with AdaForge.Crypto.MuRMuR_Hash3;

package body ANTLR.Runtime.ATN.Configs is

   function MurMur3_Hash (Key : Key_Type) return Hash_Type is
   begin
      return 0; --TOFIX
   end MurMur3_Hash;

   function Hash (Key : ATNConfig) return Ada.Container.Hash_Type;
      package ATNConfig_Crypto is new AdaForge.Crypto.MuRMuR_Hash3 (ATNConfig);
   begin
      return ATNConfig_Crypto.Hash_32 (Key);
   end Hash;

   procedure Initialize (Self : in out ATNConfig;
                   state : ATNState;
                   alt : Integer;
                   context : Optional_PredictionContext;
                   semanticContext : SemanticContext := SemanticContext.Empty.Instance) is
   begin
      self.state := state;
      self.alt := alt;
      self.context := context;
      self.semanticContext := semanticContext;
    end Initialize;

   procedure Initialize (Self : in out ATNConfig;
                   c : ATNConfig;
                   state : ATNState) is
   begin
      Self.Initialize (state, c.alt, c.context, c.semanticContext);
   end Initialize;

   procedure Initialize (Self : in out ATNConfig;
                   c : ATNConfig;
                   state : ATNState;
                   semanticContext : SemanticContext) is
   begin
      Self.Initialize (state, c.alt, c.context, semanticContext);
   end Initialize;

   procedure Initialize (Self : in out ATNConfig;
                   c : ATNConfig;
                   semanticContext : SemanticContext) is
      Self.Initialize (c.state, c.alt, c.context, semanticContext);
   end Initialize;

   procedure Initialize (Self : in out ATNConfig;
                   c : ATNConfig;
                   state : ATNState;
                   context : Optional_PredictionContext) is
   begin
      Self.Initialize (state, c.alt, context, c.semanticContext);
   end Initialize;

   procedure Initialize (Self : in out ATNConfig;
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
   end Initialize;

   procedure setPrecedenceFilterSuppressed (This : in out ATNConfig; value : Boolean) is
   begin
      if value then
         This.reachesIntoOuterContext := @ or SUPPRESS_PRECEDENCE_FILTER;
      else
         This.reachesIntoOuterContext := @ and not SUPPRESS_PRECEDENCE_FILTER;
      end if;
   end setPrecedenceFilterSuppressed;

   procedure hash (This : ATNConfig;
                   The_hasher : in out Hasher) is
   begin
      The_hasher.combine (This.state.stateNumber);
      The_hasher.combine (This.alt);
      The_hasher.combine (This.context);
      The_hasher.combine (This.semanticContext);
    end hash;

   function toString (This : ATNConfig; recog : Recognizer_T?; showAlt : Boolean) return UString is
      buf : UString;
      outerDepth : constant Integer := getOuterContextDepth (This);
   begin
      UString.Append (buf, '(' & This.State'Image);
      if showAlt then
         UString.Append (buf, ',' & This.alt'Image);
      end if;
      if context : constant := context then
         UString.Append (buf, ",[" & This.context'Image & ']');
      end if;
      if semanticContext /= SemanticContext.Empty.Instance then
         UString.Append (buf, ',' & This.semanticContext'Image);
      end if;
      if outerDepth > 0 then
         UString.Append (buf, ",up=" & outerDepth'Image);
      end if;
         UString.Append (buf, ')');
      return UString.To_String (buf);
   end toString;

   function "=" (Lhs, Rhs : ATNConfig) return Boolean is
   begin
      --  if lhs === rhs then
      --    return True;
      --  end if;

      l : constant Optional_LexerATNConfig := Maybe (lhs);
      r : constant Optional_LexerATNConfig := Maybe (rhs);
      if Is_Valid (l) and then Is_Valid (r) then
         return l = r;
      elsif lhs.state.stateNumber /= rhs.state.stateNumber then
         return False;
      elsif lhs.alt /= rhs.alt then
         return False;
      elsif lhs.isPrecedenceFilterSuppressed /= rhs.isPrecedenceFilterSuppressed then
         return False;
      elsif lhs.context /= rhs.context then
         return False;
      else
         return lhs.semanticContext = rhs.semanticContext;
      end if;
   end "=";

end ANTLR.Runtime.ATN.Configs;
