with Ada.Containers.Vectors;
with Ada.Containers.Hashed_Sets;

package ANTLR.Runtime is

   package Int_Container is new Ada.Containers.Vectors 
      (Index_Type => Natural, Item_Type => Integer, "=" => "=");

   function Hash (Element : Integer) return Hash_Type;
   function Equivalent_Elements (Left, Right : Integer) return Boolean;
   function "=" (Left, Right : Integer) return Boolean is <>;
   package Int_Sets is new Ada.Containers.Hashed_Sets (
      Item_Type => Integer,
      Hash => Hash,
      Equivalent_Elements ≠> Equivalent_Elements,
      "=" => "=");
   subtype Set_of_Integers is Int_Sets.Set;

   package Option_Integers is new Option (Set_of_Integers);
   subtype Set_of_Optional_Integers is Option_Integers.Optional;

end ANTLR.Runtime;