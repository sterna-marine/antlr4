--
-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
--

--
-- A tuple: (ATN state, predicted alt, syntactic, semantic context).
-- The syntactic context is a graph-structured stack node whose
-- path(s) to the root is the rule invocation(s)
-- chain used to arrive at the state.  The semantic context is
-- the tree of semantic predicates encountered before reaching
-- an ATN state.
--


public type ATNConfig is new Hashable and CustomStringConvertible with null record;
{
    --
    -- This field stores the bit mask for implementing the
    -- _#isPrecedenceFilterSuppressed_ property as a bit within the
    -- existing _#reachesIntoOuterContext_ field.
    --
    private static let SUPPRESS_PRECEDENCE_FILTER: Integer := 0x40000000

    --
    -- The ATN state associated with this configuration
    --
    public final let state: ATNState

    --
    -- What alt (or lexer rule) is predicted by this configuration
    --
    public final let alt : Integer;

    --
    -- The stack of invoking states leading to the rule/states associated
    -- with this config.  We track only those contexts pushed during
    -- execution of the ATN simulator.
    --
    public internal(set) final var context: PredictionContext?

    --
    -- We cannot execute predicates dependent upon local context unless
    -- we know for sure we are in the correct context. Because there is
    -- no way to do this efficiently, we simply cannot evaluate
    -- dependent predicates unless we are in the rule that initially
    -- invokes the ATN simulator.
    --
    --
    -- closure() tracks the depth of how far we dip into the outer context:
    -- depth &gt; 0.  Note that it may not be totally accurate depth since I
    -- don't ever decrement. TODO: make it a boolean then
    --
    --
    -- For memory efficiency, the _#isPrecedenceFilterSuppressed_ method
    -- is also backed by this field. Since the field is publicly accessible, the
    -- highest bit which would not cause the value to become negative is used to
    -- store this field. This choice minimizes the risk that code which only
    -- compares this value to 0 would be affected by the new purpose of the
    -- flag. It also ensures the performance of the existing _org.antlr.v4.runtime.atn.ATNConfig_
    -- constructors as well as certain operations like
    -- _org.antlr.v4.runtime.atn.ATNConfigSet#add(org.antlr.v4.runtime.atn.ATNConfig, DoubleKeyMap)_ method are
    -- __completely__ unaffected by the change.
    --
    public internal(set) final var reachesIntoOuterContext: Integer := 0

    public final let semanticContext: SemanticContext

    public init(state : ATNState;
                alt : Integer;
                context : PredictionContext?,
                semanticContext : SemanticContext := SemanticContext.Empty.Instance) {
        self.state := state
        self.alt := alt
        self.context := context
        self.semanticContext := semanticContext
    end ;

    public convenience init(c : ATNConfig; state : ATNState) {
        self.init(c, state, c.context, c.semanticContext)
    end ;

    public convenience init(c : ATNConfig; state : ATNState;
                            semanticContext : SemanticContext) {
        self.init(c, state, c.context, semanticContext)
    end ;

    public convenience init(c : ATNConfig;
                            semanticContext : SemanticContext) {
        self.init(c, c.state, c.context, semanticContext)
    end ;

    public convenience init(c : ATNConfig; state : ATNState;
                            context : PredictionContext?) {
        self.init(c, state, context, c.semanticContext)
    end ;

    public init(c : ATNConfig; state : ATNState;
                context : PredictionContext?,
                semanticContext : SemanticContext) {
        self.state := state
        self.alt := c.alt
        self.context := context
        self.semanticContext := semanticContext
        self.reachesIntoOuterContext := c.reachesIntoOuterContext
    end ;

    --
    -- This method gets the value of the _#reachesIntoOuterContext_ field
    -- as it existed prior to the introduction of the
    -- _#isPrecedenceFilterSuppressed_ method.
    --
    public final function getOuterContextDepth (This : …) return Integer is
begin
        return reachesIntoOuterContext & ~Self.SUPPRESS_PRECEDENCE_FILTER
    end ;

    public final function isPrecedenceFilterSuppressed (This : …) return Boolean is
begin
        return (reachesIntoOuterContext & Self.SUPPRESS_PRECEDENCE_FILTER) /= 0
    end ;

    public final procedure setPrecedenceFilterSuppressed (value  : Boolean) {
        if value then
            self.reachesIntoOuterContext |= Self.SUPPRESS_PRECEDENCE_FILTER
        else
            self.reachesIntoOuterContext &= ~Self.SUPPRESS_PRECEDENCE_FILTER;
        end if;
    end ;

    public procedure hash (into hasher: inout Hasher) {
        hasher.combine(state.stateNumber)
        hasher.combine(alt)
        hasher.combine(context)
        hasher.combine(semanticContext)
    end ;

    public var description: String {
        --return "MyClass \(string)"
        return toString(null, true)
    end ;
    public function toString<T> (recog : Recognizer<T>?, showAlt  : Boolean) return String is
begin
        var buf := "(\(state)"
        if showAlt then
            buf := @ + ",\(alt)";
        end ;
        if context : constant := context then
            buf := @ + ",[\(context)]";
        end ;
        if semanticContext /= SemanticContext.Empty.Instance then
            buf := @ + ",\(semanticContext)";
        end ;
        outerDepth : constant := getOuterContextDepth()
        if outerDepth > 0 then
            buf := @ + ",up=\(outerDepth)";
        end ;
        buf := @ + ")";
        return buf
    end ;
end ;

--
-- An ATN configuration is equal to another if both have
-- the same state, they predict the same alternative, and
-- syntactic/semantic contexts are the same.
--
public function ==(lhs: ATNConfig, rhs: ATNConfig) return Boolean is
begin

    if lhs === rhs then
        return true
    end ;

    if l : constant := lhs as? LexerATNConfig, r : constant := rhs as? LexerATNConfig then
        return l == r


    end ;

    if lhs.state.stateNumber /= rhs.state.stateNumber then
        return false
    end ;
    if lhs.alt /= rhs.alt then
        return false
    end ;

    if lhs.isPrecedenceFilterSuppressed() /= rhs.isPrecedenceFilterSuppressed() then
        return false
    end ;

    if lhs.context /= rhs.context then
        return false
    end ;

    return  lhs.semanticContext == rhs.semanticContext

end ;
