with Ada.Strings.Wide_Wide_Unbounded;
with Option;

use Ada.Strings.Wide_Wide_Unbounded;

package ANTLR is

   package UStrings renames Ada.Strings.Wide_Wide_Unbounded;
   subtype WWString is Wide_Wide_String;
   subtype UString is Ada.Strings.Wide_Wide_Unbounded.Unbounded_Wide_Wide_String;
   Null_UString renames Ada.Strings.Wide_Wide_Unbounded.Null_Unbounded_Wide_Wide_String;
  
   function To_WWString (Source : in Unbounded_Wide_Wide_String) return Wide_Wide_String
      renames Ada.Strings.Wide_Wide_Unbounded.To_Wide_Wide_String;
   
   function To_Unbounded_UString (Source : in Wide_Wide_String) return Unbounded_Wide_Wide_String
      renames Ada.Strings.Wide_Wide_Unbounded.To_Unbounded_Wide_Wide_String;

   package Option_Integer is new Option (Integer);
   subtype Optional_Integer is Option_Integer.Optional; -- renames

end ANTLR;