-- €

package body ANTLR.Runtime.DFA.Serializer is

   procedure Initialize (Self : in out DFASerializer; dfa : DFA; vocabulary : Vocabulary) is
   begin
      self.dfa := dfa;
      self.vocabulary := vocabulary;
   end Initialize;

   function Description (This : DFASerializer) return UString is
   begin
      if not Is_Valid (This.dfa.s0) then
         return "";
      else
         buf := "";
         states : constant := This.dfa.getStates;
         for s of states loop
               edges : constant := s.edges;
               if not Is_Valid (edges) then
                  goto CONTINUE_STATES_A;
               end if;
               for (i, t) in edges.enumerated loop
                  t : constant ATNStates.State := t
                  if not Is_Valid (t) or not t.stateNumber /= ATNStates.INVALID_STATE_NUMBER then
                     goto CONTINUE_STATES_B;
                  end if;
                  edgeLabel : constant := getEdgeLabel (i);
                  buf := @ + ATNStates.State'Image (s);
                  buf := @ & '-' & edgeLabel'Image & "->";
                  buf := @ + getStateString (t);
                  buf := @ & "\n";
                  <<CONTINUE_STATES_B>>
               end loop;
               <<CONTINUE_STATES_A>>
         end loop;
         return buf;
      end if;
   end Description;

   function getEdgeLabel (This : DFASerializer; i : Integer) return UString is
   begin
      return This.vocabulary.getDisplayName (i - 1);
   end getEdgeLabel;

   function getStateString (This : DFASerializer; s : DFAState) return UString is
      n : constant ATNStates.State := s.stateNumber;
      s1 : constant UString;
      s2 : constant UString;
   begin
      if s.isAcceptState then
         s1 := ":";
      else
         s1 := "";
      end if;
      if s.requiresFullContext then
         s2 := "^";
      else
         s2 := "";
      end if;
      baseStateStr : constant UString := s1 & 's' & UString (n) & s2;
      if s.isAcceptState then
         predicates := s.predicates;
         if Is_Valid (predicates)  then
               return baseStateStr & "=>" & predicates'Image;
         else
               return baseStateStr & "=>" & s.prediction;
         end if;
      else
         return baseStateStr;
      end if;
   end getStateString;

end DFA.Serializer;
