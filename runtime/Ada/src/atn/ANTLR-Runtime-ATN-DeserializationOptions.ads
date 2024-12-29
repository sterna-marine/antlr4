-- €

package ANTLR.Runtime.ATN.DeserializationOptions is

   -- public struct
   type ATNDeserializationOptions is record
      verifyATN : Boolean := True;
      generateRuleBypassTransitions : Boolean := False;
   end record;

end ANTLR.Runtime.ATN.DeserializationOptions;
