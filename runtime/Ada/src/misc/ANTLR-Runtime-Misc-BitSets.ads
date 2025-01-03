-- €

with Interfaces;
with Ada.Containers.Hashed_Maps;

use Interfaces;

package ANTLR.Runtime.Misc.BitSets is
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

   -- private static
   ADDRESS_BITS_PER_WORD : constant Integer := 6;
   -- private static
   BITS_PER_WORD : constant Integer := Shift_Left (1, ADDRESS_BITS_PER_WORD);
   -- private static
   BIT_INDEX_MASK : constant Integer := BITS_PER_WORD - 1;

   -- public
   type BitSet is new Ada.Finalization.Controlled -- and Hashable
   with
   record
      --
      -- BitSets are packed into arrays of "words."  Currently a word is
      -- a long, which consists of 64 bits, requiring 6 address bits.
      -- The choice of word size is determined purely by performance concerns.
      --
      --
      -- Used to shift left or right for a partial word mask
      --
      -- private static
      WORD_MASK : Integer_64 := Integer_64'Last; -- constant
      -- 16#fffffffffffffff---1#
      -- 16#xffffffffffffffff#;

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
      words : Integer_64_List;

      --
      -- The number of words in the logical size of this BitSet.
      --
      -- fileprivate
      wordsInUse : Integer := 0;
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
      serialVersionUID : constant Integer_64 := 7997698588986878753; --L;
   end record;

   subtype Object is BitSet;
   type Class is access all Object;
   type Class_Wide is access all Object'Class;

   function Hash (Key : Integer) return Ada.Containers.Hash_Type;

   function Equivalent_Keys (Left, Right : Integer) return Boolean
      is Hash (Left) = Hash (Right);

   function "=" (Left, Right : BitSet) return Boolean;

   package BitSet_Maps is new Ada.Containers.Hashed_Maps (
      Key_Type => Integer,
      Element_Type => BitSet,
      Hash => Hash,
      Equivalent_Keys => Equivalent_Keys,
      "=" => "=");
   subtype BitSet_Map is BitSet_Maps.Map;

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
   function Description (This : BitSet) return UString;

   -- public
   procedure hash (This : BitSet; hasher : in out Hasher);

   -- public
   function "=" (Lhs, Rhs : BitSet) return Boolean;

end ANTLR.Runtime.Misc.BitSets;
