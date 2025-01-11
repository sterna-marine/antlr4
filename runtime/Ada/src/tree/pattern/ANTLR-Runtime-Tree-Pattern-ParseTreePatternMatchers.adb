-- €

package body ANTLR.Runtime.Tree.Pattern.ParseTreePatternMatchers is

   procedure Initialize (Self : in out ParseTreePatternMatcher;
                         lexer : Lexer;
                         parser : Parser) is
   begin
      self.lexer := lexer;
      self.parser := parser;
   end Initialize;

   procedure setDelimiters (This : ParseTreePatternMatcher;
                            start, stop : UString;
                            escapeLeft : UString) is
   begin
      if start.Is_Empty then
         raise ANTLRError.illegalArgument with "start cannot be null or empty";
      elsif stop.Is_Empty then
         raise ANTLRError.illegalArgument with "stop cannot be null or empty";
      else
         This.start := start;
         This.stop := stop;
         This.escape := escapeLeft;
      end if;
   end setDelimiters;

   function matches (This : ParseTreePatternMatcher;
                     tree : ParseTree;
                     pattern : UString;
                     patternRuleIndex : Integer)
                     return Boolean is
      p : constant ParseTreePattern := This.compile (pattern, patternRuleIndex);
   begin
      return matches (tree, p);
   end matches;

   function matches (This : ParseTreePatternMatcher;
                     tree : ParseTree;
                     pattern : ParseTreePattern)
                     return Boolean is
      labels : constant ParseTree_MultiMap := ParseTree_MultiMap;
      mismatchedNode : constant Optional_ParseTree := This.matchImpl (tree, pattern.getPatternTree, labels);
   begin
      return not Is_Valid (mismatchedNode);
   end matches;

   function match (This : ParseTreePatternMatcher;
                   tree : ParseTree;
                   pattern : UString;
                   patternRuleIndex : Integer)
                   return ParseTreeMatch is
      p : constant ParseTreePattern := This.compile (pattern, patternRuleIndex);
   begin
      return match (tree, p);
   end match;

   function match (This : ParseTreePatternMatcher;
                   tree : ParseTree;
                   pattern : ParseTreePattern)
                   return ParseTreeMatch is
      labels : constant ParseTree_MultiMap;
      mismatchedNode : constant Optional_ParseTree := This.matchImpl (tree, pattern.getPatternTree, labels);
   begin
      return ParseTreeMatch (tree, pattern, labels, mismatchedNode);
   end match;

   function compile (This : ParseTreePatternMatcher;
                     pattern : UString;
                     patternRuleIndex : Integer)
                     return ParseTreePattern is
      tokenList : constant := tokenize (pattern);
      tokenSrc : constant Token := ListTokenSource (tokenList);
      tokens : constant Token := CommonTokenStream (tokenSrc);
   begin
      parserInterp : constant ParserInterpreter := ParserInterpreter (
               parser.getGrammarFileName,
               parser.getVocabulary,
               parser.getRuleNames,
               parser.getATNWithBypassAlts,
               tokens);
      parserInterp.setErrorHandler (BailErrorStrategy);
      tree : constant ParserRuleContext := parserInterp.parse (patternRuleIndex);

      -- Make sure tree pattern compilation checks for a complete parse
      if tokens.LA (1) /= EOF then
         raise ANTLRError.illegalState with "Tree pattern compilation doesn't check for a complete parse";
      else
         return ParseTreePattern (This, pattern, patternRuleIndex, tree);
      end if;
   end compile;

   procedure matchImpl (This : ParseTreePatternMatcher;
                        tree : ParseTree;
                        patternTree : ParseTree;
                        labels : ParseTree_MultiMap)
                        return Optional_ParseTree is
   begin
      -- x and <ID>, x and y, or x and x; or could be mismatched types
      if tree is TerminalNode
      and then patternTree is TerminalNode then
         t1 : constant TerminalNode := TerminalNode (tree);
         t2 : constant TerminalNode := TerminalNode (patternTree);
         mismatchedNode : Optional_ParseTree := (Valid => False);
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

         return mismatchedNode;
      end if;

      if tree is ParserRuleContext
      and then patternTree is ParserRuleContext then
         r1 : constant ParserRuleContext := ParserRuleContext (tree);
         r2 : constant ParserRuleContext := ParserRuleContext (patternTree);
         mismatchedNode : Optional_ParseTree := (Valid => False);
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

               return mismatchedNode;
         end if;

         -- (expr  .. ) and (expr  .. );
         if r1.getChildCount /= r2.getChildCount then
            if not Is_Valid (mismatchedNode) then
               mismatchedNode := r1;
            end if;
            return mismatchedNode;
         else
            for i in 0 .. r1.getChildCount - 1 loop
                  if childMatch : constant := matchImpl (r1.Element (i), patternTree.Element (i), labels) then
                     return childMatch;
                  end if;
            end loop;
            return mismatchedNode;
         end if;
      end if;

      -- if nodes aren't both tokens or both rule nodes, can't match
      return tree;
   end matchImpl;

   function getRuleTagToken (This : ParseTreePatternMatcher;
                             t : ParseTree)
                             return Optional_RuleTagToken is
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

   function tokenize (This : ParseTreePatternMatcher;
                      pattern : UString)
                      return Token_List is
      -- split pattern into chunks: sea (raw input) and islands (<ID>, <expr>);
      chunks : constant := split (pattern);
   begin
      -- create token stream from text and tags
      tokens : Token_List := Token_Container.Empty_Vector;
      for chunk of chunks loop
         tagChunk : constant Optional_TagChunk := Maybe (chunk);
         if Is_Valid (tagChunk) then
            -- add special rule token or conjure up new token from name
            firstStr : constant UString := To_String (tagChunk.getTag.first!);
            if firstStr.lowercased /= firstStr then
               ttype : constant := parser.getTokenType (tagChunk.getTag);
               if ttype = CommonToken.INVALID_TYPE then
                  raise ANTLRError.illegalArgument with "Unknown token " & tagChunk.getTag & " in pattern: " & pattern;
               else
                  t : constant Token := TokenTagToken (tagChunk.getTag, ttype, tagChunk.getLabel);
                  tokens.append (t);
               end if;
            else
               if firstStr.uppercased /= firstStr then
                  ruleIndex : constant Integer := parser.getRuleIndex (tagChunk.getTag);
                  if ruleIndex = -1 then
                     raise ANTLRError.illegalArgument with "Unknown rule " & tagChunk.getTag & " in pattern: " & pattern;
                  else
                     ruleImaginaryTokenType : constant Integer := parser.getATNWithBypassAlts.ruleToTokenType.Element (ruleIndex);
                     tokens.append (RuleTagToken (tagChunk.getTag, ruleImaginaryTokenType, tagChunk.getLabel));
                  end if;
               else
                  raise ANTLRError.illegalArgument with "invalid tag: " & tagChunk.getTag & " in pattern: " & pattern;
               end if;
            end if;
         else
            textChunk : constant TextChunk := TextChunk (chunk);
            inputStream : constant ANTLRInputStream := ANTLRInputStream (textChunk.getText);
            lexer.setInputStream (inputStream);
            t := lexer.nextToken;
            while t.getType /= EOF loop
               tokens.append (t);
               t := lexer.nextToken;
            end loop;
         end if;
      end loop;
      if Is_Active (Aspect.DEBUG) then
         Wide_Wide_Text_IO.Put_Line ("tokens=" & tokens'Image);
      end if;
      return tokens;
   end itokenizef;

   function split (This : ParseTreePatternMatcher;
                   pattern : UString)
                   return Chunk_Container.Vector is
      p : Integer := pattern.startIndex;
      n : constant Integer := pattern.endIndex;
      chunks := Chunk.Container.Empty_Vector;
      -- find all start and stop indexes first, then collect
      starts := [Range<UString.Index>]();
      stops := [Range<UString.Index>]();
      escapedStart : constant Integer := escape + start;
      escapedStop : constant Integer := escape + stop; 
   begin
      while p < n loop
         slice : constant := pattern [p .. ];
         if slice.hasPrefix (escapedStart) then
            p := pattern.index (p, offsetBy => escapedStart.count);
         elsif slice.hasPrefix (escapedStop) then
            p := pattern.index (p, offsetBy => escapedStop.count);
         elsif slice.hasPrefix (start) then
            upperBound : constant := pattern.index (p, offsetBy => start.count);
            starts.append (p .. upperBound - 1);
            p := upperBound;
         end if;
         elsif slice.hasPrefix (stop) then
            upperBound : constant := pattern.index (p, offsetBy => stop.count);
            stops.append (p .. upperBound -1);
            p := upperBound
         else
            p := pattern.index (after => p);
         end if;
      end loop;

      if starts.count > stops.count then
         raise ANTLRError.illegalArgument with "unterminated tag in pattern: " & pattern;
      elsif starts.count < stops.count then
         raise ANTLRError.illegalArgument with "missing start tag in pattern: " & pattern;
      else
         ntags : constant := starts.count;
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
            text : constant := pattern[pattern.startIndex .. starts.Element (0).lowerBound - 1];
            chunks.append (TextChunk (String (text)));
         end if;

         for i in 0 .. ntags - 1 loop
            -- copy inside of <tag>
            tag : constant := pattern[starts.Element (i).upperBound .. stops.Element (i).lowerBound - 1]
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
               text : constant := pattern[stops.Element (i).upperBound .. starts [i + 1].lowerBound - 1]
               chunks.append (TextChunk (String (text)));
            end if;
         end loop;

         if ntags > 0 then
            afterLastTag : constant := stops[ntags - 1].upperBound
            if afterLastTag < n then
               -- copy text from end of last tag to end
               text : constant := pattern[afterLastTag .. n - 1]
               chunks.append (TextChunk (String (text)));
            end if;
         end if;

         -- strip out the escape sequences from text chunks but not tags
         for i in 0 .. chunks.count - 1 loop
            c : constant := chunks.Element (i);
            tc : constant Optional_TextChunk := Maybe (c);
            if Is_Valid (tc) then
               unescaped : constant := tc.getText.replacingOccurrences (of => escape, with: "");
               if unescaped.count < tc.getText.count then
                  chunks.Insert (Key => i, New_Item => TextChunk (unescaped));
               end if;
            end if;
         end loop;

         return chunks;
      end if;
   end split;

end ANTLR.Runtime.Tree.Pattern.ParseTreePatternMatchers;
