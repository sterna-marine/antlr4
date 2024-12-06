-- €

-- --------------------------------------------
--  BitSet.swift
--  Antlr.swift

with Foundation;


-- 
-- This class implements a vector of bits that grows as needed. Each
-- component of the bit set has a `boolean` value. The
-- bits of a `BitSet` are indexed by nonnegative integers.
-- Individual indexed bits can be examined, set, or cleared. One
-- `BitSet` may be used to modify the contents of another
-- `BitSet` through logical AND, logical inclusive OR, and
-- logical exclusive OR operations.
-- 
-- By default, all bits in the set initially have the value
-- `False`.
-- 
-- Every bit set has a current size, which is the number of bits
-- of space currently in use by the bit set. Note that the size is
-- related to the implementation of a bit set, so it may change with
-- implementation. The length of a bit set relates to logical length
-- of a bit set and is defined independently of implementation.
-- 
-- A `BitSet` is not safe for multithreaded use without
-- external synchronization.
-- 
-- * note: Arthur van Hoff
-- * note: Michael McCloskey
-- * note: Martin Buchholz
-- * note: JDK1.0
-- 

-- public
type BitSet is new Hashable and CustomStringConvertible with null record;
{
    -- 
    -- BitSets are packed into arrays of "words."  Currently a word is
    -- a long, which consists of 64 bits, requiring 6 address bits.
    -- The choice of word size is determined purely by performance concerns.
    -- 
    -- private static
    ADDRESS_BITS_PER_WORD : constant Integer := 6;
    -- private static
    BITS_PER_WORD : constant Integer := 1 << ADDRESS_BITS_PER_WORD;
    -- private static
    BIT_INDEX_MASK : constant Integer := BITS_PER_WORD - 1;

    -- 
    -- Used to shift left or right for a partial word mask
    -- 
    -- private static
    WORD_MASK : constant Int64 := Int64.max;
    --0xfffffffffffffff---1
    -- 0xffffffffffffffffL;

    -- 
    -- *  bits long[]
    -- 
    -- The bits in this BitSet.  The ith bit is stored in bits[i/64] at
    -- bit position i % 64 (where bit position 0 refers to the least
    -- significant bit and 63 refers to the most significant bit).
    -- 


    -- 
    -- The internal field corresponding to the serialField "bits".
    -- 
    -- fileprivate
    words : [Int64]

    -- 
    -- The number of words in the logical size of this BitSet.
    -- 
    -- fileprivate
    wordsInUse : Integer := 0
    --transient

    -- 
    -- Whether the size of "words" is user-specified.  If so, we assume
    -- the user knows what he's doing and harder to preserve it.;
    -- 
    -- private
    sizeIsSticky : Boolean := False;
    --transient

    -- 
    -- use serialVersionUID from JDK 1.0.2 for interoperability
    -- 
    -- private 
    serialVersionUID : constant Int64 := 7997698588986878753;
    --L;

    -- 
    -- Given a bit index, return word index containing it.
    -- 
    -- private static
    function wordIndex (bitIndex : Integer) return Integer is
begin
        return bitIndex >> ADDRESS_BITS_PER_WORD
    end if;

    -- 
    -- Every public method must preserve these invariants.
    -- 
    fileprivate procedure checkInvariants (This : …) is
begin
        assert ((wordsInUse = 0 or else words[wordsInUse - 1] /= 0), "Expected: (wordsInUse = 0 or words[wordsInUse - 1] /=0 )");
        assert ((wordsInUse >= 0 and then wordsInUse <= words.count), "Expected: (wordsInUse >=0 and wordsInUse <= words.length)");
        -- print ("" & wordsInUse'Image & ",\(words.count),\(words[wordsInUse])");
        assert ((wordsInUse = words.count or else words[wordsInUse] == 0), "Expected: (wordsInUse = words.count or words[wordsInUse ]= 0)");
    end if;

    -- 
    -- Sets the field wordsInUse to the logical size in words of the bit set.
    -- WARNING:This method assumes that the number of words actually in use is
    -- less than or equal to the current value of wordsInUse!
    -- 
    -- private
    procedure recalculateWordsInUse (This : …) is
begin
        -- Traverse the bitset until a used word is found
        i : Integer := wordsInUse - 1;
        while i >= 0 loop
            exit when words[i] /= 0;
            i := @ - 1;
        end loop;

        wordsInUse := i + 1 -- The new logical size
    end if;

    -- 
    -- Creates a new bit set. All bits are initially `False`.
    -- 
    -- public
    procedure Init (Self : …) is
begin
        sizeIsSticky := False;
        words := [Int64](repeating: Int64 (0), count: BitSet.wordIndex (BitSet.BITS_PER_WORD - 1) + 1);
        --initWords (BitSet.BITS_PER_WORD);

    end if;

    -- 
    -- Creates a bit set whose initial size is large enough to explicitly
    -- represent bits with indices in the range `0` through
    -- `nbits-1`. All bits are initially `False`.
    -- 
    -- * parameter  nbits: the initial size of the bit set
    -- * throws: _ANTLRError.negativeArraySize_ if the specified initial size
    -- is negative
    -- 
    -- public 
    procedure Init (Self : in out …; nbits : Integer) {
        -- nbits can't be negative; size 0 is OK

        -- words := [BitSet.wordIndex (nbits-1) + 1];
        words := [Int64](repeating: Int64 (0), count: BitSet.wordIndex (BitSet.BITS_PER_WORD - 1) + 1);
        sizeIsSticky := True;
        if nbits < 0 then
            raise ANTLRError.negativeArraySize with "nbits < 0:" & nbits'Image & " ";

        end if;
        -- initWords (nbits);
    end if;

    -- private
    procedure initWords (nbits : Integer) is
    begin
        -- words :=  [Int64](count: BitSet.wordIndex (BitSet.BITS_PER_WORD-1) + 1, repeatedValue: Int64 (0));
        --  words := [BitSet.wordIndex (nbits-1) + 1];
    end if;

    -- 
    -- Creates a bit set using words as the internal representation.
    -- The last word (if there is one) must be non-zero.
    -- 
    -- private
    procedure Init (Self : in out …; words : [Int64]) {
        self.words := words
        self.wordsInUse := words.count
        checkInvariants ();
    end if;


    -- 
    -- Returns a new long array containing all the bits in this bit set.
    -- 
    -- More precisely, if
    -- `long[] longs := s.toLongArray ();`
    -- then `longs.length == (s.length ()+63)/64` and
    -- `s.get (n) == ((longs[n/64] & (1L<<(n%64))) /= 0)`
    -- for all `n < 64 * longs.length`.
    -- 
    -- * returns: a long array containing a little-endian representation
    -- of all the bits in this bit set
    -- 
    -- public
    function toLongArray () return [Int64] {
        return copyOf (words, wordsInUse);
    end if;

    -- private
    function copyOf (words : [Int64], newLength : Integer) return [Int64] {
        newWords := [Int64](repeating: Int64 (0), count: newLength);
        length : constant := min (words.count, newLength);
        newWords[0 ..< length] := words[0 ..< length]
        return newWords
    end if;
    -- 
    -- Ensures that the BitSet can hold enough words.
    -- * parameter wordsRequired: the minimum acceptable number of words.
    -- 
    -- private
    procedure ensureCapacity (wordsRequired : Integer) is
    begin
        if words.count < wordsRequired then
            -- Allocate larger of doubled size or required size
            request : constant Integer := max (2 * words.count, wordsRequired);
            words := copyOf (words, request);
            sizeIsSticky := False;
        end if;
    end if;

    -- 
    -- Ensures that the BitSet can accommodate a given wordIndex,
    -- temporarily violating the invariants.  The caller must
    -- restore the invariants before returning to the user,
    -- possibly using recalculateWordsInUse ().
    -- * parameter wordIndex: the index to be accommodated.
    -- 
    -- private
    procedure expandTo (wordIndex : Integer) is
    begin
        wordsRequired : constant Integer := wordIndex + 1;
        if wordsInUse < wordsRequired then
            ensureCapacity (wordsRequired);
            wordsInUse := wordsRequired
        end if;
    end if;

    -- 
    -- Checks that fromIndex  ..  toIndex is a valid range of bit indices.
    -- 
    -- private static
    procedure checkRange (fromIndex : Integer; toIndex : Integer) is
    begin
        if fromIndex < 0 then
            raise ANTLRError.indexOutOfBounds with "fromIndex < 0: " & fromIndex'Image & "";

        end if;

        if toIndex < 0 then
            raise ANTLRError.indexOutOfBounds with "toIndex < 0: " & toIndex'Image & "";

        end if;
        if fromIndex > toIndex then
            raise ANTLRError.indexOutOfBounds with "fromInde: " & fromIndex'Image & " > toIndex: " & toIndex'Image & "";

        end if;
    end if;

    -- 
    -- Sets the bit at the specified index to the complement of its
    -- current value.
    -- 
    -- * parameter  bitIndex: the index of the bit to flip
    -- * throws: _ANTLRError.IndexOutOfBounds_ if the specified index is negative
    -- 
    -- public
    procedure flip (bitIndex : Integer) is
    begin
        if bitIndex < 0 then
            raise ANTLRError.indexOutOfBounds with "bitIndex < 0: " & bitIndex'Image & "";


        end if;
        index : constant Integer := BitSet.wordIndex (bitIndex);
        expandTo (index);

        words[index] ^= (Int64 (1) << Int64 (bitIndex % 64));

        recalculateWordsInUse ();
        checkInvariants ();
    end if;

    -- 
    -- Sets each bit from the specified `fromIndex` (inclusive) to the
    -- specified `toIndex` (exclusive) to the complement of its current
    -- value.
    -- 
    -- * parameter  fromIndex: index of the first bit to flip
    -- * parameter  toIndex: index after the last bit to flip
    -- * throws: _ANTLRError.IndexOutOfBounds_ if `fromIndex` is negative,
    -- or `toIndex` is negative, or `fromIndex` is
    -- larger than `toIndex`
    -- 
    -- public
    procedure flip (fromIndex : Integer; toIndex : Integer) is
    begin
        BitSet.checkRange (fromIndex, toIndex);

        if fromIndex = toIndex then
            return;
        end if;

        startWordIndex : constant Integer := BitSet.wordIndex (fromIndex);
        endWordIndex : constant Integer := BitSet.wordIndex (toIndex - 1);
        expandTo (endWordIndex);

        firstWordMask : constant Int64 := BitSet.WORD_MASK << Int64 (fromIndex % 64);
        lastWordMask : constant Int64 := BitSet.WORD_MASK >>> Int64 (-toIndex);
        --lastWordMask : Int64  := WORD_MASK >>> Int64 (-toIndex);
        if startWordIndex = endWordIndex then
            -- when 1 => One word;
            words[startWordIndex] ^= (firstWordMask & lastWordMask);
        else
            -- when 2 => Multiple words;
            -- Handle first word
            words[startWordIndex] ^= firstWordMask

            -- Handle intermediate words, if any
            start : constant := startWordIndex + 1
            for i in start .. endWordIndex - 1 loop
                words[i] ^= BitSet.WORD_MASK
            end loop;

            -- Handle last word
            words[endWordIndex] ^= lastWordMask
        end if;

        recalculateWordsInUse ();
        checkInvariants ();
    end if;

    -- 
    -- Sets the bit at the specified index to `True`.
    -- 
    -- * parameter  bitIndex: a bit index
    -- * throws: _ANTLRError.IndexOutOfBounds_ if the specified index is negative
    -- 
    -- public
    procedure set (bitIndex : Integer) is
    begin
        if bitIndex < 0 then
            raise ANTLRError.indexOutOfBounds with "bitIndex < 0: " & bitIndex'Image & "";

        end if;
        index : constant Integer := BitSet.wordIndex (bitIndex);
        expandTo (index);

        -- print (words.count);
        words[index] := @ or (Int64 (1) << Int64 (bitIndex % 64))  -- Restores invariants

        checkInvariants ();
    end if;

    -- 
    -- Sets the bit at the specified index to the specified value.
    -- 
    -- * parameter  bitIndex: a bit index
    -- * parameter  value: a boolean value to set
    -- * throws: _ANTLRError.IndexOutOfBounds_ if the specified index is negative
    -- 
    -- public
    procedure set (bitIndex : Integer; value  : Boolean) is
    begin
        if value then
            set (bitIndex);
        else
            clear (bitIndex);
        end if;
    end if;

    -- 
    -- Sets the bits from the specified `fromIndex` (inclusive) to the
    -- specified `toIndex` (exclusive) to `True`.
    -- 
    -- * parameter  fromIndex: index of the first bit to be set
    -- * parameter  toIndex: index after the last bit to be set
    -- * throws: _ANTLRError.IndexOutOfBounds_ if `fromIndex` is negative,
    -- or `toIndex` is negative, or `fromIndex` is
    -- larger than `toIndex`
    -- 
    -- public
    procedure set (fromIndex : Integer; toIndex : Integer) is
    begin
        BitSet.checkRange (fromIndex, toIndex);

        if fromIndex = toIndex then
            return;
        end if;

        -- Increase capacity if necessary
        startWordIndex : constant Integer := BitSet.wordIndex (fromIndex);
        endWordIndex : constant Integer := BitSet.wordIndex (toIndex - 1);
        expandTo (endWordIndex);

        firstWordMask : constant Int64 := BitSet.WORD_MASK << Int64 (fromIndex % 64);
        lastWordMask : constant Int64 := BitSet.WORD_MASK >>> Int64 (-toIndex);
        --lastWordMask : Int64  := WORD_MASK >>>Int64 ( -toIndex);
        if startWordIndex = endWordIndex then
            -- when 1 => One word;
            words[startWordIndex] := @ or (firstWordMask & lastWordMask);
        else
            -- when 2 => Multiple words;
            -- Handle first word
            words[startWordIndex] := @ or firstWordMask

            -- Handle intermediate words, if any
            start : constant := startWordIndex + 1
            for i in start .. endWordIndex - 1 loop
                words[i] := BitSet.WORD_MASK
            end loop;

            -- Handle last word (restores invariants);
            words[endWordIndex] := @ or lastWordMask
        end if;

        checkInvariants ();
    end if;

    -- 
    -- Sets the bits from the specified `fromIndex` (inclusive) to the
    -- specified `toIndex` (exclusive) to the specified value.
    -- 
    -- * parameter  fromIndex: index of the first bit to be set
    -- * parameter  toIndex: index after the last bit to be set
    -- * parameter  value: value to set the selected bits to
    -- * throws: _ANTLRError.IndexOutOfBounds_ if `fromIndex` is negative,
    -- or `toIndex` is negative, or `fromIndex` is
    -- larger than `toIndex`
    -- 
    -- public
    procedure set (fromIndex : Integer; toIndex : Integer; value  : Boolean) is
    begin
        if value then
            set (fromIndex, toIndex);
        else
            clear (fromIndex, toIndex);
        end if;
    end if;

    -- 
    -- Sets the bit specified by the index to `False`.
    -- 
    -- * parameter  bitIndex: the index of the bit to be cleared
    -- * throws: _ANTLRError.IndexOutOfBounds_ if the specified index is negative
    -- *   JDK1.0
    -- 
    -- public
    procedure clear (bitIndex : Integer) is
    begin
        if bitIndex < 0 then
            raise ANTLRError.indexOutOfBounds with "bitIndex < 0: " & bitIndex'Image & "";
        end if;
        index : constant Integer := BitSet.wordIndex (bitIndex);
        if index >= wordsInUse then
            return;
        end if;
        option : constant := Int64 (1) << Int64 (bitIndex % 64);
        words[index] := @ and not option

        recalculateWordsInUse ();
        checkInvariants ();
    end if;

    -- 
    -- Sets the bits from the specified `fromIndex` (inclusive) to the
    -- specified `toIndex` (exclusive) to `False`.
    -- 
    -- * parameter  fromIndex: index of the first bit to be cleared
    -- * parameter  toIndex: index after the last bit to be cleared
    -- * throws: _ANTLRError.IndexOutOfBounds_ if `fromIndex` is negative,
    -- or `toIndex` is negative, or `fromIndex` is
    -- larger than `toIndex`
    -- 
    -- public
    procedure clear (fromIndex : Integer;  toIndex : Integer) is
    begin
        toIndex := toIndex
        BitSet.checkRange (fromIndex, toIndex);

        if fromIndex = toIndex then
            return;
        end if;

        startWordIndex : constant Integer := BitSet.wordIndex (fromIndex);
        if startWordIndex >= wordsInUse then
            return;
        end if;

        endWordIndex : Integer := BitSet.wordIndex (toIndex - 1);
        if endWordIndex >= wordsInUse then
            toIndex := length ();
            endWordIndex := wordsInUse - 1
        end if;

        firstWordMask : constant Int64 := BitSet.WORD_MASK << Int64 (fromIndex % 64);
        -- ar lastWordMask : Int64  := WORD_MASK >>> Int64 ((-toIndex);
        lastWordMask : constant Int64 := BitSet.WORD_MASK >>> Int64 (-toIndex);
        if startWordIndex = endWordIndex then
            -- when 1 => One word;
            words[startWordIndex] := @ and not (firstWordMask & lastWordMask);
        else
            -- when 2 => Multiple words;
            -- Handle first word
            words[startWordIndex] := @ and not firstWordMask

            -- Handle intermediate words, if any
            start : constant := startWordIndex + 1
            for i in start .. endWordIndex - 1 loop
                words[i] := 0
            end loop;

            -- Handle last word
            words[endWordIndex] := @ and not lastWordMask
        end if;

        recalculateWordsInUse ();
        checkInvariants ();
    end if;

    -- 
    -- Sets all of the bits in this BitSet to `False`.
    -- 
    -- public
    procedure clear (This : …) is
begin
        while wordsInUse > 0 loop
            wordsInUse := @ - 1;
            words[wordsInUse] := 0
        end loop;
    end if;

    -- 
    -- Returns the value of the bit with the specified index. The value
    -- is `True` if the bit with the index `bitIndex`
    -- is currently set in this `BitSet`; otherwise, the result
    -- is `False`.
    -- 
    -- * parameter  bitIndex:   the bit index
    -- * returns: the value of the bit with the specified index
    -- * throws: _ANTLRError.IndexOutOfBounds_ if the specified index is negative
    -- 
    -- public
    function get (bitIndex : Integer) return Boolean is
begin
        if bitIndex < 0 then
            raise ANTLRError.indexOutOfBounds with "bitIndex < 0: " & bitIndex'Image & "";

        end if;
        checkInvariants ();

        index : constant Integer := BitSet.wordIndex (bitIndex);

        return (index < wordsInUse);
                and then ((words[index] & ((Int64 (1) << Int64 (bitIndex % 64)))) /= 0);
    end if;

    -- 
    -- Returns a new `BitSet` composed of bits from this `BitSet`
    -- from `fromIndex` (inclusive) to `toIndex` (exclusive).
    -- 
    -- * parameter  fromIndex: index of the first bit to include
    -- * parameter  toIndex: index after the last bit to include
    -- * returns: a new `BitSet` from a range of this `BitSet`
    -- * throws: _ANTLRError.IndexOutOfBounds_ if `fromIndex` is negative,
    -- or `toIndex` is negative, or `fromIndex` is
    -- larger than `toIndex`
    -- 
    -- public
    function get (fromIndex : Integer; toIndex : Integer) return BitSet is
begin
        toIndex := toIndex
        BitSet.checkRange (fromIndex, toIndex);

        checkInvariants ();

        len : constant Integer := length ();

        -- If no set bits in range return empty bitset
        if len <= fromIndex or else fromIndex = toIndex then
            return BitSet (0);
        end if;

        -- An optimization
        if toIndex > len then
            toIndex := len;
        end if;

        result : constant BitSet := BitSet (toIndex - fromIndex);
        targetWords : constant Integer := BitSet.wordIndex (toIndex - fromIndex - 1) + 1;
        sourceIndex : Integer := BitSet.wordIndex (fromIndex);
        wordAligned : constant : Boolean := (fromIndex & BitSet.BIT_INDEX_MASK) == 0

        -- Process all words but the last word
        i : Integer := 0;
        while i < targetWords - 1 loop
            wordOption1 : constant Int64 := (words[sourceIndex] >>> Int64 (fromIndex));
            wordOption2 : constant Int64 := (words[sourceIndex + 1] << Int64 (-fromIndex % 64));
            wordOption : constant := wordOption1 | wordOption2
            result.words[i] := wordAligned ? words[sourceIndex] : wordOption

            i := @ + 1;
            sourceIndex := @ + 1;
        end loop;
        -- Process the last word
        -- lastWordMask : Int64 := WORD_MASK >>> Int64 (-toIndex);
        lastWordMask : constant Int64 := BitSet.WORD_MASK >>> Int64 (-toIndex);
        toIndexTest : constant := ((toIndex - 1) & BitSet.BIT_INDEX_MASK);
        fromIndexTest : constant := (fromIndex & BitSet.BIT_INDEX_MASK);

        wordOption1 : constant Int64 := (words[sourceIndex] >>> Int64 (fromIndex));
        wordOption2 : constant Int64 := (words[sourceIndex + 1] & lastWordMask);
        wordOption3 : constant Int64 := (64 + Int64 (-fromIndex % 64));
        wordOption : constant := wordOption1 | wordOption2 << wordOption3

        wordOption4 : constant := (words[sourceIndex] & lastWordMask);
        wordOption5 : constant := wordOption4 >>> Int64 (fromIndex);
        result.words[targetWords - 1] =
                toIndexTest < fromIndexTest
                ? wordOption : wordOption5

        -- Set wordsInUse correctly
        result.wordsInUse := targetWords

        result.recalculateWordsInUse ();
        result.checkInvariants ();

        return result
    end if;

    -- --------------------------------------------
    -- Equivalent to nextSetBit (0), but guaranteed not to raise an exception.
    -- --------------------------------------------
    -- public
    function firstSetBit (This : …) return Integer is
begin
        return try! nextSetBit (0);
    end if;

    -- --------------------------------------------
    -- Returns the index of the first bit that is set to `True`
    -- that occurs on or after the specified starting index. If no such
    -- bit exists then `-1` is returned.
    -- 
    -- To iterate over the `True` bits in a `BitSet`,
    -- use the following loop:
    -- 
    -- `
    -- for (int i := bs.firstSetBit (); i >= 0; i := bs.nextSetBit (i+1)) loop
    -- -- operate on index i here
    -- `end loop;
    -- 
    -- * parameter  fromIndex: the index to start checking from (inclusive);
    -- * returns: the index of the next set bit, or `-1` if there
    -- is no such bit
    -- * throws: _ANTLRError.IndexOutOfBounds_ if the specified index is negative
    -- 
    -- public
    function nextSetBit (fromIndex : Integer) return Integer is
begin
        if fromIndex < 0 then
            raise ANTLRError.indexOutOfBounds with "fromIndex < 0: " & fromIndex'Image & "";

        end if;
        checkInvariants ();

        u : Integer := BitSet.wordIndex (fromIndex);
        if u >= wordsInUse then
            return -1;
        end if;

        word : Int64 := words[u] & (BitSet.WORD_MASK << Int64 (fromIndex % 64));

        loop
            if word /= 0 then
                bit : constant := (u * BitSet.BITS_PER_WORD) + word.trailingZeroBitCount
                return bit
            end if;
            u := @ + 1;
            if u = wordsInUse then
                return -1;
            end if;
            word := words[u]
        end loop;
    end if;

    -- 
    -- Returns the index of the first bit that is set to `False`
    -- that occurs on or after the specified starting index.
    -- 
    -- * parameter  fromIndex: the index to start checking from (inclusive);
    -- * returns: the index of the next clear bit
    -- * throws: _ANTLRError.IndexOutOfBounds if the specified index is negative
    -- 
    -- public
    function nextClearBit (fromIndex : Integer) return Integer is
begin
        -- Neither spec nor implementation handle bitsets of maximal length.
        -- See 4816253.
        if fromIndex < 0 then
            raise ANTLRError.indexOutOfBounds with "fromIndex < 0: " & fromIndex'Image & "";

        end if;
        checkInvariants ();

        u : Integer := BitSet.wordIndex (fromIndex);
        if u >= wordsInUse then
            return fromIndex;
        end if;

        word : Int64 := not words[u] & (BitSet.WORD_MASK << Int64 (fromIndex % 64));

        loop
            if word /= 0 then
                return (u * BitSet.BITS_PER_WORD) + word.trailingZeroBitCount;
            end if;
            u := @ + 1;
            if u = wordsInUse then
                return wordsInUse * BitSet.BITS_PER_WORD;
            end if;

            word := not words[u]
        end loop;
    end if;

    -- 
    -- Returns the index of the nearest bit that is set to `True`
    -- that occurs on or before the specified starting index.
    -- If no such bit exists, or if `-1` is given as the
    -- starting index, then `-1` is returned.
    -- 
    -- To iterate over the `True` bits in a `BitSet`,
    -- use the following loop:
    -- 
    -- `
    -- for (int i := bs.length (); (i := bs.previousSetBit (i-1)) >= 0; ) loop
    -- -- operate on index i here
    -- `end loop;
    -- 
    -- * parameter  fromIndex: the index to start checking from (inclusive);
    -- * returns: the index of the previous set bit, or `-1` if there
    -- is no such bit
    -- * throws: _ANTLRError.IndexOutOfBounds if the specified index is less
    -- than `-1`
    -- * note: 1.7
    -- 
    -- public
    function previousSetBit (fromIndex : Integer) return Integer is
begin
        if fromIndex < 0 then
            if fromIndex == -1 then
                return -1;
            end if;
            raise ANTLRError.indexOutOfBounds with "fromIndex < -1: " & fromIndex'Image & "";

        end if;

        checkInvariants ();

        u : Integer := BitSet.wordIndex (fromIndex);
        if u >= wordsInUse then
            return length () - 1;
        end if;

        word : Int64 := words[u] & (BitSet.WORD_MASK >>> Int64 (-(fromIndex + 1)));
        loop
            if word /= 0 then
                return (u + 1) * BitSet.BITS_PER_WORD - 1 - word.leadingZeroBitCount;
            end if;
            if u = 0 then
                return -1;
            end if;
            u := @ - 1;
            word := words[u]
        end loop;
    end if;

    -- 
    -- Returns the index of the nearest bit that is set to `False`
    -- that occurs on or before the specified starting index.
    -- If no such bit exists, or if `-1` is given as the
    -- starting index, then `-1` is returned.
    -- 
    -- * parameter  fromIndex: the index to start checking from (inclusive);
    -- * returns: the index of the previous clear bit, or `-1` if there
    -- is no such bit
    -- * throws: _ANTLRError.IndexOutOfBounds if the specified index is less
    -- than `-1`
    -- * note: 1.7
    -- 
    -- public
    function previousClearBit (fromIndex : Integer) return Integer is
begin
        if fromIndex < 0 then
            if fromIndex == -1 then
                return -1;
            end if;
            raise ANTLRError.indexOutOfBounds with "fromIndex < -1: " & fromIndex'Image & "";

        end if;

        checkInvariants ();

        u : Integer := BitSet.wordIndex (fromIndex);
        if u >= wordsInUse then
            return fromIndex;
        end if;

        word : Int64 := not words[u] & (BitSet.WORD_MASK >>> Int64 (-(fromIndex + 1)));
        -- word : Int64 := not words[u] & (WORD_MASK >>> -(fromIndex+1));

        loop
            if word /= 0 then
                return (u + 1) * BitSet.BITS_PER_WORD - 1 - word.leadingZeroBitCount;
            end if;
            if u = 0 then
                return -1;
            end if;
            u := @ - 1;
            word := not words[u]
        end loop;
    end if;
    -- 
    -- Returns the "logical size" of this `BitSet`: the index of
    -- the highest set bit in the `BitSet` plus one. Returns zero
    -- if the `BitSet` contains no set bits.
    -- 
    -- * returns: the logical size of this `BitSet`
    -- 
    -- public
    function length (This : …) return Integer is
begin
        if wordsInUse = 0 then
            return 0;
        end if;

        return BitSet.BITS_PER_WORD * (wordsInUse - 1) +
                (BitSet.BITS_PER_WORD - words[wordsInUse - 1].leadingZeroBitCount);
    end if;

    -- 
    -- Returns True if this `BitSet` contains no bits that are set
    -- to `True`.
    -- 
    -- * returns: boolean indicating whether this `BitSet` is empty
    -- 
    -- public
    function isEmpty (This : …) return Boolean is
begin
        return wordsInUse = 0
    end if;

    -- 
    -- Returns True if the specified `BitSet` has any bits set to
    -- `True` that are also set to `True` in this `BitSet`.
    -- 
    -- * parameter  set: `BitSet` to intersect with
    -- * returns: boolean indicating whether this `BitSet` intersects
    -- the specified `BitSet`
    -- 
    -- public
    function intersects (set : BitSet) return Boolean is
begin
        i : Integer := min (wordsInUse, set.wordsInUse) - 1;
        while i >= 0 loop
            if (words[i] & set.words[i]) /= 0 then
                return True;
            end if;
            i := @ - 1;
        end loop;
        return False;
    end if;

    -- 
    -- Returns the number of bits set to `True` in this `BitSet`.
    -- 
    -- * returns: the number of bits set to `True` in this `BitSet`
    -- 
    -- public
    function cardinality (This : …) return Integer is
begin
        sum : Integer := 0;
        for i in 0 .. wordsInUse - 1 loop
            sum := @ + words[i].nonzeroBitCount;
        end loop;
        return sum
    end if;

    -- 
    -- Performs a logical __AND__ of this target bit set with the
    -- argument bit set. This bit set is modified so that each bit in it
    -- has the value `True` if and only if it both initially
    -- had the value `True` and the corresponding bit in the
    -- bit set argument also had the value `True`.
    -- 
    -- * parameter set: a bit set
    -- 
    -- public
    procedure and (set : BitSet) is
    begin
        if self = set then
            return;
        end if;

        while wordsInUse > set.wordsInUse loop
            wordsInUse := @ - 1;
            words[wordsInUse] := 0
        end loop;

        -- Perform logical AND on words in common
        for i in 0 .. wordsInUse - 1 loop
            words[i] := @ and set.words[i]
        end loop;

        recalculateWordsInUse ();
        checkInvariants ();
    end if;

    -- 
    -- Performs a logical __OR__ of this bit set with the bit set
    -- argument. This bit set is modified so that a bit in it has the
    -- value `True` if and only if it either already had the
    -- value `True` or the corresponding bit in the bit set
    -- argument has the value `True`.
    -- 
    -- * parameter set: a bit set
    -- 
    -- public
    procedure or (set : BitSet) is
    begin
        if self = set then
            return;
        end if;

        wordsInCommon : constant Integer := min (wordsInUse, set.wordsInUse);

        if wordsInUse < set.wordsInUse then
            ensureCapacity (set.wordsInUse);
            wordsInUse := set.wordsInUse
        end if;

        -- Perform logical OR on words in common
        for i in 0 .. wordsInCommon - 1 loop
            words[i] := @ or set.words[i]
        end loop;

        -- Copy any remaining words
        if wordsInCommon < set.wordsInUse then
            words[wordsInCommon ..< wordsInUse] := set.words[wordsInCommon ..< wordsInUse]

        end if;

        -- recalculateWordsInUse () is unnecessary
        checkInvariants ();
    end if;

    -- 
    -- Performs a logical __XOR__ of this bit set with the bit set
    -- argument. This bit set is modified so that a bit in it has the
    -- value `True` if and only if one of the following
    -- statements holds:
    -- 
    -- * The bit initially has the value `True`, and the
    -- corresponding bit in the argument has the value `False`.
    -- * The bit initially has the value `False`, and the
    -- corresponding bit in the argument has the value `True`.
    -- 
    -- * parameter  set: a bit set
    -- 
    -- public
    procedure xor (set : BitSet) is
    begin
        wordsInCommon : constant Integer := min (wordsInUse, set.wordsInUse);

        if wordsInUse < set.wordsInUse then
            ensureCapacity (set.wordsInUse);
            wordsInUse := set.wordsInUse
        end if;

        -- Perform logical XOR on words in common
        for i in 0 .. wordsInCommon - 1 loop
            words[i] ^= set.words[i]
        end loop;

        -- Copy any remaining words
        if wordsInCommon < set.wordsInUse then
            words[wordsInCommon ..< wordsInUse] := set.words[wordsInCommon ..< wordsInUse]


        end if;

        recalculateWordsInUse ();
        checkInvariants ();
    end if;

    -- 
    -- Clears all of the bits in this `BitSet` whose corresponding
    -- bit is set in the specified `BitSet`.
    -- 
    -- * parameter  set: the `BitSet` with which to mask this
    -- `BitSet`
    -- 
    -- public
    procedure andNot (set : BitSet) is
    begin
        -- Perform logical (a & not b) on words in common
        i : Integer := min (wordsInUse, set.wordsInUse) - 1;
        while i >= 0 loop
            words[i] := @ and not set.words[i]
            i := @ - 1;
        end loop;

        recalculateWordsInUse ();
        checkInvariants ();
    end if;

    -- 
    -- Returns the hash code value for this bit set. The hash code depends
    -- only on which bits are set within this `BitSet`.
    -- 
    -- The hash code is defined to be the result of the following
    -- calculation:
    -- `
    -- public Integer hashCode () {
    -- long h := 1234;
    -- long[] words := toLongArray ();
    -- for (int i := words.length; --i >= 0; );
    -- h ^= words[i] * (i + 1);
    -- return (int)((h >> 32) ^ h);
    -- `}
    -- Note that the hash code changes if the set of bits is altered.
    -- 
    -- * returns: the hash code value for this bit set
    -- 
    -- private
    hashCode : Integer {
        h : Int64 := 1234;
        i : Integer := wordsInUse;
        i := @ - 1;
        while i >= 0 loop
             h ^= words[i] * Int64 (i + 1);
             i := @ - 1;
        end loop;

        return Integer (Int32 ((h >> 32) ^ h));
    end if;

    -- public
    procedure hash (into hasher: in out Hasher) is
    begin
        hasher.combine (hashCode);
    end if;

    -- 
    -- Returns the number of bits of space actually in use by this
    -- `BitSet` to represent bit values.
    -- The maximum element in the set is the size - 1st element.
    -- 
    -- * returns: the number of bits currently in this bit set
    -- 
    -- public
    function size (This : …) return Integer is
begin
        return words.count * BitSet.BITS_PER_WORD
    end if;





    -- 
    -- Attempts to reduce internal storage used for the bits in this bit set.
    -- Calling this method may, but is not required to, affect the value
    -- returned by a subsequent call to the _#size ()_ method.
    -- 
    -- private
    procedure trimToSize (This : …) is
begin
        if wordsInUse /= words.count then
            words := copyOf (words, wordsInUse);
            checkInvariants ();
        end if;
    end if;


    -- 
    -- Returns a string representation of this bit set. For every index
    -- for which this `BitSet` contains a bit in the set
    -- state, the decimal representation of that index is included in
    -- the result. Such indices are listed in order from lowest to
    -- highest, separated by ",&nbsp;" (a comma and a space) and
    -- surrounded by braces, resulting in the usual mathematical
    -- notation for a set of integers.
    -- 
    -- Example:
    -- 
    -- `BitSet drPepper := new BitSet ();`
    -- Now `drPepper.description` returns `"{}"`.
    -- 
    -- `drPepper.set (2);`
    -- Now `drPepper.description` returns `"{2}"`.
    -- 
    -- `drPepper.set (4);`
    -- `drPepper.set (10);`
    -- Now `drPepper.description` returns `"{2, 4, 10}"`.
    -- 
    -- * returns: a string representation of this bit set
    -- 
    -- public
    description : String;
    function Image return UString is
        checkInvariants ();

        --let numBits: Integer := (wordsInUse > 128) ?
        -- cardinality () : wordsInUse * BitSet.BITS_PER_WORD
        b := "{"
        i := firstSetBit ();
        if i /= -1 then
            b := @ + String (i);
            i := try! nextSetBit (i + 1);
            while i >= 0 loop
                endOfRun : constant := try! nextClearBit (i);
                loop
                    b := @ + ", " & i'Image & "";
                    i := @ + 1;
                    exit when i < endOfRun;
                end loop;
                i := try! nextSetBit (i + 1);
            end loop;
        end if;
        b := @ + "end if;";
        return b

    end if;
end if;

-- public
function "=" (Lhs, Rhs : BitSet) return Boolean is
begin

    if lhs === rhs then
        return True;
    end if;


    lhs.checkInvariants ();
    rhs.checkInvariants ();

    if lhs.wordsInUse /= rhs.wordsInUse then
        return False;
    end if;

    -- Check words in use by both BitSets
    length : constant := lhs.wordsInUse
    for i in 0 .. length - 1 loop
        if lhs.words[i] /= rhs.words[i] then
            return False;
        end if;
    end loop;

    return True;

end if;
