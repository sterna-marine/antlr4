-- €

package ANTLR.Runtime.ATN.ErrorInfo is

   --
   -- This class represents profiling event information for a syntax error
   -- identified during prediction. Syntax errors occur when the prediction
   -- algorithm is unable to identify an alternative which would lead to a
   -- successful parse.
   --
   -- * seealso: org.antlr.v4.runtime.Parser#notifyErrorListeners (org.antlr.v4.runtime.Token, UString, org.antlr.v4.runtime.RecognitionException);
   -- * seealso: org.antlr.v4.runtime.ANTLRErrorListener#syntaxError
   --

   -- public
   type ErrorInfo is new DecisionEventInfo with null record;

   --
   -- Constructs a new instance of the _org.antlr.v4.runtime.atn.ErrorInfo_ class with the
   -- specified detailed syntax error information.
   --
   -- * parameter decision: The decision number
   -- * parameter configs: The final configuration set reached during prediction
   --   prior to reaching the _org.antlr.v4.runtime.atn.ATNSimulator#ERROR_ state
   -- * parameter input: The input token stream
   -- * parameter startIndex: The start index for the current prediction
   -- * parameter stopIndex: The index at which the syntax error was identified
   -- * parameter fullCtx: `True` if the syntax error was identified during LL
   --   prediction; otherwise, `False` if the syntax error was identified
   --   during SLL prediction
   --

   -- public
   procedure Initialize (Self : in out ErrorInfo;
                   decision : State;
                   configs : ATNConfigSet;
                   input : TokenStream;
                   startIndex : Integer;
                   stopIndex : Integer;
                   fullCtx  : Boolean);

end ANTLR.Runtime.ATN.ErrorInfo;
