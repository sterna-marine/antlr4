-- €

with Ada.Characters.Latin_1, Unicode;

use Ada.Characters, Unicode;

package ANTLR.Runtime.Misc.Utils is

   -- public static
   function escapeWhitespace (s : UString; escapeSpaces : Boolean) return UString is
      Buf : UString := "";
   begin
      for c in s loop
         if c = Latin_1.Space and then escapeSpaces then
               Buf := @ & To_Unicode (16#00B7#);
         elsif c = Latin_1.HT then
                  Buf := @ & "\\t"; -- Latin_1.HT
         elsif c = Latin_1.LF then
               Buf := @ & "\\n";    -- Latin_1.LF
         elsif c = Latin_1.CR then
               Buf := @ & "\\r";    -- Latin_1.CR
         else
               Buf.Append (c);
         end if;
      end loop;
      return Buf;
   end escapeWhitespace;

   -- public static
   function toMap (Keys : UString.Container.Vector) return TokenID_Container.Map is
      M : TokenID_Container.Map;
   begin
      --  for V of Keys loop
      --     M.Append (V, index);
      --  end loop;
      for K_Cursor in Keys loop
         M.Insert (Key      => Keys.Element (K_Cursor),
                   New_Item => Keys.To_Index (K_Cursor));
      end loop;
      return M;
   end toMap;

end ANTLR.Runtime.Misc.Utils;
