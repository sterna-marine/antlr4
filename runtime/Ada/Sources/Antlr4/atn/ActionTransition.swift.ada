-- 
-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
-- 


public final type ActionTransition is new Transition and CustomStringConvertible with null record;
{
    public let ruleIndex : Integer;
    public let actionIndex : Integer;
    public let isCtxDependent : Boolean;
    -- e.g., $i ref in action


    public convenience init(target : ATNState; ruleIndex : Integer) {
        self.init(target, ruleIndex, -1, false)
    end ;

    public init(target : ATNState; ruleIndex : Integer; actionIndex : Integer; isCtxDependent  : Boolean) {

        self.ruleIndex := ruleIndex
        self.actionIndex := actionIndex
        self.isCtxDependent := isCtxDependent
        super.init(target)
    end ;

    override
    public function getSerializationType (This : …) return Integer is
begin
        return Transition.ACTION
    end ;

    override
    public function isEpsilon (This : …) return Boolean is
begin
        return true -- we are to be ignored by analysis 'cept for predicates
    end ;

    override
    public function matches (symbol : Integer; minVocabSymbol : Integer; maxVocabSymbol : Integer) return Boolean is
begin
        return false
    end ;

    public var description: String {
        return "action_\(ruleIndex):\(actionIndex)"
    end ;

end ;
