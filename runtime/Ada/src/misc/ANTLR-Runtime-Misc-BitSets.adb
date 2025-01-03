-- €

package body ANTLR.Runtime.Misc.BitSets is

   function Hash (Key : Integer) return Ada.Containers.Hash_Type is
   begin
      return 0; --TOFIX
   end Hash;

   function "=" (Left, Right : BitSet) return Boolean is
   begin
      return Left = Right; --TOFIX
   end "=";

    --
    -- Given a bit index, return word index containing it.
    --
    -- private static
   function wordIndex (bitIndex : Integer) return Integer
      is (Shift_Right (bitIndex, ADDRESS_BITS_PER_WORD));

   --
   -- Every public method must preserve these invariants.
   --
   -- fileprivate
   procedure checkInvariants (This : BitSet) is
   begin
      pragma assert ((This.wordsInUse = 0 or else This.words.Element (This.wordsInUse - 1) /= 0), "Expected: (wordsInUse = 0 or words.Element (wordsInUse - 1) /=0)");
      pragma assert ((This.wordsInUse >= 0 and then This.wordsInUse <= This.words.Length), "Expected: (wordsInUse >= 0 and wordsInUse <= words.Length)");
      -- Text_IO.Put_Line ("" & wordsInUse'Image & "," & This.words.Length)," & words.Element (wordsInUse));
      pragma assert ((This.wordsInUse = This.words.Length or else This.words.Element (This.wordsInUse) == 0), "Expected: (wordsInUse = words.Length or words.Element (wordsInUse) = 0)");
   end checkInvariants;

   --
   -- Sets the field wordsInUse to the logical size in words of the bit set.
   -- WARNING:This method assumes that the number of words actually in use is
   -- less than or equal to the current value of wordsInUse!
   --
   -- private
   procedure recalculateWordsInUse (This : in out BitSet) is
   begin
      -- Traverse the bitset until a used word is found
      i : Integer := This.wordsInUse - 1;
      while i >= 0 loop
         exit when This.words.Element (i) /= 0;
         i := @ - 1;
      end loop;

      This.wordsInUse := i + 1 -- The new logical size
   end recalculateWordsInUse;

   --
   -- Creates a new bit set. All bits are initially `False`.
   --
   -- public
   procedure Initialize (Self : BitSet) is
   begin
      sizeIsSticky := False;
      Self.words := Integer_64.Container.To_Vector (New_Item => Integer_64 (0), Length => BitSet.wordIndex (BitSet.BITS_PER_WORD - 1) + 1);
      --initWords (BitSet.BITS_PER_WORD);
   end Initialize;

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
   procedure Initialize (Self : in out BitSet; nbits : Integer) {
      -- nbits can't be negative; size 0 is OK

      -- words := [BitSet.wordIndex (nbits-1) + 1];
      Self.words  := Integer_64.Container.To_Vector (repeating => Integer_64 (0), Length => BitSet.wordIndex (BitSet.BITS_PER_WORD - 1) + 1);
      Self.sizeIsSticky := True;
      if nbits < 0 then
         raise ANTLRError.negativeArraySize with "nbits < 0:" & nbits'Image & " ";

      end if;
      -- initWords (nbits);
   end if;

   -- private
   procedure initWords (nbits : Integer) is
   begin
      -- words := Integer_64_List(Length => BitSet.wordIndex (BitSet.BITS_PER_WORD-1) + 1, repeatedValue => Integer_64 (0));
      -- words := [BitSet.wordIndex (nbits-1) + 1];
      null;
   end initWords;

   --
   -- Creates a bit set using words as the internal representation.
   -- The last word (if there is one) must be non-zero.
   --
   -- private
   procedure Initialize (Self : in out BitSet; words : Integer_64_List) is
   begin
      self.words := words;
      self.wordsInUse := words.Length;
      checkInvariants (Self);
   end Initialize;


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
   function toLongArray (This : BitSet) return Integer_64_List
      is (copyOf (This.words, This.wordsInUse));

   -- private
   function copyOf (words : Integer_64_List; newLength : Natural) return Integer_64_List is
      newWords : Integer_64_List := Integer_64.Container.To_Vector (New_Item => Integer_64 (0), Length => newLength);
      length : constant := min (words.Length, newLength);
   begin
      for i in 0 .. length - 1 loop
         newWords.Insert (i, words (i);
      end loop;
      return newWords;
   end copyOf;

   --
   -- Ensures that the BitSet can hold enough words.
   -- * parameter wordsRequired: the minimum acceptable number of words.
   --
   -- private
   procedure ensureCapacity (wordsRequired : Integer) is
   begin
      if This.words.Length < wordsRequired then
         -- Allocate larger of doubled size or required size
         request : constant Integer := max (2 * This.words.Length, wordsRequired);
         words := copyOf (words, request);
         sizeIsSticky := False;
      end if;
   end ensureCapacity;

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

      words.Element (index) ^= Shift_Left (Integer_64 (1), Integer_64 (bitIndex % 64));

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

      firstWordMask : constant Integer_64 := Shift_Left (BitSet.WORD_MASK, Integer_64 (fromIndex % 64));
      lastWordMask : constant Integer_64 := Shift_Right_Arithmetic ( BitSet.WORD_MASK, Integer_64 (-toIndex));
      --lastWordMask : Integer_64  := Shift_Right_Arithmetic ( WORD_MASK, Integer_64 (-toIndex));
      if startWordIndex = endWordIndex then
         -- when 1 => One word;
         words.Element (startWordIndex) ^= (firstWordMask & lastWordMask);
      else
         -- when 2 => Multiple words;
         -- Handle first word
         words.Element (startWordIndex) ^= firstWordMask

         -- Handle intermediate words, if any
         start : constant := startWordIndex + 1
         for i in start .. endWordIndex - 1 loop
               words.Element (i) ^= BitSet.WORD_MASK
         end loop;

         -- Handle last word
         words.Element (endWordIndex) ^= lastWordMask
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

      -- Text_IO.Put_Line (This.words.Length);
      words.Insert (Key => index, New_Item => @ or Shift_Left (Integer_64 (1), Integer_64 (bitIndex % 64))); -- Restores invariants);

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

      firstWordMask : constant Integer_64 := Shift_Left (BitSet.WORD_MASK, Integer_64 (fromIndex % 64));
      lastWordMask : constant Integer_64 := Shift_Right_Arithmetic ( BitSet.WORD_MASK, Integer_64 (-toIndex));
      --lastWordMask : Integer_64  :=  Shift_Right_Arithmetic (WORD_MASK, Integer_64 ( -toIndex));
      if startWordIndex = endWordIndex then
         -- when 1 => One word;
         words.Insert (Key => startWordIndex, New_Item => @ or (firstWordMask & lastWordMask));
      else
         -- when 2 => Multiple words;
         -- Handle first word
         words.Insert (Key => startWordIndex, New_Item => @ or firstWordMask);

         -- Handle intermediate words, if any
         start : constant := startWordIndex + 1
         for i in start .. endWordIndex - 1 loop
               words.Insert (Key => i, New_Item => BitSet.WORD_MASK);
         end loop;

         -- Handle last word (restores invariants);
         words.Insert (Key => endWordIndex, New_Item => @ or lastWordMask);
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
      option : constant := Shift_Left (Integer_64 (1), Integer_64 (bitIndex % 64));
      words.Insert (Key => index, New_Item => @ and not option);

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

      firstWordMask : constant Integer_64 := Shift_Left (BitSet.WORD_MASK, Integer_64 (fromIndex % 64));
      -- ar lastWordMask : Integer_64  := Shift_Right_Arithmetic ( WORD_MASK, Integer_64 ((-toIndex));
      lastWordMask : constant Integer_64 := Shift_Right_Arithmetic ( BitSet.WORD_MASK, Integer_64 (-toIndex));
      if startWordIndex = endWordIndex then
         -- when 1 => One word;
         words.Insert (Key => startWordIndex, New_Item => @ and not (firstWordMask & lastWordMask));
      else
         -- when 2 => Multiple words;
         -- Handle first word
         words.Insert (Key => startWordIndex, New_Item => @ and not firstWordMask);

         -- Handle intermediate words, if any
         start : constant := startWordIndex + 1
         for i in start .. endWordIndex - 1 loop
               words.Insert (Key => i, New_Item => 0);
         end loop;

         -- Handle last word
         words.Insert (Key => endWordIndex, New_Item => @ and not lastWordMask);
      end if;

      recalculateWordsInUse ();
      checkInvariants ();
   end if;

   --
   -- Sets all of the bits in this BitSet to `False`.
   --
   -- public
   procedure clear (This : BitSet) is
begin
      while wordsInUse > 0 loop
         wordsInUse := @ - 1;
         words.Insert (Key => wordsInUse, New_Item => 0);
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
               and then ((words.Element (index) & Shift_Left (((Integer_64 (1), Integer_64 (bitIndex % 64)))) )/= 0);
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
         wordOption1 : constant Integer_64 := Shift_Right_Arithmetic ( (words.Element (sourceIndex), Integer_64 (fromIndex)));
         wordOption2 : constant Integer_64 := (words[sourceIndex + 1] << Integer_64 (-fromIndex % 64));
         wordOption : constant := wordOption1 | wordOption2
         result.words.Insert (Key => i, New_Item => wordAligned ? words.Element (sourceIndex) : wordOption);

         i := @ + 1;
         sourceIndex := @ + 1;
      end loop;
      -- Process the last word
      -- lastWordMask : Integer_64 := Shift_Right_Arithmetic ( WORD_MASK, Integer_64 (-toIndex));
      lastWordMask : constant Integer_64 := Shift_Right_Arithmetic ( BitSet.WORD_MASK, Integer_64 (-toIndex));
      toIndexTest : constant := ((toIndex - 1) & BitSet.BIT_INDEX_MASK);
      fromIndexTest : constant := (fromIndex & BitSet.BIT_INDEX_MASK);

      wordOption1 : constant Integer_64 := Shift_Right_Arithmetic ( (words.Element (sourceIndex), Integer_64 (fromIndex)));
      wordOption2 : constant Integer_64 := (words[sourceIndex + 1] & lastWordMask);
      wordOption3 : constant Integer_64 := (64 + Integer_64 (-fromIndex % 64));
      wordOption : constant := wordOption1 | Shift_Left (wordOption2, wordOption3)

      wordOption4 : constant := (words.Element (sourceIndex) & lastWordMask);
      wordOption5 : constant := Shift_Right_Arithmetic ( wordOption4, Integer_64 (fromIndex));
      result.words[targetWords - 1] =
               toIndexTest < fromIndexTest
               ? wordOption : wordOption5

      -- Set wordsInUse correctly
      result.wordsInUse := targetWords

      result.recalculateWordsInUse ();
      result.checkInvariants ();

      return result
   end if;

   --
   -- Equivalent to nextSetBit (0), but guaranteed not to raise an exception.
   --
   -- public
   function firstSetBit (This : BitSet) return Integer is
begin
      return nextSetBit (0); -- try!
   end if;

   --
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

      word : Integer_64 := words.Element (u) & Shift_Left (BitSet.WORD_MASK, Integer_64 (fromIndex % 64));

      loop
         if word /= 0 then
               bit : constant := (u * BitSet.BITS_PER_WORD) + word.trailingZeroBitCount
               return bit
         end if;
         u := @ + 1;
         if u = wordsInUse then
               return -1;
         end if;
         word := words.Element (u);
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

      word : Integer_64 := not words.Element (u) & Shift_Left (BitSet.WORD_MASK, Integer_64 (fromIndex % 64));

      loop
         if word /= 0 then
               return (u * BitSet.BITS_PER_WORD) + word.trailingZeroBitCount;
         end if;
         u := @ + 1;
         if u = wordsInUse then
               return wordsInUse * BitSet.BITS_PER_WORD;
         end if;

         word := not words.Element (u);
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

      word : Integer_64 := words.Element (u) & Shift_Right_Arithmetic ( (BitSet.WORD_MASK, Integer_64 (-(fromIndex + 1))));
      loop
         if word /= 0 then
               return (u + 1) * BitSet.BITS_PER_WORD - 1 - word.leadingZeroBitCount;
         end if;
         if u = 0 then
               return -1;
         end if;
         u := @ - 1;
         word := words.Element (u);
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

      word : Integer_64 := not words.Element (u) & Shift_Right_Arithmetic ( (BitSet.WORD_MASK, Integer_64 (-(fromIndex + 1))));
      -- word : Integer_64 := not words.Element (u) & Shift_Right_Arithmetic ( (WORD_MASK, -(fromIndex+1)));

      loop
         if word /= 0 then
               return (u + 1) * BitSet.BITS_PER_WORD - 1 - word.leadingZeroBitCount;
         end if;
         if u = 0 then
               return -1;
         end if;
         u := @ - 1;
         word := not words.Element (u);
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
   function length (This : BitSet) return Integer is
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
   function isEmpty (This : BitSet) return Boolean is
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
         if (words.Element (i) & set.words.Element (i)) /= 0 then
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
   function cardinality (This : BitSet) return Integer is
begin
      sum : Integer := 0;
      for i in 0 .. wordsInUse - 1 loop
         sum := @ + words.Element (i).nonzeroBitCount;
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
         words.Insert (Key => wordsInUse, New_Item => 0);
      end loop;

      -- Perform logical AND on words in common
      for i in 0 .. wordsInUse - 1 loop
         words.Insert (Key => i, New_Item => @ and set.words.Element (i));
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
         words.Insert (Key => i, New_Item => @ or set.words.Element (i));
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
         words.Element (i) ^= set.words.Element (i);
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
         words.Insert (Key => i, New_Item => @ and not set.words.Element (i));
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
   -- h ^= words.Element (i) * (i + 1);
   -- return (int)(Shift_Right (h, 32) ^ h);
   -- `}
   -- Note that the hash code changes if the set of bits is altered.
   --
   -- * returns: the hash code value for this bit set
   --
   -- private
   function hashCode return Ada.Containers.Hash_Type is
   begin
      h : Integer_64 := 1234;
      i : Integer := wordsInUse;
      i := @ - 1;
      while i >= 0 loop
            h ^= words.Element (i) * Integer_64 (i + 1);
            i := @ - 1;
      end loop;

      return Integer (Integer_32 (Shift_Right (h, 32) ^ h));
   end hashCode;

   -- public
   procedure hash (This : BitSet; hasher : in out Hasher) is
   begin
      hasher.combine (hashCode);
   end hash;

   --
   -- Returns the number of bits of space actually in use by this
   -- `BitSet` to represent bit values.
   -- The maximum element in the set is the size - 1st element.
   --
   -- * returns: the number of bits currently in this bit set
   --
   -- public
   function size (This : BitSet) return Integer
      is (This.words.Length * BitSet.BITS_PER_WORD);





   --
   -- Attempts to reduce internal storage used for the bits in this bit set.
   -- Calling this method may, but is not required to, affect the value
   -- returned by a subsequent call to the _#size ()_ method.
   --
   -- private
   procedure trimToSize (This : BitSet) is
   begin
      if This.wordsInUse /= This.words.Length then
         words := copyOf (This.words, This.wordsInUse);
         checkInvariants (This);
      end if;
   end trimToSize;


   --
   -- Returns a string representation of this bit set. For every index
   -- for which this `BitSet` contains a bit in the set
   -- state, the decimal representation of that index is included in
   -- the result. Such indices are listed in order from lowest to
   -- highest, separated by ", " (a comma and a space) and
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
   subtype Sink is Ada.Strings.Text_Buffers.Root_Buffer_Type;
   procedure Put_Image_BitSet (S : in out Sink'Class; X : BitSet);
   for BitSet'Put_Image use Put_Image_BitSet;
   function Description (This : BitSet) return UString is
      b : UString;
   begin
      checkInvariants (This);

      --let numBits: Integer := (wordsInUse > 128) ?
      -- cardinality () : wordsInUse * BitSet.BITS_PER_WORD
      b := "{";
      i := firstSetBit ();
      if i /= -1 then
         b := @ & UString (i);
         i := nextSetBit (i + 1); -- try!
         while i >= 0 loop
               endOfRun : constant := nextClearBit (i); -- try!
               loop
                  b := @ & ", " & i'Image & "";
                  i := @ + 1;
                  exit when i < endOfRun;
               end loop;
               i := nextSetBit (i + 1); -- try!
         end loop;
      end if;
      b := @ & "}";
      return b;
   end Image;

   -- public
   function "=" (Left, Right : BitSet) return Boolean is
   begin
      --  if Left === Right then
      --     return True;
      --  end if;

      Left.checkInvariants;
      Right.checkInvariants;

      if Left.wordsInUse /= Right.wordsInUse then
         return False;
      end if;

      -- Check words in use by both BitSets
      length : constant := Left.wordsInUse;
      for i in 0 .. length - 1 loop
         if Left.words.Element (i) /= Right.words.Element (i) then
            return False;
         end if;
      end loop;

      return True;
   end "=";

end ANTLR.Runtime.Misc.BitSets;
