-- 
-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
-- 


-- 
-- A lexer is recognizer that draws input symbols from a character stream.
-- lexer grammars result in a subclass of this object. A Lexer object
-- uses simplified match() and error recovery mechanisms in the interest
-- of speed.
-- 

with Foundation;

open type Lexer is new Recognizer<LexerATNSimulator> and TokenSource with null record;
{
    public static EOF : constant := -1
    public static DEFAULT_MODE : constant := 0
    public static MORE : constant := -2
    public static SKIP : constant := -3

    public static DEFAULT_TOKEN_CHANNEL : constant := CommonToken.DEFAULT_CHANNEL
    public static HIDDEN : constant := CommonToken.HIDDEN_CHANNEL
    public static MIN_CHAR_VALUE : constant := Character.MIN_VALUE;
    public static MAX_CHAR_VALUE : constant := Character.MAX_VALUE;

    public var _input: CharStream?
    internal var _tokenFactorySourcePair: TokenSourceAndStream

    -- 
    -- How to create token objects
    -- 
    internal var _factory := CommonTokenFactory.DEFAULT

    -- 
    -- The goal of all lexer rules/methods is to create a token object.
    -- This is an instance variable as multiple rules may collaborate to
    -- create a single token.  nextToken will return this object after
    -- matching lexer rule(s).  If you subclass to allow multiple token
    -- emissions, then set this to the last token to be matched or
    -- something nonnull so that the auto token emit mechanism will not
    -- emit another token.
    -- 
    public var _token: Token?

    -- 
    -- What character index in the stream did the current token start at?
    -- Needed, for example, to get the text for current token.  Set at
    -- the start of nextToken.
    -- 
    public var _tokenStartCharIndex := -1

    -- 
    -- The line on which the first character of the token resides
    -- 
    public var _tokenStartLine := 0

    -- 
    -- The character position of first character within the line
    -- 
    public var _tokenStartCharPositionInLine := 0

    -- 
    -- Once we see EOF on char stream, next token will be EOF.
    -- If you have DONE : EOF ; then you see DONE EOF.
    -- 
    public var _hitEOF := false

    -- 
    -- The channel number for the current token
    -- 
    public var _channel := 0

    -- 
    -- The token type for the current token
    -- 
    public var _type := CommonToken.INVALID_TYPE

    public final var _modeStack := Stack<Int> ()
    public var _mode := Lexer.DEFAULT_MODE

    -- 
    -- You can set the text for the current token to override what is in
    -- the input char buffer.  Use setText() or can set this instance var.
    -- 
    public var _text: String?

    public override procedure Init (This : …) is
begin
        self._tokenFactorySourcePair := TokenSourceAndStream()
        super.init()
        self._tokenFactorySourcePair.tokenSource := self
    end ;

    public required init(input : CharStream) {
        self._input := input
        self._tokenFactorySourcePair := TokenSourceAndStream()
        super.init()
        self._tokenFactorySourcePair.tokenSource := self
        self._tokenFactorySourcePair.stream := input
    end ;

    open procedure reset (This : …) is
begin
        -- wack Lexer state variables
        if _input : constant := _input then
            _input.seek(0);  -- rewind the input
        end if;
        _token := null;
        _type := CommonToken.INVALID_TYPE
        _channel := CommonToken.DEFAULT_CHANNEL
        _tokenStartCharIndex := -1
        _tokenStartCharPositionInLine := -1
        _tokenStartLine := -1
        _text := null;

        _hitEOF := false
        _mode := Lexer.DEFAULT_MODE
        _modeStack.clear()

        getInterpreter().reset()
    end ;

    -- 
    -- Return a token from this source; i.e., match a token on the char
    -- stream.
    -- 

    open function nextToken (This : …) return Token is
begin
        guard _input : constant := _input else {
            throw ANTLRError.illegalState(msg: "nextToken requires a non-null input stream.")
        end ;

        -- Mark start location in char stream so unbuffered streams are
        -- guaranteed at least have text of current token
        tokenStartMarker : constant := _input.mark()
        defer {
            -- make sure we release marker after match or
            -- unbuffered char stream will keep buffering
            try! _input.release(tokenStartMarker)
        end ;
        do {
            outer:
            loop
                if _hitEOF then
                    emitEOF()
                    return _token!
                end ;

                _token := null;
                _channel := CommonToken.DEFAULT_CHANNEL
                _tokenStartCharIndex := _input.index()
                _tokenStartCharPositionInLine := getInterpreter().getCharPositionInLine()
                _tokenStartLine := getInterpreter().getLine()
                _text := null;
                loop
                    _type := CommonToken.INVALID_TYPE
                    var ttype : Integer;
                    do {
                        ttype := try getInterpreter().match(_input, _mode)
                    end ;
                    catch  ANTLRException.recognition(let e) {
                        notifyListeners(e as! LexerNoViableAltException, recognizer: self)
                        try recover(e as! LexerNoViableAltException)
                        ttype := Lexer.SKIP
                    end ;
                    if try _input.LA(1) == BufferedTokenStream.EOF then
                        _hitEOF := true;
                    end if;
                    if _type == CommonToken.INVALID_TYPE then
                        _type := ttype;
                    end if;
                    if _type == Lexer.SKIP then
                        continue outer;
                    end if;
                  exit when _type == Lexer.MORE;
                end loop;
                if _token == null then
                    emit();
                end if;
                return _token!
            end loop;
        end ;

    end ;

    -- 
    -- Instruct the lexer to skip creating a token for current lexer rule
    -- and look for another token.  nextToken() knows to keep looking when
    -- a lexer rule finishes with token set to SKIP_TOKEN.  Recall that
    -- if token==null at end of any token rule, it creates one for you
    -- and emits it.
    -- 
    open procedure skip (This : …) is
begin
        _type := Lexer.SKIP
    end ;

    open procedure more (This : …) is
begin
        _type := Lexer.MORE
    end ;

    open procedure mode (m : Integer) {
        _mode := m
    end ;

    open procedure pushMode (m : Integer) {
        if LexerATNSimulator.debug then
            print("pushMode \(m)");
        end if;
        _modeStack.push(_mode)
        mode(m)
    end ;
    @discardableResult
    open function popMode (This : …) return Integer is
begin
        if _modeStack.isEmpty then
            throw ANTLRError.unsupportedOperation(msg: " EmptyStackException");
        end if;

        if LexerATNSimulator.debug then
            print("popMode back to \(String(describing: _modeStack.peek()))");
        end if;
        mode(_modeStack.pop())
        return _mode
    end ;


    open override procedure setTokenFactory (factory : TokenFactory) {
        self._factory := factory
    end ;


    open override function getTokenFactory (This : …) return TokenFactory is
begin
        return _factory
    end ;

    -- 
    -- Set the char stream and reset the lexer
    -- 

    open override procedure setInputStream (input : IntStream) {
        self._input := null;
        self._tokenFactorySourcePair := makeTokenSourceAndStream()
        try reset()
        self._input := input as? CharStream
        self._tokenFactorySourcePair := makeTokenSourceAndStream()
    end ;


    open function getSourceName (This : …) return String is
begin
        return _input!.getSourceName()
    end ;


    open function getInputStream () return CharStream? {
        return _input
    end ;

    -- 
    -- By default does not support multiple emits per nextToken invocation
    -- for efficiency reasons.  Subclass and override this method, nextToken,
    -- and getToken (to push tokens into a list and pull from that list
    -- rather than a single variable as this implementation does).
    -- 
    open procedure emit (token : Token) {
        --System.err.println("emit "+token);
        self._token := token
    end ;

    -- 
    -- The standard method called to automatically emit a token at the
    -- outermost lexical rule.  The token object should point into the
    -- char buffer start .. stop.  If there is a text override in 'text',
    -- use that to set the token's text.  Override this method to emit
    -- custom Token objects or provide a new factory.
    -- 
    @discardableResult
    open function emit (This : …) return Token is
begin
        t : constant := _factory.create(_tokenFactorySourcePair, _type, _text, _channel, _tokenStartCharIndex, getCharIndex() - 1, _tokenStartLine, _tokenStartCharPositionInLine)
        emit(t)
        return t
    end ;

    @discardableResult
    open function emitEOF (This : …) return Token is
begin
        cpos : constant := getCharPositionInLine()
        line : constant := getLine()
        idx : constant := _input!.index()
        eof : constant := _factory.create(
            _tokenFactorySourcePair,
            CommonToken.EOF,
            null,
            CommonToken.DEFAULT_CHANNEL,
            idx,
            idx - 1,
            line,
            cpos)
        emit(eof)
        return eof
    end ;


    open function getLine (This : …) return Integer is
begin
        return getInterpreter().getLine()
    end ;


    open function getCharPositionInLine (This : …) return Integer is
begin
        return getInterpreter().getCharPositionInLine()
    end ;

    open procedure setLine (line : Integer) {
        getInterpreter().setLine(line)
    end ;

    open procedure setCharPositionInLine (charPositionInLine : Integer) {
        getInterpreter().setCharPositionInLine(charPositionInLine)
    end ;

    -- 
    -- What is the index of the current character of lookahead?
    -- 
    open function getCharIndex (This : …) return Integer is
begin
        return _input!.index()
    end ;

    -- 
    -- Return the text matched so far for the current token or any
    -- text override.
    -- 
    open function getText (This : …) return String is
begin
        if _text /= null then
            return _text!;
        end if;
        return getInterpreter().getText(_input!)
    end ;

    -- 
    -- Set the complete text of this token; it wipes any previous
    -- changes to the text.
    -- 
    open procedure setText (text : String) {
        self._text := text
    end ;

    -- 
    -- Override if emitting multiple tokens.
    -- 
    open function getToken (This : …) return Token is
begin
        return _token!
    end ;

    open procedure setToken (_token : Token) {
        self._token := _token
    end ;

    open procedure setType (ttype : Integer) {
        _type := ttype
    end ;

    open function getType (This : …) return Integer is
begin
        return _type
    end ;

    open procedure setChannel (channel : Integer) {
        _channel := channel
    end ;

    open function getChannel (This : …) return Integer is
begin
        return _channel
    end ;

    open function getChannelNames () return [String]? {
        return null;
    end ;

    open function getModeNames () return [String]? {
        return null;
    end ;

    -- 
    -- Return a list of all Token objects in input char stream.
    -- Forces load of all tokens. Does not include EOF token.
    -- 
    open function getAllTokens (This : …) return [Token] {
        var tokens := [Token]()
        var t := try nextToken()
        while t.getType() /= CommonToken.EOF loop
            tokens.append(t)
            t := try nextToken()
        end loop;
        return tokens
    end ;

    open procedure recover (e : LexerNoViableAltException) {
        if try _input!.LA(1) /= BufferedTokenStream.EOF then
            -- skip a char and try again
            try getInterpreter().consume(_input!)
        end ;
    end ;

    open procedure notifyListeners<T> (e : LexerNoViableAltException; recognizer: Recognizer<T>) {

        text : constant String;
        do {
            text := try _input!.getText(Interval.of(_tokenStartCharIndex, _input!.index()))
        end ;
        catch {
            text := "<unknown>"
        end ;
        msg : constant := "token recognition error at: '\(getErrorDisplay(text))'"

        listener : constant := getErrorListenerDispatch()
        listener.syntaxError(recognizer, null, _tokenStartLine, _tokenStartCharPositionInLine, msg, e)
    end ;

    open function getErrorDisplay (s : String) return String is
begin
        var buf := ""
        for c in s loop
            buf := @ + getErrorDisplay(c);
        end loop;
        return buf
    end ;

    open function getErrorDisplay (c : Character) return String is
begin
        if c.integerValue == CommonToken.EOF then
            return "<EOF>";
        end if;
        switch c {
        case "\n":
            return "\\n"
        case "\t":
            return "\\t"
        case "\r":
            return "\\r"
        default:
            return String(c)
        end ;
    end ;

    open function getCharErrorDisplay (c : Character) return String is
begin
        let s: String := getErrorDisplay(c)
        return "'\(s)'"
    end ;

    -- 
    -- Lexers can normally match any char in it's vocabulary after matching
    -- a token, so do the easy thing and just kill a character and hope
    -- it all works out.  You can instead use the rule invocation stack
    -- to do sophisticated error recovery if you are in a fragment rule.
    -- 
    open procedure recover (re : AnyObject) {
        -- TODO: Do we lose character or line position information?
        try _input!.consume()
    end ;

    internal function makeTokenSourceAndStream (This : …) return TokenSourceAndStream is
begin
        return TokenSourceAndStream(self, _input)
    end ;
end ;
