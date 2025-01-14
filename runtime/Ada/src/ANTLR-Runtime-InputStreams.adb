-- €

with Ada.Wide_Wide_Text_IO;
with AdaForge.Framework.Aspect;

use Ada;
use AdaForge.Framework;
use AdaForge.Framework.Aspect;

package body ANTLR.Runtime.InputStreams is

   overriding
   procedure Initialize (Self : in out ANTLRInputStream) is
   begin
      Self.n := 0;
      Self.data := "";
   end Initialize;

   procedure Initialize (Self : in out ANTLRInputStream; input : UString) is
   begin
      self.data := array (Natural range <>) of input.unicodeScalars;
      self.n := Self.data.Length;
   end Initialize;

   procedure Initialize (Self : in out ANTLRInputStream; 
                         data : UString;
                         numberOfActualUnicodeScalarsInArray : Integer) is
   begin
      self.data := data;
      self.n := numberOfActualUnicodeScalarsInArray;
   end Initialize;

   procedure Initialize (Self : in out ANTLRInputStream;
                         data : Character_List,
                         numberOfActualUnicodeScalarsInArray : Integer) is
      string : constant UString := To_String (data);
   begin
      self.data := Array (string.unicodeScalars);
      self.n := numberOfActualUnicodeScalarsInArray;
   end Initialize;

   procedure reset (This : ANTLRInputStream) is
   begin
      This.p := 0;
   end reset;

   procedure consume (This : ANTLRInputStream) is
   begin
      if This.p >= This.n then
         pragma assert (This.LA (1) = EOF, "Expected: LA (1) = EOF");
         raise ANTLRError.illegalState with "cannot consume EOF";

      elsif Is_Active (Aspect.DEBUG) then
         Wide_Wide_Text_IO.Put_Line ("prev p=" & p & ", c=" & (char)data.Element (p));

      else This.p < This.n then
         This.p := @ + 1;
         if Is_Active (Aspect.DEBUG) then
            Wide_Wide_Text_IO.Put_Line ("p moves to " & This.p & " (c='" & (char)data.Element (p) & "')");
         end if;
      end if;
   end consume;

   function LA (This : ANTLRInputStream; i : Integer) return Integer is
      i : Integer := i;
   begin
      if i = 0 then
         return 0;  -- undefined

      elsif i < 0 then
         i := @ + 1; -- e.g., translate LA (-1) to use offset i=0; then data[p+0-1]
         if (This.p + i - 1) < 0 then
            return EOF;  -- invalid; no char before first char
         end if;

      elsif (This.p + i - 1) >= This.n then
         if Is_Active (Aspect.DEBUG) then
            Wide_Wide_Text_IO.Put_Line ("char LA (" & i & ")=EOF; p=" & p);
         end if;
         return EOF;

      elsif Is_Active (Aspect.DEBUG) then
         Wide_Wide_Text_IO.Put_Line ("char LA (" & i'Image & ")=" & Character (data.Element (This.p + i - 1)) & "; p=" & p'Image);
         Wide_Wide_Text_IO.Put_Line ("LA (" & i'Image & "); p=" & p'Image & " n=" & n'Image & " data.length=" & This.data.Length);

      else
         return Integer (This.data (This.p + i - 1).value);
      end if;
   end LA;

   procedure release (This : ANTLRInputStream; marker : Integer) is null;

   procedure seek (This : ANTLRInputStream; index : Integer) is
      index : Integer := index;
   begin
      if index <= This.p then
         This.p := index; -- just jump; don't update stream state (line,  .. );
         return;
      else
         -- seek forward, consume until p hits index or n (whichever comes first);
         index := min (index, This.n);
         while This.p < index loop
            This.consume;
         end loop;
      end if;
   end seek;

   function getText (This : ANTLRInputStream; interval : Interval) return UString is
      start : constant Integer := interval.a;
      stop  : constant Integer := min (This.n, interval.b + 1);
   begin
      if start >= This.n then
         return "";
      else
         unicodeScalarView : UString := UString.UnicodeScalarView;
         unicodeScalarView.append (contentsOf => This.data.Element (start .. stop - 1));
         return UString (unicodeScalarView);
      end if;
   end getText;

   function toString (This : ANTLRInputStream) return UString is
      unicodeScalarView : UString := UString.UnicodeScalarView;
   begin
      unicodeScalarView.append (contentsOf => data);
      return UString (unicodeScalarView);
   end toString;

end ANTLRInputStream;
