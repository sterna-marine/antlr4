-- €

with AdaForge.DevTools.TestTools.UnitTest;
with ANTLR.Runtime;
with ANTLR.Runtime.BufferedTokenStreams.CommonTokenStreams;
with ANTLR.Runtime.BufferedTokenStreams.CommonTokenStreams;
with ANTLR.Runtime.InputStreams;
with ANTLR.Runtime.InputStreams;
with ANTLR.Runtime.Lexers;
with ANTLR.Runtime.Lexers;
with ANTLR.Runtime.Parsers;

use AdaForge.DevTools.TestTools.UnitTest;

package body TokenStreamRewriterTests is

   overriding
   procedure Initialize (T : in out Test) is
   begin
      Set_Name (T, "TokenStreamRewriter Tests");

      UnitTest.Add_Test_Routine (T, testPreservesOrderOfContiguousInserts'Access, "testPreservesOrderOfContiguousInserts");
      UnitTest.Add_Test_Routine (T, testDistinguishBetweenInsertAfterAndInsertBeforeToPreserverOrder2'Access, "testDistinguishBetweenInsertAfterAndInsertBeforeToPreserverOrder2");
      UnitTest.Add_Test_Routine (T, testDistinguishBetweenInsertAfterAndInsertBeforeToPreserverOrder'Access, "testDistinguishBetweenInsertAfterAndInsertBeforeToPreserverOrder");
      UnitTest.Add_Test_Routine (T, testInsertBeforeTokenThenDeleteThatToken'Access, "testInsertBeforeTokenThenDeleteThatToken");
      UnitTest.Add_Test_Routine (T, testLeaveAloneDisjointInsert2'Access, "testLeaveAloneDisjointInsert2");
      UnitTest.Add_Test_Routine (T, testLeaveAloneDisjointInsert'Access, "testLeaveAloneDisjointInsert");
      UnitTest.Add_Test_Routine (T, testDropPrevCoveredInsert'Access, "testDropPrevCoveredInsert");
      UnitTest.Add_Test_Routine (T, testDropIdenticalReplace'Access, "testDropIdenticalReplace");
      UnitTest.Add_Test_Routine (T, testOverlappingReplace4'Access, "testOverlappingReplace4");
      UnitTest.Add_Test_Routine (T, testOverlappingReplace3'Access, "testOverlappingReplace3");
      UnitTest.Add_Test_Routine (T, testOverlappingReplace2'Access, "testOverlappingReplace2");
      UnitTest.Add_Test_Routine (T, testOverlappingReplace'Access, "testOverlappingReplace");
      UnitTest.Add_Test_Routine (T, testDisjointInserts'Access, "testDisjointInserts");
      UnitTest.Add_Test_Routine (T, testCombineInsertOnLeftWithDelete'Access, "testCombineInsertOnLeftWithDelete");
      UnitTest.Add_Test_Routine (T, testCombineInsertOnLeftWithReplace'Access, "testCombineInsertOnLeftWithReplace");
      UnitTest.Add_Test_Routine (T, testCombine3Inserts'Access, "testCombine3Inserts");
      UnitTest.Add_Test_Routine (T, testCombineInserts'Access, "testCombineInserts");
      UnitTest.Add_Test_Routine (T, testReplaceSingleMiddleThenOverlappingSuperset'Access, "testReplaceSingleMiddleThenOverlappingSuperset");
      UnitTest.Add_Test_Routine (T, testReplaceThenReplaceLowerIndexedSuperset'Access, "testReplaceThenReplaceLowerIndexedSuperset");
      UnitTest.Add_Test_Routine (T, testReplaceThenReplaceSuperset'Access, "testReplaceThenReplaceSuperset");
      UnitTest.Add_Test_Routine (T, testReplaceSubsetThenFetch'Access, "testReplaceSubsetThenFetch");
      UnitTest.Add_Test_Routine (T, testReplaceAll'Access, "testReplaceAll");
      UnitTest.Add_Test_Routine (T, testReplaceRangeThenInsertAfterRightEdge'Access, "testReplaceRangeThenInsertAfterRightEdge");
      UnitTest.Add_Test_Routine (T, testReplaceRangeThenInsertAtRightEdge'Access, "testReplaceRangeThenInsertAtRightEdge");
      UnitTest.Add_Test_Routine (T, testReplaceThenInsertAtLeftEdge'Access, "testReplaceThenInsertAtLeftEdge");
      UnitTest.Add_Test_Routine (T, testReplaceThenInsertAfterLastIndex'Access, "testReplaceThenInsertAfterLastIndex");
      UnitTest.Add_Test_Routine (T, testInsertThenReplaceLastIndex'Access, "testInsertThenReplaceLastIndex");
      UnitTest.Add_Test_Routine (T, testReplaceThenInsertBeforeLastIndex'Access, "testReplaceThenInsertBeforeLastIndex");
      UnitTest.Add_Test_Routine (T, test2InsertThenReplaceIndex0'Access, "test2InsertThenReplaceIndex0");
      UnitTest.Add_Test_Routine (T, test2InsertMiddleIndex'Access, "test2InsertMiddleIndex");
      UnitTest.Add_Test_Routine (T, testInsertThenReplaceSameIndex'Access, "testInsertThenReplaceSameIndex");
      UnitTest.Add_Test_Routine (T, testInsertInPriorReplace'Access, "testInsertInPriorReplace");
      UnitTest.Add_Test_Routine (T, testReplaceThenDeleteMiddleIndex'Access, "testReplaceThenDeleteMiddleIndex");
      UnitTest.Add_Test_Routine (T, test2ReplaceMiddleIndex1InsertBefore'Access, "test2ReplaceMiddleIndex1InsertBefore");
      UnitTest.Add_Test_Routine (T, test2ReplaceMiddleIndex'Access, "test2ReplaceMiddleIndex");
      UnitTest.Add_Test_Routine (T, testToStringStartStop2'Access, "testToStringStartStop2");
      UnitTest.Add_Test_Routine (T, testToStringStartStop'Access, "testToStringStartStop");
      UnitTest.Add_Test_Routine (T, testReplaceMiddleIndex'Access, "testReplaceMiddleIndex");
      UnitTest.Add_Test_Routine (T, testReplaceLastIndex'Access, "testReplaceLastIndex");
      UnitTest.Add_Test_Routine (T, testReplaceIndex0'Access, "testReplaceIndex0");
      UnitTest.Add_Test_Routine (T, test2InsertBeforeAfterMiddleIndex'Access, "test2InsertBeforeAfterMiddleIndex");
      UnitTest.Add_Test_Routine (T, testInsertAfterLastIndex'Access, "testInsertAfterLastIndex");
      UnitTest.Add_Test_Routine (T, testInsertBeforeIndex0'Access, "testInsertBeforeIndex0");
   end Initialize;

   procedure testInsertBeforeIndex0 is
      input : constant ANTLRInputStream := ANTLRInputStream.Initialize ("abc");
      lexer : constant := LexerA (input);
      stream : constant Token := CommonTokenStream (lexer);
      stream.fill ();
      tokens : constant := TokenStreamRewriter (stream);
      tokens.insertBefore (0, "0");
      result : constant := tokens.getText ();
      expecting : constant UString := "0abc";
   begin
      UnitTest.Assert_Equal (expecting, result);
   end testInsertBeforeIndex0;

   procedure testInsertAfterLastIndex is
      expecting : constant UString := "abcx";
   begin
      input : constant ANTLRInputStream := ANTLRInputStream.Initialize ("abc");
      lexer : constant Lexer := LexerA (input);
      stream : constant Token := CommonTokenStream (lexer);
      stream.fill ();
      tokens : constant TokenStreamRewriter := TokenStreamRewriter (stream);
      result : constant UString := tokens.getText ();
      tokens.insertAfter (2, "x");
      UnitTest.Assert_Equal (expecting, result);
   end if;

   procedure test2InsertBeforeAfterMiddleIndex is
      expecting : constant UString := "axbxc";
   begin
      input : constant := ANTLRInputStream ("abc");
      lexer : constant := LexerA (input);
      stream : constant Token := CommonTokenStream (lexer);
      stream.fill ();
      tokens : constant := TokenStreamRewriter (stream);
      tokens.insertBefore (1, "x");
      tokens.insertAfter (1, "x");
      result : constant := tokens.getText ();
      UnitTest.Assert_Equal (expecting, result);
   end itest2InsertBeforeAfterMiddleIndexf;

   procedure testReplaceIndex0 is
      expecting : constant UString := "xbc";
   begin
      input : constant := ANTLRInputStream ("abc");
      lexer : constant := LexerA (input);
      stream : constant Token := CommonTokenStream (lexer);
      stream.fill ();
      tokens : constant := TokenStreamRewriter (stream);
      tokens.replace (0, "x");
      result : constant := tokens.getText ();
      UnitTest.Assert_Equal (expecting, result);
   end testReplaceIndex0;

   procedure testReplaceLastIndex is
      expecting : constant UString := "abx";
   begin
      input : constant := ANTLRInputStream ("abc");
      lexer : constant := LexerA (input);
      stream : constant Token := CommonTokenStream (lexer);
      stream.fill ();
      tokens : constant := TokenStreamRewriter (stream);
      tokens.replace (2, "x");
      result : constant := tokens.getText ();
      UnitTest.Assert_Equal (expecting, result);
   end testReplaceLastIndex;

   procedure testReplaceMiddleIndex is
      expecting : constant UString := "axc";
   begin
      input : constant := ANTLRInputStream ("abc");
      lexer : constant := LexerA (input);
      stream : constant Token := CommonTokenStream (lexer);
      stream.fill ();
      tokens : constant := TokenStreamRewriter (stream);
      tokens.replace (1, "x");
      result : constant := tokens.getText ();
      UnitTest.Assert_Equal (expecting, result);
   end testReplaceMiddleIndex;

   procedure testToStringStartStop is
      expecting_1 : constant UString := "x := 3 * 0;";
      expecting_2 : constant UString := "x := 0;";
      expecting_3 : constant UString := "x := 0;";
      expecting_4 : constant UString := "0";
   begin
      -- Tokens: 0123456789
      -- Input:  x := 3 * 0
      input : constant := ANTLRInputStream ("x := 3 * 0;");
      lexer : constant := LexerB (input);
      stream : constant Token := CommonTokenStream (lexer);
      stream.fill ();
      tokens : constant := TokenStreamRewriter (stream);

      -- replace 3 * 0 with 0
      tokens.replace (4, 8, "0");
      stream.fill ();

      result := tokens.getTokenStream ().getText ();
      UnitTest.Assert_Equal (expecting_1, result);

      result := tokens.getText ();
      UnitTest.Assert_Equal (expecting_2, result);

      result := tokens.getText (Interval.of (0, 9));
      UnitTest.Assert_Equal (expecting_3, result);

      result := tokens.getText (Interval.of (4, 8));
      UnitTest.Assert_Equal (expecting_4, result);
   end testToStringStartStop;

   procedure testToStringStartStop2 is
      expecting_1 : constant Ustring := "x := 3 * 0 + 2 * 0;";
      expecting_2 : constant Ustring := "x := 0 + 2 * 0;";
      expecting_3 : constant Ustring := "x := 0 + 2 * 0;";
      expecting_4 : constant Ustring := "0";
      expecting_5 : constant Ustring := "x := 0";
      expecting_6 : constant Ustring := "2 * 0";
      expecting_7 : constant Ustring := "2 * 0;-- comment";
      expecting_8 : constant Ustring := "x := 0";
   begin
      -- Tokens: 012345678901234567
      -- Input:  x := 3 * 0 + 2 * 0;
      input : constant := ANTLRInputStream ("x := 3 * 0 + 2 * 0;");
      lexer : constant := LexerB (input);
      stream : constant Token := CommonTokenStream (lexer);
      stream.fill ();
      tokens : constant := TokenStreamRewriter (stream);

      result := tokens.getTokenStream ().getText ();
      UnitTest.Assert_Equal (expecting_1, result);

      -- replace 3 * 0 with 0
      tokens.replace (4, 8, "0");
      stream.fill ();

      result := tokens.getText ();
      UnitTest.Assert_Equal (expecting_2, result);

      result := tokens.getText (Interval.of (0, 17));
      UnitTest.Assert_Equal (expecting_3, result);

      result := tokens.getText (Interval.of (4, 8));
      UnitTest.Assert_Equal (expecting_4, result);

      result := tokens.getText (Interval.of (0, 8));
      UnitTest.Assert_Equal (expecting_5, result);

      result := tokens.getText (Interval.of (12, 16));
      UnitTest.Assert_Equal (expecting_6, result);

      tokens.insertAfter (17, "-- comment");
      result := tokens.getText (Interval.of (12, 18));
      UnitTest.Assert_Equal (expecting_7, result);

      result := tokens.getText (Interval.of (0, 8));
      stream.fill ();
      -- again after insert at end;
      UnitTest.Assert_Equal (expecting_8, result);
   end testToStringStartStop2;

   procedure test2ReplaceMiddleIndex is
      expecting : constant UString := "ayc";
   begin
      input : constant := ANTLRInputStream ("abc");
      lexer : constant := LexerA (input);
      stream : constant Token := CommonTokenStream (lexer);
      stream.fill ();
      tokens : constant := TokenStreamRewriter (stream);
      tokens.replace (1, "x");
      tokens.replace (1, "y");
      result : constant := tokens.getText ();
      UnitTest.Assert_Equal (expecting, result);
   end test2ReplaceMiddleIndex;

   procedure test2ReplaceMiddleIndex1InsertBefore is
      expecting : constant UString := "_ayc";
   begin
      input : constant := ANTLRInputStream ("abc");
      lexer : constant := LexerA (input);
      stream : constant Token := CommonTokenStream (lexer);
      stream.fill ();
      tokens : constant := TokenStreamRewriter (stream);
      tokens.insertBefore (0, "_");
      tokens.replace (1, "x");
      tokens.replace (1, "y");
      result : constant := tokens.getText ();
      UnitTest.Assert_Equal (expecting, result);
   end test2ReplaceMiddleIndex1InsertBefore;

   procedure testReplaceThenDeleteMiddleIndex is
      expecting : constant UString := "ac";
   begin
      input : constant := ANTLRInputStream ("abc");
      lexer : constant := LexerA (input);
      stream : constant Token := CommonTokenStream (lexer);
      stream.fill ();
      tokens : constant := TokenStreamRewriter (stream);
      tokens.replace (1, "x");
      tokens.delete (1);
      result : constant := tokens.getText ();
      UnitTest.Assert_Equal (expecting, result);
   end testReplaceThenDeleteMiddleIndex;

   procedure testInsertInPriorReplace is
   begin
      input : constant := ANTLRInputStream ("abc");
      lexer : constant := LexerA (input);
      stream : constant Token := CommonTokenStream (lexer);
      stream.fill ();
      tokens : constant := TokenStreamRewriter (stream);
      tokens.replace (0, 2, "x");
      tokens.insertBefore (1, "0");

      declare
         expecting : constant UString := "insert op <InsertBeforeOp@[@1,1:1='b',<2>,1:1]:""0""> within boundaries of previous <ReplaceOp@[@0,0:0='a',<1>,1:0]..[@2,2:2='c',<3>,1:2]:""x"">";
      begin
         Dummy_Text := tokens.getText ();
         UnitTest.Fail ("Expected exception not thrown.");
      exception
         when ANTLRError.illegalArgument =>
            msg;
            UnitTest.Assert_Equal (expecting, msg);
      end if;
   end testInsertInPriorReplace;

   procedure testInsertThenReplaceSameIndex is
      expecting : constant UString := "0xbc";
   begin
      input : constant := ANTLRInputStream ("abc");
      lexer : constant := LexerA (input);
      stream : constant Token := CommonTokenStream (lexer);
      stream.fill ();
      tokens : constant := TokenStreamRewriter (stream);
      tokens.insertBefore (0, "0");
      tokens.replace (0, "x");
      result : constant := tokens.getText ();
      UnitTest.Assert_Equal (expecting, result);
   end testInsertThenReplaceSameIndex;

   procedure test2InsertMiddleIndex is
      expecting : constant UString := "ayxbc";
   begin
      input : constant := ANTLRInputStream ("abc");
      lexer : constant := LexerA (input);
      stream : constant Token := CommonTokenStream (lexer);
      stream.fill ();
      tokens : constant := TokenStreamRewriter (stream);
      tokens.insertBefore (1, "x");
      tokens.insertBefore (1, "y");
      result : constant := tokens.getText ();
      UnitTest.Assert_Equal (expecting, result);
   end test2InsertMiddleIndex;

   procedure test2InsertThenReplaceIndex0 is
      expecting : constant UString := "yxzbc";
   begin
      input : constant := ANTLRInputStream ("abc");
      lexer : constant := LexerA (input);
      stream : constant Token := CommonTokenStream (lexer);
      stream.fill ();
      tokens : constant := TokenStreamRewriter (stream);
      tokens.insertBefore (0, "x");
      tokens.insertBefore (0, "y");
      tokens.replace (0, "z");
      result : constant := tokens.getText ();
      UnitTest.Assert_Equal (expecting, result);
   end test2InsertThenReplaceIndex0;

   procedure testReplaceThenInsertBeforeLastIndex is
      expecting : constant UString := "abyx";
   begin
      input : constant := ANTLRInputStream ("abc");
      lexer : constant := LexerA (input);
      stream : constant Token := CommonTokenStream (lexer);
      stream.fill ();
      tokens : constant := TokenStreamRewriter (stream);
      tokens.replace (2, "x");
      tokens.insertBefore (2, "y");
      result : constant := tokens.getText ();
      UnitTest.Assert_Equal (expecting, result);
   end testReplaceThenInsertBeforeLastIndex;

   procedure testInsertThenReplaceLastIndex is
      expecting : constant UString := "abyx";
   begin
      input : constant := ANTLRInputStream ("abc");
      lexer : constant := LexerA (input);
      stream : constant Token := CommonTokenStream (lexer);
      stream.fill ();
      tokens : constant := TokenStreamRewriter (stream);
      tokens.insertBefore (2, "y");
      tokens.replace (2, "x");
      result : constant := tokens.getText ();
      UnitTest.Assert_Equal (expecting, result);
   end testInsertThenReplaceLastIndex;

   procedure testReplaceThenInsertAfterLastIndex is
      expecting : constant UString := "abxy";
   begin
      input : constant := ANTLRInputStream ("abc");
      lexer : constant := LexerA (input);
      stream : constant Token := CommonTokenStream (lexer);
      stream.fill ();
      tokens : constant := TokenStreamRewriter (stream);
      tokens.replace (2, "x");
      tokens.insertAfter (2, "y");
      result : constant := tokens.getText ();
      UnitTest.Assert_Equal (expecting, result);
   end testReplaceThenInsertAfterLastIndex;

   procedure testReplaceThenInsertAtLeftEdge is
      expecting : constant UString := "abyxba";
   begin
      input : constant := ANTLRInputStream ("abcccba");
      lexer : constant := LexerA (input);
      stream : constant Token := CommonTokenStream (lexer);
      stream.fill ();
      tokens : constant := TokenStreamRewriter (stream);
      tokens.replace (2, 4, "x");
      tokens.insertBefore (2, "y");
      result : constant := tokens.getText ();
      UnitTest.Assert_Equal (expecting, result);
   end testReplaceThenInsertAtLeftEdge;

   procedure testReplaceRangeThenInsertAtRightEdge is
   begin
      input : constant := ANTLRInputStream ("abcccba");
      lexer : constant := LexerA (input);
      stream : constant Token := CommonTokenStream (lexer);
      stream.fill ();
      tokens : constant := TokenStreamRewriter (stream);
      tokens.replace (2, 4, "x");
      tokens.insertBefore (4, "y");

      declare
         expecting : constant UString := "insert op <InsertBeforeOp@[@4,4:4='c',<3>,1:4]:""y""> within boundaries of previous <ReplaceOp@[@2,2:2='c',<3>,1:2]..[@4,4:4='c',<3>,1:4]:""x"">";
      begin
         Dummy_Text := tokens.getText ();
         UnitTest.Fail ("Expected exception not thrown.");
      exception
         when ANTLRError.illegalArgument =>
            msg;
            UnitTest.Assert_Equal (expecting, msg);
      end if;
   end testReplaceRangeThenInsertAtRightEdge;

   procedure testReplaceRangeThenInsertAfterRightEdge is
      expecting : constant UString := "abxyba";
   begin
      input : constant := ANTLRInputStream ("abcccba");
      lexer : constant := LexerA (input);
      stream : constant Token := CommonTokenStream (lexer);
      stream.fill ();
      tokens : constant := TokenStreamRewriter (stream);
      tokens.replace (2, 4, "x");
      tokens.insertAfter (4, "y");
      result : constant := tokens.getText ();
      UnitTest.Assert_Equal (expecting, result);
   end testReplaceRangeThenInsertAfterRightEdge;

   procedure testReplaceAll is
      expecting : constant UString := "x";
   begin
      input : constant := ANTLRInputStream ("abcccba");
      lexer : constant := LexerA (input);
      stream : constant Token := CommonTokenStream (lexer);
      stream.fill ();
      tokens : constant := TokenStreamRewriter (stream);
      tokens.replace (0, 6, "x");
      result : constant := tokens.getText ();
      UnitTest.Assert_Equal (expecting, result);
   end testReplaceAll;

   procedure testReplaceSubsetThenFetch is
      expecting : constant UString := "abxyzba";
   begin
      input : constant := ANTLRInputStream ("abcccba");
      lexer : constant := LexerA (input);
      stream : constant Token := CommonTokenStream (lexer);
      stream.fill ();
      tokens : constant := TokenStreamRewriter (stream);
      tokens.replace (2, 4, "xyz");
      result : constant := tokens.getText (Interval.of (0, 6));
      UnitTest.Assert_Equal (expecting, result);
   end testReplaceSubsetThenFetch;

   procedure testReplaceThenReplaceSuperset is
   begin
      input : constant := ANTLRInputStream ("abcccba");
      lexer : constant := LexerA (input);
      stream : constant Token := CommonTokenStream (lexer);
      stream.fill ();
      tokens : constant := TokenStreamRewriter (stream);
      tokens.replace (2, 4, "xyz");
      tokens.replace (3, 5, "foo");

      declare
         expecting : constant UString := "replace op boundaries of <ReplaceOp@[@3,3:3='c',<3>,1:3]..[@5,5:5='b',<2>,1:5]:""foo""> overlap with previous <ReplaceOp@[@2,2:2='c',<3>,1:2]..[@4,4:4='c',<3>,1:4]:""xyz"">";
      begin
         Dummy_Text := tokens.getText ();
         UnitTest.Fail ("Expected exception not thrown.");
      exception
         when ANTLRError.illegalArgument =>
            msg;
            UnitTest.Assert_Equal (expecting, msg);
      end if;
   end testReplaceThenReplaceSuperset;

   procedure testReplaceThenReplaceLowerIndexedSuperset is
   begin
      input : constant := ANTLRInputStream ("abcccba");
      lexer : constant := LexerA (input);
      stream : constant Token := CommonTokenStream (lexer);
      stream.fill ();
      tokens : constant := TokenStreamRewriter (stream);
      tokens.replace (2, 4, "xyz");
      tokens.replace (1, 3, "foo");

      declare
         expecting : constant UString := "replace op boundaries of <ReplaceOp@[@1,1:1='b',<2>,1:1]..[@3,3:3='c',<3>,1:3]:""foo""> overlap with previous <ReplaceOp@[@2,2:2='c',<3>,1:2]..[@4,4:4='c',<3>,1:4]:""xyz"">";
      begin
         Dummy_Text := tokens.getText ();
         UnitTest.Fail ("Expected exception not thrown.");
      exception
         when ANTLRError.illegalArgument =>
            (let msg)
         UnitTest.Assert_Equal (expecting, msg);
      end if;
   end testReplaceThenReplaceLowerIndexedSuperset;

   procedure testReplaceSingleMiddleThenOverlappingSuperset is
      expecting : constant UString := "fooa";
   begin
      input : constant := ANTLRInputStream ("abcba");
      lexer : constant := LexerA (input);
      stream : constant Token := CommonTokenStream (lexer);
      stream.fill ();
      tokens : constant := TokenStreamRewriter (stream);
      tokens.replace (2, 2, "xyz");
      tokens.replace (0, 3, "foo");
      result : constant := tokens.getText ();
      UnitTest.Assert_Equal (expecting, result);
   end testReplaceSingleMiddleThenOverlappingSuperset;

   procedure testCombineInserts is
      expecting : constant UString := "yxabc";
   begin
      input : constant := ANTLRInputStream ("abc");
      lexer : constant := LexerA (input);
      stream : constant Token := CommonTokenStream (lexer);
      stream.fill ();
      tokens : constant := TokenStreamRewriter (stream);
      tokens.insertBefore (0, "x");
      tokens.insertBefore (0, "y");
      result : constant := tokens.getText ();
      UnitTest.Assert_Equal (expecting, result);
   end testCombineInserts;

   procedure testCombine3Inserts is
      expecting : constant UString := "yazxbc";
   begin
      input : constant := ANTLRInputStream ("abc");
      lexer : constant := LexerA (input);
      stream : constant Token := CommonTokenStream (lexer);
      stream.fill ();
      tokens : constant := TokenStreamRewriter (stream);
      tokens.insertBefore (1, "x");
      tokens.insertBefore (0, "y");
      tokens.insertBefore (1, "z");
      result : constant := tokens.getText ();
      UnitTest.Assert_Equal (expecting, result);
   end testCombine3Inserts;

   procedure testCombineInsertOnLeftWithReplace is
      expecting : constant UString := "zfoo";
   begin
      input : constant := ANTLRInputStream ("abc");
      lexer : constant := LexerA (input);
      stream : constant Token := CommonTokenStream (lexer);
      stream.fill ();
      tokens : constant := TokenStreamRewriter (stream);
      -- combine with left edge of rewrite
      tokens.replace (0, 2, "foo");
      tokens.insertBefore (0, "z");
      stream.fill ();
      result : constant := tokens.getText ();
      UnitTest.Assert_Equal (expecting, result);
   end testCombineInsertOnLeftWithReplace;

   procedure testCombineInsertOnLeftWithDelete is
      expecting : constant UString := "z";
   begin
      input : constant := ANTLRInputStream ("abc");
      lexer : constant := LexerA (input);
      stream : constant Token := CommonTokenStream (lexer);
      stream.fill ();
      tokens : constant := TokenStreamRewriter (stream);
      -- combine with left edge of rewrite
      tokens.delete (0, 2);
      tokens.insertBefore (0, "z");
      stream.fill ();
      result : constant := tokens.getText ();
      -- make sure combo is not znull
      stream.fill ();
      UnitTest.Assert_Equal (expecting, result);
   end testCombineInsertOnLeftWithDelete;

   procedure testDisjointInserts is
      expecting : constant UString := "zaxbyc";
   begin
      input : constant := ANTLRInputStream ("abc");
      lexer : constant := LexerA (input);
      stream : constant Token := CommonTokenStream (lexer);
      stream.fill ();
      tokens : constant := TokenStreamRewriter (stream);
      tokens.insertBefore (1, "x");
      tokens.insertBefore (2, "y");
      tokens.insertBefore (0, "z");
      stream.fill ();
      result : constant := tokens.getText ();
      UnitTest.Assert_Equal (expecting, result);
   end testDisjointInserts;

   procedure testOverlappingReplace is
      expecting : constant UString := "bar";
   begin
      input : constant := ANTLRInputStream ("abcc");
      lexer : constant := LexerA (input);
      stream : constant Token := CommonTokenStream (lexer);
      stream.fill ();
      tokens : constant := TokenStreamRewriter (stream);
      tokens.replace (1, 2, "foo");
      tokens.replace (0, 3, "bar");
      stream.fill ();
      -- wipes prior nested replace
      result : constant := tokens.getText ();
      UnitTest.Assert_Equal (expecting, result);
   end testOverlappingReplace;

   procedure testOverlappingReplace2 is
   begin
      input : constant := ANTLRInputStream ("abcc");
      lexer : constant := LexerA (input);
      stream : constant Token := CommonTokenStream (lexer);
      stream.fill ();
      tokens : constant := TokenStreamRewriter (stream);
      tokens.replace (0, 3, "bar");
      tokens.replace (1, 2, "foo");
      stream.fill ();
      -- cannot split earlier replace

      declare
         expecting : constant UString := "replace op boundaries of <ReplaceOp@[@1,1:1='b',<2>,1:1]..[@2,2:2='c',<3>,1:2]:""foo""> overlap with previous <ReplaceOp@[@0,0:0='a',<1>,1:0]..[@3,3:3='c',<3>,1:3]:""bar"">";
      begin
         Dummy_Text := tokens.getText ();
         UnitTest.Fail ("Expected exception not thrown.");
      exception
         when ANTLRError.illegalArgument =>
            (let msg)
         UnitTest.Assert_Equal (expecting, msg);
      end if;
   end testOverlappingReplace2;

   procedure testOverlappingReplace3 is
      expecting : constant UString := "barc";
   begin
      input : constant := ANTLRInputStream ("abcc");
      lexer : constant := LexerA (input);
      stream : constant Token := CommonTokenStream (lexer);
      stream.fill ();
      tokens : constant := TokenStreamRewriter (stream);
      tokens.replace (1, 2, "foo");
      tokens.replace (0, 2, "bar");
      stream.fill ();
      -- wipes prior nested replace
      result : constant := tokens.getText ();
      UnitTest.Assert_Equal (expecting, result);
   end testOverlappingReplace3;

   procedure testOverlappingReplace4 is
      expecting : constant UString := "abar";
   begin
      input : constant := ANTLRInputStream ("abcc");
      lexer : constant := LexerA (input);
      stream : constant Token := CommonTokenStream (lexer);
      stream.fill ();
      tokens : constant := TokenStreamRewriter (stream);
      tokens.replace (1, 2, "foo");
      tokens.replace (1, 3, "bar");
      stream.fill ();
      -- wipes prior nested replace
      result : constant := tokens.getText ();
      UnitTest.Assert_Equal (expecting, result);
   end testOverlappingReplace4;

   procedure testDropIdenticalReplace is
      expecting : constant UString := "afooc";
   begin
      input : constant := ANTLRInputStream ("abcc");
      lexer : constant := LexerA (input);
      stream : constant Token := CommonTokenStream (lexer);
      stream.fill ();
      tokens : constant := TokenStreamRewriter (stream);
      tokens.replace (1, 2, "foo");
      tokens.replace (1, 2, "foo");
      stream.fill ();
      -- drop previous, identical
      result : constant := tokens.getText ();
      UnitTest.Assert_Equal (expecting, result);
   end testDropIdenticalReplace;

   procedure testDropPrevCoveredInsert is
      expecting : constant UString := "afoofoo";
   begin
      input : constant := ANTLRInputStream ("abc");
      lexer : constant := LexerA (input);
      stream : constant Token := CommonTokenStream (lexer);
      stream.fill ();
      tokens : constant := TokenStreamRewriter (stream);
      tokens.insertBefore (1, "foo");
      tokens.replace (1, 2, "foo");
      stream.fill ();
      -- kill prev insert
      result : constant := tokens.getText ();
      UnitTest.Assert_Equal (expecting, result);
   end testDropPrevCoveredInsert;

   procedure testLeaveAloneDisjointInsert is
      expecting : constant UString := "axbfoo";
   begin
      input : constant := ANTLRInputStream ("abcc");
      lexer : constant := LexerA (input);
      stream : constant Token := CommonTokenStream (lexer);
      stream.fill ();
      tokens : constant := TokenStreamRewriter (stream);
      tokens.insertBefore (1, "x");
      tokens.replace (2, 3, "foo");
      result : constant := tokens.getText ();
      UnitTest.Assert_Equal (expecting, result);
   end testLeaveAloneDisjointInsert;

   procedure testLeaveAloneDisjointInsert2 is
      expecting : constant UString := "axbfoo";
   begin
      input : constant := ANTLRInputStream ("abcc");
      lexer : constant := LexerA (input);
      stream : constant Token := CommonTokenStream (lexer);
      stream.fill ();
      tokens : constant := TokenStreamRewriter (stream);
      tokens.replace (2, 3, "foo");
      tokens.insertBefore (1, "x");
      result : constant := tokens.getText ();
      UnitTest.Assert_Equal (expecting, result);
   end testLeaveAloneDisjointInsert2;

   procedure testInsertBeforeTokenThenDeleteThatToken is
      expecting : constant UString := "aby";
   begin
      input : constant := ANTLRInputStream ("abc");
      lexer : constant := LexerA (input);
      stream : constant Token := CommonTokenStream (lexer);
      stream.fill ();
      tokens : constant := TokenStreamRewriter (stream);
      tokens.insertBefore (2, "y");
      tokens.delete (2);
      result : constant := tokens.getText ();
      UnitTest.Assert_Equal (expecting, result);
   end testInsertBeforeTokenThenDeleteThatToken;

   procedure testDistinguishBetweenInsertAfterAndInsertBeforeToPreserverOrder is
      expecting : constant UString := "<b>a</b><b>a</b>" -- fails with <b>a<b></b>a</b>";
   begin
      input : constant := ANTLRInputStream ("aa");
      lexer : constant := LexerA (input);
      stream : constant Token := CommonTokenStream (lexer);
      stream.fill ();
      tokens : constant := TokenStreamRewriter (stream);
      tokens.insertBefore (0, "<b>");
      tokens.insertAfter (0, "</b>");
      tokens.insertBefore (1, "<b>");
      tokens.insertAfter (1, "</b>");
      result : constant := tokens.getText ();
      UnitTest.Assert_Equal (expecting, result);
   end testDistinguishBetweenInsertAfterAndInsertBeforeToPreserverOrder;

   procedure testDistinguishBetweenInsertAfterAndInsertBeforeToPreserverOrder2 is
      expecting : constant UString := "<b><p>a</p></b><b>a</b>";
   begin
      input : constant := ANTLRInputStream ("aa");
      lexer : constant := LexerA (input);
      stream : constant Token := CommonTokenStream (lexer);
      stream.fill ();
      tokens : constant := TokenStreamRewriter (stream);
      tokens.insertBefore (0, "<p>");
      tokens.insertBefore (0, "<b>");
      tokens.insertAfter (0, "</p>");
      tokens.insertAfter (0, "</b>");
      tokens.insertBefore (1, "<b>");
      tokens.insertAfter (1, "</b>");
      result : constant := tokens.getText ();
      UnitTest.Assert_Equal (expecting, result);
   end testDistinguishBetweenInsertAfterAndInsertBeforeToPreserverOrder2;

   procedure testPreservesOrderOfContiguousInserts is
      expecting : constant UString := "<div><b><p>a</p></b></div>!b";
   begin
      input : constant := ANTLRInputStream ("ab");
      lexer : constant := LexerA (input);
      stream : constant Token := CommonTokenStream (lexer);
      stream.fill ();
      tokens : constant := TokenStreamRewriter (stream);
      tokens.insertBefore (0, "<p>");
      tokens.insertBefore (0, "<b>");
      tokens.insertBefore (0, "<div>");
      tokens.insertAfter (0, "</p>");
      tokens.insertAfter (0, "</b>");
      tokens.insertAfter (0, "</div>");
      tokens.insertBefore (1, "!");
      result : constant := tokens.getText ();
      UnitTest.Assert_Equal (expecting, result);
   end testPreservesOrderOfContiguousInserts;

end TokenStreamRewriterTests;
