-- €

package body ANTLR.Runtime.DefaultErrorStrategies.BailErrorStrategies is

   overriding
   procedure Initialize (Self : in out BailErrorStrategy) is null;

   overriding
   procedure recover (This : BailErrorStrategy;
                      recognizer : Parser;
                      e : RecognitionException) is
      context : Optional_ParserRuleContext := recognizer.getContext;
   begin
      while Is_Valid (context) loop
         context.exception := e;
         context := Optional_ParserRuleContext (contextWrap.getParent);
      end loop;

      raise ANTLRException.parseCancellation with e;
   end recover;

   overriding
   function recoverInline (This : BailErrorStrategy; recognizer : Parser) return Token is
      e : constant := InputMismatchException (recognizer);
      contextWrap : Optional_ParserRuleContext := Set (recognizer.getContext);
   begin
      while Is_Valid (contextWrap) loop
            contextWrap.exception := e;
            contextWrap := Optional_ParserRuleContext (contextWrap.getParent); --TOFIX
      end loop;

      raise ANTLRException.parseCancellation with e;
   end recoverInline;

   overriding
   procedure sync (This : BailErrorStrategy; recognizer : Parser) is null;

end ANTLR.Runtime.DefaultErrorStrategies.BailErrorStrategies;
