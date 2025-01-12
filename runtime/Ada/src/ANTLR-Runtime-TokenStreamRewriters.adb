-- €

with ANTLR.Runtime.Misc.Exceptions.Errors;

use ANTLR.Runtime.Misc.Exceptions.Errors;

package body ANTLR.Runtime.TokenStreamRewriters is

   -- ---------------- --
   -- RewriteOperation --
   -- ---------------- --

   function Hash_Integer (Key : Integer) return Ada.Containers.Hash_Type is
   begin
      return Ada.Containers.Hash_Type (Key); --TOFIX
   end Hash_Integer;

   function "=" (Left, Right : RewriteOperation) return Boolean
      is (Left = Right); --TOFIX

   function "=" (Left, Right : Optional_RewriteOperation) return Boolean is
      return (Left = Right); --TOFIX

   procedure Initialize (Self : RewriteOperation; index : Integer; tokens : TokenStream) is
   begin
      self.index := index;
      self.tokens := tokens;
   end Initialize;

   procedure Initialize (Self : RewriteOperation; index : Integer; text : Optional_UString; tokens : TokenStream) is
   begin
      self.index := index;
      self.text := text;
      self.tokens := tokens;
   end Initialize;

   procedure Put_Image_RewriteOperation (S : in out Sink'Class; X : RewriteOperation) is
   begin
      S.Wide_Wide_Put (Description (X));
   end Put_Image_RewriteOperation;

   function Description (This : RewriteOperation) return UString is
         opName : constant UString := To_UString (This'External_Tag);
   begin
         return '<' & opName'Image & '@' & This.tokens.get (This.index)'Image & '"' & Value (This.text) & """>"; -- try!
   end Description;

   -- ------------------- --
   -- TokenStreamRewriter --
   -- ------------------- --

   -- -------------- --
   -- InsertBeforeOp --
   -- -------------- --

   overriding
   function execute (This : InsertBeforeOp; buf : in out UString) return Integer is
      text : constant Optional_Text := Maybe (This.text);
      token : constant := This.tokens.get (This.index);
   begin
      if Is_Valid (text) then
         buf.append (text);
      end if;
      if token.getType /= EOF then
         buf.append (Value (token.getText));
      end if;
      return This.index + 1;
   end execute;

   -- ------------- --
   -- InsertAfterOp --
   -- ------------- --

   overriding
   procedure Initialize (Self : in out InsertAfterOp;
                         index : Integer;
                         text : Optional_UString;
                         tokens : TokenStream) is
   begin
      InsertBeforeOp (Self).Initialize (index + 1, text, tokens);
   end Initialize;

   -- --------- --
   -- ReplaceOp --
   -- --------- --

   procedure Initialize (Self : in out ReplaceOp; 
                         from, to : Integer;
                         text : Optional_UString;
                         tokens : TokenStream) is
   begin
      RewriteOperation (Self).Initialize (from, text, tokens); -- Super
      Self.lastIndex := to;
   end Initialize;

   overriding
   function execute (This : ReplaceOp; buf : in out UString) return Integer is
      text : constant Optional_Text := Maybe (This.text);
   begin
      if Is_Valid (text) then
         buf := @ + text;
      end if;
      return This.lastIndex + 1;
   end execute;

   overriding
   procedure Put_Image_ReplaceOp (S : in out Sink'Class; X : ReplaceOp);
   begin
      S.Wide_Wide_Put (Description (X));
   end Put_Image_ReplaceOp;

   function Description (This : ReplaceOp) return UString is
      token : constant := This.tokens.get (This.index); -- try!
      lastToken : constant := This.tokens.get (This.lastIndex); -- try!
   begin
      text : constant Optional_Text := Maybe (This.text);
      if Is_Valid (text) then
         return "<ReplaceOp@" & token'Image & " .. " & lastToken'Image & ":""" & This.text & """>";
      else
         return "<DeleteOp@" & token'Image & " .. " & lastToken'Image & '>';
      end if;
   end Description;

   -- --------------------- --
   -- RewriteOperationArray --
   -- --------------------- --

   function Hash_UString (Key : UString) return Ada.Containers.Hash_Type issue
   begin
      return 0; --TOFIX
   end Hash_UString;

   function "=" (Left, Right : RewriteOperationArray) return Boolean is
   begin
      is (Left = Right); --TOFIX
   end "=";

   overriding
   procedure Initialize (Self : in out RewriteOperationArray) is
   begin
      Self.rewrites.Reserve_Capacity (PROGRAM_INIT_SIZE);
   end Initialize;

   procedure append (This : RewriteOperationArray; op : RewriteOperation) is
         op.instructionIndex := This.rewrites.Length;
   begin
         This.rewrites.append (op);
   end append;

   procedure rollback (This : in out RewriteOperationArray; instructionIndex : Integer) is
   begin
         This.rewrites := [for Rollback_Index in MIN_TOKEN_INDEX .. instructionIndex - 1 use This.rewrites (Rollback_Index)]; --TOFIX
   end rollback;

   function reduceToSingleOperationPerIndex (This : RewriteOperationArray) return RewriteOperation_Map is
         rop : ReplaceOp;
         m : RewriteOperation_Map; -- := RewriteOperation_Container.Empty_Map;
   begin
         Walk_Replaces :
         for i in 0 .. This.rewrites.Length - 1 loop
            rop := ReplaceOp (This.rewrites.Element (i));
            if not Is_Valid (rop) then
               goto CONTINUE_WALK_REPLACES;
            end if;

            -- Wipe prior inserts within range
            Inserts :
            for j : Integer_List in getKindOfOps (This.rewrites, InsertBeforeOp'Tag, i) loop
               if iop : constant := This.rewrites.Element (j) then
                     if iop.index = rop.index then
                        -- E.g., insert before 2, delete 2 .. 2; update replace
                        -- text to include insert before, kill insert
                        This.rewrites.Insert (Key => iop.instructionIndex, New_Item => null);
                        rop.text := catOpText (iop.text, rop.text);
                     end if;
                     elsif iop.index > rop.index and then iop.index <= rop.lastIndex then
                        -- delete insert as it's a no-op.
                        This.rewrites.Insert (Key => iop.instructionIndex, New_Item => null);
                     end if;
               end if;
            end loop Inserts;

            -- Drop any prior replaces contained within
            PrevRopIndexList :
            for j : Integer_List in getKindOfOps (This.rewrites, ReplaceOp'Tag, i) loop
               if prevRop : constant := This.rewrites.Element (j) then
                     if prevRop.index >= rop.index and then prevRop.lastIndex <= rop.lastIndex then
                        -- delete replace as it's a no-op.
                        This.rewrites.Insert (Key => prevRop.instructionIndex, New_Item => null);
                        goto CONTINUE_PREVROPINDEXLIST;
                     end if;
                     -- raise exception unless disjoint or identical
                     disjoint : constant : Boolean =
                        prevRop.lastIndex < rop.index or else prevRop.index > rop.lastIndex;
                     -- Delete special case of replace (text = null):
                     -- D.i-j.u D.x-y.v  | boundaries overlap    combine to max (min)..max (right);
                     if not Is_Valid (prevRop.text) and then not Is_Valid (rop.text) and then not disjoint then
                        This.rewrites.Insert (Key => prevRop.instructionIndex, New_Item => null); -- kill first delete
                        rop.index := min (prevRop.index, rop.index);
                        rop.lastIndex := max (prevRop.lastIndex, rop.lastIndex);
                     end if; elsif not disjoint then
                        raise ANTLRError.illegalArgument with "replace op boundaries of " & Image (rop) & "; " &
                           "overlap with previous " & Image (prevRop);
                     end if;
               end if;
                  <<CONTINUE_PREVROPINDEXLIST>>
            end loop PrevRopIndexList;
            <<CONTINUE_WALK_REPLACES>>
         end loop Walk_Replaces;

         Walk_Inserts :
         for i in 0 .. This.rewrites.Length - 1 loop
            iop : constant := This.rewrites.Element (i);
            if not Is_Valid (iop) then
               goto CONTINUE_WALK_INSERTS;
            end if;
            if not (iop is InsertBeforeOp) then
               goto CONTINUE_WALK_INSERTS;
            end if;

            InsertBeforeOp :
            -- combine current insert with prior if any at same index
            for j : Integer_List in getKindOfOps (This.rewrites, InsertBeforeOp'Tag, i) loop
               if prevIop : constant := This.rewrites.Element (j) then
                     if prevIop.index = iop.index then
                        if prevIop is InsertAfterOp then
                           iop.text := catOpText (prevIop.text, iop.text);
                           This.rewrites.Insert (Key => prevIop.instructionIndex, New_Item => null);
                        end if;
                        elsif prevIop is InsertBeforeOp then
                           -- convert to strings .. we're in process of toString'ing
                           -- whole token buffer so no lazy eval issue with any templates
                           iop.text := catOpText (iop.text, prevIop.text);
                           -- delete redundant prior insert
                           This.rewrites.Insert (Key => prevIop.instructionIndex, New_Item => null);
                        end if;
                     end if;
               end if;
            end loop InsertBeforeOp;

            RopIndexList :
            -- look for replaces where iop.index is in range; error
            for j : Integer_List in getKindOfOps (This.rewrites, ReplaceOp'Tag, i)  loop
               if rop : constant := This.rewrites.Element (j) then
                     if iop.index = rop.index then
                        rop.text := catOpText (iop.text, rop.text);
                        This.rewrites.Insert (Key => i, New_Item => null); -- delete current insert
                        goto CONTINUE_ROPINDEXLIST;
                     end if;
                     if iop.index >= rop.index and then iop.index <= rop.lastIndex then
                        raise ANTLRError.illegalArgument with "insert op " & Image (iop) & "; within" &
                           " boundaries of previous " & Image (rop);
                     end if;
               end if;
               <<CONTINUE_ROPINDEXLIST>>
            end loop RopIndexList;
            <<CONTINUE_WALK_INSERTS>>
         end loop Walk_Inserts;

         for i in 0 .. This.rewrites.Length - 1 loop
            if op : constant := This.rewrites.Element (i) then
               if Is_Valid (m.Element (op.index)) then
                     raise ANTLRError.illegalArgument with "should only be one op per index";
               end if;
               m.Insert (Key => op.index, New_Item => op);
            end if;
         end loop;

         return m;
      end reduceToSingleOperationPerIndex;

   function catOpText (This : RewriteOperationArray; a, b : Optional_UString) return UString is
   begin
         x : constant Ustring := Maybe (a, Default => "");
         y : constant Ustring := Maybe (b, Default => "");
         return x & y;
   end catOpText;

   generic
      subtype T is RewriteOperation; -- T: RewriteOperation
   function getKindOfOps_T (This : RewriteOperationArray;
                            rewrites : in out Optional_RewriteOperation_List;
                            kind : RewriteOperation'Class;
                            before : Integer)
                            return Integer_List is
      length : constant := min (before, This.rewrites.Length);
      op : Integer_List; -- := Integer_Container.Empty_Vector;
   begin
      op.reserveCapacity (length);
      for i in 0 .. length - 1 loop
         if rewrites.Element (i)'Class = T'Class then --TOFIX
            op.append (i);
         end if;
      end loop;
      return op;
   end getKindOfOps;

   procedure Initialize (Self : in out TokenStreamRewriter; tokens : TokenStream) is
      --TOFIX lastRewriteTokenIndexes : TokenID_Map;
   begin
      self.tokens := tokens;
      Self.programs.Insert (Key => DEFAULT_PROGRAM_NAME, New_Item => This.RewriteOperationArray);
   end Initialize;

   procedure rollback (This : TokenStreamRewriter; instructionIndex : Integer) is
   begin
      rollback (DEFAULT_PROGRAM_NAME, instructionIndex);
   end rollback;

   procedure rollback (This : TokenStreamRewriter;
                     programName : UString;
                     instructionIndex : Integer) is
      program : constant Optional_RewriteOperationArray := This.programs.Element (programName);
   begin
      if Is_Valid (program) then
            program.rollback (instructionIndex);
      end if;
   end rollback;

   procedure deleteProgram (This : TokenStreamRewriter) is
   begin
      deleteProgram (DEFAULT_PROGRAM_NAME);
   end deleteProgram;

   procedure deleteProgram (This : TokenStreamRewriter; programName : UString) is
   begin
      rollback (programName, TokenStreamRewriter.MIN_TOKEN_INDEX);
   end deleteProgram;

   procedure insertAfter (This : TokenStreamRewriter; t : Token; text : UString) is
   begin
      insertAfter (DEFAULT_PROGRAM_NAME, t, text);
   end insertAfter;

   procedure insertAfter (This : TokenStreamRewriter; index : Integer; text : UString) is
   begin
      insertAfter (DEFAULT_PROGRAM_NAME, index, text);
   end insertAfter;

   procedure insertAfter (This : TokenStreamRewriter; programName : UString; t : Token; text : UString) is
   begin
      insertAfter (programName, t.getTokenIndex, text);
   end insertAfter;

   procedure insertAfter (This : TokenStreamRewriter; programName : UString; index : Integer; text : UString) is
   begin
      -- to insert after, just insert before next index (even if past end);
      op : constant := InsertAfterOp (index, text, tokens);
      rewrites : constant := getProgram (programName);
      rewrites.append (op);
   end insertAfter;

   procedure insertBefore (This : TokenStreamRewriter; t : Token; text : UString) is
   begin
      insertBefore (DEFAULT_PROGRAM_NAME, t, text);
   end insertBefore;

   procedure insertBefore (This : TokenStreamRewriter; index : Integer; text : UString) is
   begin
      insertBefore (DEFAULT_PROGRAM_NAME, index, text);
   end insertBefore;

   procedure insertBefore (This : TokenStreamRewriter; programName : UString; t : Token; text : UString) is
   begin
      insertBefore (programName, t.getTokenIndex, text);
   end insertBefore;

   procedure insertBefore (This : TokenStreamRewriter; programName : UString; index : Integer; text : UString) is
   begin
      op : constant := InsertBeforeOp (index, text, This.tokens);
      rewrites : constant := getProgram (programName);
      rewrites.append (op);
   end insertBefore;

   procedure replace (This : TokenStreamRewriter; index : Integer; text : UString) is
   begin
      replace (DEFAULT_PROGRAM_NAME, index, index, text);
   end replace;

   procedure replace (This : TokenStreamRewriter; from, to : Integer; text : UString) is
   begin
      replace (DEFAULT_PROGRAM_NAME, from, to, text);
   end replace;

   procedure replace (This : TokenStreamRewriter; indexT : Token; text : UString) is
   begin
      replace (DEFAULT_PROGRAM_NAME, indexT, indexT, text);
   end replace;

   procedure replace (This : TokenStreamRewriter; from, to : Token; text : UString) is
   begin
      replace (DEFAULT_PROGRAM_NAME, from, to, text);
   end replace;

   procedure replace (This : TokenStreamRewriter; programName : UString; from, to : Integer; text : Optional_UString) is
   begin
      if from > to or else from < 0 or else to < 0 or else to >= This.tokens.size then
            raise ANTLRError.illegalArgument with "replace: range invalid: " & from'Image & ".." & to'Image & "(size=" & tokens.size);
      end if;
      op : constant := ReplaceOp (from, to, text, tokens);
      rewritesArray : constant := getProgram (programName);
      rewritesArray.append (op);
   end replace;

   procedure replace (This : TokenStreamRewriter; programName : UString; from, to : Token; text : Optional_UString) is
   begin
      replace (programName,;
            from.getTokenIndex,
            to.getTokenIndex,
            text);
   end replace;

   procedure delete (This : TokenStreamRewriter; index : Integer) is
   begin
      delete (DEFAULT_PROGRAM_NAME, index, index);
   end delete;

   procedure delete (This : TokenStreamRewriter; from, to : Integer) is
   begin
      delete (DEFAULT_PROGRAM_NAME, from, to);
   end delete;

   procedure delete (This : TokenStreamRewriter; indexT : Token) is
   begin
      delete (DEFAULT_PROGRAM_NAME, indexT, indexT);
   end delete;

   procedure delete (This : TokenStreamRewriter; from, to : Token) is
   begin
      delete (DEFAULT_PROGRAM_NAME, from, to);
   end delete;

   procedure delete (This : TokenStreamRewriter; programName : UString; from, to : Integer) is
   begin
      replace (programName, from, to, null);
   end delete;

   procedure delete (This : TokenStreamRewriter; programName : UString; from, to : Token) is
   begin
      replace (programName, from, to, null);
   end delete;

   function getLastRewriteTokenIndex (This : TokenStreamRewriter) return Integer is
   begin
      return getLastRewriteTokenIndex (DEFAULT_PROGRAM_NAME);
   end getLastRewriteTokenIndex;

   function getLastRewriteTokenIndex (This : TokenStreamRewriter; rogramName : UString) return Integer is
   begin
      return This.lastRewriteTokenIndexes.Element (programName), Default => -1
   end getLastRewriteTokenIndex;

   procedure setLastRewriteTokenIndex (This : TokenStreamRewriter; programName : UString; i : Integer) is
   begin
      This.lastRewriteTokenIndexes.Insert (Key => programName, New_Item => i);
   end setLastRewriteTokenIndex;

   function getProgram (This : TokenStreamRewriter; name : UString) return RewriteOperationArray is
   begin
      if program : constant := programs.Element (name) then
            return program;
      else
            return initializeProgram (name);
      end if;
   end getProgram;

   function initializeProgram (This : TokenStreamRewriter; name : UString) return RewriteOperationArray is
   begin
      program : constant := This.RewriteOperationArray;
      programs.Insert (Key => name, New_Item => program);
      return program;
   end initializeProgram;

   function getText (This : TokenStreamRewriter) return UString
      is (getText (DEFAULT_PROGRAM_NAME, Interval.Set (0, This.tokens.size - 1)));

   function getText (This : TokenStreamRewriter; programName : UString) return UString
      is (getText (programName, Interval.set (0, This.tokens.size - 1)));

   function getText (This : TokenStreamRewriter; interval : Interval) return UString
       is (getText (DEFAULT_PROGRAM_NAME, interval));

   function getText (This : TokenStreamRewriter;
                     programName : UString;
                     interval : Interval)
                     return UString is
      start : Integer := interval.a;
      stop : Integer  := interval.b;
      rewrites : constant RewriteOperationArray := This.programs.Element (programName);
      buf : UString;
      indexToOp : RewriteOperation_Map;
   begin
      -- ensure start/end are in range
      if stop > This.tokens.size - 1 then
            stop := This.tokens.size - 1;
      end if;
      if start < 0 then
            start := 0;
      end if;
      if not Is_Valid (rewrites) or not rewrites.Is_Empty then
            return This.tokens.getText (interval); -- no instructions to execute
      end if;

      buf := "";

      -- First, optimize instruction stream
      indexToOp := rewrites.reduceToSingleOperationPerIndex;

      -- Walk buffer, executing instructions and emitting tokens
      i := start;
      while i <= stop and then i < This.tokens.size loop
            op : constant := indexToOp.Element (i);
            indexToOp.removeValue (forKey => i)  -- remove so any left have index size-1
            t : constant := This.tokens.get (i);
            if op : constant := op then
               i := op.execute (buf'Access); -- execute operation and skip
            else
               -- no operation at that index, just dump token
               if t.getType /= EOF then
                  buf.append (Value (t.getText));
               end if;
               i := @ + 1; -- move to next token
            end if;
      end loop;

      -- include stuff after end if it's last index in buffer
      -- So, if they did an insertAfter (lastValidIndex, "foo"), include
      -- foo if end = lastValidIndex.
      if stop = This.tokens.size - 1 then
            -- Scan any remaining operations after last token
            -- should be included (they will be inserts).
            for op in indexToOp.values loop
               if op.index >= This.tokens.size - 1 then
                  buf := @ + Value (op.text);
               end if;
            end loop;
      end if;

      return buf;
   end getText;

end ANTLR.Runtime.TokenStreamRewriters;
