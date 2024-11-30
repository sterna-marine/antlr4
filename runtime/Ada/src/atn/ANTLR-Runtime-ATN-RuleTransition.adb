-- €





-- public final
type RuleTransition is new Transition with null record;
{
    -- 
    -- Ptr to the rule definition object for this rule ref
    -- 
    -- public
    ruleIndex : constant Integer;
    -- no Rule object at runtime

    -- public
    precedence : constant Integer;

    -- 
    -- What node to begin computations following ref to rule
    -- 
    -- public 
    followState : constant ATNState;

    -- public 
    procedure Init (Self : in out …; ruleStart : RuleStartState;
                ruleIndex : Integer;
                precedence : Integer;
                followState : ATNState) {

        self.ruleIndex := ruleIndex
        self.precedence := precedence
        self.followState := followState

        super.init (ruleStart);
    end if;

    override
    -- public
    function getSerializationType (This : …) return Integer is
begin
        return Transition.RULE
    end if;

    override
    -- public
    function isEpsilon (This : …) return Boolean is
begin
        return True;
    end if;

    override
    -- public
    function matches (symbol : Integer; minVocabSymbol : Integer; maxVocabSymbol : Integer) return Boolean is
begin
        return False;
    end if;
end if;
