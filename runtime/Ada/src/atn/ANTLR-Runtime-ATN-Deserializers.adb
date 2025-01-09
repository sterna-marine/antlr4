-- €

with ANTLR.Runtime.ATN.States.DecisionStates.BlockStartStates;
with ANTLR.Runtime.Misc.Exceptions.Errors;

use ANTLR.Runtime.ATN.States.DecisionStates.BlockStartStates;
use ANTLR.Runtime.Misc.Exceptions.Errors;

package body ANTLR.Runtime.ATN.Deserializers is

   procedure Initialize (Self : in out ATNDeserializer;
                   deserializationOptions : Optional_ATNDeserializationOptions := (Valid => False)) is
   begin
      self.deserializationOptions := Value (deserializationOptions, Default => ATNDeserializationOptions);
   end Initialize;

   function deserialize (This : ATNDeserializer; data : Integer_List) return ATN is
      version : constant Integer := data.Element (0);
      reason : UString;
      grammarType : constant ATNType := ATNType (rawValue => data.Element (1);
      maxTokenType : constant Integer := data.Element (2);
      p : Integer := 3; --next item in data.Element
   begin
      if version /= ATNDeserializer.SERIALIZED_VERSION then
         reason := "Could not deserialize ATN with version " & version'Image & " (expected " & ATNDeserializer.SERIALIZED_VERSION) & ").";
         raise ANTLRError.unsupportedOperation with reason;
      end if;
      atn : ATN := ATN (grammarType, maxTokenType);
      --
      -- STATES
      --
      STATES:
      declare
         nstates : constant Integer := data.Element (p);
         loopBackStateNumbers : LoopEndState_Map; -- := LoopEndState_Map.Empty_Map;
         endStateNumbers := BlockStartState_Map; -- := LoopEndState_Map.Empty_Map;

         stype : Integer;
         ruleIndex : Integer;
         loopBackStateNumber, endStateNumber : Integer; -- : ATNStates.State;
         numNonGreedyStates : Integer;
         stateNumber : Integer; -- : ATNStates.State;
         numPrecedenceStates : Integer; -- : ATNStates.State;

         s : Optional_ATNState;
         s2 : BlockStartState;
         X : DecisionState;
         Y : RuleStartState;
      begin
         p := @ + 1;
         for Some_Dummy_State in 0 .. nstates - 1 loop
            stype := data.Element (p);
            p := @ + 1;
            -- ignore bad type of states
            if stype = ATNState.INVALID_TYPE then
               atn.addState (null);
               goto CONTINUE;
            end if;

            ruleIndex := data.Element (p);
            p := @ + 1;
            s := stateFactory (stype, ruleIndex)!;
            if stype = ATNState.LOOP_END then
               -- special case
               loopBackStateNumber := data.Element (p);
               p := @ + 1;
               loopBackStateNumbers.append ((LoopEndState (s), loopBackStateNumber));
            else -- elseif
               s2 : constant BlockStartState := BlockStartState (s);
               if Is_Valid (s) then
                  endStateNumber := data.Element (p);
                  p := @ + 1;
                  endStateNumbers.append ((s2, endStateNumber));
               end if;
            end if;
            atn.addState (s2);
            <<CONTINUE>>
         end loop;

         -- delay the assignment of loop back and end states until we know all the state instances have been initialized
         for pair in loopBackStateNumbers loop
            pair.0.loopBackState := atn.states.Element (pair.1);
         end if;

         for pair in endStateNumbers loop
            pair.0.endState := Optional_BlockEndState (atn.states.Element (pair.1));
         end loop;

         numNonGreedyStates := data.Element (p);
         p := @ + 1;
         for Some_Dummy_State in 0 .. numNonGreedyStates - 1 loop
            stateNumber := data.Element (p);
            p := @ + 1;
            X := DecisionState (atn.states.Element (stateNumber)); -- as! 
            X.nonGreedy := True;
         end loop;

         numPrecedenceStates := data.Element (p);
         p := @ + 1;
         for Some_Dummy_State in 0 .. numPrecedenceStates - 1 loop
            stateNumber := data.Element (p);
            p := @ + 1;
            Y = RuleStartState (atn.states.Element (stateNumber)); -- as!
            Y.isPrecedenceRule := True;
         end loop;

      --
      -- RULES
      --
      RULES:
      declare
         nrules : constant Integer := data.Element (p);
         ruleToTokenType : Integer_List; -- := Integer_Container.Empty_Vector;
         ruleToStartState : RuleStartState.Container; -- := RuleStartState.Container.Empty_Vector;

         s : Integer;
         tokenType : Integer;

         startState : constant RuleStartState;
      begin
         p := @ + 1;
         for Some_Dummy_Rule in 0 .. nrules - 1 loop
            s := data.Element (p);
            p := @ + 1;
            startState := RuleStartState (atn.states.Element (s));
            ruleToStartState.append (startState);

            if atn.grammarType = ATNType.lexer then
                  tokenType := data.Element (p);
                  p := @ + 1;
                  ruleToTokenType.append (tokenType);
            end if;
         end loop;
         atn.ruleToStartState := ruleToStartState;
         if atn.grammarType = ATNType.lexer then
            atn.ruleToTokenType := ruleToTokenType;
         end if;

         fillRuleToStopState (atn);
      end RULES;

      --
      -- MODES
      --
      declare
         nmodes : constant integer := data.Element (p);
         s : Integer;
   
         X : TokensStartState;
      begin
         p := @ + 1;
         for Some_Dummy_Mode in 0 .. nmodes - 1 loop
            s := data.Element (p);
            p := @ + 1;
            X := TokensStartState (atn.states.Element (s)); -- as! 
            atn.appendModeToStartState (X);
         end loop;
      end MODES;

      --
      -- SETS
      --
      SETS:
      declare
         sets : IntervalSet.Container; -- := IntervalSet.Container.Empty_Vector;
      begin
         readSets (data, p'Access, sets'Access, readInt);
      end SETS;

      --
      -- EDGES
      --
      EDGES:
      declare
         nedges : constant Integer := data.Element (p);
         src : Integer;
         trg : Integer;
         ttype : Integer;
         arg1 : Integer;
         arg2 : Integer;
         arg3 : Integer;

         trans : ATNTransition;
         srcState : atn.states; --TOFIX
      begin
         p := @ + 1;
         for Some_Dummy_Edge in 0 .. nedges - 1 loop
            src := data.Element (p);
            trg := data.Element (p + 1);
            ttype := data.Element (p + 2);
            arg1 := data.Element (p + 3);
            arg2 := data.Element (p + 4);
            arg3 := data.Element (p + 5);
            trans := edgeFactory (atn, ttype, src, trg, arg1, arg2, arg3, sets);

            srcState := Value (atn.states.Element (src)); -- !
            srcState.addTransition (trans);
            p := @ + 6;
         end loop;
         deriveEdgesForRuleStopStates (atn);
         validateStates (atn);
      end EDGES;

      --
      -- DECISIONS
      --
      DECISIONS:
      declare
         ndecisions : constant Integer := data.Element (p);
         s : Integer;

         decState : DecisionState;
      begin
         p := @ + 1;
         if (ndecisions >= 1) then
            for i in 1 .. ndecisions loop
                  s := data.Element (p);
                  p := @ + 1;
                  decState := DecisionState (atn.states.Element (s));
                  atn.appendDecisionToState (decState);
                  decState.decision := i - 1;
            end loop;
         end if;
      end DECISIONS;

      --
      -- LEXER ACTIONS
      --
      LEXER_ACTIONS:
      declare
         length : Integer;
         data1, data2 : Integer;

         lexerActions : LexerAction.Container.Empty_Vector; -- := LexerAction.Container.Empty_Vector;
         actionType :  LexerActionType;
         lexerAction : LexerAction;
      begin
         if atn.grammarType = ATNType.lexer then
            length := data.Element (p);
            p := @ + 1;
            for Some_Dummy_i in 0 .. length - 1 loop
                  actionType := Value (LexerActionType (rawValue => data.Element (p))); -- !
                  p := @ + 1;
                  data1 := data.Element (p);
                  p := @ + 1;
                  data2 := data.Element (p);
                  p := @ + 1;
                  lexerAction := lexerActionFactory (actionType, data1, data2);
                  lexerActions.append (lexerAction);
            end loop;
            atn.lexerActions := lexerActions;
         end if;
      end LEXER_ACTIONS;

      finalizeATN (This, atn);
      return atn;
   end deserialize;

   function readInt (data : Integer_List; p : in out Integer) return Integer is
      result : constant Integer := data.Element (p);
   begin
      p := @ + 1;
      return result;
   end readInt;

   function Read_Unicode (P1 : Integer_List; P2 : in out Integer) return Integer; --TOFIX

   procedure readSets (data : Integer_List;
                       p : in out Integer;
                       sets : in out IntervalSet_Container.Vector;
                       readUnicode : Read_Unicode'Access) is
      nsets : constant Integer := data.Element (p);
      nintervals : Integer;
      containsEof : Integer;
      set : IntervalSet;
   begin
      p := @ + 1;
      for Some_Dummy_nSet in 0 .. nsets - 1 loop
         nintervals := data.Element (p);
         p := @ + 1;
         set := This.IntervalSet;
         sets.append (set);

         containsEof := (data.Element (p) /= 0);
         p := @ + 1;
         if containsEof then
               set.add (-1); -- try!
         end if;

         for Some_Dummy_nInterval in 0 .. nintervals - 1 loop
               set.add (readUnicode (data, p), readUnicode (data, p)); -- try!
         end loop;
      end loop;
   end readSets;

   procedure fillRuleToStopState (atn : ATN) is
      nrules : constant Ada.Container.Count_Type := atn.ruleToStartState.Length;
      stopState : ATNState;
   begin
      atn.ruleToStopState := RuleStopState_Container.To_Vector (New_Item => This.RuleStopState, Length => nrules);

      for state in atn.states loop
         stopState : Optional_RuleStopState := RuleStopState (State);
         index : Optional_Integer := stopState.ruleIndex;
         if Is_Valid (stopState) and Is_Valid (index) then
               atn.ruleToStopState.Insert (Key => index, New_Item => stopState);
               atn.ruleToStartState.Element (index).stopState := stopState;
         end loop;
      end if;
   end fillRuleToStopState;

   procedure deriveEdgesForRuleStopStates (atn : ATN) is
      length : Natural;
      t : ATNTransition;
      ruleTransition : RuleTransition;
      outermostPrecedenceReturn : Integer;
      targetRuleIndex : Integer;
      returnTransition : EpsilonTransition;
   begin
      for state in atn.states loop
         if not Is_Valid (state) then
            goto CONTINUE_STATES;
         end if;
         length := state.getNumberOfTransitions;
         for i in 0 .. length - 1 loop
               t := state.transition (i);
               ruleTransition := RuleTransition (t);
               if not Is_Valid (ruleTransition) then
                  goto CONTINUE_TRANSITIONS;
               end if;
               outermostPrecedenceReturn := -1;
               targetRuleIndex := ruleTransition.target.ruleIndex;
               if Is_Valid (targetRuleIndex) then
                  if atn.ruleToStartState.Element (targetRuleIndex).isPrecedenceRule then
                     if ruleTransition.precedence = 0 then
                           outermostPrecedenceReturn := targetRuleIndex;
                     end if;
                  end if;

                  returnTransition := EpsilonTransition (ruleTransition.followState, outermostPrecedenceReturn);
                  atn.ruleToStopState.Element (targetRuleIndex).addTransition (returnTransition);
               end if;
               <<CONTINUE_TRANSITIONS>>
         end loop;
         <<CONTINUE_STATES>>
      end loop;
   end deriveEdgesForRuleStopStates;

   procedure validateStates (atn : ATN) is
      stateStartState : Optional_BlockStartState;
      stateEndState : Optional_BlockEndState;
      loopbackState_1 : constant PlusLoopbackState;
      loopbackState_2 : constant StarLoopbackState
      length : Natural;
      target : ATNState; --TOFIX
      startState : Optional_PlusBlockStartState;
      entryState : Optional_StarLoopEntryState;
   begin
      for Some_State in atn.states loop
         stateStartState := Maybe (validateStates); --TOFIX
         if Is_Valid (stateStartState) then
               -- we need to know the end state to set its start state
               stateEndState := Maybe (Some_State.endState); --TOFIX
               if Is_Valid (stateEndState) then
                  -- block end states can only be associated to a single block start state
                  if Is_Valid (stateEndState.startState) then
                     raise ANTLRError.illegalState with "state.endState.startState /= null";
                  end if;
                  stateEndState.startState := Some_State;
               else
                  raise ANTLRError.illegalState with "state.endState = null";
               end if;
         elsif
            loopbackState_1 := PlusLoopbackState (Some_State);
            if Is_Valid (loopbackState_1) then
               length := loopbackState_1.getNumberOfTransitions;
               for i in 0 .. length - 1 loop
                  target := loopbackState_1.transition (i).target;
                  startState := Maybe (target);
                  if Is_Valid (startState) then
                     startState.loopBackState := loopbackState_1;
                  end if;
               end loop;
         elsif
            loopbackState_2 := StarLoopbackState (Some_State);
            if Is_Valid (loopbackState_2) then
               length := loopbackState_2.getNumberOfTransitions;
               for i in 0 .. length - 1 loop
                  target := loopbackState_2.transition (i).target;
                  entryState := Maybe (target);
                  if Is_Valid (entryState) then
                     entryState.loopBackState := loopbackState_2;
                  end if;
               end loop;
         end if;
      end loop;
   end validateStates;

   procedure finalizeATN (This : ATNDeserializer; atn : ATN) is
   begin
      markPrecedenceDecisions (atn);
      if This.deserializationOptions.verifyATN then
         verifyATN (atn);
      end if;
      if This.deserializationOptions.generateRuleBypassTransitions and then atn.grammarType = ATNType.parser then
         generateRuleBypassTransitions (atn);

         if This.deserializationOptions.verifyATN then
               -- reverify after modification
               verifyATN (atn);
         end if;
      end if;
   end finalizeATN;

   procedure markPrecedenceDecisions (atn : ATN) is
   begin
      for state in atn.states loop
         --
         -- We analyze the ATN to determine if this ATN decision state is the
         -- decision for the closure block that determines whether a
         -- precedence rule should continue or complete.
         --
         declare
            state : constant StarLoopEntryState := StarLoopEntryState (state);
            stateRuleIndex : constant Optional_Integer := state.ruleIndex;
            maybeLoopEndState : ATNState;
         begin
            if not (Is_Valid (state) 
            and then Is_Valid (stateRuleIndex)
            and then atn.ruleToStartState.Element (stateRuleIndex).isPrecedenceRule) then
               goto CONTINUE;
            end if;
            maybeLoopEndState := state.transition (state.getNumberOfTransitions - 1).target;
            if maybeLoopEndState is LoopEndState
            and then maybeLoopEndState.epsilonOnlyTransitions
            and then maybeLoopEndState.transition (0).target is RuleStopState then
                  state.precedenceRuleDecision := True;
            end if;
         end;
            <<CONTINUE>>
      end loop;
   end markPrecedenceDecisions;

   procedure generateRuleBypassTransitions (atn : ATN) is
      length : constant Ada.Containers.Count_Type := atn.ruleToStartState.Length;
      bypassStart : BasicBlockStartState;
      bypassStop : BlockEndState;
      endState : Optional_ATNState;
      excludeTransition : Optional_Transition;
      maybeLoopEndState : ATNState;
      transition : transition;
      matchState : BasicState;
   begin
      for i in 0 .. length - 1 loop
         atn.ruleToTokenType.Append (atn.maxTokenType + i + 1);
      end loop;

      for i in 0 .. length - 1 loop
         bypassStart := This.BasicBlockStartState;
         bypassStart.ruleIndex := i;
         atn.addState (bypassStart);

         bypassStop := This.BlockEndState;
         bypassStop.ruleIndex := i;
         atn.addState (bypassStop);

         bypassStart.endState := bypassStop
         atn.defineDecisionState (bypassStart);

         bypassStop.startState := bypassStart;

         if atn.ruleToStartState.Element (i).isPrecedenceRule then
               -- wrap from the beginning of the rule to the StarLoopEntryState
               endState := (Valid => False);
               for state of atn.states loop
                  if not Is_Valid (state)
                  or else state.ruleIndex /= i
                  or else not (state is StarLoopEntryState) then
                     goto CONTINUE_STATES;
                  end if;

                  maybeLoopEndState := state.transition (state.getNumberOfTransitions - 1).target;
                  if not (maybeLoopEndState is LoopEndState) then
                     goto CONTINUE_STATES;
                  end if;

                  if maybeLoopEndState.epsilonOnlyTransitions
                  and then maybeLoopEndState.transition (0).target is RuleStopState then
                     endState := state;
                     exit when True;
                  end if;
                  <<CONTINUE_STATES>>
               end loop;

               if not Is_Valid (endState) then
                  raise ANTLRError.unsupportedOperation with "Couldn't identify final state of the precedence rule prefix section.";
               end if;

               excludeTransition := (StarLoopEntryState (endState))?.loopBackState?.transition (0);
         else
               endState := atn.ruleToStopState.Element (i);
         end if;

         -- all non-excluded transitions that currently target end state need to target blockEnd instead
         for state in atn.states loop
               if not Is_Valid (state) then
                  goto CONTINUE;
               end if;
               for transition in state.transitions loop
                  if transition === excludeTransition! then
                     goto CONTINUE;
                  end if;

                  if transition.target = endState then
                     transition.target := bypassStop;
                  end if;
               end loop;
            <<CONTINUE>>
         end loop;

         -- all transitions leaving the rule start state need to leave blockStart instead
         while atn.ruleToStartState.Element (i).getNumberOfTransitions > 0 loop
               transition := atn.ruleToStartState.Element (i).removeTransition (atn.ruleToStartState.Element (i).getNumberOfTransitions - 1);
               bypassStart.addTransition (transition);
         end loop;

         -- link the new states
         atn.ruleToStartState.Element (i).addTransition (EpsilonTransition (bypassStart));
         bypassStop.addTransition (EpsilonTransition (endState!));

         matchState := This.BasicState;
         atn.addState (matchState);
         matchState.addTransition (AtomTransition (bypassStop, atn.ruleToTokenType.Element (i)));
         bypassStart.addTransition (EpsilonTransition (matchState));
      end loop;
   end generateRuleBypassTransitions;

   procedure verifyATN (atn : ATN) is
   begin
      -- verify assumptions
      for state in atn.states loop
         if not Is_Valid (state) then
               goto CONTINUE;
         end if;

         checkCondition (state.onlyHasEpsilonTransitions or else state.getNumberOfTransitions <= 1);

         state : constant Optional_PlusBlockStartState := Maybe (state);
         if Is_Valid (state) then
               checkCondition (Is_Valid (state.loopBackState));
         end if;

         starLoopEntryState : constant Optional_StarLoopEntryState := Maybe (state);
         if Is_Valid (starLoopEntryState) then
               checkCondition (Is_Valid (starLoopEntryState.loopBackState));
               checkCondition (starLoopEntryState.getNumberOfTransitions = 2);

               if starLoopEntryState.transition (0).target is StarBlockStartState then
                  checkCondition (starLoopEntryState.transition (1).target is LoopEndState);
                  checkCondition (not starLoopEntryState.nonGreedy);
               else
                  if starLoopEntryState.transition (0).target is LoopEndState then
                     checkCondition (starLoopEntryState.transition (1).target is StarBlockStartState);
                     checkCondition (starLoopEntryState.nonGreedy);
                  else
                     raise ANTLRError.illegalState with "IllegalStateException";
                  end if;
               end if;
         end if;

         state : constant Optional_StarLoopbackState := Maybe (state);
         if Is_Valid (state) then
               checkCondition (state.getNumberOfTransitions = 1);
               checkCondition (state.transition (0).target is StarLoopEntryState);
         end if;

         if state is LoopEndState then
               checkCondition (Is_Valid ((LoopEndState (state)).loopBackState));
         end if;

         if state is RuleStartState then
               checkCondition (Is_Valid ((RuleStartState (state)).stopState));
         end if;

         if state is BlockStartState then
               checkCondition (Is_Valid ((BlockStartState (state)).endState));
         end if;

         if state is BlockEndState then
               checkCondition (Is_Valid ((BlockEndState (state)).startState));
         end if;

         decisionState : constant Optional_DecisionState := Maybe (state);
         if Is_Valid (decisionState) then
               checkCondition (decisionState.getNumberOfTransitions <= 1 or else decisionState.decision >= 0);
         else
               checkCondition (state.getNumberOfTransitions <= 1 or else state is RuleStopState);
         end if;
         <<CONTINUE>>
      end loop;
   end verifyATN;

   procedure checkCondition (condition  : Boolean) is
   begin
      checkCondition (condition, (Valid => False));
   end checkCondition;

   procedure checkCondition (condition : Boolean; message : Optional_UString) is
   begin
      if not condition then
         raise ANTLRError.illegalState with Value (message , Default => "");
      end if;
   end checkCondition;

   procedure edgeFactory (atn : ATN;
                          Token_Type : Token_Kind;
                          src : Integer;
                          trg : Integer;
                          arg1 : Integer;
                          arg2 : Integer;
                          arg3 : Integer;
                          sets : IntervalSet_List)
                          return Transition is
      target : constant := atn.states.Element (trg)!;
   begin
      case Token_Type is
         when Transition.EPSILON => return EpsilonTransition (target);
         when TRANSITION_RANGE =>
               if arg3 /= 0 then
                  return RangeTransition (target, CommonToken.EOF, arg2);
               else
                  return RangeTransition (target, arg1, arg2);
               end if;
         when Transition.RULE =>
               rt : constant RuleStartState := RuleStartState (RuleTransition (atn.states.Element (arg1)), arg2, arg3, target);
               return rt
         when Transition.PREDICATE =>
               pt : constant := PredicateTransition (target, arg1, arg2, arg3 /= 0);
               return pt;
         when Transition.PRECEDENCE =>
               return PrecedencePredicateTransition (target, arg1);
         when Transition.ATOM =>
               if arg3 /= 0 then
                  return AtomTransition (target, CommonToken.EOF);
               else
                  return AtomTransition (target, arg1);
               end if;
         when Transition.ACTION =>
               return ActionTransition (target, arg1, arg2, arg3 /= 0);

         when Transition.SET => return SetTransition (target, sets.Element (arg1));
         when Transition.NOT_SET => return NotSetTransition (target, sets.Element (arg1));
         when Transition.WILDCARD => return WildcardTransition (target);
         when others =>
               raise ANTLRError.illegalState with "The specified transition type is not valid.";
      end case;
   end edgeFactory;

   function stateFactory (State : ATNState.State; ruleIndex : Integer) return Optional_ATNState is
         s : ATNStates.State;
   begin
      case state is
         when ATNState.INVALID_TYPE => return (Valid => False);
         when ATNState.BASIC => s := This.BasicState;
         when ATNState.RULE_START => s := This.RuleStartState;
         when ATNState.BLOCK_START => s := This.BasicBlockStartState;
         when ATNState.PLUS_BLOCK_START => s := This.PlusBlockStartState;
         when ATNState.STAR_BLOCK_START => s := This.StarBlockStartState;
         when ATNState.TOKEN_START => s := This.TokensStartState;
         when ATNState.RULE_STOP => s := This.RuleStopState;
         when ATNState.BLOCK_END => s := This.BlockEndState;
         when ATNState.STAR_LOOP_BACK => s := This.StarLoopbackState;
         when ATNState.STAR_LOOP_EN=> s := This.StarLoopEntryState;
         when ATNState.PLUS_LOOP_BACK => s := This.PlusLoopbackState;
         when ATNState.LOOP_END => s := This.LoopEndState;
         when others =>
               message : constant UString := "The specified state type " & ATNState.State'Image & " is not valid.";

               raise ANTLRError.illegalArgument with message;
      end case;

      s.ruleIndex := ruleIndex;
      return s;
   end stateFactory;

   function lexerActionFactory (ActionType : LexerActionType; data1, data2 : Integer) return LexerAction is
   begin
      case ActionType is
         when channel =>
               return LexerChannelAction (data1);

         when custom =>
               return LexerCustomAction (data1, data2);

         when mode =>
               return LexerModeAction (data1);

         when more =>
               return LexerMoreAction.INSTANCE;

         when popMode =>
               return LexerPopModeAction.INSTANCE;

         when pushMode =>
               return LexerPushModeAction (data1);

         when skip =>
               return LexerSkipAction.INSTANCE;

         when type_action =>
               return LexerTypeAction (data1);
      end case;
   end lexerActionFactory;

end ANTLR.Runtime.ATN.Deserializers;
