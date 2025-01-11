-- €

package body ANTLR.Runtime.BaseErrorListeners.ConsoleErrorListeners is
   overriding
   procedure syntaxError (recognizer : Recognizer_T,
                                       offendingSymbol : Optional_AnyObject;
                                       line : Integer;
                                       charPositionInLine : Integer;
                                       msg : UString;
                                       e : Optional_AnyObject) is
   begin
      if Parser.ConsoleError then
         Wide_Wide_Text_IO.Put_Line (Standard_Error, "line " & line'Image & ':' & charPositionInLine'Image & ' ' & msg'Image);
      end if;
   end syntaxError;

end ANTLR.Runtime.BaseErrorListeners.ConsoleErrorListeners;
