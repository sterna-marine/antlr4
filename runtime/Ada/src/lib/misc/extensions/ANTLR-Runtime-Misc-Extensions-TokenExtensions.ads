-- €

with ANTLR.Runtime.Token_Protocol;

package ANTLR.Runtime.Misc.Extensions.TokenExtensions is

   -- ------ --
   -- TOKENS --
   -- ------ --

   -- static public
   INVALID_TYPE : constant Integer := 0;

   --
   -- During lookahead operations, this "token" signifies we hit rule end ATN state
   -- and did not follow it despite needing to.
   --
   -- static public
   EPSILON : constant Integer := -2;

   -- static public
   MIN_USER_TOKEN_TYPE : constant Integer := 1;

   -- -------- --
   -- CHANNELS --
   -- -------- --
   --
   -- All tokens go to the parser (unless This.skip is called in that rule);
   -- on a particular "channel".  The parser tunes to a particular channel
   -- so that whitespace etc ..  can go to the parser on a "hidden" channel.
   --
   type Channel_Number is Integer range -1 .. Integer'Last;

   NON_DEFAULT_CHANNEL : constant Channel_Number := -1;

   -- static public
   DEFAULT_CHANNEL : constant Channel_Number := 0;

   --
   -- Anything on different channel than DEFAULT_CHANNEL is not parsed
   -- by parser.
   --
   HIDDEN_Channel : Channel_Number := 1;

   --
   -- This is the minimum constant value which can be assigned to a
   -- user-defined token channel.
   --
   --
   -- The non-negative numbers less than _#MIN_USER_CHANNEL_VALUE_ are
   -- assigned to the predefined channels _#DEFAULT_CHANNEL_ and
   -- _#HIDDEN_CHANNEL_.
   --
   -- * seealso: org.antlr.v4.runtime.Token#getChannel;
   --
   -- static public
   MIN_USER_CHANNEL_VALUE : Channel_Number := 2;

   subtype User_Channel_Number is Channel_Number range MIN_USER_CHANNEL_VALUE .. Integer'Last;

end ANTLR.Runtime.Misc.Extensions.TokenExtensions;
