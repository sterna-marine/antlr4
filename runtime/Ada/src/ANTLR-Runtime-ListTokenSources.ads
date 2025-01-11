-- €

with ANTLR.Runtime.CommonTokenFactories;
with ANTLR.Runtime.TokenSource_Protocol;
with Ada.Finalization;

use ANTLR.Runtime.CommonTokenFactories;
use ANTLR.Runtime.TokenSource_Protocol;

package ANTLR.Runtime.ListTokenSources is

   --
   -- Provides an implementation of _org.antlr.v4.runtime.TokenSource_ as a wrapper around a list
   -- of _org.antlr.v4.runtime.Token_ objects.
   --
   -- If the final token in the list is an _org.antlr.v4.runtime.Token#EOF_ token, it will be used
   -- as the EOF token for every call to _#nextToken_ after the end of the
   -- list is reached. Otherwise, an EOF token will be created.
   --

   type ListTokenSource_Base is Ada.Finalization.Controller with null record;

   -- public
   type ListTokenSource is new ListTokenSource_Base and TokenSource with
   record
      --
      -- The wrapped collection of _org.antlr.v4.runtime.Token_ objects to return.
      --
      -- internal
      tokens : Token_List; -- constant

      --
      -- The name of the input source. If this value is `null`, a call to
      -- _#getSourceName_ should return the source name used to create the
      -- the next token in _#tokens_ (or the previous token if the end of
      -- the input has been reached).
      --
      -- private
      sourceName : Optional_UString; -- constant

      --
      -- The index into _#tokens_ of token to return by the next call to
      -- _#nextToken_. The end of the input is indicated by this value
      -- being greater than or equal to the number of items in _#tokens_.
      --
      -- internal
      i : Integer := 0;

      --
      -- This field caches the EOF token for the token source.
      --
      -- internal
      eofToken : Optional_Token;

      --
      -- This is the backing field for _#getTokenFactory_ and
      -- _setTokenFactory_.
      --
      -- private
      factory := DEFAULT;
   end record;

   --
   -- Constructs a new _org.antlr.v4.runtime.ListTokenSource_ instance from the specified
   -- collection of _org.antlr.v4.runtime.Token_ objects.
   --
   -- * parameter tokens: The collection of _org.antlr.v4.runtime.Token_ objects to provide as a
   -- _org.antlr.v4.runtime.TokenSource_.
   --
   -- public convenience
   procedure Initialize (Self : in out ListTokenSource; tokens : Token_List);

   --
   -- Constructs a new _org.antlr.v4.runtime.ListTokenSource_ instance from the specified
   -- collection of _org.antlr.v4.runtime.Token_ objects and source name.
   --
   -- * parameter tokens: The collection of _org.antlr.v4.runtime.Token_ objects to provide as a
   -- _org.antlr.v4.runtime.TokenSource_.
   -- * parameter sourceName: The name of the _org.antlr.v4.runtime.TokenSource_. If this value is
   -- `null`, _#getSourceName_ will attempt to infer the name from
   -- the next _org.antlr.v4.runtime.Token_ (or the previous token if the end of the input has
   -- been reached).
   --
   -- public
   procedure Initialize (Self : in out ListTokenSource;
                        tokens : Token_List;
                        sourceName : Optional_UString);

   -- public
   function getCharPositionInLine (This : ListTokenSource) return Integer;

   -- public
   function nextToken (This : ListTokenSource) return Token;

   -- public
   function getLine (This : ListTokenSource) return Integer;

   -- public
   function getInputStream (This : ListTokenSource) return Optional_CharStream;

   -- public
   function getSourceName (This : ListTokenSource) return UString;

   -- public
   procedure setTokenFactory (This : ListTokenSource; factory : TokenFactory);

   -- public
   function getTokenFactory (This : ListTokenSource) return TokenFactory
      is (This.factory);

end ANTLR.Runtime.ListTokenSources;
