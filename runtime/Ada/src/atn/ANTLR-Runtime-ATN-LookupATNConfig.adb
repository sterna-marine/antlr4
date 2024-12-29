-- €

package body ANTLR.Runtime.ATN.LookupATNConfig is

   procedure Initialize (Self : in out LookupATNConfig; old : ATNConfig) is
   begin
      -- dup
      Self.config := old;
   end Initialize;

   procedure hash (This : LookupATNConfig; hasher : in out Hasher) is
   begin
      hasher.combine (This.config.state.stateNumber);
      hasher.combine (This.config.alt);
      hasher.combine (This.config.semanticContext);
   end hash;

   function "=" (Lhs, Rhs : LookupATNConfig) return Boolean is
   begin
      --  if lhs.config === rhs.config then
      --     return True;
      --  end if;
      return lhs.config.state.stateNumber = rhs.config.state.stateNumber
               and then lhs.config.alt = rhs.config.alt
               and then lhs.config.semanticContext = rhs.config.semanticContext
   end "=";

end ANTLR.Runtime.ATN.LookupATNConfig;
