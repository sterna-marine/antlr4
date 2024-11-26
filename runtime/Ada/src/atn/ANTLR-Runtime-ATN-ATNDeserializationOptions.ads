-- 
-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
-- 

package ANTLR.Runtime.ATNDeserializationOptions is

   -- public struct 
   type ATNDeserializationOptions is record
      verifyATN : Boolean := True;
      generateRuleBypassTransitions : Boolean := False;
   end record;

end ANTLR.Runtime.ATNDeserializationOptions;
