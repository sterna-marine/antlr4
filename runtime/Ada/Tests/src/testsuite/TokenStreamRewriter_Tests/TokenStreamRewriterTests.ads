-- €

with AdaForge.DevTools.TestTools.UnitTest;
use AdaForge.DevTools.TestTools;

package TokenStreamRewriterTests is

   type Test is new UnitTest.Test_Case with null record;

   overriding
   procedure Initialize (T : in out Test);

private
   procedure testInsertBeforeIndex0;
   procedure testInsertAfterLastIndex;
   procedure test2InsertBeforeAfterMiddleIndex;
   procedure testReplaceIndex0;
   procedure testReplaceLastIndex;
   procedure testReplaceMiddleIndex;
   procedure testToStringStartStop;
   procedure testToStringStartStop2;
   procedure test2ReplaceMiddleIndex;
   procedure test2ReplaceMiddleIndex1InsertBefore;
   procedure testReplaceThenDeleteMiddleIndex;
   procedure testInsertInPriorReplace;
   procedure testInsertThenReplaceSameIndex;
   procedure test2InsertMiddleIndex;
   procedure test2InsertThenReplaceIndex0;
   procedure testReplaceThenInsertBeforeLastIndex;
   procedure testInsertThenReplaceLastIndex;
   procedure testReplaceThenInsertAfterLastIndex;
   procedure testReplaceThenInsertAtLeftEdge;
   procedure testReplaceRangeThenInsertAtRightEdge;
   procedure testReplaceRangeThenInsertAfterRightEdge;
   procedure testReplaceAll;
   procedure testReplaceSubsetThenFetch;
   procedure testReplaceThenReplaceSuperset;
   procedure testReplaceThenReplaceLowerIndexedSuperset;
   procedure testReplaceSingleMiddleThenOverlappingSuperset;
   procedure testCombineInserts;
   procedure testCombine3Inserts;
   procedure testCombineInsertOnLeftWithReplace;
   procedure testCombineInsertOnLeftWithDelete;
   procedure testDisjointInserts;
   procedure testOverlappingReplace;
   procedure testOverlappingReplace2;
   procedure testOverlappingReplace3;
   procedure testOverlappingReplace4;
   procedure testDropIdenticalReplace;
   procedure testDropPrevCoveredInsert;
   procedure testLeaveAloneDisjointInsert;
   procedure testLeaveAloneDisjointInsert2;
   procedure testInsertBeforeTokenThenDeleteThatToken;
   procedure testDistinguishBetweenInsertAfterAndInsertBeforeToPreserverOrder;
   procedure testDistinguishBetweenInsertAfterAndInsertBeforeToPreserverOrder2;
   procedure testPreservesOrderOfContiguousInserts;

end TokenStreamRewriterTests;