-- €

package body ANTLR.Runtime.RecognitionExceptions.NoViableAltExceptions is

    procedure Initialize (Self : in out NoViableAltException; recognizer : Parser) is
        -- LL (1) error
        token : constant Token := recognizer.getCurrentToken; -- try!
    begin
        Self.Initialize (recognizer => recognizer,
                         input => Value (recognizer.getInputStream),
                         startToken => token,
                         offendingToken => token,
                         deadEndConfigs => (Valid => False),
                         ctx => recognizer.ctx);
    end Initialize;

    -- public
    procedure Initialize (Self : in out NoViableAltException;
                          recognizer : Optional_Parser;
                          input : IntStream;
                          startToken : Token;
                          offendingToken : Optional_Token;
                          deadEndConfigs : Optional_ATNConfigSet;
                          ctx : Optional_ParserRuleContext) is
      offendingToken : constant Optional_Token := Maybe (offendingToken);
   begin
      self.deadEndConfigs := deadEndConfigs;
      self.startToken := startToken;
      Super (Self).Initialize (recognizer, input, ctx);
      if Is_Valid (offendingToken) then
         This.setOffendingToken (offendingToken);
      end if;
   end Initialize;

end ANTLR.Runtime.RecognitionExceptions.NoViableAltExceptions;
