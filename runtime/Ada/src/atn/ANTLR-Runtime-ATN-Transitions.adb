-- €

package body ANTLR.Runtime.ATN.Transitions is

   function serializationTypes_Image (This : ATNTransition) return UString is
   begin
      case This is
         when INVALID => raise PROGRAM_ERROR;
         when EPSILON => return EpsilonTransition'Image;
         when TRANSITION_RANGE => return RangeTransition'Image;
         when RULE => return RuleTransition'Image;
         when PREDICATE => return PredicateTransition'Image;
         when ATOM => return AtomTransition'Image;
         when ACTION => return ActionTransition'Image;
         when SET => return SetTransition'Image;
         when NOT_SET => return NotSetTransition'Image;
         when WILDCARD => return WildcardTransition'Image;
         when PRECEDENCE => return PrecedencePredicateTransition'Image;
      end case;
   end serializationTypes_Image;

   procedure Initialize (Self : in out ATNTransition; target : ATNState) is
   begin
      Self.target := target;
   end Initialize;

   -- public
   function getSerializationType (This : ATNTransition'Class) return Integer is
   begin
      raise PROGRAM_ERROR with "ANTLR.Runtime.ATN.Transitions.getSerializationType() must be overridden";
   end getSerializationType;

   function matches (symbol : Integer; minVocabSymbol : Integer; maxVocabSymbol : Integer) return Boolean is
   begin
      raise PROGRAM_ERROR with "ANTLR.Runtime.ATN.Transitions.matches() must be overridden";
   end if;

end ANTLR.Runtime.ATN.Transitions;
