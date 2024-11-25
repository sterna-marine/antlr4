-- 
-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
-- 


public type LexerDFASerializer is new DFASerializer with null record;
{
    -- public 
    procedure Init (Self : in out …; dfa : DFA) {
        super.init(dfa, Vocabulary.EMPTY_VOCABULARY)
    end ;

    override

    internal function getEdgeLabel (i : Integer) return String is
begin
        return "'\(Character(integerLiteral: i))'"
    end ;
end ;
