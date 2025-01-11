-- €

with Ada.Containers;
with Ada.Containers.Hashed_Maps;

generic
   type V is private;
   function "=" (Left, Right : V) return Boolean;
package ANTLR.Runtime.Tree.ParseTreeListener_Protocol is

   function Hash (Key : ObjectIdentifier) return Ada.Containers.Hash_Type;
   function Equivalent_Keys (Left, Right : ObjectIdentifier) return Boolean;
      is Hash (Left) = Hash (Right);
   package Annotations_Container is new Ada.Containers.Hashed_Maps (
      Key_Type => ObjectIdentifier,
      Element_Type => V,
      Hash => Hash,
      Equivalent_Keys => Equivalent_Keys,
      "=" => "=");

   -- public
   type ParseTreeProperty<V> is tagged with record
      annotations : Annotations_Container.Hashed_Map;
   end record;

   -- public
   overriding
   procedure Initialize (Self : in out ParseTreeProperty) is null;

  -- open
   function get (This : ParseTreeProperty; node : ParseTree) return Optional_V is
   begin
      return annotations.Element (ObjectIdentifier (node));
   end get;

   -- open
   procedure put (This : ParseTreeProperty; node : ParseTree; value : V) is
   begin
      annotations.Element (ObjectIdentifier (node)) := value;
   end put;

   -- open
   procedure removeFrom (This : ParseTreeProperty; node : ParseTree) is
   begin 
      annotations.removeValue (forKey => ObjectIdentifier (node));
   end removeFrom;
end ParseTreeListener_Protocol;
