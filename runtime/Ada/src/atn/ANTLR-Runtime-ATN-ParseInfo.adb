-- €

package body ANTLR.Runtime.ATN.ParseInfo is

   procedure Initialize (Self : in out ParseInfo; atnSimulator : ProfilingATNSimulator) is
   begin
      self.atnSimulator := atnSimulator;
   end Initialize;

   function getLLDecisions (This : ParseInfo) return Integer.Container.Vector is
      LL : Integer.Container.Vector;
      decisions : constant DecisionInfo.Container.Vector := This.atnSimulator.getDecisionInfo ();
      fallBack : Integer_64; -- constant
   begin
      for i in 0 .. decisions.Length - 1 loop
         fallBack := decisions.Element (i).LL_Fallback;
         if fallBack > 0 then
               LL.append (i);
               -- LL.add (i);
         end if;
      end loop;
      return LL;
   end getLLDecisions;

   function getTotalTimeInPrediction (This : ParseInfo) return Integer_64 is
      decisions : constant DecisionInfo.Container.Vector := This.atnSimulator.getDecisionInfo ();
      t : Integer_64 := 0;
   begin
      for d of decisions loop
         t := @ + d.timeInPrediction;
      end loop;
      return t;
   end getTotalTimeInPrediction;

   function getTotalSLLLookaheadOps (This : ParseInfo) return Integer_64 is
      decisions : constant DecisionInfo.Container.Vector := This.atnSimulator.getDecisionInfo ();
      k : Integer_64 := 0;
   begin
      for d of decisions loop
         k := @ + d.SLL_TotalLook;
      end loop;
      return k;
   end getTotalSLLLookaheadOps;

   function getTotalLLLookaheadOps (This : ParseInfo) return Integer_64 is
      decisions : constant DecisionInfo.Container.Vector := This.atnSimulator.getDecisionInfo ();
      k : Integer_64 := 0;
   begin
      for d of decisions loop
         k := @ + d.LL_TotalLook;
      end loop;
      return k;
   end getTotalLLLookaheadOps;

   function getTotalSLLATNLookaheadOps (This : ParseInfo) return Integer_64 is
      decisions : constant DecisionInfo.Container.Vector := This.atnSimulator.getDecisionInfo ();
      k : Integer_64 := 0;
   begin
      for d of decisions loop
         k := @ + d.SLL_ATNTransitions;
      end loop;
      return k;
   end getTotalSLLATNLookaheadOps;

   function getTotalLLATNLookaheadOps (This : ParseInfo) return Integer_64 is
      decisions : constant DecisionInfo.Container.Vector := This.atnSimulator.getDecisionInfo ();
      k : Integer_64 := 0;
   begin
      for d of decisions loop
         k := @ + d.LL_ATNTransitions;
      end loop;
      return k;
   end getTotalLLATNLookaheadOps;

   function getTotalATNLookaheadOps (This : ParseInfo) return Integer_64 is
      decisions : constant DecisionInfo.Container.Vector := This.atnSimulator.getDecisionInfo ();
      k : Integer_64 := 0;
   begin
      for d in decisions loop
         k := @ + d.SLL_ATNTransitions;
         k := @ + d.LL_ATNTransitions;
      end loop;
      return k;
   end getTotalATNLookaheadOps;

   function getDFASize (This : ParseInfo) return Integer is
      decisionToDFA : constant DFA.Container.Vector := This.atnSimulator.decisionToDFA;
      n : Integer := 0;
   begin
      for i in 0 .. decisionToDFA.Length - 1 loop
         n := @ + getDFASize (i);
      end loop;
      return n;
   end getDFASize;

   function getDFASize (This : ParseInfo; decision : Integer) return Integer is
      decisionToDFA : constant DFA := This.atnSimulator.decisionToDFA.Element (decision);
   begin
      return decisionToDFA.states.Length;
   end getDFASize;

end ANTLR.Runtime.ATN.ParseInfo;
