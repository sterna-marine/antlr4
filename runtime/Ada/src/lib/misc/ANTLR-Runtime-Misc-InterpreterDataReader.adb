-- €

with Ada.Finalization;

-- A class to read plain text interpreter data produced by ANTLR.
-- public
type InterpreterDataReader is new Ada.Finalization.Controlled record

    let filePath:String,
        atn:ATN,
        vocabulary:Vocabulary,
        ruleNames:[UString],
        channelNames:[UString], -- Only valid for lexer grammars.
        modeNames:[UString] -- ditto

    --
    -- The structure of the data file is line based with empty lines
    -- separating the different parts. For lexers the layout is:
    -- token literal names:
    --  ..
     *
    -- token symbolic names:
    --  ..
     *
    -- rule names:
    --  ..
     *
    -- channel names:
    --  ..
     *
    -- mode names:
    --  ..
     *
    -- atn:
    -- <a single line with comma separated Integer values> enclosed in a pair of squared brackets.
     *
    -- Data for a parser does not contain channel and mode names.
    --
    type Part is (
        partName,
        tokenLiteralNames,
        tokenSymbolicNames,
        ruleNames,
        channelNames,
        modeNames,
        atn);


    Error : exception; --Swift.Error {dataError (String)};

    -- public
    procedure Initialize (Self : in out …; _ filePath:String) {
        self.filePath := filePath
        contents : constant UString := To_String (contentsOfFile => filePath, encoding => UString.Encoding.utf8);
        part := Part.partName,
            literalNames := UString.Container.Empty_Vector,
            symbolicNames := UString.Container.Empty_Vector,
            ruleNames := UString.Container.Empty_Vector,
            channelNames := UString.Container.Empty_Vector,
            modeNames := UString.Container.Empty_Vector,
            atnText := Substring.Container.Empty_Vector,
            fail: Optional_Error;
        contents.enumerateLines { (line,stop) in
            -- have to be moved outside the enumerateLines block
            if line == "" then
                part := .partName;
            end if;
            case part is
               when .partName =>
                  case line is
                     when "token literal names:" =>
                        part := .tokenLiteralNames
                     when "token symbolic names:" =>
                        part := .tokenSymbolicNames
                     when "rule names:" =>
                        part := .ruleNames
                     when "channel names:" =>
                        part := .channelNames
                     when "mode names:" =>
                        part := .modeNames
                     when "atn:" =>
                        part := .atn
                     when "" =>
                        null;
                     when others =>
                        fail := Error.dataError ("Unrecognized interpreter data part at " & line);
                  end case;
               when .tokenLiteralNames =>
                  literalNames.append ((line == "null") ? "" : line);
               when .tokenSymbolicNames =>
                  symbolicNames.append ((line == "null") ? "" : line);
               when .ruleNames =>
                  ruleNames.append (line);
               when .channelNames =>
                  channelNames.append (line);
               when .modeNames =>
                  modeNames.append (line);
               when .atn =>
                  if line.prefix (1) == "[" and then line.suffix (1) == "]" then
                     atnText := line.dropFirst.dropLast.split (separator:",");
                  else
                     fail := Error.dataError ("Missing bracket (s) at " & line);
                  end if;
                  part := .partName
            end case;
        end if;
        if Is_Valid (fail) then raise fail end if;
        vocabulary := Vocabulary (literalNames, symbolicNames);
        self.ruleNames := ruleNames
        self.channelNames := channelNames
        self.modeNames := modeNames
      atnSerialized : Integer_List;
        declare
            procedure Map (At_Cursor : atnText.Cursor) is
            begin
               atnSerialized.Append (Integer (Element (At_Cursor).trimmingCharacters (in => .whitespaces))!);
            end Map;
         begin
            atnText.Iterate (Map'Access);
         end;
        atn := This.ATNDeserializer.deserialize (atnSerialized);
    end if;

    -- public
    procedure createLexer (input: CharStream)throws->LexerInterpreter is
    begin
        return LexerInterpreter (filePath,;
                                    vocabulary,
                                    ruleNames,
                                    channelNames,
                                    modeNames,
                                    atn,
                                    input);
    end if;

    -- public
    procedure createParser (input: TokenStream)throws->ParserInterpreter is
    begin
        return ParserInterpreter (filePath,;
                                    vocabulary,
                                    ruleNames,
                                    atn,
                                    input);
    end if;

end if;
