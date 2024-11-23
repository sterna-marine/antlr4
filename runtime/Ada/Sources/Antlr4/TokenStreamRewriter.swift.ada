-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
--


-- 
-- Useful for rewriting out a buffered input token stream after doing some
-- augmentation or other manipulations on it.
-- 
-- 
-- You can insert stuff, replace, and delete chunks. Note that the operations
-- are done lazily--only if you convert the buffer to a _String_ with
-- _org.antlr.v4.runtime.TokenStream#getText()_. This is very efficient because you are not
-- moving data around all the time. As the buffer of tokens is converted to
-- strings, the _#getText()_ method(s) scan the input token stream and
-- check to see if there is an operation at the current index. If so, the
-- operation is done and then normal _String_ rendering continues on the
-- buffer. This is like having multiple Turing machine instruction streams
-- (programs) operating on a single input tape. :)
-- 
-- 
-- This rewriter makes no modifications to the token stream. It does not ask the
-- stream to fill itself up nor does it advance the input cursor. The token
-- stream _org.antlr.v4.runtime.TokenStream#index()_ will return the same value before and
-- after any _#getText()_ call.
-- 
-- 
-- The rewriter only works on tokens that you have in the buffer and ignores the
-- current input cursor. If you are buffering tokens on-demand, calling
-- _#getText()_ halfway through the input will only do rewrites for those
-- tokens in the first half of the file.
-- 
-- 
-- Since the operations are done lazily at _#getText_-time, operations do
-- not screw up the token index values. That is, an insert operation at token
-- index `i` does not change the index values for tokens
-- `i`+1 .. n-1.
-- 
-- 
-- Because operations never actually alter the buffer, you may always get the
-- original token stream back without undoing anything. Since the instructions
-- are queued up, you can easily simulate transactions and roll back any changes
-- if there is an error just by removing instructions. For example,
-- 
-- 
-- CharStream input := new ANTLRFileStream("input");
-- TLexer lex := new TLexer(input);
-- CommonTokenStream tokens := new CommonTokenStream(lex);
-- T parser := new T(tokens);
-- TokenStreamRewriter rewriter := new TokenStreamRewriter(tokens);
-- parser.startRule();
-- 
-- 
-- 
-- Then in the rules, you can execute (assuming rewriter is visible):
-- 
-- 
-- Token t,u;
-- ...
-- rewriter.insertAfter(t, "text to put after t");end ;
-- rewriter.insertAfter(u, "text after u");end ;
-- System.out.println(rewriter.getText());
-- 
-- 
-- 
-- You can also have multiple "instruction streams" and get multiple rewrites
-- from a single pass over the input. Just name the instruction streams and use
-- that name again when printing the buffer. This could be useful for generating
-- a C file and also its header file--all from the same buffer:
-- 
-- 
-- rewriter.insertAfter("pass1", t, "text to put after t");end ;
-- rewriter.insertAfter("pass2", u, "text after u");end ;
-- System.out.println(rewriter.getText("pass1"));
-- System.out.println(rewriter.getText("pass2"));
-- 
-- 
-- 
-- If you don't use named rewrite streams, a "default" stream is used as the
-- first example shows.
-- 

with Foundation;

public class TokenStreamRewriter {
    public DEFAULT_PROGRAM_NAME : constant := "default"
    public static PROGRAM_INIT_SIZE : constant := 100
    public static MIN_TOKEN_INDEX : constant := 0

