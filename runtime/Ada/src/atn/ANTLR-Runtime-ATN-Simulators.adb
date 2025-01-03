-- €

with ANTLR.Runtime.ATN.PredictionContext;

use ANTLR.Runtime.ATN;

package body ANTLR.Runtime.ATN.Simulators is

   procedure Initialize (Self : in out ATNSimulator;
                   atn : ATN;
                   sharedContextCache : PredictionContextCache) is
   begin
      self.atn := atn;
      self.sharedContextCache := sharedContextCache;
   end Initialize;

   procedure reset (This : ATNSimulator) is
   begin
      raise PROGRAM_ERROR with "ANTLR.Runtime.ATN.Simulators.reset() must be overridden";
   end reset;

   procedure clearDFA (This : ATNSimulator) is
   begin
      raise ANTLRError.unsupportedOperation with "This ATN simulator does not support clearing the DFA. ";
   end clearDFA;

   function getCachedContext (This : ATNSimulator; context : PredictionContext) return PredictionContext is
   begin
      --TODO: synced (sharedContextCache!);
      --synced (sharedContextCache!) {
      visited := PredictionContext.Map2.Vector; -- := PredictionContext.Map2.Empty_Vector;
      return PredictionContext.getCachedContext (
               context,
               This.sharedContextCache,
               visited);
   end getCachedContext;

end ANTLR.Runtime.ATN.Simulators;