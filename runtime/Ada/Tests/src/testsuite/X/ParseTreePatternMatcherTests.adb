-- €

with ANTLR.Runtime;
with ANTLR.Runtime.InputStreams;
with ANTLR.Runtime.Tree.Pattern.ParseTreePatternMatchers;
with ANTLR.Runtime.BufferedTokenStreams;
with Sterna.DevTools.TestTools.UnitTest;

package body ParseTreePatternMatcherTests is

   -- private
   procedure doSplitTest (input : UString; expected : Chunk_List) is
      matcher : constant := This.makeMatcher;
   begin
      UnitTest.Assert_Equal (matcher.split (input), expected);
   end doSplitTest;

   -- private
   function makeMatcher return ParseTreePatternMatcher is
      -- The lexer and parser here aren't actually used.  They're just here
      -- so that ParseTreePatternMatcher can be constructed, but in this file
      -- we're currently only testing methods that don't depend on them.
      lexer : constant := This.Lexer;
      ts : constant Token := BufferedTokenStream (lexer);
      parser : constant := Parser (ts);
   begin
      return ParseTreePatternMatcher (lexer, parser);
   end makeMatcher;

   procedure testSplit is
   begin
      doSplitTest ("", [TextChunk ("")]);
      doSplitTest ("Foo", [TextChunk ("Foo")]);
      doSplitTest ("<ID> := <e:expr> ;",;
                     [TagChunk ("ID"), TextChunk (" := "), TagChunk ("e", "expr"), TextChunk (" ;")]);
      doSplitTest ("\\<ID\\> := <e:expr> ;",;
                     [TextChunk ("<ID> := "), TagChunk ("e", "expr"), TextChunk (" ;")]);
   end testSplit;

end ParseTreePatternMatcherTests;
