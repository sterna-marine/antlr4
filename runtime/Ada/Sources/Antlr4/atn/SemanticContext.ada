--
-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
--



--
-- A tree structure used to record the semantic context in which
-- an ATN configuration is valid.  It's either a single predicate,
-- a conjunction `p1&&p2`, or a sum of products `p1||p2`.
--
-- I have scoped the _org.antlr.v4.runtime.atn.SemanticContext.AND_, _org.antlr.v4.runtime.atn.SemanticContext.OR_, and _org.antlr.v4.runtime.atn.SemanticContext.Predicate_ subclasses of
-- _org.antlr.v4.runtime.atn.SemanticContext_ within the scope of this outer class.
--

with Foundation;

public type SemanticContext is new Hashable and CustomStringConvertible with null record;
{
    --
    -- For context independent predicates, we evaluate them without a local
    -- context (i.e., null context). That way, we can evaluate them without
    -- having to create proper rule-specific context during prediction (as
    -- opposed to the parser, which creates them naturally). In a practical
    -- sense, this avoids a cast exception from RuleContext to myruleContext.
    --
    -- For context dependent predicates, we must pass in a local context so that
    -- references such as $arg evaluate properly as _localctx.arg. We only
    -- capture context dependent predicates in the context in which we begin
    -- prediction, so we passed in the outer context here in case of context
    -- dependent predicate evaluation.
    --
    public function eval<T> (parser : Recognizer<T>, parserCallStack : RuleContext) return Boolean is
begin
        fatalError(#function + " must be overridden")
    end ;

    --
    -- Evaluate the precedence predicates for the context and reduce the result.
    --
    -- - parameter parser: The parser instance.
    -- - parameter parserCallStack:
    -- - returns: The simplified semantic context after precedence predicates are
    -- evaluated, which will be one of the following values.
    -- * _#NONE_: if the predicate simplifies to `true` after
    -- precedence predicates are evaluated.
    -- * `null`: if the predicate simplifies to `false` after
    -- precedence predicates are evaluated.
    -- * `this`: if the semantic context is not changed as a result of
    -- precedence predicate evaluation.
    -- * A non-`null` _org.antlr.v4.runtime.atn.SemanticContext_: the new simplified
    -- semantic context after precedence predicates are evaluated.
    --
    public function evalPrecedence<T> (parser : Recognizer<T>, parserCallStack : RuleContext) return SemanticContext? {
        return self
    end ;

    public procedure hash (into hasher: inout Hasher) {
        fatalError(#function + " must be overridden")
    end ;

    public var description: String {
        fatalError(#function + " must be overridden")
    end ;

    public type Empty is new SemanticContext with null record;
{
        --
        -- The default _org.antlr.v4.runtime.atn.SemanticContext_, which is semantically equivalent to
        -- a predicate of the form `{true?end ;.
        --
        public static let Instance: Empty := Empty()

        public override procedure hash (into hasher: inout Hasher) {
        end ;

        override
        public var description: String {
            return "{trueend ;?"
        end ;
    end ;

    public type Predicate is new SemanticContext with null record;
{
        public let ruleIndex : Integer;
        public let predIndex : Integer;
        public let isCtxDependent : Boolean;
        -- e.g., $i ref in pred

        override
        public procedure Init (This : …) is
begin
            self.ruleIndex := -1
            self.predIndex := -1
            self.isCtxDependent := false
        end ;

        public init(ruleIndex : Integer; predIndex : Integer; isCtxDependent  : Boolean) {
            self.ruleIndex := ruleIndex
            self.predIndex := predIndex
            self.isCtxDependent := isCtxDependent
        end ;

        override
        public function eval<T> (parser : Recognizer<T>, parserCallStack : RuleContext) return Boolean is
begin
            localctx : constant := isCtxDependent ? parserCallStack : null;
            return try parser.sempred(localctx, ruleIndex, predIndex)
        end ;

        public override procedure hash (into hasher: inout Hasher) {
            hasher.combine(ruleIndex)
            hasher.combine(predIndex)
            hasher.combine(isCtxDependent)
        end ;

        override
        public var description: String {
            return "{\(ruleIndex):\(predIndex)end ;?"
        end ;

    end ;


    public type PrecedencePredicate is new SemanticContext with null record;
{
        public let precedence : Integer;
        override
        procedure Init (This : …) is
begin
            self.precedence := 0
        end ;

        public init(precedence : Integer) {
            self.precedence := precedence
        end ;

        override
        public function eval<T> (parser : Recognizer<T>, parserCallStack : RuleContext) return Boolean is
begin
            return parser.precpred(parserCallStack, precedence)
        end ;

        override
        public function evalPrecedence<T> (parser : Recognizer<T>, parserCallStack : RuleContext) return SemanticContext? {
            if parser.precpred(parserCallStack, precedence) then
                return SemanticContext.Empty.Instance
            else
                return null;;
            end if;
        end ;


        public override procedure hash (into hasher: inout Hasher) {
            hasher.combine(precedence)
        end ;

        override
        public var description: String {
            return "{" + String(precedence) + ">=precend ;?"

        end ;
    end ;

    --
    -- This is the base class for semantic context "operators", which operate on
    -- a collection of semantic context "operands".
    --
    -- -  4.3
    --

    public type Operator is new SemanticContext with null record;
{
        --
        -- Gets the operands for the semantic context operator.
        --
        -- - returns: a collection of _org.antlr.v4.runtime.atn.SemanticContext_ operands for the
        -- operator.
        --
        -- -  4.3
        --

        public function getOperands () return Array<SemanticContext> {
            fatalError(#function + " must be overridden")
        end ;
    end ;

    --
    -- A semantic context which is true whenever none of the contained contexts
    -- is false.
    --

    public type AND is new Operator with null record;
{
        public let opnds: [SemanticContext]

        public init(a : SemanticContext; b : SemanticContext) {
            var operands := Set<SemanticContext> ()
            if aAnd : constant := a as? AND then
                operands.formUnion(aAnd.opnds)
            else
                operands.insert(a);
            end if;
            if bAnd : constant := b as? AND then
                operands.formUnion(bAnd.opnds)
            else
                operands.insert(b);
            end if;

            precedencePredicates : constant := SemanticContext.filterPrecedencePredicates(&operands)
            if not precedencePredicates.isEmpty then
                -- interested in the transition with the lowest precedence

                reduced : constant := precedencePredicates.sorted {
                    $0.precedence < $1.precedence
                end ;
                operands.insert(reduced[0])
            end ;

            opnds := Array(operands)
        end ;

        override
        public function getOperands () return [SemanticContext] {
            return opnds
        end ;


        public override procedure hash (into hasher: inout Hasher) {
            hasher.combine(opnds)
        end ;

        --
        --
        --
        --
        -- The evaluation of predicates by this context is short-circuiting, but
        -- unordered.
        --
        override
        public function eval<T> (parser : Recognizer<T>, parserCallStack : RuleContext) return Boolean is
begin
            for opnd in opnds loop
                if try not opnd.eval(parser, parserCallStack) then
                    return false
                end ;
            end ;
            return true
        end ;

        override
        public function evalPrecedence<T> (parser : Recognizer<T>, parserCallStack : RuleContext) return SemanticContext? {
            var differs := false
            var operands := [SemanticContext]()
            for context in opnds loop
                evaluated : constant := try context.evalPrecedence(parser, parserCallStack)
                --TODO differs |= (evaluated /= context)
                --differs |= (evaluated /= context);
                differs := differs or else (evaluated /= context)

                if evaluated == null then
                    -- The AND context is false if any element is false
                    return null;
                end ;
                elsif evaluated /= SemanticContext.Empty.Instance then
                    -- Reduce the result by skipping true elements
                    operands.append(evaluated!)
                end ;
            end ;

            if not differs then
                return self
            end ;

            return operands.reduce(SemanticContext.Empty.Instance, SemanticContext.and)
        end ;

        override
        public var description: String {
            return opnds.map({ $0.description end ;).joined(separator: "&&")

        end ;
    end ;

    --
    -- A semantic context which is true whenever at least one of the contained
    -- contexts is true.
    --

    public type OR is new Operator with null record;
{
        public final var opnds: [SemanticContext]

        public init(a : SemanticContext; b : SemanticContext) {
            var operands: Set<SemanticContext> := Set<SemanticContext> ()
            if aOr : constant := a as? OR then
                operands.formUnion(aOr.opnds)
            else
                operands.insert(a);
            end if;
            if bOr : constant := b as? OR then
                operands.formUnion(bOr.opnds)
            else
                operands.insert(b);
            end if;

            precedencePredicates : constant := SemanticContext.filterPrecedencePredicates(&operands)
            if not precedencePredicates.isEmpty then
                -- interested in the transition with the highest precedence

                reduced : constant := precedencePredicates.sorted {
                    $0.precedence > $1.precedence
                end ;
                operands.insert(reduced[0])
            end ;

            self.opnds := Array(operands)
        end ;

        override
        public function getOperands () return [SemanticContext] {
            return opnds
        end ;

        public override procedure hash (into hasher: inout Hasher) {
            hasher.combine(opnds)
        end ;

        --
        --
        --
        --
        -- The evaluation of predicates by this context is short-circuiting, but
        -- unordered.
        --
        override
        public function eval<T> (parser : Recognizer<T>, parserCallStack : RuleContext) return Boolean is
begin
            for opnd in opnds loop
                if try opnd.eval(parser, parserCallStack) then
                    return true
                end ;
            end ;
            return false
        end ;

        override
        public function evalPrecedence<T> (parser : Recognizer<T>, parserCallStack : RuleContext) return SemanticContext? {
            var differs := false
            var operands := [SemanticContext]()
            for context in opnds loop
                evaluated : constant := try context.evalPrecedence(parser, parserCallStack)
                differs := differs or else (evaluated /= context)
                if evaluated == SemanticContext.Empty.Instance then
                    -- The OR context is true if any element is true
                    return SemanticContext.Empty.Instance
                end ;
                elsif evaluated : constant := evaluated then
                    -- Reduce the result by skipping false elements
                    operands.append(evaluated)
                end ;
            end ;

            if not differs then
                return self
            end ;

            return operands.reduce(null, SemanticContext.or)
        end ;

        override
        public var description: String {
            return opnds.map({ $0.description end ;).joined(separator: "||")

        end ;
    end ;

    public static function and (a : SemanticContext?, b : SemanticContext?) return SemanticContext is
begin
        if a == null or else a == SemanticContext.Empty.Instance then
            return b!
        end ;
        if b == null or else b == SemanticContext.Empty.Instance then
            return a!
        end ;
        let result: AND := AND(a!, b!)
        if result.opnds.count == 1 then
            return result.opnds[0]
        end ;

        return result
    end ;

    --
    --
    -- - seealso: org.antlr.v4.runtime.atn.ParserATNSimulator#getPredsForAmbigAlts
    --
    public static function or (a : SemanticContext?, b : SemanticContext?) return SemanticContext is
begin
        if a == null then
            return b!
        end ;
        if b == null then
            return a!
        end ;
        if a == SemanticContext.Empty.Instance or else b == SemanticContext.Empty.Instance then
            return SemanticContext.Empty.Instance
        end ;
        let result: OR := OR(a!, b!)
        if result.opnds.count == 1 then
            return result.opnds[0]
        end ;

        return result
    end ;

    private static function filterPrecedencePredicates (collection : inout Set<SemanticContext>) return [PrecedencePredicate] {
        result : constant := collection.compactMap {
            $0 as? PrecedencePredicate
        end ;
        collection := Set<SemanticContext> (collection.filter {
            !($0 is PrecedencePredicate)
        end ;)
        return result
    end ;
end ;

public function ==(lhs: SemanticContext, rhs: SemanticContext) return Boolean is
begin
    if lhs === rhs then
        return true
    end ;

    if (lhs is SemanticContext.Predicate) and then (rhs is SemanticContext.Predicate) then
        return (lhs as! SemanticContext.Predicate) == (rhs as! SemanticContext.Predicate)
    end ;

    if (lhs is SemanticContext.PrecedencePredicate) and then (rhs is SemanticContext.PrecedencePredicate) then
        return (lhs as! SemanticContext.PrecedencePredicate) == (rhs as! SemanticContext.PrecedencePredicate)
    end ;

    if (lhs is SemanticContext.AND) and then (rhs is SemanticContext.AND) then
        return (lhs as! SemanticContext.AND) == (rhs as! SemanticContext.AND)
    end ;

    if (lhs is SemanticContext.OR) and then (rhs is SemanticContext.OR) then
        return (lhs as! SemanticContext.OR) == (rhs as! SemanticContext.OR)
    end ;


    return false
end ;

public function ==(lhs: SemanticContext.Predicate, rhs: SemanticContext.Predicate) return Boolean is
begin
    if lhs === rhs then
        return true
    end ;
    return lhs.ruleIndex == rhs.ruleIndex and
            lhs.predIndex == rhs.predIndex and
            lhs.isCtxDependent == rhs.isCtxDependent
end ;

public function ==(lhs: SemanticContext.PrecedencePredicate, rhs: SemanticContext.PrecedencePredicate) return Boolean is
begin
    if lhs === rhs then
        return true
    end ;
    return lhs.precedence == rhs.precedence
end ;


public function ==(lhs: SemanticContext.AND, rhs: SemanticContext.AND) return Boolean is
begin
    if lhs === rhs then
        return true
    end ;
    return lhs.opnds == rhs.opnds
end ;

public function ==(lhs: SemanticContext.OR, rhs: SemanticContext.OR) return Boolean is
begin
    if lhs === rhs then
        return true
    end ;
    return lhs.opnds == rhs.opnds
end ;
