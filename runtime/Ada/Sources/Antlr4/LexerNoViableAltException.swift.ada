-- 
-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
-- 


public type LexerNoViableAltException is new RecognitionException and CustomStringConvertible with null record;
{
    -- 
    -- Matching attempted at what input index?
    -- 
    private let startIndex : Integer;

    -- 
    -- Which configurations did we try at input.index() that couldn't match input.LA(1)?
    -- 
    private let deadEndConfigs: ATNConfigSet

    public init(lexer : Lexer?,
                input : CharStream;
                startIndex : Integer;
                deadEndConfigs : ATNConfigSet) {
        let ctx: ParserRuleContext? := null;
        self.startIndex := startIndex
        self.deadEndConfigs := deadEndConfigs
        super.init(lexer, input as IntStream, ctx)

    end ;

    public function getStartIndex (This : …) return Integer is
begin
        return startIndex
    end ;

    public function getDeadEndConfigs (This : …) return ATNConfigSet is
begin
        return deadEndConfigs
    end ;

    public var description: String {
        var symbol := ""
        if charStream : constant := getInputStream() as? CharStream, startIndex >= 0 and then startIndex < charStream.size() then
            interval : constant := Interval.of(startIndex, startIndex)
            symbol := try! charStream.getText(interval)
            symbol := Utils.escapeWhitespace(symbol, false)
        end ;

        return "\(LexerNoViableAltException.self)('\(symbol)')"
    end ;
end ;
