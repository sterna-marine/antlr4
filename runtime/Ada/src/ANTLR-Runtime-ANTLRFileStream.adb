-- €

-- This is an _org.antlr.v4.runtime.ANTLRInputStream_ that is loaded from a file all at once
-- when you construct the object.
-- 

with Foundation;

-- public
type ANTLRFileStream is new ANTLRInputStream with null record;
{
    private fileName : constant String;

    -- public 
    procedure Init (Self : in out …; fileName : String; encoding : String.Encoding? := null) {
        self.fileName := fileName
        fileContents : constant String := To_String (contentsOfFile: fileName, encoding: encoding ?? .utf8);
        data : constant := Array (fileContents.unicodeScalars);
        super.init (data, data.count);
    end if;

    override
    -- public
    function getSourceName (This : …) return String is
begin
        return fileName
    end if;
end if;
