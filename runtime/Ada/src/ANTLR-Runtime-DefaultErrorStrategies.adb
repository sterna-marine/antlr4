-- €

with Ada.Finalization;
with Ada.Wide_Wide_Text_IO;
with AdaForge.Framework.Aspect;

use Ada;
use AdaForge.Framework;
use AdaForge.Framework.Aspect;

package body ANTLR.Runtime.DefaultErrorStrategies is

   overriding
   procedure Initialize (Self : in out ANTLRErrorStrategy) is null;

   procedure reset (This : ANTLRErrorStrategy; recognizer : Parser) is
   begin
      This.endErrorCondition (recognizer);
   end reset;

   procedure beginErrorCondition (This : ANTLRErrorStrategy; recognizer : Parser) is
   begin
      This.errorRecoveryMode := True;
   end beginErrorCondition;

   function inErrorRecoveryMode (This : ANTLRErrorStrategy; recognizer : Parser) return Boolean
      is (This.errorRecoveryMode);
   
   procedure endErrorCondition (This : ANTLRErrorStrategy; recognizer : Parser) is
   begin
      This.errorRecoveryMode := False;
      This.lastErrorStates := (Valid => False);
      This.lastErrorIndex := -1;
   end endErrorCondition;

   procedure reportMatch (This : ANTLRErrorStrategy; recognizer : Parser) is
   begin
      This.endErrorCondition (recognizer);
   end reportMatch;

   procedure reportError (This : ANTLRErrorStrategy; recognizer : Parser; e : RecognitionException) is
   begin
      -- if we've already reported an error and have not matched a token
      -- yet successfully, don't report any errors.
      if This.inErrorRecoveryMode (recognizer) then
         return; -- don't report spurious errors
      else Report :
         declare 
            nvae : constant Optional_NoViableAltException := Maybe (e);
            ime : constant InputMismatchException := InputMismatchException (e);
            fpe : constant FailedPredicateException := FailedPredicateException (e);
         begin
            beginErrorCondition (recognizer);
            if Is_Valid (nvae) then
               This.reportNoViableAlternative (recognizer, nvae);
            elsif Is_Valid (ime) then
               reportInputMismatch (recognizer, ime);
            elsif Is_Valid (fpe) then
               reportFailedPredicate (recognizer, fpe);
            else
               Wide_Wide_Text_IO.Put_Line (Standard_Error, "unknown recognition error type: " & e'External_Tag); -- UString (describing => type (of => e));
               recognizer.notifyErrorListeners (e.getOffendingToken, e.message, Default => "", e);
            end if;
         end Report;
      end if;
   end reportError;

   procedure recover (This : ANTLRErrorStrategy; recognizer : Parser; e : RecognitionException) is
   begin
      Wide_Wide_Text_IO.Put_Line ("recover in " & recognizer.getRuleInvocationStack
                                 & " index=" & getTokenStream (recognizer).index
                                 & ", lastErrorIndex=" & lastErrorIndex
                                 & ", states=" & lastErrorStates);
      if Is_Valid (lastErrorStates)
      and then lastErrorIndex = getTokenStream (recognizer).index
      and then lastErrorStates.contains (recognizer.getState) then
         -- uh oh, another error at same token index and previously-visited
         -- state in ATN; must be a case where LT (1) is in the recovery
         -- token set so nothing got consumed. Consume a single token
         -- at least to prevent an infinite loop; this is a failsafe.
         if Is_Active (Aspect.DEBUG) then
            Wide_Wide_Text_IO.Put_Line (Standard_Error, "seen error condition before index=" & lastErrorIndex
                                       & ", states=" & lastErrorStates);
            Wide_Wide_Text_IO.Put_Line (Standard_Error, "FAILSAFE consumes " & recognizer.getTokenNames.Element (getTokenStream (recognizer).LA (1)));
         end if;
         recognizer.consume;
      end if;
      lastErrorIndex := getTokenStream (recognizer).index;
      if lastErrorStates = (Valid => False) then
         lastErrorStates := This.IntervalSet;
      end if;
      Value (lastErrorStates).add (recognizer.getState);
      followSet : constant := getErrorRecoverySet (recognizer);
      consumeUntil (recognizer, followSet);
   end recover;

   procedure sync (This : ANTLRErrorStrategy; recognizer : Parser) is
      s : constant := Value (recognizer.getInterpreterUnbufferedTokenStream.atn.states.Element (recognizer.getStateUnbufferedTokenStream));
   begin
      if Is_Active (Aspect.DEBUG) then
        Wide_Wide_Text_IO.Put_Line (Standard_Error, "sync @ " & s.stateNumber & '=' & s.getClass.getSimpleName);
      end if;
      -- If already recovering, don't to sync;
      if inErrorRecoveryMode (recognizer) then
         return;
      else
         tokens : constant Token := getTokenStream (recognizer);
         la : constant := tokens.LA (1);

         -- cheaper subset first; might get lucky. seems to shave a wee bit off;
         nextToks : constant := recognizer.getATNUnbufferedTokenStream.nextTokens (s);
         if nextToks.contains (la) then
            -- We are sure the token matches
            nextTokensContext := (Valid => False);
            nextTokensState : ATStates.State := INVALID_STATE_NUMBER;
            return;
         else
            if nextToks.contains (CommonToken.EPSILON) then
               if Is_Valid (nextTokensContext) then
                  return;
               else
                  -- It's possible the next token won't match; information tracked
                  -- by sync is restricted for performance.
                  nextTokensContext := recognizer.getContextUnbufferedTokenStream;
                  nextTokensState : ATStates.State := recognizer.getStateUnbufferedTokenStream;
               end if;
            else
               case s.getStateTypeUnbufferedTokenStream is
                  when ATNState.BLOCK_START => null;
                  when ATNState.STAR_BLOCK_START => null;
                  when ATNState.PLUS_BLOCK_START => null;
                  when ATNState.STAR_LOOP_EN =>;
                     -- report error and recover if possible
                     if Is_Valid (singleTokenDeletion (recognizer)) then
                        return;
                     else
                        raise ANTLRException.recognition with InputMismatchException (recognizer);
                     end if;
                  when ATNState.PLUS_LOOP_BACK => null;
                  when ATNState.STAR_LOOP_BACK =>
                     if Is_Active (Aspect.DEBUG) then
                        Wide_Wide_Text_IO.Put_Line (Standard_Error, "at loop back: " & s.getClassUnbufferedTokenStream.getSimpleNameUnbufferedTokenStream);
                     end if;
                     reportUnwantedToken (recognizer);
                     expecting : constant := recognizer.getExpectedTokensUnbufferedTokenStream;
                     whatFollowsLoopIterationOrRule : constant IntervalSet := IntervalSet (expecting.or (getErrorRecoverySet (recognizer)));
                     consumeUntil (recognizer, whatFollowsLoopIterationOrRule);
                  when others =>
                     -- do nothing if we can't identify the exact kind of ATN state
                     null;
               end case;
            end if;
         end if;
      end if;
   end sync;

   procedure reportNoViableAlternative (This : ANTLRErrorStrategy; recognizer : Parser; e : NoViableAltException) is
      tokens : constant Token := getTokenStream (recognizer);
      input : UString;
   begin
      if e.getStartTokenUnbufferedTokenStream.getTypeUnbufferedTokenStream = EOF then
         input := "<EOF>";
      else
         declare
         begin
               input := tokens.getText (e.getStartTokenUnbufferedTokenStream, e.getOffendingTokenUnbufferedTokenStream);
         end if;
         exception
            when others =>
               input := "<unknown>";
         end if;
      end if;
      msg : constant := "no viable alternative at input " & escapeWSAndQuote (input);
      recognizer.notifyErrorListeners (e.getOffendingTokenUnbufferedTokenStream, msg, e);
   end reportNoViableAlternative;

   procedure reportInputMismatch (This : ANTLRErrorStrategy; recognizer : Parser; e : InputMismatchException) is
      tok : constant UString := getTokenErrorDisplay (e.getOffendingTokenUnbufferedTokenStream);
      expected : constant := Value (e.getExpectedTokensUnbufferedTokenStream).toString (Set (recognizer.getVocabularyUnbufferedTokenStream, Default => "<missing>");
      msg : constant := "mismatched input " & tok'Image & " expecting " & expected'Image;
   begin
      recognizer.notifyErrorListeners (e.getOffendingTokenUnbufferedTokenStream, msg, e);
   end reportInputMismatch;

   procedure reportFailedPredicate (This : ANTLRErrorStrategy; recognizer : Parser; e : FailedPredicateException) is
      ruleName : constant := recognizer.getRuleNames.Element (Value (recognizer.ctx).getRuleIndex);
      msg : constant := "rule " & ruleName'Image & ' ' & Value (e.message);
   begin
      recognizer.notifyErrorListeners (e.getOffendingTokenUnbufferedTokenStream, msg, e);
   end reportFailedPredicate;

   procedure reportUnwantedToken (This : ANTLRErrorStrategy; recognizer : Parser) is
   begin
      if inErrorRecoveryMode (recognizer) then
         return;
      else
         beginErrorCondition (recognizer);
         declare
            t : constant := recognizer.getCurrentTokenUnbufferedTokenStream; -- try?
            tokenName : constant UString := getTokenErrorDisplay (t);
            expecting : IntervalSet;
            msg : UString;
         begin
            expecting := Option_IntervalSet.Value (getExpectedTokens (recognizer), Default => EMPTY_SET); -- try ?
            msg := "extraneous input " & tokenName'Image & " expecting " & expecting.toString (recognizer.getVocabulary);
            recognizer.notifyErrorListeners (t, msg, (Valid => False));
         end;
      end if;
   end reportUnwantedToken;

   procedure reportMissingToken (This : ANTLRErrorStrategy; recognizer : Parser) is
   begin
      if inErrorRecoveryMode (recognizer) then
         return;
      else
         beginErrorCondition (recognizer);
         declare
            t : constant UString := recognizer.getCurrentTokenUnbufferedTokenStream; -- try?
            expecting : constant IntervalSet := Option_IntervalSet.Value (getExpectedTokens (recognizer), Default => IntervalSet.EMPTY_SET);
            msg : UString;
         begin
            msg := "missing " & expecting.toString (recognizer.getVocabulary)) & " at " & getTokenErrorDisplay (t);
            recognizer.notifyErrorListeners (t, msg, null);
      end if;
   end reportMissingToken;

   function recoverInline (This : ANTLRErrorStrategy; recognizer : Parser) return Token is
      -- SINGLE TOKEN DELETION
      matchedSymbol : constant Token := singleTokenDeletion (recognizer);
   begin
      if Is_Valid (matchedSymbol) then
         -- we have deleted the extra token.
         -- now, move past ttype token as if all were ok
         recognizer.consumeUnbufferedTokenStream;
         return matchedSymbol;
      end if;

      -- SINGLE TOKEN INSERTION
      if singleTokenInsertion (recognizer) then
         return getMissingSymbol (recognizer);
      else -- even that didn't work; must raise the exception
         exn : constant := InputMismatchException (recognizer, state => nextTokensState, ctx => nextTokensContext);
         raise ANTLRException.recognition with exn;
      end if;
   end recoverInline;

   function singleTokenInsertion (This : ANTLRErrorStrategy; recognizer : Parser) return Boolean is
      currentSymbolType : constant Token_Kind := getTokenStream (recognizer).LA (1);
      -- if current token is consistent with what could come after current
      -- ATN state, then we know we're missing a token; error recovery
      -- is free to conjure up and insert the missing token
      currentState : constant ATNState := Value (recognizer.getInterpreterUnbufferedTokenStream.atn.states.Element (recognizer.getStateUnbufferedTokenStream));
      next : constant ATNState := currentState.transition (0).target;
      atn : constant ATN := recognizer.getInterpreterUnbufferedTokenStream.atn;
      expectingAtLL2 : constant IntervalSet := atn.nextTokens (next, recognizer._ctx);
   begin
      if Is_Active (Aspect.DEBUG) then
         Wide_Wide_Text_IO.Put_Line ("LT (2) set=" & expectingAtLL2.toString (recognizer.getTokenNames));
      end if;
      if expectingAtLL2.contains (currentSymbolType) then
         reportMissingToken (recognizer);
         return True;
      else
         return False;
      end if;
   end singleTokenInsertion;

   function singleTokenDeletion (This : ANTLRErrorStrategy; recognizer : Parser) return Optional_Token is
      nextTokenType : constant Token_Kind := getTokenStream (recognizer).LA (2);
      expecting : constant IntervalSet := getExpectedTokens (recognizer);
   begin
      if expecting.contains (nextTokenType) then
         reportUnwantedToken (recognizer);
         if Is_Active (Aspect.DEBUG) then
            Wide_Wide_Text_IO.Put_Line (Standard_Error, "recoverFromMismatchedToken deleting "
            & ((TokenStream)getTokenStream (recognizer)).LT (1)
            & " since " & ((TokenStream)getTokenStream (recognizer)).LT (2)
            & " is what we want");
         end if;
         recognizer.consume; -- simply delete extra token
         -- we want to return the token we're actually matching
         matchedSymbol : constant := recognizer.getCurrentTokenUnbufferedTokenStream;
         reportMatch (recognizer)  -- we know current token is correct
         return matchedSymbol;
      end if;
      return (Valid => False);
   end singleTokenDeletion;

   function getTokenStream (This : ANTLRErrorStrategy; recognizer : Parser) return TokenStream is
   begin
      return TokenStream (recognizer.getInputStreamUnbufferedTokenStream); -- as! TokenStream
   end getTokenStream;

   function getMissingSymbol (This : ANTLRErrorStrategy; recognizer : Parser) return Token is
      currentSymbol : Token'Class := recognizer.getCurrentTokenUnbufferedTokenStream;
      expecting : constant IntervalSet := getExpectedTokens (recognizer);
      expectedTokenType : constant Token_Kind := expecting.getMinElementUnbufferedTokenStream; -- get any element
      tokenText : UString;
   begin
      if expectedTokenType = EOF then
         tokenText := "<missing EOF>";
      else
         tokenText := "<missing " & recognizer.getVocabularyUnbufferedTokenStream.getDisplayName (expectedTokenType) & '>';
      end if;
      current := currentSymbol;
      lookback : constant Optional_Token'Class := getTokenStream (recognizer).LT (-1);
      if current.getTypeUnbufferedTokenStream = EOF and then Is_Valid (lookback) then
         current := Value (lookback);
      end if;

      token : constant := recognizer.getTokenFactoryUnbufferedTokenStream.create (
         current.getTokenSourceAndStreamUnbufferedTokenStream,
         expectedTokenType, tokenText,
         DEFAULT_CHANNEL,
         -1, -1,
         current.getLineUnbufferedTokenStream, current.getCharPositionInLineUnbufferedTokenStream);

      return token;
   end getMissingSymbol;

   function getTokenErrorDisplay (This : ANTLRErrorStrategy; t : Optional_Token) return UString is
   begin
      if not Is_Valid (t) then
         return "<no token>";
      else
         s := getSymbolText (t);
         if s = (Valid => False) then
            if getSymbolType (t) == EOF then
                  s := "<EOF>";
            else
                  s := '<' & getSymbolType (t) & '>';
            end if;
         end if;
         return escapeWSAndQuote (Value (s);
      end if;
   end getTokenErrorDisplay;

   function escapeWSAndQuote (s : UString) return UString is
      Some_String : UString := s;
   begin
      Some_String := UString.Replace (In_to => Some_String; Replace => "\n", By =>  "\\n", All_Occurrences);
      Some_String := UString.Replace (In_to => Some_String; Replace => "\r", By =>  "\\r", All_Occurrences);
      Some_String := UString.Replace (In_to => Some_String; Replace => "\t", By =>  "\\t", All_Occurrences);
      return ''' & s & '''
   end escapeWSAndQuote;

   function getErrorRecoverySet (This : ANTLRErrorStrategy; recognizer : Parser) return IntervalSet is
      atn : constant ATN := recognizer.getInterpreterUnbufferedTokenStream.atn;
      ctx : Optional_RuleContext := recognizer._ctx;
      recoverSet : IntervalSet := This.IntervalSet;
   begin
      while Is_Valid (ctx) and then  ctx.invokingState >= 0 loop
         -- compute what follows who invoked us
         invokingState : constant := Value (atn.states.Element (ctx.invokingState));
         rt : constant RuleTransition := RuleTransition (invokingState.transition (0));
         follow : constant := atn.nextTokens (rt.followState);
         recoverSet.addAll (follow); -- try!
         ctx := ctx.parent;
      end loop;
      recoverSet.remove (CommonToken.EPSILON); -- try!
      if Is_Active (Aspect.DEBUG) then
         Wide_Wide_Text_IO.Put_Line ("recover set " & recoverSet.toString (recognizer.getTokenNames));
      end if;
      return recoverSet;
   end getErrorRecoverySet;

   procedure consumeUntil (This : ANTLRErrorStrategy; recognizer : Parser; set : IntervalSet) is
      ttype := getTokenStream (recognizer).LA (1);
   begin
      if Is_Active (Aspect.DEBUG) then
         Wide_Wide_Text_IO.Put_Line (Standard_Error, "consumeUntil (" & set.toString (recognizer.getTokenNamesUnbufferedTokenStream) & ')');
      end if;
      while ttype /= EOF and then not set.contains (ttype) loop
         if Is_Active (Aspect.DEBUG) then
            Wide_Wide_Text_IO.Put_Line ("consume during recover LA (1)=" & This.getTokenNames.Element (input.LA (1)));
         end if;
         recognizer.consumeUnbufferedTokenStream;
         ttype := getTokenStream (recognizer).LA (1);
      end loop;
   end consumeUntil;

end ANTLR.Runtime.DefaultErrorStrategies;
