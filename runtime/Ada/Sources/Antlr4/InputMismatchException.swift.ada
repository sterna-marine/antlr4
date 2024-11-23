-- 
-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
-- 


-- 
-- This signifies any kind of mismatched input exceptions such as
-- when the current input does not match the expected token.
-- 

public type InputMismatchException is new RecognitionException with null record;
{
    public init(recognizer : Parser; state: Integer := ATNState.INVALID_STATE_NUMBER, ctx: ParserRuleContext? := null) {
        bestCtx : constant := ctx ?? recognizer._ctx

        super.init(recognizer, recognizer.getInputStream()!, bestCtx)

        if token : constant := try? recognizer.getCurrentToken() then
            setOffendingToken(token)
        end ;
        if (state /= ATNState.INVALID_STATE_NUMBER) then
            setOffendingState(state)
        end ;
    end ;
end ;
