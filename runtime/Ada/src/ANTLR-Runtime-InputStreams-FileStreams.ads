-- €

package ANTLR.Runtime.InputStreams.FileStreams is

   -- This is an _org.antlr.v4.runtime.ANTLRInputStream_ that is loaded from a file all at once
   -- when you construct the object.
   --

   -- public
   type ANTLRFileStream is new ANTLRInputStream with
   record
      -- private 
      fileName : constant UString;
   end record;

   subtype Object is ANTLRFileStream;
   subtype Super is ANTLRInputStream;
   type Class is access all Object;
   type Class_Wide is access all Object'Class;

   -- public
   procedure Initialize (Self : in out ANTLRFileStream;
                         fileName : UString;
                         encoding : Optional_String.Encoding := (Valid => False));

   -- public
   overriding
   function getSourceName (This : ANTLRFileStream) return UString
      is (This.fileName);

end ANTLR.Runtime.InputStreams.FileStreams;
