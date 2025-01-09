-- €

with Ada.Strings;
with ANTLR.Runtime.ATN.States;

use ANTLR.Runtime.ATN;
use ANTLR.Runtime.ATN.States;

package ANTLR.Runtime.ATN.Transitions.ActionTransitions is

   use ANTLR.Runtime.ATN.Transitions;

   -- public final
   type ActionTransition is new ATNTransition with
   record
      -- public
      ruleIndex : Integer; -- constant
      -- public
      actionIndex : Integer; -- constant
      -- public
      isCtxDependent : Boolean; -- constant
      -- e.g., $i ref in action
   end record;

   subtype Object is ActionTransition;
   subtype Super is ATNTransition;
   type Class is access all Object;
   type Class_Wide is access all Object'Class;

   -- public convenience
   procedure Initialize (Self : in out ActionTransition; target : ATNState; ruleIndex : Integer);

   -- public
   procedure Initialize (Self : in out ActionTransition;
                   target : ATNState;
                   ruleIndex : Integer;
                   actionIndex : Integer;
                   isCtxDependent  : Boolean);

   overriding
   -- public
   function getSerializationType (This : ActionTransition) return Integer
      is (Transition.ACTION);

   overriding
   -- public
   function isEpsilon (This : ActionTransition) return Boolean
      is (True); -- we are to be ignored by analysis 'cept for predicates

   -- public
   overriding
   function matches (symbol : Integer; minVocabSymbol : Integer; maxVocabSymbol : Integer) return Boolean
      is (False);

   subtype Sink is Ada.Strings.Text_Buffers.Root_Buffer_Type;
   procedure Put_Image_ActionTransition (S : in out Sink'Class; X : ActionTransition);
   for ActionTransition'Put_Image use Put_Image_ActionTransition;
   -- public
   function Description (This : ActionTransition) return UString
      is ("action_" & ruleIndex'Image & ':' & actionIndex'Image);

end ANTLR.Runtime.ATN.Transitions.ActionTransitions;
