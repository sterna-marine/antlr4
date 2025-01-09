-- €

with Ada.Wide_Wide_Text_IO;
with ANTLR.Runtime.Misc.Exceptions.Errors;
with Aspect;

use Ada;
use ANTLR.Runtime.Misc.Exceptions.Errors;
use Aspect;

package body ANTLR.Runtime.Recognizers.Lexers is

   overriding
   procedure Initialize (Self : Lexer) is
   begin
      self.tokenFactorySourcePair := This.TokenSourceAndStream;
      Super (Self).Initialize; -- Super
      self.tokenFactorySourcePair.tokenSource := self;
   end Initialize;

   procedure Initialize (input : CharStream) is
   begin
      self.input := input;
      self.tokenFactorySourcePair := This.TokenSourceAndStream;
      super.Initialize (Self);
      self.tokenFactorySourcePair.tokenSource := self;
      self.tokenFactorySourcePair.stream := input;
   end Initialize;

   procedure reset (This : Lexer) is
   begin
      -- wack Lexer state variables
      if Is_Valid (This.input) then
         This.input.seek (0);  -- rewind the input
      end if;
      This.token := (Valid => False);
      This.Token_Type := CommonToken.INVALID_Token_Type;
      This.channel := CommonToken.DEFAULT_CHANNEL;
      This.tokenStartCharIndex := -1;
      This.tokenStartCharPositionInLine := -1;
      This.tokenStartLine := -1;
      This.text := (Valid => False);

      This.hitEOF := False;
      This.mode := DEFAULT_MODE;
      This.modeStack.clear;

      This.getInterpreter.reset;
   end reset;

   function nextToken (This : Lexer) return Token is
   begin
      if not Is_Valid (This.input) then
         raise ANTLRError.illegalState with "nextToken requires a non-null input stream.";
      end if;

      -- Mark start location in char stream so unbuffered streams are
      -- guaranteed at least have text of current token
      tokenStartMarker : constant := This.input.mark;

      declare
      begin
         OUTER:
            loop
               if This.hitEOF then
                  This.emitEOF;
                  return This.token!
               end if;

               This.token := (Valid => False);
               This.channel := CommonToken.DEFAULT_CHANNEL
               This.tokenStartCharIndex := This.input.index;
               This.tokenStartCharPositionInLine := This.getInterpreter.getCharPositionInLine;
               This.tokenStartLine := This.getInterpreter.getLine;
               This.text := (Valid => False);
               loop
                  This.Token_Type := CommonToken.INVALID_Token_Type
                  tType : Token_Kind;

                  declare
                  begin
                     ttype := This.getInterpreter.match (This.input, This.mode);
                  exception
                     when ANTLRException.recognition => (let e)
                        notifyListeners (LexerNoViableAltException (e), recognizer => This);
                        recover (LexerNoViableAltException (e));
                        ttype := Lexer.SKIP
                  end;

                  if This.input.LA (1) = BufferedTokenStream.EOF then
                     This.hitEOF := True;
                  end if;
                  if This.Token_Type = CommonToken.INVALID_Token_Type then
                     This.Token_Type := ttype;
                  end if;
                  if This.Token_Type = Lexer.SKIP then
                     goto CONTINUE_OUTER;
                  end if;
                  exit when This.Token_Type = Lexer.MORE;
               end loop;

               if This.token = (Valid => False) then
                  This.emit;
               end if;

               return This.token!;

               <<CONTINUE_OUTER>>
            end loop OUTER;
      end;
      defer:
         begin
            -- make sure we release marker after match or
            -- unbuffered char stream will keep buffering
            This.input.release (tokenStartMarker); -- try!
         end defer;
   end nextToken;

   procedure skip (This : Lexer) is
   begin
      This.Token_Type := Lexer.SKIP;
   end skip;

   procedure more (This : Lexer) is
   begin
      This.Token_Type := Lexer.MORE;
   end more;

   procedure mode (This : Lexer; m : Lexer_Mode) is
   begin
      This.mode := m;
   end mode;

   procedure pushMode (This : Lexer; m : Lexer_Mode) is
   begin
      if LexerATNSimulator.debug then
         Wide_Wide_Text_IO.Put_Line ("pushMode " & m'Image);
      end if;
      This.modeStack.push (This.mode);
      mode (m);
   end pushMode;

   function popMode (This : Lexer) return Lexer_Mode is
   begin
      if This.modeStack.isEmpty then
         raise ANTLRError.unsupportedOperation with " EmptyStackException";
      end if;

      if LexerATNSimulator.debug then
         Wide_Wide_Text_IO.Put_Line ("popMode back to " & UString (describing => This.modeStack.peek));
      end if;
      mode (This.modeStack.pop);
      return This.mode;
   end popMode;

   overriding
   procedure setTokenFactory (This : Lexer; Some_factory : TokenFactory) is
   begin
      This.factory := Some_factory;
   end setTokenFactory;

   overriding
   procedure setInputStream (This : Lexer; Some_input : IntStream) is
   begin
      This.input := (Valid => False);
      This.tokenFactorySourcePair := This.makeTokenSourceAndStream;
      This.reset;
      This.input := Is_Valid (Some_input); -- as CharStream
      This.tokenFactorySourcePair := This.makeTokenSourceAndStream;
   end setInputStream;

   procedure emit (This : Lexer; Some_token : Token) is
   begin
      if Is_Active (Aspect.DEBUG) then
         Wide_Wide_Text_IO.Put_Line (Standard_Error, "emit " & token'Image);
      end if;
      This.token := Some_token;
   end emit;

   function emit (This : Lexer) return Token is
      t : Token constant := This.factory.create (_tokenFactorySourcePair, This.Token_Type, This.text, This.channel, This.tokenStartCharIndex, This.getCharIndex - 1, This.tokenStartLine, This.tokenStartCharPositionInLine);
   begin
      emit (t);
      return t;
   end emit;

   function emitEOF (This : Lexer) return Token is
      cpos : constant := This.getCharPositionInLine;
      line : constant := This.getLine;
      idx : constant := This.input!.index;
      eof : constant := This.factory.create (
         This.tokenFactorySourcePair,
         CommonToken.EOF,
         null,
         CommonToken.DEFAULT_CHANNEL,
         idx,
         idx - 1,
         line,
         cpos);
   begin
      emit (eof);
      return eof;
   end emitEOF;

   procedure setLine (This : Lexer; line : Integer) is
   begin
      This.getInterpreter.setLine (line);
   end setLine;

   procedure setCharPositionInLine (This : Lexer; charPositionInLine : Integer) is
   begin
      This.getInterpreter.setCharPositionInLine (charPositionInLine);
   end setCharPositionInLine;

   function getText (This : Lexer) return UString is
   begin
      if This.text /= (Valid => False) then
         return This.text!;
      else
         return This.getInterpreter.getText (This.input!);
      end if;
   end getText;

   procedure setText (This : Lexer; text : UString) is
   begin
      This.text := text;
   end setText;

   procedure setToken (This : Lexer; Some_token : Token) is
   begin
      This.token := Some_token;
   end setToken;

   procedure setType (This : Lexer; tType : Token_Kind) is
   begin
      This.Token_Type := ttype;
   end setType;

   procedure setChannel (This : Lexer; Some_Channel : Channel_Number) is
   begin
      This.channel := Some_channel;
   end setChannel;

   function getAllTokens (This : Lexer) return Token_List is
      tokens : Token_List := Token.Container.Empty_Vector;
      t := This.nextToken;
      while t.getType /= CommonToken.EOF loop
         Token.Container.append (tokens, t);
         t := This.nextToken;
      end loop;
      return tokens
   end getAllTokens;

   procedure recover (This : Lexer; e : LexerNoViableAltException) is
   begin
      if This.input!.LA (1) /= BufferedTokenStream.EOF then
         -- skip a char and again;
         This.getInterpreter.consume (This.input!);
      end if;
   end recover;

   procedure notifyListeners (This : Lexer; e : LexerNoViableAltException; recognizer: Recognizer_T is
      msg : UString;
   begin
      text : constant UString;

      declare
      begin
         text := This.input!.getText (Interval.Set (_tokenStartCharIndex, This.input!.index));
      exception
         when others =>
            text := "<unknown>";
      end;

      msg := "token recognition error at: '" & getErrorDisplay (text)) & ''';

      listener : constant := This.getErrorListenerDispatch;
      listener.syntaxError (recognizer, null, This.tokenStartLine, This.tokenStartCharPositionInLine, msg, e);
   end notifyListeners;

   function getErrorDisplay (This : Lexer; s : UString) return UString is
      buf := "";
   begin
      for c of s loop
         buf := @ & getErrorDisplay (c);
      end loop;
      return buf;
   end getErrorDisplay;

   function getErrorDisplay (This : Lexer; c : Character) return UString is
   begin
      if c.integerValue = CommonToken.EOF then
         return "<EOF>";
      else
         case c is
            when "\n" =>
                  return "\\n";
            when "\t" =>
                  return "\\t";
            when "\r" =>
                  return "\\r";
            when others =>
                  return UString (c);
            end case;
      end if;
   end getErrorDisplay;

   procedure recover (This : Lexer; re : AnyObject) is
   begin
      -- TODO: Do we lose character or line position information?
      This.input!.consume;
   end recover;

   -- internal
   function makeTokenSourceAndStream (This : Lexer) return TokenSourceAndStream
      is (TokenSourceAndStream (This, This.input));

end ANTLR.Runtime.Recognizers.Lexers;
