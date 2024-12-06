-- €

package body ANTLR.Runtime.ATN.LexerAction is

   function getActionType (This : LexerAction) return LexerActionType is
   begin
      raise PROGRAM_ERROR with "ANTLR.Runtime.ATN.LexerAction.getActionType() must be overridden";
   end getActionType;

   function isPositionDependent (This : LexerAction) return Boolean is
   begin
      raise PROGRAM_ERROR with "ANTLR.Runtime.ATN.LexerAction.isPositionDependent() must be overridden";
   end isPositionDependent;

   procedure execute (This : LexerAction; lexer : Lexer) is
   begin
      raise PROGRAM_ERROR with "ANTLR.Runtime.ATN.LexerAction.execute() must be overridden";
   end execute;

   procedure hash (This : LexerAction; into hasher: in out Hasher) is
   begin
      raise PROGRAM_ERROR with "ANTLR.Runtime.ATN.LexerAction.hash() must be overridden";
   end hash;

   function "=" (Lhs, Rhs : LexerAction) return Boolean is
   begin

      --  if Lhs === Rhs then
      --     return True;
      --  end if;

      if (Lhs is LexerChannelAction) and then (Rhs is LexerChannelAction) then
         return (LexerChannelAction (Lhs)) = (LexerChannelAction (Rhs));
      elsif (Lhs is LexerCustomAction) and then (Rhs is LexerCustomAction) then
         return (LexerCustomAction (Lhs)) = (LexerCustomAction (Rhs));
      elsif (Lhs is LexerIndexedCustomAction) and then (Rhs is LexerIndexedCustomAction) then
         return (LexerIndexedCustomAction (Lhs)) = (LexerIndexedCustomAction (Rhs));
      elsif (Lhs is LexerModeAction) and then (Rhs is LexerModeAction) then
         return (LexerModeAction (Lhs)) = (LexerModeAction (Rhs));
      elsif (Lhs is LexerMoreAction) and then (Rhs is LexerMoreAction) then
         return (LexerMoreAction (Lhs)) = (LexerMoreAction (Rhs));
      elsif (Lhs is LexerPopModeAction) and then (Rhs is LexerPopModeAction) then
         return (LexerPopModeAction (Lhs)) = (LexerPopModeAction (Rhs));
      elsif (Lhs is LexerPushModeAction) and then (Rhs is LexerPushModeAction) then
         return (LexerPushModeAction (Lhs)) = (LexerPushModeAction (Rhs));
      elsif (Lhs is LexerSkipAction) and then (Rhs is LexerSkipAction) then
         return (LexerSkipAction (Lhs)) = (LexerSkipAction (Rhs));
      elsif (Lhs is LexerTypeAction) and then (Rhs is LexerTypeAction) then
         return (LexerTypeAction (Lhs)) = (LexerTypeAction (Rhs));
      else
         return False;
      end if;
   end "=";

end ANTLR.Runtime.ATN.LexerAction;
