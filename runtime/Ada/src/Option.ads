generic
   type Element_Type is private;

package Option is

   type Optional (Valid : Boolean := False) is record
      case Valid is
         when True  => Element : Element_Type;
         when False => null;
      end case;
   end record;

   No_Value        : constant Optional := (Valid => False);
   No_Element      : constant Optional := (Valid => False);
   Invalid_Element : constant Optional := (Valid => False);

   Invalid_Optional_Value : exception;

   -- ? -> Boolean
   function Is_Valid (This : Optional) return Boolean
      is (This.Valid);

   -- Element? -> Optional
   function Maybe (Element : Element_Type) return Optional;

   -- Optional as? Element_Type -> Optional
   function Maybe (This : Optional; Default : Element_Type) return Optional;

   -- Element as! Element_Type
   function Maybe (This : Optional) return Element_Type;

   -- Element! -> Element_Type
   function Value (This : Optional) return Element_Type;

   -- Element ?? Default -> Element_Type
   function Value (This : Optional; Default : Element_Type) return Element_Type;

   -- --------- --
   -- Get Value --
   -- --------- --
   function Get (This : Optional) return Boolean
      is (This.Valid);

   -- --- --
   -- Set --
   -- --- --
   procedure Set (This : in out Optional; Element : Element_Type);

   function Set (Element : Element_Type) return Optional
      is (Valid => True, Element => Element);

   -- ----- --
   -- unset --
   -- ----- --

   procedure Unset (This : in out Optional);

   function Unset return Optional
      is (Valid => False);

   -- ---- --
   --  As
   -- ---- --

   function As (Element : Element_Type) return Optional;

   -- ------------------------------
   -- with a common (shared objectt);
   -- ------------------------------
   function Is_Valid return Boolean;

   procedure Set (Element : Element_Type);
   -- for enumerations
   --  procedure Value (Value : String);
   --  procedure Val (Pos : Integer);
   --  procedure Enum_Val (Enum_Val : Integer);

   procedure Unset;

end Option;