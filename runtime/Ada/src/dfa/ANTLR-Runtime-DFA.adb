-- €

with ANTLR.Runtime.Misc.Exceptions.Errors;

use ANTLR.Runtime.Misc.Exceptions.Errors;

package body ANTLR.Runtime.DFA is

   procedure Initialize (Self : in out DFA; atnStartState : DecisionState) is
   begin
      Self.Initialize (atnStartState, 0);
   end Initialize;

   procedure Initialize (Self : in out DFA; atnStartState : DecisionState; decision : Integer) is
   begin
      self.atnStartState := atnStartState;
      self.decision := decision;

      starLoopState : constant Optional_StarLoopEntryState;
      if Is_Valid (starLoopState) then
         declare
            precedenceState : DFAState := DFAState (This.ATNConfigSet); -- constant
         begin
            starLoopState.precedenceRuleDecision := Maybe (Self.atnStartState);
            precedenceState.edges := DFAState.Container.Empty_Vector;
            precedenceState.isAcceptState := False;
            precedenceState.requiresFullContext := False;
            Self.precedenceDfa := True;
            Self.s0 := precedenceState;
         end;
      else
         Self.precedenceDfa := False;
         Self.s0 := (Valid => False);
      end if;
   end Initialize;

   function getPrecedenceStartState (This : DFA; precedence : Integer) return Optional_DFAState is
   begin
      if not This.isPrecedenceDfa then
         raise ANTLRError.illegalState with "Only precedence DFAs may contain a precedence start state.";
      end if;

      if not Is_Valid (This.s0)
         or not Is_Valid (This.s0.edges)
         or not precedence >= 0
         or not precedence < edges.count then
         return Optional_DFAState (Valid => False);
      else
         return Element (edges, precedence);
      end if;
   end getPrecedenceStartState;

   procedure setPrecedenceStartState (This : DFA; precedence : Integer; startState : DFAState) is

      function Closure return … is
      begin
         -- s0.edges is never null for a precedence DFA
         if precedence >= edges.count then
            increase : constant := [DFAState?](repeating => null, count: (precedence + 1 - edges.count));
            s0.edges := edges + increase;
         else
            DFAState.Container.Insert (Key => s0.edges, precedence, New_Item => startState);
         end if;
      end Closure;
      Closure_Return_Value : …;
      function Synchronized_Closure is new Mutex.Gen_Closure (Closure => Closure, Result_Type => …);

   begin
      if not This.isPrecedenceDfa then
         raise ANTLRError.illegalState with "Only precedence DFAs may contain a precedence start state.";
      end if;

      if not Is_Valid (s0)
         or not Is_Valid (s0.edges)
         or not precedence >= 0 then
         exit;
      else
         -- synchronization on s0 here is ok. when the DFA is turned into a
         -- precedence DFA, s0 will be initialized once and not updated again
         s0.Mutex.Run (Synchronized_Closure'Access, Closure_Return_Value);
         --TOFIX return Closure_Return_Value;
      end if;
   end setPrecedenceStartState;

   function getStates (This : DFA) return DFAState_List is
      result : DFAState_List := [DFAState](states.keys);

      function '<' (Left, Right : DFAState) return Boolean
         is (Left.stateNumber < Right.stateNumber);

       package body DFAState_Sorting is new DFAState.Container.Generic_Sorting ('<');

   begin
      DFAState_Sorting.Sort (result);
      return result;
   end getStates;

   function toString (This : DFA; vocabulary : Vocabulary) return UString is
   begin
      if not Is_Valid (This.s0) then
         return "";
      else
         declare
            serializer : constant := DFASerializer (This, vocabulary);
         begin
            return serializer'Image;
         end;
      end if;
   end toString;

   function toLexerString (This : DFA) return UString is
   begin
      if not Is_Valid (This.s0) then
         return "";
      else
         declare
            serializer : constant := LexerDFASerializer (This);
         begin
            return serializer'Image;
         end
      end if;
   end toLexerString;

end ANTLR.Runtime.DFA;
