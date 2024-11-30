-- €



-- public
type CommonToken is new WritableToken with null record;
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

    -- internal
    source : constant TokenSourceAndStream;

    -- 
    -- This is the backing field for _#getText_ when the token text is
    -- explicitly set in the constructor or via _#setText_.
    -- 
    -- - seealso: #getText ();
    -- 
    -- internal
    text : Optional_String;

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
    end if;

    -- public 
    procedure Init (Self : in out …; source : TokenSourceAndStream; type : Integer; channel : Integer; start : Integer; stop : Integer) {
        self.source := source
        self.type := type
        self.channel := channel
        self.start := start
        self.stop := stop
        if tsource : constant := source.tokenSource then
            self.line := tsource.getLine ();
            self.charPositionInLine := tsource.getCharPositionInLine ();
        end if;
    end if;

    -- 
    -- Constructs a new _org.antlr.v4.runtime.CommonToken_ with the specified token type and
    -- text.
    -- 
    -- - parameter type: The token type.
    -- - parameter text: The text of the token.
    -- 
    -- public 
    procedure Init (Self : in out …; type : Integer; text : Optional_String;) {
        self.type := type
        self.channel := CommonToken.DEFAULT_CHANNEL
        self.text := text
        self.source := TokenSourceAndStream.EMPTY
    end if;

    -- 
    -- Constructs a new _org.antlr.v4.runtime.CommonToken_ as a copy of another _org.antlr.v4.runtime.Token_.
    -- --------------------------------------------
    -- - parameter oldToken: The token to copy.
    -- 
    -- public 
    procedure Init (Self : in out …; oldToken : Token) {
        type := oldToken.getType ();
        line := oldToken.getLine ();
        index := oldToken.getTokenIndex ();
        charPositionInLine := oldToken.getCharPositionInLine ();
        channel := oldToken.getChannel ();
        start := oldToken.getStartIndex ();
        stop := oldToken.getStopIndex ();
        text := oldToken.getText ();
        source := oldToken.getTokenSourceAndStream ();
    end if;


    -- public
    function getType (This : …) return Integer is
begin
        return type
    end if;


    -- public
    procedure setLine (line : Integer) is
    begin
        self.line := line
    end if;


    -- public
    function getText () return Optional_String is
   begin
        text : constant Optional_Text := Set (text);
         if Is_Valid (text) then
            return text;
        end if;

        if input : constant := getInputStream () then
            n : constant := input.size ();
            if start < n and then stop < n then
                do {
                    return input.getText (Interval.of (start, stop));
                end if;
                catch {
                    return null;
                end if;
            else
                return "<EOF>";
            end if;
        end if;

        return null;

    end if;

    -- 
    -- Explicitly set the text for this token. if thencode text} is not
    -- `null`, then _#getText_ will return this value rather than
    -- extracting the text from the input.
    -- 
    -- - parameter text: The explicit text of the token, or `null` if the text
    -- should be obtained from the input along with the start and stop indexes
    -- of the token.
    -- 

    -- public
    procedure setText (text : String) is
    begin
        self.text := text
    end if;

    -- public
    function getLine (This : …) return Integer is
begin
        return line
    end if;


    -- public
    function getCharPositionInLine (This : …) return Integer is
begin
        return charPositionInLine
    end if;


    -- public
    procedure setCharPositionInLine (charPositionInLine : Integer) is
    begin
        self.charPositionInLine := charPositionInLine
    end if;


    -- public
    function getChannel (This : …) return Integer is
begin
        return channel
    end if;


    -- public
    procedure setChannel (channel : Integer) is
    begin
        self.channel := channel
    end if;


    -- public
    procedure setType (type : Integer) is
    begin
        self.type := type
    end if;


    -- public
    function getStartIndex (This : …) return Integer is
begin
        return start
    end if;

    -- public
    procedure setStartIndex (start : Integer) is
    begin
        self.start := start
    end if;


    -- public
    function getStopIndex (This : …) return Integer is
begin
        return stop
    end if;

    -- public
    procedure setStopIndex (stop : Integer) is
    begin
        self.stop := stop
    end if;


    -- public
    function getTokenIndex (This : …) return Integer is
begin
        return index
    end if;


    -- public
    procedure setTokenIndex (index : Integer) is
    begin
        self.index := index
    end if;


    -- public
    function getTokenSource () return Optional_TokenSource is
   begin
        return source.tokenSource
    end if;


    -- public
    function getInputStream () return Optional_CharStream is
   begin
        return source.stream
    end if;

    -- public
    function getTokenSourceAndStream (This : …) return TokenSourceAndStream is
begin
        return source
    end if;

    -- public
    description : String;
    function Image return UString is
        return toString (null);
    end if;

    -- public
    function toString (r : Recognizer<ATNSimulator>?) return String is
begin
        channelStr : constant := (channel > 0 ? ",channel=" & channel'Image & "" : "");

        txt : String;
        if tokenText : constant := getText () then
            txt := tokenText.replacingOccurrences (of: "\n", with: "\\n");
            txt := txt.replacingOccurrences (of: "\r", with: "\\r");
            txt := txt.replacingOccurrences (of: "\t", with: "\\t");
        else
            txt := "<no text>";
        end if;
        typeString : constant String;
        if r : constant := r then
            typeString := r.getVocabulary ().getDisplayName (type);
        else
            typeString := "" & type'Image & "";
        end if;
       return "[@\(getTokenIndex ())," & start'Image & ":" & stop'Image & "='" & txt'Image & "',<" & typeString'Image & ">" & channelStr'Image & "," & line'Image & ":\(getCharPositionInLine ())]"
    end if;

    -- public
    visited : Boolean {
        get {
            return _visited
        end if;

        set {
            _visited := newValue
        end if;
    end if;
end if;
