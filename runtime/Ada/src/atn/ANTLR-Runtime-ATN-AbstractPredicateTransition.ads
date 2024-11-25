-- 
-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
-- 


with ANTLR.Runtime.ATN.Transition;
with ANTLR.Runtime.ATN.ATNState;
use ANTLR.Runtime.ATN;

package ANTLR.Runtime.ATN.AbstractPredicateTransition is

   -- public
   type AbstractPredicateTransition is new Transition with null record;

   --public override 
   procedure Init (Self : in out AbstractPredicateTransition; target : ATNState);

end ANTLR.Runtime.ATN.AbstractPredicateTransition;
