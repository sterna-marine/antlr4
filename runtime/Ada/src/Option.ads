generic
   type Element_Type is (<>); -- private;

package Option is

   type Optional (Is_Valid : Boolean := False) is record
      case Is_Valid is
         when True  => Element : Element_Type;
         when False => null;
      end case;
   end record;

   function Is_Valid (This : Optional) return Boolean
      is (This.Is_Valid);

   -- ---
   -- Set
   -- ---
   procedure Set (This : in out Optional; Element : Element_Type);

   function Set (Element : Element_Type) return Optional
      is (Is_Valid => True, Element => Element);

   -- for enumeration from a String Image
   procedure Value (This : in out Optional; Value : String);

   -- for enumeration positional clause
   procedure Val (This : in out Optional; Pos : Integer);

   -- for enumeration representation clause
   procedure Enum_Val (This : in out Optional; Enum_Val : Integer);


   -- -----
   -- unset
   -- -----

   procedure Unset (This : in out Optional);

   function Unset return Optional
      is (Is_Valid => False);

   -- -----
   -- As
   -- -----

   function As (Element : Element_Type) return Optional;

   -- ------------------------------
   -- with a common (shared objectt)
   -- ------------------------------
   function Is_Valid return Boolean;

   procedure Set (Element : Element_Type);
   -- for enumerations
   procedure Value (Value : String);
   procedure Val (Pos : Integer);
   procedure Enum_Val (Enum_Val : Integer);

   procedure Unset;

end Option;