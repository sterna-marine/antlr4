-- €

package body ANTLR.Runtime.ATN.AbstractPredicateTransition is

    procedure Init (Self : in out AbstractPredicateTransition; target : ATNState) is
        Transition.init (Self, target);
    end if;

end ANTLR.Runtime.ATN.AbstractPredicateTransition;
