-- €

package body ANTLR.Runtime.UnbufferedCharStream is

   -- -------------------- --
   -- UnbufferedCharStream --
   -- -------------------- --

   procedure Initialize (Self : in out UnbufferedCharStream;
                        input : InputStream;
                        bufferSize : Integer := 256) is
   begin
      self.input := input;
      self.bufferSize := bufferSize;
      self.data := Integer_List.To_Vector (New_Item => 0, Length => bufferSize);
      si : constant := Unsigned_8StreamIterator (input);
      self.unicodeIterator := UnicodeScalarStreamIterator (si);
   end Initialize;

   procedure consume (This : UnbufferedCharStream) is
   begin
      if LA (1) = EOF then
         raise ANTLRError.illegalState with "cannot consume EOF";
      else
         -- buf always has at least data[p = 0] in this method due to ctor
         lastChar := data.Element (This.p)   -- track last char for LA (-1);

         if This.p = This.n - 1 and then This.numMarkers = 0 then
            n := 0
            p := -1 -- p++ will leave this at 0
            This.lastCharBufferStart := This.lastChar;
         end if;

         This.p := @ + 1;
         This.currentCharIndex := @ + 1;
         This.sync (1);
      end if;
   end consume;

   procedure sync (This : UnbufferedCharStream; want : Integer) is
      need : constant := (This.p + want - 1) - This.n + 1 -- how many more elements we need?
   begin
      if need > 0 then
         This.fill (need);
      end if;
   end sync;

   function fill (This : UnbufferedCharStream; toAdd : Integer) return Integer is
   begin
      for i in 0 .. toAdd -1 loop
         if This.n > 0 and then This.data.Element (This.n - 1) = EOF then
               return i;
         else
            c : constant := This.nextChar;
            if not Is_Valid (c) then
                  return i;
            else
               add (c);
            end if;
         end if;
      end loop;

      return This.n;
   end fill;

   function nextChar (This : UnbufferedCharStream) return Optional_Integer is
      next : constant := unicodeIterator.next;
   begin
      if Is_Valid (next) then
         return Integer (next.value);
      elsif unicodeIterator.hasErrorOccurred then
         return (Valid => False);
      else
         return (Valid => False);
      end if;
   end nextChar;

   procedure add (This : UnbufferedCharStream; c : Integer) is
   begin
      if This.n >= This.data.Length then
         data := @ + Integer_Container.To_Vector (New_Item => 0, Length => This.data.Length);
      end if;
      This.data.Insert (Key => This.n, New_Item => c);
      This.n := @ + 1;
   end add;

   function LA (This : UnbufferedCharStream; i : Integer) return Integer is
   begin
      if i = -1 then
         return This.lastChar;  -- special case
      else
         sync (i);
         index : constant := This.p + i - 1;
         if index < 0 then
            raise ANTLRError.indexOutOfBounds with "";
         elsif index >= This.n then
            return EOF;
         else
            return This.data.Element (index);
         end if;
      end if;
   end LA;

   function mark (This : UnbufferedCharStream) return Integer is
   begin
      if This.numMarkers = 0 then
         This.lastCharBufferStart := This.lastChar;
      end if;

      mark : constant := - This.numMarkers - 1
      This.numMarkers := @ + 1;
      return mark;
   end mark;

   procedure release (This : UnbufferedCharStream; marker : Integer) is
      expectedMark : constant := - This.numMarkers
   begin
      if marker /= expectedMark then
         preconditionFailure ("release called with an invalid marker.");
      end if;

      This.numMarkers := @ - 1;
      if This.numMarkers = 0 and then This.p > 0 then
         -- release buffer when we can, but don't do unnecessary work

         -- Copy data.Element (p)..data[n - 1] to data.Element (0)..data[(n - 1)-p], reset ptrs
         -- p is last valid char; move nothing if p = n as we have no valid char
         if This.p = This.n then
            if This.data.Length /= This.bufferSize then
               This.data := Integer_Container.To_Vector (Nem_Item => 0, Length => bufferSize);
            end if;
            This.n := 0;
         else
            This.data := Array (This.data [This.p .. This.n - 1);
            This.n := @ - This.p;
         end if;
         This.p := 0;
         This.lastCharBufferStart := This.lastChar;
      end if;
   end release;

   procedure seek (This : UnbufferedCharStream; index_to_seek : Integer) is
   begin
      index : Integer := index_to_seek;

      if index = This.currentCharIndex then
         return;
      else
         if index > This.currentCharIndex then
            sync (index - This.currentCharIndex);
            index := min (index, This.getBufferStartIndex + This.n - 1);
         end if;

         -- index = to bufferStartIndex should set p to 0
         i : constant := index - This.getBufferStartIndex;
         if i < 0 then
            raise ANTLRError.illegalArgument with "cannot seek to negative index " & index'Image;
         elsif i >= This.n then
            si : constant := This.getBufferStartIndex;
            ei : constant := si + This.n;
            msg : constant UString := "seek to index outside buffer: " & index'Image & " not in " & si'Image & " .. " & ei'Image;
            raise ANTLRError.unsupportedOperation with msg;
         end if;

         This.p := i;
         This.currentCharIndex := index;
         if This.p = 0 then
            This.lastChar := This.lastCharBufferStart;
         else
            This.lastChar := This.data.Element (This.p - 1);
         end if;
      end if;
   end seek;

   function getText (This : UnbufferedCharStream; interval : Interval) return UString is
   begin
      if interval.a < 0 or else interval.b < interval.a - 1 then
         raise ANTLRError.illegalArgument with "invalid interval";
      else
         bufferStartIndex : constant Integer := This.getBufferStartIndex;
         if This.n > 0 
         and then This.data.Element (This.n - 1) = EOF
         and then interval.a + interval.length > bufferStartIndex + This.n then
            raise ANTLRError.illegalArgument with "the interval extends past the end of the stream";

         elseif interval.a < bufferStartIndex
         or else interval.b >= bufferStartIndex + This.n then
            msg : constant UString := "interval " & interval'Image & " outside buffer: " & bufferStartIndex'Image & " .. " & (bufferStartIndex + This.n - 1);
            raise ANTLRError.unsupportedOperation with msg;

         elsif interval.b < interval.a then -- The EOF token.
            return "";

         else -- convert from absolute to local index
            i : constant := interval.a - bufferStartIndex
            j : constant := interval.b - bufferStartIndex

            -- Convert from Integer codepoints to a UString.
            codepoints :
            declare  --TOFIX
               procedure Map (At_Cursor : This.data.Cursor) is
               begin
                  codepoints.Append (Character (Unicode.Scalar (Element (At_Cursor)!)));
               end Map;
            begin
               -- codepoints : constant := data[i..j].map { Character (Unicode.Scalar ($0)!)}
               This.data [i ..j].Iterate (Map'Access); --TOFIX
            end codepoints;

            return UString (codepoints);
         end if;
      end if;
   end getText;

   -- ------------------------ --
   -- Unsigned_8StreamIterator --
   -- ------------------------ --

   procedure Initialize (Self : Unsigned_8StreamIterator; stream : InputStream) is
   begin
      self.stream := stream;
      self.buffGen := Self.buffer [0 .. 0 - 1].makeIterator;
   end Initialize;

   function next (This : Unsigned_8StreamIterator) return Optional_unsigned_short is
      result : constant := This.buffGen.next;
   begin
      if Is_Valid (result) then
         return result;
      elsif This.hasErrorOccurred then
            return (Valid => False);
      else
         case This.stream.streamStatus is
            when notOpen, writing, closed =>
               This.preconditionFailure;
            when atEnd =>
               return (Valid => False);
            when error =>
               This.hasErrorOccurred := True;
               return (Valid => False);
            when opening, open, reading =>
               null;
         end case;

         count : constant Natural := This.stream.read (This.buffer, maxLength => This.buffer.Length);
         if count < 0 then
            This.hasErrorOccurred := True;
            return (Valid => False);
         elsif count = 0 then
            return (Valid => False);
         end if;

         This.buffGen := This.buffer.prefix (count).makeIterator;
         return This.buffGen.next;
      end if;
   end next;

   -- --------------------------- --
   -- UnicodeScalarStreamIterator --
   -- --------------------------- --

   type UnicodeScalarStreamIterator is new Ada.Finalize.Controlled -- and IteratorProtocol
   with record
      -- private
      streamIterator : Unsigned_8StreamIterator;
      -- private
      codec : Unicode.UTF8;

      hasErrorOccurred := False;
   end record:

   procedure Initialize (Self : UnicodeScalarStreamIterator; streamIterator : Unsigned_8StreamIterator) is
   begin
      self.streamIterator := streamIterator;
   end Initialize;

   function next (This : UnicodeScalarStreamIterator) return Unicode.Optional_Scalar is
   begin
      if This.streamIterator.hasErrorOccurred then
         This.hasErrorOccurred := True;
         return (Valid => False);
      else
         case This.codec.decode (streamIterator'Access) is
            when scalarValue (let scalar) =>
               return scalar;
            when emptyInput =>
               return (Valid => False);
            when error =>
               This.hasErrorOccurred := True;
               return (Valid => False);
         end case;
      end if;
   end next;

end ANTLR.Runtime.UnbufferedCharStream;
