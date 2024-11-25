-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
--



-- 
-- https:--en.wikipedia.org/wiki/MurmurHash
-- 
-- - Author: Sam Harwell
-- 

public final class MurmurHash {

    -- private static
    DEFAULT_SEED : constant UInt32 := 0;

    private static c1 : constant := UInt32(0xCC9E2D51)
    private static c2 : constant := UInt32(0x1B873593)
    private static r1 : constant := UInt32(15)
    private static r2 : constant := UInt32(13)
    private static m : constant := UInt32(5)
    private static n : constant := UInt32(0xE6546B64)

    -- 
    -- Initialize the hash using the default seed value.
    -- 
    -- - Returns: the intermediate hash value
    -- 
    public static function initialize (This : …) return UInt32 is
begin
        return initialize(DEFAULT_SEED)
    end ;

    -- 
    -- Initialize the hash using the specified `seed`.
    -- 
    -- - Parameter seed: the seed
    -- - Returns: the intermediate hash value
    -- 
    public static function initialize (seed : UInt32) return UInt32 is
begin
        return seed
    end ;

    private static function calcK (value : UInt32) return UInt32 is
begin
        var k := value
        k := k &* c1
        k := (k << r1) | (k >> (32 - r1))
        k := k &* c2
        return k
     end ;

    -- 
    -- Update the intermediate hash value for the next input `value`.
    -- 
    -- - Parameter hash: the intermediate hash value
    -- - Parameter value: the value to add to the current hash
    -- - Returns: the updated intermediate hash value
    -- 
    public static function update2 (hashIn : UInt32; value : Integer) return UInt32 is
begin
        return updateInternal(hashIn, UInt32(truncatingIfNeeded: value))
    end ;


    private static function updateInternal (hashIn : UInt32; value : UInt32) return UInt32 is
begin
        k : constant := calcK(value)
        var hash := hashIn
        hash := hash ^ k
        hash := (hash << r2) | (hash >> (32 - r2))
        hash := hash &* m &+ n
        -- print("murmur update2 : \(hash)")
        return hash
    end ;

    -- 
    -- Update the intermediate hash value for the next input `value`.
    -- 
    -- - Parameter hash: the intermediate hash value
    -- - Parameter value: the value to add to the current hash
    -- - Returns: the updated intermediate hash value
    -- 
    public static function update<T:Hashable> (hash : UInt32; value : T?) return UInt32 is
begin
        return update2(hash, value?.hashValue ?? 0)
    end ;

    -- 
    -- Apply the final computation steps to the intermediate value `hash`
    -- to form the final result of the MurmurHash 3 hash function.
    -- 
    -- - Parameter hash: the intermediate hash value
    -- - Parameter numberOfWords: the number of UInt32 values added to the hash
    -- - Returns: the final hash result
    -- 
    public static function finish (hashin : UInt32; numberOfWords : Integer) return Integer is
begin
        return Integer (finish(hashin, byteCount: (numberOfWords &* 4)))
    end ;

    private static function finish (hashin : UInt32; byteCount byteCountInt : Integer) return UInt32 is
begin
        byteCount : constant := UInt32(truncatingIfNeeded: byteCountInt)
        var hash := hashin
        hash ^= byteCount
        hash ^= (hash >> 16)
        hash := hash &* 0x85EBCA6B
        hash ^= (hash >> 13)
        hash := hash &* 0xC2B2AE35
        hash ^= (hash >> 16)
        --print("murmur finish : \(hash)")
        return hash
    end ;

    -- 
    -- Utility function to compute the hash code of an array using the
    -- MurmurHash algorithm.
    -- 
    -- - Parameter <T>: the array element type
    -- - Parameter data: the array data
    -- - Parameter seed: the seed for the MurmurHash algorithm
    -- - Returns: the hash code of the data
    -- 
    public static function hashCode<T:Hashable> (data : [T], seed : Integer) return Integer is
begin
        var hash := initialize(UInt32(truncatingIfNeeded: seed))
        for value in data loop
            hash := update(hash, value)
        end loop;

        return finish(hash, data.count)
    end ;

    --
    -- Compute a hash for the given String and seed.  The String is encoded
    -- using UTF-8, then the bytes are interpreted as unsigned 32-bit
    -- little-endian values, giving UInt32 values for the update call.
    --
    -- If the bytes do not evenly divide by 4, the final bytes are treated
    -- slightly differently (not doing the final rotate / multiply / add).
    --
    -- This matches the treatment of byte sequences in publicly available
    -- test patterns (see MurmurHashTests.swift) and the example code on
    -- Wikipedia.
    --
    public static function hashString (s : String; seed : UInt32) return UInt32 is
begin
        bytes : constant := Array(s.utf8)
        return hashBytesLittleEndian(bytes, seed)
    end ;

    private static function hashBytesLittleEndian (bytes : [UInt8], seed : UInt32) return UInt32 is
begin
        byteCount : constant := bytes.count

        var hash := seed
        for i in stride(from: 0, to: byteCount - 3, by: 4) loop
            var word := UInt32(bytes[i])
            word := @ or UInt32(bytes[i + 1]) << 8
            word := @ or UInt32(bytes[i + 2]) << 16
            word := @ or UInt32(bytes[i + 3]) << 24

            hash := updateInternal(hash, word)
        end loop;
        remaining : constant := byteCount & 3
        if remaining /= 0 then
            var lastWord := UInt32(0)
            for r in 0 ..< remaining loop
                lastWord := @ or UInt32(bytes[byteCount - 1 - r]) << (8 * (remaining - 1 - r))
            end loop;

            k : constant := calcK(lastWord)
            hash ^= k
        end ;

        return finish(hash, byteCount: byteCount)
    end ;

    private procedure Init (Self : …) is
begin
    end ;
end ;
