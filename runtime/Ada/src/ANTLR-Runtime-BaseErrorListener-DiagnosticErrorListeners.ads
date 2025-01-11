-- €

with ANTLR.Runtime.ATN.ConfigSets;
with ANTLR.Runtime.DFA;
with ANTLR.Runtime.Misc.BitSets;
with ANTLR.Runtime.Parsers;

use ANTLR.Runtime.ATN.ConfigSets;
use ANTLR.Runtime.BaseErrorListener;
use ANTLR.Runtime.DFA;
use ANTLR.Runtime.Misc.BitSets;
use ANTLR.Runtime.Parsers;

package ANTLR.Runtime.BaseErrorListener.DiagnosticErrorListeners is

   --
   -- This implementation of _org.antlr.v4.runtime.ANTLRErrorListener_ can be used to identify
   -- certain potential correctness and performance problems in grammars. "Reports"
   -- are made by calling _org.antlr.v4.runtime.Parser#notifyErrorListeners_ with the appropriate
   -- message.
   --
   -- * __Ambiguities__: These are cases where more than one path through the
   -- grammar can match the input.
   -- * __Weak context sensitivity__: These are cases where full-context
   -- prediction resolved an SLL conflict to a unique alternative which equaled the
   -- minimum alternative of the SLL conflict.
   -- * __Strong (forced) context sensitivity__: These are cases where the
   -- full-context prediction resolved an SLL conflict to a unique alternative,
   -- __and__ the minimum alternative of the SLL conflict was found to not be
   -- a truly viable alternative. Two-stage parsing cannot be used for inputs where
   -- this situation occurs.
   --
   -- *  Sam Harwell
   --

   -- public
   type DiagnosticErrorListener is new BaseErrorListener with
   record
      --
      -- When `True`, only exactly known ambiguities are reported.
      --
      -- internal final
      exactOnly : Boolean;
   end record;

   --
   -- Initializes a new instance of _org.antlr.v4.runtime.DiagnosticErrorListener_ which only
   -- reports exact ambiguities.
   --
   -- public convenience
   overriding
   procedure Initialize (Self : in out DiagnosticErrorListener);

   --
   -- Initializes a new instance of _org.antlr.v4.runtime.DiagnosticErrorListener_, specifying
   -- whether all ambiguities or only exact ambiguities are reported.
   --
   -- * parameter exactOnly: `True` to report only exact ambiguities, otherwise
   -- `False` to report all ambiguities.
   --
   -- public
   procedure Initialize (Self : in out DiagnosticErrorListener; exactOnly  : Boolean);

   -- public
   overriding
   procedure reportAmbiguity (This : DiagnosticErrorListener; 
                              recognizer : Parser;
                              dfa : DFA;
                              startIndex, stopIndex : Integer;
                              exact : Boolean;
                              ambigAlts : BitSet;
                              configs : ATNConfigSet);

   -- public
   overriding
   procedure reportAttemptingFullContext (This : DiagnosticErrorListener;
                                          recognizer : Parser;
                                          dfa : DFA;
                                          startIndex, stopIndex : Integer;
                                          conflictingAlts : Optional_BitSet;
                                          configs : ATNConfigSet);

   -- public
   overriding
   procedure reportContextSensitivity (This : DiagnosticErrorListener;
                                       recognizer : Parser;
                                       dfa : DFA;
                                       startIndex, stopIndex : Integer;
                                       prediction : Integer;
                                       configs : ATNConfigSet);

   -- internal
   function getDecisionDescription (This : DiagnosticErrorListener;
                                    recognizer : Parser;
                                    dfa : DFA)
                                    return UString;

   --
   -- Computes the set of conflicting or ambiguous alternatives from a
   -- configuration set, if that information was not already provided by the
   -- parser.
   --
   -- * parameter reportedAlts: The set of conflicting or ambiguous alternatives, as
   -- reported by the parser.
   -- * parameter configs: The conflicting or ambiguous configuration set.
   -- * returns: Returns `reportedAlts` if it is not `null`, otherwise
   -- returns the set of alternatives represented in `configs`.
   --
   -- internal
   function getConflictingAlts (This : DiagnosticErrorListener;
                                reportedAlts : Optional_BitSet;
                                configs : ATNConfigSet)
                                return BitSet;

   -- fileprivate
   function getTextInInterval (recognizer : Parser;
                               startIndex, stopIndex : Integer)
                               return UString;

end ANTLR.Runtime.BaseErrorListener.DiagnosticErrorListeners;
