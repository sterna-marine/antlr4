-- €

with Ada.Containers;
with Ada.Containers.Vectors;
with Ada.Containers.Hashed_Sets;
with Option;

use Ada.Containers;

package ANTLR.Runtime is

   package Integer_Container is new Ada.Containers.Vectors 
      (Index_Type => Natural, Element_Type => Integer, "=" => "=");
   subtype Integer_List is Integer_Container.Vector;

   function Hash (Element : Integer) return Hash_Type;
   function Equivalent_Elements (Left, Right : Integer) return Boolean
      is (Hash (Left) = Hash (Right));
   package Integer_Sets is new Ada.Containers.Hashed_Sets (
      Element_Type        => Integer,
      Hash                => Hash,
      Equivalent_Elements => Equivalent_Elements,
      "="                 => "=");
   subtype Set_of_Integers is Integer_Sets.Set;

   package Option_Integers is new Option (Set_of_Integers);
   subtype Set_of_Optional_Integers is Option_Integers.Optional;

end ANTLR.Runtime;