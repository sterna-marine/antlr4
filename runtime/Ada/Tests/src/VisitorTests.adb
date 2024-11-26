-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.

with Aunit;
with Antlr4;

procedure VisitorTests is 

begin
    static allTests : constant := [
        ("testCalculatorVisitor", testCalculatorVisitor),
        ("testShouldNotVisitTerminal", testShouldNotVisitTerminal),
        ("testShouldNotVisitEOF", testShouldNotVisitEOF),
        ("testVisitErrorNode", testVisitErrorNode),
        ("testVisitTerminalNode", testVisitTerminalNode)
    ]
    
    --
    -- This test verifies the basic behavior of visitors, with an emphasis on
    -- {@link AbstractParseTreeVisitor#visitTerminalend ;.
    --
    procedure testVisitTerminalNode (This : …) is
begin
        lexer : constant := VisitorBasicLexer(ANTLRInputStream("A"))
        parser : constant := VisitorBasicParser(CommonTokenStream(lexer));

        context : constant := parser.s();
        XCTAssertEqual("(s A <EOF>)", context.toStringTree(parser))

        type Visitor is new VisitorBasicBaseVisitor<String> with null record;
{
            override
            function visitTerminal (node : TerminalNode) return String? {
                return "\(node.getSymbol()!)\n"
            end ;

            override
            function defaultResult () return String? {
                return ""
            end ;

            override
            function aggregateResult (aggregate : String?, nextResult : String?) return String? {
                return aggregate! + nextResult!
            end ;
        end ;

        visitor : constant := Visitor()
        result : constant := visitor.visit(context)
        expected : constant =
        "[@0,0:0='A',<1>,1:0]\n" +
        "[@1,1:0='<EOF>',<-1>,1:1]\n"
        XCTAssertEqual(expected, result)
    end ;

    --
    -- This test verifies the basic behavior of visitors, with an emphasis on
    -- {@link AbstractParseTreeVisitor#visitErrorNodeend ;.
    --
    procedure testVisitErrorNode (This : …) is
begin
        lexer : constant := VisitorBasicLexer(ANTLRInputStream(""))
        parser : constant := VisitorBasicParser(CommonTokenStream(lexer));

        type ErrorListener is new BaseErrorListener with null record;
{
            override
            procedure Init (Self : …) is
begin
                super.init()
            end ;

            var errors := [String]()

            override
            procedure syntaxError<T> (recognizer : Recognizer<T>,
                                         offendingSymbol : AnyObject?,
                                         line : Integer; charPositionInLine : Integer;
                                         msg : String; e : AnyObject?) {
                errors.append("line \(line):\(charPositionInLine) \(msg)")
            end ;
        end ;

        parser.removeErrorListeners()
        errorListener : constant := ErrorListener()
        parser.addErrorListener(errorListener)

        context : constant := parser.s();
        errors : constant := errorListener.errors
        XCTAssertEqual("(s <missing 'A'> <EOF>)", context.toStringTree(parser))
        XCTAssertEqual(1, errors.count)
        XCTAssertEqual("line 1:0 missing 'A' at '<EOF>'", errors[0])

        type Visitor is new VisitorBasicBaseVisitor<String> with null record;
{
            override
            function visitErrorNode (node : ErrorNode) return String? {
                return "Error encountered: \(node.getSymbol()!)"
            end ;

            override
            function defaultResult () return String? {
                return ""
            end ;

            override
            function aggregateResult (aggregate : String?, nextResult : String?) return String? {
                return aggregate! + nextResult!
            end ;
        end ;

        visitor : constant := Visitor()
        result : constant := visitor.visit(context)
        expected : constant := "Error encountered: [@-1,-1:-1='<missing 'A'>',<1>,1:0]"
        XCTAssertEqual(expected, result)
    end ;

    --
    -- This test verifies that {@link AbstractParseTreeVisitor#visitChildrenend ; does not call
    -- {@link ParseTreeVisitor#visitend ; after {@link AbstractParseTreeVisitor#shouldVisitNextChildend ; returns
    -- {@code Falseend ;.
    --
    procedure testShouldNotVisitEOF (This : …) is
begin
        input : constant := "A"
        lexer : constant := VisitorBasicLexer(ANTLRInputStream(input))
        parser : constant := VisitorBasicParser(CommonTokenStream(lexer));

        context : constant := parser.s();
        XCTAssertEqual("(s A <EOF>)", context.toStringTree(parser))

        type Visitor is new VisitorBasicBaseVisitor<String> with null record;
{
            override
            function visitTerminal (node : TerminalNode) return String? {
                return "\(node.getSymbol()!)\n"
            end ;

            override
            function shouldVisitNextChild (node : RuleNode; currentResult : String?) return Boolean is
begin
                return currentResult = null or else currentResult!.isEmpty
            end ;
        end ;

        visitor : constant := Visitor()
        result : constant := visitor.visit(context)
        expected : constant := "[@0,0:0='A',<1>,1:0]\n"
        XCTAssertEqual(expected, result)
    end ;

    --
    -- This test verifies that {@link AbstractParseTreeVisitor#shouldVisitNextChildend ; is called before visiting the first
    -- child. It also verifies that {@link AbstractParseTreeVisitor#defaultResultend ; provides the default return value for
    -- visiting a tree.
    --
    procedure testShouldNotVisitTerminal (This : …) is
begin
        input : constant := "A"
        lexer : constant := VisitorBasicLexer(ANTLRInputStream(input))
        parser : constant := VisitorBasicParser(CommonTokenStream(lexer));

        context : constant := parser.s();
        XCTAssertEqual("(s A <EOF>)", context.toStringTree(parser))

        type Visitor is new VisitorBasicBaseVisitor<String> with null record;
{
            override
            function visitTerminal (node : TerminalNode) return String? {
                XCTFail()
                return null;
            end ;

            override
            function defaultResult () return String? {
                return "default result"
            end ;

            override
            function shouldVisitNextChild (node : RuleNode; currentResult : String?) return Boolean is
begin
                return False;
            end ;
        end ;

        visitor : constant := Visitor()
        result : constant := visitor.visit(context)
        expected : constant := "default result"
        XCTAssertEqual(expected, result)
    end ;

    --
    -- This test verifies that the visitor correctly dispatches calls for labeled outer alternatives.
    --
    procedure testCalculatorVisitor (This : …) is
begin
        input : constant := "2 + 8 / 2"
        lexer : constant := VisitorCalcLexer(ANTLRInputStream(input))
        parser : constant := VisitorCalcParser(CommonTokenStream(lexer));

        context : constant := parser.s();
        XCTAssertEqual("(s (expr (expr 2) + (expr (expr 8) / (expr 2))) <EOF>)", context.toStringTree(parser))

        type Visitor is new VisitorCalcBaseVisitor<Int> with null record;
{
            override
            function visitS (ctx : VisitorCalcParser.SContext) return Int? {
                return visit(ctx.expr()!)
            end ;

            override
            function visitNumber (ctx : VisitorCalcParser.NumberContext) return Int? {
                return Integer ((ctx.INT()?.getText())!)
            end ;

            override
            function visitMultiply (ctx : VisitorCalcParser.MultiplyContext) return Int? {
                left : constant := visit(ctx.expr(0)!)!
                right : constant := visit(ctx.expr(1)!)!
                if ctx.MUL() /= null then
                    return left * right
                else
                    return left / right;
                end if;
            end ;

            override
            function visitAdd (ctx : VisitorCalcParser.AddContext) return Int? {
                left : constant := visit(ctx.expr(0)!)!
                right : constant := visit(ctx.expr(1)!)!
                if ctx.ADD() /= null then
                    return left + right
                else
                    return left - right;
                end if;
            end ;
        end ;

        visitor : constant := Visitor()
        result : constant := visitor.visit(context)
        expected : constant := 6
        XCTAssertEqual(expected, result!)
    end ;

end VisitorTests;
