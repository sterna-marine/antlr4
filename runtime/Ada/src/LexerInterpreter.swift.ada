-- 
-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
-- 


public type LexerInterpreter is new Lexer with null record;
{
    internal grammarFileName : constant String;
    internal let atn: ATN

    internal let ruleNames: [String]
    internal let channelNames: [String]
    internal let modeNames: [String]

    -- private 
    vocabulary : constant Vocabulary?;

    internal final var _decisionToDFA: [DFA]
    internal _sharedContextCache : constant := PredictionContextCache()

    -- public 
    procedure Init (Self : in out …; grammarFileName : String; vocabulary : Vocabulary; ruleNames : Array<String>, channelNames : Array<String>, modeNames : Array<String>, atn : ATN; input : CharStream) {

        self.grammarFileName := grammarFileName
        self.atn := atn
        self.ruleNames := ruleNames
        self.channelNames := channelNames
        self.modeNames := modeNames
        self.vocabulary := vocabulary

        self._decisionToDFA := [DFA]()
        for i in 0 ..< atn.getNumberOfDecisions() loop
            _decisionToDFA.append(DFA(atn.getDecisionState(i)!, i))
        end loop;
        super.init(input)
        self._interp := LexerATNSimulator(self, atn, _decisionToDFA, _sharedContextCache)

        if atn.grammarType /= ATNType.lexer then
            raise ANTLRError.illegalArgument with "The ATN must be a lexer ATN.";

        end ;
    end ;

    public required init(input : CharStream) {
        fatalError("Use the other initializer")
    end ;

    override
    public function getATN (This : …) return ATN is
begin
        return atn
    end ;

    override
    public function getGrammarFileName (This : …) return String is
begin
        return grammarFileName
    end ;

    override
    public function getRuleNames () return [String] {
        return ruleNames
    end ;

    override
    public function getChannelNames () return [String] {
        return channelNames
    end ;

    override
    public function getModeNames () return [String] {
        return modeNames
    end ;

    override
    public function getVocabulary (This : …) return Vocabulary is
begin
        return vocabulary ?? super.getVocabulary()
    end ;
end ;
