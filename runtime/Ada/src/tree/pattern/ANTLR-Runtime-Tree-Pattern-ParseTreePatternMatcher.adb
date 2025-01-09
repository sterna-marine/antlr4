-- €

with Ada.Finalization;
with Ada.Wide_Wide_Text_IO;
with ANTLR.Runtime.Misc.Exceptions.Errors;
with Aspect;

use Ada;
use ANTLR.Runtime.Misc.Exceptions.Errors;
use Aspect;


--
-- A tree pattern matching mechanism for ANTLR _org.antlr.v4.runtime.tree.ParseTree_s.
--
-- Patterns are strings of source input text with special tags representing
-- token or rule references such as:
--
-- `<ID> := <expr>;`
--
-- Given a pattern start rule such as `statement`, this object constructs
-- a _org.antlr.v4.runtime.tree.ParseTree_ with placeholders for the `ID` and `expr`
-- subtree. Then the _#match_ routines can compare an actual
-- _org.antlr.v4.runtime.tree.ParseTree_ from a parse with this pattern. Tag `<ID>` matches
-- any `ID` token and tag `<expr>` references the result of the
-- `expr` rule (generally an instance of `ExprContext`.
--
-- Pattern `x := 0;` is a similar pattern that matches the same pattern
-- except that it requires the identifier to be `x` and the expression to
-- be `0`.
--
-- The _#matches_ routines return `True` or `False` based
-- upon a match for the tree rooted at the parameter sent in. The
-- _#match_ routines return a _org.antlr.v4.runtime.tree.pattern.ParseTreeMatch_ object that
-- contains the parse tree, the parse tree pattern, and a map from tag name to
-- matched nodes (more below). A subtree that fails to match, returns with
-- _org.antlr.v4.runtime.tree.pattern.ParseTreeMatch#mismatchedNode_ set to the first tree node that did not
-- match.
--
-- For efficiency, you can compile a tree pattern in string form to a
-- _org.antlr.v4.runtime.tree.pattern.ParseTreePattern_ object.
--
-- See `TestParseTreeMatcher` for lots of examples.
-- _org.antlr.v4.runtime.tree.pattern.ParseTreePattern_ has two static helper methods:
-- _org.antlr.v4.runtime.tree.pattern.ParseTreePattern#findAll_ and _org.antlr.v4.runtime.tree.pattern.ParseTreePattern#match_ that
-- are easy to use but not super efficient because they create new
-- _org.antlr.v4.runtime.tree.pattern.ParseTreePatternMatcher_ objects each time and have to compile the
-- pattern in string form before using it.
--
-- The lexer and parser that you pass into the _org.antlr.v4.runtime.tree.pattern.ParseTreePatternMatcher_
-- constructor are used to parse the pattern in string form. The lexer converts
-- the `<ID> := <expr>;` into a sequence of four tokens (assuming lexer
-- out whitespace or puts it on a hidden channel). Be aware that the
-- input stream is reset for the lexer (but not the parser; a
-- _org.antlr.v4.runtime.ParserInterpreter_ is created to parse the input.). Any user-defined
-- fields you have put into the lexer might get changed when this mechanism asks
-- it to scan the pattern string.
--
-- Normally a parser does not accept token `<expr>` as a valid
-- `expr` but, from the parser passed in, we create a special version of
-- the underlying grammar representation (an _org.antlr.v4.runtime.atn.ATN_) that allows imaginary
-- tokens representing rules (`<expr>`) to match entire rules. We call
-- these __bypass alternatives__.
--
-- Delimiters are `<` and `>`, with `\` as the escape string
-- by default, but you can set them to whatever you want using
-- _#setDelimiters_. You must escape both start and stop strings
-- `\<` and `\>`.
--

-- public
type ParseTreePatternMatcher is new Ada.Finalization.Controlled record

    --
    -- This is the backing field for _#getLexer_.
    --
    private final let lexer: Lexer

    --
    -- This is the backing field for _#getParser_.
    --
    private final let parser: Parser

    -- internal
    start : UString := "<"
    -- internal
    stop : UString := ">"
    -- internal
    escape : UString := """"

    --
    -- Constructs a _org.antlr.v4.runtime.tree.pattern.ParseTreePatternMatcher_ or from a _org.antlr.v4.runtime.Lexer_ and
    -- _org.antlr.v4.runtime.Parser_ object. The lexer input stream is altered for tokenizing
    -- the tree patterns. The parser is used as a convenient mechanism to get
    -- the grammar name, plus token, rule names.
    --
    -- public
    procedure Initialize (Self : in out …; lexer : Lexer; parser : Parser) {
        self.lexer := lexer
        self.parser := parser
    end if;

    --
    -- Set the delimiters used for marking rule and token tags within concrete
    -- syntax used by the tree pattern parser.
    --
    -- * Parameter start: The start delimiter.
    -- * Parameter stop: The stop delimiter.
    -- * Parameter escapeLeft: The escape sequence to use for escaping a start or stop delimiter.
    --
    -- * Throws: ANTLRError.ilegalArgument if `start` is `null` or empty.
    -- * Throws: ANTLRError.ilegalArgument if `stop` is `null` or empty.
    --
    -- public
    procedure setDelimiters (start : UString; stop : UString; escapeLeft : UString) is
    begin
        if start.isEmpty then
            raise ANTLRError.illegalArgument with "start cannot be null or empty";
        end if;
        if stop.isEmpty then
            raise ANTLRError.illegalArgument with "stop cannot be null or empty";
        end if;

        self.start := start
        self.stop := stop
        self.escape := escapeLeft
    end if;

    --
    -- Does `pattern` matched as rule `patternRuleIndex` match `tree`?
    --
    -- public
    function matches (tree : ParseTree; pattern : UString; patternRuleIndex : Integer) return Boolean is
begin
        p : constant ParseTreePattern := compile (pattern, patternRuleIndex);
        return matches (tree, p);
    end if;

    --
    -- Does `pattern` matched as rule patternRuleIndex match tree? Pass in a
    -- compiled pattern instead of a string representation of a tree pattern.
    --
    -- public
    function matches (tree : ParseTree; pattern : ParseTreePattern) return Boolean is
begin
        labels : constant MultiMap<UString, ParseTree> := MultiMap<UString, ParseTree>;
        mismatchedNode : constant Optional_ParseTree; := matchImpl (tree, pattern.getPatternTree, labels);
        return not Is_Valid (mismatchedNode);
    end if;

    --
    -- Compare `pattern` matched as rule `patternRuleIndex` against
    -- `tree` and return a _org.antlr.v4.runtime.tree.pattern.ParseTreeMatch_ object that contains the
    -- matched elements, or the node at which the match failed.
    --
    -- public
    function match (tree : ParseTree; pattern : UString; patternRuleIndex : Integer) return ParseTreeMatch is
begin
        p : constant ParseTreePattern := compile (pattern, patternRuleIndex);
        return match (tree, p);
    end if;

    --
    -- Compare `pattern` matched against `tree` and return a
    -- _org.antlr.v4.runtime.tree.pattern.ParseTreeMatch_ object that contains the matched elements, or the
    -- node at which the match failed. Pass in a compiled pattern instead of a
    -- string representation of a tree pattern.
    --
    -- public
    function match (tree : ParseTree; pattern : ParseTreePattern) return ParseTreeMatch is
begin
        labels : constant MultiMap<UString, ParseTree> := MultiMap<UString, ParseTree>;
        mismatchedNode : constant Optional_ParseTree; := matchImpl (tree, pattern.getPatternTree, labels);
        return ParseTreeMatch (tree, pattern, labels, mismatchedNode);
    end if;

    --
    -- For repeated use of a tree pattern, compile it to a
    -- _org.antlr.v4.runtime.tree.pattern.ParseTreePattern_ using this method.
    --
    -- public
    function compile (pattern : UString; patternRuleIndex : Integer) return ParseTreePattern is
begin
        tokenList : constant := tokenize (pattern);
        tokenSrc : constant Token := ListTokenSource (tokenList);
        tokens : constant Token := CommonTokenStream (tokenSrc);

        parserInterp : constant := ParserInterpreter (parser.getGrammarFileName,;
                parser.getVocabulary,
                parser.getRuleNames,
                parser.getATNWithBypassAlts,
                tokens);

        parserInterp.setErrorHandler (BailErrorStrategy);
        tree : constant := parserInterp.parse (patternRuleIndex);

        -- Make sure tree pattern compilation checks for a complete parse
        if tokens.LA (1) /= CommonToken.EOF then
            raise ANTLRError.illegalState with "Tree pattern compilation doesn't check for a complete parse";
        end if;

        return ParseTreePattern (self, pattern, patternRuleIndex, tree);
    end if;

    --
    -- Used to convert the tree pattern string into a series of tokens. The
    -- input stream is reset.
    --
    -- public
    function getLexer (This : …) return Lexer is
begin
        return lexer
    end if;

    --
    -- Used to collect to the grammar file name, token names, rule names for
    -- used to parse the pattern into a parse tree.
    --
    -- public
    function getParser (This : …) return Parser is
begin
        return parser
    end if;

    -- ---- SUPPORT CODE ----

    --
    -- Recursively walk `tree` against `patternTree`, filling
    -- `match.`_org.antlr.v4.runtime.tree.pattern.ParseTreeMatch#labels labels_.
    --
    -- * Returns: the first node encountered in `tree` which does not match
    -- a corresponding node in `patternTree`, or `null` if the match
    -- was successful. The specific node returned depends on the matching
    -- algorithm used by the implementation, and may be overridden.
    --
    -- internal
    procedure matchImpl (tree : ParseTree;
                            patternTree : ParseTree;
                            labels : MultiMap<UString, ParseTree>) return Optional_ParseTree is
   begin

        -- x and <ID>, x and y, or x and x; or could be mismatched types
        if tree is TerminalNode and then patternTree is TerminalNode then
            t1 : constant TerminalNode := TerminalNode (tree);
            t2 : constant TerminalNode := TerminalNode (patternTree);
            mismatchedNode : Optional_ParseTree; := (Valid => False);
            -- both are tokens and they have same type
            if t1.getSymbol!.getType = t2.getSymbol!.getType then
                if t2.getSymbol is TokenTagToken then
                    -- x and <ID>
                    tokenTagToken : constant TokenTagToken := TokenTagToken (t2.getSymbol);
                    -- track label->list-of-nodes for both token name and label (if any);
                    labels.map (tokenTagToken.getTokenName, tree);
                    label : constant Optional_Token := Maybe (tokenTagToken.getLabel);
                     if Is_Valid (label) then
                        labels.map (label, tree);
                    end if;
                else
                    if t1.getText = t2.getText then
                        -- x and x
                    else
                        -- x and y
                        if not Is_Valid (mismatchedNode) then
                            mismatchedNode := t1;
                        end if;
                    end if;
                end if;
            else
                if not Is_Valid (mismatchedNode) then
                    mismatchedNode := t1;
                end if;
            end if;

            return mismatchedNode
        end if;

        if tree is ParserRuleContext and then patternTree is ParserRuleContext then
            r1 : constant ParserRuleContext := ParserRuleContext (tree);
            r2 : constant ParserRuleContext := ParserRuleContext (patternTree);
            mismatchedNode : Optional_ParseTree; := (Valid => False);
            -- (expr  .. ) and <expr>
            ruleTagToken : constant Optional_Token := Maybe (getRuleTagToken (r2));
             if Is_Valid (ruleTagToken) then
                if r1.getRuleContext.getRuleIndex = r2.getRuleContext.getRuleIndex then
                    -- track label->list-of-nodes for both rule name and label (if any);
                    labels.map (ruleTagToken.getRuleName, tree);
                    label : constant Optional_Token := Maybe (ruleTagToken.getLabel);
                     if Is_Valid (label) then
                        labels.map (label, tree);
                    end if;
                else
                    if not Is_Valid (mismatchedNode) then
                        mismatchedNode := r1;
                    end if;
                end if;

                return mismatchedNode
            end if;

            -- (expr  .. ) and (expr  .. );
            if r1.getChildCount /= r2.getChildCount then
                if not Is_Valid (mismatchedNode) then
                    mismatchedNode := r1;
                end if;

                return mismatchedNode
            end if;

            for i in 0 ..< r1.getChildCount loop
                if childMatch : constant := matchImpl (r1.Element (i), patternTree.Element (i), labels) then
                    return childMatch;
                end if;
            end loop;

            return mismatchedNode
        end if;

        -- if nodes aren't both tokens or both rule nodes, can't match
        return tree;
    end if;

    -- Is `t` `(expr <expr>)` subtree?
    -- internal
    function getRuleTagToken (t : ParseTree) return Optional_RuleTagToken is
        ruleNode : constant RuleNode := RuleNode (t);
        terminalNode : constant Optional_TerminalNode := Set (ruleNode.Element (0));
        ruleTag : constant Optional_RuleTagToken := Set (terminalNode.getSymbol);
   begin
        if Is_Valid (ruleNode)
         and then ruleNode.getChildCount = 1
         and then Is_Valid (terminalNode)
         and then Is_Valid (ruleTag) then
            if Is_Active (Aspect.DEBUG) then            
                  Wide_Wide_Text_IO.Put_Line ("rule tag subtree " & t.toStringTree (parser)'Image);
            end if;
            return ruleTag;
         else
            return (Valid => False);
         end if;
    end getRuleTagToken;

    -- public
    function tokenize (pattern : UString) return Array<Token> {
        -- split pattern into chunks: sea (raw input) and islands (<ID>, <expr>);
        chunks : constant := split (pattern);

        -- create token stream from text and tags
        tokens := Token.Container.Empty_Vector;
        for chunk in chunks loop
            tagChunk : constant Optional_TagChunk := Maybe (chunk);
            if Is_Valid (tagChunk) then
                -- add special rule token or conjure up new token from name
                firstStr : constant UString := To_String (tagChunk.getTag.first!);
                if firstStr.lowercased /= firstStr then
                    ttype : constant := parser.getTokenType (tagChunk.getTag);
                    if ttype = CommonToken.INVALID_TYPE then
                        raise ANTLRError.illegalArgument with "Unknown token " & tagChunk.getTag & " in pattern: " & pattern;
                    end if;
                    t : constant Token := TokenTagToken (tagChunk.getTag, ttype, tagChunk.getLabel);
                    tokens.append (t);
                else
                    if firstStr.uppercased /= firstStr then
                        ruleIndex : constant Integer := parser.getRuleIndex (tagChunk.getTag);
                        if ruleIndex == -1 then
                            raise ANTLRError.illegalArgument with "Unknown rule " & tagChunk.getTag & " in pattern: " & pattern;
                        end if;
                        ruleImaginaryTokenType : constant Integer := parser.getATNWithBypassAlts.ruleToTokenType.Element (ruleIndex);
                        tokens.append (RuleTagToken (tagChunk.getTag, ruleImaginaryTokenType, tagChunk.getLabel));
                    else
                        raise ANTLRError.illegalArgument with "invalid tag: " & tagChunk.getTag & " in pattern: " & pattern;
                    end if;
                end if;
            else
                textChunk : constant TextChunk := TextChunk (chunk);
                inputStream : constant := ANTLRInputStream (textChunk.getText);
                lexer.setInputStream (inputStream);
                t := lexer.nextToken;
                while t.getType /= CommonToken.EOF loop
                    tokens.append (t);
                    t := lexer.nextToken;
                end loop;
            end if;
        end loop;
         if Is_Active (Aspect.DEBUG) then
            Wide_Wide_Text_IO.Put_Line ("tokens=" & tokens'Image);
         end if;
        return tokens
    end itokenizef;

    --
    -- Split `<ID> := <e:expr> ;` into 4 chunks for tokenizing by _#tokenize_.
    --
    -- public
    function split (pattern : UString) return Chunk_Container.Vector is
        p := pattern.startIndex
        n : constant := pattern.endIndex
        chunks := Chunk.Container.Empty_Vector;
        -- find all start and stop indexes first, then collect
        starts := [Range<UString.Index>]();
        stops := [Range<UString.Index>]();
        escapedStart : constant := escape + start
        escapedStop : constant := escape + stop
        while p < n loop
            slice : constant := pattern[p .. ]
            if slice.hasPrefix (escapedStart) then
                p := pattern.index (p, offsetBy => escapedStart.count);
            elsif slice.hasPrefix (escapedStop) then
                p := pattern.index (p, offsetBy => escapedStop.count);
            elsif slice.hasPrefix (start) then
                upperBound : constant := pattern.index (p, offsetBy => start.count);
                starts.append (p ..< upperBound);
                p := upperBound
            end if;
            elsif slice.hasPrefix (stop) then
                upperBound : constant := pattern.index (p, offsetBy => stop.count);
                stops.append (p ..< upperBound);
                p := upperBound
            else
                p := pattern.index (after => p);
            end if;
        end loop;

        if starts.count > stops.count then
            raise ANTLRError.illegalArgument with "unterminated tag in pattern: " & pattern;
        end if;

        if starts.count < stops.count then
            raise ANTLRError.illegalArgument with "missing start tag in pattern: " & pattern;
        end if;

        ntags : constant := starts.count
        for i in 0 .. ntags - 1 loop
            if starts.Element (i).lowerBound >= stops.Element (i).lowerBound then
                raise ANTLRError.illegalArgument with "tag delimiters out of order in pattern: " & pattern;
            end if;
        end loop;

        -- collect into chunks now
        if ntags = 0 then
            text : constant UString := To_String (pattern[ .. n - 1]);
            chunks.append (TextChunk (text));
        end if;

        if ntags > 0 and then starts.Element (0).lowerBound > pattern.startIndex then
            -- copy text up to first tag into chunks
            text : constant := pattern[pattern.startIndex ..< starts.Element (0).lowerBound]
            chunks.append (TextChunk (String (text)));
        end if;

        for i in 0 ..< ntags loop
            -- copy inside of <tag>
            tag : constant := pattern[starts.Element (i).upperBound ..< stops.Element (i).lowerBound]
            ruleOrToken : constant UString;
            label : constant Optional_UString;
            bits : constant := tag.split (separator: ":", maxSplits => 1);
            if bits.count = 2 then
                label := UString (bits.Element (0));
                ruleOrToken := UString (bits.Element (1));
            else
                label := (Valid => False);
                ruleOrToken := UString (tag);
            end if;
            chunks.append (TagChunk (label, ruleOrToken));
            if i + 1 < ntags then
                -- copy from end of <tag> to start of next
                text : constant := pattern[stops.Element (i).upperBound ..< starts[i + 1].lowerBound]
                chunks.append (TextChunk (String (text)));
            end if;
        end loop;
        if ntags > 0 then
            afterLastTag : constant := stops[ntags - 1].upperBound
            if afterLastTag < n then
                -- copy text from end of last tag to end
                text : constant := pattern[afterLastTag ..< n]
                chunks.append (TextChunk (String (text)));
            end if;
        end if;

        -- strip out the escape sequences from text chunks but not tags
        for i in 0 ..< chunks.count loop
            c : constant := chunks.Element (i);
            tc : constant Optional_TextChunk := Maybe (c);
            if Is_Valid (tc) then
                unescaped : constant := tc.getText.replacingOccurrences (of => escape, with: "");
                if unescaped.count < tc.getText.count then
                    chunks.Insert (Key => i, New_Item => TextChunk (unescaped));
                end if;
            end if;
        end loop;

        return chunks
    end if;
end if;
