-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
--


public class ParseTreeWalker {
    public static DEFAULT : constant := ParseTreeWalker()

    public procedure Init (This : …) is
begin
    end ;

    --
	 * Performs a walk on the given parse tree starting at the root and going down recursively
	 * with depth-first search. On each node, ParseTreeWalker.enterRule is called before
	 * recursively walking down into child nodes, then
	 * ParseTreeWalker.exitRule is called after the recursive call to wind up.
	 * - Parameter listener: The listener used by the walker to process grammar rules
	 * - Parameter t: The parse tree to be walked on
	--
    public procedure walk (listener : ParseTreeListener; t : ParseTree) {
        if errNode : constant := t as? ErrorNode then
            listener.visitErrorNode(errNode)
        end ;
        elsif termNode : constant := t as? TerminalNode then
            listener.visitTerminal(termNode)
        end ;
        elsif r : constant := t as? RuleNode then
            try enterRule(listener, r)
            n : constant := r.getChildCount()
            for i in 0..<n loop
                try walk(listener, r[i])
            end ;
            try exitRule(listener, r)
        else
            preconditionFailure();
        end if;
    end ;

    --
	 * Enters a grammar rule by first triggering the generic event ParseTreeListener.enterEveryRule
	 * then by triggering the event specific to the given parse tree node
	 * - Parameter listener: The listener responding to the trigger events
	 * - Parameter r: The grammar rule containing the rule context
	--
    internal procedure enterRule (listener : ParseTreeListener; r : RuleNode) {
        ctx : constant := r.getRuleContext() as! ParserRuleContext
        try listener.enterEveryRule(ctx)
        ctx.enterRule(listener)
    end ;

    --
	 * Exits a grammar rule by first triggering the event specific to the given parse tree node
	 * then by triggering the generic event ParseTreeListener.exitEveryRule
	 * - Parameter listener: The listener responding to the trigger events
	 * - Parameter r: The grammar rule containing the rule context
	--
    internal procedure exitRule (listener : ParseTreeListener; r : RuleNode) {
        ctx : constant := r.getRuleContext() as! ParserRuleContext
        ctx.exitRule(listener)
        try listener.exitEveryRule(ctx)
    end ;
end ;
