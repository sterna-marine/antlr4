-- €


--
-- https:--en.wikipedia.org/wiki/MurmurHash
--
-- * Author: Sam Harwell
--

-- public final
type MurmurHash is tagged record

    -- private static
    DEFAULT_SEED : constant Unsigned_32 := 0;

    private static c1 : constant := Unsigned_32 (0xCC9E2D51);
    private static c2 : constant := Unsigned_32 (0x1B873593);
    private static r1 : constant := Unsigned_32 (15);
    private static r2 : constant := Unsigned_32 (13);
    private static m : constant := Unsigned_32 (5);
    private static n : constant := Unsigned_32 (0xE6546B64);

    --
    -- Initialize the hash using the default seed value.
    --
    -- * Returns: the intermediate hash value
    --
    -- public static
    function initialize (This : …) return Unsigned_32 is
begin
        return initialize (DEFAULT_SEED);
    end if;

    --
    -- Initialize the hash using the specified `seed`.
    --
    -- * Parameter seed: the seed
    -- * Returns: the intermediate hash value
    --
    -- public static
    function initialize (seed : Unsigned_32) return Unsigned_32 is
begin
        return seed
    end if;

    -- private static
    function calcK (value : Unsigned_32) return Unsigned_32 is
begin
        k := value
        k := k &* c1
        k := Shift_Left (k, r1) | Shift_Right ( (k, (32 - r1)));
        k := k &* c2
        return k
     end if;

    --
    -- Update the intermediate hash value for the next input `value`.
    --
    -- * Parameter hash: the intermediate hash value
    -- * Parameter value: the value to add to the current hash
    -- * Returns: the updated intermediate hash value
    --
    -- public static
    function update2 (hashIn : Unsigned_32; value : Integer) return Unsigned_32 is
begin
        return updateInternal (hashIn, Unsigned_32 (truncatingIfNeeded => value));
    end if;


    -- private static
    function updateInternal (hashIn : Unsigned_32; value : Unsigned_32) return Unsigned_32 is
begin
        k : constant := calcK (value);
        hash := hashIn
        hash := hash ^ k
        hash := Shift_Left (hash, r2) | Shift_Right ( (hash, (32 - r2)));
        hash := hash &* m &+ n
        -- Text_IO.Put_Line ("murmur update2 : " & hash'Image);
        return hash
    end if;

    --
    -- Update the intermediate hash value for the next input `value`.
    --
    -- * Parameter hash: the intermediate hash value
    -- * Parameter value: the value to add to the current hash
    -- * Returns: the updated intermediate hash value
    --
    -- public static
    function update<T:Hashable> (hash : Unsigned_32; value : Optional_T;) return Unsigned_32 is
begin
        return update2 (hash, value?.hashValue, Default => 0);
    end if;

    --
    -- Apply the final computation steps to the intermediate value `hash`
    -- to form the final result of the MurmurHash 3 hash function.
    --
    -- * Parameter hash: the intermediate hash value
    -- * Parameter numberOfWords: the number of Unsigned_32 values added to the hash
    -- * Returns: the final hash result
    --
    -- public static
    function finish (hashin : Unsigned_32; numberOfWords : Integer) return Ada.Containers.Hash_Type is
begin
        return Ada.Containers.Hash_Type (finish (hashin, byteCount: (numberOfWords &* 4)));
    end if;

    -- private static
    function finish (hashin : Unsigned_32; byteCount byteCountInt : Integer) return Unsigned_32 is
begin
        byteCount : constant := Unsigned_32 (truncatingIfNeeded => byteCountInt);
        hash := hashin
        hash ^= byteCount
        hash ^= Shift_Right (hash, 16);
        hash := hash &* 0x85EBCA6B
        hash ^= Shift_Right (hash, 13);
        hash := hash &* 0xC2B2AE35
        hash ^= Shift_Right (hash, 16);
        --print ("murmur finish : " & hash'Image);
        return hash
    end if;

    --
    -- Utility function to compute the hash code of an array using the
    -- MurmurHash algorithm.
    --
    -- * Parameter <T>: the array element type
    -- * Parameter data: the array data
    -- * Parameter seed: the seed for the MurmurHash algorithm
    -- * Returns: the hash code of the data
    --
    -- public static
    function hashCode<T:Hashable> (data : T.Container.Vector, seed : Integer) return Ada.Containers.Hash_Type is
begin
        hash := initialize (Unsigned_32 (truncatingIfNeeded => seed));
        for value in data loop
            hash := update (hash, value);
        end loop;

        return finish (hash, data.count);
    end if;

    --
    -- Compute a hash for the given UString and seed.  The UString is encoded
    -- using UTF-8, then the bytes are interpreted as unsigned 32-bit
    -- little-endian values, giving Unsigned_32 values for the update call.
    --
    -- If the bytes do not evenly divide by 4, the final bytes are treated
    -- slightly differently (not doing the final rotate / multiply / add).
    --
    -- This matches the treatment of byte sequences in publicly available
    -- test patterns (see MurmurHashTests.swift) and the example code on
    -- Wikipedia.
    --
    -- public static
    function hashString (s : UString; seed : Unsigned_32) return Unsigned_32 is
begin
        bytes : constant := Array (s.utf8);
        return hashBytesLittleEndian (bytes, seed);
    end if;

    -- private static
    function hashBytesLittleEndian (bytes : Unsigned_8.Container.Vector, seed : Unsigned_32) return Unsigned_32 is
begin
        byteCount : constant := bytes.count

        hash := seed
        for i in stride (from => 0, to => byteCount - 3, by => 4) loop
            word := Unsigned_32 (bytes.Element (i));
            word := @ or Unsigned_32 (bytes[i + 1]) << 8
            word := @ or Unsigned_32 (bytes[i + 2]) << 16
            word := @ or Unsigned_32 (bytes[i + 3]) << 24

            hash := updateInternal (hash, word);
        end loop;
        remaining : constant := byteCount & 3
        if remaining /= 0 then
            lastWord := Unsigned_32 (0);
            for r in 0 ..< remaining loop
                lastWord := @ or Unsigned_32 (bytes[byteCount - 1 - r]) << (8 * (remaining - 1 - r));
            end loop;

            k : constant := calcK (lastWord);
            hash ^= k
        end if;

        return finish (hash, byteCount => byteCount);
    end if;

    -- private
    overriding
    procedure Initialize (Self : in out …) is
begin
    end if;
end if;
