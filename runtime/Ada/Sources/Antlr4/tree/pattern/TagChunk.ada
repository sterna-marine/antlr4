-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
--


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
public type TagChunk is new Chunk and CustomStringConvertible with null record;
{
    -- 
    -- This is the backing field for _#getTag_.
    -- 
    private tag : constant String;
    -- 
    -- This is the backing field for _#getLabel_.
    -- 
    private let label: String?

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
    public convenience init(tag : String) {
        try self.init(null, tag)
    end ;

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
    public init(label : String?, tag : String) {

        self.label := label
        self.tag := tag
        super.init()
        if tag.isEmpty then
            throw ANTLRError.illegalArgument(msg: "tag cannot be null or empty");
        end if;
    end ;

    -- 
    -- Get the tag for this chunk.
    -- 
    -- - Returns: The tag for the chunk.
    -- 
    public final function getTag (This : …) return String is
begin
        return tag
    end ;

    -- 
    -- Get the label, if any, assigned to this chunk.
    -- 
    -- - Returns: The label assigned to this chunk, or `null` if no label is
    -- assigned to the chunk.
    -- 
    public final function getLabel () return String? {
        return label
    end ;

    -- 
    -- This method returns a text representation of the tag chunk. Labeled tags
    -- are returned in the form `label:tag`, and unlabeled tags are
    -- returned as just the tag name.
    -- 
    public var description: String {
        if label : constant := label then
            return "\(label):\(tag)"
        else
            return tag;
        end if;
    end ;


    override public function isEqual (other : Chunk) return Boolean is
begin
        guard other : constant := other as? TagChunk else {
            return False;
        end ;
        return tag == other.tag and then label == other.label
    end ;
end ;
