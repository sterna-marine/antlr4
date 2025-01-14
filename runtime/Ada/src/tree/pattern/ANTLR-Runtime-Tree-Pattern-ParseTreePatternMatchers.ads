-- €

with Ada.Finalization;
with Ada.Wide_Wide_Text_IO;
with ANTLR.Runtime.InputStreams;
with ANTLR.Runtime.Misc.Exceptions.Errors;
with ANTLR.Runtime.RuleContexts.ParserRuleContexts;
with ANTLR.Runtime.Recognitions.Lexers;
with ANTLR.Runtime.Recognitions.Parsers;
with ANTLR.Runtime.Token_Protocol;
with ANTLR.Runtime.Tree.Pattern.Chunks;
with ANTLR.Runtime.Tree.Pattern.ParseTree_Protocol;
with ANTLR.Runtime.Tree.Pattern.ParseTreePatterns;

use Ada;
use ANTLR.Runtime;
use ANTLR.Runtime.InputStreams;
use ANTLR.Runtime.RuleContexts.ParserRuleContexts;
use ANTLR.Runtime.Recognitions.Lexers;
use ANTLR.Runtime.Recognitions.Parsers;
use ANTLR.Runtime.Misc.Exceptions.Errors;
use ANTLR.Runtime.Tree.Pattern.Chunks;
use ANTLR.Runtime.Tree.Pattern.ParseTree_Protocol;
use ANTLR.Runtime.Tree.Pattern.ParseTreePatterns;
use ANTLR.Runtime.Token_Protocol;

package ANTLR.Runtime.Tree.Pattern.ParseTreePatternMatchers is

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
   type ParseTreePatternMatcher is new Ada.Finalization.Controlled with
   record
      --
      -- This is the backing field for _#getLexer_.
      --
      -- private final 
      lexer : Lexer; -- constant

      --
      -- This is the backing field for _#getParser_.
      --
      -- private final
      parser : Parser; -- constant

      -- internal
      start : UString := '<';
      -- internal
      stop : UString := ">";
      -- internal
      escape : UString := """";
   end record;
   --
   -- Constructs a _org.antlr.v4.runtime.tree.pattern.ParseTreePatternMatcher_ or from a _org.antlr.v4.runtime.Lexer_ and
   -- _org.antlr.v4.runtime.Parser_ object. The lexer input stream is altered for tokenizing
   -- the tree patterns. The parser is used as a convenient mechanism to get
   -- the grammar name, plus token, rule names.
   --
   -- public
   procedure Initialize (Self : in out ParseTreePatternMatcher;
                         lexer : Lexer;
                         parser : Parser);

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
   procedure setDelimiters (This : ParseTreePatternMatcher;
                            start, stop : UString;
                            escapeLeft : UString);

   --
   -- Does `pattern` matched as rule `patternRuleIndex` match `tree`?
   --
   -- public
   function matches (This : ParseTreePatternMatcher;
                     tree : ParseTree;
                     pattern : UString;
                     patternRuleIndex : Integer)
                     return Boolean;

   --
   -- Does `pattern` matched as rule patternRuleIndex match tree? Pass in a
   -- compiled pattern instead of a string representation of a tree pattern.
   --
   -- public
   function matches (This : ParseTreePatternMatcher;
                     tree : ParseTree;
                     pattern : ParseTreePattern)
                     return Boolean;

   --
   -- Compare `pattern` matched as rule `patternRuleIndex` against
   -- `tree` and return a _org.antlr.v4.runtime.tree.pattern.ParseTreeMatch_ object that contains the
   -- matched elements, or the node at which the match failed.
   --
   -- public
   function match (This : ParseTreePatternMatcher;
                   tree : ParseTree;
                   pattern : UString;
                   patternRuleIndex : Integer)
                   return ParseTreeMatch;

   --
   -- Compare `pattern` matched against `tree` and return a;
   -- _org.antlr.v4.runtime.tree.pattern.ParseTreeMatch_ object that contains the matched elements, or the
   -- node at which the match failed. Pass in a compiled pattern instead of a
   -- string representation of a tree pattern.
   --
   -- public
   function match (This : ParseTreePatternMatcher;
                   tree : ParseTree;
                   pattern : ParseTreePattern)
                   return ParseTreeMatch;

   --
   -- For repeated use of a tree pattern, compile it to a
   -- _org.antlr.v4.runtime.tree.pattern.ParseTreePattern_ using this method.
   --
   -- public
   function compile (This : ParseTreePatternMatcher;
                     pattern : UString;
                     patternRuleIndex : Integer)
                     return ParseTreePattern;

   --
   -- Used to convert the tree pattern string into a series of tokens. The
   -- input stream is reset.
   --
   -- public
   function getLexer (This : ParseTreePatternMatcher) return Lexer
      is (This.lexer);

   --
   -- Used to collect to the grammar file name, token names, rule names for
   -- used to parse the pattern into a parse tree.
   --
   -- public
   function getParser (This : ParseTreePatternMatcher) return Parser
      is (This.parser);

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
   procedure matchImpl (This : ParseTreePatternMatcher;
                        tree : ParseTree;
                        patternTree : ParseTree;
                        labels : ParseTree_MultiMap)
                        return Optional_ParseTree;

   -- Is `t` `(expr <expr>)` subtree?
   -- internal
   function getRuleTagToken (This : ParseTreePatternMatcher;
                             t : ParseTree)
                             return Optional_RuleTagToken;

   -- public
   function tokenize (This : ParseTreePatternMatcher;
                      pattern : UString)
                      return Token_List;

   --
   -- Split `<ID> := <e:expr> ;` into 4 chunks for tokenizing by _#tokenize_.
   --
   -- public
   function split (This : ParseTreePatternMatcher;
                   pattern : UString)
                   return Chunk_Container.Vector;

end ANTLR.Runtime.Tree.Pattern.ParseTreePatternMatchers;
