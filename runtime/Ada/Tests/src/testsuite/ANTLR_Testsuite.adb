-- €

with VisitorTests;
with TokenStreamTests;
with TokenStreamRewriterTests;

package body ANTLR_Testsuite is

   function Get_Test_Suite return UnitTest.Test_Suite is

      S : UnitTest.Test_Suite := UnitTest.Create_Suite ("Visitor Tests");

      Visitor_Tests             : VisitorTests.Test;
      TokenStream_Tests         : TokenStreamTests.Test;
      TokenStreamRewriter_Tests : TokenStreamRewriterTests.Test;

   begin
      UnitTest.Add_Static_Test (S, Visitor_Tests);
      UnitTest.Add_Static_Test (S, TokenStream_Tests);
      UnitTest.Add_Static_Test (S, TokenStreamRewriter_Tests);

      return S;

   end Get_Test_Suite;
end ANTLR_Testsuite;
