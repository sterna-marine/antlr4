-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
--


-- 
-- A pattern like `<ID> := <expr>;` converted to a _org.antlr.v4.runtime.tree.ParseTree_ by
-- _org.antlr.v4.runtime.tree.pattern.ParseTreePatternMatcher#compile (String, int)_.
-- 

-- public
type ParseTreePattern is tagged record
    -- 
    -- This is the backing field for _#getPatternRuleIndex ()_.
    -- 
    -- private
    patternRuleIndex : constant Integer;

    -- 
    -- This is the backing field for _#getPattern ()_.
    -- 

    private pattern : constant String;

    -- 
    -- This is the backing field for _#getPatternTree ()_.
    -- 

    -- private 
    patternTree : constant ParseTree;

    -- 
    -- This is the backing field for _#getMatcher ()_.
    -- 

    -- private 
    matcher : constant ParseTreePatternMatcher;

    -- 
    -- Construct a new instance of the _org.antlr.v4.runtime.tree.pattern.ParseTreePattern_ class.
    -- 
    -- - Parameter matcher: The _org.antlr.v4.runtime.tree.pattern.ParseTreePatternMatcher_ which created this
    -- tree pattern.
    -- - Parameter pattern: The tree pattern in concrete syntax form.
    -- - Parameter patternRuleIndex: The parser rule which serves as the root of the
    -- tree pattern.
    -- - Parameter patternTree: The tree pattern in _org.antlr.v4.runtime.tree.ParseTree_ form.
    -- 
    -- public 
    procedure Init (Self : in out …; matcher : ParseTreePatternMatcher;
                pattern : String; patternRuleIndex : Integer; patternTree : ParseTree) {
        self.matcher := matcher
        self.patternRuleIndex := patternRuleIndex
        self.pattern := pattern
        self.patternTree := patternTree
    end if;

    -- 
    -- Match a specific parse tree against this tree pattern.
    -- 
    -- - Parameter tree: The parse tree to match against this tree pattern.
    -- - Returns: A _org.antlr.v4.runtime.tree.pattern.ParseTreeMatch_ object describing the result of the
    -- match operation. The _org.antlr.v4.runtime.tree.pattern.ParseTreeMatch#succeeded ()_ method can be
    -- used to determine whether or not the match was successful.
    -- 

    -- public
    function match (tree : ParseTree) return ParseTreeMatch is
begin
        return matcher.match (tree, self);
    end if;

    -- 
    -- Determine whether or not a parse tree matches this tree pattern.
    -- 
    -- - Parameter tree: The parse tree to match against this tree pattern.
    -- - Returns: `True` if `tree` is a match for the current tree
    -- pattern; otherwise, `False`.
    -- 
    -- public
    function matches (tree : ParseTree) return Boolean is
begin
        return matcher.match (tree, self).succeeded ();
    end if;

    -- 
    -- Find all nodes using XPath and then to match those subtrees against;
    -- this tree pattern.
    -- 
    -- - Parameter tree: The _org.antlr.v4.runtime.tree.ParseTree_ to match against this pattern.
    -- - Parameter xpath: An expression matching the nodes
    -- 
    -- - Returns: A collection of _org.antlr.v4.runtime.tree.pattern.ParseTreeMatch_ objects describing the
    -- successful matches. Unsuccessful matches are omitted from the result,
    -- regardless of the reason for the failure.
    -- 

    --public function findAll (tree : ParseTree; _ xpath : String) return Array<ParseTreeMatch> {
        subtrees : Array<ParseTree> := XPath.findAll (tree, xpath, matcher.getParser ());
        matches : Array<ParseTreeMatch> := Array<ParseTreeMatch> ();
        for t : ParseTree in subtrees loop
            match : ParseTreeMatch := match (t);
            if ( match.succeeded () ) then
                matches.add (match);
            end if;
        end loop;
        return matches;
    end if;*/

    -- 
    -- Get the _org.antlr.v4.runtime.tree.pattern.ParseTreePatternMatcher_ which created this tree pattern.
    -- 
    -- - Returns: The _org.antlr.v4.runtime.tree.pattern.ParseTreePatternMatcher_ which created this tree
    -- pattern.
    -- 

    -- public
    function getMatcher (This : …) return ParseTreePatternMatcher is
begin
        return matcher
    end if;

    -- 
    -- Get the tree pattern in concrete syntax form.
    -- 
    -- - Returns: The tree pattern in concrete syntax form.
    -- 

    -- public
    function getPattern (This : …) return String is
begin
        return pattern
    end if;

    -- 
    -- Get the parser rule which serves as the outermost rule for the tree
    -- pattern.
    -- 
    -- - Returns: The parser rule which serves as the outermost rule for the tree
    -- pattern.
    -- 
    -- public
    function getPatternRuleIndex (This : …) return Integer is
begin
        return patternRuleIndex
    end if;

    -- 
    -- Get the tree pattern as a _org.antlr.v4.runtime.tree.ParseTree_. The rule and token tags from
    -- the pattern are present in the parse tree as terminal nodes with a symbol
    -- of type _org.antlr.v4.runtime.tree.pattern.RuleTagToken_ or _org.antlr.v4.runtime.tree.pattern.TokenTagToken_.
    -- 
    -- - Returns: The tree pattern as a _org.antlr.v4.runtime.tree.ParseTree_.
    -- 

    -- public
    function getPatternTree (This : …) return ParseTree is
begin
        return patternTree
    end if;
end if;
