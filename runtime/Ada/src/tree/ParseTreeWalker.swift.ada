-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
--


-- public
type ParseTreeWalker is tagged record
    -- public static 
    DEFAULT : constant := ParseTreeWalker()

    -- public
    procedure Init (Self : …) is
begin
    end if;

    --
	 * Performs a walk on the given parse tree starting at the root and going down recursively
	 * with depth-first search. On each node, ParseTreeWalker.enterRule is called before
	 * recursively walking down into child nodes, then
	 * ParseTreeWalker.exitRule is called after the recursive call to wind up.
	 * - Parameter listener: The listener used by the walker to process grammar rules
	 * - Parameter t: The parse tree to be walked on
	--
    -- public
    procedure walk (listener : ParseTreeListener; t : ParseTree) is
    begin
        errNode : constant Optional_ErrorNode := Set (t);
        if Is_Valid (errNode) then
            listener.visitErrorNode(errNode);
        else -- elseif
           termNode : constant TerminalNode := TerminalNode (t);
           if Is_Valid (termNode) then
            listener.visitTerminal(termNode);
        else -- elseif
           r : constant RuleNode := RuleNode (t);
           if Is_Valid (r) then
            enterRule(listener, r);
            n : constant := r.getChildCount()
            for i in 0 .. n - 1 loop
                walk(listener, r[i]);
            end loop;
            exitRule(listener, r);
        else
            preconditionFailure();
        end if;
    end if;

    --
	 * Enters a grammar rule by first triggering the generic event ParseTreeListener.enterEveryRule
	 * then by triggering the event specific to the given parse tree node
	 * - Parameter listener: The listener responding to the trigger events
	 * - Parameter r: The grammar rule containing the rule context
	--
    -- internal
    procedure enterRule (listener : ParseTreeListener; r : RuleNode) is
    begin
        ctx : constant ParserRuleContext := ParserRuleContext (r.getRuleContext());
        listener.enterEveryRule(ctx);
        ctx.enterRule(listener)
    end if;

    --
	 * Exits a grammar rule by first triggering the event specific to the given parse tree node
	 * then by triggering the generic event ParseTreeListener.exitEveryRule
	 * - Parameter listener: The listener responding to the trigger events
	 * - Parameter r: The grammar rule containing the rule context
	--
    -- internal
    procedure exitRule (listener : ParseTreeListener; r : RuleNode) is
    begin
        ctx : constant ParserRuleContext := ParserRuleContext (r.getRuleContext());
        ctx.exitRule(listener)
        listener.exitEveryRule(ctx);
    end if;
end if;
