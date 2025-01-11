-- €

with Ada.Containers.Vectors;
with ANTLR.Runtime.ATN.Configs;

use ANTLR.Runtime.ATN.Configs;

package ANTLR.Runtime.ATN.LookupDictionaries is

   -- public
   type LookupDictionaryType is (lookup, ordered);
   for LookupDictionaryType use (
      lookup  => 0,
      ordered => 1);

   -- public struct
   type LookupDictionary is private;

   -- public
   procedure Initialize (Self : in out LookupDictionary;
                   Type_of_LookupDictionary : LookupDictionaryType := LookupDictionaryType.lookup);

-- public mutating
   function getOrAdd (This : in out LookupDictionary; config : ATNConfig) return ATNConfig;

-- public
   function Is_Empty (This : LookupDictionary) return Boolean
      is (Hashed_ATNConfig.Is_Empty (This.Cache));


-- public
   function contains (This : LookupDictionary; config : ATNConfig) return Boolean;

-- public mutating
   procedure removeAll (This : LookupDictionary);

private

   type LookupDictionary is record
      -- private let
      Type_of_LookupDictionary : LookupDictionaryType;
      -- private
      Cache : ATNConfig_Map; -- [Int: ATNConfig](); --TOFIX
   end record;

end ANTLR.Runtime.ATN.LookupDictionaries;