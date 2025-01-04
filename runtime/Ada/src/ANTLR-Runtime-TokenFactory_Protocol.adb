-- €

with Ada.Finalization;
with ANTLR.Runtime.Misc.Extensions.TokenExtension;

use ANTLR.Runtime.Misc.Extensions.TokenExtension;

package body ANTLR.Runtime.TokenFactory_Protocol is

   -- -------------------- --
   -- TokenSourceAndStream --
   -- -------------------- --

   procedure Initialize (Self : in out TokenSourceAndStream;
                         tokenSource : Optional_TokenSource;
                         stream : Optional_CharStream := (Valid => False)) is
   begin
      self.tokenSource := tokenSource;
      self.stream := stream;
   end Initialize;

end ANTLR.Runtime.TokenFactory_Protocol;
