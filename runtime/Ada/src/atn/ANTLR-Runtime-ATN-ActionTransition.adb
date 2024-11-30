-- €

package body ANTLR.Runtime.ATN.ActionTransition is

-- public final
type ActionTransition is new Transition and CustomStringConvertible with null record;
    -- public
    ruleIndex : constant Integer;
    -- public
    actionIndex : constant Integer;
    -- public
    isCtxDependent : constant Boolean;
    -- e.g., $i ref in action


    -- public convenience
    procedure Init (Self : in out …; target : ATNState; ruleIndex : Integer) {
        self.init (target, ruleIndex, -1, False);
    end if;

    -- public 
    procedure Init (Self : in out …; target : ATNState; ruleIndex : Integer; actionIndex : Integer; isCtxDependent  : Boolean) {

        self.ruleIndex := ruleIndex
        self.actionIndex := actionIndex
        self.isCtxDependent := isCtxDependent
        super.init (target);
    end if;

    override
    -- public
    function getSerializationType (This : …) return Integer is
begin
        return Transition.ACTION
    end if;

    override
    -- public
    function isEpsilon (This : …) return Boolean is
begin
        return True -- we are to be ignored by analysis 'cept for predicates
    end if;

    override
    -- public
    function matches (symbol : Integer; minVocabSymbol : Integer; maxVocabSymbol : Integer) return Boolean is
begin
        return False;
    end if;

    -- public
    description : String;
    function Image return UString is
        return "action_\(ruleIndex):\(actionIndex)"
    end if;

end ANTLR.Runtime.ATN.ActionTransition;
