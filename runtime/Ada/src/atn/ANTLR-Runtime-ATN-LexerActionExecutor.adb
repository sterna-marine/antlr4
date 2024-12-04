-- €

package body ANTLR.Runtime.ATN.LexerAction is

   procedure Init (Self : in out LexerActionExecutor; lexerActions : LexerAction.Container.Vector) is
   begin
      self.lexerActions := lexerActions;
      hash := MurmurHash.initialize ();
      for Some_lexerAction in Self.LexerActions loop --TOFIX
            hash := MurmurHash.update (hash, Some_lexerAction); --TOFIX
      end loop;
      self.hashCode := MurmurHash.finish (hash, lexerActions.count); --TOFIX
   end Init;

   function append (This : LexerActionExecutor;
                    lexerActionExecutor : Optional_LexerActionExecutor;
                    lexerAction : LexerAction)
                    return LexerActionExecutor is
   begin
      if not Is_Valid (lexerActionExecutor) then
            return LexerActionExecutor ([lexerAction]);
      end if;

      --lexerActions : [LexerAction] := lexerActionExecutor.lexerActions, --lexerActionExecutor.lexerActions.length + 1);
      lexerActions : [LexerAction] := lexerActionExecutor.lexerActions;
      lexerActions.append (lexerAction);
      --lexerActions[lexerActions.length - 1] := lexerAction;
      return LexerActionExecutor (lexerActions);
   end append;

   function fixOffsetBeforeMatch (This : LexerActionExecutor; offset : Integer) return LexerActionExecutor is
      updatedLexerActions : [LexerAction]? := null;
      length : constant := lexerActions.count
   begin
      for i in 0 .. length - 1 loop
         if lexerActions[i].isPositionDependent () and then not (lexerActions[i] is LexerIndexedCustomAction) then
            if updatedLexerActions = null then
               updatedLexerActions := lexerActions;  --lexerActions.clone ();
            end if;

            updatedLexerActions![i] := LexerIndexedCustomAction (offset, lexerActions[i]);
         end if;
      end loop;

      if updatedLexerActions = null then
            return self;
      end if;

      return LexerActionExecutor (updatedLexerActions!);
   end fixOffsetBeforeMatch;

   procedure execute (This : LexerActionExecutor;
                      lexer : Lexer;
                      input : CharStream;
                      startIndex : Integer) is
   begin
      requiresSeek : Boolean := False;
      stopIndex : constant Integer := input.index ();

      for lexerAction : LexerAction in self.lexerActions loop
         runLexerAction : constant Optional_LexerIndexedCustomAction := Set (lexerAction);
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
               try! input.seek (stopIndex);
            end if;
         end defer;

   end execute;

   procedure hash (This : LexerActionExecutor; hasher: in out Hasher) is
   begin
      hasher.combine (hashCode);
   end hash;

   function "=" (lhs: LexerActionExecutor; rhs: LexerActionExecutor) return Boolean is
   begin
      --  if lhs === rhs then
      --     return True;
      --  end if;
      if LexerAction.Container.Length (Lhs.lexerActions) /= LexerAction.Container.Length (Rhs.lexerActions) then
         return False;
      end if;

      for i in 0 .. LexerAction.Container.Length (Lhs.lexerActions) - 1 loop
         if not LexerAction.Container.Element (Lhs.lexerActions, i) = LexerAction.Container.Element (Rhs.lexerActions, i) then
            return False;
         end if;
      end loop;

      return lhs.hashCode = rhs.hashCode
   end "=";

end ANTLR.Runtime.ATN.LexerAction;
