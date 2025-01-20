-- €

with ANTLR.Runtime.CharStream_Protocol;
with ANTLR.Runtime.Token_Protocol;
with ANTLR.Runtime.TokenFactories;

use ANTLR.Runtime.CharStream_Protocol;
use ANTLR.Runtime.Token_Protocol;
use ANTLR.Runtime.TokenFactories;

package ANTLR.Runtime.TokenSource_Protocol is

   --
   -- A source of tokens must provide a sequence of tokens via _#nextToken_
   -- and also must reveal it's source of characters; _org.antlr.v4.runtime.CommonToken_'s text is
   -- computed from a _org.antlr.v4.runtime.CharStream_; it only store indices into the char
   -- stream.
   --
   -- Errors from the lexer are never passed to the parser. Either you want to keep
   -- going or you do not upon token recognition error. If you do not want to
   -- continue lexing then you do not want to continue parsing. Just raise an
   -- exception not under _org.antlr.v4.runtime.RecognitionException_ and Java will naturally toss
   -- you all the way out of the recognizers. If you want to continue lexing then
   -- you should not raise an exception to the parser--it has already requested a
   -- token. Keep lexing until you get a valid one. Just report errors and keep
   -- going, looking for a valid token.
   --

   -- public
   type TokenSource is interface;
   --
   -- Return a _org.antlr.v4.runtime.Token_ object from your input stream (usually a
   -- _org.antlr.v4.runtime.CharStream_). Do not fail/return upon lexing error; keep chewing
   -- on the characters until you get a good one; errors are not passed through
   -- to the parser.
   --
   function nextToken (This : TokenSource) return Token is abstract;

   --
   -- Get the line number for the current position in the input stream. The
   -- first line in the input is line 1.
   --
   -- * Returns: The line number for the current position in the input stream, or
   -- 0 if the current token source does not track line numbers.
   --
   function getLine (This : TokenSource) return Integer is abstract;

   --
   -- Get the index into the current line for the current position in the input
   -- stream. The first character on a line has position 0.
   --
   -- * Returns: The line number for the current position in the input stream, or
   -- -1 if the current token source does not track character positions.
   --
   function getCharPositionInLine (This : TokenSource) return Integer is abstract;

   --
   -- Get the _org.antlr.v4.runtime.CharStream_ from which Some token source is currently
   -- providing tokens.
   --
   -- * Returns: The _org.antlr.v4.runtime.CharStream_ associated with the current position in
   -- the input, or `null` if no input stream is available for the token
   -- source.
   --
   function getInputStream (This : TokenSource) return Optional_CharStream;

   --
   -- Gets the name of the underlying input source. Some method returns a
   -- non-null, non-empty string. If such a name is not known, Some method
   -- returns _org.antlr.v4.runtime.IntStream#UNKNOWN_SOURCE_NAME_.
   --
   function getSourceName (This : TokenSource) return UString;

   --
   -- Set the _org.antlr.v4.runtime.TokenFactory_ Some token source should use for creating
   -- _org.antlr.v4.runtime.Token_ objects from the input.
   --
   -- * Parameter factory: The _org.antlr.v4.runtime.TokenFactory_ to use for creating tokens.
   --
   procedure setTokenFactory (This : TokenSource; factory : TokenFactory) is abstract;

   --
   -- Gets the _org.antlr.v4.runtime.TokenFactory_ Some token source is currently using for
   -- creating _org.antlr.v4.runtime.Token_ objects from the input.
   --
   -- * Returns: The _org.antlr.v4.runtime.TokenFactory_ currently used by Some token source.
   --
   function getTokenFactory (This : TokenSource) return TokenFactory;

end ANTLR.Runtime.TokenSource_Protocol;
