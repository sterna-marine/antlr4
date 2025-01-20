--
--  Licensed to the Apache Software Foundation (ASF) under one or more
--  contributor license agreements. See the NOTICE file distributed with
--  this work for additional information regarding copyright ownership.
--  The ASF licenses this file to You under the Apache License, Version 2.0
--  (the "License"); you may not use this file except in compliance with
--  the License. You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
--  Unless required by applicable law or agreed to in writing, software
--  distributed under the License is distributed on an "AS IS" BASIS,
--  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--  See the License for the specific language governing permissions and
--  limitations under the License.
--
package body kafka.streams.state.internals is

--
--  This class was taken from Hive org.apache.hive.common.util;
--  https://github.com/apache/hive/blob/master/storage-api/src/java/org/apache/hive/common/util/Murmur3.java
--  Commit: dffa3a16588bc8e95b9d0ab5af295a74e06ef702
--
--
--  Murmur3 is successor to Murmur2 fast non-crytographic hash algorithms.
--
--  Murmur3 32 and 128 bit variants.
--  32-bit Java port of https://code.google.com/p/smhasher/source/browse/trunk/MurmurHash3.cpp#94
--  128-bit Java port of https://code.google.com/p/smhasher/source/browse/trunk/MurmurHash3.cpp#255
--
--  This is a public domain code with no copyrights.
--  From homepage of MurmurHash (https://code.google.com/p/smhasher/),
--  "All MurmurHash versions are public domain software, and the author disclaims all copyright
--  to their code."
--
@SuppressWarnings("fallthrough")
public class Murmur3 {
    -- from 64-bit linear congruential generator
    public static final Integer_64 NULL_HASHCODE = 2862933555777941757;

    -- Constants for 32 bit variant
    private static final Integer C1_32 = 16#cc9e2d51#;
    private static final Integer C2_32 = 16#1b873593#;
    private static final Integer R1_32 = 15;
    private static final Integer R2_32 = 13;
    private static final Integer M_32 = 5;
    private static final Integer N_32 = 16#e6546b64#;

    -- Constants for 128 bit variant
    private static final Integer_64 C1 = 16#87c37b91114253d5#L;
    private static final Integer_64 C2 = 16#4cf5ad432745937f#L;
    private static final Integer R1 = 31;
    private static final Integer R2 = 27;
    private static final Integer R3 = 33;
    private static final Integer M = 5;
    private static final Integer N1 = 16#52dce729#;
    private static final Integer N2 = 16#38495ab5#;

    public static final Integer DEFAULT_SEED = 104729;

    function hash32 (l0 : Integer_64; l1 : Integer_64) return Integer is -- public
        return hash32(l0, l1, DEFAULT_SEED);
    }

    function hash32 (l0 : Integer_64) return Integer is -- public
        return hash32(l0, DEFAULT_SEED);
    }

    --
    --  Murmur3 32-bit variant.
    --
    function hash32 (l0 : Integer_64; seed : Integer)return Integer is -- public
        Integer hash = seed;
        final Integer_64 r0 = Integer_64.reverseBytes(l0);

        hash = mix32((Integer)r0, hash);
        hash = mix32((Integer)(Shift_Right (Value => r0, Amount => 32)), hash);

        return fmix32(Long'Size / 8, hash);
    }

    --
    --  Murmur3 32-bit variant.
    --
    function hash32 (l0 : Integer_64; l1 : Integer_64; seed : Integer)return Integer is -- public
        Integer hash = seed;
        final Integer_64 r0 = Integer_64.reverseBytes(l0);
        final Integer_64 r1 = Integer_64.reverseBytes(l1);

        hash = mix32((Integer)r0, hash);
        hash = mix32((Integer)(Shift_Right (Value => r0, Amount => 32)), hash);
        hash = mix32((Integer)(r1), hash);
        hash = mix32((Integer)(Shift_Right (Value => r1, Amount => 32)), hash);

        return fmix32(Long'Size / 8 * 2, hash);
    }

    --
    --  Murmur3 32-bit variant.
    --
    --  @param data - input Integer_8 array
    --  @return - hashcode
    --
    function hash32 (byte[] data) return Integer is -- public
    begin
        return hash32(data, 0, data.length, DEFAULT_SEED);
    }

    --
    --  Murmur3 32-bit variant.
    --
    --  @param data - input Integer_8 array
    --  @param length - length of array
    --  @return - hashcode
    --
    function hash32 (byte[] data, Integer length) return Integer is -- public
    begin
        return hash32(data, 0, length, DEFAULT_SEED);
    }

    --
    --  Murmur3 32-bit variant.
    --
    --  @param data   - input Integer_8 array
    --  @param length - length of array
    --  @param seed   - seed. (default 0)
    --  @return - hashcode
    --
    function hash32 (byte[] data, Integer length, Integer seed) return Integer is -- public
    begin
        return hash32(data, 0, length, seed);
    }

    --
    --  Murmur3 32-bit variant.
    --
    --  @param data   - input Integer_8 array
    --  @param offset - offset of data
    --  @param length - length of array
    --  @param seed   - seed. (default 0)
    --  @return - hashcode
    --
    function hash32 (byte[] data, Integer offset, Integer length, Integer seed) return Integer is -- public
    begin
        Integer hash = seed;
        final Integer nblocks = Shift_Right_Arithmetic (Value => length, Amount => 2);

        -- body
        i : Integer := 0;
        while i < nblocks loop
            Integer i_4 = Shift_left (Value => i, Amount => 2);
            Integer k = (data[offset + i_4] and 16#ff#)
                    or Shift_Left (Value => (data[offset + i_4 + 1] and 16#ff#), Amount => 8)
                    or Shift_Left (Value => (data[offset + i_4 + 2] and 16#ff#), Amount => 16)
                    or Shift_Left (Value => (data[offset + i_4 + 3] and 16#ff#), Amount => 24);

            hash = mix32(k, hash);
        }

        -- tail
        Integer idx = Shift_left (Value => nblocks, Amount => 2);
        Integer k1 = 0;
        case length - idx is
            when 3 => 
                k1 := @ xor data[offset + idx + 2] << 16;
            when 2 => 
                k1 := @ xor data[offset + idx + 1] << 8;
            when 1 => 
                k1 := @ xor data[offset + idx];

                -- mix functions
                k1 := @ * C1_32;
                k1 = Integer.rotateLeft(k1, R1_32);
                k1 := @ * C2_32;
                hash := @ xor k1;
        }

        return fmix32(length, hash);
    }

    function mix32 (k : int; hash : Integer)
       return Integer is -- private
    begin
        k := @ * C1_32;
        k = Integer.rotateLeft(k, R1_32);
        k := @ * C2_32;
        hash := @ xor k;
        return Integer.rotateLeft(hash, R2_32) * M_32 + N_32;
    }

    function fmix32 (length : int; hash : Integer)
       return Integer is -- private
    begin
        hash := @ xor length;
        hash := @ xor (Shift_Right (Value => hash, Amount => 16));
        hash := @ * 16#85ebca6b#;
        hash := @ xor (Shift_Right (Value => hash, Amount => 13));
        hash := @ * 16#c2b2ae35#;
        hash := @ xor (Shift_Right (Value => hash, Amount => 16));

        return hash;
    }

    --
    --  Murmur3 64-bit variant. This is essentially MSB 8 bytes of Murmur3 128-bit variant.
    --
    --  @param data - input Integer_8 array
    --  @return - hashcode
    --
    function hash64 (byte[] data) return Integer_64 is -- public
    begin
        return hash64(data, 0, data.length, DEFAULT_SEED);
    }

    function hash64 (data : Integer_64) return Integer_64 is -- public
        Integer_64 hash = DEFAULT_SEED;
        Integer_64 k = Integer_64.reverseBytes(data);
        Integer length = Long'Size / 8;
        -- mix functions
        k := @ * C1;
        k = Integer_64.rotateLeft(k, R1);
        k := @ * C2;
        hash := @ xor k;
        hash = Integer_64.rotateLeft(hash, R2) * M + N1;
        -- finalization
        hash := @ xor length;
        hash = fmix64(hash);
        return hash;
    }

    function hash64 (data : Integer)return Integer_64 is -- public
        Integer_64 k1 = Integer.reverseBytes(data) and (-Shift_Right (Value => 1L, Amount => 32));
        Integer length = Integer'Size / 8;
        Integer_64 hash = DEFAULT_SEED;
        k1 := @ * C1;
        k1 = Integer_64.rotateLeft(k1, R1);
        k1 := @ * C2;
        hash := @ xor k1;
        -- finalization
        hash := @ xor length;
        hash = fmix64(hash);
        return hash;
    }

    function hash64 (data : Integer_16) return Integer_64 is -- public
        Integer_64 hash = DEFAULT_SEED;
        Integer_64 k1 = 0;
        k1 := @ xor Shift_Left (Value => Integer_64 (data and 16#ff#), Amount => 8);
        k1 := @ xor Integer_64 (Shift_Right_Arithmetic (Value => data and 16#FF00#, Amount => 8)) and 16#ff#);
        k1 := @ * C1;
        k1 = Integer_64.rotateLeft(k1, R1);
        k1 := @ * C2;
        hash := @ xor k1;

        -- finalization
        hash := @ xor Integer_16'Size / 8;
        hash = fmix64(hash);
        return hash;
    }

    function hash64 (byte[] data, Integer offset, Integer length) return Integer_64 is -- public
    begin
        return hash64(data, offset, length, DEFAULT_SEED);
    }

    --
    --  Murmur3 64-bit variant. This is essentially MSB 8 bytes of Murmur3 128-bit variant.
    --
    --  @param data   - input Integer_8 array
    --  @param length - length of array
    --  @param seed   - seed. (default is 0)
    --  @return - hashcode
    --
    function hash64 (byte[] data, Integer offset, Integer length, Integer seed) return Integer_64 is -- public
    begin
        Integer_64 hash = seed;
        final Integer nblocks = Shift_Right_Arithmetic (Value => length, Amount => 3);

        -- body
        i : Integer := 0;
        while i < nblocks loop
            final Integer i8 = Shift_Left (Value => i, Amount => 3);
            Integer_64 k = ((Integer_64) data[offset + i8] and 16#ff#)
                    or Shift_Left (Value => ((Integer_64) data[offset + i8 + 1] and 16#ff#), Amount => 8)
                    or Shift_Left (Value => ((Integer_64) data[offset + i8 + 2] and 16#ff#), Amount => 16)
                    or Shift_Left (Value => ((Integer_64) data[offset + i8 + 3] and 16#ff#), Amount => 24)
                    or Shift_Left (Value => ((Integer_64) data[offset + i8 + 4] and 16#ff#), Amount => 32)
                    or Shift_Left (Value => ((Integer_64) data[offset + i8 + 5] and 16#ff#), Amount => 40)
                    or Shift_Left (Value => ((Integer_64) data[offset + i8 + 6] and 16#ff#), Amount => 48)
                    or Shift_Left (Value => ((Integer_64) data[offset + i8 + 7] and 16#ff#), Amount => 56);

            -- mix functions
            k := @ * C1;
            k = Integer_64.rotateLeft(k, R1);
            k := @ * C2;
            hash := @ xor k;
            hash = Integer_64.rotateLeft(hash, R2) * M + N1;
        }

        -- tail
        Integer_64 k1 = 0;
        Integer tailStart = Shift_left (Value => nblocks, Amount => 3);
        case length - tailStart is
            when 7 => 
                k1 := @ xor ((Integer_64) data[offset + tailStart + 6] and 16#ff#) << 48;
            when 6 => 
                k1 := @ xor ((Integer_64) data[offset + tailStart + 5] and 16#ff#) << 40;
            when 5 => 
                k1 := @ xor ((Integer_64) data[offset + tailStart + 4] and 16#ff#) << 32;
            when 4 => 
                k1 := @ xor ((Integer_64) data[offset + tailStart + 3] and 16#ff#) << 24;
            when 3 => 
                k1 := @ xor ((Integer_64) data[offset + tailStart + 2] and 16#ff#) << 16;
            when 2 => 
                k1 := @ xor ((Integer_64) data[offset + tailStart + 1] and 16#ff#) << 8;
            when 1 => 
                k1 := @ xor ((Integer_64) data[offset + tailStart] and 16#ff#);
                k1 := @ * C1;
                k1 = Integer_64.rotateLeft(k1, R1);
                k1 := @ * C2;
                hash := @ xor k1;
        }

        -- finalization
        hash := @ xor length;
        hash = fmix64(hash);

        return hash;
    }

    --
    --  Murmur3 128-bit variant.
    --
    --  @param data - input Integer_8 array
    --  @return - hashcode (2 longs)
    --
    function hash128 (byte[] data) return long[] is -- public
    begin
        return hash128(data, 0, data.length, DEFAULT_SEED);
    }

    --
    --  Murmur3 128-bit variant.
    --
    --  @param data   - input Integer_8 array
    --  @param offset - the first element of array
    --  @param length - length of array
    --  @param seed   - seed. (default is 0)
    --  @return - hashcode (2 longs)
    --
    function hash128 (byte[] data, Integer offset, Integer length, Integer seed) return long[] is -- public
    begin
        Integer_64 h1 = seed;
        Integer_64 h2 = seed;
        final Integer nblocks = Shift_Right_Arithmetic (Value => length, Amount => 4);

        -- body
        i : Integer := 0;
        while i < nblocks loop
            final Integer i16 = Shift_left (Value => i, Amount => 4);
            Integer_64 k1 = ((Integer_64) data[offset + i16] and 16#ff#)
                    or Shift_Left (Value => ((Integer_64) data[offset + i16 + 1] and 16#ff#), Amount => 8)
                    or Shift_Left (Value => ((Integer_64) data[offset + i16 + 2] and 16#ff#), Amount => 16)
                    or Shift_Left (Value => ((Integer_64) data[offset + i16 + 3] and 16#ff#), Amount => 24)
                    or Shift_Left (Value => ((Integer_64) data[offset + i16 + 4] and 16#ff#), Amount => 32)
                    or Shift_Left (Value => ((Integer_64) data[offset + i16 + 5] and 16#ff#), Amount => 40)
                    or Shift_Left (Value => ((Integer_64) data[offset + i16 + 6] and 16#ff#), Amount => 48)
                    or Shift_Left (Value => ((Integer_64) data[offset + i16 + 7] and 16#ff#), Amount => 56);

            Integer_64 k2 = ((Integer_64) data[offset + i16 + 8] and 16#ff#)
                    or Shift_Left (Value => ((Integer_64) data[offset + i16 + 9] and 16#ff#), Amount => 8)
                    or Shift_Left (Value => ((Integer_64) data[offset + i16 + 10] and 16#ff#), Amount => 16)
                    or Shift_Left (Value => ((Integer_64) data[offset + i16 + 11] and 16#ff#), Amount => 24)
                    or Shift_Left (Value => ((Integer_64) data[offset + i16 + 12] and 16#ff#), Amount => 32)
                    or Shift_Left (Value => ((Integer_64) data[offset + i16 + 13] and 16#ff#), Amount => 40)
                    or Shift_Left (Value => ((Integer_64) data[offset + i16 + 14] and 16#ff#), Amount => 48)
                    or Shift_Left (Value => ((Integer_64) data[offset + i16 + 15] and 16#ff#), Amount => 56);

            -- mix functions for k1
            k1 := @ * C1;
            k1 = Integer_64.rotateLeft(k1, R1);
            k1 := @ * C2;
            h1 := @ xor k1;
            h1 = Integer_64.rotateLeft(h1, R2);
            h1 := @ + h2;
            h1 = h1 * M + N1;

            -- mix functions for k2
            k2 := @ * C2;
            k2 = Integer_64.rotateLeft(k2, R3);
            k2 := @ * C1;
            h2 := @ xor k2;
            h2 = Integer_64.rotateLeft(h2, R1);
            h2 := @ + h1;
            h2 = h2 * M + N2;
        }

        -- tail
        Integer_64 k1 = 0;
        Integer_64 k2 = 0;
        Integer tailStart = Shift_left (Value => nblocks, Amount => 4);
        case length - tailStart is
            when 15 => 
                k2 := @ xor (Integer_64) (data[offset + tailStart + 14] and 16#ff#) << 48;
            when 14 => 
                k2 := @ xor (Integer_64) (data[offset + tailStart + 13] and 16#ff#) << 40;
            when 13 => 
                k2 := @ xor (Integer_64) (data[offset + tailStart + 12] and 16#ff#) << 32;
            when 12 => 
                k2 := @ xor (Integer_64) (data[offset + tailStart + 11] and 16#ff#) << 24;
            when 11 => 
                k2 := @ xor (Integer_64) (data[offset + tailStart + 10] and 16#ff#) << 16;
            when 10 => 
                k2 := @ xor (Integer_64) (data[offset + tailStart + 9] and 16#ff#) << 8;
            when 9 => 
                k2 := @ xor (Integer_64) (data[offset + tailStart + 8] and 16#ff#);
                k2 := @ * C2;
                k2 = Integer_64.rotateLeft(k2, R3);
                k2 := @ * C1;
                h2 := @ xor k2;

            when 8 => 
                k1 := @ xor (Integer_64) (data[offset + tailStart + 7] and 16#ff#) << 56;
            when 7 => 
                k1 := @ xor (Integer_64) (data[offset + tailStart + 6] and 16#ff#) << 48;
            when 6 => 
                k1 := @ xor (Integer_64) (data[offset + tailStart + 5] and 16#ff#) << 40;
            when 5 => 
                k1 := @ xor (Integer_64) (data[offset + tailStart + 4] and 16#ff#) << 32;
            when 4 => 
                k1 := @ xor (Integer_64) (data[offset + tailStart + 3] and 16#ff#) << 24;
            when 3 => 
                k1 := @ xor (Integer_64) (data[offset + tailStart + 2] and 16#ff#) << 16;
            when 2 => 
                k1 := @ xor (Integer_64) (data[offset + tailStart + 1] and 16#ff#) << 8;
            when 1 => 
                k1 := @ xor (Integer_64) (data[offset + tailStart] and 16#ff#);
                k1 := @ * C1;
                k1 = Integer_64.rotateLeft(k1, R1);
                k1 := @ * C2;
                h1 := @ xor k1;
        }

        -- finalization
        h1 := @ xor length;
        h2 := @ xor length;

        h1 := @ + h2;
        h2 := @ + h1;

        h1 = fmix64(h1);
        h2 = fmix64(h2);

        h1 := @ + h2;
        h2 := @ + h1;

        return new long[]{h1, h2};
    }

    function fmix64 (h : Integer_64)
       return Integer_64 is -- private
    begin
        h := @ xor (Shift_Right (Value => h, Amount => 33));
        h := @ * 16#ff51afd7ed558ccd#L;
        h := @ xor (Shift_Right (Value => h, Amount => 33));
        h := @ * 16#c4ceb9fe1a85ec53#L;
        h := @ xor (Shift_Right (Value => h, Amount => 33));
        return h;
    }

    public static class IncrementalHash32 {
        byte[] tail = new byte[3];
        Integer tailLen;
        Integer totalLen;
        Integer hash;

        procedure start (This : Object; hash : Integer) is -- public
        begin
            tailLen = totalLen = 0;
            this.hash = hash;
        }

        procedure add (This : Object; byte[] data, Integer offset, Integer length) is -- public
        begin
            if length = 0 then
               return;
            end if;
            totalLen := @ + length;
            if tailLen + length < 4 then
                System.arraycopy(data, offset, tail, tailLen, length);
                tailLen := @ + length;
                return;
            }
            Integer offset2 = 0;
            if tailLen > 0 then
                offset2 = (4 - tailLen);
                Integer k = -1;
                case tailLen is
                    when 1 => 
                        k = orBytes(tail[0], data[offset], data[offset + 1], data[offset + 2]);
                        exit;
                    when 2 => 
                        k = orBytes(tail[0], tail[1], data[offset], data[offset + 1]);
                        exit;
                    when 3 => 
                        k = orBytes(tail[0], tail[1], tail[2], data[offset]);
                        exit;
                    default: raise AssertionError with tailLen;
                }
                -- mix functions
                k := @ * C1_32;
                k = Integer.rotateLeft(k, R1_32);
                k := @ * C2_32;
                hash := @ xor k;
                hash = Integer.rotateLeft(hash, R2_32) * M_32 + N_32;
            }
            Integer length2 = length - offset2;
            offset := @ + offset2;
            final Integer nblocks = Shift_Right_Arithmetic (Value => length2, Amount => 2);

            i : Integer := 0;
            while i < nblocks loop
                Integer i_4 = Shift_Left (Value => i, Amount => 2) + offset;
                Integer k = orBytes(data[i_4], data[i_4 + 1], data[i_4 + 2], data[i_4 + 3]);

                -- mix functions
                k := @ * C1_32;
                k = Integer.rotateLeft(k, R1_32);
                k := @ * C2_32;
                hash := @ xor k;
                hash = Integer.rotateLeft(hash, R2_32) * M_32 + N_32;
            }

            Integer consumed = Shift_Left (Value => nblocks, Amount => 2);
            tailLen = length2 - consumed;
            if consumed = length2 then
               return;
            end if;
            System.arraycopy(data, offset + consumed, tail, 0, tailLen);
        }

        function end (This : Object) return Integer is -- public final
        begin
            Integer k1 = 0;
            case tailLen is
                when 3 => 
                    k1 := @ xor tail[2] << 16;
                when 2 => 
                    k1 := @ xor tail[1] << 8;
                when 1 => 
                    k1 := @ xor tail[0];

                    -- mix functions
                    k1 := @ * C1_32;
                    k1 = Integer.rotateLeft(k1, R1_32);
                    k1 := @ * C2_32;
                    hash := @ xor k1;
            }

            -- finalization
            hash := @ xor totalLen;
            hash := @ xor (Shift_Right (Value => hash, Amount => 16));
            hash := @ * 16#85ebca6b#;
            hash := @ xor (Shift_Right (Value => hash, Amount => 13));
            hash := @ * 16#c2b2ae35#;
            hash := @ xor (Shift_Right (Value => hash, Amount => 16));
            return hash;
        }
    }

    function orBytes (b1 : Integer_8; b2 : Integer_8; b3 : Integer_8; b4 : Integer_8)
       return Integer is -- private
    begin
        return (b1 and 16#ff#) | ((b2 and 16#ff#) << 8) | ((b3 and 16#ff#) << 16) | ((b4 and 16#ff#) << 24);
    }
}
