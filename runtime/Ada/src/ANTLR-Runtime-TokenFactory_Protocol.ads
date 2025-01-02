-- €

with Ada.Finalization;
with ANTLR.Runtime.Misc.Extensions.TokenExtension;

use ANTLR.Runtime.Misc.Extensions.TokenExtension;

package ANTLR.Runtime.TokenFactory_Protocol is

   -- -------------------- --
   -- TokenSourceAndStream --
   -- -------------------- --
   --
   --   Holds the references to the TokenSource and CharStream used to create a Token.
   --   These are together to reduce memory footprint by having one instance of
   --   TokenSourceAndStream shared across many tokens.  The references here are weak
   --   to avoid retain cycles.
   --
   -- public
   type TokenSourceAndStream is new Ada.Finalization.Controlled record
      --
      -- An empty TokenSourceAndStream which is used as the default value of
      -- _#source_ for tokens that do not have a source.
      --

      -- public weak
      tokenSource : Optional_TokenSource;
      -- public weak
      stream : Optional_CharStream;
   end record;

   -- public static
   EMPTY : constant TokenSourceAndStream := (tokenSource => (Valid => False), stream => (Valid => False));

   -- public
   procedure Initialize (Self : in out TokenSourceAndStream;
                         tokenSource : Optional_TokenSource := (Valid => False);
                         stream : Optional_CharStream := (Valid => False));

   -- ------------ --
   -- TokenFactory --
   -- ------------ --
   -- The default mechanism for creating tokens. It's used by default in Lexer and
   -- the error handling strategy (to create missing tokens).  Notifying the parser
   -- of a new factory means that it notifies it's token source and error strategy.
   --
   -- public
   type TokenFactory is interface;

   --typealias Symbol
   -- This is the method used to create tokens in the lexer and in the
   -- error handling strategy. If Is_Valid (text), than the start and stop positions
   -- are wiped to -1 in the text override is set in the CommonToken.
   --
   function create (This         : TokenFactory;
                    source       : TokenSourceAndStream;
                    Token_Kind   : Token_Kind;
                    text         : Optional_String;
                    Channel      : Channel_Number;
                    start, stop  : Integer;
                    line         : Integer;
                    charPositionInLine : Integer)
                    return Token is abstract;

   -- Generically useful
   function create (This       : TokenFactory;
                    Token_Kind : Token_Kind;
                    text       : UString)
                  return Token is abstract;



end ANTLR.Runtime.TokenFactory_Protocol;
