-- €

package body ANTLR.Runtime.ATN.PredictionContext is 

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


   procedure Init (Self : PredictionContext; cachedHashCode : Hash_code) is
   begin
      self.cachedHashCode := cachedHashCode;
   end Init;

   function fromRuleContext (atn : ATN; outerContext : Optional_RuleContext) return PredictionContext is
   begin
      _outerContext : constant := outerContext ?? ParserRuleContext.EMPTY

      -- if we are in RuleContext of start rule, s, then PredictionContext
      -- is EMPTY. Nobody called us. (if we are empty, return empty);
      if (_outerContext.parent = null or else _outerContext === ParserRuleContext.EMPTY) then
            return EmptyPredictionContext.Instance;
      end if;

      -- If we have a parent, convert it to a PredictionContext graph
      parent : constant := PredictionContext.fromRuleContext (atn, _outerContext.parent);

      state : constant := atn.states[_outerContext.invokingState]!
      transition : constant RuleTransition := RuleTransition (state.transition (0));
      return SingletonPredictionContext.create (parent, transition.followState.stateNumber);
   end fromRuleContext;

   function size (This : PredictionContext) return Integer is
   begin
      raise PROGRAM_ERROR with "ANTLR.Runtime.ATN.PredictionContext.size() must be overridden";
   end size;

   function getParent (This : PredictionContext; index : Integer) return Optional_PredictionContext is
   begin
      raise PROGRAM_ERROR with "ANTLR.Runtime.ATN.PredictionContext.getParent() must be overridden";
   end getParent;

   function getReturnState (This : PredictionContext; index : Integer) return ATNStates.State is
   begin
      raise PROGRAM_ERROR with "ANTLR.Runtime.ATN.PredictionContext.getReturnState() must be overridden";
   end getReturnState;

   function isEmpty (This : PredictionContext) return Boolean
      is This === EmptyPredictionContext.Instance;

   function hasEmptyPath (This : PredictionContext) return Boolean
      is (getReturnState (Last_ID) == PredictionContext.EMPTY_RETURN_STATE)

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

   function calculateHashCode (parents : [PredictionContext?], returnStates : [Int]) return Hash_Code is
      hash : Hash_Code;
   begin
      hash := MurmurHash.initialize (INITIAL_HASH);
      for parent in parents loop
            hash := MurmurHash.update (hash, parent);
      end if;
      for state in returnStates loop
            hash := MurmurHash.update (hash, state);
      end loop;

      return  MurmurHash.finish (hash, 2 * parents.count);
   end calculateHashCode;

   function merge (a : PredictionContext;
                   b : PredictionContext;
                   rootIsWildcard : Boolean;
                   mergeCache : in out DoubleKeyMap<PredictionContext, PredictionContext, PredictionContext>?)
                   return PredictionContext is
      a := a
      b := b
   begin
      -- assert ( a /= null and then b /= null,"Expected: a /= null and b /= null");
      -- assert ( a /= null and then b /= null,"Expected: a /= null and b /= null"); -- must be empty context, never null
      -- share same graph if both same


      if a = b then
         return a;
      end if;

      spc_a : constant Optional_SingletonPredictionContext := Set (a);
      spc_b : constant Optional_SingletonPredictionContext := Set (b);
      if Is_Valid (spc_a) and Is_Valid (spc_b) then
         return mergeSingletons (spc_a, spc_b, rootIsWildcard, &mergeCache);
      end if;

      -- At least one of a or b is array
      -- If one is $ and rootIsWildcard, return $ as * wildcard
      if rootIsWildcard then
         if a is EmptyPredictionContext then
            return a;
         end if;
         if b is EmptyPredictionContext then
            return b;
         end if;
      end if;

      -- convert singleton so both are arrays to normalize
      spc_a : constant Optional_SingletonPredictionContext := Set (a);
      if Is_Valid (spc_a) then
         a := ArrayPredictionContext (spc_a);
      end if;
      spc_b : constant Optional_SingletonPredictionContext := Set (b);
      if Is_Valid (spc_b) then
         b := ArrayPredictionContext (spc_b);
      end if;
      return mergeArrays (ArrayPredictionContext (a), ArrayPredictionContext (b),
         rootIsWildcard, &mergeCache);
   end merge;

   function mergeSingletons (a : SingletonPredictionContext;
                             b : SingletonPredictionContext;
                             rootIsWildcard : Boolean;
                             mergeCache : inxout DoubleKeyMap<PredictionContext, PredictionContext, PredictionContext>?)
                             return PredictionContext is
   begin
      if mergeCache : constant := mergeCache then
         previous := mergeCache.get (a, b);
         if previous : constant := previous then
            return previous;
         end if;
         previous := mergeCache.get (b, a);
         if previous : constant := previous then
            return previous;
         end if;
      end if;

      if rootMerge : constant := mergeRoot (a, b, rootIsWildcard) then
         mergeCache?.put (a, b, rootMerge);
         return rootMerge
      end if;

      if a.returnState = b.returnState then
         -- a = b
         parent : constant := merge (a.parent!, b.parent!, rootIsWildcard, &mergeCache);
         -- if parent is same as existing a or b parent or reduced to a parent, return it
         if parent === a.parent! then
            return a;
         end if; -- ax + bx := ax, if a=b
         if parent === b.parent! then
            return b;
         end if; -- ax + bx := bx, if a=b
         -- else: ax + ay := a'[x,y]
         -- merge parents x and y, giving array node with x,y then remainders
         -- of those graphs.  dup a, a' points at merged array
         -- new joined parent so create new singleton pointing to it, a'
         a_ : constant := SingletonPredictionContext.create (parent, a.returnState);
         mergeCache?.put (a, b, a_);
         return a_
      else
         -- a /= b payloads differ
         -- see if we can collapse parents due to $+x parents if local ctx
         singleParent : Optional_PredictionContext; := null;
         --added by janyou
         if a === b or else (a.parent /= null and then a.parent! == b.parent) then
            -- ax + bx := [a,b]x
            singleParent := a.parent
         end if;
         if singleParent : constant := singleParent then
            -- parents are same
            -- sort payloads and use same parent
            payloads := [a.returnState, b.returnState]
            if a.returnState > b.returnState then
                  payloads[0] := b.returnState
                  payloads[1] := a.returnState
            end if;
            parents : constant := [singleParent, singleParent]
            a_ : constant := ArrayPredictionContext (parents, payloads);
            mergeCache?.put (a, b, a_);
            return a_
         end if;
         -- parents differ and can't merge them. Just pack together
         -- into array; can't merge.
         -- ax + by := [ax,by]
         payloads := [a.returnState, b.returnState]
         parents := [a.parent, b.parent]
         if a.returnState > b.returnState then
            -- sort by payload
            payloads[0] := b.returnState
            payloads[1] := a.returnState
            parents := [b.parent, a.parent]
         end if;
         if a is EmptyPredictionContext then
            null;  -- print ("parent is null");
         end if;
         a_ : constant := ArrayPredictionContext (parents, payloads);
         mergeCache?.put (a, b, a_);
         return a_
      end if;
   end mergeSingletons;

   function mergeRoot (a : SingletonPredictionContext;
                       b : SingletonPredictionContext;
                       rootIsWildcard : Boolean)
                       return Optional_PredictionContext is
   begin
      if rootIsWildcard then
         if a === EmptyPredictionContext.Instance then
            return EmptyPredictionContext.Instance;
         end if;  -- * + b := *
         if b === EmptyPredictionContext.Instance then
            return EmptyPredictionContext.Instance;
         end if;  -- a + * := *
      else
         if a === EmptyPredictionContext.Instance and then b === EmptyPredictionContext.Instance then
            return EmptyPredictionContext.Instance;
         end if; -- $ + $ := $
         if a === EmptyPredictionContext.Instance then
            -- $ + x := [$,x]
            payloads : constant := [b.returnState, EMPTY_RETURN_STATE]
            parents : constant := [b.parent, null]
            joined : constant := ArrayPredictionContext (parents, payloads);
            return joined
         end if;
         if b === EmptyPredictionContext.Instance then
            -- x + $ := [$,x] ($ is always first if present);
            payloads : constant := [a.returnState, EMPTY_RETURN_STATE]
            parents : constant := [a.parent, null]
            joined : constant := ArrayPredictionContext (parents, payloads);
            return joined
         end if;
      end if;
      return null;
   end mergeRoot;

   function mergeArrays (a : ArrayPredictionContext;
                         b : ArrayPredictionContext;
                         rootIsWildcard : Boolean;
                         mergeCache : in out DoubleKeyMap<PredictionContext, PredictionContext, PredictionContext>?)
                         return PredictionContext is
   begin
      if previous : constant := mergeCache?.get (a, b) ?? mergeCache?.get (b, a) then
         return previous;
      end if;

      -- merge sorted payloads a + b => M
      i := 0 -- walks a
      j := 0 -- walks b
      k := 0 -- walks target M array

      aReturnStatesLength : constant := a.returnStates.count
      bReturnStatesLength : constant := b.returnStates.count

      mergedReturnStatesLength : constant := aReturnStatesLength + bReturnStatesLength
      mergedReturnStates := [Int](repeating: 0, count: mergedReturnStatesLength);

      mergedParents := [PredictionContext?](repeating: null, count: mergedReturnStatesLength);
      -- walk and merge to yield mergedParents, mergedReturnStates
      aReturnStates : constant := a.returnStates
      bReturnStates : constant := b.returnStates
      aParents : constant := a.parents
      bParents : constant := b.parents

      while i < aReturnStatesLength and then j < bReturnStatesLength loop
         a_parent : constant := aParents[i]
         b_parent : constant := bParents[j]
         if aReturnStates[i] == bReturnStates[j] then
            -- same payload (stack tops are equal), must yield merged singleton
            payload : constant := aReturnStates[i]
            -- $+$ := $
            let both$ := ((payload = EMPTY_RETURN_STATE) and then a_parent = null and then b_parent = null);
            ax_ax : constant := (a_parent /= null and then b_parent /= null and then a_parent = b_parent);

            if both$ or else ax_ax then
                  mergedParents[k] := a_parent -- choose left
                  mergedReturnStates[k] := payload
            else
                  -- ax+ay -> a'[x,y]
                  mergedParent : constant := merge (a_parent!, b_parent!, rootIsWildcard, &mergeCache);
                  mergedParents[k] := mergedParent
                  mergedReturnStates[k] := payload
            end if;
            i := @ + 1; -- hop over left one as usual
            j := @ + 1; -- but also skip one in right side since we merge
         end if; elsif aReturnStates[i] < bReturnStates[j] then
            -- copy a[i] to M
            mergedParents[k] := a_parent
            mergedReturnStates[k] := aReturnStates[i]
            i := @ + 1;
         else
            -- b > a, copy b[j] to M
            mergedParents[k] := b_parent
            mergedReturnStates[k] := bReturnStates[j]
            j := @ + 1;
         end if;
         k := @ + 1;
      end loop;

      -- copy over any payloads remaining in either array
      if i < aReturnStatesLength then

         for p in i .. aReturnStatesLength - 1 loop
            mergedParents[k] := aParents[p]
            mergedReturnStates[k] := aReturnStates[p]
            k := @ + 1;
         end loop;
      else
         for p in j .. bReturnStatesLength - 1 loop
            mergedParents[k] := bParents[p]
            mergedReturnStates[k] := bReturnStates[p]
            k := @ + 1;
         end loop;
      end if;

      -- trim merged if we combined a few that had same stack tops
      if k < mergedParents.count then
         -- write index < last position; trim
         if k = 1 then
            -- for just one merged element, return singleton top
            a_ : constant := SingletonPredictionContext.create (mergedParents[0], mergedReturnStates[0]);
            mergeCache?.put (a, b, a_);
            --print ("merge array 1 " & a_'Image);
            return a_
         end if;
         mergedParents := Array (mergedParents[0 ..< k]);
         mergedReturnStates := Array (mergedReturnStates[0 ..< k]);
      end if;

      M : constant := ArrayPredictionContext (mergedParents, mergedReturnStates);

      -- if we created same array as a or b, return that instead
      -- TODO: track whether this is possible above during merge sort for speed
      if M = a then
         mergeCache?.put (a, b, a);
         return a
      end if;
      if M = b then
         mergeCache?.put (a, b, b);
         return b
      end if;

      --modify by janyou
      --combineCommonParents (&mergedParents);
      M.combineCommonParents ();

      mergeCache?.put (a, b, M);
      -- print ("merge array 4 " & M'Image);
      return M
   end mergeArrays;

   -- public static
   function toDOTString (context : Optional_PredictionContext) return String is
   begin
      if context = null then
            return "";
      end if;
      buf := ""
      buf := @ + "digraph G {\n";
      buf := @ + "rankdir=LR;\n";

      nodes := getAllContextNodes (context!);
      -- closure
         function ">" (Lhs, Rhs : ) return True is
            (lhs > rhs);
      nodes.sort { $0.id > $1.id };

      for current in nodes loop
         if current is SingletonPredictionContext then
            buf := @ + "  s\(current.id)";
            returnState : UString := String (current.getReturnState (0));
            if current is EmptyPredictionContext then
               returnState := "$";
            end if;
            buf := @ + " [label=""" & returnState'Image & """];\n";
            goto CONTINUE_NODES_A;
         end if;
         arr : constant ArrayPredictionContext := ArrayPredictionContext (current);
         buf := @ + "  s\(arr.id) [shape=box, label=""[";
         first := True;
         returnStates : constant := arr.returnStates
         for inv in returnStates loop
            if not first then
               buf := @ + ", ";
            end if;
            if inv = EMPTY_RETURN_STATE then
               buf := @ + "$";
            else
               buf := @ + String (inv);
            end if;
            first := False;
         end loop;
         buf := @ + "]""];\n";
         <<CONTINUE_NODES_A>>
      end loop;

      for current in nodes loop
         if current === EmptyPredictionContext.Instance then
            goto CONTINUE_NODES_B;
         end if;
         length : constant := current.size ();
         for i in 0 .. length - 1 loop
            currentParent : constant := current.getParent (i);
            if not Is_Valid (currentParent) then
               goto CONTINUE_NODES_C;
            end if;
            buf := @ + "  s\(current.id) -> s\(currentParent.id)";
            if current.size () > 1 then
               buf := @ + " [label=""parent[" & i'Image & "]""];\n";
            else
               buf := @ + ";\n";
            end if;
            <<CONTINUE_NODES_C>>
         end loop;
         <<CONTINUE_NODES_B>>
      end loop;

      buf.append ("end if;\n");
      return buf
   end toDOTString;

   function getCachedContext (context : PredictionContext;
                              contextCache : PredictionContextCache;
                              visited : in out [PredictionContext: PredictionContext])
                              return PredictionContext is
   begin
      if context.isEmpty () then
         return context;
      end if;

      if visitedContext : constant := visited[context] then
         return visitedContext;
      end if;

      if cachedContext : constant := contextCache.get (context) then
         visited[context] := cachedContext
         return cachedContext
      end if;

      changed := False;
      parents := [PredictionContext?](repeating: null, count: context.size ());
      length : constant := parents.count
      for i in 0 .. length - 1 loop
         p : constant := context.getParent (i);
         if not Is_Valid (p) then
            return context
         end if;

         parent : constant := getCachedContext (p, contextCache, &visited);
         if changed or else parent !== p then
            if not changed then
               parents := [PredictionContext?](repeating: null, count: context.size ());

               for j in 0 .. context - 1.size () loop
                  parents[j] := context.getParent (j);
               end loop;

               changed := True;
            end if;

            parents[i] := parent
         end if;
      end loop;

      if not changed then
         contextCache.add (context);
         visited[context] := context
         return context
      end if;

      updated : constant PredictionContext;
      if parents.isEmpty then
         updated := EmptyPredictionContext.Instance;
      elsif parents.count = 1 then
         updated := SingletonPredictionContext.create (parents[0], context.getReturnState (0));
      else
         arrayPredictionContext : constant ArrayPredictionContext := ArrayPredictionContext (context);
         updated := ArrayPredictionContext (parents, arrayPredictionContext.returnStates);
      end if;

      contextCache.add (updated);
      visited[updated] := updated
      visited[context] := updated

      return updated
   end getCachedContext;



   -- ter's recursive version of Sam's getAllNodes ();
   function getAllContextNodes (context : PredictionContext) return [PredictionContext] is
      nodes := [PredictionContext]();
      visited := [PredictionContext: PredictionContext]();
   begin
      getAllContextNodes_ (context, &nodes, &visited);
      return nodes
   end getAllContextNodes;

   -- private static
   procedure getAllContextNodes_ (context : Optional_PredictionContext;
                                  nodes : in out [PredictionContext],
                                  visited : in out [PredictionContext: PredictionContext]) is
   begin   
      if not Is_Valid (context) or (visited[context] = null) then
         exit;
      end if;
      visited[context] := context
      nodes.append (context);
      length : constant := context.size ();
      for i in 0 .. length - 1 loop
         getAllContextNodes_ (context.getParent (i), &nodes, &visited);
      end loop;
   end getAllContextNodes_;

   function toString<T> (recog : Recognizer<T>) return String is
   begin
      return String (describing: PredictionContext.self);
      --		return toString (recog, ParserRuleContext.EMPTY);
   end toString;

   function toStrings<T> (recognizer : Recognizer<T>, currentState : ATStates.State) return [String] is
   begin
      return toStrings (recognizer, EmptyPredictionContext.Instance, currentState);
   end if;

   -- public
   function toStrings<T> (recognizer : Recognizer<T>?, stop : PredictionContext; currentState : ATStates.State) return [String] is
      result := [String]();
      perm := 0
   begin
      OUTER: loop
         offset := 0
         last := True;
         p := self
         stateNumber := currentState
         localBuffer := "["
         while not p.isEmpty () and then p !== stop loop
            index := 0
            if p.size () > 0 then
               bits := 1
               while (1 << bits) < p.size () loop
                  bits := @ + 1;
               end loop;

               mask : constant := (1 << bits) - 1
               index := (perm >> offset) & mask

               --last := @ and  index >= p.size () - 1;
               --last := Bool (Int (last) & (index >= p.size () - 1));
               last := last and then (index >= p.size () - 1);

               if index >= p.size () then
                  goto CONTINUE_OUTER;
               end if;
               offset := @ + bits;
            end if;

            if recognizer : constant := recognizer then
               if localBuffer.count > 1 then
                  -- first char is '[', if more than that this isn't the first rule
                  localBuffer := @ + " ";
               end if;

               atn : constant := recognizer.getATN ();
               s : constant ATNStates.State := atn.states[stateNumber]!
               ruleName : constant := recognizer.getRuleNames ()[s.ruleIndex!]
               localBuffer.append (ruleName);
            elsif p.getReturnState (index) /= PredictionContext.EMPTY_RETURN_STATE then
               if not p.isEmpty () then
                  if localBuffer.count > 1 then
                     -- first char is '[', if more than that this isn't the first rule
                     localBuffer := @ + " ";
                  end if;

                  localBuffer := @ + String (p.getReturnState (index));
               end if;
            end if;
            stateNumber := p.getReturnState (index);
            p := p.getParent (index)!
            <<CONTINUE_OUTER>>
         end loop;
         localBuffer := @ + "]";
         result.append (localBuffer);

         exit when last;

         perm := @ + 1;
      end loop OUTER;

      return result
   end toStrings<T>;

   function Image return UString
      is (describing: PredictionContext.self) + "@" + String (Unmanaged.passUnretained (self).toOpaque ().hashValue);

   function "=" (lhs: RuleContext; rhs: ParserRuleContext) return Boolean is
      lhs : constant Optional_ParserRuleContext := Set (lhs);
   begin
      if Is_Valid (lhs) then
         return lhs === rhs
      else
         return False;
      end if;
   end "=";

   function "=" (lhs: PredictionContext; rhs: PredictionContext) return Boolean is
   begin
      if lhs === rhs then
         return True;
      end if;
      if lhs is EmptyPredictionContext then
         return lhs === rhs;
      end if;

      lhs : constant Optional_SingletonPredictionContext := Set (lhs);
      rhs : constant Optional_SingletonPredictionContext := Set (rhs);
      if Is_Valid (lhs) and Is_Valid (rhs) then
         return lhs = rhs;
      end if;

      lhs : constant Optional_ArrayPredictionContext := Set (lhs);
      rhs : constant Optional_ArrayPredictionContext := Set (rhs);
      if Is_Valid (lhs) and Is_Valid (rhs) then
         return lhs = rhs;
      end if;

      return False;
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

end ANTLR.Runtime.ATN.PredictionContext;