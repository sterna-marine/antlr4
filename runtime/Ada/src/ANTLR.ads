package ANTLR is

   package Option_Integer is new Option (Integer);
   subtype Optional_Integer is Option_Integer.Optional; -- renames

end ANTLR;