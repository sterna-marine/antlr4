-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
--



-- This interface describes the minimal core of methods triggered
-- by _org.antlr.v4.runtime.tree.ParseTreeWalker_. E.g.,
-- 
-- ParseTreeWalker walker := new ParseTreeWalker ();
-- walker.walk (myParseTreeListener, myParseTree); <-- triggers events in your listener
-- 
-- If you want to trigger events in multiple listeners during a single
-- tree walk, you can use the ParseTreeDispatcher object available at
-- 
-- https:--github.com/antlr/antlr4/issues/841
-- 

-- public
type ParseTreeListener is interface;
    procedure visitTerminal (node : TerminalNode);

    procedure visitErrorNode (node : ErrorNode);

    procedure enterEveryRule (ctx : ParserRuleContext);

    procedure exitEveryRule (ctx : ParserRuleContext);
end if;
