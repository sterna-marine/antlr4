-- €

package body ANTLR.Runtime.Lexer is

   override
   procedure Init (Self : Lexer) is
   begin
      self._tokenFactorySourcePair := TokenSourceAndStream ();
      Recognizer.init (); -- Super
      self._tokenFactorySourcePair.tokenSource := self;
   end Init;

   procedure Init (input : CharStream) is
   begin
      self._input := input;
      self._tokenFactorySourcePair := TokenSourceAndStream ();
      super.init ();
      self._tokenFactorySourcePair.tokenSource := self;
      self._tokenFactorySourcePair.stream := input;
   end Init;

   procedure reset (This : Lexer) is
   begin
      -- wack Lexer state variables
      _input : constant := This._input
      if Is_Valid (_input) then
         _input.seek (0);  -- rewind the input
      end if;
      _token := (Valid => False);
      _Token_Type := CommonToken.INVALID_Token_Type;
      _channel := CommonToken.DEFAULT_CHANNEL;
      _tokenStartCharIndex := -1;
      _tokenStartCharPositionInLine := -1;
      _tokenStartLine := -1;
      _text := (Valid => False);

      _hitEOF := False;
      _mode := DEFAULT_MODE
      _modeStack.clear ();

      getInterpreter ().reset ();
   end reset;

   function nextToken (This : Lexer) return Token is
   begin
      if not Is_Valid (This._input) then
         raise ANTLRError.illegalState with "nextToken requires a non-null input stream.";
      end if;

      -- Mark start location in char stream so unbuffered streams are
      -- guaranteed at least have text of current token
      tokenStartMarker : constant := This._input.mark ();

      declare
      begin
         OUTER:
            loop
               if _hitEOF then
                  emitEOF ();
                  return This._token!
               end if;

               This._token := null;
               This._channel := CommonToken.DEFAULT_CHANNEL
               This._tokenStartCharIndex := This._input.index ();
               This._tokenStartCharPositionInLine := getInterpreter ().getCharPositionInLine ();
               This._tokenStartLine := getInterpreter ().getLine ();
               This._text := null;
               loop
                  This._Token_Type := CommonToken.INVALID_Token_Type
                  tType : Token_Kind;

                  declare
                  begin
                     ttype := getInterpreter ().match (This._input, This._mode);
                  exception
                     when ANTLRException.recognition => (let e) 
                        notifyListeners (LexerNoViableAltException (e), recognizer: This);
                        recover (LexerNoViableAltException (e));
                        ttype := Lexer.SKIP
                  end;

                  if This._input.LA (1) = BufferedTokenStream.EOF then;
                     This._hitEOF := True;
                  end if;
                  if This._Token_Type = CommonToken.INVALID_Token_Type then
                     This._Token_Type := ttype;
                  end if;
                  if This._Token_Type = Lexer.SKIP then
                     goto CONTINUE_OUTER;
                  end if;
                  exit when This._Token_Type = Lexer.MORE;
               end loop;

               if This._token = null then
                  emit ();
               end if;

               return _token!;

               <<CONTINUE_OUTER>>
            end loop OUTER;
      end;
      defer:
         begin 
            -- make sure we release marker after match or
            -- unbuffered char stream will keep buffering
            This._input.release (tokenStartMarker);; -- try!
         end defer;
   end nextToken;

   procedure skip (This : Lexer) is
   begin
      This._Token_Type := Lexer.SKIP;
   end skip;

   procedure more (This : Lexer) is
   begin
      This._Token_Type := Lexer.MORE;
   end more;

   procedure mode (This : Lexer; m : Lexer_Mode) is
   begin
      This._mode := m;
   end mode;

   procedure pushMode (This : Lexer; m : Lexer_Mode) is
   begin
      if LexerATNSimulator.debug then
         print ("pushMode " & m'Image);
      end if;
      This._modeStack.push (This._mode);
      mode (m);
   end pushMode;

   function popMode (This : Lexer) return Lexer_Mode is
   begin
      if _modeStack.isEmpty then
         raise ANTLRError.unsupportedOperation with " EmptyStackException";
      end if;

      if LexerATNSimulator.debug then
         print ("popMode back to " & String (describing => This._modeStack.peek ()));
      end if;
      mode (This._modeStack.pop ());
      return This._mode;
   end popMode;

   override
   procedure setTokenFactory (This : Lexer; factory : TokenFactory) is
   begin
      This._factory := factory;
   end setTokenFactory;

   override
   procedure setInputStream (This : Lexer; input : IntStream) is
   begin
      This._input := null;
      This._tokenFactorySourcePair := makeTokenSourceAndStream ();
      reset ();
      This._input := Is_Valid (input); -- as CharStream
      This._tokenFactorySourcePair := makeTokenSourceAndStream ();
   end setInputStream;

   procedure emit (This : Lexer; token : Token) is
   begin
      --System.err.println ("emit "+token);
      This._token := token;
   end emit;

   function emit (This : Lexer) return Token is
      t : Token constant := _factory.create (_tokenFactorySourcePair, _Token_Type, _text, _channel, _tokenStartCharIndex, getCharIndex () - 1, _tokenStartLine, _tokenStartCharPositionInLine);
   begin
      emit (t);
      return t;
   end emit;

   function emitEOF (This : Lexer) return Token is
      cpos : constant := getCharPositionInLine ();
      line : constant := getLine ();
      idx : constant := This._input!.index ();
      eof : constant := This._factory.create (
         This._tokenFactorySourcePair,
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
      getInterpreter ().setLine (line);
   end setLine;

   procedure setCharPositionInLine (This : Lexer; charPositionInLine : Integer) is
   begin
      getInterpreter ().setCharPositionInLine (charPositionInLine);
   end setCharPositionInLine;

   function getText (This : Lexer) return String is
   begin
      if This._text /= null then
         return This._text!;
      else
         return getInterpreter ().getText (This._input!);
      end if;
   end getText;

   procedure setText (This : Lexer; text : String) is
   begin
      This._text := text;
   end setText;

   procedure setToken (This : Lexer; _token : Token) is
   begin
      This._token := _token;
   end setToken;

   procedure setType (This : Lexer; tType : Token_Kind) is
   begin
      This._Token_Type := ttype;
   end setType;

   procedure setChannel (This : Lexer; Channel : Channel_Number) is
   begin
      This._channel := channel;
   end setChannel;

   function getAllTokens (This : Lexer) return Token.Container.Vector is
      tokens : Token.Container.Vector := Token.Container.Empty_Vector;
      t := nextToken ();
      while t.getType () /= CommonToken.EOF loop
         Token.Container.append (tokens, t);
         t := nextToken ();
      end loop;
      return tokens
   end getAllTokens;

   procedure recover (This : Lexer; e : LexerNoViableAltException) is
   begin
      if This._input!.LA (1) /= BufferedTokenStream.EOF then;
         -- skip a char and again;
         getInterpreter ().consume (This._input!);
      end if;
   end recover;

   generic
      type T is private;
   procedure notifyListeners (This : Lexer; e : LexerNoViableAltException; recognizer: Recognizer<T>) is
      msg : UString;
   begin
      text : constant String;

      declare
      begin
         text := This._input!.getText (Interval.of (_tokenStartCharIndex, This._input!.index ()));
      exception
         when others =>
            text := "<unknown>";
      end;

      msg := "token recognition error at: '" & getErrorDisplay (text))& "'";

      listener : constant := getErrorListenerDispatch ();
      listener.syntaxError (recognizer, null, _tokenStartLine, _tokenStartCharPositionInLine, msg, e);
   end notifyListeners;

   function getErrorDisplay (This : Lexer; s : String) return String is
      buf := "";
   begin
      for c in s loop
         buf := @ & getErrorDisplay (c);
      end loop;
      return buf;
   end getErrorDisplay;

   function getErrorDisplay (This : Lexer; c : Character) return String is
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
                  return String (c);
            end case;
      end if;
   end getErrorDisplay;

   procedure recover (This : Lexer; re : AnyObject) is
   begin
      -- TODO: Do we lose character or line position information?
      This._input!.consume ();
   end recover;

   -- internal
   function makeTokenSourceAndStream (This : Lexer) return TokenSourceAndStream
      is (TokenSourceAndStream (This, This._input));

end  ANTLR.Runtime.Lexer;
