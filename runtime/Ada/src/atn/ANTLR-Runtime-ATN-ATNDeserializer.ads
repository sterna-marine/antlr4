-- €

with Ada.Finalization;
with ANTLR.Runtime.ATN.ATNState;
use ANTLR.Runtime.ATN;

package ANTLR.Runtime.ATN.ATNDeserializer is

   -- public static
   SERIALIZED_VERSION : constant := 4;

   -- public
   type ATNDeserializer is new Ada.Finalization.Controlled private;

   -- public
   procedure Initialize (Self : in out ATNDeserializer;
                   deserializationOptions : Optional_ATNDeserializationOptions := (Valid => False));

   -- public
   function deserialize (This : ATNDeserializer; data : Integer.Container.Vector) return ATN;

   --
   -- Analyze the _org.antlr.v4.runtime.atn.StarLoopEntryState_ states in the specified ATN to set
   -- the _org.antlr.v4.runtime.atn.StarLoopEntryState#precedenceRuleDecision_ field to the
   -- correct value.
   --
   -- * parameter atn: The ATN.
   --
   -- internal
   procedure markPrecedenceDecisions (atn : ATN);

   -- internal
   procedure verifyATN (atn : ATN);

   -- internal
   procedure checkCondition (condition  : Boolean);

   -- internal
   procedure checkCondition (condition : Boolean; message : Optional_String);

   -- internal
   procedure edgeFactory (atn : ATN;
                          Token_Type : Token_Kind;
                          src : Integer;
                          trg : Integer;
                          arg1 : Integer;
                          arg2 : Integer;
                          arg3 : Integer;
                          sets : IntervalSet.Container.Vector)
                          return Transition;

   -- internal
   function stateFactory (State : ATNState.State; ruleIndex : Integer) return Optional_ATNState;

   -- internal
   function lexerActionFactory (ActionType : LexerActionType; data1, data2 : Integer) return LexerAction;

private

   -- public
   type ATNDeserializer is new Ada.Finalization.Controlled record
      -- private
      deserializationOptions : ATNDeserializationOptions; -- constant
   end record;

   -- edges for rule stop states can be derived, so they aren't serialized
   -- private
   procedure deriveEdgesForRuleStopStates (atn : ATN);

   -- private
   procedure validateStates (atn : ATN);

   -- private
   procedure finalizeATN (This : ATNDeserializer; atn : ATN);

   -- private
   function readInt (data : Integer.Container.Vector; p : in out Integer) return Integer;

   function Read_Unicode (P1 : Integer_Container.Vector; P2 : in out Integer) return Integer; --TOFIX

   -- private
   procedure readSets (data : Integer.Container.Vector;
                       p : in out Integer;
                       sets : in out IntervalSet_Container.Vector;
                       readUnicode : Read_Unicode'Access);

   -- private
   procedure fillRuleToStopState (atn : ATN);

   -- private
   procedure generateRuleBypassTransitions (atn : ATN);

end ANTLR.Runtime.ATN.ATNDeserializer;
