-- €

package body ANTLR.Runtime.ATN.PredictionModes is

   function hasSLLConflictTerminatingPrediction (mode : PredictionMode; configs : ATNConfigSet) return Boolean is
      --TOFIX configs := configs;
      altsets : BitSet_List;
      heuristic : Boolean;
   begin
      --
      -- Configs in rule stop states indicate reaching the end of the decision
      -- rule (local context) or end of start rule (full context). If all
      -- configs meet this condition, then none of the configurations is able
      -- to match additional input so we terminate prediction.
      --
      if allConfigsInRuleStopStates (configs) then
         return True;
      end if;

      -- pure SLL mode parsing
      if mode = PredictionModes.SLL then
         -- Don't bother with combining configs from different semantic
         -- contexts if we can fail over to full LL; costs more time
         -- since we'll often fail over anyway.
         if configs.hasSemanticContext then
               -- dup configs, tossing out semantic predicates
               configs := configs.dupConfigsWithoutSemanticPredicates ();
         end if;
         -- now we have combined contexts for configs with dissimilar preds
      end if;

      -- pure SLL or combined SLL+LL mode parsing

      altsets := getConflictingAltSubsets (configs);

      heuristic := hasConflictingAltSet (altsets) and then not hasStateAssociatedWithOneAlt (configs);
      return heuristic;
   end hasSLLConflictTerminatingPrediction;

   function hasNonConflictingAltSet (altsets : BitSet_List) return Boolean is
   begin
      for alts of altsets loop
         if alts.cardinality () = 1 then
            return True;
         end if;
      end loop;
      return False;
   end hasNonConflictingAltSet;

   function hasConflictingAltSet (altsets : BitSet_List) return Boolean is
   begin
      for alts of altsets loop
         if alts.cardinality () > 1 then
            return True;
         end if;
      end loop;
      return False;
   end hasConflictingAltSet;

   function allSubsetsEqual (altsets : BitSet_List) return Boolean is
      first : constant BitSet := altsets.Element (0);
   begin
      for it of altsets loop
         if it /= first then
            return False;
         end if;
      end loop;
      return True;
   end allSubsetsEqual;

   function getUniqueAlt (altsets : BitSet_List) return Integer is
      All_BitSet : constant BitSet := getAlts (altsets);
   begin
      if All_BitSet.cardinality () = 1 then
         return All_BitSet.firstSetBit ();
      end if;
      return ATN.INVALID_ALT_NUMBER;
   end getUniqueAlt;

   function getAlts (altsets : BitSet_List) return BitSet is
      All_BitSet : constant BitSet := This.BitSet;
   begin
      for alts of altsets loop
         All_BitSet.or (alts);
      end if;
      return All_BitSet;
   end getAlts;

   function hasStateAssociatedWithOneAlt (configs : ATNConfigSet) return Boolean is
      x : constant BitSet_Map := configs.getStateToAltMap;
   begin
      for alts of x.values loop
         if alts.cardinality () = 1 then
            return True;
         end if;
      end loop;
      return False;
   end hasStateAssociatedWithOneAlt;

   function getSingleViableAlt (altsets : BitSet_List) return Integer is
      viableAlts : constant BitSet := This.BitSet;
      minAlt : Integer;
   begin
      for alts of altsets loop
         minAlt := alts.firstSetBit ();
         viableAlts.set (minAlt); -- try!
         if viableAlts.cardinality () > 1 then
            -- more than 1 viable alt
            return ATN.INVALID_ALT_NUMBER;
         end if;
      end loop;
      return viableAlts.firstSetBit ();
   end getSingleViableAlt;

end ANTLR.Runtime.ATN.PredictionModes;
