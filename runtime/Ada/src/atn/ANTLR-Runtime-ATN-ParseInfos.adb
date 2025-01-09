-- €

with ANTLR.Runtime.ATN.ParseInfos;

use ANTLR.Runtime.ATN.ParseInfos;

package body ANTLR.Runtime.ATN.ParseInfos is

   procedure Initialize (Self : in out ParseInfo; atnSimulator : ProfilingATNSimulator) is
   begin
      self.atnSimulator := atnSimulator;
   end Initialize;

   function getLLDecisions (This : ParseInfo) return Integer_List is
      LL : Integer_List;
      decisions : constant DecisionInfo_List := This.atnSimulator.getDecisionInfo;
      fallBack : Long_Long_Integer; -- constant
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

   function getTotalTimeInPrediction (This : ParseInfo) return Real_Time.Time_Span is
      decisions : constant DecisionInfo_List := This.atnSimulator.getDecisionInfo;
      t : Real_Time.Time_Span := Real_Time.Time_Span_Zero;
   begin
      for d of decisions loop
         t := @ + d.timeInPrediction;
      end loop;
      return t;
   end getTotalTimeInPrediction;

   function getTotalSLLLookaheadOps (This : ParseInfo) return Long_Long_Integer is
      decisions : constant DecisionInfo_List := This.atnSimulator.getDecisionInfo;
      k : Long_Long_Integer := 0;
   begin
      for d of decisions loop
         k := @ + d.SLL_TotalLook;
      end loop;
      return k;
   end getTotalSLLLookaheadOps;

   function getTotalLLLookaheadOps (This : ParseInfo) return Long_Long_Integer is
      decisions : constant DecisionInfo_List := This.atnSimulator.getDecisionInfo;
      k : Long_Long_Integer := 0;
   begin
      for d of decisions loop
         k := @ + d.LL_TotalLook;
      end loop;
      return k;
   end getTotalLLLookaheadOps;

   function getTotalSLLATNLookaheadOps (This : ParseInfo) return Long_Long_Integer is
      decisions : constant DecisionInfo_List := This.atnSimulator.getDecisionInfo;
      k : Long_Long_Integer := 0;
   begin
      for d of decisions loop
         k := @ + d.SLL_ATNTransitions;
      end loop;
      return k;
   end getTotalSLLATNLookaheadOps;

   function getTotalLLATNLookaheadOps (This : ParseInfo) return Long_Long_Integer is
      decisions : constant DecisionInfo_List := This.atnSimulator.getDecisionInfo;
      k : Long_Long_Integer := 0;
   begin
      for d of decisions loop
         k := @ + d.LL_ATNTransitions;
      end loop;
      return k;
   end getTotalLLATNLookaheadOps;

   function getTotalATNLookaheadOps (This : ParseInfo) return Long_Long_Integer is
      decisions : constant DecisionInfo_List := This.atnSimulator.getDecisionInfo;
      k : Long_Long_Integer := 0;
   begin
      for d of decisions loop
         k := @ + d.SLL_ATNTransitions;
         k := @ + d.LL_ATNTransitions;
      end loop;
      return k;
   end getTotalATNLookaheadOps;

   function getDFASize (This : ParseInfo) return Integer is
      decisionToDFA : constant DFA_List := This.atnSimulator.decisionToDFA;
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

end ANTLR.Runtime.ATN.ParseInfos;
