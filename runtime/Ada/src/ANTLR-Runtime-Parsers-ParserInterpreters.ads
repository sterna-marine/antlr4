-- €

with ANTLR.Runtime.ATN;
with ANTLR.Runtime.ATN.Simulators.Parsers;
with ANTLR.Runtime.ATN.PredictionContextCaches;
with ANTLR.Runtime.ATN.States;
with ANTLR.Runtime.DFA;
with ANTLR.Runtime.Misc.BitSets;
with ANTLR.Runtime.Misc.Exceptions.Errors;
with ANTLR.Runtime.Parsers;
with ANTLR.Runtime.RuleContexts.ParserRuleContexts;
with ANTLR.Runtime.Vocabularies;

use ANTLR.Runtime.ATN;
use ANTLR.Runtime.ATN.PredictionContextCaches;
use ANTLR.Runtime.ATN.States;
use ANTLR.Runtime.ATN.Simulators.Parsers;
use ANTLR.Runtime.DFA;
use ANTLR.Runtime.Misc.BitSets;
use ANTLR.Runtime.Misc.Exceptions.Errors;
use ANTLR.Runtime.Parsers;
use ANTLR.Runtime.RuleContexts.ParserRuleContexts;
use ANTLR.Runtime.Vocabularies;

package ANTLR.Runtime.Parsers.ParserInterpreters is

   -- A parser simulator that mimics what ANTLR's generated
   -- parser code does. A ParserATNSimulator is used to make
   -- predictions via adaptivePredict but this class moves a pointer through the
   -- ATN to simulate parsing. ParserATNSimulator just
   -- makes us efficient rather than having to backtrack, for example.
   --
   -- This properly creates parse trees even for left recursive rules.
   --
   -- We rely on the left recursive rule invocation and special predicate
   -- transitions to make left recursive rules work.
   --
   -- See TestParserInterpreter for examples.
   --

   -- Tracks LR rules for adjusting the contexts
   -- internal final
   type  Ctxt_ID is record
      Ctxt : Optional_ParserRuleContext;
      ID :  Integer;
   end record;

   package Ctxt_ID_Container is new Ada.Containers.Vectors (Ctxt_ID);
   subtype Ctxt_ID_List is Ctxt_ID_Container.Vector;

   -- public
   type ParserInterpreter is new Parser with
   record
      -- internal
      grammarFileName : UString; -- constant
      -- internal
      atn : ATN; -- constant
      -- This identifies StarLoopEntryState's that begin the ( .. )*
      -- precedence loops of left recursive rules.
      --
      -- internal
      statesNeedingLeftRecursionContext : BitSet; -- constant

      -- internal final
      decisionToDFA : DFA_List;
      -- not shared like it is for generated parsers
      internal sharedContextCache : PredictionContextCache := This.PredictionContextCache; -- constant

      -- internal
      ruleNames : UString_List; -- constant

      -- private
      vocabulary : Vocabulary; -- constant

      parentContextStack : Ctxt_ID_List;

      -- We need a map from (decision,inputIndex)->forced alt for computing ambiguous
      -- parse trees. For now, we allow exactly one override.
      --
      -- internal
      overridingDecision : State := INVALID_STATE_NUMBER;
      -- internal
      overridingDecisionInputIndex : Integer := -1;
      -- internal
      overridingDecisionAlt : Integer := -1;

   end record;

   -- A copy constructor that creates a new parser interpreter by reusing
   -- the fields of a previous interpreter.
   --
   -- * Parameter old: The interpreter to copy
   --
   -- public
   procedure Initialize (Self : in out ParserInterpreter; old : ParserInterpreter);

   -- public
   procedure Initialize (Self : in out ParserInterpreter;
                         grammarFileName : UString;
                         vocabulary : Vocabulary;
                         ruleNames : UString_List;
                         atn : ATN;
                         input : TokenStream);
   -- public
   overriding
   function getATN (This : ParserInterpreter) return ATN
      is (This.atn);

   -- public
   overriding
   function getVocabulary (This : ParserInterpreter) return Vocabulary
      is (This.vocabulary);

   -- public
   overriding
   function getRuleNames (This : ParserInterpreter) return UString_List
      is (This.ruleNames);

   -- public
   overriding
   function getGrammarFileName (This : ParserInterpreter) return UString
      is (This.grammarFileName);

   -- Begin parsing at startRuleIndex
   -- public
   function parse (This : ParserInterpreter;
                   startRuleIndex : Integer)
                   return ParserRuleContext;

   overriding
   -- public
   procedure enterRecursionRule (This : ParserInterpreter;
                                 localctx : ParserRuleContext;
                                 state : Integer;
                                 ruleIndex : Integer;
                                 precedence : Integer);

   -- internal
   function getATNState (This : ParserInterpreter) return Optional_ATNState
      is (This.atn.states.Elememt (getState));

   -- internal
   procedure visitState (This : ParserInterpreter; p : ATNState);

   -- internal
   procedure visitRuleStopState (This : ParserInterpreter; p : ATNState);

   -- Override this parser interpreters normal decision-making process
   -- at a particular decision and input token index. Instead of
   -- allowing the adaptive prediction mechanism to choose the
   -- first alternative within a block that leads to a successful parse,
   -- force it to take the alternative, 1 .. n for n alternatives.
   --
   -- As an implementation limitation right now, you can only specify one
   -- override. This is sufficient to allow construction of different
   -- parse trees for ambiguous input. It means re-parsing the entire input
   -- in general because you're never sure where an ambiguous sequence would
   -- live in the various parse trees. For example, in one interpretation,
   -- an ambiguous input sequence would be matched completely in expression
   -- but in another it could match all the way back to the root.
   --
   -- s : e '!'? ;
   -- e : ID
   -- | ID '!'
   -- ;
   --
   -- Here, x! can be matched as (s (e ID) !) or (s (e ID !)). In the first
   -- case, the ambiguous sequence is fully contained only by the root.
   -- In the second case, the ambiguous sequences fully contained within just
   -- e, as in: (e ID !).
   --
   -- Rather than trying to optimize this and make
   -- some intelligent decisions for optimization purposes, I settled on
   -- just re-parsing the whole input and then using
   -- {link Trees#getRootOfSubtreeEnclosingRegion} to find the minimal
   -- subtree that contains the ambiguous sequence. I originally tried to
   -- record the call stack at the point the parser detected and ambiguity but
   -- left recursive rules create a parse tree stack that does not reflect
   -- the actual call stack. That impedance mismatch was enough to make
   -- it it challenging to restart the parser at a deeply nested rule
   -- invocation.
   --
   -- Only parser interpreters can override decisions so as to avoid inserting
   -- override checking code in the critical ALL (*) prediction execution path.
   --
   -- public
   procedure addDecisionOverride (This : ParserInterpreter;
                                  decision : Integer;
                                  tokenIndex : Integer;
                                  forcedAlt : Integer);

end ANTLR.Runtime.Parsers.ParserInterpreters;
