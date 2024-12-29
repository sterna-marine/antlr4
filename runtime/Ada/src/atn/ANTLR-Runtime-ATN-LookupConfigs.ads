-- €

with Ada.Finalization;
with ANTLR.Runtime.ATN.Configs;

use ANTLR.Runtime.ATN.Configs;

package ANTLR.Runtime.ATN.LookupConfigs is

   -- public
   type LookupATNConfig is new Ada.Finalization.Controlled -- and Hashable
   record
      -- public
      config : ATNConfig; -- constant
   end record;

   subtype Object is LookupATNConfig;
   type Class is access all Object;
   type Class_Wide is access all Object'Class;

   -- public
   procedure Initialize (Self : in out LookupATNConfig; old : ATNConfig);

   -- public
   procedure hash (This : LookupATNConfig; hasher : in out Hasher);

   -- public
   function "=" (Lhs, Rhs : LookupATNConfig) return Boolean;

end ANTLR.Runtime.ATN.LookupConfigs;
