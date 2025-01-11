-- €

with ANTLR.Runtime.Misc.Extensions.TokenExtensions;

use ANTLR.Runtime.BufferedTokenStreams;
use ANTLR.Runtime.Misc.Extensions.TokenExtensions;

package ANTLR.Runtime.BufferedTokenStreams.CommonTokenStreams is

   --
   -- This class extends _org.antlr.v4.runtime.BufferedTokenStream_ with functionality to filter
   -- token streams to tokens on a particular channel (tokens where
   -- _org.antlr.v4.runtime.Token#getChannel_ returns a particular value).
   --
   --
   -- This token stream provides access to all tokens by index or when calling
   -- methods like _#getText_. The channel filtering is only used for code
   -- accessing tokens via the lookahead methods _#LA_, _#LT_, and
   -- _#LB_.
   --
   --
   -- By default, tokens are placed on the default channel
   -- (_org.antlr.v4.runtime.Token#DEFAULT_CHANNEL_), but may be reassigned by using the
   -- `->channel (HIDDEN)` lexer command, or by using an embedded action to
   -- call _org.antlr.v4.runtime.Lexer#setChannel_.
   --
   --
   --
   -- Note: lexer rules which use the `->skip` lexer command or call
   -- _org.antlr.v4.runtime.Lexer#skip_ do not produce tokens at all, so input text matched by
   -- such a rule will not be available as part of the token stream, regardless of
   -- channel.
   --

   -- public
   type CommonTokenStream is new BufferedTokenStream with
   record
      --
      -- Specifies the channel to use for filtering tokens.
      --
      --
      -- The default value is _org.antlr.v4.runtime.Token#DEFAULT_CHANNEL_, which matches the
      -- default channel assigned to tokens created by the lexer.
      --
      -- internal
      channel : Channel_Number := DEFAULT_CHANNEL;
   end record;

   --
   -- Constructs a new _org.antlr.v4.runtime.CommonTokenStream_ using the specified token
   -- source and the default token channel (_org.antlr.v4.runtime.Token#DEFAULT_CHANNEL_).
   --
   -- * parameter tokenSource: The token source.
   --
   -- public
   overriding
   procedure Initialize (Self : in out CommonTokenStream; tokenSource : TokenSource);

   --
   -- Constructs a new _org.antlr.v4.runtime.CommonTokenStream_ using the specified token
   -- source and filtering tokens to the specified channel. Only tokens whose
   -- _org.antlr.v4.runtime.Token#getChannel_ matches `channel` or have the
   -- _org.antlr.v4.runtime.Token#getType_ equal to _org.antlr.v4.runtime.Token#EOF_ will be returned by the
   -- token stream lookahead methods.
   --
   -- * parameter tokenSource: The token source.
   -- * parameter channel: The channel to use for filtering tokens.
   --
   -- public convenience
   procedure Initialize (Self : in out CommonTokenStream;
                         tokenSource : TokenSource;
                         Channel : Channel_Number);

   -- internal
   overriding
   function adjustSeekIndex (This : CommonTokenStream;
                             i : Integer)
                             return Integer
      is (This.nextTokenOnChannel (i, This.channel));

   -- internal
   overriding
   function LB (This : CommonTokenStream;
                k : Integer)
                return Optional_Token;

   -- public
   overriding
   function LT (This : CommonTokenStream;
                k : Integer)
                return Optional_Token;

   --
   -- Count EOF just once.
   --
   -- public
   function getNumberOfOnChannelTokens (This : CommonTokenStream) return Natural;

end ANTLR.Runtime.BufferedTokenStreams.CommonTokenStreams;
