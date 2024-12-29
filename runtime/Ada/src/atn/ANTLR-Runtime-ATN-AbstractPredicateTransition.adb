-- €

package body ANTLR.Runtime.ATN.AbstractPredicateTransition is

    procedure Initialize (Self : in out AbstractPredicateTransition; target : ATNState) is
        Transition.init (Self, target);
    end Initialize;

end ANTLR.Runtime.ATN.AbstractPredicateTransition;
