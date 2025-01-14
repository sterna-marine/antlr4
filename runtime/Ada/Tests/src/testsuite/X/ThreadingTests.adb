-- Copyright (c) 2012-2021 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.

with Ada.Wide_Wide_Text_IO;
with ANTLR.Runtime.InputStreams;
with ANTLR.Runtime.Parsers;

use Ada;

package body ThreadingTests is

   -- static
   allTests : constant array (Positive) of UString := ("testParallelExecution", testParallelExecution);

   --
   -- This test verifies parallel execution of the parser
   --
   procedure testParallelExecution is
      input : constant array (Positive) of Integer := [
         "2 * 8 - 4",
         "2 + 8 / 4",
         "2 - 8 - 4",
         "2 * 8 * 4",
         "2 / 8 / 4",
         "2 + 8 + 4",
         "890"];
      exp : constant Ustring := expectation (description : "Waiting on async-task");

      procedure waitForExpectations (timeout : Duration := 30.0) is
      begin
         Wide_Wide_Text_IO.Put_Line ("Completed");
      end waitForExpectations;

   begin
      exp.expectedFulfillmentCount := 100;
      for i in 1 .. 100 loop
         DispatchQueue : 
            declare
               DispatchQueue.global ().async;
               Dummy_parser : Parser;
               lexer : constant := ThreadingLexer (ANTLRInputStream (input[i % 7]));
               tokenStream : constant Token := CommonTokenStream (lexer);
               parser : constant := ThreadingParser (tokenStream); -- try?
            begin

               Dummy_parser := parser?.s (); -- try?
               exp.fulfill ();
            end DispatchQueue;
      end loop;

      waitForExpectations (timeout => 30.0);
   end testParallelExecution;

end ThreadingTests;
