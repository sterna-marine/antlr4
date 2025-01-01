package body Option is

   function Value (This : Optional) return Element_Type is
   begin
      if This.Valid then
         return This.Element;
      else
         raise Invalid_Optional_Value; -- with Element_Type'Base'Image;
      end if;
   end Value;

   -- Element ?? Default -> Element_Type
   function Value (This : Optional; Default : Element_Type) return Element_Type is
   begin
      if This.Valid then
         return This.Element;
      else
         return Default;
      end if;
   end Value;

   -- Element? -> Optional
   function Maybe (Element : Element_Type) return Optional is
   begin
      return (Valid => True, Element => Element); --TOFIX
   end Maybe;

   -- Optional as? Element_Type -> Optional
   function Maybe (This : Optional; Default : Element_Type) return Optional is
   begin
      if This.Valid then
         return This;
      else
         return (Valid => True, Element => Default);
      end if;
   end Maybe;

   -- Element as! Element_Type
   function Maybe (This : Optional) return Element_Type is
   begin
      if This.Valid then
         return This.Element;
      else
         raise Invalid_Optional_Value;
      end if;
   end Maybe;

   -- ---
   -- Set
   -- ---

   procedure Set (This : in out Optional; Element : Element_Type) is
   begin
      This := (Valid => True, Element => Element);
   end Set;

   --  procedure Value (This : in out Optional; Value : String) is
   --  begin
   --     This := (Valid => True, Element => Element_Type'Value (Value));
   --  exception
   --        when Constraint_Error =>
   --           This := (Valid => False);
   --  end Value;

   --  procedure Val (This : in out Optional; Pos : Integer) is
   --  begin
   --     This := (Valid => True, Element => Element_Type'Val (Pos));
   --  exception
   --        when Constraint_Error =>
   --           This := (Valid => False);
   --  end Val;

   --  procedure Enum_Val (This : in out Optional; Enum_Val : Integer) is
   --  begin
   --     This := (Valid => True, Element => Element_Type'Enum_Val (Enum_Val));
   --  exception
   --        when Constraint_Error =>
   --           This := (Valid => False);
   --  end Enum_Val;

   -- -----
   -- Unset
   -- -----

   procedure Unset (This : in out Optional) is
   begin
      This := (Valid => False);
   end Unset;

   function As (Element : Element_Type) return Optional is
     X : Optional;
   begin
      declare
      begin
         X := (Valid => True, Element => Element);
      exception
         when Constraint_Error =>
           X := (Valid => False);
      end;
      return X;
   end As;

   -- ------------------------------
   -- with a common (shared objectt);
   -- ------------------------------
   Object : Optional;

   function Is_Valid return Boolean
      is (Object.Valid);

   procedure Set (Element : Element_Type) is
   begin
      Object := (Valid => True, Element => Element);
   end Set;

   --  procedure Value (Value : String) is
   --  begin
   --     Object := (Valid => True, Element => Element_Type'Value (Value));
   --  exception
   --        when Constraint_Error =>
   --           Object := (Valid => False);
   --  end Value;

   --  procedure Val (Pos : Integer) is
   --  begin
   --     Object := (Valid => True, Element => Element_Type'Val (Pos));
   --  exception
   --        when Constraint_Error =>
   --           Object := (Valid => False);
   --  end Val;

   --  procedure Enum_Val (Enum_Val : Integer) is
   --  begin
   --     Object := (Valid => True, Element => Element_Type'Enum_Val (Enum_Val));
   --  exception
   --        when Constraint_Error =>
   --           Object := (Valid => False);
   --  end Enum_Val;

   procedure Unset is
   begin
      Object := (Valid => False);
   end Unset;

end Option;