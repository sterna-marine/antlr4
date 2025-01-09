-- €

with Ada.Containers;
with Ada.Containers.Hashed_Maps;
with Ada.Containers.Vectors;
with Ada.Finalization;
with Ada.Strings;
with ANTLR.Runtime.Misc.Intervals;
with ANTLR.Runtime.RuleContexts;
with ANTLR.Runtime.Token_Protocol;
with ANTLR.Runtime.TokenSource_Protocol;
with ANTLR.Runtime.TokenStream_Protocol;
with Option;

use Ada;
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
   -- _org.antlr.v4.runtime.TokenStream#getText_. This is very efficient because you are not
   -- moving data around all the time. As the buffer of tokens is converted to
   -- strings, the _#getText_ method (s) scan the input token stream and
   -- check to see if there is an operation at the current index. If so, the
   -- operation is done and then normal _String_ rendering continues on the
   -- buffer. This is like having multiple Turing machine instruction streams
   -- (programs) operating on a single input tape. :);
   --
   --
   -- This rewriter makes no modifications to the token stream. It does not ask the
   -- stream to fill itself up nor does it advance the input cursor. The token
   -- stream _org.antlr.v4.runtime.TokenStream#index_ will return the same value before and
   -- after any _#getText_ call.
   --
   --
   -- The rewriter only works on tokens that you have in the buffer and ignores the
   -- current input cursor. If you are buffering tokens on-demand, calling
   -- _#getText_ halfway through the input will only do rewrites for those
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
   PROGRAM_INIT_SIZE : constant Ada.Containers.Count_Type := 100;
   -- public static
   MIN_TOKEN_INDEX : constant Integer := 0;

   -- ---------------- --
   -- RewriteOperation --
   -- ---------------- --
   type RewriteOperation is tagged record --
      -- What index into rewrites List are we?
      -- internal
      instructionIndex : Integer := 0;

      -- Token buffer index.
      -- internal
      index : Integer;

      -- internal
      text : Optional_UString;

      -- internal
      lastIndex : Integer := 0;

      -- internal weak
      tokens : TokenStream; --!
   end record;

   function "=" (Left, Right : RewriteOperation) return Boolean;

   function Hash_Integer (Key : Integer) return Ada.Containers.Hash_Type;
   function Equivalent_Keys (Left, Right : Integer) return Boolean
      is (Hash_Integer (Left) = Hash_Integer (Right));

   package RewriteOperation_Container is new Ada.Containers.Hashed_Maps (
      Key_Type => Integer,
      Element_Type => RewriteOperation,
      Hash => Hash_Integer,
      Equivalent_Keys => Equivalent_Keys,
      "=" => "=");
   subtype RewriteOperation_Map is RewriteOperation_Container.Map;

   package Option_RewriteOperation is new Option (RewriteOperation);
   subtype Optional_RewriteOperation is Option_RewriteOperation.Optional;
   function "=" (Left, Right : Optional_RewriteOperation) return Boolean;

   package Optional_RewriteOperation_Container is new Ada.Containers.Vectors (
      Index_Type => Natural,
      Element_Type => Optional_RewriteOperation,
      "=" => "=");
   subtype Optional_RewriteOperation_List is Optional_RewriteOperation_Container.Vector;

   procedure Initialize (Self : RewriteOperation; index : Integer; tokens : TokenStream);

   procedure Initialize (Self : RewriteOperation; index : Integer; text : Optional_UString; tokens : TokenStream);

   -- Execute the rewrite operation by possibly adding to the buffer.
   -- Return the index of the next token to operate on.
   --
   -- public
   function execute (This : RewriteOperation; buf : in out UString) return Integer
      is (This.index);

   subtype Sink is Ada.Strings.Text_Buffers.Root_Buffer_Type;
   procedure Put_Image_RewriteOperation (S : in out Sink'Class; X : RewriteOperation);
   for RewriteOperation'Put_Image use Put_Image_RewriteOperation;
   -- public
   function Description (This : RewriteOperation) return UString;

   -- ------------------- --
   -- TokenStreamRewriter --
   -- ------------------- --
   type RewriteOperationArray_Map;

   -- public
   type TokenStreamRewriter is new Ada.Finalization.Controlled with record
      -- public
      DEFAULT_PROGRAM_NAME : UString := "default"; -- constant

      -- Map UString (program name) > Integer index
      -- internal final
      lastRewriteTokenIndexes : TokenID_Map; -- := TokenID_Container.Empty_Map

      -- You may have multiple, named streams of rewrite operations.
      -- I'm calling these things "programs."
      -- Maps UString (name) > rewrite (List);
      --
      -- internal
      programs : RewriteOperationArray_Map;

      -- Define the rewrite operation hierarchy
      -- public
      RewriteOperation : TokenStreamRewriter;

      -- Our source stream
      -- internal
      tokens : TokenStream;
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
   overriding
   function execute (This : InsertBeforeOp; buf : in out UString) return Integer;
      text : constant Optional_Text := Maybe (This.text);
      token : constant := This.tokens.get (This.index);

   -- ------------- --
   -- InsertAfterOp --
   -- ------------- --
   -- public
   type InsertAfterOp is new InsertBeforeOp with null record;

   -- public
   overriding
   procedure Initialize (Self : in out InsertAfterOp;
                         index : Integer;
                         text : Optional_UString;
                         tokens : TokenStream);

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
                         text : Optional_UString;
                         tokens : TokenStream);

   -- public
   overriding
   function execute (This : ReplaceOp; buf : in out UString) return Integer;

   subtype Sink is Ada.Strings.Text_Buffers.Root_Buffer_Type;
   procedure Put_Image_ReplaceOp (S : in out Sink'Class; X : ReplaceOp);
   for ReplaceOp'Put_Image use Put_Image_ReplaceOp;
   -- public
   overriding
   function Description (This : ReplaceOp) return UString;

   -- --------------------- --
   -- RewriteOperationArray --
   -- --------------------- --
   -- public
   type RewriteOperationArray is new Ada.Finalization.Controlled with
   record
      -- private final 
      rewrites : Optional_RewriteOperation_List;
   end record;

   function "=" (Left, Right : RewriteOperationArray) return Boolean;

   function Hash_UString (Key : UString) return Ada.Containers.Hash_Type;
   function Equivalent_Keys (Left, Right : UString) return Boolean
      is (Hash (Left) = Hash (Right));

   package RewriteOperationArray_Container is new Ada.Containers.Hashed_Maps (
      Key_Type => UString,
      Element_Type => RewriteOperationArray,
      Hash => Hash_UString,
      Equivalent_Keys => Equivalent_Keys,
      "=" => "=");
   subtype RewriteOperationArray_Map is RewriteOperationArray_Container.Map;

   -- public
   overriding
   procedure Initialize (Self : in out RewriteOperationArray);

   -- final
   procedure append (This : RewriteOperationArray; op : RewriteOperation);

   -- final
   procedure rollback (This : in out RewriteOperationArray; instructionIndex : Integer);

   -- final
   function Is_Empty (This : RewriteOperationArray) return Boolean
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
   function reduceToSingleOperationPerIndex (This : RewriteOperationArray) return RewriteOperation_Map;

   -- final
   function catOpText (This : RewriteOperationArray; a, b : Optional_String) return UString;

   -- Get all operations before an index of a particular kind

   -- final
   generic
      type T is new RewriteOperation with private; -- T: RewriteOperation
   function getKindOfOps_T (This : RewriteOperationArray;
                            rewrites : in out Optional_RewriteOperation_List;
                            kind : RewriteOperation'Class;
                            before : Integer)
                            return Integer_List;

   -- ------------------ --

   -- public
   procedure Initialize (Self : in out TokenStreamRewriter; tokens : TokenStream);
      --TOFIX lastRewriteTokenIndexes : TokenID_Map;

   -- public final
   function getTokenStream (This : TokenStreamRewriter) return TokenStream
      is (This.tokens);

   -- public
   procedure rollback (This : TokenStreamRewriter; instructionIndex : Integer);

   -- Rollback the instruction stream for a program so that
   -- the indicated instruction (via instructionIndex) is no
   -- longer in the stream. UNTESTED!
   --
   -- public
   procedure rollback (This : TokenStreamRewriter;
                     programName : UString;
                     instructionIndex : Integer);

   -- public
   procedure deleteProgram (This : TokenStreamRewriter);

   -- Reset the program so that no instructions exist
   -- public
   procedure deleteProgram (This : TokenStreamRewriter; programName : UString);

   -- public
   procedure insertAfter (This : TokenStreamRewriter; t : Token; text : UString);

   -- public
   procedure insertAfter (This : TokenStreamRewriter; index : Integer; text : UString);

   -- public
   procedure insertAfter (This : TokenStreamRewriter; programName : UString; t : Token; text : UString);

   -- public
   procedure insertAfter (This : TokenStreamRewriter; programName : UString; index : Integer; text : UString);

   -- public
   procedure insertBefore (This : TokenStreamRewriter; t : Token; text : UString);

   -- public
   procedure insertBefore (This : TokenStreamRewriter; index : Integer; text : UString);

   -- public
   procedure insertBefore (This : TokenStreamRewriter; programName : UString; t : Token; text : UString);

   -- public
   procedure insertBefore (This : TokenStreamRewriter; programName : UString; index : Integer; text : UString);

   -- public
   procedure replace (This : TokenStreamRewriter; index : Integer; text : UString);

   -- public
   procedure replace (This : TokenStreamRewriter; from, to : Integer; text : UString);

   -- public
   procedure replace (This : TokenStreamRewriter; indexT : Token; text : UString);

   -- public
   procedure replace (This : TokenStreamRewriter; from, to : Token; text : UString);

   -- public
   procedure replace (This : TokenStreamRewriter; programName : UString; from, to : Integer; text : Optional_String);

   -- public
   procedure replace (This : TokenStreamRewriter; programName : UString; from, to : Token; text : Optional_String);

   -- public
   procedure delete (This : TokenStreamRewriter; index : Integer);

   -- public
   procedure delete (This : TokenStreamRewriter; from, to : Integer);

   -- public
   procedure delete (This : TokenStreamRewriter; indexT : Token);

   -- public
   procedure delete (This : TokenStreamRewriter; from, to : Token);

   -- public
   procedure delete (This : TokenStreamRewriter; programName : UString; from, to : Integer);

   -- public
   procedure delete (This : TokenStreamRewriter; programName : UString; from, to : Token);

   -- public
   function getLastRewriteTokenIndex (This : TokenStreamRewriter) return Integer;

   -- internal
   function getLastRewriteTokenIndex (This : TokenStreamRewriter; rogramName : UString) return Integer;

   -- internal
   procedure setLastRewriteTokenIndex (This : TokenStreamRewriter; programName : UString; i : Integer);

   -- internal
   function getProgram (This : TokenStreamRewriter; name : UString) return RewriteOperationArray;

   -- Return the text from the original tokens altered per the
   -- instructions given to this rewriter.
   --
   -- public
   function getText (This : TokenStreamRewriter) return UString
      is (getText (DEFAULT_PROGRAM_NAME, Interval.Set (0, This.tokens.size - 1)));

   -- Return the text from the original tokens altered per the
   -- instructions given to this rewriter in programName.
   --
   -- public
   function getText (This : TokenStreamRewriter; programName : UString) return UString
      is (getText (programName, Interval.Set (0, This.tokens.size - 1)));

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
                     return UString;

private

   function initializeProgram (This : TokenStreamRewriter; name : UString) return RewriteOperationArray;

end ANTLR.Runtime.TokenStreamRewriters;
