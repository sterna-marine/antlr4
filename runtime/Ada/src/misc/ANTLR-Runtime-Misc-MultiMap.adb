-- €

with Ada.Containers;
with Ada.Containers.Hashed_Maps;

generic
   type Key_Type is private;
   type Element_Type is private;
package ANTLR.Runtime.Misc.MultiMaps is

   type MultiMap is tagged private;

   type Key_Element_Pair is record
      Key     : Key_Type;
      Element : Element_Type;
   end record;

   type Pair_Array is array (Natural range <>) of Key_Element_Pair;
   type Element_Array is array (Natural range <>) of Element_Type;

   procedure map (Container : MultiMap; Key : Key_Type; Element : Element_Type) is
   begin
      Mapping[key, default => This.Array].append (value);
   end map;

   -- public
   function GetPairs (Container : MultiMap) return Pair_Array is
      Pairs : Pair_Array (1 .. Container.Length);
      I : Natural := 0;
   begin
      if Mapping.Has_Element then
         for Some_key of Mapping.keys loop
            for Some_Element of Mapping.Element (Some_key) loop
               I := @ + 1;
               Pairs (i) := (Some_key, Some_Element);
            end loop;
         end loop;
         return Pairs;
      end if;
   end GetPairs;

   -- public
   function Get (Container : MultiMap; key : Key_Type) return Element_Array;
      is (Mapping.Element (key));

   -- public
   function Length (Container : MultiMap) return Ada.Containers.Count_Type
      is Mapping.Length;

   private
      function Hash (Key : Key_Type) return Ada.Containers.Hash_Type;
      function Equivalent_Keys (Left, Right : Key_Type) return Boolean;
      function "=" (Left, Right : Element_Type) return Boolean;

      package TokenID_Container is new Ada.Containers.Hashed_Maps (
         Key_Type => Key_Type,
         Element_Type => Element_Type,
         Hash => Hash,
         Equivalent_Keys => Equivalent_Keys,
         "=" => "=");
      Mapping := [Key_Type: array (<>) of Element_Type]();

      type MultiMap is tagged private;

end ANTLR.Runtime.Misc.MultiMaps;
