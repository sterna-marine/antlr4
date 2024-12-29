-- €

with Ada.Containers.Vectors;
with Murmur3;

package body LookupDictionary is

   -- Hashed_Map
   subtype hash_Type is Ada.Containers.Hash_Type;

-- private
-- function Hash_ATNConfig (Key : ATNConfig) return Hash_Type is --TOFIX
   function hash (Key : ATNConfig) return Hash_Type is --TOFIX
      hashCode : Ada.Containers.Hash_Type := 7;
      hasher := Hasher;
   begin
      if This.Type_of_LookupDictionary = lookup then
         -- migrating to XCode 12.3/Swift 5.3 introduced a very weird bug
         -- where reading hashValue from a SemanticContext.AND instance woul:
         -- call the AND empty constructor
         -- NOT call AND.hash (into);
         -- Could it be a Swift compiler bug ?
         -- All tests pass when using Hasher.combine ();
         -- Keeping the old code for reference:

         hashCode := 31 * hashCode + Key.state.stateNumber;
         hashCode := 31 * hashCode + Key.alt;
         hashCode := 31 * hashCode + Key.semanticContext.hashValue; -- <- the crash would occur here
         return hashCode;

           --
         hasher.combine (7);
         hasher.combine (Key.state.stateNumber);
         hasher.combine (Key.alt);
         hasher.combine (Key.semanticContext);
         return hasher.finalize;
      else
         --Ordered
         return Key.hashValue;
      end if;
    end hash;

   function Equivalent_Keys (Left, Right : Hash_Type) return Boolean
      is (Left = Right);

   function equal (Left : ATNConfig; Right : ATNConfig) return Boolean is --TOFIX
   begin
      --  if This = lookup then
      --     if Left === Right then
      --           return True;
      --     end if;
      return
         Left.state.stateNumber = Right.state.stateNumber
         and Left.alt = Right.alt
         and Left.semanticContext = Right.semanticContext;
      --  else --Ordered
      --     return Left = Right;
      --  end if;
   end equal;

   package body Hashed_ATNConfig is new Ada.Containers.Hashed_Maps (
      Key_Type => Hash_Type,
      Element_Type => ATNConfig,
      Hash => Hash_ATNConfig,
      Equivalent_Keys => Equivalent_Keys,
      "=" => equal);

   procedure Initialize (Self : in out LookupDictionary;
                   Type_of_LookupDictionary : LookupDictionaryType := LookupDictionaryType.lookup) is
   begin  --TOFIX
      Self.Type_of_LookupDictionary := Type_of_LookupDictionary;
   end Initialize;

   function getOrAdd (This : in out LookupDictionary; config : ATNConfig) return ATNConfig is --TOFIX
      h : constant Hash_Type := hash (config);
      configList :  Container.Element (configList, h), Length => 1);
   begin
      if Hashed_ATNConfig.Contains (This.Cache, Key => h) then
         return Hashed_ATNConfig.Element (This.Cache, h);
      else
         Hashed_ATNConfig.Insert (
               This.Cache,
               Key      => h,
               New_Item => config);
         return config;
      end if;
   end getOrAdd;

   function contains (This : LookupDictionary; config : ATNConfig) return Boolean is --TOFIX
      h : constant Hash_Type := hash (config);
   begin
      return Hashed_ATNConfig.Contains (This.Cache, h);
   end contains;

   procedure removeAll (This : LookupDictionary; ) is --TOFIX
   begin
      -- This.Cache := Hashed_ATNConfig.Empty_Map;
      Hashed_ATNConfig.Clear (This.Cache); --  does not affect the capacity of Container
   end removeAll;

end LookupDictionary;