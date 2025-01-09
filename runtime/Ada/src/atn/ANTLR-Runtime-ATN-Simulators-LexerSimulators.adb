-- €

with Ada.Wide_Wide_Text_IO;
with ANTLR.Runtime.Misc.Exceptions.Errors;
with Aspect;

use Ada;
use ANTLR.Runtime.Misc.Exceptions.Errors;
use Aspect;

package body ANTLR.Runtime.ATN.Simulators.LexerSimulators is

   --
   -- Compute a target state for an edge in the DFA, and attempt to add the
   -- computed state and corresponding edge to the DFA.
   --
   -- * parameter input: The input stream
   -- * parameter s: The current DFA state
   -- * parameter t: The next input symbol
   --
   -- * returns: The computed target DFA state for the given input symbol
   -- `t`. If `t` does not lead to a valid DFA state, this method
   -- returns _#ERROR_.
   --
   -- internal
   function computeTargetState (This : LexerATNSimulator;
                                input : CharStream;
                                s : DFAState;
                                t : Integer)
                                return DFAState is

   -- internal
   function failOrAccept (This : LexerATNSimulator;
                          prevAccept : SimState;
                          input : CharStream;
                          reach : ATNConfigSet;
                          t : Integer)
                          return Integer is

   --
   -- Given a starting configuration set, figure out all ATN configurations
   -- we can reach upon input `t`. Parameter `reach` is a return
   -- parameter.
   --
   -- internal
   procedure getReachableConfigSet (This : LexerATNSimulator; input : CharStream; closureConfig : ATNConfigSet; reach : ATNConfigSet; t : Integer) is

   -- internal
   procedure accept_State (This : LexerATNSimulator;
                     input : CharStream;
                     lexerActionExecutor : Optional_LexerActionExecutor;
                     startIndex : Integer;
                     index : Integer;
                     line : Integer;
                     charPos : Integer) is

   -- internal
   function getReachableTarget (This : LexerATNSimulator; trans : ATNTransition; t : Integer) return Optional_ATNState is

   -- final
   procedure captureSimState (This : LexerATNSimulator;
                              settings : SimState;
                              input : CharStream;
                              dfaState : DFAState) is


   -- -------- --
   -- SimState --
   -- -------- --
   procedure reset (This : SimState) is
   begin
      This.index := -1;
      This.line := 0;
      This.charPos := -1;
      This.dfaState := Optional_DFAState (Valid => False);
   end reset;

   -- ----------------- --
   -- LexerATNSimulator --
   -- ----------------- --
   procedure Initialize (Self : in out LexerATNSimulator;
                   atn : ATN;
                   decisionToDFA : DFA_List;
                   sharedContextCache : PredictionContextCache) is
   begin
      Self.Initialize (null, atn, decisionToDFA, sharedContextCache);
   end Initialize;

   procedure Initialize (Self : in out LexerATNSimulator;
                   recog : Optional_Lexer;
                   atn : ATN;
                   decisionToDFA : DFA_List,
                   sharedContextCache : PredictionContextCache) is
   begin
      self.decisionToDFA := decisionToDFA;
      self.recog := recog;
      ATNSimulator.init (atn, sharedContextCache); -- Super
   end Initialize;

   procedure copyState (This : LexerATNSimulator; simulator : LexerATNSimulator) is
   begin
      This.charPositionInLine := simulator.charPositionInLine;
      This.line := simulator.line;
      This.mode := simulator.mode;
      This.startIndex := simulator.startIndex;
   end copyState;

   function match (This : LexerATNSimulator; input : CharStream; mode : Lexer_Mode) return Integer is
      dfa : constant DFA := DFA.Container.Element (decisionToDFA, mode);
      Result : Integer;

      procedure Defered_Release is
      begin
         input.release (mark); -- try!
      exception
         when others => null;
      end Defered_Release;

   begin
      This.mode := mode;
      mark : constant := input.mark;

      This.startIndex := input.index;
      This.prevAccept.reset;
      s0 : constant := dfa.s0;
      if Is_Valid (s0) then
         Result := execATN (input, s0);
         Defered_Release;
         return Result;
      else
         Result := matchATN (input);
         Defered_Release;
         return Result;
      end if;
   end match;

   overriding
   procedure reset (This : LexerATNSimulator) is
   begin
      This.prevAccept.reset;
      This.startIndex := -1;
      This.line := 1;
      This.charPositionInLine := 0;
      This.mode := Lexer.DEFAULT_MODE;
   end reset;

   overriding
   procedure clearDFA (This : LexerATNSimulator) is
   begin
      for d of This.decisionToDFA loop --TOFIX
            DFA.Container.Replace (This.decisionToDFA, d) := DFA (atn.getDecisionState (d)!, d);
      end loop;
   end clearDFA;

   function matchATN (This : LexerATNSimulator; input : CharStream) return Integer is
      startState : constant := atn.modeToStartState.Element (mode);
      old_mode : constant := mode;
      s0_closure : constant := computeStartState (input, startState);
      suppressEdge : constant := s0_closure.hasSemanticContext
   begin

      if LexerATNSimulator.debug then
            Wide_Wide_Text_IO.Put_Line ("matchATN mode " & mode'Image & " start: " & startState'Image & "\n");
      end if;

      s0_closure.hasSemanticContext := False;

      next := addDFAState (s0_closure); -- constant
      if not suppressEdge then
            decisionToDFA.Element (mode).s0 := next;
      end if;

      predict := execATN (input, next); -- constant

      if LexerATNSimulator.debug then
            Wide_Wide_Text_IO.Put_Line ("DFA after matchATN: " & decisionToDFA.Element (old_mode).toLexerString);
      end if;

      return predict;
   end matchATN;

   function execATN (This : LexerATNSimulator; input : CharStream; ds0 : DFAState) return Integer is
   begin
      if Is_Active (Aspect.DEBUG) then
         Wide_Wide_Text_IO.Put_Line ("enter exec index " & input.index & " from " & ds0.configs);
      end if;
      if LexerATNSimulator.debug then
            Wide_Wide_Text_IO.Put_Line ("start state closure=" & ds0.configs & "\n");
      end if;

      if ds0.isAcceptState then
            -- allow zero-length tokens
            captureSimState (prevAccept, input, ds0);
      end if;

      t := input.LA (1);

      s := ds0 -- s is current/from DFA state

      loop
         -- while more work
         if LexerATNSimulator.debug then
            Wide_Wide_Text_IO.Put_Line ("execATN loop starting closure: " & s.configs & "\n");
         end if;

         -- As we move src->trg, src->trg, we keep track of the previous trg to
         -- avoid looking up the DFA state again, which is expensive.
         -- If the previous target was already part of the DFA, we might
         -- be able to avoid doing a reach operation upon t. If Is_Valid (s),
         -- it means that semantic predicates didn't prevent us from
         -- creating a DFA state. Once we know Is_Valid (s), we check to see if
         -- the DFA state has an edge already for t. If so, we can just reuse
         -- it's configuration set; there's no point in re-computing it.
         -- This is kind of like doing DFA simulation within the ATN
         -- simulation because DFA simulation is really just a way to avoid
         -- computing reach/closure sets. Technically, once we know that
         -- we have a previously added DFA state, we could jump over to
         -- the DFA simulator. But, that would mean popping back and forth
         -- a lot and making things more complicated algorithmically.
         -- This optimization makes a lot of sense for loops within DFA.
         -- A character will take us back to an existing DFA state
         -- that already has lots of edges out of it. e.g., .* in comments.
         target : DFAState;
         existingTarget : constant := getExistingTargetState (s, t);
         if Is_Valid (existingTarget) then
            target := existingTarget;
         else
            target := computeTargetState (input, s, t);
         end if;

         exit when target = ATNSimulator.ERROR;
         -- If this is a consumable input element, make sure to consume before
         -- capturing the accept state so the input index, line, and char
         -- position accurately reflect the state of the interpreter at the
         -- end of the token.
         if t /= BufferedTokenStream.EOF then
            consume (input);
         end if;

         if target.isAcceptState then
            captureSimState (prevAccept, input, target);
            exit when t = BufferedTokenStream.EOF;
         end if;

         t := input.LA (1);
         s := target -- flip; current DFA target becomes new src/from state
      end loop;

      return failOrAccept (prevAccept, input, s.configs, t);
   end execATN;

   function getExistingTargetState (This : LexerATNSimulator;
                                    s : DFAState;
                                    t : Integer)
                                    return Optional_DFAState is
      target : edges.Vetor;
   begin
      if not Is_Valid (s.edges)
         or else t < LexerATNSimulator.MIN_DFA_EDGE
         or else t > LexerATNSimulator.MAX_DFA_EDGE then
            return (Valid => False);
      else
         target := s.edges.Element (t - LexerATNSimulator.MIN_DFA_EDGE); -- constant
         if LexerATNSimulator.debug and then not target.Is_Empty then
               Wide_Wide_Text_IO.Put_Line ("reuse state " & s.stateNumber & " edge to " & target!.stateNumber);
         end if;
         return target;
      end if;
   end getExistingTargetState;

   function computeTargetState (This : LexerATNSimulator;
                                input : CharStream;
                                s : DFAState;
                                t : Integer)
                                return DFAState is
      reach : constant := ATNConfigSet (True, isOrdered => True);
   begin

      -- if we don't find an existing DFA state
      -- Fill reach starting from closure, following t transitions

      getReachableConfigSet (input, s.configs, reach, t);

      if reach.isEmpty then
         -- we got nowhere on t from s
         if not reach.hasSemanticContext then
            -- we got nowhere on t, don't raise out this knowledge; it'd
            -- cause a failover from DFA later.
            addDFAEdge (s, t, ATNSimulator.ERROR);
         end if;

         -- stop when we can't match any more char
         return ATNSimulator.ERROR;
      else
         -- Add an edge from s to target DFA found/created for reach
         return addDFAEdge (s, t, reach);
      end if;
   end computeTargetState;

   function failOrAccept (This : LexerATNSimulator;
                          prevAccept : SimState;
                          input : CharStream;
                          reach : ATNConfigSet;
                          t : Integer)
                          return Integer is
   begin
      if dfaState : constant := prevAccept.dfaState then
         lexerActionExecutor : constant := dfaState.lexerActionExecutor
         accept_State (input, lexerActionExecutor, startIndex,;
            prevAccept.index, prevAccept.line, prevAccept.charPos);
         return dfaState.prediction
      else
         -- if no accept and EOF is first char, return EOF
         if t = BufferedTokenStream.EOF and then input.index = startIndex then
            return CommonToken.EOF;
         else
            raise ANTLRException.recognition with LexerNoViableAltException (recog, input, startIndex, reach);
         end if;
      end if;
   end failOrAccept;

   procedure getReachableConfigSet (This : LexerATNSimulator; input : CharStream; closureConfig : ATNConfigSet; reach : ATNConfigSet; t : Integer) is
   begin
      -- this is used to skip processing for configs which have a lower priority
      -- than a config that already reached an accept state for the same rule
      skipAlt := ATN.INVALID_ALT_NUMBER
      for c of closureConfig.configs loop
            c : constant LexerATNConfig := Optional_LexerATNConfig (c);
            if not Is_Valid (c) then
               goto CONTINUE;
            end if;
            currentAltReachedAcceptState : constant := (c.alt = skipAlt);
            if currentAltReachedAcceptState and then c.hasPassedThroughNonGreedyDecision then
               goto CONTINUE;
            end if;

            if LexerATNSimulator.debug then
               Wide_Wide_Text_IO.Put_Line ("testing " & getTokenName (t) & " at " & c.toString (recog, True) & "\n");

            end if;

            n : constant := c.state.getNumberOfTransitions;
            for ti in 0 .. n - 1 loop
               -- for each transition
               trans : constant := c.state.transition (ti);
               if target : constant := getReachableTarget (trans, t) then
                  lexerActionExecutor := c.getLexerActionExecutor;
                  if lex : constant := lexerActionExecutor then
                        lexerActionExecutor := lex.fixOffsetBeforeMatch (input.index - startIndex);
                  end if;

                  treatEofAsEpsilon : constant := (t = BufferedTokenStream.EOF);
                  if closure (input,;
                        LexerATNConfig (c, target, lexerActionExecutor),
                        reach,
                        currentAltReachedAcceptState,
                        True,
                        treatEofAsEpsilon) {
                           -- any remaining configs for this alt have a lower priority than
                           -- the one that just reached an accept state.
                           skipAlt := c.alt
                           exit when True;
                  end if;
               end if;
            end loop;
            <<CONTINUE>>
      end loop;
   end if;

   procedure accept_State (This : LexerATNSimulator;
                     input : CharStream;
                     lexerActionExecutor : Optional_LexerActionExecutor;
                     startIndex : Integer;
                     index : Integer;
                     line : Integer;
                     charPos : Integer) is
   begin
      if LexerATNSimulator.debug then
         Wide_Wide_Text_IO.Put_Line ("ACTION " & UString (describing => lexerActionExecutor) & "\n");
      end if;

      -- seek to after last char in token
      input.seek (index);
      This.line := line;
      This.charPositionInLine := charPos;
      --TODO: CHECK
      lexerActionExecutor : constant := lexerActionExecutor;
      recog : constant := recog;
      if Is_Valid (lexerActionExecutor) and then Is_Valid (recog) then
         lexerActionExecutor.execute (recog, input, startIndex);
      end if;
   end accept;

   function getReachableTarget (This : LexerATNSimulator; trans : ATNTransition; t : Integer) return Optional_ATNState is
   begin
      if trans.matches (t, Character.MIN_VALUE, Character.MAX_VALUE) then
            return trans.target;
      else
         return (Valid => False);
      end if;
   end if;

   function computeStartState (This : LexerATNSimulator;
                               input : CharStream;
                               p : ATNState)
                               return ATNConfigSet is
      initialContext : constant := EmptyPredictionContext.Instance;
      configs : constant := ATNConfigSet (True, isOrdered => True);
      length : constant := p.getNumberOfTransitions;
   begin
      for i in 0 .. length - 1 loop
         target : constant := p.transition (i).target;
         c : constant := LexerATNConfig (target, i + 1, initialContext);
         closure (input, c, configs, False, False, False);
      end loop;
      return configs;
   end computeStartState;

   function closure (This : LexerATNSimulator;
                     input : CharStream;
                     config : LexerATNConfig;
                     configs : ATNConfigSet;
                     currentAltReachedAcceptState : Boolean;
                     speculative : Boolean;
                     treatEofAsEpsilon : Boolean)
                     return Boolean is
      currentAltReachedAcceptState := currentAltReachedAcceptState;
   begin
      if LexerATNSimulator.debug then
            Wide_Wide_Text_IO.Put_Line ("closure (" & config.toString (recog, True) & ')');
      end if;

      if config.state is RuleStopState then
         if LexerATNSimulator.debug then
            if recog : constant := recog then
               Wide_Wide_Text_IO.Put_Line ("closure at " & recog.getRuleNames[config.state.ruleIndex!] & " rule stop " & config'Image & "\n");
            else
               Wide_Wide_Text_IO.Put_Line ("closure at rule stop " & config'Image & "\n");
            end if;
         end if;

         if config.context?.hasEmptyPath, Default => True then
            if config.context?.isEmpty, Default => True then
               configs.add (config);
               return True;
            else
               configs.add (LexerATNConfig (config, config.state, EmptyPredictionContext.Instance));
               currentAltReachedAcceptState := True;
            end if;
         end if;

         if configContext : constant := config.context , not configContext.isEmpty then
            length : constant := configContext.size;
            for i in 0 .. length - 1 loop
               if configContext.getReturnState (i) /= PredictionContext.EMPTY_RETURN_STATE then
                     newContext : constant := configContext.getParent (i)!; -- "pop" return state
                     returnState : constant := atn.states[configContext.getReturnState (i)];
                     c : constant := LexerATNConfig (config, returnState!, newContext);
                     currentAltReachedAcceptState := closure (input, c, configs, currentAltReachedAcceptState, speculative, treatEofAsEpsilon);
               end if;
            end loop;
         end if;

         return currentAltReachedAcceptState
      end if;

      -- optimization
      if not config.state.onlyHasEpsilonTransitions then
            if not currentAltReachedAcceptState
               or else not config.hasPassedThroughNonGreedyDecision then
               configs.add (config);
            end if;
      end if;

      p : constant := config.state;
      length : constant := p.getNumberOfTransitions;
      for i in 0 .. length - 1 loop
            t : constant := p.transition (i);
            if c : constant := getEpsilonTarget (input, config, t, configs, speculative, treatEofAsEpsilon) then
               currentAltReachedAcceptState := closure (input, c, configs, currentAltReachedAcceptState, speculative, treatEofAsEpsilon);
            end if;
      end loop;

      return currentAltReachedAcceptState;
   end closure;

   function getEpsilonTarget (This : LexerATNSimulator;
                              input : CharStream;
                              config : LexerATNConfig;
                              t : ATNTransition;
                              configs : ATNConfigSet;
                              speculative : Boolean;
                              treatEofAsEpsilon  : Boolean)
                              return Optional_LexerATNConfig is
      c : Optional_LexerATNConfig; := (Valid => False);
   begin
      case t.getSerializationType is

         when Transition.RULE =>
            ruleTransition : constant RuleTransition := RuleTransition (t);
            newContext : constant := SingletonPredictionContext.create (config.context, ruleTransition.followState.stateNumber);
            c := LexerATNConfig (config, t.target, newContext);

         when Transition.PRECEDENCE =>
            raise ANTLRError.unsupportedOperation with "Precedence predicates are not supported in lexers.";


         when Transition.PREDICATE =>
            --
            -- Track traversing semantic predicates. If we traverse,
            -- we cannot add a DFA state for this "reach" computation
            -- because the DFA would not test the predicate again in the
            -- future. Rather than creating collections of semantic predicates
            -- like v3 and testing them on prediction, v4 will test them on the
            -- fly all the time using the ATN not the DFA. This is slower but
            -- semantically it's not used that often. One of the key elements to
            -- this predicate mechanism is not adding DFA states that see
            -- predicates immediately afterwards in the ATN. For example,
            --
            -- a : ID {p1}? | ID {p2}? ;
            --
            -- should create the start state for rule 'a' (to save start state
            -- competition), but should not create target of ID state. The
            -- collection of ATN states the following ID references includes
            -- states reached by traversing predicates. Since this is when we
            -- test them, we cannot cash the DFA state target of ID.
            --
            pt : constant PredicateTransition := PredicateTransition (t);
            if LexerATNSimulator.debug then
               Wide_Wide_Text_IO.Put_Line ("EVAL rule " & pt.ruleIndex & ':' & pt.predIndex);
            end if;
            configs.hasSemanticContext := True;
            if evaluatePredicate (input, pt.ruleIndex, pt.predIndex, speculative) then
               c := LexerATNConfig (config, t.target);
            end if;

         when Transition.ACTION =>
            if not Is_Valid (config.context)
            or else config.context!.hasEmptyPath then
               -- execute actions anywhere in the start rule for a token.
               --
               -- TODO: if the enrule is invoked recursively, some;
               -- actions may be executed during the recursive call. The
               -- problem can appear when This.hasEmptyPath is True but
               -- This.isEmpty is False. In this case, the config needs to be
               -- split into two contexts - one with just the empty path
               -- and another with everything but the empty path.
               -- Unfortunately, the current algorithm does not allow
               -- getEpsilonTarget to return two configurations, so
               -- additional modifications are needed before we can support
               -- the split operation.
               lexerActionExecutor : constant ActionTransition := ActionTransition (LexerActionExecutor.append (config.getLexerActionExecutor, atn.lexerActions[(t);).actionIndex]);
               c := LexerATNConfig (config, t.target, lexerActionExecutor);
            else
               -- ignore actions in referenced rules
               c := LexerATNConfig (config, t.target);
            end if;

         when Transition.EPSILON =>
            c := LexerATNConfig (config, t.target);

         when Transition.ATOM => fallthrough;
         when TRANSITION_RANGE => fallthrough;
         when Transition.SET =>
            if treatEofAsEpsilon then
               if t.matches (BufferedTokenStream.EOF, Character.MIN_VALUE, Character.MAX_VALUE) then
                     c := LexerATNConfig (config, t.target);
               end if;
            end if;

         when others =>
            return c;
      end case;

      return c;
   end getEpsilonTarget;

   function evaluatePredicate (This : LexerATNSimulator;
                               input : CharStream;
                               ruleIndex : Integer;
                               predIndex : Integer;
                               speculative  : Boolean)
                               return Boolean is
      Result : Boolean;

      procedure Defered_Release is
      begin
         charPositionInLine := savedCharPositionInLine;
         line := savedLine;
         input.seek (index); -- try!
         input.release (marker); -- try!
      exception
         when others => null;
      end Defered_Release;

   begin
      -- assume True if no recognizer was provided
      if not Is_Valid (recog) then
            return True;
      elsif not speculative then
         return recog.sempred (null, ruleIndex, predIndex);
      else
         declare
            savedCharPositionInLine : constant Integer := charPositionInLine;
            savedLine : constant Integer := line;
            index : constant Integer := input.index;
            marker : constant Integer := input.mark;
         begin
            consume (input);
            Result := recog.sempred (null, ruleIndex, predIndex);
            Defered_Release;
            return Result;
         exception
            when others => Defered_Release;
         end;
      end if;
   end evaluatePredicate;

   procedure captureSimState (This : LexerATNSimulator;
                              settings : SimState;
                              input : CharStream;
                              dfaState : DFAState) is
   begin
      settings.index := input.index;
      settings.line := This.line;
      settings.charPos := This.charPositionInLine;
      settings.dfaState := dfaState;
   end captureSimState;

   function addDFAEdge (This : LexerATNSimulator;
                        from : DFAState;
                        t : Integer;
                        q : ATNConfigSet)
                        return DFAState is
      --
      -- leading to this call, ATNConfigSet.hasSemanticContext is used as a
      -- marker indicating dynamic predicate evaluation makes this edge
      -- dependent on the specific input sequence, so the static edge in the
      -- DFA should be omitted. The target DFAState is still created since
      -- execATN has the ability to resynchronize with the DFA state cache
      -- following the predicate evaluation step.
      --
      -- TJP notes: next time through the DFA, we see a pred again and eval.
      -- If that gets us to a previously created (but dangling) DFA
      -- state, we can continue in pure DFA mode from there.
      --
      suppressEdge : constant := q.hasSemanticContext
      q.hasSemanticContext := False;
      to : constant := addDFAState (q);
   begin
      if suppressEdge then
         return to;
      else
         addDFAEdge (from, t, to);
         return to;
      end if;
   end addDFAEdge;

   procedure addDFAEdge (This : LexerATNSimulator; p : DFAState; t : Integer; q : DFAState) is

      function Closure return LexerATNSimulator is
         if not Is_Valid (p.edges) then
               --  make room for tokens 1 .. n and -1 masquerading as index 0
               p.edges := [DFAState?](repeating => null, count => LexerATNSimulator.MAX_DFA_EDGE - LexerATNSimulator.MIN_DFA_EDGE + 1);
         end if;
         p.edges[t - LexerATNSimulator.MIN_DFA_EDGE] := q -- connect
      end Closure;
      Closure_Return_Value : LexerATNSimulator;
      function Synchronized_Closure is new Mutex.Gen_Closure (Closure => Closure, Result_Type => LexerATNSimulator);

   begin
      if t < LexerATNSimulator.MIN_DFA_EDGE or else t > LexerATNSimulator.MAX_DFA_EDGE then
            -- Only track edges within the DFA bounds
            exit;
      end if;

      if LexerATNSimulator.debug then
            Wide_Wide_Text_IO.Put_Line ("EDGE " & p'Image & " -> " & q'Image & " upon " & t'Image);
      end if;

      p.Mutex.Run (Synchronized_Closure'Access, Closure_Return_Value);
      --TOFIX return Closure_Return_Value;

   end addDFAEdge;

   function addDFAState (This : LexerATNSimulator; configs : ATNConfigSet) return DFAState is

      function Closure return DFAState is
         existing : constant := dfa.states.Element (proposed);
      begin
         if Is_Valid (existing) then
               return existing;
         else
            declare
               newState : constant := proposed;
               newState.stateNumber := dfa.states.count;
            begin
               configs.setReadonly (True);
               newState.configs := configs;
               dfa.states.Insert (Key => newState, New_Item => newStateO);
               return newStateO;
            end;
         end if;
      end Closure;
      Closure_Return_Value : DFAState;
      function Synchronized_Closure is new Mutex.Gen_Closure (Closure => Closure, Result_Type => DFAState);

   begin
      --
      -- the lexer evaluates predicates on-the-fly; by this point configs
      -- should not contain any configurations with unevaluated predicates.
      --
      pragma assert (not configs.hasSemanticContext, "Expected: not configs.hasSemanticContext");

      proposed : constant := DFAState (configs);

      if rss : constant := configs.firstConfigWithRuleStopState then
            proposed.isAcceptState := True;
            proposed.lexerActionExecutor := (LexerATNConfig (rss)).getLexerActionExecutor;
            proposed.prediction := atn.ruleToTokenType[rss.state.ruleIndex!];
      end if;

      dfa : constant := decisionToDFA.Element (mode);

      dfa.statesMutex.Run (Synchronized_Closure'Access, Closure_Return_Value);
      return Closure_Return_Value;

   end addDFAState;

   function getText (This : LexerATNSimulator; input : CharStream) return UString is
   begin
      -- index is first lookahead char, don't include.
      return input.getText (Interval.of (startIndex, input.index - 1)); --try!
   exception
      when Others => null;
   end getText;

   procedure setLine (This : LexerATNSimulator; line : Integer) is
   begin
      This.line := line;
   end setLine;

   procedure setCharPositionInLine (This : LexerATNSimulator; charPositionInLine : Integer) is
   begin
      This.charPositionInLine := charPositionInLine;
   end setCharPositionInLine;

   procedure consume (This : LexerATNSimulator; input : CharStream) is
      curChar : constant := input.LA (1);
   begin
      if UString (Character (integerLiteral => curChar)) == "\n" then
            line := @ + 1;
            charPositionInLine := 0;
      else
            charPositionInLine := @ + 1;
      end if;
      input.consume;
   end consume;

   function getTokenName (This : LexerATNSimulator; t : Integer) return UString is
   begin
      if t = -1 then
         return "EOF";
      else
         --if ( Is_Valid (atn.g) ) return atn.g.getTokenDisplayName (t);
         return ''' & UString (Character (integerLiteral => t)) & ''';
      end if;
   end getTokenName;

end ANTLR.Runtime.ATN.Simulators.LexerSimulators;
