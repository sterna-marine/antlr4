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

    --
    -- This test verifies the basic behavior of visitors, with an emphasis on
    -- {@link AbstractParseTreeVisitor#visitTerminal}.
    --
    procedure testVisitTerminalNode (This : …) is
begin
        lexer : constant := VisitorBasicLexer (ANTLRInputStream ("A"));
        parser : constant := VisitorBasicParser (CommonTokenStream (lexer));

        context : constant := parser.s ();
        UnitTest.Assert_Equal ("(s A <EOF>)", context.toStringTree (parser));

        type Visitor is new VisitorBasicBaseVisitor<UString> with null record;
{
            overriding
            function visitTerminal (node : TerminalNode) return Optional_String is
   begin
                return node.getSymbol ()! & "\n"
            end if;

            overriding
            function defaultResult (This : …) return Optional_String is
   begin
                return ""
            end if;

            overriding
            function aggregateResult (aggregate : Optional_UString; nextResult : Optional_UString) return Optional_String is
   begin
                return aggregate! + nextResult!
            end if;
        end if;

        visitor : constant := This.Visitor;
        result : constant := visitor.visit (context);
        expected : constant =
        "[@0,0:0='A',<1>,1:0]\n" +
        "[@1,1:0='<EOF>',<-1>,1:1]\n"
        UnitTest.Assert_Equal (expected, result);
    end if;

    --
    -- This test verifies the basic behavior of visitors, with an emphasis on
    -- {@link AbstractParseTreeVisitor#visitErrorNode}.
    --
    procedure testVisitErrorNode (This : …) is
begin
        lexer : constant := VisitorBasicLexer (ANTLRInputStream (""));
        parser : constant := VisitorBasicParser (CommonTokenStream (lexer));

        type ErrorListener is new BaseErrorListener with null record;
{
            overriding
            procedure Initialize (Self : in out …) is
begin
                super.Initialize (Self);
            end if;

            errors := UString.Container.Empty_Vector;

            overriding
            procedure syntaxError<T> (recognizer : Recognizer<T>,
                                         offendingSymbol : Optional_AnyObject;
                                         line : Integer; charPositionInLine : Integer;
                                         msg : UString; e : Optional_AnyObject;) {
                errors.append ("line " & line'Image & ":" & charPositionInLine'Image & " " & msg'Image);
            end if;
        end if;

        parser.removeErrorListeners ();
        errorListener : constant := This.ErrorListener;
        parser.addErrorListener (errorListener);

        context : constant := parser.s ();
        errors : constant := errorListener.errors
        UnitTest.Assert_Equal ("(s <missing 'A'> <EOF>)", context.toStringTree (parser));
        UnitTest.Assert_Equal (1, errors.count);
        UnitTest.Assert_Equal ("line 1:0 missing 'A' at '<EOF>'", errors.Element (0));

        type Visitor is new VisitorBasicBaseVisitor<UString> with null record;
{
            overriding
            function visitErrorNode (node : ErrorNode) return Optional_String is
   begin
                return "Error encountered: " & node.getSymbol ()!)"
            end if;

            overriding
            function defaultResult (This : …) return Optional_String is
   begin
                return ""
            end if;

            overriding
            function aggregateResult (aggregate : Optional_UString; nextResult : Optional_UString) return Optional_String is
   begin
                return aggregate! + nextResult!
            end if;
        end if;

        visitor : constant := This.Visitor;
        result : constant := visitor.visit (context);
        expected : constant := "Error encountered: [@-1,-1:-1='<missing 'A'>',<1>,1:0]"
        UnitTest.Assert_Equal (expected, result);
    end if;

    --
    -- This test verifies that {@link AbstractParseTreeVisitor#visitChildren} does not call
    -- {@link ParseTreeVisitor#visit} after {@link AbstractParseTreeVisitor#shouldVisitNextChild} returns
    -- {@code False}.
    --
    procedure testShouldNotVisitEOF (This : …) is
begin
        input : constant := "A"
        lexer : constant := VisitorBasicLexer (ANTLRInputStream (input));
        parser : constant := VisitorBasicParser (CommonTokenStream (lexer));

        context : constant := parser.s ();
        UnitTest.Assert_Equal ("(s A <EOF>)", context.toStringTree (parser));

        type Visitor is new VisitorBasicBaseVisitor<UString> with null record;
{
            overriding
            function visitTerminal (node : TerminalNode) return Optional_String is
   begin
                return Valae (node.getSymbol ()) & "\n";
            end if;

            overriding
            function shouldVisitNextChild (node : RuleNode; currentResult : Optional_UString) return Boolean is
begin
                return not Is_Valid (currentResult) or else currentResult!.isEmpty
            end if;
        end if;

        visitor : constant := This.Visitor;
        result : constant := visitor.visit (context);
        expected : constant := "[@0,0:0='A',<1>,1:0]\n"
        UnitTest.Assert_Equal (expected, result);
    end if;

    --
    -- This test verifies that {@link AbstractParseTreeVisitor#shouldVisitNextChild} is called before visiting the first
    -- child. It also verifies that {@link AbstractParseTreeVisitor#defaultResult} provides the default return value for
    -- visiting a tree.
    --
    procedure testShouldNotVisitTerminal (This : …) is
begin
        input : constant := "A"
        lexer : constant := VisitorBasicLexer (ANTLRInputStream (input));
        parser : constant := VisitorBasicParser (CommonTokenStream (lexer));

        context : constant := parser.s ();
        UnitTest.Assert_Equal ("(s A <EOF>)", context.toStringTree (parser));

        type Visitor is new VisitorBasicBaseVisitor<UString> with null record;
{
            overriding
            function visitTerminal (node : TerminalNode) return Optional_String is
   begin
                UnitTest.Fail ();
                return (Valid => False);
            end if;

            overriding
            function defaultResult (This : …) return Optional_String is
   begin
                return "default result"
            end if;

            overriding
            function shouldVisitNextChild (node : RuleNode; currentResult : Optional_UString) return Boolean is
begin
                return False;
            end if;
        end if;

        visitor : constant := This.Visitor;
        result : constant := visitor.visit (context);
        expected : constant := "default result"
        UnitTest.Assert_Equal (expected, result);
    end if;

    --
    -- This test verifies that the visitor correctly dispatches calls for labeled outer alternatives.
    --
    procedure testCalculatorVisitor (This : …) is
begin
        input : constant := "2 + 8 / 2"
        lexer : constant := VisitorCalcLexer (ANTLRInputStream (input));
        parser : constant := VisitorCalcParser (CommonTokenStream (lexer));

        context : constant := parser.s ();
        UnitTest.Assert_Equal ("(s (expr (expr 2) + (expr (expr 8) / (expr 2))) <EOF>)", context.toStringTree (parser));

        type Visitor is new VisitorCalcBaseVisitor<Int> with null record;
{
            overriding
            function visitS (ctx : VisitorCalcParser.SContext) return Optional_Integer is
   begin
                return visit (ctx.expr ()!);
            end if;

            overriding
            function visitNumber (ctx : VisitorCalcParser.NumberContext) return Optional_Integer is
   begin
                return Integer ((ctx.INT ()?.getText ())!);
            end if;

            overriding
            function visitMultiply (ctx : VisitorCalcParser.MultiplyContext) return Optional_Integer is
   begin
                left : constant := visit (ctx.expr (0)!)!
                right : constant := visit (ctx.expr (1)!)!
                if Is_Valid (ctx.MUL ()) then
                    return left * right
                else
                    return left / right;
                end if;
            end if;

            overriding
            function visitAdd (ctx : VisitorCalcParser.AddContext) return Optional_Integer is
   begin
                left : constant := visit (ctx.expr (0)!)!
                right : constant := visit (ctx.expr (1)!)!
                if Is_Valid (ctx.ADD ()) then
                    return left + right
                else
                    return left - right;
                end if;
            end if;
        end if;

        visitor : constant := This.Visitor;
        result : constant := visitor.visit (context);
        expected : constant := 6
        UnitTest.Assert_Equal (expected, result!);
    end if;

end VisitorTests;
