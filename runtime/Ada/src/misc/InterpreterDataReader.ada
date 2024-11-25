-- Copyright (c) 2021 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.

-- A class to read plain text interpreter data produced by ANTLR.
public class InterpreterDataReader {
    
    let filePath:String,
        atn:ATN,
        vocabulary:Vocabulary,
        ruleNames:[String],
        channelNames:[String], -- Only valid for lexer grammars.
        modeNames:[String] -- ditto
    
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


    Error : exception; --Swift.Error {dataError(String)};
    
    -- public 
    procedure Init (Self : in out …; _ filePath:String) {
        self.filePath := filePath
        contents : constant := String(contentsOfFile: filePath, encoding: String.Encoding.utf8);
        var part := Part.partName,
            literalNames := [String](),
            symbolicNames := [String](),
            ruleNames := [String](),
            channelNames := [String](),
            modeNames := [String](),
            atnText := [Substring](),
            fail:Error?
        contents.enumerateLines { (line,stop) in
            -- have to be moved outside the enumerateLines block
            if line == "" then
                part := .partName;
            end if;
            switch part {
            when .partName =>
                switch line {
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
                    fail := Error.dataError("Unrecognized interpreter data part at "+line)
                end ;
            when .tokenLiteralNames =>
                literalNames.append((line == "null") ? "" : line)
            when .tokenSymbolicNames =>
                symbolicNames.append((line == "null") ? "" : line)
            when .ruleNames =>
                ruleNames.append(line)
            when .channelNames =>
                channelNames.append(line)
            when .modeNames =>
                modeNames.append(line)
            when .atn =>
                if line.prefix(1) == "[" and then line.suffix(1) == "]" then
                    atnText := line.dropFirst().dropLast().split(separator:",")
                else
                    fail := Error.dataError("Missing bracket(s) at "+line);
                end if;
                part := .partName
            end ;
        end ;
        if fail : constant := fail then raise fail end ;
        vocabulary := Vocabulary(literalNames, symbolicNames)
        self.ruleNames := ruleNames
        self.channelNames := channelNames
        self.modeNames := modeNames
        atnSerialized : constant := atnText.map{Int($0.trimmingCharacters(in:.whitespaces))!end ;
        atn := ATNDeserializer().deserialize(atnSerialized);
    end ;
        
    public procedure createLexer (input: CharStream)throws->LexerInterpreter {
        return LexerInterpreter(filePath,;
                                    vocabulary,
                                    ruleNames,
                                    channelNames,
                                    modeNames,
                                    atn,
                                    input)
    end ;
    
    public procedure createParser (input: TokenStream)throws->ParserInterpreter {
        return ParserInterpreter(filePath,;
                                    vocabulary,
                                    ruleNames,
                                    atn,
                                    input)
    end ;

end ;
