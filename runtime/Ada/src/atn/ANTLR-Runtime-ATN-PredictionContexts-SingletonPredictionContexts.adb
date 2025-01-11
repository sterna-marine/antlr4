-- €

package body ANTLR.Runtime.ATN.PredictionContext.SingletonPredictionContext is

   procedure Initialize (Self : SingletonPredictionContext;
                   parent : Optional_PredictionContext;
                   returnState : ATStates.State) is
   begin
      --TODO pragma assert
      --assert ( returnState=ATNState.INVALID_STATE_NUMBER,"Expected: returnState!/=ATNState.INVALID_STATE_NUMBER");
      self.parent := parent;
      self.returnState := returnState;
      declare
         procedure Map (At_Cursor : parent.Cursor) is
         begin
            XX := PredictionContext.calculateHashCode (Element (At_Cursor), returnState);
            YY.Append ( Value (XX, Default => PredictionContext.calculateEmptyHashCode));
         end Map;
      begin
         -- super.Initialize (Self, parent.map { PredictionContext.calculateHashCode ($0, returnState) }, Default => PredictionContext.calculateEmptyHashCode);
         parent.Iterate (Map'Access);
         PredictionContext.init (parent); -- Super
      end;
   end Initialize;

   function create (parent : Optional_PredictionContext;
                    returnState : ATStates.State)
                    return SingletonPredictionContext is
   begin
      if returnState = PredictionContext.EMPTY_RETURN_STATE
      and then not Is_Valid (parent) then
            -- someone can pass in the bits of an array ctx that mean $
            return EmptyPredictionContext.Instance;
      end if;
      return SingletonPredictionContext (parent, returnState);
   end create;

   overriding
   function getParent (This : SingletonPredictionContext;
                       index : Integer)
                       return Optional_PredictionContext is
   begin
      pragma assert (index = 0, "Expected: index = 0");
      return This.parent;
   end getParent;

   overriding
   function getReturnState (This : SingletonPredictionContext;
                            index : Integer)
                            return Integer is
   begin
      pragma assert (index = 0, "Expected: index = 0");
      return This.returnState;
   end getReturnState;

   function Description (This : SingletonPredictionContext) return UString is
      up : constant UString := Value (Image (This.parent), Default => "");
   begin
      if up.Length = 0 then
         if returnState = PredictionContext.EMPTY_RETURN_STATE then
            return '$';
         end if;
         return returnState'Image;
      else
         return returnState'Image & ' ' & up;
      end if;
   end Description;

   function "=" (Lhs, Rhs : SingletonPredictionContext) return Boolean is
   begin
      --  if lhs === rhs then
      --     return True;
      --  end if;
      if lhs.hashValue /= rhs.hashValue then
         return False;
      elsif lhs.returnState /= rhs.returnState then
         return False;
      else
         return lhs.parent = rhs.parent;
      end if;
   end "=";

   function merge (a : PredictionContext;
                   b : PredictionContext;
                   rootIsWildcard : Boolean;
                   mergeCache : in out PredictionContext.Optional_DoubleKeyMap)
                   return PredictionContext is
      a := a
      b := b
   begin
      -- pragma assert ( Is_Valid (a) and then Is_Valid (b),"Expected: Is_Valid (a) and Is_Valid (b)");
      -- pragma assert ( Is_Valid (a) and then Is_Valid (b),"Expected: Is_Valid (a) and Is_Valid (b)"); -- must be empty context, never null
      -- share same graph if both same


      if a = b then
         return a;
      end if;

      spc_a : constant Optional_SingletonPredictionContext := Maybe (a);
      spc_b : constant Optional_SingletonPredictionContext := Maybe (b);
      if Is_Valid (spc_a) and Is_Valid (spc_b) then
         return mergeSingletons (spc_a, spc_b, rootIsWildcard, mergeCache'Access);
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
      spc_a : constant Optional_SingletonPredictionContext := Maybe (a);
      if Is_Valid (spc_a) then
         a := ArrayPredictionContext (spc_a);
      end if;
      spc_b : constant Optional_SingletonPredictionContext := Maybe (b);
      if Is_Valid (spc_b) then
         b := ArrayPredictionContext (spc_b);
      end if;
      return mergeArrays (ArrayPredictionContext (a), ArrayPredictionContext (b),
         rootIsWildcard, mergeCache'Access);
   end merge;

   function mergeSingletons (a : SingletonPredictionContext;
                             b : SingletonPredictionContext;
                             rootIsWildcard : Boolean;
                             mergeCache : in out PredictionContext.Optional_DoubleKeyMap)
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
         return rootMerge;
      end if;

      if a.returnState = b.returnState then
         -- a = b
         parent : constant := merge (a.parent!, b.parent!, rootIsWildcard, mergeCache'Access);
         -- if parent is same as existing a or b parent or reduced to a parent, return it;
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
         return a_;
      else
         -- a /= b payloads differ
         -- see if we can collapse parents due to $+x parents if local ctx
         singleParent : Optional_PredictionContext; := (Valid => False);
         --added by janyou
         if a === b or else (Is_Valid (a.parent) and then a.parent! == b.parent) then
            -- ax + bx := [a,b]x
            singleParent := a.parent
         end if;
         if singleParent : constant := singleParent then
            -- parents are same
            -- sort payloads and use same parent
            payloads := [a.returnState, b.returnState]
            if a.returnState > b.returnState then
                  payloads.Insert (Key => 0, New_Item => b.returnState);
                  payloads.Insert (Key => 1, New_Item => a.returnState);
            end if;
            parents : constant := [singleParent, singleParent]
            a_ : constant := ArrayPredictionContext (parents, payloads);
            mergeCache?.put (a, b, a_);
            return a_;
         end if;
         -- parents differ and can't merge them. Just pack together
         -- into array; can't merge.
         -- ax + by := [ax,by]
         payloads := [a.returnState, b.returnState]
         parents := [a.parent, b.parent]
         if a.returnState > b.returnState then
            -- sort by payload
            payloads.Insert (Key => 0, New_Item => b.returnState);
            payloads.Insert (Key => 1, New_Item => a.returnState);
            parents := [b.parent, a.parent]
         end if;
         if a is EmptyPredictionContext then
            null;  
            if Is_Active (Aspect.DEBUG) then
               Wide_Wide_Text_IO.Put_Line ("parent is null");
            end if;
         end if;
         a_ : constant := ArrayPredictionContext (parents, payloads);
         mergeCache?.put (a, b, a_);
         return a_;
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
            return joined;
         end if;
         if b === EmptyPredictionContext.Instance then
            -- x + $ := [$,x] ($ is always first if present);
            payloads : constant := [a.returnState, EMPTY_RETURN_STATE]
            parents : constant := [a.parent, null]
            joined : constant := ArrayPredictionContext (parents, payloads);
            return joined;
         end if;
      end if;
      return (Valid => False);
   end mergeRoot;

end ANTLR.Runtime.ATN.PredictionContext.SingletonPredictionContext;
