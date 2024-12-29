-- €

package ANTLR.Runtime.ATN.ATNDeserializationOptions is

   -- public struct
   type ATNDeserializationOptions is record
      verifyATN : Boolean := True;
      generateRuleBypassTransitions : Boolean := False;
   end record;

end ANTLR.Runtime.ATN.ATNDeserializationOptions;
