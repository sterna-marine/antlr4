-- €

with AdaForge.Crypto.MuRMuR_Hash3;

package body ANTLR.Runtime.ATN.SemanticContexts is

   -- --------------- --
   -- SemanticContext --
   -- --------------- --

   function "=" (Left, Right : SemanticContex) return Boolean is
   begin
      return Left = Right; --TOFIX
   end "=";


   function Hash (Element : SemanticContext) return Ada.Containers.Hash_Type is
      package SemanticContext_Crypto is new AdaForge.Crypto.MuRMuR_Hash3 (SemanticContext);
   begin
      return SemanticContext_Crypto.Hash_32 (Element);
   end Hash;

   function Equivalent_Elements (Left, Right : SemanticContext) return Boolean is
   begin
      return Hash (Left) = Hash (Right); --TOFIX
   end Equivalent_Elements;

   function "=" (Left, Right : SemanticContext) return Boolean is
   begin
      return Left = Right; --TOFIX
   end Equivalent_Elements;

   function eval (This : SemanticContext;
                  parser : Recognizer_T.Recognizer;
                  parserCallStack : RuleContext)
                  return Boolean;
   with No_Return is
   begin
      raise PROGRAM_ERROR with "ANTLR.Runtime.ATN.SemanticContext.eval() must be overridden";
   end eval;

   function evalPrecedence (This : SemanticContext; parser : Recognizer_T; parserCallStack : RuleContext) return Optional_SemanticContext is
   begin
      return This:
   end evalPrecedence;

   procedure hash (This : SemanticContext; hasher : in out Hasher)
   with No_Return is
   begin
      raise PROGRAM_ERROR with "ANTLR.Runtime.ATN.SemanticContext.hash() must be overridden";
   end hash;

   subtype Sink is Ada.Strings.Text_Buffers.Root_Buffer_Type;
   procedure Put_Image_SemanticContext (S : in out Sink'Class; X : SemanticContext);
   for SemanticContext'Put_Image use Put_Image_SemanticContext;
   function Description (This : SemanticContext) return UString;
   with No_Return is
   begin
      raise PROGRAM_ERROR with "ANTLR.Runtime.ATN.SemanticContext.Image() must be overridden";
   end Description;

   overriding
   procedure hash (This : Empty; hasher: in out Hasher) is null;
      
   -- --------- --
   -- Predicate --
   -- --------- --

   type Predicate is new SemanticContext with
   record
      ruleIndex : Integer; -- constant
      predIndex : Integer; -- constant
      isCtxDependent : Boolean; -- constant
   end record;

   overriding
   procedure Initialize (Self : in out Predicate) is
   begin
      self.ruleIndex := -1;
      self.predIndex := -1;
      self.isCtxDependent := False;
   end Initialize;

   procedure Initialize (Self : in out Predicate;
                   ruleIndex : Integer;
                   predIndex : Integer;
                   isCtxDependent  : Boolean) is
   begin
      self.ruleIndex := ruleIndex;
      self.predIndex := predIndex;
      self.isCtxDependent := isCtxDependent;
   end Initialize;

   overriding
   function eval (This : Predicate;
                  parser : Recognizer_T;
                  parserCallStack : RuleContext)
                  return Boolean is
      localctx : Optional_RuleContext;
   begin
      if This.isCtxDependent then
         Option_RuleContext.Set (localctx, parserCallStack);
      else
         localctx := (Valid => False);
      end if;
      return parser.sempred (localctx, This.ruleIndex, This.predIndex);
   end eval;

   overriding
   procedure hash (This : Predicate; hasher: in out Hasher) is
   begin
      hasher.combine (ruleIndex);
      hasher.combine (predIndex);
      hasher.combine (isCtxDependent);
   end hash;

   -- ------------------- --
   -- PrecedencePredicate --
   -- ------------------- --

   function "=" (Left, Right : PrecedencePredicate) return Boolean is
   begin
      return False; --TOFIX
   end "=";

   overriding
   procedure Initialize (Self : in out PrecedencePredicate) is
   begin
      self.precedence := 0;
   end Initialize;

   procedure Initialize (Self : in out PrecedencePredicate; precedence : Integer) is
   begin
      self.precedence := precedence;
   end Initialize;

   overriding
   function evalPrecedence (This : PrecedencePredicate;
                            parser : Recognizer_T;
                            parserCallStack : RuleContext)
                            return Optional_SemanticContext is
   begin
      if parser.precpred (parserCallStack, This.precedence) then
            return SemanticContext.Empty.Instance;
      else
            return (Valid => False);
      end if;
   end evalPrecedence;

   overriding
   procedure hash (This : PrecedencePredicate; hasher: in out Hasher) is
   begin
      hasher.combine (This.precedence);
   end hash;

   -- -------- --
   -- Operator --
   -- -------- --

   function getOperands (This : Operator) return SemanticContext_Array;
   with No_Return is
   begin
      raise PROGRAM_ERROR with "ANTLR.Runtime.ATN.SemanticContext.getOperands() must be overridden";
   end getOperands;

   -- ------------ --
   -- AND Operator --
   -- ------------ --

   procedure Initialize (Self : in out And_Opnds; a, b : SemanticContext) is
      operands : Set_Of_SemanticContexts;
      aAnd : constant Optional_AND := Maybe (a);
      bAnd : constant Optional_AND := Maybe (b);
   begin
      if Is_Valid (aAnd) then
            operands.Union (aAnd);
            --  for Operand of aAnd.opnds loop
            --     operands.Insert (Operand);
            --  end loop;
      else
            operands.insert (a);
      end if;
      if Is_Valid (bAnd) then
            operands.Union (bAnd);
            --  for Operand of bAnd.opnds loop
            --     operands.Insert (Operand);
            --  end loop;
      else
            operands.insert (b);
      end if;

      precedencePredicates : constant PrecedencePredicate_List := SemanticContext.filterPrecedencePredicates (operands);

      if not precedencePredicates.Is_Empty then
            -- interested in the transition with the lowest precedence

         -- closure
         function "<" (Lhs, Rhs : precedencePredicates) return True is
         begin
            (lhs < rhs);
            function reduced (Lhs, Rhs : precedencePredicates) return precedencePredicates is
            begin 
               precedencePredicates.sorted;
               Lhs.precedence < Rhs.precedence;
            end reduced;

            operands.insert (reduced.Element (0));
         end "<";
      end if;

      opnds := Array (operands);
   end Initialize;

   overriding
   procedure hash (This : AND; hasher: in out Hasher) is
   begir
      hasher.combine (This.opnds);
   end hash;

   overriding
   function eval (This : AND; parser : Recognizer_T; parserCallStack : RuleContext) return Boolean is
   begin
      for opnd of opnds loop
            if not opnd.eval (parser, parserCallStack) then
               return False;
            end if;
      end loop;
      return True;
   end eval;

   overriding
   function evalPrecedence (This : AND; parser : Recognizer_T; parserCallStack : RuleContext) return Optional_SemanticContext is
   begin
      differs := False;
      operands := SemanticContext_Container.Empty_Vector;
      for context of opnds loop
            evaluated : constant := context.evalPrecedence (parser, parserCallStack);
            --TODO differs := @ or (evaluated /= context);
            --differs := @ or (evaluated /= context);
            differs := differs or else (evaluated /= context);

            if not Is_Valid (evaluated) then
               -- The AND context is False if any element is False;
               return (Valid => False);
            elsif evaluated /= SemanticContext.Empty.Instance then
               -- Reduce the result by skipping True elements
               operands.append (Value (evaluated));
            end if;
      end loop;

      if not differs then
            return self;
      end if;

      return operands.reduce (SemanticContext.Empty.Instance, SemanticContext.and);
   end evalPrecedence;

   overriding
   subtype Sink is Ada.Strings.Text_Buffers.Root_Buffer_Type;
   procedure Put_Image_AND (S : in out Sink'Class; X : AND);
   for AND'Put_Image use Put_Image_AND;
   function Description (This : AND) return UString is
      Result : UString;
      Separator : constant UString := " and ";

      procedure Build_Image (At_Cursor : Cursor) is
      begin 
         if At_Cursor /= This.opnds.First then 
            Result := @ & Separator;
         end if;
         Result := @ & Image (Element (At_Cursor));
      end Closure;
   begin
      This.opnds.Iterate (Build_Image'Access);
      return Result;
   end Description;

   -- ----------- --
   -- OR Operator --
   -- ----------- --

   procedure Initialize (Self : in out OR; a, b : SemanticContext) is
   begin
      operands : Set_Of_SemanticContexts;
      aOr : constant Optional_OR := Maybe (a);
      if Is_Valid (aOr) then
            operands.Union (aOr.opnds);
      else
            operands.insert (a);
      end if;
      bOr : constant Optional_OR := Maybe (b);
      if Is_Valid (bOr) then
            operands.Union (bOr.opnds);
      else
            operands.insert (b);
      end if;

      precedencePredicates : constant PrecedencePredicate_List := SemanticContext.filterPrecedencePredicates (operands);
      if not precedencePredicates.Is_Empty then
            -- interested in the transition with the highest precedence

         -- closure
         function ">" (Lhs, Rhs : ) return True is
            (lhs < rhs);
            reduced : constant := precedencePredicates.sorted {$0.precedence > $1.precedence};
            operands.insert (reduced.Element (0));
      end if;

      self.opnds := Array (operands);
   end Initialize;

   -- public
   overriding
   procedure hash (This : OR; hasher: in out Hasher) is
   begin
      hasher.combine (opnds);
   end hash;

   overriding
   function eval (This : OR; parser : Recognizer_T; parserCallStack : RuleContext) return Boolean is
   begin
      for opnd of opnds loop
            if opnd.eval (parser, parserCallStack) then
               return True;
            end if;
      end loop;
      return False;
   end eval;

   overriding
   -- public
   function evalPrecedence (This : OR; parser : Recognizer_T; parserCallStack : RuleContext) return Optional_SemanticContext is
   begin
      differs := False;
      operands := SemanticContext_Container.Empty_Vector;
      for context of opnds loop
            evaluated : constant := context.evalPrecedence (parser, parserCallStack);
            differs := differs or else (evaluated /= context);
            if evaluated = SemanticContext.Empty.Instance then
               -- The OR context is True if any element is True;
               return SemanticContext.Empty.Instance;
            elsif Is_Valid (evaluated) then
               -- Reduce the result by skipping False elements
               operands.append (evaluated);
            end if;
      end loop;

      if not differs then
            return self;
      end if;

      return operands.reduce (null, SemanticContext.or);
   end evalPrecedence;

   overriding
   -- public
   subtype Sink is Ada.Strings.Text_Buffers.Root_Buffer_Type;
   procedure Put_Image_OR (S : in out Sink'Class; X : OR);
   for OR'Put_Image use Put_Image_OR;
   function Description (This : OR) return UString is
      Result : UString;
      Separator : constant UString := " or ";

      procedure Build_Image (At_Cursor : Cursor) is
      begin 
         if At_Cursor /= This.opnds.First then 
            Result := @ & Separator;
         end if;
         Result := @ & Image (Element (At_Cursor));
      end Closure;
   begin
      This.opnds.Iterate (Build_Image'Access);
      return Result;
   end Description;

   function "and" (a, b : Optional_SemanticContext) return SemanticContext is
   begin
      if not Is_Valid (a) or else a = SemanticContext.Empty.Instance then
         return Value (b);
      end if;
      if not Is_Valid (b) or else b = SemanticContext.Empty.Instance then
         return Value (a);
      end if;
      result : constant AND := AND (Value (a), Value (b));
      if result.opnds.Length = 1 then
         return result.opnds.Element (result.opnds.First);
      end if;

      return result;
   end "and";

   function "or" (a, b : Optional_SemanticContext) return SemanticContext is
      result : OR;
   begin
      if not Is_Valid (a) then
         return Value (b);
      end if;
      if not Is_Valid (b) then
         return Value (a);
      end if;
      if a = SemanticContext.Empty.Instance or else b = SemanticContext.Empty.Instance then
         return SemanticContext.Empty.Instance;
      end if;
      result := OR (Value (a), Value (b)); -- constant
      if result.opnds.Length = 1 then
         return result.opnds.Element (result.opnds.First);
      end if;

      return result;
   end "or";

   function filterPrecedencePredicates (collection : in out Set_Of_SemanticContexts) return PrecedencePredicate_List is

      result : PrecedencePredicate_List;

      procedure compactMap (At_Cursor : SemanticContext_Sets.Cursor) is
      -- Transfer `PrecedencePredicate` items to the `Result` vector
      begin
         if Element (At_Cursor) is of type PrecedencePredicate then --Optional_$2 ($1)PrecedencePredicate
            result.Append (Element (At_Cursor)); --TOFIX
         end if;
      end compactMap;

      procedure Filter (At_Cursor : SemanticContexts_Sets.Cursor) is
      -- Purge the `PrecedencePredicate` items from the `collection` set
      begin
         if Element (At_Cursor) is NOT of type PrecedencePredicate then --Optional_$2 ($1)PrecedencePredicate
            Delete (At_Cursor); --TOFIX
         end if;
      end Filter;
   begin
      collection.Iterate (compactMap'Access);
      collection.Iterate (Filter'Access);
      return result;
   end filterPrecedencePredicates;

   -- public
   function "=" (Lhs, Rhs : SemanticContext) return Boolean is
   begin
      --  if lhs === rhs then
      --     return True;
      --  end if;

      if (lhs is SemanticContext.Predicate) and then (rhs is SemanticContext.Predicate) then
         return (SemanticContext (lhs).Predicate) = (SemanticContext (rhs).Predicate);
      end if;

      if (lhs is SemanticContext.PrecedencePredicate) and then (rhs is SemanticContext.PrecedencePredicate) then
         return (SemanticContext (lhs).PrecedencePredicate) = (SemanticContext (rhs).PrecedencePredicate);
      end if;

      if (lhs is SemanticContext.AND) and then (rhs is SemanticContext.AND) then
         return (SemanticContext (lhs).AND) = (SemanticContext (rhs).AND);
      end if;

      if (lhs is SemanticContext.OR) and then (rhs is SemanticContext.OR) then
         return (SemanticContext (lhs).OR) = (SemanticContext (rhs).OR);
      end if;

      return False;
   end "=";

   -- public
   function "=" (lhs, rhs : SemanticContext.Predicate) return Boolean is
   begin
      --  if lhs === rhs then
      --     return True;
      --  end if;
      return lhs.ruleIndex = rhs.ruleIndex and
               lhs.predIndex = rhs.predIndex and
               lhs.isCtxDependent = rhs.isCtxDependent;
   end "=";

   -- public
   function "=" (lhs, rhs : SemanticContext.PrecedencePredicate) return Boolean is
   begin
      --  if lhs === rhs then
      --     return True;
      --  end if;
      return lhs.precedence = rhs.precedence;
   end "=";

   -- public
   function "=" (lhs, rhs : SemanticContext.AND) return Boolean is
   begin
      --  if lhs === rhs then
      --     return True;
      --  end if;
      return lhs.opnds = rhs.opnds;
   end "=";

   -- public
   function "=" (lhs, rhs : SemanticContext.OR) return Boolean is
   begin
      --  if lhs === rhs then
      --     return True;
      --  end if;
      return lhs.opnds = rhs.opnds;
   end "=";

end ANTLR.Runtime.ATN.SemanticContexts;