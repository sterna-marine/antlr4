-- €

package ANTLR.Runtime.Misc.Exceptions.Errors is

   -- public
   package ANTLRError is
      unsupportedOperation : exception; -- (msg:String);
      indexOutOfBounds : exception; -- (msg:String);
      illegalState : exception; -- (msg:String);
      illegalArgument : exception; -- (msg:String);
      negativeArraySize : exception; -- (msg:String);
   end ANTLRError;

end ANTLR.Runtime.Misc.Exceptions.Errors;