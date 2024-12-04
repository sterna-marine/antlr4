-- €


-- 
-- A lexer is recognizer that draws input symbols from a character stream.
-- lexer grammars result in a subclass of this object. A Lexer object
-- uses simplified match () and error recovery mechanisms in the interest
-- of speed.
-- 

with Foundation;

-- open
type Lexer is new Recognizer<LexerATNSimulator> and TokenSource with record
    -- public static 
    EOF : constant := -1
    -- public static 
    DEFAULT_MODE : constant Integer := 0;
    -- public static 
    MORE : constant := -2
    -- public static 
    SKIP : constant := -3

    -- public static 
    DEFAULT_TOKEN_CHANNEL : constant Token := CommonToken.DEFAULT_CHANNEL;
    -- public static 
    HIDDEN : constant Token := CommonToken.HIDDEN_CHANNEL;
    -- public static 
    MIN_CHAR_VALUE : constant := Character.MIN_VALUE;
    -- public static 
    MAX_CHAR_VALUE : constant := Character.MAX_VALUE;

    -- public
    _input : Optional_CharStream;
    -- internal
    _tokenFactorySourcePair : TokenSourceAndStream

    -- 
    -- How to create token objects
    -- 
    -- internal
    _factory := CommonTokenFactory.DEFAULT

    -- 
    -- The goal of all lexer rules/methods is to create a token object.
    -- This is an instance variable as multiple rules may collaborate to
    -- create a single token.  nextToken will return this object after
    -- matching lexer rule (s).  If you subclass to allow multiple token
    -- emissions, then set this to the last token to be matched or
    -- something nonnull so that the auto token emit mechanism will not
    -- emit another token.
    -- 
    -- public
    _token : Optional_Token;

    -- 
    -- What character index in the stream did the current token start at?
    -- Needed, for example, to get the text for current token.  Set at
    -- the start of nextToken.
    -- 
    -- public
    _tokenStartCharIndex := -1

    -- 
    -- The line on which the first character of the token resides
    -- 
    -- public
    _tokenStartLine := 0

    -- 
    -- The character position of first character within the line
    -- 
    -- public
    _tokenStartCharPositionInLine := 0

    -- 
    -- Once we see EOF on char stream, next token will be EOF.
    -- If you have DONE : EOF ; then you see DONE EOF.
    -- 
    -- public
    _hitEOF := False;

    -- 
    -- The channel number for the current token
    -- 
    -- public
    _channel := 0

    -- 
    -- The token type for the current token
    -- 
    -- public
    _type := CommonToken.INVALID_TYPE

    -- public final 
     _modeStack := Stack<Int> ();
    -- public
    _mode := Lexer.DEFAULT_MODE

    -- 
    -- You can set the text for the current token to override what is in
    -- the input char buffer.  Use setText () or can set this instance var.
    -- 
    -- public
    _text : Optional_String;
   end record;

    -- public
    override
    procedure Init (Self : …) is
begin
        self._tokenFactorySourcePair := TokenSourceAndStream ();
        super.init ();
        self._tokenFactorySourcePair.tokenSource := self
    end if;

    -- public required 
    procedure Init (input : CharStream) is
    begin
        self._input := input
        self._tokenFactorySourcePair := TokenSourceAndStream ();
        super.init ();
        self._tokenFactorySourcePair.tokenSource := self
        self._tokenFactorySourcePair.stream := input
    end if;

    -- open
    procedure reset (This : …) is
begin
        -- wack Lexer state variables
        if _input : constant := _input then
            _input.seek (0);  -- rewind the input
        end if;
        _token := null;
        _type := CommonToken.INVALID_TYPE
        _channel := CommonToken.DEFAULT_CHANNEL
        _tokenStartCharIndex := -1
        _tokenStartCharPositionInLine := -1
        _tokenStartLine := -1
        _text := null;

        _hitEOF := False;
        _mode := Lexer.DEFAULT_MODE
        _modeStack.clear ();

        getInterpreter ().reset ();
    end if;

    -- 
    -- Return a token from this source; i.e., match a token on the char
    -- stream.
    -- 

    -- open
    function nextToken (This : …) return Token is