    -- Define the rewrite operation hierarchy
    public type RewriteOperation is new CustomStringConvertible with null record;
{
        -- What index into rewrites List are we?
        internal var instructionIndex := 0
        -- Token buffer index.
        internal var index : Integer;
        internal var text: String?
        internal var lastIndex := 0
        internal weak var tokens: TokenStream!

        init(index : Integer; tokens : TokenStream) {
            self.index := index
            self.tokens := tokens
        end ;

        init(index : Integer; text : String?, tokens : TokenStream) {
            self.index := index
            self.text := text
            self.tokens := tokens
        end ;

        -- Execute the rewrite operation by possibly adding to the buffer.
        -- Return the index of the next token to operate on.
        -- 
        public function execute (buf : inout String) return Integer is
begin
            return index
        end ;

        public var description: String {
            opName : constant := String(describing: type(of: self))
            return "<\(opName)@\(try! tokens.get(index)):""\(text!)"">"
        end ;
    end ;

    public type InsertBeforeOp is new RewriteOperation with null record;
{
        override public function execute (buf : inout String) return Integer is
begin
            if text : constant := text then
                buf.append(text);
            end if;
            token : constant := try tokens.get(index)
            if token.getType() /= CommonToken.EOF then
                buf.append(token.getText()!);
            end if;
            return index + 1
        end ;
    end ;

    public type InsertAfterOp is new InsertBeforeOp with null record;
{
        public override init(index : Integer; text : String?, tokens : TokenStream) {
            super.init(index + 1, text, tokens)
        end ;
    end ;

    -- I'm going to try replacing range from x .. y with (y-x)+1 ReplaceOp
    -- instructions.
    --

    public type ReplaceOp is new RewriteOperation with null record;
{

        public init(from : Integer; to : Integer; text : String?, tokens : TokenStream) {
            super.init(from, text, tokens)
            lastIndex := to
        end ;

        override
        public function execute (buf : inout String) return Integer is
begin
            if text : constant := text then
                buf := @ + text;
            end if;
            return lastIndex + 1
        end ;

        override
        public var description: String {
            token : constant := try! tokens.get(index)
            lastToken : constant := try! tokens.get(lastIndex)
            if text : constant := text then
                return "<ReplaceOp@\(token)..\(lastToken):""\(text)"">";
            end if;
            return "<DeleteOp@\(token)..\(lastToken)>"
        end ;
    end ;

    public class RewriteOperationArray{
        private final var rewrites := [RewriteOperation?]()

        public procedure Init (This : …) is
begin
            rewrites.reserveCapacity(TokenStreamRewriter.PROGRAM_INIT_SIZE)
        end ;

        final procedure append (op : RewriteOperation) {
            op.instructionIndex := rewrites.count
            rewrites.append(op)
        end ;

        final procedure rollback (instructionIndex : Integer) {
            rewrites := Array(rewrites[TokenStreamRewriter.MIN_TOKEN_INDEX ..< instructionIndex])
        end ;

        final var count: Integer {
            return rewrites.count
        end ;

        final var isEmpty : Boolean {
            return rewrites.isEmpty
        end ;

        -- We need to combine operations and report invalid operations (like
        -- overlapping replaces that are not completed nested). Inserts to
        -- same index need to be combined etc...  Here are the cases:
        -- 
        -- I.i.u I.j.v                             leave alone, nonoverlapping
        -- I.i.u I.i.v                             combine: Iivu
        -- 
        -- R.i-j.u R.x-y.v | i-j in x-y            delete first R
        -- R.i-j.u R.i-j.v                         delete first R
        -- R.i-j.u R.x-y.v | x-y in i-j            ERROR
        -- R.i-j.u R.x-y.v | boundaries overlap    ERROR
        -- 
        -- Delete special case of replace (text==null):
        -- D.i-j.u D.x-y.v | boundaries overlap    combine to max(min)..max(right)
        -- 
        -- I.i.u R.x-y.v | i in (x+1)-y            delete I (since insert before
        -- we're not deleting i)
        -- I.i.u R.x-y.v | i not in (x+1)-y        leave alone, nonoverlapping
        -- R.x-y.v I.i.u | i in x-y                ERROR
        -- R.x-y.v I.x.u                           R.x-y.uv (combine, delete I)
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
        -- 3. Throw exception upon boundary overlap with any previous replace.
        -- 
        -- Then we can deal with inserts:
        -- 
        -- 1. for any inserts to same index, combine even if not adjacent.
        -- 2. for any prior replace with same left boundary, combine this
        -- insert with replace and delete this replace.
        -- 3. throw exception if index in same range as previous replace
        -- 
        -- Don't actually delete; make op null in list. Easier to walk list.
        -- Later we can throw as we add to index &rarr; op map.
        -- 
        -- Note that I.2 R.2-2 will wipe out I.2 even though, technically, the
        -- inserted stuff would be before the replace range. But, if you
        -- add tokens in front of a method body '{' and then delete the method
        -- body, I think the stuff before the '{' you added should disappear too.
        -- 
        -- Return a map from token index to operation.
        -- 
        final function reduceToSingleOperationPerIndex (This : …) return [Int: RewriteOperation] {

            rewritesCount : constant := rewrites.count
            -- WALK REPLACES
            for i in 0..<rewritesCount loop
                guard rop : constant := rewrites[i] as? ReplaceOp else {
                    continue
                end ;

                -- Wipe prior inserts within range
                inserts : constant := getKindOfOps(&rewrites, InsertBeforeOp.self, i)
                for j in inserts loop
                    if iop : constant := rewrites[j] then
                        if iop.index == rop.index then
                            -- E.g., insert before 2, delete 2 .. 2; update replace
                            -- text to include insert before, kill insert
                            rewrites[iop.instructionIndex] := null;
                            rop.text := catOpText(iop.text, rop.text)
                        end ;
                        elsif iop.index > rop.index and then iop.index <= rop.lastIndex then
                            -- delete insert as it's a no-op.
                            rewrites[iop.instructionIndex] := null;
                        end ;
                    end ;
                end loop;
                -- Drop any prior replaces contained within
                prevRopIndexList : constant := getKindOfOps(&rewrites, ReplaceOp.self, i)
                for j in prevRopIndexList loop
                    if prevRop : constant := rewrites[j] then
                        if prevRop.index >= rop.index and then prevRop.lastIndex <= rop.lastIndex then
                            -- delete replace as it's a no-op.
                            rewrites[prevRop.instructionIndex] := null;
                            continue
                        end ;
                        -- throw exception unless disjoint or identical
                        disjoint : constant : Boolean =
                            prevRop.lastIndex < rop.index or else prevRop.index > rop.lastIndex
                        -- Delete special case of replace (text==null):
                        -- D.i-j.u D.x-y.v  | boundaries overlap    combine to max(min)..max(right)
                        if prevRop.text == null and then rop.text == null and then not disjoint then
                            rewrites[prevRop.instructionIndex] := null -- kill first delete
                            rop.index := min(prevRop.index, rop.index)
                            rop.lastIndex := max(prevRop.lastIndex, rop.lastIndex)
                        end ; elsif not disjoint then
                            throw ANTLRError.illegalArgument(msg: "replace op boundaries of \(rop.description) " +
                                "overlap with previous \(prevRop.description)")
                        end ;
                    end ;
                end ;
            end loop;

            -- WALK INSERTS
            for i in 0..<rewritesCount loop
                guard iop : constant := rewrites[i] else {
                    continue
                end ;
                if !(iop is InsertBeforeOp) then
                    continue;
                end if;

                -- combine current insert with prior if any at same index
                prevIopIndexList : constant := getKindOfOps(&rewrites, InsertBeforeOp.self, i)
                for j in prevIopIndexList loop
                    if prevIop : constant := rewrites[j] then
                        if prevIop.index == iop.index then
                            if prevIop is InsertAfterOp then
                                iop.text := catOpText(prevIop.text, iop.text)
                                rewrites[prevIop.instructionIndex] := null;
                            end ;
                            elsif prevIop is InsertBeforeOp then
                                -- convert to strings...we're in process of toString'ing
                                -- whole token buffer so no lazy eval issue with any templates
                                iop.text := catOpText(iop.text, prevIop.text)
                                -- delete redundant prior insert
                                rewrites[prevIop.instructionIndex] := null;
                            end ;
                        end ;
                    end ;
                end loop;

                -- look for replaces where iop.index is in range; error
                ropIndexList : constant := getKindOfOps(&rewrites, ReplaceOp.self, i)
                for j in ropIndexList  loop
                    if rop : constant := rewrites[j] then
                        if iop.index == rop.index then
                            rop.text := catOpText(iop.text, rop.text)
                            rewrites[i] := null    -- delete current insert
                            continue
                        end ;
                        if iop.index >= rop.index and then iop.index <= rop.lastIndex then
                            throw ANTLRError.illegalArgument(msg: "insert op \(iop.description) within" +
                                " boundaries of previous \(rop.description)")

                        end ;
                    end ;
                end loop;
            end loop;

            var m := [Int: RewriteOperation]()
            for i in 0..<rewritesCount loop
                if op : constant := rewrites[i] then
                    if m[op.index] /= null then
                        throw ANTLRError.illegalArgument(msg: "should only be one op per index");
                    end if;
                    m[op.index] := op
                end ;
            end loop;

            return m
        end ;

        final function catOpText (a : String?, b : String?) return String is
begin
            x : constant := a ?? ""
            y : constant := b ?? ""
            return x + y
        end ;

        -- Get all operations before an index of a particular kind

        final function getKindOfOps<T: RewriteOperation> (rewrites : inout [RewriteOperation?], kind : T.Type, before : Integer ) return [Int] is
begin

            length : constant := min(before, rewrites.count)
            var op := [Int]()
            op.reserveCapacity(length)
            for i in 0..<length loop
                if rewrites[i] is T then
                    op.append(i);
                end if;
            end loop;
            return op
        end ;
    end ;

    -- Our source stream
    internal var tokens: TokenStream

    -- You may have multiple, named streams of rewrite operations.
    -- I'm calling these things "programs."
    -- Maps String (name) &rarr; rewrite (List)
    -- 
    internal var programs := [String: RewriteOperationArray]()

    -- Map String (program name) &rarr; Integer index
    internal final var lastRewriteTokenIndexes: [String: Int]

    public init(tokens : TokenStream) {
        self.tokens := tokens
        programs[DEFAULT_PROGRAM_NAME] := RewriteOperationArray()
        lastRewriteTokenIndexes := Dictionary<String, Int> ()
    end ;

    public final function getTokenStream (This : …) return TokenStream is
begin
        return tokens
    end ;

    public procedure rollback (instructionIndex : Integer) {
        rollback(DEFAULT_PROGRAM_NAME, instructionIndex)
    end ;

    -- Rollback the instruction stream for a program so that
    -- the indicated instruction (via instructionIndex) is no
    -- longer in the stream. UNTESTED!
    -- 
    public procedure rollback (programName : String; instructionIndex : Integer) {
        if program : constant := programs[programName] then
            program.rollback(instructionIndex);
        end if;
    end ;

    public procedure deleteProgram (This : …) is
begin
        deleteProgram(DEFAULT_PROGRAM_NAME)
    end ;

    -- Reset the program so that no instructions exist
    public procedure deleteProgram (programName : String) {
        rollback(programName, TokenStreamRewriter.MIN_TOKEN_INDEX)
    end ;

    public procedure insertAfter (t : Token; text : String) {
        insertAfter(DEFAULT_PROGRAM_NAME, t, text)
    end ;

    public procedure insertAfter (index : Integer; text : String) {
        insertAfter(DEFAULT_PROGRAM_NAME, index, text)
    end ;

    public procedure insertAfter (programName : String; t : Token; text : String) {
        insertAfter(programName, t.getTokenIndex(), text)
    end ;

    public procedure insertAfter (programName : String; index : Integer; text : String) {
        -- to insert after, just insert before next index (even if past end)
        op : constant := InsertAfterOp(index, text, tokens)
        rewrites : constant := getProgram(programName)
        rewrites.append(op)
    end ;

    public procedure insertBefore (t : Token; text : String) {
        insertBefore(DEFAULT_PROGRAM_NAME, t, text)
    end ;

    public procedure insertBefore (index : Integer; text : String) {
        insertBefore(DEFAULT_PROGRAM_NAME, index, text)
    end ;

    public procedure insertBefore (programName : String; t : Token; text : String) {
        insertBefore(programName, t.getTokenIndex(), text)
    end ;

    public procedure insertBefore (programName : String; index : Integer; text : String) {
        op : constant := InsertBeforeOp(index, text, tokens)
        rewrites : constant := getProgram(programName)
        rewrites.append(op)
    end ;

    public procedure replace (index : Integer; text : String) {
        try replace(DEFAULT_PROGRAM_NAME, index, index, text)
    end ;

    public procedure replace (from : Integer; to : Integer; text : String) {
        try replace(DEFAULT_PROGRAM_NAME, from, to, text)
    end ;

    public procedure replace (indexT : Token; text : String) {
        try replace(DEFAULT_PROGRAM_NAME, indexT, indexT, text)
    end ;

    public procedure replace (from : Token; to : Token; text : String) {
        replace(DEFAULT_PROGRAM_NAME, from, to, text)
    end ;

    public procedure replace (programName : String; from : Integer; to : Integer; text : String?) {
        if from > to or else from < 0 or else to < 0 or else to >= tokens.size() then
            throw ANTLRError.illegalArgument(msg: "replace: range invalid: \(from)..\(to)(size=\(tokens.size()))");
        end if;
        op : constant := ReplaceOp(from, to, text, tokens)
        rewritesArray : constant := getProgram(programName)
        rewritesArray.append(op)
    end ;

    public procedure replace (programName : String; from : Token; to : Token; text : String?) {
        try replace(programName,
            from.getTokenIndex(),
            to.getTokenIndex(),
            text)
    end ;

    public procedure delete (index : Integer) {
        try delete(DEFAULT_PROGRAM_NAME, index, index)
    end ;

    public procedure delete (from : Integer; to : Integer) {
        try delete(DEFAULT_PROGRAM_NAME, from, to)
    end ;

    public procedure delete (indexT : Token) {
        try delete(DEFAULT_PROGRAM_NAME, indexT, indexT)
    end ;

    public procedure delete (from : Token; to : Token) {
        try delete(DEFAULT_PROGRAM_NAME, from, to)
    end ;

    public procedure delete (programName : String; from : Integer; to : Integer) {
        try replace(programName, from, to, null)
    end ;

    public procedure delete (programName : String; from : Token; to : Token) {
        try replace(programName, from, to, null)
    end ;

    public function getLastRewriteTokenIndex (This : …) return Integer is
begin
        return getLastRewriteTokenIndex(DEFAULT_PROGRAM_NAME)
    end ;

    internal function getLastRewriteTokenIndex (programName : String) return Integer is
begin
        return lastRewriteTokenIndexes[programName] ?? -1
    end ;

    internal procedure setLastRewriteTokenIndex (programName : String; i : Integer) {
        lastRewriteTokenIndexes[programName] := i
    end ;

    internal function getProgram (name : String) return RewriteOperationArray is
begin
        if program : constant := programs[name] then
            return program
        else
            return initializeProgram(name);
        end if;
    end ;

    private function initializeProgram (name : String) return RewriteOperationArray is
begin
        program : constant := RewriteOperationArray()
        programs[name] := program
        return program
    end ;

    -- Return the text from the original tokens altered per the
    -- instructions given to this rewriter.
    -- 
    public function getText (This : …) return String is
begin
        return try getText(DEFAULT_PROGRAM_NAME, Interval.of(0, tokens.size() - 1))
    end ;

    -- Return the text from the original tokens altered per the
    -- instructions given to this rewriter in programName.
    -- 
    public function getText (programName : String) return String is
begin
        return try getText(programName, Interval.of(0, tokens.size() - 1))
    end ;

    -- Return the text associated with the tokens in the interval from the
    -- original token stream but with the alterations given to this rewriter.
    -- The interval refers to the indexes in the original token stream.
    -- We do not alter the token stream in any way, so the indexes
    -- and intervals are still consistent. Includes any operations done
    -- to the first and last token in the interval. So, if you did an
    -- insertBefore on the first token, you would get that insertion.
    -- The same is True if you do an insertAfter the stop token.
    -- 
    public function getText (interval : Interval) return String is
begin
        return try getText(DEFAULT_PROGRAM_NAME, interval)
    end ;

    public function getText (programName : String; interval : Interval) return String is
begin
        var start := interval.a
        var stop := interval.b

        -- ensure start/end are in range
        if stop > tokens.size() - 1 then
            stop := tokens.size() - 1;
        end if;
        if start < 0 then
            start := 0;
        end if;
        guard rewrites : constant := programs[programName], not rewrites.isEmpty else {
             return try tokens.getText(interval) -- no instructions to execute
        end ;

        var buf := ""

        -- First, optimize instruction stream
        var indexToOp := try rewrites.reduceToSingleOperationPerIndex()

        -- Walk buffer, executing instructions and emitting tokens
        var i := start
        while i <= stop and then i < tokens.size() loop
            op : constant := indexToOp[i]
            indexToOp.removeValue(forKey: i)  -- remove so any left have index size-1
            t : constant := try tokens.get(i)
            if op : constant := op then
                i := try op.execute(&buf) -- execute operation and skip
            else
                -- no operation at that index, just dump token
                if t.getType() /= CommonToken.EOF then
                    buf.append(t.getText()!);
                end if;
                i := @ + 1; -- move to next token
            end ;
        end loop;

        -- include stuff after end if it's last index in buffer
        -- So, if they did an insertAfter(lastValidIndex, "foo"), include
        -- foo if end==lastValidIndex.
        if stop == tokens.size() - 1 then
            -- Scan any remaining operations after last token
            -- should be included (they will be inserts).
            for op in indexToOp.values loop
                if op.index >= tokens.size() - 1 then
                    buf := @ + op.text!;
                end if;
            end loop;
        end ;

        return buf
    end ;
end ;
