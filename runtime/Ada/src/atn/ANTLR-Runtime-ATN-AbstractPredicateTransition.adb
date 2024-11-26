-- 
-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
-- 



-- 
-- 
-- -  Sam Harwell
-- 

package body ANTLR.Runtime.ATN.AbstractPredicateTransition is

    procedure Init (Self : in out AbstractPredicateTransition; target : ATNState) is
        Transition.init(Self, target);
    end ;

end ANTLR.Runtime.ATN.AbstractPredicateTransition;
