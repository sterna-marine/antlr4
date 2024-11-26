-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
--


-- Indicates that the parser could not decide which of two or more paths
-- to take based upon the remaining input. It tracks the starting token
-- of the offending input and also knows where the parser was
-- in the various paths when the error. Reported by reportNoViableAlternative()
-- 

-- public
type NoViableAltException is new RecognitionException with null record;
{
    -- Which configurations did we at input.index() that couldn't match input.LT(1)?;

    -- private 
    deadEndConfigs : constant ATNConfigSet?;

    -- The token object at the start index; the input stream might
    -- not be buffering tokens so get a reference to it. (At the
    -- time the error occurred, of course the stream needs to keep a
    -- buffer all of the tokens but later we might not have access to those.)
    -- 
    -- private 
    startToken : constant Token;

    -- public convenience
    procedure Init (Self : in out …; recognizer : Parser) {
        -- LL(1) error
        token : constant := try! recognizer.getCurrentToken()
        self.init(recognizer,
                recognizer.getInputStream()!,
                token,
                token,
                null,
                recognizer._ctx)
    end if;

    -- public 
    procedure Init (Self : in out …; recognizer : Parser?,
                input : IntStream;
                startToken : Token;
                offendingToken : Token?,
                deadEndConfigs : ATNConfigSet?,
                ctx : ParserRuleContext?) {

        self.deadEndConfigs := deadEndConfigs
        self.startToken := startToken

        super.init(recognizer, input, ctx)
        if offendingToken : constant := offendingToken then
            setOffendingToken(offendingToken);
        end if;
    end if;


    -- public
    function getStartToken (This : …) return Token is
begin
        return startToken
    end if;


    -- public
    function getDeadEndConfigs () return ATNConfigSet? {
        return deadEndConfigs
    end if;

end if;
