-- €

-- This is an _org.antlr.v4.runtime.ANTLRInputStream_ that is loaded from a file all at once
-- when you construct the object.
--

with Foundation;

-- public
type ANTLRFileStream is new ANTLRInputStream with null record;
{
    private fileName : constant UString;

    -- public
    procedure Initialize (Self : in out …; fileName : UString; encoding : Optional_String.Encoding := (Valid => False)) {
        self.fileName := fileName
        fileContents : constant UString := To_String (contentsOfFile => fileName, encoding => encoding, Default => .utf8);
        data : constant := array (<>) of fileContents.unicodeScalars;
        Super (Self).Initialize (data, data.count);
    end if;

    overriding
    -- public
    function getSourceName (This : …) return UString is
begin
        return fileName
    end if;
end if;
