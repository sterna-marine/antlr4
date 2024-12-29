-- €

with Ada.Containers;
with ANTLR.Runtime.ATN.LexerAction;

package body ANTLR.Runtime.ATN.LexerActionExecutors is

   procedure Initialize (Self : in out LexerActionExecutor; lexerActions : LexerAction.Container.Vector) is
   begin
      self.lexerActions := lexerActions;
      hash := MurmurHash.initialize ();
      for Some_lexerAction in Self.LexerActions loop --TOFIX
            hash := MurmurHash.update (hash, Some_lexerAction); --TOFIX
      end loop;
      self.hashCode := MurmurHash.finish (hash, lexerActions.count); --TOFIX
   end Initialize;

   function append (This : LexerActionExecutor;
                    lexerActionExecutor : Optional_LexerActionExecutor;
                    lexerAction : LexerAction)
                    return LexerActionExecutor is
      lexerActions : LexerActionContainer.Vector;
   begin
      if not Is_Valid (lexerActionExecutor) then
            return LexerActionExecutor ([lexerAction]); --TOFIX
      end if;

      --lexerActions : LexerAction.Container.Vector := lexerActionExecutor.lexerActions, --lexerActionExecutor.lexerActions.length + 1);
      lexerActions := lexerActionExecutor.lexerActions;
      LexerActionContainer.Append (lexerActions, lexerAction);
      --lexerActions[lexerActions.length - 1] := lexerAction;
      return LexerActionExecutor (lexerActions);
   end append;

   function fixOffsetBeforeMatch (This : LexerActionExecutor; offset : Integer) return LexerActionExecutor is
      updatedLexerActions : LexerAction.Container.Vector := LexerAction.Container.Empty_Vector;
      length : constant Ada.Containers.Count_Type := LexerAction.Container.Legnth (This.lexerActions);
   begin
      for i in 0 .. length - 1 loop
         if lexerActions.Element (i).isPositionDependent () and then not (lexerActions.Element (i) is LexerIndexedCustomAction) then
            if not Is_Valid (updatedLexerActions) then
               updatedLexerActions := lexerActions;  --lexerActions.clone ();
            end if;

            updatedLexerActions!.Replace_Element (Index =>i, New_Item => LexerIndexedCustomAction (offset, lexerActions.Element (i));
         end if;
      end loop;

      if not Is_Valid (updatedLexerActions) then
            return This;
      else
         return LexerActionExecutor (updatedLexerActions!);
      end if;
   end fixOffsetBeforeMatch;

   procedure execute (This : LexerActionExecutor;
                      lexer : Lexer;
                      input : CharStream;
                      startIndex : Integer) is
   begin
      requiresSeek : Boolean := False;
      stopIndex : constant Integer := input.index ();

      for lexerAction : LexerAction in self.lexerActions loop
         runLexerAction : constant Optional_LexerIndexedCustomAction := Maybe (lexerAction);
         if Is_Valid (runLexerAction) then
            offset : constant Integer := runLexerAction.getOffset ();
            input.seek (startIndex + offset);
            lexerAction := runLexerAction.getAction ();
            requiresSeek := (startIndex + offset) /= stopIndex;
         else
            if lexerAction.isPositionDependent () then
               input.seek (stopIndex);
               requiresSeek := False;
            end if;
         end if;

         lexerAction.execute (lexer);
      end loop;

      defer:
         begin
            if requiresSeek then
               input.seek (stopIndex); -- try!
            end if;
         end defer;

   end execute;

   procedure hash (This : LexerActionExecutor; hasher: in out Hasher) is
   begin
      hasher.combine (hashCode);
   end hash;

   function "=" (lhs, rhs : LexerActionExecutor) return Boolean is
   begin
      --  if lhs === rhs then
      --     return True;
      --  end if;
      if LexerAction.Container.Length (Lhs.lexerActions) /= LexerAction.Container.Length (Rhs.lexerActions) then
         return False;
      else
         for i in 0 .. LexerAction.Container.Length (Lhs.lexerActions) - 1 loop
            if not LexerAction.Container.Element (Lhs.lexerActions, i) = LexerAction.Container.Element (Rhs.lexerActions, i) then
               return False;
            end if;
         end loop;
         return (lhs.hashCode = rhs.hashCode);
      end if;
   end "=";

end ANTLR.Runtime.ATN.LexerActionExecutors;
