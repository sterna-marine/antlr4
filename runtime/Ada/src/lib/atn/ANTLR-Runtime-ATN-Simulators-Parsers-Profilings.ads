-- €

with ANTLR.Runtime.ATN.DecisionInfo;
with ANTLR.Runtime.ATN.States;
with ANTLR.Runtime.ATN.Transitions;
with ANTLR.Runtime.DFA.States;
with ANTLR.Runtime.Parsers;

use ANTLR.Runtime.ATN.DecisionInfo;
use ANTLR.Runtime.ATN.Simulators;
use ANTLR.Runtime.ATN.Simulators.Parsers;
use ANTLR.Runtime.ATN.States;
use ANTLR.Runtime.ATN.Transitions;
use ANTLR.Runtime.DFA.States;
use ANTLR.Runtime.Parsers;

package ANTLR.Runtime.ATN.Simulators.Parsers.Profilings is

   -- public
   type ProfilingATNSimulator is new ParserATNSimulator with
   record
      -- private (set);
      decisions: DecisionInfo_List; -- := DecisionInfo.Container.Empty_Vector;
      -- internal
      numDecisions : Integer := 0;
      -- internal
      sllStopIndex : Integer := 0;
      -- internal
      llStopIndex : Integer := 0;
      -- internal
      currentDecision : State := INVALID; --TOFIX
      -- internal
      currentState : Optional_DFAState;

      --
      -- At the point of LL failover, we record how SLL would resolve the conflict so that
      -- we can determine whether or not a decision / input pair is context-sensitive.
      -- If LL gives a different result than SLL's predicted alternative, we have a
      -- context sensitivity for sure. The converse is not necessarily True, however.
      -- It's possible that after conflict resolution chooses minimum alternatives,
      -- SLL could get the same answer as LL. Regardless of whether or not the result indicates
      -- an ambiguity, it is not treated as a context sensitivity because LL prediction
      -- was not required in order to produce a correct prediction for this decision and input sequence.
      -- It may in fact still be a context sensitivity but we don't know by looking at the
      -- minimum alternatives for the current input.
      --
      -- internal
      conflictingAltResolvedBySLL : Integer := 0;
   end record;

   subtype Object is ProfilingATNSimulator;
   subtype Super is ParserATNSimulator;
   type Class is access all Object;
   type Class_Wide is access all Object'Class;

   -- public
   procedure Initialize (Self : in out ProfilingATNSimulator; parser : Parser);

   -- public
   overriding
   function adaptivePredict (This : ProfilingATNSimulator;
                             input : TokenStream;
                             decision : State;
                             outerContext : Optional_ParserRuleContext)
                             return Integer;

   -- internal
   overriding
   function getExistingTargetState (This : ProfilingATNSimulator;
                                    previousD : DFAState;
                                    t : Integer)
                                    return Optional_DFAState;

   -- internal
   overriding
   function computeTargetState (This : ProfilingATNSimulator;
                                dfa : DFA;
                                previousD : DFAState;
                                t : Integer)
                                return DFAState;
      state : constant DFAState := Super (This).computeTargetState (dfa, previousD, t);

   overriding
   -- internal
   function computeReachSet (This : ProfilingATNSimulator;
                             closure : ATNConfigSet;
                             t : Integer;
                             fullCtx  : Boolean)
                             return Optional_ATNConfigSet;

   -- internal
   overriding
   function evalSemanticContext (This : ProfilingATNSimulator;
                                 pred : SemanticContext;
                                 parserCallStack : ParserRuleContext;
                                 alt : Integer;
                                 fullCtx  : Boolean)
                                 return Boolean;

   -- internal
   overriding
   procedure reportAttemptingFullContext (This : ProfilingATNSimulator;
                                          dfa : DFA;
                                          conflictingAlts : Optional_BitSet;
                                          configs : ATNConfigSet;
                                          startIndex, stopIndex : Integer);

   -- internal
   overriding
   procedure reportContextSensitivity (This : ProfilingATNSimulator;
                                       dfa : DFA;
                                       prediction : Integer;
                                       configs : ATNConfigSet;
                                       startIndex, stopIndex : Integer);

   -- internal
   overriding
   procedure reportAmbiguity (This : ProfilingATNSimulator;
                              dfa : DFA;
                              D : DFAState;
                              startIndex, stopIndex : Integer;
                              exact : Boolean;
                              ambigAlts : Optional_BitSet;
                              configs : ATNConfigSet);

   -- public
   function getDecisionInfo (This : ProfilingATNSimulator) return DecisionInfo_List
      is (This.decisions);

end ANTLR.Runtime.ATN.Simulators.Parsers.Profilings;
