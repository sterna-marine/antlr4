-- €

with Ada.Wide_Wide_Text_IO;
with Aspect;

use Ada;
use Aspect;

package body ANTLR.Runtime.ATN.LL1Analyzer is

   procedure Initialize (Self : in out LL1Analyzer; atn : ATN) is
   begin
      self.atn := atn;
   end Initialize;

   function getDecisionLookahead (This : LL1Analyzer; s : Optional_ATNState) return Optional_IntervalSet_List is --?]? 
      length : Natural; -- constant
      look : Optional_IntervalSet_List;
      lookBusy : Set_of_ATNConfigs;
   begin
      if not Is_Valid (s) then
            return (Valid => False);
      else
         length := s.getNumberOfTransitions ();
         look   := Optional_IntervalSet.Container.To_Vector (New_Item => (Valid => False), Length => length);  --TOFIX
         for alt in 0 .. length - 1 loop  --TOFIX
            look.Update_Element (Key => alt, New_Item => This.IntervalSet); --TOFIX
            lookBusy := ATNConfigs_Sets.Empty_Set;
            seeThruPreds : constant := False; -- fail to get lookahead upon pred
            This_LOOK (This => This,
                        s => s.transition (alt).target,
                        stopState => (Valid => False),
                        ctx => EmptyPredictionContext.Instance,
                        look => Value (look.Element (alt)),
                        lookBusy => lookBusy,
                        calledRuleStack => This.BitSet,
                        seeThruPreds => seeThruPreds,
                        addEOF  => False);
            -- Wipe out lookahead for this alternative if we found nothing
            -- or we had a predicate when we not seeThruPreds
            if look.Element (alt)!.size () = 0
            or else look.Element (alt)!.contains (This.HIT_PRED) then
               look.Update_Element (Key => alt, New_Item => null);
            end if;
         end loop;
         return look;
      end if;
   end getDecisionLookahead;

   function LOOK (This : LL1Analyzer;
                  s : ATNState;
                  stopState : Optional_ATNState;
                  ctx : Optional_RuleContext)
                  return IntervalSet is
      lookContext : Optional_RuleContext;
      r : constant := This.IntervalSet;
      config : Set_of_ATNConfigs;
      seeThruPreds : constant Boolean := True; -- ignore preds; get all lookahead
   begin
      if Is_Valid (ctx) then
         lookContext := PredictionContext.fromRuleContext (s.atn!, ctx);
      else
         lookContext := (Valid => False);
      end if;
      This_LOOK (This => This,
                  s => s,
                  stopState => stopState,
                  ctx => lookContext,
                  look => r,
                  lookBusy => config,
                  calledRuleStack => This.BitSet,
                  seeThruPreds => seeThruPreds,
                  addEOF  => True);
      return r;
   end LOOK;

   procedure This_LOOK (This : LL1Analyzer;
                        s : ATNState;
                        stopState : Optional_ATNState;
                        ctx : Optional_PredictionContext;
                        look : IntervalSet;
                        lookBusy : in out Set_of_ATNConfigs;
                        calledRuleStack : BitSet;
                        seeThruPreds : Boolean;
                        addEOF  : Boolean) is
      c : constant ATNConfig := ATNConfig (s, ATN.INVALID_ALT_NUMBER, ctx);
   begin
      if Is_Active (Aspect.DEBUG) then
         Wide_Wide_Text_IO.Put_Line ("This_LOOK (" & s.stateNumber'Image & ", ctx=" & ctx'Image & ')');
      end if;

      if lookBusy.Contains (c) then
         return;
      else
         lookBusy.insert (c);
      end if;

      if s = stopState then
         if not Is_Valid (ctx) then
            look.add (CommonToken.EPSILON); -- try!
            return;
         end if;

         if ctx.isEmpty () and then addEOF then
            look.add (CommonToken.EOF); -- try!
            return;
         end if;
      end if;

      if s is RuleStopState then
         if not Is_Valid (ctx) then
            look.add (CommonToken.EPSILON); -- try!
            return;
         end if;

         if ctx.isEmpty () and then addEOF then
            look.add (CommonToken.EOF); -- try!
            return;
         end if;

         if ctx /= EmptyPredictionContext.Instance then
            removed : constant := calledRuleStack.get (s.ruleIndex!); -- try!
            calledRuleStack.clear (s.ruleIndex!); -- try!
            -- run thru all possible stack tops in ctx
            length : constant := ctx.size ();
            for i in 0 .. length - 1 loop
               returnState : constant ATNState := Value (This.atn.states.Element (ctx.getReturnState (i)));
               This_LOOK (This => This,
                           s => returnState,
                           stopState => stopState,
                           ctx => ctx.getParent (i),
                           look => look,
                           lookBusy => lookBusy,
                           calledRuleStack => calledRuleStack,
                           seeThruPreds => seeThruPreds,
                           addEOF  => addEOF);
            end loop;
            defer:
               begin
                  if removed then
                        calledRuleStack.set (s.ruleIndex!); -- try!
                  end if;
               end defer;
            return;
         end if;
      end if;

      n : constant := s.getNumberOfTransitions ();
      for i in 0 .. n - 1 loop
         t : constant := s.transition (i);
         rt : constant Optional_RuleTransition := Maybe (t);
         if Is_Valid (rt) then
            if calledRuleStack.get (rt.target.ruleIndex!) then -- try!
               goto CONTINUE;
            end if;

            newContext : constant := SingletonPredictionContext.create (ctx, rt.followState.stateNumber);
            calledRuleStack.set (rt.target.ruleIndex!); -- try!
            This_LOOK (This => This,
                        s => t.target,
                        stopState => stopState,
                        ctx => newContext,
                        look => look,
                        lookBusy => lookBusy,
                        calledRuleStack => calledRuleStack,
                        seeThruPreds => seeThruPreds,
                        addEOF  => addEOF);
            calledRuleStack.clear (rt.target.ruleIndex!); -- try!
         elsif t is AbstractPredicateTransition then
            if seeThruPreds then
               This_LOOK (This => This,
                           s => t.target,
                           stopState => stopState,
                           ctx => ctx,
                           look => look,
                           lookBusy => lookBusy,
                           calledRuleStack => calledRuleStack,
                           seeThruPreds => seeThruPreds,
                           addEOF  => addEOF);
            else
               look.add (This.HIT_PRED); -- try!
            end if;
         elsif t.isEpsilon () then
            This_LOOK (This => This,
                        s => t.target,
                        stopState => stopState,
                        ctx => ctx,
                        look => look,
                        lookBusy => lookBusy,
                        calledRuleStack => calledRuleStack,
                        seeThruPreds => seeThruPreds,
                        addEOF  => addEOF);
         elsif t is WildcardTransition then
            look.addAll (IntervalSet.of (CommonToken.MIN_USER_TOKEN_TYPE, This.atn.maxTokenType)); -- try!
         else
            set := t.labelIntervalSet ();
            if Is_Valid (set) then
               if t is NotSetTransition then
                  set := set!.complement (IntervalSet.of (CommonToken.MIN_USER_TOKEN_TYPE, Optional_IntervalSet ( This.atn.maxTokenType)));
               end if;
               look.addAll (set); -- try!
            end if;
         end if;
      end loop;
   end This_LOOK;

end ANTLR.Runtime.ATN.LL1Analyzer;
