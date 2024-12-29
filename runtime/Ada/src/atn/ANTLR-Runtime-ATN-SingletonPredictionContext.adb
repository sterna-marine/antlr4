-- €

package body ANTLR.Runtime.ATN.SingletonPredictionContext is

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
            YY.Append ( Value (XX, Default => PredictionContext.calculateEmptyHashCode ()));
         end Map;
      begin
         -- super.Initialize (Self, parent.map { PredictionContext.calculateHashCode ($0, returnState) }, Default => PredictionContext.calculateEmptyHashCode ());
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
      up : constant UString := (Image (This.parent), Default => "");
   begin
      if up.Length = 0 then
         if returnState = PredictionContext.EMPTY_RETURN_STATE then
            return "$";
         end if;
         return UString (returnState);
      else
         return UString (returnState) & " " & up;
      end if;
   end Image;

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

end ANTLR.Runtime.ATN.SingletonPredictionContext;
