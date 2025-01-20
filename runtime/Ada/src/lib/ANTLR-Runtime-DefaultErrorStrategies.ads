-- €

with Ada.Finalization;
with ANTLR.Runtime.ATN.States;
with ANTLR.Runtime.ErrorStrategy;
with ANTLR.Runtime.Misc.IntervalSets;
with ANTLR.Runtime.Parsers;
with ANTLR.Runtime.RuleContexts.ParserRuleContexts;
with ANTLR.Runtime.Token_Protocol;

use Ada;
use ANTLR.Runtime.ATN.States;
use ANTLR.Runtime.ErrorStrategy;
use ANTLR.Runtime.Misc.IntervalSets;
use ANTLR.Runtime.Parsers;
use ANTLR.Runtime.RuleContexts.ParserRuleContexts;
use ANTLR.Runtime.Token_Protocol;

package ANTLR.Runtime.DefaultErrorStrategies is

   --
   -- This is the default implementation of _org.antlr.v4.runtime.ANTLRErrorStrategy_ used for
   -- error reporting and recovery in ANTLR parsers.
   --

   -- open
   type DefaultErrorStrategy_Base is new Ada.Finalization.Controlled with null record;

   type ANTLRErrorStrategy is new DefaultErrorStrategy_Base with
   record
      --
      -- Indicates whether the error strategy is currently "recovering from an
      -- error". This is used to suppress reporting multiple error messages while
      -- attempting to recover from a detected syntax error.
      --
      -- * seealso: #inErrorRecoveryMode
      --
      -- open
      errorRecoveryMode : Boolean := False;

      --
      -- The index into the input stream where the last error occurred.
      -- This is used to prevent infinite loops where an error is found
      -- but no token is consumed during recovery .. another error is found,
      -- ad nauseum.  This is a failsafe mechanism to guarantee that at least
      -- one token/tree node is consumed for two errors.
      --
      -- open
      lastErrorIndex : Integer := -1;

      -- open
      lastErrorStates : Optional_IntervalSet;

      --
      -- This field is used to propagate information about the lookahead following
      -- the previous match. Since prediction prefers completing the current rule
      -- to error recovery efforts, error reporting may occur later than the
      -- original point where it was discoverable. The original context is used to
      -- compute the True expected sets as though the reporting occurred as early
      -- as possible.
      --
      -- open
      nextTokensContext : Optional_ParserRuleContext;

      -- open
      nextTokensState : State := INVALID_STATE_NUMBER;
   end record;

   -- public
   overriding
   procedure Initialize (Self : in out ANTLRErrorStrategy) is null;

   --
   -- The default implementation simply calls _#endErrorCondition_ to
   -- ensure that the handler is not in error recovery mode.
   --
   -- open
   procedure reset (This : ANTLRErrorStrategy; recognizer : Parser);

   --
   -- This method is called to enter error recovery mode when a recognition
   -- exception is reported.
   --
   -- * parameter recognizer: the parser instance
   --
   -- open
   procedure beginErrorCondition (This : ANTLRErrorStrategy; recognizer : Parser);

   -- open
   function inErrorRecoveryMode (This : ANTLRErrorStrategy; recognizer : Parser) return Boolean
      is (This.errorRecoveryMode);
   
   --
   -- This method is called to leave error recovery mode after recovering from
   -- a recognition exception.
   --
   -- * parameter recognizer:
   --
   -- open
   procedure endErrorCondition (This : ANTLRErrorStrategy; recognizer : Parser);

   --
   -- The default implementation simply calls _#endErrorCondition_.
   --
   -- open
   procedure reportMatch (This : ANTLRErrorStrategy; recognizer : Parser);

   --
   --
   -- The default implementation returns immediately if the handler is already
   -- in error recovery mode. Otherwise, it calls _#beginErrorCondition_
   -- and dispatches the reporting task based on the runtime type of `e`
   -- according to the following table.
   --
   -- * _org.antlr.v4.runtime.NoViableAltException_: Dispatches the call to
   -- _#reportNoViableAlternative_
   -- * _org.antlr.v4.runtime.InputMismatchException_: Dispatches the call to
   -- _#reportInputMismatch_
   -- * _org.antlr.v4.runtime.FailedPredicateException_: Dispatches the call to
   -- _#reportFailedPredicate_
   -- * All other types: calls _org.antlr.v4.runtime.Parser#notifyErrorListeners_ to report
   -- the exception
   --
   -- open
   procedure reportError (This : ANTLRErrorStrategy; recognizer : Parser; e : RecognitionException);

   --
   -- The default implementation resynchronizes the parser by consuming tokens
   -- until we find one in the resynchronization set--loosely the set of tokens
   -- that can follow the current rule.
   --
   -- open
   procedure recover (This : ANTLRErrorStrategy; recognizer : Parser; e : RecognitionException);

   --
   -- The default implementation of _org.antlr.v4.runtime.ANTLRErrorStrategy#sync_ makes sure
   -- that the current lookahead symbol is consistent with what were expecting
   -- at this point in the ATN. You can call this anytime but ANTLR only
   -- generates code to check before subrules/loops and each iteration.
   --
   -- Implements Jim Idle's magic sync mechanism in closures and optional
   -- subrules. E.g.,
   --
   --
   -- a : sync ( stuff sync )* ;
   -- sync : {consume to what can follow syncend}
   --
   --
   -- At the start of a sub rule upon error, _#sync_ performs single
   -- token deletion, if possible. If it can't do that, it bails on the current
   -- rule and uses the default error recovery, which consumes until the
   -- resynchronization set of the current rule.
   --
   -- If the sub rule is optional (`( .. )?`, `( .. )*`, or block
   -- with an empty alternative), then the expected set includes what follows
   -- the subrule.
   --
   -- During loop iteration, it consumes until it sees a token that can start a
   -- sub rule or what follows loop. Yes, that is pretty aggressive. We opt to
   -- stay in the loop as long as possible.
   --
   -- __ORIGINS__
   --
   -- Previous versions of ANTLR did a poor job of their recovery within loops.
   -- A single mismatch token or missing token would force the parser to bail
   -- out of the entire rules surrounding the loop. So, for rule
   --
   --
   -- classDef : 'class' ID '{' member* '}'
   --
   --
   -- input with an extra token between members would force the parser to
   -- consume until it found the next class definition rather than the next
   -- member definition of the current class.
   --
   -- This functionality cost a little bit of effort because the parser has to
   -- compare token set at the start of the loop and at each iteration. If for
   -- some reason speed is suffering for you, you can turn off this
   -- functionality by simply overriding this method as a blank { }.
   --

   -- open
   procedure sync (This : ANTLRErrorStrategy; recognizer : Parser);

   --
   -- This is called by _#reportError_ when the exception is a
   -- _org.antlr.v4.runtime.NoViableAltException_.
   --
   -- * seealso: #reportError
   --
   -- * parameter recognizer: the parser instance
   -- * parameter e: the recognition exception
   --
   -- open
   procedure reportNoViableAlternative (This : ANTLRErrorStrategy; recognizer : Parser; e : NoViableAltException);

   --
   -- This is called by _#reportError_ when the exception is an
   -- _org.antlr.v4.runtime.InputMismatchException_.
   --
   -- * seealso: #reportError
   --
   -- * parameter recognizer: the parser instance
   -- * parameter e: the recognition exception
   --
   -- open
   procedure reportInputMismatch (This : ANTLRErrorStrategy; recognizer : Parser; e : InputMismatchException);

   --
   -- This is called by _#reportError_ when the exception is a
   -- _org.antlr.v4.runtime.FailedPredicateException_.
   --
   -- * seealso: #reportError
   --
   -- * parameter recognizer: the parser instance
   -- * parameter e: the recognition exception
   --
   -- open
   procedure reportFailedPredicate (This : ANTLRErrorStrategy; recognizer : Parser; e : FailedPredicateException);

   --
   -- This method is called to report a syntax error which requires the removal
   -- of a token from the input stream. At the time this method is called, the
   -- erroneous symbol is current `LT (1)` symbol and has not yet been
   -- removed from the input stream. When this method returns,
   -- `recognizer` is in error recovery mode.
   --
   -- This method is called when _#singleTokenDeletion_ identifies
   -- single-token deletion as a viable recovery strategy for a mismatched
   -- input error.
   --
   -- The default implementation simply returns if the handler is already in
   -- error recovery mode. Otherwise, it calls _#beginErrorCondition_ to
   -- enter error recovery mode, followed by calling
   -- _org.antlr.v4.runtime.Parser#notifyErrorListeners_.
   --
   -- * parameter recognizer: the parser instance
   --
   -- open

   procedure reportUnwantedToken (This : ANTLRErrorStrategy; recognizer : Parser);

   --
   -- This method is called to report a syntax error which requires the
   -- insertion of a missing token into the input stream. At the time this
   -- method is called, the missing token has not yet been inserted. When this
   -- method returns, `recognizer` is in error recovery mode.
   --
   -- This method is called when _#singleTokenInsertion_ identifies
   -- single-token insertion as a viable recovery strategy for a mismatched
   -- input error.
   --
   -- The default implementation simply returns if the handler is already in
   -- error recovery mode. Otherwise, it calls _#beginErrorCondition_ to
   -- enter error recovery mode, followed by calling
   -- _org.antlr.v4.runtime.Parser#notifyErrorListeners_.
   --
   -- * parameter recognizer: the parser instance
   --
   -- open
   procedure reportMissingToken (This : ANTLRErrorStrategy; recognizer : Parser);

   --
   --
   --
   -- The default implementation attempts to recover from the mismatched input
   -- by using single token insertion and deletion as described below. If the
   -- recovery attempt fails, this method an
   -- _org.antlr.v4.runtime.InputMismatchException_.
   --
   -- __EXTRA TOKEN__ (single token deletion);
   --
   -- `LA (1)` is not what we are looking for. If `LA (2)` has the
   -- right token, however, then assume `LA (1)` is some extra spurious
   -- token and delete it. Then consume and return the next token (which was
   -- the `LA (2)` token) as the successful result of the match operation.
   --
   -- This recovery strategy is implemented by _#singleTokenDeletion_.
   --
   -- __MISSING TOKEN__ (single token insertion);
   --
   -- If current token (at `LA (1)`) is consistent with what could come
   -- after the expected `LA (1)` token, then assume the token is missing
   -- and use the parser's _org.antlr.v4.runtime.TokenFactory_ to create it on the fly. The
   -- "insertion" is performed by returning the created token as the successful
   -- result of the match operation.
   --
   -- This recovery strategy is implemented by _#singleTokenInsertion_.
   --
   -- __EXAMPLE__
   --
   -- For example, Input `i=(3;` is clearly missing the `')'`. When
   -- the parser returns from the nested call to `expr`, it will have
   -- call chain:
   --
   --
   -- stat > expr > atom
   --
   --
   -- and it will be trying to match the `')'` at this point in the
   -- derivation:
   --
   --
   -- => ID '=' '(' Integer ')' ('+' atom)* ';'
   -- ^
   --
   --
   -- The attempt to match `')'` will fail when it sees `';'` and
   -- call _#recoverInline_. To recover, it sees that `LA (1)==';'`
   -- is in the set of tokens that can follow the `')'` token reference
   -- in rule `atom`. It can assume that you forgot the `')'`.
   --

   -- open
   function recoverInline (This : ANTLRErrorStrategy; recognizer : Parser) return Token;

   --
   -- This method implements the single-token insertion inline error recovery
   -- strategy. It is called by _#recoverInline_ if the single-token
   -- deletion strategy fails to recover from the mismatched input. If this
   -- method returns `True`, `recognizer` will be in error recovery
   -- mode.
   --
   -- This method determines whether or not single-token insertion is viable by
   -- checking if the `LA (1)` input symbol could be successfully matched
   -- if it were instead the `LA (2)` symbol. If this method returns
   -- `True`, the caller is responsible for creating and inserting a
   -- token with the correct type to produce this behavior.
   --
   -- * parameter recognizer: the parser instance
   -- * returns: `True` if single-token insertion is a viable recovery
   -- strategy for the current mismatched input, otherwise `False`
   --
   -- open
   function singleTokenInsertion (This : ANTLRErrorStrategy; recognizer : Parser) return Boolean;

   --
   -- This method implements the single-token deletion inline error recovery
   -- strategy. It is called by _#recoverInline_ to attempt to recover
   -- from mismatched input. If this method returns null, the parser and error
   -- handler state will not have changed. If this method returns non-null,
   -- `recognizer` will __not__ be in error recovery mode since the
   -- returned token was a successful match.
   --
   -- If the single-token deletion is successful, this method calls
   -- _#reportUnwantedToken_ to report the error, followed by
   -- _org.antlr.v4.runtime.Parser#consume_ to actually "delete" the extraneous token. Then,
   -- before returning _#reportMatch_ is called to signal a successful
   -- match.
   --
   -- * parameter recognizer: the parser instance
   -- * returns: the successfully matched _org.antlr.v4.runtime.Token_ instance if single-token
   -- deletion successfully recovers from the mismatched input, otherwise
   -- `null`
   --
   -- open
   function singleTokenDeletion (This : ANTLRErrorStrategy; recognizer : Parser) return Optional_Token;

   --
   -- Conjure up a missing token during error recovery.
   --
   -- The recognizer attempts to recover from single missing
   -- symbols. But, actions might refer to that missing symbol.
   -- for example, x=ID {f ($x);}. The action clearly assumes
   -- that there has been an identifier matched previously and that
   -- $x points at that token. If that token is missing, but
   -- the next token in the stream is what we want we assume that
   -- this token is missing and we keep going. Because we
   -- have to return some token to replace the missing token,
   -- we have to conjure one up. This method gives the user control
   -- over the tokens returned for missing tokens. Mostly,
   -- you will want to create something special for identifier
   -- tokens. For literals such as '{' and ',', the default
   -- action in the parser or tree parser works. It simply creates
   -- a CommonToken of the appropriate type. The text will be the token.
   -- If you change what tokens must be created by the lexer,
   -- override this method to create the appropriate tokens.
   --
   -- open
   function getTokenStream (This : ANTLRErrorStrategy; recognizer : Parser) return TokenStream;

   -- open
   function getMissingSymbol (This : ANTLRErrorStrategy; recognizer : Parser) return Token;

   -- open
   function getExpectedTokens (This : ANTLRErrorStrategy; recognizer : Parser) return IntervalSet
      is (recognizer.getExpectedTokensUnbufferedTokenStream);

   --
   -- How should a token be displayed in an error message? The default
   -- is to display just the text, but during development you might
   -- want to have a lot of information spit out.  Override in that case
   -- to use t.toStringUnbufferedTokenStream (which, for CommonToken, dumps everything about
   -- the token). This is better than forcing you to override a method in
   -- your token objects because you don't have to go modify your lexer
   -- so that it creates a new Java type.
   --
   -- open
   function getTokenErrorDisplay (This : ANTLRErrorStrategy; t : Optional_Token) return UString;

   -- open
   function getSymbolText (symbol : Token) return Optional_UString
      is (symbol.getTextUnbufferedTokenStream);

   -- open
   function getSymbolType (symbol : Token) return Integer
      is (symbol.getType);

   -- open
   function escapeWSAndQuote (s : UString) return UString;

   --
   -- Compute the error recovery set for the current rule.  During
   -- rule invocation, the parser pushes the set of tokens that can
   -- follow that rule reference on the stack; this amounts to
   -- computing FIRST of what follows the rule reference in the
   -- enclosing rule. See LinearApproximator.FIRSTUnbufferedTokenStream.
   -- This local follow set only includes tokens
   -- from within the rule; i.e., the FIRST computation done by
   -- ANTLR stops at the end of a rule.
   --
   -- EXAMPLE
   --
   -- When you find a "no viable alt exception", the input is not
   -- consistent with any of the alternatives for rule r.  The best
   -- thing to do is to consume tokens until you see something that
   -- can legally follow a call to r *or* any rule that called r.
   -- You don't want the exact set of viable next tokens because the
   -- input might just be missing a token--you might consume the
   -- rest of the input looking for one of the missing tokens.
   --
   -- Consider grammar:
   --
   -- a : '[' b ']'
   -- | '(' b ')'
   -- ;
   -- b : c '^' Integer ;
   -- c : ID
   -- | INT
   -- ;
   --
   -- At each rule invocation, the set of tokens that could follow
   -- that rule is pushed on a stack.  Here are the various
   -- context-sensitive follow sets:
   --
   -- FOLLOW (b1_in_a) := FIRST (']') := ']'
   -- FOLLOW (b2_in_a) := FIRST (')') := ')'
   -- FOLLOW (c_in_b) := FIRST ('^') := '^'
   --
   -- Upon erroneous input "[]", the call chain;
   --
   -- a -> b -> c
   --
   -- and, hence, the follow context stack is:
   --
   -- depth     follow set       start of rule execution
   -- 0         <EOF>                    a (from This.main);
   -- 1          ']'                     b
   -- 2          '^'                     c
   --
   -- Notice that ')' is not included, because b would have to have
   -- been called from a different context in rule a for ')' to be
   -- included.
   --
   -- For error recovery, we cannot consider FOLLOW (c);
   -- (context-sensitive or otherwise).  We need the combined set of
   -- all context-sensitive FOLLOW sets--the set of all tokens that
   -- could follow any reference in the call chain.  We need to
   -- resync to one of those tokens.  Note that FOLLOW (c)='^' and if
   -- we resync'd to that token, we'd consume until EOF.  We need to
   -- sync to context-sensitive FOLLOWs for a, b, and c: {']','^'}.
   -- In this case, for input "[]", LA (1) is ']' and in the set, so we would
   -- not consume anything. After printing an error, rule c would
   -- return normally.  Rule b would not find the required '^' though.
   -- At this point, it gets a mismatched token error and an
   -- exception (since LA (1) is not in the viable following token
   -- set).  The rule exception handler tries to recover, but finds
   -- the same recovery set and doesn't consume anything.  Rule b
   -- exits normally returning to rule a.  Now it finds the ']' (and
   -- with the successful match exits errorRecovery mode).
   --
   -- So, you can see that the parser walks up the call chain looking
   -- for the token that was a member of the recovery set.
   --
   -- Errors are not generated in errorRecovery mode.
   --
   -- ANTLR's error recovery mechanism is based upon original ideas:
   --
   -- "Algorithms + Data Structures := Programs" by Niklaus Wirth
   --
   -- and
   --
   -- "A note on error recovery in recursive descent parsers":
   -- http:--portal.acm.org/citation.cfm?id=947902.947905
   --
   -- Later, Josef Grosch had some good ideas:
   --
   -- "Efficient and Comfortable Error Recovery in Recursive Descent
   -- Parsers":
   -- ftp:--www.cocolab.com/products/cocktail/doca4.ps/ell.ps.zip
   --
   -- Like Grosch I implement context-sensitive FOLLOW sets that are combined
   -- at run-time upon error to avoid overhead during parsing.
   --
   -- open
   function getErrorRecoverySet (This : ANTLRErrorStrategy; recognizer : Parser) return IntervalSet;

   --
   -- Consume tokens until one matches the given token set.
   --
   -- open
   procedure consumeUntil (This : ANTLRErrorStrategy; recognizer : Parser; set : IntervalSet);

end ANTLR.Runtime.DefaultErrorStrategies;
