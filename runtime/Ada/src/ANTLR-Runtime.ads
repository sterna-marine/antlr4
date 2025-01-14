-- €

with Ada.Containers;
with Ada.Containers.Vectors;
with Ada.Containers.Hashed_Sets;
with AdaForge.Utils.Optionals;
use AdaForge.Utils;

use Ada.Containers;

package ANTLR.Runtime is

   -- ------- --
   -- UString --
   -- ------- --
   package UStrings renames Ada.Strings.Wide_Wide_Unbounded;
   subtype WWString is Wide_Wide_String;
   subtype UString is Ada.Strings.Wide_Wide_Unbounded.Unbounded_Wide_Wide_String;
   Null_UString renames Ada.Strings.Wide_Wide_Unbounded.Null_Unbounded_Wide_Wide_String;

   function To_WWString (Source : in Unbounded_Wide_Wide_String) return Wide_Wide_String
      renames Ada.Strings.Wide_Wide_Unbounded.To_Wide_Wide_String;
   
   function To_Unbounded_UString (Source : in Wide_Wide_String) return Unbounded_Wide_Wide_String
      renames Ada.Strings.Wide_Wide_Unbounded.To_Unbounded_Wide_Wide_String;

   function Hash (Key : UString) return Ada.Containers.Hash_Type;

   -- ---------------- --
   -- Optional_UString --
   -- ---------------- --
   package Option_UString is new AdaForge.Util.Optionals (UString);
   subtype Optional_UString is Option_UString.Optional;

   -- ------------ --
   -- UString_List --
   -- ------------ --
   package UString_Container is new Ada.Containers.Vectors 
      (Index_Type => Natural, Element_Type => UString, "=" => "=");
   subtype UString_List is UString_Container.Vector;

   -- ------- --
   -- Integer --
   -- ------- --
   function Hash (Key : Integer) return Ada.Containers.Hash_Type;

   -- ---------------- --
   -- Optional_Integer --
   -- ---------------- --
   package Option_Integer is new AdaForge.Util.Optionals (Integer);
   subtype Optional_Integer is Option_Integer.Optional; -- renames

   -- ------------ --
   -- Integer_List --
   -- ------------ --
   package Integer_Container is new Ada.Containers.Vectors 
      (Index_Type => Natural, Element_Type => Integer, "=" => "=");
   subtype Integer_List is Integer_Container.Vector;

   -- --------------- --
   -- Set_of_Integers --
   -- --------------- --
   function Hash (Element : Integer) return Hash_Type;
   function Equivalent_Elements (Left, Right : Integer) return Boolean
      is (Hash (Left) = Hash (Right));
   package Integer_Sets is new Ada.Containers.Hashed_Sets (
      Element_Type        => Integer,
      Hash                => Hash,
      Equivalent_Elements => Equivalent_Elements,
      "="                 => "=");
   subtype Set_of_Integers is Integer_Sets.Set;

   -- ------------------------ --
   -- Set_of_Optional_Integers --
   -- ------------------------ --
   package Option_Integers is new AdaForge.Util.Optionals (Set_of_Integers);
   subtype Set_of_Optional_Integers is Option_Integers.Optional;

end ANTLR.Runtime;