-- €

-- 
-- Represents a placeholder tag in a tree pattern. A tag can have any of the
-- following forms.
-- 
-- * `expr`: An unlabeled placeholder for a parser rule `expr`.
-- * `ID`: An unlabeled placeholder for a token of type `ID`.
-- * `e:expr`: A labeled placeholder for a parser rule `expr`.
-- * `id:ID`: A labeled placeholder for a token of type `ID`.
-- 
-- This class does not perform any validation on the tag or label names aside
-- from ensuring that the tag is a non-null, non-empty string.
-- 
-- public
type TagChunk is new Chunk and CustomStringConvertible with null record;
{
    -- 
    -- This is the backing field for _#getTag_.
    -- 
    private tag : constant String;
    -- 
    -- This is the backing field for _#getLabel_.
    -- 
    -- private 
    label : constant String?;

    -- 
    -- Construct a new instance of _org.antlr.v4.runtime.tree.pattern.TagChunk_ using the specified tag and
    -- no label.
    -- 
    -- - Parameter tag: The tag, which should be the name of a parser rule or token
    -- type.
    -- 
    -- - Throws: ANTLRError.illegalArgument if `tag` is `null` or
    -- empty.
    -- 
    -- public convenience
    procedure Init (Self : in out …; tag : String) {
        self.init (null, tag);
    end if;

    -- 
    -- Construct a new instance of _org.antlr.v4.runtime.tree.pattern.TagChunk_ using the specified label
    -- and tag.
    -- 
    -- - Parameter label: The label for the tag. If this is `null`, the
    -- _org.antlr.v4.runtime.tree.pattern.TagChunk_ represents an unlabeled tag.
    -- - Parameter tag: The tag, which should be the name of a parser rule or token
    -- type.
    -- 
    -- - Throws: ANTLRError.illegalArgument if `tag` is `null` or
    -- empty.
    -- 
    -- public 
    procedure Init (Self : in out …; label : Optional_String; tag : String) {

        self.label := label
        self.tag := tag
        super.init ();
        if tag.isEmpty then
            raise ANTLRError.illegalArgument with "tag cannot be null or empty";
        end if;
    end if;

    -- 
    -- Get the tag for this chunk.
    -- 
    -- - Returns: The tag for the chunk.
    -- 
    -- public final
    function getTag (This : …) return String is
begin
        return tag
    end if;

    -- 
    -- Get the label, if any, assigned to this chunk.
    -- 
    -- - Returns: The label assigned to this chunk, or `null` if no label is
    -- assigned to the chunk.
    -- 
    -- public final
    function getLabel () return Optional_String is
   begin
        return label
    end if;

    -- 
    -- This method returns a text representation of the tag chunk. Labeled tags
    -- are returned in the form `label:tag`, and unlabeled tags are
    -- returned as just the tag name.
    -- 
    -- public
    description : String;
    function Image return UString is
        if label : constant := label then
            return "" & label'Image & ":" & tag'Image & ""
        else
            return tag;
        end if;
    end if;


    -- override public
    function isEqual (other : Chunk) return Boolean is
begin
        other : constant TagChunk := TagChunk (other);
        if not Is_Valid (other) then
            return False;
        end if;
        return tag = other.tag and then label = other.label
    end if;
end if;
