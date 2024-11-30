-- €

with Aunit;
with Antlr4;

procedure VisitorTests is 

begin
    static allTests : constant := [
        ("testCalculatorVisitor", testCalculatorVisitor),
        ("testShouldNotVisitTerminal", testShouldNotVisitTerminal),
        ("testShouldNotVisitEOF", testShouldNotVisitEOF),
        ("testVisitErrorNode", testVisitErrorNode),
        ("testVisitTerminalNode", testVisitTerminalNode);
    ]
    
    -- --------------------------------------------
    -- This test verifies the basic behavior of visitors, with an emphasis on
    -- {@link AbstractParseTreeVisitor#visitTerminal}.
    -- --------------------------------------------
    procedure testVisitTerminalNode (This : …) is
begin
        lexer : constant := VisitorBasicLexer (ANTLRInputStream ("A"));
        parser : constant := VisitorBasicParser (CommonTokenStream (lexer));

        context : constant := parser.s ();
        XCTAssertEqual ("(s A <EOF>)", context.toStringTree (parser));

        type Visitor is new VisitorBasicBaseVisitor<String> with null record;
{
            override
            function visitTerminal (node : TerminalNode) return Optional_String is
   begin
                return "\(node.getSymbol ()!)\n"
            end if;

            override
            function defaultResult () return Optional_String is
   begin
                return ""
            end if;

            override
            function aggregateResult (aggregate : Optional_String; nextResult : Optional_String;) return Optional_String is
   begin
                return aggregate! + nextResult!
            end if;
        end if;

        visitor : constant := Visitor ();
        result : constant := visitor.visit (context);
        expected : constant =
        "[@0,0:0='A',<1>,1:0]\n" +
        "[@1,1:0='<EOF>',<-1>,1:1]\n"
        XCTAssertEqual (expected, result);
    end if;

    -- --------------------------------------------
    -- This test verifies the basic behavior of visitors, with an emphasis on
    -- {@link AbstractParseTreeVisitor#visitErrorNode}.
    -- --------------------------------------------
    procedure testVisitErrorNode (This : …) is
begin
        lexer : constant := VisitorBasicLexer (ANTLRInputStream (""));
        parser : constant := VisitorBasicParser (CommonTokenStream (lexer));

        type ErrorListener is new BaseErrorListener with null record;
{
            override
            procedure Init (Self : …) is
begin
                super.init ();
            end if;

            errors := [String]();

            override
            procedure syntaxError<T> (recognizer : Recognizer<T>,
                                         offendingSymbol : Optional_AnyObject;
                                         line : Integer; charPositionInLine : Integer;
                                         msg : String; e : Optional_AnyObject;) {
                errors.append ("line " & line'Image & ":" & charPositionInLine'Image & " " & msg'Image);
            end if;
        end if;

        parser.removeErrorListeners ();
        errorListener : constant := ErrorListener ();
        parser.addErrorListener (errorListener);

        context : constant := parser.s ();
        errors : constant := errorListener.errors
        XCTAssertEqual ("(s <missing 'A'> <EOF>)", context.toStringTree (parser));
        XCTAssertEqual (1, errors.count);
        XCTAssertEqual ("line 1:0 missing 'A' at '<EOF>'", errors[0]);

        type Visitor is new VisitorBasicBaseVisitor<String> with null record;
{
            override
            function visitErrorNode (node : ErrorNode) return Optional_String is
   begin
                return "Error encountered: \(node.getSymbol ()!)"
            end if;

            override
            function defaultResult () return Optional_String is
   begin
                return ""
            end if;

            override
            function aggregateResult (aggregate : Optional_String; nextResult : Optional_String;) return Optional_String is
   begin
                return aggregate! + nextResult!
            end if;
        end if;

        visitor : constant := Visitor ();
        result : constant := visitor.visit (context);
        expected : constant := "Error encountered: [@-1,-1:-1='<missing 'A'>',<1>,1:0]"
        XCTAssertEqual (expected, result);
    end if;

    -- --------------------------------------------
    -- This test verifies that {@link AbstractParseTreeVisitor#visitChildren} does not call
    -- {@link ParseTreeVisitor#visit} after {@link AbstractParseTreeVisitor#shouldVisitNextChild} returns
    -- {@code False}.
    -- --------------------------------------------
    procedure testShouldNotVisitEOF (This : …) is
begin
        input : constant := "A"
        lexer : constant := VisitorBasicLexer (ANTLRInputStream (input));
        parser : constant := VisitorBasicParser (CommonTokenStream (lexer));

        context : constant := parser.s ();
        XCTAssertEqual ("(s A <EOF>)", context.toStringTree (parser));

        type Visitor is new VisitorBasicBaseVisitor<String> with null record;
{
            override
            function visitTerminal (node : TerminalNode) return Optional_String is
   begin
                return "\(node.getSymbol ()!)\n"
            end if;

            override
            function shouldVisitNextChild (node : RuleNode; currentResult : Optional_String;) return Boolean is
begin
                return currentResult = null or else currentResult!.isEmpty
            end if;
        end if;

        visitor : constant := Visitor ();
        result : constant := visitor.visit (context);
        expected : constant := "[@0,0:0='A',<1>,1:0]\n"
        XCTAssertEqual (expected, result);
    end if;

    -- --------------------------------------------
    -- This test verifies that {@link AbstractParseTreeVisitor#shouldVisitNextChild} is called before visiting the first
    -- child. It also verifies that {@link AbstractParseTreeVisitor#defaultResult} provides the default return value for
    -- visiting a tree.
    -- --------------------------------------------
    procedure testShouldNotVisitTerminal (This : …) is
begin
        input : constant := "A"
        lexer : constant := VisitorBasicLexer (ANTLRInputStream (input));
        parser : constant := VisitorBasicParser (CommonTokenStream (lexer));

        context : constant := parser.s ();
        XCTAssertEqual ("(s A <EOF>)", context.toStringTree (parser));

        type Visitor is new VisitorBasicBaseVisitor<String> with null record;
{
            override
            function visitTerminal (node : TerminalNode) return Optional_String is
   begin
                XCTFail ();
                return null;
            end if;

            override
            function defaultResult () return Optional_String is
   begin
                return "default result"
            end if;

            override
            function shouldVisitNextChild (node : RuleNode; currentResult : Optional_String;) return Boolean is
begin
                return False;
            end if;
        end if;

        visitor : constant := Visitor ();
        result : constant := visitor.visit (context);
        expected : constant := "default result"
        XCTAssertEqual (expected, result);
    end if;

    -- --------------------------------------------
    -- This test verifies that the visitor correctly dispatches calls for labeled outer alternatives.
    -- --------------------------------------------
    procedure testCalculatorVisitor (This : …) is
begin
        input : constant := "2 + 8 / 2"
        lexer : constant := VisitorCalcLexer (ANTLRInputStream (input));
        parser : constant := VisitorCalcParser (CommonTokenStream (lexer));

        context : constant := parser.s ();
        XCTAssertEqual ("(s (expr (expr 2) + (expr (expr 8) / (expr 2))) <EOF>)", context.toStringTree (parser));

        type Visitor is new VisitorCalcBaseVisitor<Int> with null record;
{
            override
            function visitS (ctx : VisitorCalcParser.SContext) return Optional_Integer is
   begin
                return visit (ctx.expr ()!);
            end if;

            override
            function visitNumber (ctx : VisitorCalcParser.NumberContext) return Optional_Integer is
   begin
                return Integer ((ctx.INT ()?.getText ())!);
            end if;

            override
            function visitMultiply (ctx : VisitorCalcParser.MultiplyContext) return Optional_Integer is
   begin
                left : constant := visit (ctx.expr (0)!)!
                right : constant := visit (ctx.expr (1)!)!
                if ctx.MUL () /= null then
                    return left * right
                else
                    return left / right;
                end if;
            end if;

            override
            function visitAdd (ctx : VisitorCalcParser.AddContext) return Optional_Integer is
   begin
                left : constant := visit (ctx.expr (0)!)!
                right : constant := visit (ctx.expr (1)!)!
                if ctx.ADD () /= null then
                    return left + right
                else
                    return left - right;
                end if;
            end if;
        end if;

        visitor : constant := Visitor ();
        result : constant := visitor.visit (context);
        expected : constant := 6
        XCTAssertEqual (expected, result!);
    end if;

end VisitorTests;
