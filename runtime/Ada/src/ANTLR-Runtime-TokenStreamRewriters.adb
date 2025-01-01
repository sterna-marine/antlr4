-- €

with Ada.Containers.Hashed_Maps;
with Ada.Finalization;
with ANTLR.Runtime.Misc.Intervals;
with ANTLR.Runtime.RuleContexts;
with ANTLR.Runtime.Token_Protocol;
with ANTLR.Runtime.TokenSource_Protocol;
with ANTLR.Runtime.TokenStream_Protocol;

use ANTLR.Runtime.Misc.Intervals;
use ANTLR.Runtime.RuleContexts;
use ANTLR.Runtime.Token_Protocol;
use ANTLR.Runtime.TokenSource_Protocol;
use ANTLR.Runtime.TokenStream_Protocol;


package ANTLR.Runtime.TokenStreamRewriters is

   --
   -- Useful for rewriting out a buffered input token stream after doing some
   -- augmentation or other manipulations on it.
   --
   --
   -- You can insert stuff, replace, and delete chunks. Note that the operations
   -- are done lazily--only if you convert the buffer to a _String_ with
   -- _org.antlr.v4.runtime.TokenStream#getText ()_. This is very efficient because you are not
   -- moving data around all the time. As the buffer of tokens is converted to
   -- strings, the _#getText ()_ method (s) scan the input token stream and
   -- check to see if there is an operation at the current index. If so, the
   -- operation is done and then normal _String_ rendering continues on the
   -- buffer. This is like having multiple Turing machine instruction streams
   -- (programs) operating on a single input tape. :);
   --
   --
   -- This rewriter makes no modifications to the token stream. It does not ask the
   -- stream to fill itself up nor does it advance the input cursor. The token
   -- stream _org.antlr.v4.runtime.TokenStream#index ()_ will return the same value before and
   -- after any _#getText ()_ call.
   --
   --
   -- The rewriter only works on tokens that you have in the buffer and ignores the
   -- current input cursor. If you are buffering tokens on-demand, calling
   -- _#getText ()_ halfway through the input will only do rewrites for those
   -- tokens in the first half of the file.
   --
   --
   -- Since the operations are done lazily at _#getText_-time, operations do
   -- not screw up the token index values. That is, an insert operation at token
   -- index `i` does not change the index values for tokens
   -- `i + 1 .. n - 1`.
   --
   --
   -- Because operations never actually alter the buffer, you may always get the
   -- original token stream back without undoing anything. Since the instructions
   -- are queued up, you can easily simulate transactions and roll back any changes
   -- if there is an error just by removing instructions. For example,
   --
   --  ```ada
   --  declare
   --     input : CharStream := new ANTLRFileStream ("input");
   --     lex : TLexer := new TLexer (input);
   --     tokens : CommonTokenStream := new CommonTokenStream (lex);
   --     parser : T := new T (tokens);
   --     rewriter : TokenStreamRewriter := new TokenStreamRewriter (tokens);
   --  begin
   --     parser.startRule;
   --  end;
   --  ```
   --
   --
   -- Then in the rules, you can execute (assuming rewriter is visible):
   --
   --  ```ada
   --  declare
   --     t,u; : Token;
   --  begin
   --     …
   --     rewriter.insertAfter (t, "text to put after t");
   --     rewriter.insertAfter (u, "text after u");
   --     Ada.Wide_Wide_Text_IO.Put_Line (rewriter.getText);
   --  end;
   --  ```
   --
   --
   -- You can also have multiple "instruction streams" and get multiple rewrites
   -- from a single pass over the input. Just name the instruction streams and use
   -- that name again when printing the buffer. This could be useful for generating
   -- a Ada file and also its header file--all from the same buffer:
   --
   --  ```ada
   --  rewriter.insertAfter ("pass1", t, "text to put after t");
   --  rewriter.insertAfter ("pass2", u, "text after u");
   --  Ada.Wide_Wide_Text_IO.Put_Line (rewriter.getText ("pass1"));
   --  Ada.Wide_Wide_Text_IO.Put_Line (rewriter.getText ("pass2"));
   --  ```
   --
   --
   -- If you don't use named rewrite streams, a "default" stream is used as the
   -- first example shows.
   --

   -- public static
   PROGRAM_INIT_SIZE : constant Positive := 100;
   -- public static
   MIN_TOKEN_INDEX : constant Integer := 0;

   -- ---------------- --
   -- RewriteOperation --
   -- ---------------- --
   type RewriteOperation is record --
      -- What index into rewrites List are we?
      -- internal
      instructionIndex : Integer := 0;
      -- Token buffer index.
      -- internal
      index : Integer;
      -- internal
      text : Optional_String;
      -- internal
      lastIndex : Integer := 0;
      -- internal weak
      tokens : TokenStream; --!
   end record;

   package Option_RewriteOperation is new Option (RewriteOperation);
   subtype Optional_RewriteOperation is Option_RewriteOperation.Optional;

   package Optional_RewriteOperation_Containers is new Ada.Containers.Vectors (
      Index_Type => Natural,
      Element_Type => Optional_RewriteOperation,
      "=" => "=");
   subtype Optional_RewriteOperation_Container is Optional_RewriteOperation_Containers.Vector;

   procedure Initialize (Self : RewriteOperation; index : Integer; tokens : TokenStream) is
   begin
      self.index := index;
      self.tokens := tokens;
   end Initialize;

   procedure Initialize (Self : RewriteOperation; index : Integer; text : Optional_String; tokens : TokenStream) is
   begin
      self.index := index;
      self.text := text;
      self.tokens := tokens;
   end Initialize;

   -- Execute the rewrite operation by possibly adding to the buffer.
   -- Return the index of the next token to operate on.
   --
   -- public
   function execute (This : RewriteOperation; buf : in out UString) return Integer
      is (This.index);

   -- public
   subtype Sink is Ada.Strings.Text_Buffers.Root_Buffer_Type;
   procedure Put_Image_RewriteOperation (S : in out Sink'Class; X : RewriteOperation);
   for RewriteOperation'Put_Image use Put_Image_RewriteOperation;
   function Description (This : RewriteOperation) return UString is
         opName : constant UString := To_UString (This'External_Tag);
   begin
         return "<" & opName'Image & "@" & tokens.get (This.index) & """" & Value (This.text) & """>"; -- try!
   end Description;

   -- ---------------- --
   function Hash (Key : UString) return Ada.Containers.Hash_Type;
   function Equivalent_Keys (Left, Right : UString) return Boolean
      is Hash (Left) = Hash (Right);
   with function "=" (Left, Right : RewriteOperationArray) return Boolean
      is (Left = Right); --TOFIX
   package RewriteOperationArray_Container is new Ada.Containers.Hashed_Maps (
      Key_Type => UString,
      Element_Type => RewriteOperationArray,
      Hash => Hash,
      Equivalent_Keys => Equivalent_Keys,
      "=" => "=");
   subtype RewriteOperationArray_Container is RewriteOperationArray_Container.Map;

   -- ------------------- --
   -- TokenStreamRewriter --
   -- ------------------- --
   -- public
   type TokenStreamRewriter is new Ada.Finalization.Controlled with record
      -- public
      DEFAULT_PROGRAM_NAME : UString := "default"; -- constant

      -- Map UString (program name) > Integer index
      -- internal final
      lastRewriteTokenIndexes : TokenID_Container.Map; -- := TokenID_Container.Empty_Map

      -- You may have multiple, named streams of rewrite operations.
      -- I'm calling these things "programs."
      -- Maps UString (name) > rewrite (List);
      --
      -- internal
      programs : lastRewriteTokenIndexes_Map;

      -- Define the rewrite operation hierarchy
      -- public
      RewriteOperation : TokenStreamRewriter;

      -- Our source stream
      -- internal
      tokens : TokenStream;

function Hash (Key : UString) return Ada.Containers.Hash_Type;

function Equivalent_Keys (Left, Right : UString) return Boolean
   is Hash (Left) = Hash (Right); --TOFIX

package lastRewriteTokenIndexes_Container is new Ada.Containers.Hashed_Maps (
   Key_Type => UString,
   Element_Type => Integer,
   Hash => Hash,
   Equivalent_Keys => Equivalent_Keys,
   "=" => "=");

subtype lastRewriteTokenIndexes_Map is lastRewriteTokenIndexes_Container.Map;

   end record;

   subtype Object is TokenStreamRewriter;
   type Class is access all Object;
   type Class_Wide is access all Object'Class;

   -- -------------- --
   -- InsertBeforeOp --
   -- -------------- --
   -- public
   type InsertBeforeOp is new RewriteOperation with null record;

   -- public
   override
   function execute (This : InsertBeforeOp; buf : in out UString) return Integer is
      text : constant Optional_Text := Maybe (This.text);
      token : constant := tokens.get (This.index);
   begin
      if Is_Valid (text) then
         buf.append (text);
      end if;
      if token.getType /= CommonToken.EOF then
         buf.append (Value (token.getText));
      end if;
      return This.index + 1;
   end execute;

   -- -------------- --
   -- InsertBeforeOp --
   -- -------------- --
   -- public
   type InsertAfterOp is new InsertBeforeOp with null record;

   -- public
   overriding
   procedure Initialize (Self : in out InsertAfterOp;
                         index : Integer;
                         text : Optional_String;
                         tokens : TokenStream) is
   begin
      InsertBeforeOp (Self).Initialize (index + 1, text, tokens);
   end Initialize;

   -- I'm going to replacing range from x .. y with (y-x)+1 ReplaceOp;
   -- instructions.
   --

   -- --------- --
   -- ReplaceOp --
   -- --------- --
   -- public
   type ReplaceOp is new RewriteOperation with null record;

   -- public
   procedure Initialize (Self : in out ReplaceOp; 
                         from, to : Integer;
                         text : Optional_String;
                         tokens : TokenStream) is
   begin
      RewriteOperation (Self).Initialize (from, text, tokens); -- Super
      Self.lastIndex := to;
   end Initialize;

   overriding
   -- public
   function execute (This : ReplaceOp; buf : in out UString) return Integer is
      text : constant Optional_Text := Maybe (This.text);
   begin
      if Is_Valid (text) then
         buf := @ + text;
      end if;
      return This.lastIndex + 1;
   end execute;

   overriding
   -- public
   subtype Sink is Ada.Strings.Text_Buffers.Root_Buffer_Type;
   procedure Put_Image_ReplaceOp (S : in out Sink'Class; X : ReplaceOp);
   for …'Put_Image use Put_Image_ReplaceOp;
   function Description (This : ReplaceOp) return UString is
      token : constant := tokens.get (This.index); -- try!
      lastToken : constant := tokens.get (This.lastIndex); -- try!
   begin
      text : constant Optional_Text := Maybe (This.text);
      if Is_Valid (text) then
         return "<ReplaceOp@" & token'Image & ".." & lastToken'Image & ":""" & text'Image & """>";
      else
         return "<DeleteOp@" & token'Image & ".." & lastToken'Image & ">"
      end if;
   end Description;

   -- --------------------- --
   -- RewriteOperationArray --
   -- --------------------- --
   -- public
   type RewriteOperationArray is new Ada.Finalization.Controlled with
   record
      -- private final 
      rewrites : Optional_RewriteOperation_Container;
   end record;

   -- public
   overriding
   procedure Initialize (Self : in out RewriteOperationArray) is
   begin
      rewrites.reserveCapacity (TokenStreamRewriter.PROGRAM_INIT_SIZE);
   end Initialize;

   -- final
   procedure append (This : RewriteOperationArray; op : RewriteOperation) is
         op.instructionIndex := This.rewrites.Length;
   begin
         This.rewrites.append (op);
   end append;

   -- final
   procedure rollback (This : RewriteOperationArray; instructionIndex : Integer) is
   begin
         This.rewrites := To_Vector (rewrites[TokenStreamRewriter.MIN_TOKEN_INDEX .. instructionIndex - 1]);
   end rollback;

   -- final
   function count (This : RewriteOperationArray) return Integer
      is (This.rewrites.Length);

   -- final
   function isEmpty (This : RewriteOperationArray) return Boolean
      is (This.rewrites.Is_Empty);

   -- We need to combine operations and report invalid operations (like
   -- overlapping replaces that are not completed nested). Inserts to
   -- same index need to be combined etc ..   Here are the cases:
   --
   -- I.i.u I.j.v                             leave alone, nonoverlapping
   -- I.i.u I.i.v                             combine: Iivu
   --
   -- R.i-j.u R.x-y.v | i-j in x-y            delete first R
   -- R.i-j.u R.i-j.v                         delete first R
   -- R.i-j.u R.x-y.v | x-y in i-j            ERROR
   -- R.i-j.u R.x-y.v | boundaries overlap    ERROR
   --
   -- Delete special case of replace (text = null):
   -- D.i-j.u D.x-y.v | boundaries overlap    combine to max (min)..max (right);
   --
   -- I.i.u R.x-y.v | i in (x+1)-y            delete I (since insert before
   -- we're not deleting i);
   -- I.i.u R.x-y.v | i not in (x+1)-y        leave alone, nonoverlapping
   -- R.x-y.v I.i.u | i in x-y                ERROR
   -- R.x-y.v I.x.u                           R.x-y.uv (combine, delete I);
   -- R.x-y.v I.i.u | i not in x-y            leave alone, nonoverlapping
   --
   -- I.i.u := insert u before op @ index i
   -- R.x-y.u := replace x-y indexed tokens with u
   --
   -- First we need to examine replaces. For any replace op:
   --
   -- 1. wipe out any insertions before op within that range.
   -- 2. Drop any replace op before that is contained completely within
   -- that range.
   -- 3. Raise exception upon boundary overlap with any previous replace.
   --
   -- Then we can deal with inserts:
   --
   -- 1. for any inserts to same index, combine even if not adjacent.
   -- 2. for any prior replace with same left boundary, combine this
   -- insert with replace and delete this replace.
   -- 3. Raise exception if index in same range as previous replace
   --
   -- Don't actually delete; make op null in list. Easier to walk list.
   -- Later we can raise as we add to index > op map.
   --
   -- Note that I.2 R.2-2 will wipe out I.2 even though, technically, the
   -- inserted stuff would be before the replace range. But, if you
   -- add tokens in front of a method body '{' and then delete the method
   -- body, I think the stuff before the '{' you added should disappear too.
   --
   -- Return a map from token index to operation.
   --
   -- final
   function reduceToSingleOperationPerIndex (This : RewriteOperationArray) return [Int: RewriteOperation] is
         rewritesCount : constant := rewrites.count
   begin
         WALK_REPLACES :
         for i in 0 .. rewritesCount - 1 loop
            rop : constant ReplaceOp := ReplaceOp (rewrites.Element (i));
            if not Is_Valid (rop) then
               goto CONTINUE_WALK_REPLACES;
            end if;

            -- Wipe prior inserts within range
            inserts : constant := getKindOfOps (rewrites'Access, InsertBeforeOp.self, i);
            for j in inserts loop
               if iop : constant := rewrites.Element (j) then
                     if iop.index = rop.index then
                        -- E.g., insert before 2, delete 2 .. 2; update replace
                        -- text to include insert before, kill insert
                        rewrites.Insert (Key => iop.instructionIndex, New_Item => null);
                        rop.text := catOpText (iop.text, rop.text);
                     end if;
                     elsif iop.index > rop.index and then iop.index <= rop.lastIndex then
                        -- delete insert as it's a no-op.
                        rewrites.Insert (Key => iop.instructionIndex, New_Item => null);
                     end if;
               end if;
            end loop;
            -- Drop any prior replaces contained within
            prevRopIndexList : constant := getKindOfOps (rewrites'Access, ReplaceOp.self, i);
            for j in prevRopIndexList loop
               if prevRop : constant := rewrites.Element (j) then
                     if prevRop.index >= rop.index and then prevRop.lastIndex <= rop.lastIndex then
                        -- delete replace as it's a no-op.
                        rewrites.Insert (Key => prevRop.instructionIndex, New_Item => null);
                        goto CONTINUE_PREVROPINDEXLIST;
                     end if;
                     -- raise exception unless disjoint or identical
                     disjoint : constant : Boolean =
                        prevRop.lastIndex < rop.index or else prevRop.index > rop.lastIndex;
                     -- Delete special case of replace (text = null):
                     -- D.i-j.u D.x-y.v  | boundaries overlap    combine to max (min)..max (right);
                     if not Is_Valid (prevRop.text) and then not Is_Valid (rop.text) and then not disjoint then
                        rewrites.Insert (Key => prevRop.instructionIndex, New_Item => null); -- kill first delete
                        rop.index := min (prevRop.index, rop.index);
                        rop.lastIndex := max (prevRop.lastIndex, rop.lastIndex);
                     end if; elsif not disjoint then
                        raise ANTLRError.illegalArgument with "replace op boundaries of " & Image (rop) & "; " &
                           "overlap with previous " & Image (prevRop);
                     end if;
               end if;
                  <<CONTINUE_PREVROPINDEXLIST>>
            end loop;
            <<CONTINUE_WALK_REPLACES>>
         end loop WALK_REPLACES;

         WALK_INSERTS :
         for i in 0 .. rewritesCount - 1 loop
            iop : constant := rewrites.Element (i);
            if not Is_Valid (iop) then
               goto CONTINUE_WALK_INSERTS;
            end if;
            if not (iop is InsertBeforeOp) then
               goto CONTINUE_WALK_INSERTS;
            end if;

            -- combine current insert with prior if any at same index
            prevIopIndexList : constant := getKindOfOps (rewrites'Access, InsertBeforeOp.self, i);
            for j in prevIopIndexList loop
               if prevIop : constant := rewrites.Element (j) then
                     if prevIop.index = iop.index then
                        if prevIop is InsertAfterOp then
                           iop.text := catOpText (prevIop.text, iop.text);
                           rewrites.Insert (Key => prevIop.instructionIndex, New_Item => null);
                        end if;
                        elsif prevIop is InsertBeforeOp then
                           -- convert to strings .. we're in process of toString'ing
                           -- whole token buffer so no lazy eval issue with any templates
                           iop.text := catOpText (iop.text, prevIop.text);
                           -- delete redundant prior insert
                           rewrites.Insert (Key => prevIop.instructionIndex, New_Item => null);
                        end if;
                     end if;
               end if;
            end loop;

            -- look for replaces where iop.index is in range; error
            ropIndexList : constant := getKindOfOps (rewrites'Access, ReplaceOp.self, i);
            for j in ropIndexList  loop
               if rop : constant := rewrites.Element (j) then
                     if iop.index = rop.index then
                        rop.text := catOpText (iop.text, rop.text);
                        rewrites.Insert (Key => i, New_Item => null); -- delete current insert
                        goto CONTINUE_ROPINDEXLIST;
                     end if;
                     if iop.index >= rop.index and then iop.index <= rop.lastIndex then
                        raise ANTLRError.illegalArgument with "insert op " & Image (iop) & "; within" &
                           " boundaries of previous " & Image (rop);
                     end if;
               end if;
               <<CONTINUE_ROPINDEXLIST>>
            end loop;
            <<CONTINUE_WALK_INSERTS>>
         end loop WALK_INSERTS;

         m := [Int: RewriteOperation]();
         for i in 0 .. rewritesCount - 1 loop
            if op : constant := rewrites.Element (i) then
               if Is_Valid (m.Element (op.index)) then
                     raise ANTLRError.illegalArgument with "should only be one op per index";
               end if;
               m.Insert (Key => op.index, New_Item => op);
            end if;
         end loop;

         return m;
      end reduceToSingleOperationPerIndex;

   -- final
   function catOpText (This : RewriteOperationArray; a : Optional_String; b : Optional_String;) return UString is
   begin
         x : constant Ustring := Maybe (a, Default => "");
         y : constant Ustring := Maybe (b, Default => "");
         return x & y;
   end catOpText;

   -- Get all operations before an index of a particular kind

   -- final
   generic
      subtype T is RewriteOperation; -- T: RewriteOperation
   function getKindOfOps_T (This : RewriteOperationArray; rewrites : in out [RewriteOperation?], kind : T.Type, before : Integer ) return Int_Container.Vector is
      length : constant := min (before, rewrites.count);
      op : Integer.Container.Vector := Integer.Container.Empty_Vector;
   begin
      op.reserveCapacity (length);
      for i in 0 .. length - 1 loop
         if rewrites.Element (i) is T then
            op.append (i);
         end if;
      end loop;
      return op;
   end getKindOfOps;

   -- ------------------ --

   -- public
   procedure Initialize (Self : in out TokenStreamRewriter; tokens : TokenStream) is
      --TOFIX lastRewriteTokenIndexes : lastRewriteTokenIndexes_Map;
   begin
      self.tokens := tokens;
      Self.programs.Insert (Key => DEFAULT_PROGRAM_NAME, New_Item => This.RewriteOperationArray);
   end Initialize;

   -- public final
   function getTokenStream (This : TokenStreamRewriter) return TokenStream
      is (This.tokens);

   -- public
   procedure rollback (This : TokenStreamRewriter; instructionIndex : Integer) is
   begin
      rollback (DEFAULT_PROGRAM_NAME, instructionIndex);
   end rollback;

   -- Rollback the instruction stream for a program so that
   -- the indicated instruction (via instructionIndex) is no
   -- longer in the stream. UNTESTED!
   --
   -- public
   procedure rollback (This : TokenStreamRewriter;
                     programName : UString;
                     instructionIndex : Integer) is
      program : constant Optional_RewriteOperationArray := This.programs.Element (programName);
   begin
      if Is_Valid (program) then
            program.rollback (instructionIndex);
      end if;
   end rollback;

   -- public
   procedure deleteProgram (This : TokenStreamRewriter) is
   begin
      deleteProgram (DEFAULT_PROGRAM_NAME);
   end deleteProgram;

   -- Reset the program so that no instructions exist
   -- public
   procedure deleteProgram (This : TokenStreamRewriter; programName : UString) is
   begin
      rollback (programName, TokenStreamRewriter.MIN_TOKEN_INDEX);
   end deleteProgram;

   -- public
   procedure insertAfter (This : TokenStreamRewriter; t : Token; text : UString) is
   begin
      insertAfter (DEFAULT_PROGRAM_NAME, t, text);
   end insertAfter;

   -- public
   procedure insertAfter (This : TokenStreamRewriter; index : Integer; text : UString) is
   begin
      insertAfter (DEFAULT_PROGRAM_NAME, index, text);
   end insertAfter;

   -- public
   procedure insertAfter (This : TokenStreamRewriter; programName : UString; t : Token; text : UString) is
   begin
      insertAfter (programName, t.getTokenIndex (), text);
   end insertAfter;

   -- public
   procedure insertAfter (This : TokenStreamRewriter; programName : UString; index : Integer; text : UString) is
   begin
      -- to insert after, just insert before next index (even if past end);
      op : constant := InsertAfterOp (index, text, tokens);
      rewrites : constant := getProgram (programName);
      rewrites.append (op);
   end insertAfter;

   -- public
   procedure insertBefore (This : TokenStreamRewriter; t : Token; text : UString) is
   begin
      insertBefore (DEFAULT_PROGRAM_NAME, t, text);
   end insertBefore;

   -- public
   procedure insertBefore (This : TokenStreamRewriter; index : Integer; text : UString) is
   begin
      insertBefore (DEFAULT_PROGRAM_NAME, index, text);
   end insertBefore;

   -- public
   procedure insertBefore (This : TokenStreamRewriter; programName : UString; t : Token; text : UString) is
   begin
      insertBefore (programName, t.getTokenIndex (), text);
   end insertBefore;

   -- public
   procedure insertBefore (This : TokenStreamRewriter; programName : UString; index : Integer; text : UString) is
   begin
      op : constant := InsertBeforeOp (index, text, tokens);
      rewrites : constant := getProgram (programName);
      rewrites.append (op);
   end insertBefore;

   -- public
   procedure replace (This : TokenStreamRewriter; index : Integer; text : UString) is
   begin
      replace (DEFAULT_PROGRAM_NAME, index, index, text);
   end replace;

   -- public
   procedure replace (This : TokenStreamRewriter; from : Integer; to : Integer; text : UString) is
   begin
      replace (DEFAULT_PROGRAM_NAME, from, to, text);
   end replace;

   -- public
   procedure replace (This : TokenStreamRewriter; indexT : Token; text : UString) is
   begin
      replace (DEFAULT_PROGRAM_NAME, indexT, indexT, text);
   end replace;

   -- public
   procedure replace (This : TokenStreamRewriter; from : Token; to : Token; text : UString) is
   begin
      replace (DEFAULT_PROGRAM_NAME, from, to, text);
   end replace;

   -- public
   procedure replace (This : TokenStreamRewriter; programName : UString; from : Integer; to : Integer; text : Optional_String;) is
   begin
      if from > to or else from < 0 or else to < 0 or else to >= tokens.size () then
            raise ANTLRError.illegalArgument with "replace: range invalid: " & from'Image & ".." & to'Image & "(size=" & tokens.size ());
      end if;
      op : constant := ReplaceOp (from, to, text, tokens);
      rewritesArray : constant := getProgram (programName);
      rewritesArray.append (op);
   end replace;

   -- public
   procedure replace (This : TokenStreamRewriter; programName : UString; from : Token; to : Token; text : Optional_String;) is
   begin
      replace (programName,;
            from.getTokenIndex (),
            to.getTokenIndex (),
            text);
   end replace;

   -- public
   procedure delete (This : TokenStreamRewriter; index : Integer) is
   begin
      delete (DEFAULT_PROGRAM_NAME, index, index);
   end delete;

   -- public
   procedure delete (This : TokenStreamRewriter; from : Integer; to : Integer) is
   begin
      delete (DEFAULT_PROGRAM_NAME, from, to);
   end delete;

   -- public
   procedure delete (This : TokenStreamRewriter; indexT : Token) is
   begin
      delete (DEFAULT_PROGRAM_NAME, indexT, indexT);
   end delete;

   -- public
   procedure delete (This : TokenStreamRewriter; from : Token; to : Token) is
   begin
      delete (DEFAULT_PROGRAM_NAME, from, to);
   end delete;

   -- public
   procedure delete (This : TokenStreamRewriter; programName : UString; from : Integer; to : Integer) is
   begin
      replace (programName, from, to, null);
   end delete;

   -- public
   procedure delete (This : TokenStreamRewriter; programName : UString; from : Token; to : Token) is
   begin
      replace (programName, from, to, null);
   end delete;

   -- public
   function getLastRewriteTokenIndex (This : TokenStreamRewriter) return Integer is
   begin
      return getLastRewriteTokenIndex (DEFAULT_PROGRAM_NAME);
   end getLastRewriteTokenIndex;

   -- internal
   function getLastRewriteTokenIndex (This : TokenStreamRewriter; rogramName : UString) return Integer is
   begin
      return This.lastRewriteTokenIndexes.Element (programName), Default => -1
   end getLastRewriteTokenIndex;

   -- internal
   procedure setLastRewriteTokenIndex (This : TokenStreamRewriter; programName : UString; i : Integer) is
   begin
      This.lastRewriteTokenIndexes.Insert (Key => programName, New_Item => i);
   end setLastRewriteTokenIndex;

   -- internal
   function getProgram (This : TokenStreamRewriter; name : UString) return RewriteOperationArray is
   begin
      if program : constant := programs.Element (name) then
            return program
      else
            return initializeProgram (name);
      end if;
   end getProgram;

   -- private
   function initializeProgram (This : TokenStreamRewriter; name : UString) return RewriteOperationArray is
   begin
      program : constant := RewriteOperationArray ();
      programs.Insert (Key => name, New_Item => program);
      return program
   end initializeProgram;

   -- Return the text from the original tokens altered per the
   -- instructions given to this rewriter.
   --
   -- public
   function getText (This : TokenStreamRewriter) return UString
      is getText (DEFAULT_PROGRAM_NAME, Interval.of (0, tokens.size () - 1));

   -- Return the text from the original tokens altered per the
   -- instructions given to this rewriter in programName.
   --
   -- public
   function getText (This : TokenStreamRewriter; programName : UString) return UString
      is (getText (programName, Interval.of (0, tokens.size () - 1)));

   -- Return the text associated with the tokens in the interval from the
   -- original token stream but with the alterations given to this rewriter.
   -- The interval refers to the indexes in the original token stream.
   -- We do not alter the token stream in any way, so the indexes
   -- and intervals are still consistent. Includes any operations done
   -- to the first and last token in the interval. So, if you did an
   -- insertBefore on the first token, you would get that insertion.
   -- The same is True if you do an insertAfter the stop token.
   --
   -- public
   function getText (This : TokenStreamRewriter; interval : Interval) return UString
       is (getText (DEFAULT_PROGRAM_NAME, interval));

   -- public
   function getText (This : TokenStreamRewriter;
                     programName : UString;
                     interval : Interval)
                     return UString is
      start := interval.a;
      stop := interval.b;
      rewrites : constant RewriteOperationArray := This.programs.Element (programName);
   begin
      -- ensure start/end are in range
      if stop > tokens.size () - 1 then
            stop := tokens.size () - 1;
      end if;
      if start < 0 then
            start := 0;
      end if;
      if not Is_Valid (rewrites) or not rewrites.isEmpty then
            return tokens.getText (interval); -- no instructions to execute
      end if;

      buf := ""

      -- First, optimize instruction stream
      indexToOp := rewrites.reduceToSingleOperationPerIndex ();

      -- Walk buffer, executing instructions and emitting tokens
      i := start
      while i <= stop and then i < tokens.size () loop
            op : constant := indexToOp.Element (i);
            indexToOp.removeValue (forKey => i)  -- remove so any left have index size-1
            t : constant := tokens.get (i);
            if op : constant := op then
               i := op.execute (buf'Access); -- execute operation and skip
            else
               -- no operation at that index, just dump token
               if t.getType () /= CommonToken.EOF then
                  buf.append (t.getText ()!);
               end if;
               i := @ + 1; -- move to next token
            end if;
      end loop;

      -- include stuff after end if it's last index in buffer
      -- So, if they did an insertAfter (lastValidIndex, "foo"), include
      -- foo if end = lastValidIndex.
      if stop = tokens.size () - 1 then
            -- Scan any remaining operations after last token
            -- should be included (they will be inserts).
            for op in indexToOp.values loop
               if op.index >= tokens.size () - 1 then
                  buf := @ + op.text!;
               end if;
            end loop;
      end if;

      return buf;
   end getText;

end ANTLR.Runtime.TokenStreamRewriters;
