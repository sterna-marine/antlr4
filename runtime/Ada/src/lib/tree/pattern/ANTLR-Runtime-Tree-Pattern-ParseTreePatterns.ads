-- €

with Ada.Finalization;
with ANTLR.Runtime.Tree.Pattern.ParseTree_Protocol;
with ANTLR.Runtime.Tree.Pattern.ParseTreeMatchs;
with ANTLR.Runtime.Tree.Pattern.ParseTreePatternMatchers;

use ANTLR.Runtime.Tree.Pattern.ParseTree_Protocol;
use ANTLR.Runtime.Tree.Pattern.ParseTreeMatchs;
use ANTLR.Runtime.Tree.Pattern.ParseTreePatternMatchers;

package ANTLR.Runtime.Tree.Pattern.ParseTreePatterns is

   use ANTLR.Runtime;

   --
   -- A pattern like `<ID> := <expr>;` converted to a _org.antlr.v4.runtime.tree.ParseTree_ by
   -- _org.antlr.v4.runtime.tree.pattern.ParseTreePatternMatcher#compile (String, int)_.
   --

   -- public
   type ParseTreePattern is new Ada.Finalization.Controlled with
   record
      --
      -- This is the backing field for _#getPatternRuleIndex_.
      --
      -- private
      patternRuleIndex : Integer; -- constant

      --
      -- This is the backing field for _#getPattern_.
      --
      -- private
      pattern : UString; -- constant

      --
      -- This is the backing field for _#getPatternTree_.
      --
      -- private
      patternTree : ParseTree; -- constant

      --
      -- This is the backing field for _#getMatcher_.
      --
      -- private
      matcher : ParseTreePatternMatcher; -- constant
   end record;

   --
   -- Construct a new instance of the _org.antlr.v4.runtime.tree.pattern.ParseTreePattern_ class.
   --
   -- * Parameter matcher: The _org.antlr.v4.runtime.tree.pattern.ParseTreePatternMatcher_ which created this
   -- tree pattern.
   -- * Parameter pattern: The tree pattern in concrete syntax form.
   -- * Parameter patternRuleIndex: The parser rule which serves as the root of the
   -- tree pattern.
   -- * Parameter patternTree: The tree pattern in _org.antlr.v4.runtime.tree.ParseTree_ form.
   --
   -- public
   procedure Initialize (Self : in out ParseTreePattern;
                         matcher : ParseTreePatternMatcher;
                         pattern : UString;
                         patternRuleIndex : Integer;
                         patternTree : ParseTree);

   --
   -- Match a specific parse tree against this tree pattern.
   --
   -- * Parameter tree: The parse tree to match against this tree pattern.
   -- * Returns: A _org.antlr.v4.runtime.tree.pattern.ParseTreeMatch_ object describing the result of the
   -- match operation. The _org.antlr.v4.runtime.tree.pattern.ParseTreeMatch#succeeded_ method can be
   -- used to determine whether or not the match was successful.
   --

   -- public
   function match (This : ParseTreePattern;
                   tree : ParseTree)
                   return ParseTreeMatch
      is (This.matcher.match (tree, This));

   --
   -- Determine whether or not a parse tree matches this tree pattern.
   --
   -- * Parameter tree: The parse tree to match against this tree pattern.
   -- * Returns: `True` if `tree` is a match for the current tree
   -- pattern; otherwise, `False`.
   --
   -- public
   function matches (This : ParseTreePattern;
                     tree : ParseTree)
                     return Boolean
      is (This.matcher.match (tree, This).succeeded);
   
   --
   -- Find all nodes using XPath and then to match those subtrees against;
   -- this tree pattern.
   --
   -- * Parameter tree: The _org.antlr.v4.runtime.tree.ParseTree_ to match against this pattern.
   -- * Parameter xpath: An expression matching the nodes
   --
   -- * Returns: A collection of _org.antlr.v4.runtime.tree.pattern.ParseTreeMatch_ objects describing the
   -- successful matches. Unsuccessful matches are omitted from the result,
   -- regardless of the reason for the failure.
   --

   --  public
   function findAll (This : ParseTreePattern;
                     tree : ParseTree;
                     xpath : UString)
                     return ParseTreeMatch_List;

   --
   -- Get the _org.antlr.v4.runtime.tree.pattern.ParseTreePatternMatcher_ which created this tree pattern.
   --
   -- * Returns: The _org.antlr.v4.runtime.tree.pattern.ParseTreePatternMatcher_ which created this tree
   -- pattern.
   --

   -- public
   function getMatcher (This : ParseTreePattern) return ParseTreePatternMatcher
      is (This.matcher);

   --
   -- Get the tree pattern in concrete syntax form.
   --
   -- * Returns: The tree pattern in concrete syntax form.
   --

   -- public
   function getPattern (This : ParseTreePattern) return UString
      is (This.pattern);

   --
   -- Get the parser rule which serves as the outermost rule for the tree
   -- pattern.
   --
   -- * Returns: The parser rule which serves as the outermost rule for the tree
   -- pattern.
   --
   -- public
   function getPatternRuleIndex (This : ParseTreePattern) return Integer
      is (This.patternRuleIndex);

   --
   -- Get the tree pattern as a _org.antlr.v4.runtime.tree.ParseTree_. The rule and token tags from
   -- the pattern are present in the parse tree as terminal nodes with a symbol
   -- of type _org.antlr.v4.runtime.tree.pattern.RuleTagToken_ or _org.antlr.v4.runtime.tree.pattern.TokenTagToken_.
   --
   -- * Returns: The tree pattern as a _org.antlr.v4.runtime.tree.ParseTree_.
   --

   -- public
   function getPatternTree (This : ParseTreePattern) return ParseTree
      is (This.patternTree);

end ANTLR.Runtime.Tree.Pattern.ParseTreePatterns;
