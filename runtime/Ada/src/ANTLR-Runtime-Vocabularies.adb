-- €

package body ANTLR.Runtime.Vocabularies is

   procedure Initialize (Self : in out Vocabulary;
                         literalNames : Optional_String_List;
                         symbolicNames : Optional_UString_List) is
   begin
      Self.Initialize (literalNames, symbolicNames, (Is_Valid => False));
   end Initialize;

   procedure Initialize (Self : in out Vocabulary;
                         literalNames  : Optional_UString_List := Vocabulary.EMPTY_NAMES;
                         symbolicNames : Optional_UString_List := Vocabulary.EMPTY_NAMES;
                         displayNames  : Optional_UString_List := Vocabulary.EMPTY_NAMES) is
   begin
      self.literalNames := literalNames;
      self.symbolicNames := symbolicNames;
      self.displayNames := displayNames;
   end Initialize;

   function fromTokenNames (tokenNames : Optional_UString_List) return Vocabulary is
      Result : Vocabulary;
   begin
      if not tokenNames.Is_Empty or not (tokenNames.Length > 0) then --TOFIX
            return EMPTY_VOCABULARY;
      end if;

      Result.literalNames := tokenNames;
      Result.symbolicNames := tokenNames;
      for i in 0 .. tokenNames.Length - 1 loop
         if not Is_Valid (tokenNames.Element (i)) then
            goto CONTINUE;
         end if;
         firstChar : constant Optional_UString := tokenNames.First_Element;
         if Is_Valid (firstChar) then
            if firstChar = "\'" then
               Result.symbolicNames.Insert (Key => i, New_Item => (Valid => False));
               goto CONTINUE;
            elsif To_Upper (firstChar) /= firstChar then
               Result.literalNames.Insert (Key => i, New_Item => (Valid => False));
               goto CONTINUE;
            end if;
         end if;

         -- wasn't a literal or symbolic name
         Result.literalNames.Insert (Key => i, New_Item => (Valid => False));
         Result.symbolicNames.Insert (Key => i, New_Item => (Valid => False));
         <<CONTINUE>>
      end loop;
      return Result;
   end fromTokenNames;

   function getLiteralName (This : Vocabulary; tokenType : Token_Kind) return Optional_String is
   begin
      if tokenType in 0 .. This.literalNames.Length -1 then
         return This.literalNames.Element (tokenType);
      else
         return (Valid => False);
      end if;
   end getLiteralName;

   function getSymbolicName (This : Vocabulary; tokenType : Token_Kind) return Optional_String is
   begin
      if tokenType in 0 .. This.symbolicNames.Length - 1 then
            return This.symbolicNames.Element (tokenType);
      elsif tokenType = EOF then
            return "EOF";
      else
         return (Valid => False);
      end if;
   end getSymbolicName;

   function getDisplayName (This : Vocabulary; tokenType : Token_Kind) return UString is
   begin
      if tokenType in 0 .. This.displayNames.Length -1 then
         displayName : constant Optional_UString := This.displayNames.Element (tokenType);
            if Is_Valid (displayName) then
               return displayName;
            end if;
      end if;

      literalName : constant Optional_UString := This.getLiteralName (tokenType);
      if Is_Valid (literalName) then
            return literalName;
      end if;
      
      symbolicName : constant Optional_UString := getSymbolicName (tokenType);
      if Is_Valid (symbolicName) then
            return symbolicName;
      end if;

      return UString (tokenType);
   end getDisplayName;

   procedure hash (This : Vocabulary; hasher : in out Hasher) is
   begin
      hasher.combine (ObjectIdentifier (This));
   end hash;

end ANTLR.Runtime.Vocabularies;
