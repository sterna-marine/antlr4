-- €

--
-- Represents a span of raw text (concrete syntax) between tags in a tree
-- pattern string.
--

-- public
type TextChunk is new Chunk with null record;
{
    --
    -- This is the backing field for _#getText_.
    --

    private text : constant UString;

    --
    -- Constructs a new instance of _org.antlr.v4.runtime.tree.pattern.TextChunk_ with the specified text.
    --
    -- * Parameter text: The text of this chunk.
    -- * Throws: ANTLRError.illegalArgument if `text` is `null`.
    --
    -- public
    procedure Initialize (Self : in out …; text : UString) {
        self.text := text
    end if;

    --
    -- Gets the raw text of this chunk.
    --
    -- * Returns: The text of the chunk.
    --

    -- public final
    function getText (This : …) return UString is
begin
        return text
    end if;

    --
    -- The implementation for _org.antlr.v4.runtime.tree.pattern.TextChunk_ returns the result of
    -- _#getText ()_ in single quotes.
    --
    -- public
    subtype Sink is Ada.Strings.Text_Buffers.Root_Buffer_Type;
    procedure Put_Image_… (S : in out Sink'Class; X : …);
    for …'Put_Image use Put_Image_…;
    function Description (This : …) return UString is
        return "'" & text'Image & '''
    end if;


    -- override public
    function isEqual (other : Chunk) return Boolean is
begin
        other : constant TextChunk := TextChunk (other);
        if not Is_Valid (other) then
            return False;
        end if;
        return text = other.text
    end if;
end if;
