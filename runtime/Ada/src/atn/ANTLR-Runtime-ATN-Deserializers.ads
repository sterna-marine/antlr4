-- €

with Ada.Finalization;
with ANTLR.Runtime.ATN.States;
with ANTLR.Runtime.Token_Protocol;

use ANTLR.Runtime.ATN.States;
use ANTLR.Runtime.Token_Protocol;

package ANTLR.Runtime.ATN.Deserializers is

   -- public static
   SERIALIZED_VERSION : constant := 4;

   -- public
   type ATNDeserializer is new Ada.Finalization.Controlled with private;

   subtype Object is ATNDeserializer;
   type Class is access all Object;
   type Class_Wide is access all Object'Class;

   -- public
   procedure Initialize (Self : in out ATNDeserializer;
                   deserializationOptions : Optional_ATNDeserializationOptions := (Valid => False));

   -- public
   function deserialize (This : ATNDeserializer; data : Integer_List) return ATN;

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
   procedure checkCondition (condition : Boolean; message : Optional_UString);

   -- internal
   function edgeFactory (atn : ATN;
                          Token_Type : Token_Kind;
                          src : Integer;
                          trg : Integer;
                          arg1 : Integer;
                          arg2 : Integer;
                          arg3 : Integer;
                          sets : IntervalSet_List)
                          return Transition;

   -- internal
   function stateFactory (State : State; ruleIndex : Integer) return Optional_ATNState;

   -- internal
   function lexerActionFactory (ActionType : LexerActionType; data1, data2 : Integer) return LexerAction;

private

   -- public
   type ATNDeserializer is new Ada.Finalization.Controlled with record
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
   function readInt (data : Integer_List; p : in out Integer) return Integer;

   function Read_Unicode (P1 : Integer_List; P2 : in out Integer) return Integer; --TOFIX
   type Read_Unicode_Access is access (P1 : Integer_List; P2 : in out Integer) return Integer;
   -- private
   procedure readSets (data : Integer_List;
                       p : in out Integer;
                       sets : in out IntervalSet_Container.Vector;
                       readUnicode : Read_Unicode_Access);

   -- private
   procedure fillRuleToStopState (atn : ATN);

   -- private
   procedure generateRuleBypassTransitions (atn : ATN);

end ANTLR.Runtime.ATN.Deserializers;
