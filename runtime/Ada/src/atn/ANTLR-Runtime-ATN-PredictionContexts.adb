-- €

with Ada.Wide_Wide_Text_IO;
with Aspect;

use Ada;
use Aspect;

package body ANTLR.Runtime.ATN.PredictionContexts is

   -- private static
   INITIAL_HASH : constant Hash_code := 1;

   protected body globalNodeCount is

      procedure New_ID is
      begin
         ID := @ + 1;
      end New_ID;

      function Last_ID return Context_ID
         is (ID);
      function Count return Context_ID
         is (ID + 1);

   end globalNodeCount;


   procedure Initialize (Self : PredictionContext; cachedHashCode : Hash_code) is
   begin
      self.cachedHashCode := cachedHashCode;
   end Initialize;

   function fromRuleContext (atn : ATN; outerContext : Optional_RuleContext) return PredictionContext is
   begin
     Some_outerContext : constant := outerContext, Default => ParserRuleContext.EMPTY

      -- if we are in RuleContext of start rule, s, then PredictionContext
      -- is EMPTY. Nobody called us. (if we are empty, return empty);
      if (not Is_Valid (Some_outerContext.parent) or else Some_outerContext === ParserRuleContext.EMPTY) then
            return EmptyPredictionContext.Instance;
      end if;

      -- If we have a parent, convert it to a PredictionContext graph
      parent : constant := PredictionContext.fromRuleContext (atn, Some_outerContext.parent);

      state : constant := Value (atn.states.Element (Some_outerContext.invokingState));
      transition : constant RuleTransition := RuleTransition (state.transition (0));
      return SingletonPredictionContext.create (parent, transition.followState.stateNumber);
   end fromRuleContext;

   function size (This : PredictionContext) return Integer with No_Return is
   begin
      raise PROGRAM_ERROR with "ANTLR.Runtime.ATN.PredictionContext.size() must be overridden";
   end size;

   function getParent (This : PredictionContext; index : Integer) return Optional_PredictionContext with No_Return is
   begin
      raise PROGRAM_ERROR with "ANTLR.Runtime.ATN.PredictionContext.getParent() must be overridden";
   end getParent;

   function getReturnState (This : PredictionContext; index : Integer) return ATNStates.State with No_Return is
   begin
      raise PROGRAM_ERROR with "ANTLR.Runtime.ATN.PredictionContext.getReturnState() must be overridden";
   end getReturnState;

   function isEmpty (This : PredictionContext) return Boolean
      is This === EmptyPredictionContext.Instance;

   function hasEmptyPath (This : PredictionContext) return Boolean
      is (getReturnState (Last_ID) = EMPTY_RETURN_STATE);

   procedure hash (This : PredictionContext; hasher: in out Hasher) is
   begin
      hasher.combine (cachedHashCode);
   end hash;

   function calculateEmptyHashCode (This : PredictionContext) return Hash_Code is
      hash : constant Hash_Code := MurmurHash.initialize (INITIAL_HASH);
   begin
      return MurmurHash.finish (hash, 0);
   end calculateEmptyHashCode;

   function calculateHashCode (parent : Optional_PredictionContext; returnState : ATStates.State) return Hash_Code is
      hash : Hash_Code;
   begin
      hash := MurmurHash.initialize (INITIAL_HASH);
      hash := MurmurHash.update (hash, parent);
      hash := MurmurHash.update (hash, returnState);
      return MurmurHash.finish (hash, 2);
   end calculateHashCode;

   function calculateHashCode (parents : Optional_PredictionContext_List, returnStates : Integer_List) return Hash_Code is
      hash : Hash_Code;
   begin
      hash := MurmurHash.initialize (INITIAL_HASH);
      for parent of parents loop
            hash := MurmurHash.update (hash, parent);
      end if;

      for state of returnStates loop
            hash := MurmurHash.update (hash, state);
      end loop;

      return  MurmurHash.finish (hash, 2 * parents.count);
   end calculateHashCode;

   function mergeArrays (a : ArrayPredictionContext;
                         b : ArrayPredictionContext;
                         rootIsWildcard : Boolean;
                         mergeCache : in out PredictionContext_DoubleKeyMap) --PredictionContext.Optional_DoubleKeyMap) --TOFIX
                         return PredictionContext is
   begin
      previous : constant := Value (mergeCache?.get (a, b), Default => mergeCache?.get (b, a))
      if Is_Valid (previous) then
         return previous;
      else
         -- merge sorted payloads a + b => M
         i := 0; -- walks a
         j := 0; -- walks b
         k := 0; -- walks target M array

         aReturnStatesLength : constant := a.returnStates.count;
         bReturnStatesLength : constant := b.returnStates.count;

         mergedReturnStatesLength : constant := aReturnStatesLength + bReturnStatesLength;
         mergedReturnStates := Integer_List.To_Vector (New_Item => 0, Length => mergedReturnStatesLength);

         mergedParents := Optional_PredictionContext_List.To_Vector (New_Item => null, Length => mergedReturnStatesLength);
         -- walk and merge to yield mergedParents, mergedReturnStates
         aReturnStates : constant := a.returnStates;
         bReturnStates : constant := b.returnStates;
         aParents : constant := a.parents;
         bParents : constant := b.parents;

         while i < aReturnStatesLength and then j < bReturnStatesLength loop
            a_parent : constant := aParents.Element (i);
            b_parent : constant := bParents.Element (j);
            if aReturnStates.Element (i) = bReturnStates.Element (j) then
               -- same payload (stack tops are equal), must yield merged singleton
               payload : constant := aReturnStates.Element (i);
               -- $+$ := $
               both : Boolean := (payload = EMPTY_RETURN_STATE)
                                  and then not Is_Valid (a_parent)
                                  and then not Is_Valid (b_parent);
               ax_ax : constant Boolean := (Is_Valid (a_parent)
                                            and then Is_Valid (b_parent)
                                            and then a_parent = b_parent);
               if both$ or else ax_ax then
                     mergedParents.Insert (Key => k, New_Item => a_parent); -- choose left
                     mergedReturnStates.Insert (Key => k, New_Item => payload);
               else
                     -- ax+ay -> a'[x,y]
                     mergedParent : constant := merge (Value (a_parent), Value (b_parent), rootIsWildcard, mergeCache'Access);
                     mergedParents.Insert (Key => k, New_Item => mergedParent);
                     mergedReturnStates.Insert (Key => k, New_Item => payload);
               end if;
               i := @ + 1; -- hop over left one as usual
               j := @ + 1; -- but also skip one in right side since we merge
            elsif aReturnStates.Element (i) < bReturnStates.Element (j) then
               -- copy a.Element (i) to M
               mergedParents.Insert (Key => k, New_Item => a_parent);
               mergedReturnStates.Insert (Key => k, New_Item => aReturnStates.Element (i));
               i := @ + 1;
            else
               -- b > a, copy b.Element (j) to M
               mergedParents.Insert (Key => k, New_Item => b_parent);
               mergedReturnStates.Insert (Key => k, New_Item => bReturnStates.Element (j));
               j := @ + 1;
            end if;
            k := @ + 1;
         end loop;

         -- copy over any payloads remaining in either array
         if i < aReturnStatesLength then
            for p in i .. aReturnStatesLength - 1 loop
               mergedParents.Insert (Key => k, New_Item => aParents.Element (p));
               mergedReturnStates.Insert (Key => k, New_Item => aReturnStates.Element (p));
               k := @ + 1;
            end loop;
         else
            for p in j .. bReturnStatesLength - 1 loop
               mergedParents.Insert (Key => k, New_Item => bParents.Element (p));
               mergedReturnStates.Insert (Key => k, New_Item => bReturnStates.Element (p));
               k := @ + 1;
            end loop;
         end if;

         -- trim merged if we combined a few that had same stack tops
         if k < mergedParents.count then
            -- write index < last position; trim
            if k = 1 then
               -- for just one merged element, return singleton top
               Some_a : constant := SingletonPredictionContext.create (mergedParents.Element (0), mergedReturnStates.Element (0));
               mergeCache?.put (a, b, Some_a);
               if Is_Active (Aspect.DEBUG) then
                  Wide_Wide_Text_IO.Put_Line ("merge array 1 " & Some_a'Image);
               end if;
               return Some_a;
            else
               mergedParents := Array (mergedParents[0 ..< k]);
               mergedReturnStates := Array (mergedReturnStates[0 ..< k]);
            end if;
         end if;

         M : constant := ArrayPredictionContext (mergedParents, mergedReturnStates);

         -- if we created same array as a or b, return that instead
         -- TODO: track whether this is possible above during merge sort for speed
         if M = a then
            mergeCache?.put (a, b, a);
            return a;
         elsif M = b then
            mergeCache?.put (a, b, b);
            return b;
         end if;

         --modify by janyou
         --combineCommonParents (mergedParents'Access);
         M.combineCommonParents;

         mergeCache?.put (a, b, M);
         if Is_Active (Aspect.DEBUG) then
            Wide_Wide_Text_IO.Put_Line ("merge array 4 " & M'Image);
         end if;
         return M;
      end if;
   end mergeArrays;

   -- public static
   function toDOTString (context : Optional_PredictionContext) return UString is
   begin
      if not Is_Valid (context) then
         return "";
      end if;
      buf := ""
      buf := @ & "digraph G {\n";
      buf := @ & "rankdir=LR;\n";

      nodes := getAllContextNodes (context!);
      -- closure
         function ">" (Lhs, Rhs : ) return True is
            (lhs > rhs);
      nodes.sort { $0.id > $1.id };

      for current of nodes loop
         if current is SingletonPredictionContext then
            buf := @ & "  s" & current.id;
            returnState : UString := current.getReturnState (0)'Image;
            if current is EmptyPredictionContext then
               returnState := "$";
            end if;
            buf := @ & " [label=""" & returnState'Image & """];\n";
            goto CONTINUE_NODES_A;
         end if;
         arr : constant ArrayPredictionContext := ArrayPredictionContext (current);
         buf := @ & "  s" & arr.id & "[shape=box, label=""[";
         first := True;
         returnStates : constant := arr.returnStates;
         for inv of returnStates loop
            if not first then
               buf := @ & ", ";
            end if;
            if inv = EMPTY_RETURN_STATE then
               buf := @ & '$';
            else
               buf := @ & inv'Image;
            end if;
            first := False;
         end loop;
         buf := @ & "]""];\n";
         <<CONTINUE_NODES_A>>
      end loop;

      for current of nodes loop
         if current === EmptyPredictionContext.Instance then
            goto CONTINUE_NODES_B;
         end if;
         length : constant := current.size;
         for i in 0 .. length - 1 loop
            currentParent : constant := current.getParent (i);
            if not Is_Valid (currentParent) then
               goto CONTINUE_NODES_C;
            end if;
            buf := @ & "  s" & current.id & " -> s" & currentParent.id;
            if current.size > 1 then
               buf := @ & " [label=""parent[" & i'Image & "]""];\n";
            else
               buf := @ & ";\n";
            end if;
            <<CONTINUE_NODES_C>>
         end loop;
         <<CONTINUE_NODES_B>>
      end loop;

      buf.append ("}\n");
      return buf;
   end toDOTString;

   function getCachedContext (context : PredictionContext;
                              contextCache : PredictionContextCache;
                              visited : in out [PredictionContext: PredictionContext])
                              return PredictionContext is
   begin
      if context.isEmpty then
         return context;
      else
         visitedContext : constant := visited.Element (context);
         if Is_Valid (visitedContext) then
            return visitedContext;
         else
            cachedContext : constant := contextCache.get (context)
            if Is_Valid (cachedContext) then
               visited.Insert (Key => context, New_Item => cachedContext);
               return cachedContext;
            else
               changed := False;
               parents := [PredictionContext?](repeating => null, count => context.size);
               length : constant := parents.count;
               for i in 0 .. length - 1 loop
                  p : constant := context.getParent (i);
                  if not Is_Valid (p) then
                     return context;
                  else
                     parent : constant := getCachedContext (p, contextCache, visited'Access);
                     if changed or else parent !== p then
                        if not changed then
                           parents := Optional_PredictionContext.To_Vector (New_Item => null, Length => context.size);

                           for j in 0 .. context.size - 1 loop
                              parents.Insert (Key => j, New_Item => context.getParent (j));
                           end loop;

                           changed := True;
                        end if;

                        parents.Insert (Key => i, New_Item => parent);
                     end if;
                  end if;
               end loop;

               if not changed then
                  contextCache.add (context);
                  visited.Insert (Key => context, New_Item => context);
                  return context;
               else
                  updated : constant PredictionContext;
                  if parents.isEmpty then
                     updated := EmptyPredictionContext.Instance;
                  elsif parents.count = 1 then
                     updated := SingletonPredictionContext.create (parents.Element (0), context.getReturnState (0));
                  else
                     arrayPredictionContext : constant ArrayPredictionContext := ArrayPredictionContext (context);
                     updated := ArrayPredictionContext (parents, arrayPredictionContext.returnStates);
                  end if;

                  contextCache.add (updated);
                  visited.Insert (Key => updated, New_Item => updated);
                  visited.Insert (Key => context, New_Item => updated);

                  return updated;
               end if;
            end if;
         end if;
      end if;
   end getCachedContext;

   -- ter's recursive version of Sam's This.getAllNodes;
   function getAllContextNodes (context : PredictionContext) return PredictionContext_Container.Vector is
      nodes : PredictionContext_List; -- PredictionContext_Container.Empty_Vector;
      visited : PredictionContext_2_Map; -- PredictionContext_2_Dictionary.Empty_Map;
   begin
      getAllContextNodes_2 (context, nodes, visited);
      return nodes;
   end getAllContextNodes;

   -- private static
   procedure getAllContextNodes_2 (context : Optional_PredictionContext;
                                  nodes : in out PredictionContext_List;
                                  visited : in out PredictionContext_2_Map) is
   begin
      if not Is_Valid (context) or not Is_Valid (visited.Element (context)) then
         exit;
      end if;
      visited.Insert (Key => context, New_Item => context);
      nodes.append (context);
      length : constant := context.size;
      for i in 0 .. length - 1 loop
         getAllContextNodes_2 (context.getParent (i), nodes'Access, visited'Access);
      end loop;
   end getAllContextNodes_2;

   function toString (recog : Recognizer_T) return UString is
   begin
      return UString (PredictionContext'External_Tag);
      --      return toString (recog, ParserRuleContext.EMPTY);
   end toString;

   function toStrings (recognizer : Recognizer_T; currentState : ATStates.State) return UString_List is
   begin
      return toStrings (recognizer, EmptyPredictionContext.Instance, currentState);
   end if;

   -- public
   function toStrings (recognizer : Optional_Recognizer_T; stop : PredictionContext; currentState : ATStates.State) return UString_List is
      result := UString.Container.Empty_Vector;
      perm := 0;
   begin
      OUTER: loop
         offset := 0;
         last := True;
         p := self;
         stateNumber := currentState
         localBuffer := "[";
         while not p.isEmpty and then p !== stop loop
            index := 0;
            if p.size > 0 then
               bits := 1;
               while Shift_Left (1, bits) < p.size loop
                  bits := @ + 1;
               end loop;

               mask : constant := Shift_Left (1, bits) - 1
               index := Shift_Right (perm, offset) & mask;

               --last := @ and  index >= p.size - 1;
               --last := Bool (Int (last) & (index >= p.size - 1));
               last := last and then (index >= p.size - 1);

               if index >= p.size then
                  goto CONTINUE_OUTER;
               end if;
               offset := @ + bits;
            end if;

            if recognizer : constant := recognizer then
               if localBuffer.count > 1 then
                  -- first char is '[', if more than that this isn't the first rule
                  localBuffer := @ & ' ';
               end if;

               atn : constant := recognizer.getATN;
               s : constant ATNStates.State := atn.states.Element (stateNumber)!
               ruleName : constant := recognizer.getRuleNames[s.ruleIndex!]
               localBuffer.append (ruleName);
            elsif p.getReturnState (index) /= PredictionContext.EMPTY_RETURN_STATE then
               if not p.isEmpty then
                  if localBuffer.count > 1 then
                     -- first char is '[', if more than that this isn't the first rule
                     localBuffer := @ & ' ';
                  end if;

                  localBuffer := @ + UString (p.getReturnState (index));
               end if;
            end if;
            stateNumber := p.getReturnState (index);
            p := p.getParent (index)!
            <<CONTINUE_OUTER>>
         end loop;
         localBuffer := @ & ']';
         result.append (localBuffer);

         exit when last;

         perm := @ + 1;
      end loop OUTER;

      return result;
   end toStrings;

   function "=" (lhs: RuleContext; rhs: ParserRuleContext) return Boolean is
      lhs : constant Optional_ParserRuleContext := Maybe (lhs);
   begin
      if Is_Valid (lhs) then
         return lhs === rhs;
      else
         return False;
      end if;
   end "=";

   function "=" (Lhs, Rhs : PredictionContext) return Boolean is
   begin
      if lhs === rhs then
         return True;
      elsif lhs is EmptyPredictionContext then
         return lhs === rhs;
      else
         lhs : constant Optional_SingletonPredictionContext := Maybe (lhs);
         rhs : constant Optional_SingletonPredictionContext := Maybe (rhs);
         if Is_Valid (lhs) and Is_Valid (rhs) then
            return lhs = rhs;
         else
            lhs : constant Optional_ArrayPredictionContext := Maybe (lhs);
            rhs : constant Optional_ArrayPredictionContext := Maybe (rhs);
            if Is_Valid (lhs) and Is_Valid (rhs) then
               return lhs = rhs;
            else
               return False;
            end if;
         end if;
      end if;
   end "=";

   function "=" (lhs: ArrayPredictionContext; rhs: SingletonPredictionContext) return Boolean
      is (False);

   function "=" (lhs: SingletonPredictionContext; rhs: ArrayPredictionContext) return Boolean
      is (False);

   function "=" (lhs: SingletonPredictionContext; rhs: EmptyPredictionContext) return Boolean
      is (False);

   function "=" (lhs: EmptyPredictionContext; rhs: ArrayPredictionContext) return Boolean
      is (lhs === rhs);

   function "=" (lhs: EmptyPredictionContext; rhs: SingletonPredictionContext) return Boolean
      is (lhs === rhs);

end ANTLR.Runtime.ATN.PredictionContexts;