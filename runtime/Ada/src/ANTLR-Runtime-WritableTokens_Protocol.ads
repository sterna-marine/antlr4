-- €

package ANTLR.Runtime.WritableTokens_Protocol is

   -- public
   type WritableToken is interface and Token;

   procedure setText (text : UString) is abstract;

   procedure setType (tType : Token_Kind) is abstract;

   procedure setLine (line : Integer) is abstract;

   procedure setCharPositionInLine (pos : Integer) is abstract;

   procedure setChannel (Channel : Channel_Number) is abstract;

   procedure setTokenIndex (index : Integer) is abstract;
end ANTLR.Runtime.WritableTokens_Protocol;
