-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.

-- 
-- -  Sam Harwell
-- 

package ATNType is 

-- Represents the type of recognizer an ATN applies to.

   type ATNType is (lexer, parser);
   for ATNType use (
      lexer  => 0,   -- A lexer grammar.
      parser => 1);  -- A parser grammar.
   for ATNType'Size use Integer'Size;

end ATNType;
