-- €

package body ANTLR.Runtime.ATN.PredictionContexts.ArrayPredictionContexts is

   procedure Initialize (Self : in out ArrayPredictionContext; a : SingletonPredictionContext) is
      parents : constant Option_PredictionContext_List := [a.parent];
   begin
      Self.Initialize (parents, [a.returnState]);
   end Initialize;

   procedure Initialize (Self : in out ArrayPredictionContext;
                   parents : Optional_PredictionContext_List;
                   returnStates : Integer_List) is
   begin
      self.parents := parents;
      self.returnStates := returnStates;
      Super (Self).Initialize (PredictionContext.calculateHashCode (parents, returnStates)); -- super
   end Initialize;

   overriding
   function Description (This : …) return UString is
   begin
      if isEmpty () then
            return "[]";
      end if;
      buf := "[";
      for (i, returnState) in returnStates.enumerated () loop

         if i > 0 then
            buf := @ & ", ";
         end if;

         if returnState = PredictionContext.EMPTY_RETURN_STATE then
            buf := @ & "$";
            goto CONTINUE;
         end if;

         buf := @ & "" & returnState'Image & "";
         if parent : constant := parents.Element (i) then
            buf := @ & " " & parent'Image & "";
         else
            buf := @ & "null";
         end if;

         <<CONTINUE>>
      end loop;
      buf := @ & "]";
      return buf;
   end Image;

   procedure combineCommonParents (This : ArrayPredictionContext) is
      length : constant : Ada.Containers.Count_Type := This.parents.Length;
   begin
      uniqueParents : Dictionary<PredictionContext, PredictionContext> :=
         Dictionary<PredictionContext, PredictionContext> ();
      for p in This.parents loop
         parent : constant PredictionContext := p;
         if Is_Valid (parent) then
            -- if not uniqueParents.keys.contains (parent) then
            if uniqueParents.Element (parent) = (Valid => False) then
               uniqueParents.Insert (Key => parent, New_Item => parent); -- don't replace
            end if;
         end if;
      end loop;

      for p in 0 .. length - 1 loop
         parent : constant PredictionContext := parents.Element (p);
         if Is_Valid (parent) then
            parents.Insert (Key => p, New_Item => uniqueParents.Element (parent));
         end if;
      end loop;

   end combineCommonParents;

   function "=" (Lhs, Rhs : ArrayPredictionContext) return Boolean is
   begin
      --  if lhs === rhs then
      --     return True;
      --  end if;
      if lhs.hashValue /= rhs.hashValue then
         return False;
      end if;

      return lhs.returnStates = rhs.returnStates and then lhs.parents = rhs.parents
   end "=";

end ANTLR.Runtime.ATN.PredictionContexts.ArrayPredictionContexts;
