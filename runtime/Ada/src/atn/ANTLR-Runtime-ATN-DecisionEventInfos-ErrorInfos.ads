-- €

with Ada.Containers.Vectors;
with ANTLR.Runtime.ATN.States;
with ANTLR.Runtime.ATN.ConfigSets;
with ANTLR.Runtime.TokenStream_Protocol;

use ANTLR.Runtime.ATN.DecisionEventInfos;
use ANTLR.Runtime.ATN.States;
use ANTLR.Runtime.ATN.ConfigSets;
use ANTLR.Runtime.TokenStream_Protocol;

package ANTLR.Runtime.ATN.DecisionEventInfos.ErrorInfos is

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

   subtype Object is ErrorInfo;
   subtype Super is DecisionEventInfo;
   type Class is access all Object;
   type Class_Wide is access all Object'Class;

   function "=" (Left, Right : ErrorInfo) return Boolean;

   package ErrorInfo_Container is new Ada.Containers.Vectors (
      Index_Type => Natural,
      Element_Type => ErrorInfo,
      "=" => "=");
   subtype ErrorInfo_List is ErrorInfo_Container.Vector;


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

end ANTLR.Runtime.ATN.DecisionEventInfos.ErrorInfos;
