-- €

package body ANTLR.Runtime.Tree.Pattern.ParseTreePatterns is

   procedure Initialize (Self : in out ParseTreePattern;
                         matcher : ParseTreePatternMatcher;
                         pattern : UString;
                         patternRuleIndex : Integer;
                         patternTree : ParseTree) is
   begin
      self.matcher := matcher;
      self.patternRuleIndex := patternRuleIndex;
      self.pattern := pattern;
      self.patternTree := patternTree;
   end Initialize;

   function findAll (This : ParseTreePattern;
                     tree : ParseTree;
                     xpath : UString)
                     return ParseTreeMatch_List is
      subtrees : ParseTree_List := XPath.findAll (tree, xpath, This.matcher.getParser);
      matches : ParseTreeMatch_List;
   begin
      for t : ParseTree of subtrees loop
         match : ParseTreeMatch := match (t);
         if match.succeeded then
            matches.append (match);
         end if;
      end loop;
      return matches;
   end findAll;

end ANTLR.Runtime.Tree.Pattern.ParseTreePatterns;
