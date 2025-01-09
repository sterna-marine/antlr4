-- €

with ANTLR.Runtime.Misc.Exceptions.Errors;

use ANTLR.Runtime.Misc.Exceptions.Errors;

package body ANTLR.Runtime.ATN.ConfigSets is

   procedure Initialize (Self : in out ATNConfigSet;
                   fullCtx  : Boolean := True;
                   isOrdered : Boolean := False) is
   begin
      if isOrdered then
         Self.configLookup :=  LookupDictionary.Init (Type_of_LookupDictionary => LookupDictionaryType.ordered);
      else
         Self.configLookup :=  LookupDictionary.Init;
      end if;
      self.fullCtx := fullCtx;
   end Initialize;

   overriding
   function add (This : in out ATNConfigSet; config : ATNConfig) return Boolean is
      mergeCache : PredictionContext.Optional_DoubleKeyMap; --  := (Valid => False) / Empty_Map by default;
   begin
      return This.add (config, mergeCache);
   end add;

   function add (This : in out ATNConfigSet;
                 config : ATNConfig;
                 mergeCache : in out PredictionContext.Optional_DoubleKeyMap)
                 return Boolean is
      existing : ATNConfig;
      merged : PredictionContext;
   begin
      if This.readonly then
         raise ANTLRError.illegalState with "This set is readonly";
      end if;
      if config.semanticContext /= This.SemanticContext.Empty.Instance then
            This.hasSemanticContext := True;
      end if;
      if config.getOuterContextDepth > 0 then
            This.dipsIntoOuterContext := True;
      end if;

      existing := This.getOrAdd (config);
      if existing === config then
            -- we added this new one
            cachedHashCode := -1;
            This.configs.append (config);  -- track order here
            return True;
      end if;
      -- a previous (s,i,pi,_), merge with it and save result
      rootIsWildcard : constant Boolean := not This.fullCtx;

      merged := PredictionContext.merge (
            a => Value (existing.context),
            b => Value (config.context),
            rootIsWildcard => rootIsWildcard,
            mergeCache => mergeCache);

      -- no need to check for existing.context, config.context in cache
      -- since only way to create new graphs is "call rule" and here. We
      -- cache at both places.
      existing.reachesIntoOuterContext :=
            max (existing.reachesIntoOuterContext, config.reachesIntoOuterContext);

      -- make sure to preserve the precedence filter suppression during the merge
      if config.isPrecedenceFilterSuppressed then
            existing.setPrecedenceFilterSuppressed (True);
      end if;

      existing.context := merged -- replace context; no need to alt mapping
      return True;
   end add;

   function getStates (This : ATNConfigSet) return Set_of_ATNStates is
      states : Set_of_ATNStates; -- (minimumCapacity => configs.count);
   begin
      for config of This.configs loop
         states.insert (config.state);
      end loop;
      return states;
   end getStates;

   function getAlts (This : ATNConfigSet) return BitSet is
      alts : constant := BitSet;
   begin
      for config of This.configs loop
         alts.set (config.alt); -- try!
      end loop;
      return alts;
   end getAlts;

   function getPredicates (This : ATNConfigSet) return SemanticContext_List is
      preds : SemanticContext_List;
   begin
      for config of This.configs loop
         if config.semanticContext /= SemanticContext.Empty.Instance then
               preds.append (config.semanticContext);
         end if;
      end loop;
      return preds;
   end getPredicates;

   procedure optimizeConfigs (This : ATNConfigSet; interpreter : ATNSimulator) is
   begin
      if This.readonly then
         raise ANTLRError.illegalState with "This set is readonly";
      end if;
      if configLookup.isEmpty then
         exit;
      end if;
      for config of This.configs loop
         config.context := interpreter.getCachedContext (Value (config.context)); --TOFIX
      end loop;
   end optimizeConfigs;

   function addAll (This : ATNConfigSet; coll : ATNConfigSet) return Boolean is
   begin
      for c of coll.configs loop
         This.add (c);
      end loop;
      return False;
   end addAll;

   procedure hash (This : ATNConfigSet; hasher : in out Hasher) is
   begin
      if This.isReadonly then
         if This.cachedHashCode = -1 then
               This.cachedHashCode := configsHashValue;
         end if;
         hasher.combine (This.cachedHashCode);
      else
         hasher.combine (configsHashValue);
      end if;
   end if;

   function configshashValue return Ada.Containers.Hash_Type is
      hashCode : Ada.Containers.Hash_Type := 1;
   begin
      for item of This.configs loop
         --  hashCode := hashCode &* 3 &+ item.hashValue;
         hashCode := hashCode * 3 + item.hashValue;  --TOFIX
      end loop;
      return hashCode
   end configshashValue;

   procedure clear (This : ATNConfigSet) is
   begin
      if This.readonly then
         raise ANTLRError.illegalState with "This set is readonly";
      end if;
      This.configs.removeAll;
      This.cachedHashCode := -1;
      This.configLookup.removeAll;
   end clear;

   procedure setReadonly (This : ATNConfigSet; readonly  : Boolean) is
   begin
      This.readonly := readonly;
      This.configLookup.removeAll;
   end setReadonly;

   subtype Sink is Ada.Strings.Text_Buffers.Root_Buffer_Type;
   procedure Put_Image_ATNConfigSet (S : in out Sink'Class; X : ATNConfigSet);
   for ATNConfigSet'Put_Image use Put_Image_ATNConfigSet;
   function Description (This : ATNConfigSet) return UString is
      buf : UString; -- := "";
   begin
      buf := @ & UString (describing => This.elements);
      if This.hasSemanticContext then
         buf := @ & ",hasSemanticContext=True";
      end if;
      if This.uniqueAlt /= ATN.INVALID_ALT_NUMBER then
         buf := @ & ",uniqueAlt=" & uniqueAlt'Image;
      end if;
      if Is_Valid (This.conflictingAlts) then
         buf := @ & ",conflictingAlts=" & This.conflictingAlts'Image;
      end if;
      if This.dipsIntoOuterContext then
         buf := @ & ",dipsIntoOuterContext";
      end if;
      return buf;
   end Image;

   function configHash (This : ATNConfigSet;
                        stateNumber : ATNStates.State;
                        context : Optional_PredictionContext)
                        return Ada.Containers.Hash_Type is
      hashCode : Ada.Containers.Hash_Type;
   begin
      hashCode := MurmurHash.initialize (7);
      hashCode := MurmurHash.update (hashCode, stateNumber);
      hashCode := MurmurHash.update (hashCode, context);
      return MurmurHash.finish (hashCode, 2);
   end configHash;

   function getConflictingAltSubsets (This : ATNConfigSet) return BitSet_Map is
      configToAlts : BitSet_Map;
      hash : Ada.Containers.Hash_Type;
      alts : BitSet;
   begin
      for cfg of This.configs loop
         hash := configHash (cfg.state.stateNumber, cfg.context);
         configToAlt := configToAlts.Element (hash);
         if configToAlt then --TOFIX
            alts := configToAlt;
         else
            alts := This.BitSet;
            configToAlts.Insert (Key => hash, New_Item => alts);
         end if;

         alts.set (cfg.alt); -- try!
      end loop;

      return Array (configToAlts.values);
   end getConflictingAltSubsets;

   function getStateToAltMap (This : ATNConfigSet) return BitSet_Map is
      m : BitSet_Map;
      alts : BitSet;
   begin
      for cfg of configs loop
         mAlts : constant :=  m.Element (cfg.state.stateNumber);
         if mAlts then
            alts := mAlts;
         else
            alts := This.BitSet;
            m.Insert (Key => cfg.state.stateNumber, New_Item => alts);
         end if;

         alts.set (cfg.alt); -- try!
      end loop;
      return m;
   end getStateToAltMap;

   function getAltSet (This : ATNConfigSet) return Set_of_Optional_Integers is
   begin
      if This.configs.isEmpty then
         return (Valid => False);
      else
         alts := This.Set_of_Optional_Integers;
         for config of This.configs loop
            alts.insert (config.alt);
         end loop;
         return alts;
      end if;
   end getAltSet;

   function getAltBitSet (This : ATNConfigSet) return BitSet is
      result : constant := This.BitSet;
   begin
      for config of This.configs loop
         result.set (config.alt); -- try!
      end loop;
      return result
   end getAltBitSet;

   function firstConfigWithRuleStopState return Optional_ATNConfig is
   begin
      for config of This.configs loop
         if config.state is RuleStopState then
               return config;
         end if;
      end loop;
      return (Valid => False);
   end firstConfigWithRuleStopState;

   function getUniqueAlt (This : ATNConfigSet) return Integer is
      alt : Integer;
   begin
      alt := ATN.INVALID_ALT_NUMBER;
      for config of This.configs loop
         if alt = ATN.INVALID_ALT_NUMBER then
            alt := config.alt -- found first alt;
         elsif config.alt /= alt then
            return ATN.INVALID_ALT_NUMBER;
         end if;
      end loop;
      return alt
   end getUniqueAlt;

   function removeAllConfigsNotInRuleStopState (This : ATNConfigSet;
                                                mergeCache : in out PredictionContext.Optional_DoubleKeyMap;
                                                lookToEndOfRule : Boolean;
                                                atn : ATN)
                                                return ATNConfigSet is
   begin
      if PredictionModes.allConfigsInRuleStopStates (This) then
         return This;
      else
         result : constant := ATNConfigSet (fullCtx);
         for config of This.configs loop
            if config.state is RuleStopState then
               result.add (config, mergeCache); -- try!
               goto CONTINUE_CONFIGS;
            end if;

            if lookToEndOfRule and then config.state.onlyHasEpsilonTransitions then
               nextTokens : constant := atn.nextTokens (config.state);
               if nextTokens.contains (CommonToken.EPSILON) then
                  endOfRuleState : constant := atn.ruleToStopState[config.state.ruleIndex!]
                  result.add (ATNConfig (config, endOfRuleState), mergeCache); -- try!
               end if;
            end if;
            <<CONTINUE_CONFIGS>>
         end loop;
         return result;
      end if;
   end removeAllConfigsNotInRuleStopState;

   function applyPrecedenceFilter (This : ATNConfigSet;
                                   mergeCache : in out PredictionContext.Optional_DoubleKeyMap;
                                   parser : Parser;
                                   outerContext : ParserRuleContext)
                                   return ATNConfigSet is
      configSet : constant := ATNConfigSet (fullCtx);
      statesFromAlt1 : PredictionContext.Map;
   begin
      for config of This.configs loop
         -- handle alt 1 first
         if config.alt /= 1 then
               goto CONTINUE_CONFIGS;
         end if;

         updatedContext : constant := config.semanticContext.evalPrecedence (parser, outerContext);
         if not Is_Valid (updatedContext) then
               -- the configuration was eliminated
               goto CONTINUE_CONFIGS;
         end if;

         statesFromAlt1.Insert (Key => config.state.stateNumber, New_Item => config.context);
         if updatedContext /= config.semanticContext then
               configSet.add (ATNConfig (config, updatedContext!), mergeCache); -- try!
         else
               configSet.add (config, mergeCache); -- try!
         end if;
         <<CONTINUE_CONFIGS>>
      end loop;

      for config of This.configs loop
         if config.alt = 1 then
               -- already handled
               goto CONTINUE;
         end if;

         if not config.isPrecedenceFilterSuppressed then
               --
               -- In the future, this elimination step could be updated to also
               -- filter the prediction context for alternatives predicting alt>1
               -- (basically a graph subtraction algorithm).
               --
               context : constant := statesFromAlt1.Element (config.state.stateNumber);
               if Is_Valid (context) and then context = config.context then 
               --TOFIX if statesFromAlt1.Has_Element then
                  --TOFIX context : constant := statesFromAlt1.Element (config.state.stateNumber);
                  --TOFIX if context = config.context then
                     -- eliminated
                     goto CONTINUE;
                  --TOFIX end if;
               end if;
         end if;

         configSet.add (config, mergeCache); -- try!
         <<CONTINUE>>
      end loop;

      return configSet;
   end applyPrecedenceFilter;

   function getPredsForAmbigAlts (ambigAlts : BitSet; nalts : Integer) return Optional_SemanticContext_Container.Vector is -- ]?
      altToPred : SemanticContext_Container.Vector := SemanticContext_Container.To_Vector (New_Item => null, Length => nalts + 1);
      for config of This.configs loop
         if ambigAlts.get (config.alt) then -- try!
               altToPred.Insert (Key => config.alt, New_Item => SemanticContext.or (altToPred.Element (config.alt), config.semanticContext));
         end if;
      end loop;
      nPredAlts := 0;
      for i in 1 .. nalts loop
         if not Is_Valid (altToPred.Element (i)) then
               altToPred.Insert (Key => i, New_Item => SemanticContext.Empty.Instance);
         elsif altToPred.Element (i) /= SemanticContext.Empty.Instance then
               nPredAlts := @ + 1;
         end if;
      end loop;

      --      -- Optimize away p or p and p and p TODO: This.optimize was a no-op
      --      for i in 0 .. altToPred.length - 1 loop
      --         altToPred.Insert (Key => i, New_Item => altToPred.Element (i).optimize);
      --       i := @ + 1;
      --      end loop;

      -- nonambig alts are null in altToPred
      return (if nPredAlts = 0 then
               return Optional_SemanticContext_Container.Empty_Vector; --null
               else return altToPred);
   end getPredsForAmbigAlts;

   function getAltThatFinishedDecisionEntryRule (This : ATNConfigSet) return Integer is
      alts : constant IntervalSet := This.IntervalSet;
   begin
      for config of This.configs loop
         if config.getOuterContextDepth > 0
         or else (config.state is RuleStopState and config.context!.hasEmptyPath) then
            alts.add (config.alt); -- try!
         end if;
      end loop;
      if alts.size = 0 then
         return ATN.INVALID_ALT_NUMBER;
      end if;
      return alts.getMinElement;
   end getAltThatFinishedDecisionEntryRule;

   function evalSemanticContext (P1 : SemanticContext;
                                 P2 : ParserRuleContext;
                                 P3 : Integer;
                                 P4 : Boolean)
                                 return Boolean;
   type evalSemanticContext_Access is evalSemanticContext'Access;

   function splitAccordingToSemanticValidity (This : ATNConfigSet;
                                              outerContext : ParserRuleContext;
                                              evalSemanticContext : evalSemanticContext_Access) --TOFIX
                                              return Splitted_ConfigSets is
      Pair_of_ConfigSets : Splitted_ConfigSets := (
         succeeded => ATNConfigSet (fullCtx),
         failed => ATNConfigSet (fullCtx));
   begin
      for config of This.configs loop
         if config.semanticContext /= SemanticContext.Empty.Instance then
            predicateEvaluationResult : constant Boolean := evalSemanticContext (config.semanticContext, outerContext, config.alt,fullCtx);
            if predicateEvaluationResult then
               Pair_of_ConfigSets.Succeeded.add (config); -- try!
            else
               Pair_of_ConfigSets.Failed.add (config); -- try!
            end if;
         else
            Pair_of_ConfigSets.succeeded.add (config); -- try!
         end if;
      end loop;
      return Pair_of_ConfigSets;
   end splitAccordingToSemanticValidity;

   function dupConfigsWithoutSemanticPredicates (This : ATNConfigSet) return ATNConfigSet is
      dup : constant ATNConfigSet := This.ATNConfigSet;
   begin
      for config of This.configs loop
         c : constant := ATNConfig (config, SemanticContext.Empty.Instance);
         dup.add (c); -- try!
      end loop;
      return dup;
   end dupConfigsWithoutSemanticPredicates;

   function hasConfigInRuleStopState (This : ATNConfigSet) return Boolean is

      RuleStopState_Found : Boolean := False;

      function Check_RuleStopState (At_Cursor : configs.Cursor) is
      begin
         if Element (At_Cursor).state is RuleStopState then
            RuleStopState_Found := True;
         end if;
      end Check_RuleStopState;

   begin
      for At_Cursor in configs.Iterate loop
         if Check_RuleStopState (At_Cursor) then
            exit; -- RuleStopState_Found !
         end loop;
      return RuleStopState_Found;
   end hasConfigInRuleStopState;

   function allConfigsInRuleStopStates return Boolean is

      RuleStopState_Found : Boolean := False;

      function Check_RuleStopState (At_Cursor : configs.Cursor) is
      begin
         if Element (At_Cursor).state is RuleStopState then
            RuleStopState_Found := True;
         else
            RuleStopState_Found := False;
         end if;
      end Check_RuleStopState;

   begin
      for At_Cursor in configs.Iterate loop
         if not Check_RuleStopState (At_Cursor) then
            exit; -- some state is not a RuleStopState !
         end loop;
      return RuleStopState_Found;
   end allConfigsInRuleStopStates;

   function "=" (Lhs, Rhs : ATNConfigSet) return Boolean is
   begin
      --  if lhs === rhs then
      --     return True;
      --  end if;

      return
         lhs.configs = rhs.configs and then -- includes stack context
         lhs.fullCtx = rhs.fullCtx and then
         lhs.uniqueAlt = rhs.uniqueAlt and then
         lhs.conflictingAlts = rhs.conflictingAlts and then
         lhs.hasSemanticContext = rhs.hasSemanticContext and then
         lhs.dipsIntoOuterContext = rhs.dipsIntoOuterContext
   end "=";

end ANTLR.Runtime.ATN.ConfigSets;
