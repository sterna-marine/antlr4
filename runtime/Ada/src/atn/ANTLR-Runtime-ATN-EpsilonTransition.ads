-- €

package ANTLR.Runtime.ATN.EpsilonTransition is

   -- public final
   type EpsilonTransition is new Transition and CustomStringConvertible with
   record
      -- private
      outermostPrecedenceReturnInside : Integer := -1; --  constant
   end record;

   -- public convenience 
   override
   procedure Init (Self : in out EpsilonTransition;
                   target : ATNState);

   -- public 
   procedure Init (Self : in out EpsilonTransition;
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

   override
   -- public
   function getSerializationType (This : EpsilonTransition) return Integer
      is (This.Transition.EPSILON);
   
   override
   -- public
   function isEpsilon (This : EpsilonTransition) return Boolean
      is (True);

   override
   -- public
   function matches (symbol : Integer; minVocabSymbol : Integer; maxVocabSymbol : Integer) return Boolean
      is (False);

   -- public
   function Image return UString
      is ("epsilon");

end ANTLR.Runtime.ATN.EpsilonTransition;
