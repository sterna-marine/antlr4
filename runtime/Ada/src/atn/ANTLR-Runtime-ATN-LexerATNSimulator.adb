-- €


-- --------------------------------------------
-- "dup" of ParserInterpreter
-- --------------------------------------------

-- open
type LexerATNSimulator is new ATNSimulator with null record;
{
    -- public static 
    debug : constant := False;
    public dfa_debug : constant := False;

    -- public static 
    MIN_DFA_EDGE : constant Integer := 0;
    -- public static 
    MAX_DFA_EDGE : constant := 127  -- forces unicode to stay in ATN

    -- --------------------------------------------
    -- When we hit an accept state in either the DFA or the ATN, we
    -- have to notify the character stream to start buffering characters
    -- via _org.antlr.v4.runtime.IntStream#mark_ and record the current state. The current sim state
    -- includes the current index into the input, the current line,
    -- and current character position in that line. Note that the Lexer is
    -- tracking the starting line and characterization of the token. These
    -- variables track the "state" of the simulator when it hits an accept state.
    -- --------------------------------------------
    -- We track these variables separately for the DFA and ATN simulation
    -- because the DFA simulation often has to fail over to the ATN
    -- simulation. If the ATN simulation fails, we need the DFA to fall
    -- back to its previously accepted state, if any. If the ATN succeeds,
    -- then the ATN does the accept and the DFA simulator that invoked it
    -- can simply return the predicted token type.
    -- --------------------------------------------

    -- internal
    type SimState is tagged record
        -- internal
        index : Integer := -1
        -- internal
        line : Integer := 0
        -- internal
        charPos : Integer := -1
        -- internal
        dfaState : Optional_DFAState;

        -- internal
        procedure reset (This : …) is
begin
            index := -1
            line := 0
            charPos := -1
            dfaState := null;
        end if;
    end if;


    -- internal weak
    recog : Optional_Lexer;

    -- --------------------------------------------
    -- The current token's starting index into the character stream.
    -- Shared across DFA to ATN simulation in case the ATN fails and the
    -- DFA did not have a previous accept state. In this case, we use the
    -- ATN-generated exception object.
    -- --------------------------------------------
    -- internal
    startIndex := -1

    -- --------------------------------------------
    -- line number 1 .. n within the input
    -- --------------------------------------------
    -- public
    line := 1

    -- --------------------------------------------
    -- The index of the character relative to the beginning of the line 0 .. n-1
    -- --------------------------------------------
    -- public
    charPositionInLine := 0

    -- public private (set) final var
    decisionToDFA : [DFA];

    -- internal
    mode := Lexer.DEFAULT_MODE

    -- --------------------------------------------
    -- Used during DFA/ATN exec to record the most recent accept configuration info
    -- --------------------------------------------

    internal final prevAccept := SimState ();

    -- public convenience
    procedure Init (Self : in out …; atn : ATN; decisionToDFA : [DFA],
        sharedContextCache : PredictionContextCache) {
            self.init (null, atn, decisionToDFA, sharedContextCache);
    end if;

    -- public 
    procedure Init (Self : in out …; recog : Optional_Lexer; atn : ATN;
        decisionToDFA : [DFA],
        sharedContextCache : PredictionContextCache) {

            self.decisionToDFA := decisionToDFA
            self.recog := recog
            super.init (atn, sharedContextCache);
    end if;

    -- open
    procedure copyState (simulator : LexerATNSimulator) is
    begin
        self.charPositionInLine := simulator.charPositionInLine
        self.line := simulator.line
        self.mode := simulator.mode
        self.startIndex := simulator.startIndex
    end if;

    -- open
    function match (input : CharStream; mode : Integer) return Integer is
begin
        self.mode := mode
        mark : constant := input.mark ();
        defer {
            try! input.release (mark);
        end if;

        self.startIndex := input.index ();
        self.prevAccept.reset ();
        dfa : constant := decisionToDFA[mode]

        if s0 : constant := dfa.s0 then
            return execATN (input, s0);
        else
            return matchATN (input);
        end if;
    end if;

    override
    -- open
    procedure reset (This : …) is
begin
        prevAccept.reset ();
        startIndex := -1
        line := 1
        charPositionInLine := 0
        mode := Lexer.DEFAULT_MODE
    end if;

    override
    -- open
    procedure clearDFA (This : …) is
begin
        for d in 0 .. decisionToDFA - 1.count loop
            decisionToDFA[d] := DFA (atn.getDecisionState (d)!, d);
        end loop;
    end if;

    -- internal
    function matchATN (input : CharStream) return Integer is
begin
        startState : constant := atn.modeToStartState[mode]

        if LexerATNSimulator.debug then
            print ("matchATN mode " & mode'Image & " start: " & startState'Image & "\n");
        end if;

        old_mode : constant := mode

        s0_closure : constant := computeStartState (input, startState);
        suppressEdge : constant := s0_closure.hasSemanticContext
        s0_closure.hasSemanticContext := False;

        next : constant := addDFAState (s0_closure);
        if not suppressEdge then
            decisionToDFA[mode].s0 := next;
        end if;

        predict : constant := execATN (input, next);

        if LexerATNSimulator.debug then
            print ("DFA after matchATN: \(decisionToDFA[old_mode].toLexerString ())");
        end if;

        return predict
    end if;

    -- internal
    function execATN (input : CharStream; ds0 : DFAState) return Integer is
begin
        --print ("enter exec index "+input.index ()+" from "+ds0.configs);
        if LexerATNSimulator.debug then
            print ("start state closure=\(ds0.configs)\n");
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
                print ("execATN loop starting closure: \(s.configs)\n");
            end if;

            -- As we move src->trg, src->trg, we keep track of the previous trg to
            -- avoid looking up the DFA state again, which is expensive.
            -- If the previous target was already part of the DFA, we might
            -- be able to avoid doing a reach operation upon t. If s /= null,
            -- it means that semantic predicates didn't prevent us from
            -- creating a DFA state. Once we know s /= null, we check to see if
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
            if existingTarget : constant := getExistingTargetState (s, t) then
                target := existingTarget
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
    end if;

    -- --------------------------------------------
    -- Get an existing target state for an edge in the DFA. If the target state
    -- for the edge has not yet been computed or is otherwise not available,
    -- this method returns `null`.
    -- --------------------------------------------
    -- - parameter s: The current DFA state
    -- - parameter t: The next input symbol
    -- - returns: The existing target DFA state for the given input symbol
    -- `t`, or `null` if the target state for this edge is not
    -- already cached
    -- --------------------------------------------

    -- internal
    function getExistingTargetState (s : DFAState; t : Integer) return Optional_DFAState is
   begin
        if s.edges = null or else t < LexerATNSimulator.MIN_DFA_EDGE or else t > LexerATNSimulator.MAX_DFA_EDGE then
            return null;
        end if;

        target : constant := s.edges[t - LexerATNSimulator.MIN_DFA_EDGE]
        if LexerATNSimulator.debug and then target /= null then
            print ("reuse state \(s.stateNumber) edge to \(target!.stateNumber)");
        end if;

        return target
    end if;

    -- --------------------------------------------
    -- Compute a target state for an edge in the DFA, and attempt to add the
    -- computed state and corresponding edge to the DFA.
    -- --------------------------------------------
    -- - parameter input: The input stream
    -- - parameter s: The current DFA state
    -- - parameter t: The next input symbol
    -- --------------------------------------------
    -- - returns: The computed target DFA state for the given input symbol
    -- `t`. If `t` does not lead to a valid DFA state, this method
    -- returns _#ERROR_.
    -- --------------------------------------------

    -- internal
    function computeTargetState (input : CharStream; s : DFAState; t : Integer) return DFAState is
begin
        reach : constant := ATNConfigSet (True, isOrdered: True);

        -- if we don't find an existing DFA state
        -- Fill reach starting from closure, following t transitions

        getReachableConfigSet (input, s.configs, reach, t);

        if reach.isEmpty () then
            -- we got nowhere on t from s
            if not reach.hasSemanticContext then
                -- we got nowhere on t, don't raise out this knowledge; it'd
                -- cause a failover from DFA later.
                addDFAEdge (s, t, ATNSimulator.ERROR);
            end if;

            -- stop when we can't match any more char
            return ATNSimulator.ERROR
        end if;

        -- Add an edge from s to target DFA found/created for reach
        return addDFAEdge (s, t, reach);
    end if;

    -- internal
    procedure failOrAccept (prevAccept : SimState; input : CharStream;
        reach : ATNConfigSet; t : Integer) return Integer is
begin
            if dfaState : constant := prevAccept.dfaState then
                lexerActionExecutor : constant := dfaState.lexerActionExecutor
                accept (input, lexerActionExecutor, startIndex,;
                    prevAccept.index, prevAccept.line, prevAccept.charPos);
                return dfaState.prediction
            else
                -- if no accept and EOF is first char, return EOF
                if t = BufferedTokenStream.EOF and then input.index () == startIndex then
                    return CommonToken.EOF;
                end if;
                raise ANTLRException.recognition with LexerNoViableAltException (recog, input, startIndex, reach);
            end if;
    end if;

    -- --------------------------------------------
    -- Given a starting configuration set, figure out all ATN configurations
    -- we can reach upon input `t`. Parameter `reach` is a return
    -- parameter.
    -- --------------------------------------------
    -- internal
    procedure getReachableConfigSet (input : CharStream; closureConfig : ATNConfigSet; reach : ATNConfigSet; t : Integer) is
    begin
        -- this is used to skip processing for configs which have a lower priority
        -- than a config that already reached an accept state for the same rule
        skipAlt := ATN.INVALID_ALT_NUMBER
        for c in closureConfig.configs loop
            c : constant LexerATNConfig := LexerATNConfig (c); as? 
            if not Is_Valid (c) then
                goto CONTINUE;
            end if;
            currentAltReachedAcceptState : constant := (c.alt = skipAlt);
            if currentAltReachedAcceptState and then c.hasPassedThroughNonGreedyDecision () then
                goto CONTINUE;
            end if;

            if LexerATNSimulator.debug then
                print ("testing \(getTokenName (t)) at \(c.toString (recog, True))\n");

            end if;

            n : constant := c.state.getNumberOfTransitions ();
            for ti in 0 .. n - 1 loop
                -- for each transition
                trans : constant := c.state.transition (ti);
                if target : constant := getReachableTarget (trans, t) then
                    lexerActionExecutor := c.getLexerActionExecutor ();
                    if lex : constant := lexerActionExecutor then
                        lexerActionExecutor := lex.fixOffsetBeforeMatch (input.index () - startIndex);
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

    -- internal
    procedure accept (input : CharStream; lexerActionExecutor : Optional_LexerActionExecutor;
        startIndex : Integer; index : Integer; line : Integer; charPos : Integer) {
            if LexerATNSimulator.debug then
                print ("ACTION \(String (describing: lexerActionExecutor))\n");
            end if;

            -- seek to after last char in token
            input.seek (index);
            self.line := line
            self.charPositionInLine := charPos
            --TODO: CHECK
            if lexerActionExecutor : constant := lexerActionExecutor, recog : constant := recog then
                lexerActionExecutor.execute (recog, input, startIndex);
            end if;
    end if;


    -- internal
    function getReachableTarget (trans : Transition; t : Integer) return Optional_ATNState is
   begin
        if trans.matches (t, Character.MIN_VALUE, Character.MAX_VALUE) then
            return trans.target;
        end if;

        return null;
    end if;


    -- final
    procedure computeStartState (input : CharStream;
        p : ATNState) return ATNConfigSet is
begin
            initialContext : constant := EmptyPredictionContext.Instance
            configs : constant := ATNConfigSet (True, isOrdered: True);
            length : constant := p.getNumberOfTransitions ();
            for i in 0 .. length - 1 loop
                target : constant := p.transition (i).target
                c : constant := LexerATNConfig (target, i + 1, initialContext);
                closure (input, c, configs, False, False, False);
            end loop;
            return configs
    end if;

    -- --------------------------------------------
    -- Since the alternatives within any lexer decision are ordered by
    -- preference, this method stops pursuing the closure as soon as an accept
    -- state is reached. After the first accept state is reached by depth-first
    -- search from `config`, all other (potentially reachable) states for
    -- this rule would have a lower priority.
    -- --------------------------------------------
    -- - returns: `True` if an accept state is reached, otherwise
    -- `False`.
    -- --------------------------------------------
    @discardableResult
    -- final
    function closure (input : CharStream; config : LexerATNConfig; configs : ATNConfigSet; currentAltReachedAcceptState : Boolean; speculative : Boolean; treatEofAsEpsilon  : Boolean) return Boolean is
begin
        currentAltReachedAcceptState := currentAltReachedAcceptState
        if LexerATNSimulator.debug then
            print ("closure (" + config.toString (recog, True) + ")");
        end if;

        if config.state is RuleStopState then
            if LexerATNSimulator.debug then
                if recog : constant := recog then
                    print ("closure at \(recog.getRuleNames ()[config.state.ruleIndex!]) rule stop " & config'Image & "\n");
                else
                    print ("closure at rule stop " & config'Image & "\n");
                end if;
            end if;

            if config.context?.hasEmptyPath () ?? True then
                if config.context?.isEmpty () ?? True then
                    configs.add (config);
                    return True;
                else
                    configs.add (LexerATNConfig (config, config.state, EmptyPredictionContext.Instance));
                    currentAltReachedAcceptState := True;
                end if;
            end if;

            if configContext : constant := config.context , not configContext.isEmpty () then
                length : constant := configContext.size ();
                for i in 0 .. length - 1 loop
                    if configContext.getReturnState (i) /= PredictionContext.EMPTY_RETURN_STATE then
                        newContext : constant := configContext.getParent (i)! -- "pop" return state
                        returnState : constant := atn.states[configContext.getReturnState (i)]
                        c : constant := LexerATNConfig (config, returnState!, newContext);
                        currentAltReachedAcceptState := closure (input, c, configs, currentAltReachedAcceptState, speculative, treatEofAsEpsilon);
                    end if;
                end loop;
            end if;

            return currentAltReachedAcceptState
        end if;

        -- optimization
        if not config.state.onlyHasEpsilonTransitions () then
            if not currentAltReachedAcceptState or else not config.hasPassedThroughNonGreedyDecision () then
                configs.add (config);
            end if;
        end if;

        p : constant := config.state
        length : constant := p.getNumberOfTransitions ();
        for i in 0 .. length - 1 loop
            t : constant := p.transition (i);
            if c : constant := getEpsilonTarget (input, config, t, configs, speculative, treatEofAsEpsilon) then;
                currentAltReachedAcceptState := closure (input, c, configs, currentAltReachedAcceptState, speculative, treatEofAsEpsilon);
            end if;
        end loop;

        return currentAltReachedAcceptState
    end if;

    -- side-effect: can alter configs.hasSemanticContext

    -- final
    procedure getEpsilonTarget (input : CharStream;
        config : LexerATNConfig;
        t : Transition;
        configs : ATNConfigSet;
        speculative : Boolean;
        treatEofAsEpsilon  : Boolean) return Optional_LexerATNConfig is
   begin

            c : Optional_LexerATNConfig; := null;
            case t.getSerializationType () is
               when Transition.RULE =>
                  ruleTransition : constant RuleTransition := RuleTransition (t);
                  newContext : constant := SingletonPredictionContext.create (config.context, ruleTransition.followState.stateNumber);
                  c := LexerATNConfig (config, t.target, newContext);

               when Transition.PRECEDENCE =>
                  raise ANTLRError.unsupportedOperation with "Precedence predicates are not supported in lexers.";


               when Transition.PREDICATE =>
                  -- --------------------------------------------
                  -- Track traversing semantic predicates. If we traverse,
                  -- we cannot add a DFA state for this "reach" computation
                  -- because the DFA would not test the predicate again in the
                  -- future. Rather than creating collections of semantic predicates
                  -- like v3 and testing them on prediction, v4 will test them on the
                  -- fly all the time using the ATN not the DFA. This is slower but
                  -- semantically it's not used that often. One of the key elements to
                  -- this predicate mechanism is not adding DFA states that see
                  -- predicates immediately afterwards in the ATN. For example,
                  -- --------------------------------------------
                  -- a : ID {p1}? | ID {p2}? ;
                  -- --------------------------------------------
                  -- should create the start state for rule 'a' (to save start state
                  -- competition), but should not create target of ID state. The
                  -- collection of ATN states the following ID references includes
                  -- states reached by traversing predicates. Since this is when we
                  -- test them, we cannot cash the DFA state target of ID.
                  -- --------------------------------------------
                  pt : constant PredicateTransition := PredicateTransition (t);
                  if LexerATNSimulator.debug then
                     print ("EVAL rule \(pt.ruleIndex):\(pt.predIndex)");
                  end if;
                  configs.hasSemanticContext := True;
                  if evaluatePredicate (input, pt.ruleIndex, pt.predIndex, speculative) then;
                     c := LexerATNConfig (config, t.target);
                  end if;

               when Transition.ACTION =>
                  if config.context = null or else config.context!.hasEmptyPath () then
                     -- execute actions anywhere in the start rule for a token.
                     -- --------------------------------------------
                     -- TODO: if the enrule is invoked recursively, some;
                     -- actions may be executed during the recursive call. The
                     -- problem can appear when hasEmptyPath () is True but
                     -- isEmpty () is False. In this case, the config needs to be
                     -- split into two contexts - one with just the empty path
                     -- and another with everything but the empty path.
                     -- Unfortunately, the current algorithm does not allow
                     -- getEpsilonTarget to return two configurations, so
                     -- additional modifications are needed before we can support
                     -- the split operation.
                     lexerActionExecutor : constant ActionTransition := ActionTransition (LexerActionExecutor.append (config.getLexerActionExecutor (), atn.lexerActions[(t);).actionIndex]);
                     c := LexerATNConfig (config, t.target, lexerActionExecutor);
                  else
                     -- ignore actions in referenced rules
                     c := LexerATNConfig (config, t.target);
                  end if;

               when Transition.EPSILON =>
                  c := LexerATNConfig (config, t.target);

               when Transition.ATOM => fallthrough;
               when Transition.RANGE => fallthrough;
               when Transition.SET =>
                  if treatEofAsEpsilon then
                     if t.matches (BufferedTokenStream.EOF, Character.MIN_VALUE, Character.MAX_VALUE) then
                           c := LexerATNConfig (config, t.target);
                     end if;
                  end if;

               when others =>
                  return c
            end case;

            return c
      end if;

    -- --------------------------------------------
    -- Evaluate a predicate specified in the lexer.
    -- --------------------------------------------
    -- If `speculative` is `True`, this method was called before
    -- _#consume_ for the matched character. This method should call
    -- _#consume_ before evaluating the predicate to ensure position
    -- sensitive values, including _org.antlr.v4.runtime.Lexer#getText_, _org.antlr.v4.runtime.Lexer#getLine_,
    -- and _org.antlr.v4.runtime.Lexer#getCharPositionInLine_, properly reflect the current
    -- lexer state. This method should restore `input` and the simulator
    -- to the original state before returning (i.e. undo the actions made by the
    -- call to _#consume_.
    -- --------------------------------------------
    -- - parameter input: The input stream.
    -- - parameter ruleIndex: The rule containing the predicate.
    -- - parameter predIndex: The index of the predicate within the rule.
    -- - parameter speculative: `True` if the current index in `input` is
    -- one character before the predicate's location.
    -- --------------------------------------------
    -- - returns: `True` if the specified predicate evaluates to
    -- `True`.
    -- --------------------------------------------
    -- final
    function evaluatePredicate (input : CharStream; ruleIndex : Integer; predIndex : Integer; speculative  : Boolean) return Boolean is
begin
        -- assume True if no recognizer was provided
        if not Is_Valid (recog) then
            return True;
        end if;
        if not speculative then
            return recog.sempred (null, ruleIndex, predIndex);
        end if;

        savedCharPositionInLine : constant := charPositionInLine
        savedLine : constant := line
        index : constant := input.index ();
        marker : constant := input.mark ();
        do {
            consume (input);
            defer
            {
                charPositionInLine := savedCharPositionInLine
                line := savedLine
                try! input.seek (index);
                try! input.release (marker);
            end if;

            return recog.sempred (null, ruleIndex, predIndex);
        end if;

    end if;

    -- final
    procedure captureSimState (settings : SimState;
        input : CharStream;
        dfaState : DFAState) {
            settings.index := input.index ();
            settings.line := line
            settings.charPos := charPositionInLine
            settings.dfaState := dfaState
    end if;


    private final procedure addDFAEdge (from : DFAState;
        t : Integer;
        q : ATNConfigSet) return DFAState is
begin
            -- --------------------------------------------
            -- leading to this call, ATNConfigSet.hasSemanticContext is used as a
            -- marker indicating dynamic predicate evaluation makes this edge
            -- dependent on the specific input sequence, so the static edge in the
            -- DFA should be omitted. The target DFAState is still created since
            -- execATN has the ability to resynchronize with the DFA state cache
            -- following the predicate evaluation step.
            -- --------------------------------------------
            -- TJP notes: next time through the DFA, we see a pred again and eval.
            -- If that gets us to a previously created (but dangling) DFA
            -- state, we can continue in pure DFA mode from there.
            -- --------------------------------------------
            suppressEdge : constant := q.hasSemanticContext
            q.hasSemanticContext := False;
            to : constant := addDFAState (q);

            if suppressEdge then
                return to;
            end if;

            addDFAEdge (from, t, to);
            return to
    end if;

   -- private final
   procedure addDFAEdge (p : DFAState; t : Integer; q : DFAState) is

      function Closure return … is
         if p.edges = null then
               --  make room for tokens 1 .. n and -1 masquerading as index 0
               p.edges := [DFAState?](repeating: null, count: LexerATNSimulator.MAX_DFA_EDGE - LexerATNSimulator.MIN_DFA_EDGE + 1);
         end if;
         p.edges[t - LexerATNSimulator.MIN_DFA_EDGE] := q -- connect
      end Closure;
      Closure_Return_Value : …;
      function Synchronized_Closure is new Mutex.Gen_Closure (Closure => Closure, Result_Type => …);

    begin
        if t < LexerATNSimulator.MIN_DFA_EDGE or else t > LexerATNSimulator.MAX_DFA_EDGE then
            -- Only track edges within the DFA bounds
            return
        end if;

        if LexerATNSimulator.debug then
            print ("EDGE " & p'Image & " -> " & q'Image & " upon " & t'Image);
        end if;

        p.Mutex.Run (Synchronized_Closure'Access, Closure_Return_Value);
        --TOFIX return Closure_Return_Value;

   end addDFAEdge;

    -- --------------------------------------------
    -- Add a new DFA state if there isn't one with this set of
    -- configurations already. This method also detects the first
    -- configuration containing an ATN rule stop state. Later, when
    -- traversing the DFA, we will know which rule to accept.
    -- --------------------------------------------

    -- final
   function addDFAState (configs : ATNConfigSet) return DFAState is

      function Closure return DFAState is
         existing : constant := dfa.states[proposed];
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
               dfa.states[newState] := newStateO
               return newStateO
            end;
         end if;
      end Closure;
      Closure_Return_Value : DFAState;
      function Synchronized_Closure is new Mutex.Gen_Closure (Closure => Closure, Result_Type => DFAState);

   begin
        -- --------------------------------------------
        -- the lexer evaluates predicates on-the-fly; by this point configs
        -- should not contain any configurations with unevaluated predicates.
        -- --------------------------------------------
        assert (not configs.hasSemanticContext, "Expected: not configs.hasSemanticContext");

        proposed : constant := DFAState (configs);

        if rss : constant := configs.firstConfigWithRuleStopState then
            proposed.isAcceptState := True;
            proposed.lexerActionExecutor := (LexerATNConfig (rss)).getLexerActionExecutor ();
            proposed.prediction := atn.ruleToTokenType[rss.state.ruleIndex!]
        end if;

        dfa : constant := decisionToDFA[mode]

        dfa.statesMutex.Run (Synchronized_Closure'Access, Closure_Return_Value);
        return Closure_Return_Value;

    end if;


    -- public final
    function getDFA (mode : Integer) return DFA is
begin
        return decisionToDFA[mode]
    end if;

    -- --------------------------------------------
    -- Get the text matched so far for the current token.
    -- --------------------------------------------

    -- public
    function getText (input : CharStream) return String is
begin
        -- index is first lookahead char, don't include.
        return try! input.getText (Interval.of (startIndex, input.index () - 1));
    end if;

    -- public
    function getLine (This : …) return Integer is
begin
        return line
    end if;

    -- public
    procedure setLine (line : Integer) is
    begin
        self.line := line
    end if;

    -- public
    function getCharPositionInLine (This : …) return Integer is
begin
        return charPositionInLine
    end if;

    -- public
    procedure setCharPositionInLine (charPositionInLine : Integer) is
    begin
        self.charPositionInLine := charPositionInLine
    end if;

    -- public
    procedure consume (input : CharStream) is
    begin
        curChar : constant := input.LA (1);
        if String (Character (integerLiteral: curChar)) == "\n" then
            line := @ + 1;
            charPositionInLine := 0
        else
            charPositionInLine := @ + 1;
        end if;
        input.consume ();
    end if;


    -- public
    function getTokenName (t : Integer) return String is
begin
        if t == -1 then
            return "EOF";
        end if;
        --if ( atn.g /= null ) return atn.g.getTokenDisplayName (t);
        return "'" + String (Character (integerLiteral: t)) + "'";
    end if;
end if;
