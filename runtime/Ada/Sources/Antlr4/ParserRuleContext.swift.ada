-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
--


-- A rule invocation record for parsing.
--
-- Contains all of the information about the current rule not stored in the
-- RuleContext. It handles parse tree children list, Any ATN state
-- tracing, and the default values available for rule invocations:
-- start, stop, rule index, current alt number.
--
-- Subclasses made for each rule and grammar track the parameters,
-- return values, locals, and labels specific to that rule. These
-- are the objects that are returned from rules.
--
-- Note text is not an actual field of a rule return value; it is computed
-- from start and stop using the input stream's toString() method.  I
-- could add a ctor to this so that we can pass in and store the input
-- stream, but I'm not sure we want to do that.  It would seem to be undefined
-- to get the .text property anyway if the rule matches tokens from multiple
-- input streams.
--
-- I do not use getters for fields of objects that are used simply to
-- group values such as this aggregate.  The getters/setters are there to
-- satisfy the superclass interface.
--
open type ParserRuleContext is new RuleContext with null record;
{
    public static EMPTY : constant := ParserRuleContext()

    public var visited := false

    -- If we are debugging or building a parse tree for a visitor,
    -- we need to track all of the tokens and rule invocations associated
    -- with this rule's context. This is empty for parsing w/o tree constr.
    -- operation because we don't the need to track the details about
    -- how we parse this rule.
    --
    public var children: [ParseTree]?

    -- For debugging/tracing purposes, we want to track all of the nodes in
    -- the ATN traversed by the parser for a particular rule.
    -- This list indicates the sequence of ATN nodes used to match
    -- the elements of the children list. This list does not include
    -- ATN nodes and other rules used to match rule invocations. It
    -- traces the rule invocation node itself but nothing inside that
    -- other rule's ATN submachine.
    --
    -- There is NOT a one-to-one correspondence between the children and
    -- states list. There are typically many nodes in the ATN traversed
    -- for each element in the children list. For example, for a rule
    -- invocation there is the invoking state and the following state.
    --
    -- The parser setState() method updates field s and adds it to this list
    -- if we are debugging/tracing.
    --
    -- This does not trace states visited during prediction.
    --
    public var start: Token?, stop: Token?

    --
    -- The exception that forced this rule to return. If the rule successfully
    -- completed, this is `null`.
    --
    public var exception: RecognitionException?

    public override procedure Init (This : …) is
begin
        super.init()
    end ;

    public init(parent : ParserRuleContext?, invokingStateNumber : Integer) {
        super.init(parent, invokingStateNumber)
    end ;

    -- COPY a ctx (I'm deliberately not using copy constructor) to avoid
    -- confusion with creating node with parent. Does not copy children.
    --
    -- This is used in the generated parser code to flip a generic XContext
    -- node for rule X to a YContext for alt label Y. In that sense, it is
    -- not really a generic copy function.
    --
    -- If we do an error sync() at start of a rule, we might add error nodes
    -- to the generic XContext so this function must copy those nodes to
    -- the YContext as well else they are lost!
    --
    open procedure copyFrom (ctx : ParserRuleContext) {
        self.parent := ctx.parent
        self.invokingState := ctx.invokingState
        self.start := ctx.start
        self.stop := ctx.stop

        -- copy any error nodes to alt label node
        if ctxChildren : constant := ctx.children then
            self.children := [ParseTree]()
            -- reset parent pointer for any error nodes
            for child in ctxChildren loop
                if errNode : constant := child as? ErrorNode then
                    addChild(errNode);
                end if;
            end loop;
        end ;
    end ;

    -- Double dispatch methods for listeners

    open procedure enterRule (listener : ParseTreeListener) {
    end ;

    open procedure exitRule (listener : ParseTreeListener) {
    end ;

    -- Add a parse tree node to this as a child.  Works for
    -- internal and leaf nodes. Does not set parent link;
    -- other add methods must do that. Other addChild methods
    -- call this.
    --
    -- We cannot set the parent pointer of the incoming node
    -- because the existing interfaces do not have a setParent()
    -- method and I don't want to break backward compatibility for this.
    --
    -- - Since: 4.7
    --
    open procedure addAnyChild (t : ParseTree) {
        if children == null then
            children := [ParseTree]();
        end if;
        children!.append(t)
    end ;

    open procedure addChild (ruleInvocation : RuleContext) {
        addAnyChild(ruleInvocation)
    end ;

    -- Add a token leaf node child and force its parent to be this node.
    open procedure addChild (t : TerminalNode) {
        t.setParent(self)
        addAnyChild(t)
    end ;

    -- Add an error node child and force its parent to be this node.
    open procedure addErrorNode (errorNode : ErrorNode) {
        errorNode.setParent(self)
        addAnyChild(errorNode)
    end ;


    -- Used by enterOuterAlt to toss out a RuleContext previously added as
    -- we entered a rule. If we have # label, we will need to remove
    -- generic ruleContext object.
    --
    open procedure removeLastChild (This : …) is
begin
        children?.removeLast()
    end ;


    override
    open function getChild (i : Integer) return Tree? {
        guard children : constant := children, i >= 0 and then i < children.count else {
            return null;
        end ;
        return children[i]
    end ;

    open function getChild<T: ParseTree> (ctxType : T.Type, i : Integer) return T? is
begin
        guard children : constant := children, i >= 0 and then i < children.count else {
            return null;
        end ;
        var j := -1 -- what element have we found with ctxType?
        for o in children loop
            if o : constant := o as? T then
                j := @ + 1;
                if j == i then
                    return o;
                end if;
            end ;
        end loop;

        return null;
    end ;

    open function getToken (ttype : Integer; i : Integer) return TerminalNode? {
        guard children : constant := children, i >= 0 and then i < children.count else {
            return null;
        end ;
        var j := -1 -- what token with ttype have we found?
        for o in children loop
            if tnode : constant := o as? TerminalNode then
                symbol : constant := tnode.getSymbol()!
                if symbol.getType() == ttype then
                    j := @ + 1;
                    if j == i then
                        return tnode;
                    end if;
                end ;
            end ;
        end loop;

        return null;
    end ;

    open function getTokens (ttype : Integer) return [TerminalNode] {
        guard children : constant := children else {
            return [TerminalNode]()
        end ;

        return children.compactMap {
            if tnode : constant := $0 as? TerminalNode, symbol : constant := tnode.getSymbol(), symbol.getType() == ttype then
                return tnode
            else
                return null;
            end if;
        end ;
    end ;

    open function getRuleContext<T: ParserRuleContext> (ctxType : T.Type, i : Integer) return T? is
begin
        return getChild(ctxType, i: i)
    end ;

    open function getRuleContexts<T: ParserRuleContext> (ctxType : T.Type) return [T] is
begin
        guard children : constant := children else {
            return [T]()
        end ;
        return children.compactMap { $0 as? T end ;
    end ;

    override
    open function getChildCount (This : …) return Integer is
begin
        return children?.count ?? 0
    end ;

    override
    open subscript(index : Integer) return ParseTree is
begin
        return children![index]
    end ;

    override
    open function getSourceInterval (This : …) return Interval is
begin
        guard start : constant := start, stop : constant := stop else {
             return Interval.INVALID
        end ;
        return Interval.of(start.getTokenIndex(), stop.getTokenIndex())
    end ;

    --
    -- Get the initial token in this context.
    -- Note that the range from start to stop is inclusive, so for rules that do not consume anything
    -- (for example, zero length or error productions) this token may exceed stop.
    --
    open function getStart () return Token? {
        return start
    end ;
    --
    -- Get the final token in this context.
    -- Note that the range from start to stop is inclusive, so for rules that do not consume anything
    -- (for example, zero length or error productions) this token may precede start.
    --
    open function getStop () return Token? {
        return stop
    end ;

    -- Used for rule context info debugging during parse-time, not so much for ATN debugging
    open function toInfoString (recognizer : Parser) return String is
begin
        rules : constant := Array(recognizer.getRuleInvocationStack(self).reversed())
        startStr : constant := start?.description ?? "<unknown>"
        stopStr : constant := stop?.description ?? "<unknown>"
        return "ParserRuleContext\(rules){start=\(startStr)), stop=\(stopStr)end ;"
    end ;
end ;
