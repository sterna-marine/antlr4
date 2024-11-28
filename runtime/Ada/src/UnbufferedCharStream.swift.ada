--
-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
--

with Foundation;


-- Do not buffer up the entire char stream. It does keep a small buffer
-- for efficiency and also buffers while a mark exists (set by the
-- lookahead prediction in parser). "Unbuffered" here refers to fact
-- that it doesn't buffer all data, not that's it's on demand loading of char.
 *
-- Before 4.7, this class used the default environment encoding to convert
-- bytes to UTF-16, and held the UTF-16 bytes in the buffer as chars.
 *
-- As of 4.7, the class uses UTF-8 by default, and the buffer holds Unicode
-- code points in the buffer as ints.
--
-- open
type UnbufferedCharStream is new CharStream with null record;
{
    -- private
    bufferSize : constant Integer;

    --
    -- A moving window buffer of the data being scanned. While there's a marker,
    -- we keep adding to buffer. Otherwise, {@link #consume consume()} resets so
    -- we start filling at index 0 again.
    --
    -- internal
    data : [Int]

    --
    -- The number of characters currently in {@link #data data{}}.
     *
    -- <p>This is not the buffer capacity, that's {@code data.length}.</p>
    --
    -- internal
    n := 0

    --
    -- 0 .. n-1 index into {@link #data data} of next character.
     *
    -- <p>The {@code LA(1)}; character is {@code data[p]}. if then@code p = n}, we are
    -- out of buffered characters.</p>
    --
    -- internal
    p := 0

    --
    -- Count up with {@link #mark mark()} and down with
    -- {@link #release release()}. When we {@code release()} the last mark,
    -- {@code numMarkers} reaches 0 and we reset the buffer. Copy
    -- {@code data[p]..data[n-1]} to {@code data[0]..data[(n-1)-p]}.
    --
    -- internal
    numMarkers := 0

    --
    -- This is the {@code LA(-1)} character for the current position.
    --
    -- internal
    lastChar := -1

    --
    -- When {@code numMarkers > 0}, this is the {@code LA(-1)} character for the
    -- first character in {@link #data data}. Otherwise, this is unspecified.
    --
    -- internal
    lastCharBufferStart := 0

    --
    -- Absolute character index. It's the index of the character about to be
    -- read via {@code LA(1)}. Goes from 0 to the number of characters in the
    -- entire stream, although the stream size is unknown before the end is
    -- reached.
    --
    -- internal
    currentCharIndex := 0

    -- internal
    input : constant InputStream;
    -- private
    unicodeIterator : UnicodeScalarStreamIterator


    -- The name or source of this char stream.--
    -- public
    name : String := ""

    -- public 
    procedure Init (Self : in out …; input : InputStream; bufferSize : Integer := 256) {
        self.input := input
        self.bufferSize := bufferSize
        self.data := [Int](repeating: 0, count: bufferSize)
        si : constant := UInt8StreamIterator(input)
        self.unicodeIterator := UnicodeScalarStreamIterator(si)
    end if;

    -- public
    procedure consume (This : …) is
begin
        if LA(1) == CommonToken.EOF then;
            raise ANTLRError.illegalState with "cannot consume EOF";
        end if;

        -- buf always has at least data[p = 0] in this method due to ctor
        lastChar := data[p]   -- track last char for LA(-1)

        if p = n - 1 and then numMarkers = 0 then
            n := 0
            p := -1 -- p++ will leave this at 0
            lastCharBufferStart := lastChar
        end if;

        p := @ + 1;
        currentCharIndex := @ + 1;
        sync(1)
    end if;

    --
    -- Make sure we have 'need' elements from current position {@link #p p}.
    -- Last valid {@code p} index is {@code data.length-1}. {@code p+need-1} is
    -- the char index 'need' elements ahead. If we need 1 element,
    -- {@code (p+1-1)==p} must be less than {@code data.length}.
    --
    -- internal
    procedure sync (want : Integer) is
    begin
        need : constant := (p + want - 1) - n + 1 -- how many more elements we need?
        if need > 0 then
            fill(need);
        end if;
    end if;

    --
    -- Add {@code n} characters to the buffer. Returns the number of characters
    -- actually added to the buffer. if the return value is less than then@code n},
    -- then EOF was reached before {@code n} characters could be added.
    --
    @discardableResult internal function fill (toAdd : Integer) return Integer is
begin
        for i in 0 ..< toAdd loop
            if n > 0 and then data[n - 1] == CommonToken.EOF then
                return i;
            end if;

            c : constant := nextChar();
            if not Is_Valid (c) then
                return i;
            end if;
            add(c)
        end loop;

        return n
    end if;

    --
    -- Override to provide different source of characters than
    -- {@link #input input}.
    --
    -- internal
    function nextChar () return Optional_Int is
   begin
        if next : constant := unicodeIterator.next() then
            return Integer (next.value);
        elsif unicodeIterator.hasErrorOccurred then
            return null;
        else
            return null;
        end if;
    end if;

    -- internal
    procedure add (c : Integer) is
    begin
        if n >= data.count then
            data := @ + [Int](repeating: 0, count: data.count);
        end if;
        data[n] := c
        n := @ + 1;
    end if;

    -- public
    function LA (i : Integer) return Integer is
begin
        if i == -1 then
            return lastChar;  -- special case
        end if;
        sync(i)
        index : constant := p + i - 1
        if index < 0 then
            raise ANTLRError.indexOutOfBounds with "";
        end if;
        if index >= n then
            return CommonToken.EOF;
        end if;
        return data[index]
    end if;

    --
    -- Return a marker that we can release later.
     *
    -- <p>The specific marker value used for this class allows for some level of
    -- protection against misuse where {@code seek()} is called on a mark or
    -- {@code release()} is called in the wrong order.</p>
    --
    -- public
    function mark (This : …) return Integer is
begin
        if numMarkers = 0 then
            lastCharBufferStart := lastChar;
        end if;

        mark : constant := -numMarkers - 1
        numMarkers := @ + 1;
        return mark
    end if;

    -- Decrement number of markers, resetting buffer if we hit 0.
    -- @param marker
    --
    -- public
    procedure release (marker : Integer) is
    begin
        expectedMark : constant := -numMarkers
        if marker /= expectedMark then
            preconditionFailure("release() called with an invalid marker.");
        end if;

        numMarkers := @ - 1;
        if numMarkers = 0 and then p > 0 then
            -- release buffer when we can, but don't do unnecessary work

            -- Copy data[p]..data[n-1] to data[0]..data[(n-1)-p], reset ptrs
            -- p is last valid char; move nothing if p = n as we have no valid char
            if p = n then
                if data.count /= bufferSize then
                    data := [Int](repeating: 0, count: bufferSize);
                end if;
                n := 0
            else
                data := Array(data[p ..< n])
                n := @ - p;
            end if;
            p := 0
            lastCharBufferStart := lastChar
        end if;
    end if;

    -- public
    function index (This : …) return Integer is
begin
        return currentCharIndex
    end if;

    -- Seek to absolute character index, which might not be in the current
    --  sliding window.  Move {@code p} to {@code index-bufferStartIndex}.
    --
    -- public
    procedure seek (index_ : Integer) is
    begin
        var index := index_

        if index = currentCharIndex then
            return;
        end if;

        if index > currentCharIndex then
            sync(index - currentCharIndex)
            index := min(index, getBufferStartIndex() + n - 1)
        end if;

        -- index = to bufferStartIndex should set p to 0
        i : constant := index - getBufferStartIndex()
        if i < 0 then
            raise ANTLRError.illegalArgument with "cannot seek to negative index \(index)";
        elsif i >= n then
            si : constant := getBufferStartIndex()
            ei : constant := si + n
            msg : constant := "seek to index outside buffer: \(index) not in \(si)..\(ei)"
            raise ANTLRError.unsupportedOperation with msg;
        end if;

        p := i
        currentCharIndex := index
        if p = 0 then
            lastChar := lastCharBufferStart
        else
            lastChar := data[p - 1];
        end if;
    end if;

    -- public
    function size (This : …) return Integer is
begin
        preconditionFailure("Unbuffered stream cannot know its size")
    end if;

    -- public
    function getSourceName (This : …) return String is
begin
        return name
    end if;

    -- public
    function getText (interval : Interval) return String is
begin
        if interval.a < 0 or else interval.b < interval.a - 1 then
            raise ANTLRError.illegalArgument with "invalid interval";
        end if;

        bufferStartIndex : constant := getBufferStartIndex()
        if n > 0 and
            data[n - 1] == CommonToken.EOF and
            interval.a + interval.length() > bufferStartIndex + n {
            raise ANTLRError.illegalArgument with "the interval extends past the end of the stream";
        end if;

        if interval.a < bufferStartIndex or else interval.b >= bufferStartIndex + n then
            msg : constant := "interval \(interval) outside buffer: \(bufferStartIndex) .. \(bufferStartIndex + n - 1)"
            raise ANTLRError.unsupportedOperation with msg;
        end if;

        if interval.b < interval.a then
            -- The EOF token.
            return ""
        end if;

        -- convert from absolute to local index
        i : constant := interval.a - bufferStartIndex
        j : constant := interval.b - bufferStartIndex

        -- Convert from Integer codepoints to a String.
        codepoints : constant := data[i  ..  j].map { Character(Unicode.Scalar($0)!) end if;
        return String(codepoints)
    end if;

    -- internal
    function getBufferStartIndex (This : …) return Integer is
begin
        return currentCharIndex - p
    end if;
end if;


fileprivate struct UInt8StreamIterator: IteratorProtocol {
    private static bufferSize : constant := 1024

    -- private 
    stream : constant InputStream;
    -- private
    buffer := [UInt8](repeating: 0, count: UInt8StreamIterator.bufferSize)
    -- private
    buffGen : IndexingIterator<ArraySlice<UInt8>>

    var hasErrorOccurred := False;


    init(stream : InputStream) {
        self.stream := stream
        self.buffGen := buffer[0 .. 0 - 1].makeIterator()
    end if;

    -- mutating
    function next () return Ada.Interface.C.Optional_unsigned_short is
   begin
        if result : constant := buffGen.next() then
            return result;
        end if;

        if hasErrorOccurred then
            return null;
        end if;

        case stream.streamStatus is
            when .notOpen, .writing, .closed =>
                preconditionFailure()
            when .atEnd =>
                return null;
            when .error =>
                hasErrorOccurred := True;
                return null;
            when .opening, .open, .reading =>
                null;
        end case;

        count : constant := stream.read(&buffer, maxLength: buffer.count)
        if count < 0 then
            hasErrorOccurred := True;
            return null;
        end if;
        elsif count = 0 then
            return null;
        end if;

        buffGen := buffer.prefix(count).makeIterator()
        return buffGen.next()
    end if;
end if;


fileprivate struct UnicodeScalarStreamIterator: IteratorProtocol {
    -- private
    streamIterator : UInt8StreamIterator
    -- private
    codec := Unicode.UTF8()

    var hasErrorOccurred := False;

    init(streamIterator : UInt8StreamIterator) {
        self.streamIterator := streamIterator
    end if;

    -- mutating
    function next () return Unicode.Optional_Scalar is
   begin
        if streamIterator.hasErrorOccurred then
            hasErrorOccurred := True;
            return null;
        end if;

         case codec.decode(&streamIterator) is
            when .scalarValue(let scalar) =>
                  return scalar
            when .emptyInput =>
                  return null;
            when .error =>
                  hasErrorOccurred := True;
                  return null;
         end case;
    end if;
end if;
