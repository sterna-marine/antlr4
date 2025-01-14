-- €

with Ada.Containers;
with Ada.Containers.Hashed_Maps;
with AdaForge.Utils.Optionals;
use AdaForge.Utils;

generic
   type V is private;
   function "=" (Left, Right : V) return Boolean;
package ANTLR.Runtime.Tree.ParseTreeProperty is

   package Option_V is new AdaForge.Util.Optionals (V);
   subtype Optional_V is Option_V.Optional;

   function Hash (Key : ObjectIdentifier) return Ada.Containers.Hash_Type;
   function Equivalent_Keys (Left, Right : ObjectIdentifier) return Boolean
      is (Hash (Left) = Hash (Right));
   package Annotations_Dictionary is new Ada.Containers.Hashed_Maps (
      Key_Type => ObjectIdentifier,
      Element_Type => V,
      Hash => Hash,
      Equivalent_Keys => Equivalent_Keys,
      "=" => "=");
   subtype Annotations_Map is Annotations_Dictionary.Map;

   -- public
   type ParseTreeProperty is tagged with record
      annotations : Annotations_Map;
   end record;

   -- public
   overriding
   procedure Initialize (Self : in out ParseTreeProperty);

  -- open
   function get (This : ParseTreeProperty; node : ParseTree) return Optional_V
      is (annotations.Element (ObjectIdentifier (node)));

   -- open
   procedure put (This : ParseTreeProperty; node : ParseTree; value : V);

   -- open
   procedure removeFrom (This : ParseTreeProperty; node : ParseTree);

end ANTLR.Runtime.Tree.ParseTreeProperty;
