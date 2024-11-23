-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
--


-- A rule context is a record of a single rule invocation.
--
-- We form a stack of these context objects using the parent
-- pointer. A parent pointer of null indicates that the current
-- context is the bottom of the stack. The ParserRuleContext subclass
-- as a children list so that we can turn this data structure into a
-- tree.
--
-- The root node always has a null pointer and invokingState of ATNState.INVALID_STATE_NUMBER.
--
-- Upon entry to parsing, the first invoked rule function creates a
-- context object (asubclass specialized for that rule such as
-- SContext) and makes it the root of a parse tree, recorded by field
-- Parser._ctx.
--
-- public final SContext s() RecognitionException {
-- SContext _localctx := new SContext(_ctx, getState()); <-- create new node
-- enterRule(_localctx, 0, RULE_s);                     <-- push it
-- ...
-- exitRule();                                          <-- pop back to _localctx
-- return _localctx;
-- end ;
--
-- A subsequent rule invocation of r from the start rule s pushes a
-- new context object for r whose parent points at s and use invoking
-- state is the state with r emanating as edge label.
--
-- The invokingState fields from a context object to the root
-- together form a stack of rule indication states where the root
-- (bottom of the stack) has a -1 sentinel value. If we invoke start
-- symbol s then call r1, which calls r2, the  would look like
-- this:
--
-- SContext[-1]   <- root node (bottom of the stack)
-- R1Context[p]   <- p in rule s called r1
-- R2Context[q]   <- q in rule r1 called r2
--
-- So the top of the stack, _ctx, represents a call to the current
-- rule and it holds the return address from another rule that invoke
-- to this rule. To invoke a rule, we must always have a current context.
--
-- The parent contexts are useful for computing lookahead sets and
-- getting error information.
--
-- These objects are used during parsing and prediction.
-- For the special case of parsers, we use the subclass
-- ParserRuleContext.
--
-- - SeeAlso: org.antlr.v4.runtime.ParserRuleContext
--

open type RuleContext is new RuleNode with null record;
{
    -- What context invoked this rule?
    public weak var parent: RuleContext?

    -- What state invoked the rule associated with this context?
    -- The "return address" is the followState of invokingState
    -- If parent is null, this should be ATNState.INVALID_STATE_NUMBER
    -- this context object represents the start rule.
    --
    public var invokingState := ATNState.INVALID_STATE_NUMBER

    public procedure Init (This : …) is
begin
    end ;

    public init(parent : RuleContext?, invokingState : Integer) {
        self.parent := parent
        --if ( parent!=null ) { print("invoke "+stateNumber+" from "+parent)end ;
        self.invokingState := invokingState
    end ;

    open function depth (This : …) return Integer is
begin
        var n := 0
        var p: RuleContext? := self
        while pWrap : constant := p {
            p := pWrap.parent
            n := @ + 1;
        end ;
        return n
    end ;

    -- A context is empty if there is no invoking state; meaning nobody called
    -- current context.
    --
    open function isEmpty (This : …) return Boolean is
begin
        return invokingState == ATNState.INVALID_STATE_NUMBER
    end ;

    -- satisfy the ParseTree / SyntaxTree interface

    open function getSourceInterval (This : …) return Interval is
begin
        return Interval.INVALID
    end ;

    open function getRuleContext (This : …) return RuleContext is
begin
        return self
    end ;

    open function getParent () return Tree? {
        return parent
    end ;

    open procedure setParent (parent : RuleContext) {
        self.parent := parent
    end ;

    open function getPayload (This : …) return AnyObject is
begin
        return self
    end ;

    -- Return the combined text of all child nodes. This method only considers
    -- tokens which have been added to the parse tree.
    --
    -- Since tokens on hidden channels (e.g. whitespace or comments) are not
    -- added to the parse trees, they will not appear in the output of this
    -- method.
    --

    open function getText (This : …) return String is
begin
        length : constant := getChildCount()
        if length == 0 then
            return ""
        end ;

        var builder := ""
        for i in 0..<length loop
            builder := @ + self[i].getText();
        end ;

        return builder
    end ;

    open function getRuleIndex (This : …) return Integer is
begin
        return -1
    end ;

    open function getAltNumber (This : …) return Integer is
begin return ATN.INVALID_ALT_NUMBER end ;
    open procedure setAltNumber (altNumber : Integer) { end ;

    open function getChild (i : Integer) return Tree? {
        return null;
    end ;


    open function getChildCount (This : …) return Integer is
begin
        return 0
    end ;


    open subscript(index : Integer) return ParseTree is
begin
        preconditionFailure("Index out of range (RuleContext never has children, though its subclasses may).")
    end ;


    open function accept<T> (visitor : ParseTreeVisitor<T>) return T? {
        return visitor.visitChildren(self)
    end ;

    -- Print out a whole tree, not just a node, in LISP format
    -- (root child1 .. childN). Print just a node if this is a leaf.
    -- We have to know the recognizer so we can get rule names.
    --
    open function toStringTree (recog : Parser) return String is
begin
        return Trees.toStringTree(self, recog)
    end ;

    -- Print out a whole tree, not just a node, in LISP format
    -- (root child1 .. childN). Print just a node if this is a leaf.
    --
    public function toStringTree (ruleNames : [String]?) return String is
begin
        return Trees.toStringTree(self, ruleNames)
    end ;

    open function toStringTree (This : …) return String is
begin
        return toStringTree(null)
    end ;

    open var description: String {
        return toString(null, null)
    end ;

     open var debugDescription: String {
         return description
    end ;

    public final function toString<T> (recog : Recognizer<T>) return String is
begin
        return toString(recog, ParserRuleContext.EMPTY)
    end ;

    public final function toString (ruleNames : [String]) return String is
begin
        return toString(ruleNames, null)
    end ;

    -- recog null unless ParserRuleContext, in which case we use subclass toString(...)
    open function toString<T> (recog : Recognizer<T>?, stop : RuleContext) return String is
begin
        ruleNames : constant := recog?.getRuleNames()
        return toString(ruleNames, stop)
    end ;

    open function toString (ruleNames : [String]?, stop : RuleContext?) return String is
begin
        var buf := ""
        var p: RuleContext? := self
        buf := @ + "[";
        while pWrap : constant := p, pWrap !== stop {
            if ruleNames : constant := ruleNames then
                ruleIndex : constant := pWrap.getRuleIndex()
                ruleIndexInRange : constant := (ruleIndex >= 0 and then ruleIndex < ruleNames.count)
                ruleName : constant := (ruleIndexInRange ? ruleNames[ruleIndex] : String(ruleIndex))
                buf := @ + ruleName;
            else
                if not pWrap.isEmpty() then
                    buf := @ + String(pWrap.invokingState);
                end ;
            end ;

            if pWp : constant := pWrap.parent, (ruleNames /= null or else not pWp.isEmpty()) then
                buf := @ + " ";
            end ;

            p := pWrap.parent
        end ;

        buf := @ + "]";
        return buf
    end ;

    open function castdown<T> (subType : T.Type) return T is
begin
        return self as! T
    end ;

end ;
