-- €

with Ada.Finalization;
with ANTLR.Runtime.ATN.ATNConfig;

use ANTLR.Runtime.ATN.ATNConfig;

package ANTLR.Runtime.ATN.LookupATNConfig is

   -- public
   type LookupATNConfig is new Ada.Finalization.Controlled -- and Hashable
   record
      -- public
      config : ATNConfig; -- constant
   end record;

   -- public
   procedure Initialize (Self : in out LookupATNConfig; old : ATNConfig);

   -- public
   procedure hash (This : LookupATNConfig; hasher : in out Hasher);

   -- public
   function "=" (Lhs, Rhs : LookupATNConfig) return Boolean;

end ANTLR.Runtime.ATN.LookupATNConfig;
