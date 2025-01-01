-- €

package ANTLR.Runtime.Misc.Exceptions.Errors is

   -- public
   ANTLRError : exception; -- : Error { … }
   unsupportedOperation : exception; -- (msg:String);
   indexOutOfBounds : exception;, -- (msg:String);
   illegalState : exception; -- (msg:String);
   illegalArgument : exception; -- (msg:String);
   negativeArraySize : exception; -- (msg:String);

end ANTLR.Runtime.Misc.Exceptions.ANTLRErrors;