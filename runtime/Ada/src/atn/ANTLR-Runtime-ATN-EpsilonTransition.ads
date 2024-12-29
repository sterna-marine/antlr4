-- €

package ANTLR.Runtime.ATN.EpsilonTransition is

   -- public final
   type EpsilonTransition is new ATNTransition and CustomStringConvertible with
   record
      -- private
      outermostPrecedenceReturnInside : Integer := -1; --  constant
   end record;

   -- public convenience
   overriding
   procedure Initialize (Self : in out EpsilonTransition;
                   target : ATNState);

   -- public
   procedure Initialize (Self : in out EpsilonTransition;
                   target : ATNState;
                   outermostPrecedenceReturn : Integer);

   --
   -- * returns: the rule index of a precedence rule for which this transition is
   -- returning from, where the precedence value is 0; otherwise, -1.
   --
   -- * seealso: org.antlr.v4.runtime.atn.ATNConfig#isPrecedenceFilterSuppressed ();
   -- * seealso: org.antlr.v4.runtime.atn.ParserATNSimulator#applyPrecedenceFilter (org.antlr.v4.runtime.atn.ATNConfigSet);
   --

   -- public
   function outermostPrecedenceReturn (This : EpsilonTransition) return Integer
      is (This.outermostPrecedenceReturnInside);

   overriding
   -- public
   function getSerializationType (This : EpsilonTransition) return Integer
      is (This.Transition.EPSILON);

   overriding
   -- public
   function isEpsilon (This : EpsilonTransition) return Boolean
      is (True);

   overriding
   -- public
   function matches (symbol : Integer; minVocabSymbol : Integer; maxVocabSymbol : Integer) return Boolean
      is (False);

   -- public
   function Description (This : …) return UString
      is ("epsilon");

end ANTLR.Runtime.ATN.EpsilonTransition;
