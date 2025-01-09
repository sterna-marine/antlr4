-- €

package body ANTLR.Runtime.InputStreams.FileStreams is

   procedure Initialize (Self : in out ANTLRFileStream;
                         fileName : UString;
                         encoding : Optional_String.Encoding := (Valid => False)) is
   begin   
      self.fileName := fileName;
      fileContents : constant UString := To_String (contentsOfFile => fileName, encoding => encoding, Default => .utf8);
      This.data : constant := array (<>) of fileContents.unicodeScalars;
      Super (Self).Initialize (This.data, This.data.Length);
   end Initialize;

end ANTLR.Runtime.InputStreams.FileStreams;
