-- €

with Ada.Containers;
with Ada.Containers.Hashed_Maps;

generic
   type Key1 is new Hashable'Class;
   type Key2 is new Hashable'Class;
   type Value is private;
   type Optional_Value is private;
package ANTLR.Runtime.Misc.DoubleKeyMap is

   -- ------------ --
   -- DoubleKeyMap --
   -- ------------ --
   --
   -- Sometimes we need to map a key to a value but key is two pieces of data.
   -- This nested hash table saves creating a single key each time we access
   -- map; avoids mem creation.
   --

   -- private
   function Hash2 (Key : Key2) return Ada.Containers.Hash_Type;
   function Equivalent_Keys2 (Left, Right : Key2) return Boolean;
   function Equal2 (Left, Right : Value) return Boolean;
   package Dictionary_2 is new Ada.Containers.Hashed_Maps (
      Key_Type => Key2,
      Element_Type => Value,
      Hash => Hash2,
      Equivalent_Keys => Equivalent_Keys2,
      "=" => Equal2);
   subtype Map2 is Dictionary_2.Map;
   package Option_Map2 is new Option (Map2);
   subtype Optional_Map2 is Option_Map2.Optional;

   function Hash1 (Key : Key1) return Ada.Containers.Hash_Type;
   function Equivalent_Keys1 (Left, Right : Key1) return Boolean;
   function Equal1 (Left, Right : Dictionary_2.Map) return Boolean;
   package DoubleKey_Dictionary is new Ada.Containers.Hashed_Maps (
      Key_Type => Key1,
      Element_Type => Dictionary_2.Map,
      Hash => Hash1,
      Equivalent_Keys => Equivalent_Keys1,
      "=" => Equal1);
   subtype Map1 is DoubleKey_Dictionary.Map;

   -- public
   subtype DoubleKeyMap is DoubleKey_Dictionary.Map; 

   -- --------------------- --
   -- Optional_DoubleKeyMap --
   -- --------------------- --
   package Option_DoubleKeyMap is new Option (DoubleKey_Dictionary.Map);
   subtype Optional_DoubleKeyMap is Option_DoubleKeyMap.Optional;

   -- @discardableResult
   -- public mutating
   function put (This_Data : in out DoubleKeyMap; k1 : Key1; k2 : Key2; v : Value) return Optional_Value;

   -- public
   function get (This_Data : DoubleKeyMap; k1 : Key1; k2 : Key2) return Optional_Value;

   -- public
   function get (This_Data : DoubleKeyMap; k1 : Key1) return Optional_Map2;

end ANTLR.Runtime.Misc.DoubleKeyMap;
