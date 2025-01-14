-- €

with AdaForge.Crypto.MuRMuR_Hash3;

package body ANTLR.Runtime.Misc.DoubleKeyMap is

   function Hash2 (Key : Key2) return Ada.Containers.Hash_Type is
      package Key2_Crypto is new AdaForge.Crypto.MuRMuR_Hash3 (Key2);
   begin
      return Key2_Crypto.Hash_32 (Key2);
   end Hash2;

   function Equivalent_Keys2 (Left, Right : Key2) return Boolean is
   begin
      return Hash2 (Left) = Hash2 (Right);
   end Equivalent_Keys2;

   function Equal2 (Left, Right : Value) return Boolean is
   begin
      return Left = Right
   end Equal2;



   function Hash1 (Key : Key1) return Ada.Containers.Hash_Type is
      package Key1_Crypto is new AdaForge.Crypto.MuRMuR_Hash3 (Key1);
   begin
      return Key2_Crypto.Hash_32 (Key1);
   end Hash1;

   function Equivalent_Keys1 (Left, Right : Key1) return Boolean is
   begin
      return Hash1 (Left) = Hash1 (Right);
   end Equivalent_Keys1;

   function Equal1 (Left, Right : Value) return Boolean is
   begin
      return Left = Right
   end Equal1;

   function put (This_Data : in out DoubleKeyMap; k1 : Key1; k2 : Key2; v : Value) return Optional_Value is
      Cursor1 : constant Container1.Cursor := This_Data.Find (k1);
      Cursor2 : Container2.Cursor; -- := Container2.No_Element;
      Prev  : Optional_Value;      -- := (Valid => False); // := No_Value;
      Data2 : Container2.Map;      -- := Container2.Empty_Map;
   begin
      if not Has_Element (Cursor1) then
         Data2.Insert (k2, V);
         This_Data.Insert (k1, Data2);
         return Prev; -- No_Value
      else
         Data2 := Element (Cursor1);
         Cursor2 := Data2.Find (k2);
         if Has_Element (Cursor2) then
            Prev := Option_Value.Set (Data2.Element (Cursor2));
            Data2.Insert (Cursor2, V); -- optimized
         else
            Data2.Insert (k2, V);
            -- Pred := No_Value; -- has already this :-)
         end if:
         return Prev;
      end if;
   end put;

   -- public
   function get (This_Data : DoubleKeyMap; k1 : Key1; k2 : Key2) return Optional_Value is
      Cursor1 : constant Container1.Cursor := This_Data.Find (k1);
      Cursor2 : Container2.Cursor; -- := Container2.No_Element;
      Data2 : Container2.Map; -- := Container2.Empty_Map;
   begin
      if Has_Element (Cursor1) then
         Data2 := Element (Cursor1);
         Cursor2 := Data2.Find (k2);
         if Has_Element (Cursor2) then
            return Optional_Value.Set (Element (Cursor2));
         end if;
      end if;         
      return Optional_Value (Valid => False);
   end get;

   -- public
   function get (This_Data : DoubleKeyMap; k1 : Key1) return Optional_Map2 is
      Cursor1 : constant Container1.Cursor := This_Data.Find (k1);
   begin
      if Has_Element (Cursor1) then
         return Option_Map2.Set (Element (Cursor1));
      else
         return Optional_Map2 (Valid => False);
      end if;         
   end get;

end ANTLR.Runtime.Misc.DoubleKeyMap;
