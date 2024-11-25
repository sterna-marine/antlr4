-- 
-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
-- 

--
--  ANTLRError.swift
--  antlr.swift
--
--  Created by janyou on 15/9/4.
--

package ANTLRError is

-- public 
   ANTLRError : exception; -- : Error { … }
   unsupportedOperation : exception; -- (msg:String)
   indexOutOfBounds : exception;, -- (msg:String)
   illegalState : exception; -- (msg:String)
   illegalArgument : exception; -- (msg:String)
   negativeArraySize : exception; -- (msg:String)

end ANTLRError;