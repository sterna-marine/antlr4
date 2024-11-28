with Option;
with Ada.Text_IO;
use Ada.Text_IO;

-- with ANTLR.Runtime.ATN.ATNStates;
-- with ANTLR.Runtime.ATN;
-- with ANTLR.Runtime.ATN.AbstractPredicateTransition;

procedure Main is

   type Color is (Blue, Green, Red);
   for Color use (
      Blue => Character'Pos ('B'),
      Green => Character'Pos ('G'),
      Red  => Character'Pos ('R'));
   for Color'Size use 8;

   package Optional_Color is new Option (Color);
   use Optional_Color;

   My_Color : Optional_Color.Optional;

begin
   Put_Line (My_Color'Image);
   Put_Line ("===============");
   Put_Line ("Set (My_Color, Red)");
   Set (My_Color, Red);
   Put_Line (My_Color'Image);
   Put_Line ("===============");
   Put_Line ("Set (My_Color, ""Red"")");
   Value (My_Color, "Red");
   Put_Line (My_Color'Image);
   Put_Line ("===============");
   Put_Line ("Set (My_Color, ""YELLOW"")");
   Value (My_Color, "YELLOW");
   Put_Line (My_Color'Image);
   Put_Line ("===============");
   Put_Line ("Set (My_Color, " & Color'Pos (Color'Last)'Image & ")");
   Val (My_Color, Color'Pos (Color'Last));
   Put_Line (My_Color'Image);
   Put_Line ("===============");
   Put_Line ("Set (My_Color, " & Character'Pos ('R')'Image & ")");
   Enum_Val (My_Color, Character'Pos ('R'));
   Put_Line (My_Color'Image);
   Put_Line ("===============");

   Put_Line ("===============");
   Put_Line ("Set (Red)");
   Set (Red);
   Put_Line (My_Color'Image);
   Put_Line ("===============");
   Put_Line ("Set (""Red"")");
   Value ("Red");
   Put_Line (My_Color'Image);
   Put_Line ("===============");
   Put_Line ("Set (""YELLOW"")");
   Value ("YELLOW");
   Put_Line (My_Color'Image);
   Put_Line ("===============");
   Put_Line ("Set (" & Color'Pos (Color'Last)'Image & ")");
   Val (Color'Pos (Color'Last));
   Put_Line (My_Color'Image);
   Put_Line ("===============");
   Put_Line ("Set (" & Character'Pos ('R')'Image & ")");
   Enum_Val (Character'Pos ('R'));
   Put_Line (My_Color'Image);
   Put_Line ("===============");
end Main;
