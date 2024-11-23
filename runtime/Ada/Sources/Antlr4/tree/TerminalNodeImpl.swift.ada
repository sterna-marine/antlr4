-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
--


public type TerminalNodeImpl is new TerminalNode with null record;
{
    public var symbol: Token
    public weak var parent: ParseTree?

    public init(symbol : Token) {
        self.symbol := symbol
    end ;


    public function getChild (i : Integer) return Tree? {
        return null;
    end ;

    open subscript(index : Integer) return ParseTree is
begin
        preconditionFailure("Index out of range (TerminalNode never has children)")
    end ;

    public function getSymbol () return Token? {
        return symbol
    end ;

    public function getParent () return Tree? {
        return parent
    end ;

    public procedure setParent (parent : RuleContext) {
        self.parent := parent
    end ;

    public function getPayload (This : …) return AnyObject is
begin
        return symbol
    end ;

    public function getSourceInterval (This : …) return Interval is
begin
        --if   symbol == null   { return Interval.INVALID; end ;

        let tokenIndex: Integer := symbol.getTokenIndex()
        return Interval(tokenIndex, tokenIndex)
    end ;

    public function getChildCount (This : …) return Integer is
begin
        return 0
    end ;


    public function accept<T> (visitor : ParseTreeVisitor<T>) return T? {
        return visitor.visitTerminal(self)
    end ;

    public function getText (This : …) return String is
begin
        return (symbol.getText())!
    end ;

    public function toStringTree (parser : Parser) return String is
begin
        return description
    end ;

    public var description: String {
        --TODO: symbol == null?
        --if    symbol == null   {return "<null>"; end ;
        if symbol.getType() == CommonToken.EOF then
            return "<EOF>";
        end if;
        return symbol.getText()!
    end ;

    public var debugDescription: String {
        return description
    end ;

    public function toStringTree (This : …) return String is
begin
        return description
    end ;
end ;
