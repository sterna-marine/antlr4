-- €

package Hashable is

   type Hashed_Item is Integer;

   type Hashable is interface;

   function Hash (Key : Hashable) return Hashed_Item;

end Hashable;