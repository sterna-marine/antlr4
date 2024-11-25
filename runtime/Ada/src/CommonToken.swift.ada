-- 
-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
-- 



public type CommonToken is new WritableToken with null record;
{
    -- 
    -- This is the backing field for _#getType_ and _#setType_.
    -- 
    -- internal
    type : Integer;

    -- 
    -- This is the backing field for _#getLine_ and _#setLine_.
    -- 
    -- internal
    line := 0

    -- 
    -- This is the backing field for _#getCharPositionInLine_ and
    -- _#setCharPositionInLine_.
    -- 
    -- internal
    charPositionInLine := -1
    -- set to invalid position

    -- 
    -- This is the backing field for _#getChannel_ and
    -- _#setChannel_.
    -- 
    -- internal
    channel := DEFAULT_CHANNEL

    -- 
    -- This is the backing field for _#getTokenSource_ and
    -- _#getInputStream_.
    -- 
    -- 
    -- These properties share a field to reduce the memory footprint of
    -- _org.antlr.v4.runtime.CommonToken_. Tokens created by a _org.antlr.v4.runtime.CommonTokenFactory_ from
    -- the same source and input stream share a reference to the same
    -- _org.antlr.v4.runtime.misc.Pair_ containing these values.
    -- 

    internal let source: TokenSourceAndStream

    -- 
    -- This is the backing field for _#getText_ when the token text is
    -- explicitly set in the constructor or via _#setText_.
    -- 
    -- - seealso: #getText()
    -- 
    -- internal
    text : String?

    -- 
    -- This is the backing field for _#getTokenIndex_ and
    -- _#setTokenIndex_.
    -- 
    -- internal
    index := -1

    -- 
    -- This is the backing field for _#getStartIndex_ and
    -- _#setStartIndex_.
    -- 
    -- internal
    start := 0

    -- 
    -- This is the backing field for _#getStopIndex_ and
    -- _#setStopIndex_.
    -- 
    -- internal
    stop := 0

    -- 
    -- Constructs a new _org.antlr.v4.runtime.CommonToken_ with the specified token type.
    -- 
    -- - parameter type: The token type.
    -- 

    -- private
    _visited : Boolean := False;

    -- public 
    procedure Init (Self : in out …; type : Integer) {
        self.type := type
        self.source := TokenSourceAndStream.EMPTY
    end ;

    -- public 
    procedure Init (Self : in out …; source : TokenSourceAndStream; type : Integer; channel : Integer; start : Integer; stop : Integer) {
        self.source := source
        self.type := type
        self.channel := channel
        self.start := start
        self.stop := stop
        if tsource : constant := source.tokenSource then
            self.line := tsource.getLine()
            self.charPositionInLine := tsource.getCharPositionInLine()
        end ;
    end ;

    -- 
    -- Constructs a new _org.antlr.v4.runtime.CommonToken_ with the specified token type and
    -- text.
    -- 
    -- - parameter type: The token type.
    -- - parameter text: The text of the token.
    -- 
    -- public 
    procedure Init (Self : in out …; type : Integer; text : String?) {
        self.type := type
        self.channel := CommonToken.DEFAULT_CHANNEL
        self.text := text
        self.source := TokenSourceAndStream.EMPTY
    end ;

    -- 
    -- Constructs a new _org.antlr.v4.runtime.CommonToken_ as a copy of another _org.antlr.v4.runtime.Token_.
    --
    -- - parameter oldToken: The token to copy.
    -- 
    -- public 
    procedure Init (Self : in out …; oldToken : Token) {
        type := oldToken.getType()
        line := oldToken.getLine()
        index := oldToken.getTokenIndex()
        charPositionInLine := oldToken.getCharPositionInLine()
        channel := oldToken.getChannel()
        start := oldToken.getStartIndex()
        stop := oldToken.getStopIndex()
        text := oldToken.getText()
        source := oldToken.getTokenSourceAndStream()
    end ;


    public function getType (This : …) return Integer is
begin
        return type
    end ;


    public procedure setLine (line : Integer) {
        self.line := line
    end ;


    public function getText () return String? {
        if text : constant := text then
            return text;
        end if;

        if input : constant := getInputStream() then
            n : constant := input.size()
            if start < n and then stop < n then
                do {
                    return input.getText(Interval.of(start, stop));
                end ;
                catch {
                    return null;
                end ;
            else
                return "<EOF>";
            end if;
        end ;

        return null;

    end ;

    -- 
    -- Explicitly set the text for this token. if thencode textend ; is not
    -- `null`, then _#getText_ will return this value rather than
    -- extracting the text from the input.
    -- 
    -- - parameter text: The explicit text of the token, or `null` if the text
    -- should be obtained from the input along with the start and stop indexes
    -- of the token.
    -- 

    public procedure setText (text : String) {
        self.text := text
    end ;

    public function getLine (This : …) return Integer is
begin
        return line
    end ;


    public function getCharPositionInLine (This : …) return Integer is
begin
        return charPositionInLine
    end ;


    public procedure setCharPositionInLine (charPositionInLine : Integer) {
        self.charPositionInLine := charPositionInLine
    end ;


    public function getChannel (This : …) return Integer is
begin
        return channel
    end ;


    public procedure setChannel (channel : Integer) {
        self.channel := channel
    end ;


    public procedure setType (type : Integer) {
        self.type := type
    end ;


    public function getStartIndex (This : …) return Integer is
begin
        return start
    end ;

    public procedure setStartIndex (start : Integer) {
        self.start := start
    end ;


    public function getStopIndex (This : …) return Integer is
begin
        return stop
    end ;

    public procedure setStopIndex (stop : Integer) {
        self.stop := stop
    end ;


    public function getTokenIndex (This : …) return Integer is
begin
        return index
    end ;


    public procedure setTokenIndex (index : Integer) {
        self.index := index
    end ;


    public function getTokenSource () return TokenSource? {
        return source.tokenSource
    end ;


    public function getInputStream () return CharStream? {
        return source.stream
    end ;

    public function getTokenSourceAndStream (This : …) return TokenSourceAndStream is
begin
        return source
    end ;

    -- public
    description : String;
    function description return String is
        return toString(null)
    end ;

    public function toString (r : Recognizer<ATNSimulator>?) return String is
begin
        channelStr : constant := (channel > 0 ? ",channel=\(channel)" : "")

        var txt : String;
        if tokenText : constant := getText() then
            txt := tokenText.replacingOccurrences(of: "\n", with: "\\n")
            txt := txt.replacingOccurrences(of: "\r", with: "\\r")
            txt := txt.replacingOccurrences(of: "\t", with: "\\t")
        else
            txt := "<no text>";
        end if;
        typeString : constant String;
        if r : constant := r then
            typeString := r.getVocabulary().getDisplayName(type)
        else
            typeString := "\(type)";
        end if;
       return "[@\(getTokenIndex()),\(start):\(stop)='\(txt)',<\(typeString)>\(channelStr),\(line):\(getCharPositionInLine())]"
    end ;

    -- public
    visited : Boolean {
        get {
            return _visited
        end ;

        set {
            _visited := newValue
        end ;
    end ;
end ;
