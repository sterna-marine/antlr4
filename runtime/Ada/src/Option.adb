package body Option is

   -- ---
   -- Set
   -- ---

   procedure Set (This : in out Optional; Element : Element_Type) is
   begin
      This := (Is_Valid => True, Element => Element);
   end Set;

   procedure Value (This : in out Optional; Value : String) is
   begin
      This := (Is_Valid => True, Element => Element_Type'Value (Value));
   exception
         when Constraint_Error =>
            This := (Is_Valid => False);
   end Value;

   procedure Val (This : in out Optional; Pos : Integer) is
   begin
      This := (Is_Valid => True, Element => Element_Type'Val (Pos));
   exception
         when Constraint_Error =>
            This := (Is_Valid => False);
   end Val;

   procedure Enum_Val (This : in out Optional; Enum_Val : Integer) is
   begin
      This := (Is_Valid => True, Element => Element_Type'Enum_Val (Enum_Val));
   exception
         when Constraint_Error =>
            This := (Is_Valid => False);
   end Enum_Val;

   -- -----
   -- Unset
   -- -----

   procedure Unset (This : in out Optional) is
   begin
      This := (Is_Valid => False);
   end Unset;

   function As (Element : Element_Type) return Optional is
      : Optional (Is_Valid => True);
   begin
      declare
      begin
         := (Is_Valid => True, Element => Element);
      exception
         when Constraint_Error =>
            := (Is_Valid => False);
      end;
      return Var;
   end As;

   -- ------------------------------
   -- with a common (shared objectt);
   -- ------------------------------
   Object : Optional;

   function Is_Valid return Boolean
      is (Object.Is_Valid);

   procedure Set (Element : Element_Type) is
   begin
      Object := (Is_Valid => True, Element => Element);
   end Set;

   procedure Value (Value : String) is
   begin
      Object := (Is_Valid => True, Element => Element_Type'Value (Value));
   exception
         when Constraint_Error =>
            Object := (Is_Valid => False);
   end Value;

   procedure Val (Pos : Integer) is
   begin
      Object := (Is_Valid => True, Element => Element_Type'Val (Pos));
   exception
         when Constraint_Error =>
            Object := (Is_Valid => False);
   end Val;

   procedure Enum_Val (Enum_Val : Integer) is
   begin
      Object := (Is_Valid => True, Element => Element_Type'Enum_Val (Enum_Val));
   exception
         when Constraint_Error =>
            Object := (Is_Valid => False);
   end Enum_Val;

   procedure Unset is
   begin
      Object := (Is_Valid => False);
   end Unset;

end Option;