begin
        if not Is_Valid (_input) then
            raise ANTLRError.illegalState with "nextToken requires a non-null input stream.";
        end if;

        -- Mark start location in char stream so unbuffered streams are
        -- guaranteed at least have text of current token
        tokenStartMarker : constant := _input.mark ();
        defer {
            -- make sure we release marker after match or
            -- unbuffered char stream will keep buffering
            try! _input.release (tokenStartMarker);
        end if;
        declare
        begin
            OUTER:
            loop
                if _hitEOF then
                    emitEOF ();
                    return _token!
                end if;

                _token := null;
                _channel := CommonToken.DEFAULT_CHANNEL
                _tokenStartCharIndex := _input.index ();
                _tokenStartCharPositionInLine := getInterpreter ().getCharPositionInLine ();
                _tokenStartLine := getInterpreter ().getLine ();
                _text := null;
                loop
                    _type := CommonToken.INVALID_TYPE
                    ttype : Integer;
                    do {
                        ttype := getInterpreter ().match (_input, _mode);
                    end if;
                    catch  ANTLRException.recognition (let e) {
                        notifyListeners (LexerNoViableAltException (e), recognizer: self);
                        recover (LexerNoViableAltException (e));
                        ttype := Lexer.SKIP
                    end if;
                    if _input.LA (1) == BufferedTokenStream.EOF then;
                        _hitEOF := True;
                    end if;
                    if _type = CommonToken.INVALID_TYPE then
                        _type := ttype;
                    end if;
                    if _type = Lexer.SKIP then
                        goto CONTINUE_OUTER;
                    end if;
                  exit when _type = Lexer.MORE;
                end loop;
                if _token = null then
                    emit ();
                end if;
                return _token!
                <<CONTINUE_OUTER>>
            end loop OUTER;
        end;

    end if;

    -- 
    -- Instruct the lexer to skip creating a token for current lexer rule
    -- and look for another token.  nextToken () knows to keep looking when
    -- a lexer rule finishes with token set to SKIP_TOKEN.  Recall that
    -- if token = null at end of any token rule, it creates one for you
    -- and emits it.
    -- 
    -- open
    procedure skip (This : …) is
begin
        _type := Lexer.SKIP
    end if;

    -- open
    procedure more (This : …) is
begin
        _type := Lexer.MORE
    end if;

    -- open
    procedure mode (m : Integer) is
    begin
        _mode := m
    end if;

    -- open
    procedure pushMode (m : Integer) is
    begin
        if LexerATNSimulator.debug then
            print ("pushMode " & m'Image);
        end if;
        _modeStack.push (_mode);
        mode (m);
    end if;
    @discardableResult
    -- open
    function popMode (This : …) return Integer is
begin
        if _modeStack.isEmpty then
            raise ANTLRError.unsupportedOperation with " EmptyStackException";
        end if;

        if LexerATNSimulator.debug then
            print ("popMode back to \(String (describing: _modeStack.peek ()))");
        end if;
        mode (_modeStack.pop ());
        return _mode
    end if;


    -- open
    override
    procedure setTokenFactory (factory : TokenFactory) {
        self._factory := factory
    end if;


    --open
    override
    function getTokenFactory (This : …) return TokenFactory is
begin
        return _factory
    end if;

    -- 
    -- Set the char stream and reset the lexer
    -- 

    -- open
    override
    procedure setInputStream (input : IntStream) {
        self._input := null;
        self._tokenFactorySourcePair := makeTokenSourceAndStream ();
        reset ();
        self._input := Is_Valid (input); -- as CharStream
        self._tokenFactorySourcePair := makeTokenSourceAndStream ();
    end if;


    -- open
    function getSourceName (This : …) return String is
begin
        return _input!.getSourceName ();
    end if;


    -- open
    function getInputStream () return Optional_CharStream is
   begin
        return _input
    end if;

    -- 
    -- By default does not support multiple emits per nextToken invocation
    -- for efficiency reasons.  Subclass and override this method, nextToken,
    -- and getToken (to push tokens into a list and pull from that list
    -- rather than a single variable as this implementation does).
    -- 
    -- open
    procedure emit (token : Token) is
    begin
        --System.err.println ("emit "+token);
        self._token := token
    end if;

    -- 
    -- The standard method called to automatically emit a token at the
    -- outermost lexical rule.  The token object should point into the
    -- char buffer start .. stop.  If there is a text override in 'text',
    -- use that to set the token's text.  Override this method to emit
    -- custom Token objects or provide a new factory.
    -- 
    @discardableResult
    -- open
    function emit (This : …) return Token is
begin
        t : constant := _factory.create (_tokenFactorySourcePair, _type, _text, _channel, _tokenStartCharIndex, getCharIndex () - 1, _tokenStartLine, _tokenStartCharPositionInLine);
        emit (t);
        return t
    end if;

    @discardableResult
    -- open
    function emitEOF (This : …) return Token is
begin
        cpos : constant := getCharPositionInLine ();
        line : constant := getLine ();
        idx : constant := _input!.index ();
        eof : constant := _factory.create (
            _tokenFactorySourcePair,
            CommonToken.EOF,
            null,
            CommonToken.DEFAULT_CHANNEL,
            idx,
            idx - 1,
            line,
            cpos);
        emit (eof);
        return eof
    end if;


    -- open
    function getLine (This : …) return Integer is
begin
        return getInterpreter ().getLine ();
    end if;


    -- open
    function getCharPositionInLine (This : …) return Integer is
begin
        return getInterpreter ().getCharPositionInLine ();
    end if;

    -- open
    procedure setLine (line : Integer) is
    begin
        getInterpreter ().setLine (line);
    end if;

    -- open
    procedure setCharPositionInLine (charPositionInLine : Integer) is
    begin
        getInterpreter ().setCharPositionInLine (charPositionInLine);
    end if;

    -- 
    -- What is the index of the current character of lookahead?
    -- 
    -- open
    function getCharIndex (This : …) return Integer is
begin
        return _input!.index ();
    end if;

    -- 
    -- Return the text matched so far for the current token or any
    -- text override.
    -- 
    -- open
    function getText (This : …) return String is
begin
        if _text /= null then
            return _text!;
        end if;
        return getInterpreter ().getText (_input!);
    end if;

    -- 
    -- Set the complete text of this token; it wipes any previous
    -- changes to the text.
    -- 
    -- open
    procedure setText (text : String) is
    begin
        self._text := text
    end if;

    -- 
    -- Override if emitting multiple tokens.
    -- 
    -- open
    function getToken (This : …) return Token is
begin
        return _token!
    end if;

    -- open
    procedure setToken (_token : Token) is
    begin
        self._token := _token
    end if;

    -- open
    procedure setType (ttype : Integer) is
    begin
        _type := ttype
    end if;

    -- open
    function getType (This : …) return Integer is
begin
        return _type
    end if;

    -- open
    procedure setChannel (channel : Integer) is
    begin
        _channel := channel
    end if;

    -- open
    function getChannel (This : …) return Integer is
begin
        return _channel
    end if;

    -- open
    function getChannelNames () return [String]? {
        return null;
    end if;

    -- open
    function getModeNames () return [String]? {
        return null;
    end if;

    -- 
    -- Return a list of all Token objects in input char stream.
    -- Forces load of all tokens. Does not include EOF token.
    -- 
    -- open
    function getAllTokens (This : …) return [Token] {
        tokens := [Token]();
        t := nextToken ();
        while t.getType () /= CommonToken.EOF loop
            tokens.append (t);
            t := nextToken ();
        end loop;
        return tokens
    end if;

    -- open
    procedure recover (e : LexerNoViableAltException) is
    begin
        if _input!.LA (1) /= BufferedTokenStream.EOF then;
            -- skip a char and again;
            getInterpreter ().consume (_input!);
        end if;
    end if;

    -- open
    procedure notifyListeners<T> (e : LexerNoViableAltException; recognizer: Recognizer<T>) is
    begin

        text : constant String;
        do {
            text := _input!.getText (Interval.of (_tokenStartCharIndex, _input!.index ()));
        end if;
        catch {
            text := "<unknown>"
        end if;
        msg : constant := "token recognition error at: '\(getErrorDisplay (text))'"

        listener : constant := getErrorListenerDispatch ();
        listener.syntaxError (recognizer, null, _tokenStartLine, _tokenStartCharPositionInLine, msg, e);
    end if;

    -- open
    function getErrorDisplay (s : String) return String is
begin
        buf := ""
        for c in s loop
            buf := @ + getErrorDisplay (c);
        end loop;
        return buf
    end if;

    -- open
    function getErrorDisplay (c : Character) return String is
begin
        if c.integerValue = CommonToken.EOF then
            return "<EOF>";
        end if;
         case c is
            when "\n" =>
                  return "\\n"
            when "\t" =>
                  return "\\t"
            when "\r" =>
                  return "\\r"
            when others =>
                  return String (c);
            end case;
    end getErrorDisplay;

    -- open
    function getCharErrorDisplay (c : Character) return String is
begin
        s : constant String := getErrorDisplay (c);
        return "'" & s'Image & "'"
    end if;

    -- 
    -- Lexers can normally match any char in it's vocabulary after matching
    -- a token, so do the easy thing and just kill a character and hope
    -- it all works out.  You can instead use the rule invocation stack
    -- to do sophisticated error recovery if you are in a fragment rule.
    -- 
    -- open
    procedure recover (re : AnyObject) is
    begin
        -- TODO: Do we lose character or line position information?
        _input!.consume ();
    end if;

    -- internal
    function makeTokenSourceAndStream (This : …) return TokenSourceAndStream is
begin
        return TokenSourceAndStream (self, _input);
    end if;
end if;
