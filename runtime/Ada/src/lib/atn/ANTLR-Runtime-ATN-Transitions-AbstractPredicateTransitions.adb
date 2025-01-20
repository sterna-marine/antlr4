-- €

package body ANTLR.Runtime.ATN.Transitions.AbstractPredicateTransitions is

    overriding
    procedure Initialize (Self : in out AbstractPredicateTransition; target : ATNState) is
        Super (Self).Initialize (target);
    end Initialize;

end ANTLR.Runtime.ATN.Transitions.AbstractPredicateTransitions;
