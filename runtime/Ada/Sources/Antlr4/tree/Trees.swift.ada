-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
--


-- A set of utility routines useful for all kinds of ANTLR trees.

public class Trees {
    --
    public class procedure getPS (t: Tree, ruleNames : Array<String>,
    fontName : String; fontSize : Integer) return String is
begin
    let psgen: TreePostScriptGenerator =
    TreePostScriptGenerator(ruleNames, t, fontName, fontSize)
    return psgen.getPS()
    end ;

    public class function getPS (t: Tree, ruleNames : Array<String>) return String is
begin
    return getPS(t, ruleNames, "Helvetica", 11)
    end ;
    --TODO: write to file

    public class procedure writePS (t: Tree, ruleNames : Array<String>,
    fileName : String;
    fontName : String; fontSize : Integer)
    {
    var ps: String := getPS(t, ruleNames, fontName, fontSize)
    var f: FileWriter := FileWriter(fileName)
    var bw: BufferedWriter := BufferedWriter(f)
    try {
    bw.write(ps)
    end ;
    defer {
    bw.close()
    end ;
    end ;

    public class procedure writePS (t: Tree, ruleNames : Array<String>, fileName : String)
    {
    writePS(t, ruleNames, fileName, "Helvetica", 11)
    end ;
   --
    -- Print out a whole tree in LISP form. _#getNodeText_ is used on the
    -- node payloads to get the text for the nodes.  Detect
    -- parse trees and extract data appropriately.
    -- 
    public static function toStringTree (t : Tree) return String is
begin
        let rulsName: Array<String>? := null;
        return toStringTree(t, rulsName)
    end ;

    -- Print out a whole tree in LISP form. _#getNodeText_ is used on the
    -- node payloads to get the text for the nodes.  Detect
    -- parse trees and extract data appropriately.
    -- 
    public static function toStringTree (t : Tree; recog : Parser?) return String is
begin
        let ruleNamesList: [String]? := recog?.getRuleNames()
        return toStringTree(t, ruleNamesList)
    end ;

    -- Print out a whole tree in LISP form. _#getNodeText_ is used on the
    -- node payloads to get the text for the nodes.  Detect
    -- parse trees and extract data appropriately.
    -- 
    public static function toStringTree (t : Tree; ruleNames : Array<String>?) return String is
begin
        s : constant := Utils.escapeWhitespace(getNodeText(t, ruleNames), false)
        if t.getChildCount() == 0 then
            return s;
        end if;
        var buf := "(\(s) "
        length : constant := t.getChildCount()
        for i in 0..<length loop
            if i > 0 then
                buf := @ + " ";
            end if;
            buf := @ + toStringTree(t.getChild(i)!, ruleNames);
        end loop;
        buf := @ + ")";
        return buf
    end ;

    public static function getNodeText (t : Tree; recog : Parser?) return String is
begin
        return getNodeText(t, recog?.getRuleNames())
    end ;

    public static function getNodeText (t : Tree; ruleNames : Array<String>?) return String is
begin
        if ruleNames : constant := ruleNames then
            if ruleNode : constant := t as? RuleNode then
                let ruleIndex: Integer := ruleNode.getRuleContext().getRuleIndex()
                let ruleName: String := ruleNames[ruleIndex]
                altNumber : constant := (t as! RuleContext).getAltNumber()
                if altNumber /= ATN.INVALID_ALT_NUMBER  then
                    return "\(ruleName):\(altNumber)";
                end if;
                return ruleName
            else
                if errorNode : constant := t as? ErrorNode then
                    return errorNode.description;
                end if; elsif terminalNode : constant := t as? TerminalNode then
                    if symbol : constant := terminalNode.getSymbol() then
                        let s: String := symbol.getText()!
                        return s
                    end ;
                end ;
            end ;
        end ;
        -- no recog for rule names
        let payload: AnyObject := t.getPayload()
        if token : constant := payload as? Token then
            return token.getText()!;
        end if;
        return "\(t.getPayload())"

    end ;

    -- Return ordered list of all children of this node
    public static function getChildren (t : Tree) return Array<Tree> {
        var kids: Array<Tree> := Array<Tree> ()
        length : constant := t.getChildCount()
        for i in 0..<length loop
            kids.append(t.getChild(i)!)
        end loop;
        return kids
    end ;

    -- Return a list of all ancestors of this node.  The first node of
    -- list is the root and the last is the parent of this node.
    -- 

    public static function getAncestors (t : Tree) return Array<Tree> {
        var ancestors: Array<Tree> := Array<Tree> ()
        if t.getParent() == null then

            return ancestors
            --return Collections.emptyList();
        end ;

        var tp := t.getParent()
        while tpWrap : constant := tp loop
            ancestors.insert(t, at: 0)
            --ancestors.add(0, t); -- insert at start
            tp := tpWrap.getParent()
        end loop;
        return ancestors
    end ;

    public static function findAllTokenNodes (t : ParseTree; ttype : Integer) return Array<ParseTree> {
        return findAllNodes(t, ttype, true)
    end ;

    public static function findAllRuleNodes (t : ParseTree; ruleIndex : Integer) return Array<ParseTree> {
        return findAllNodes(t, ruleIndex, false)
    end ;

    public static function findAllNodes (t : ParseTree; index : Integer; findTokens  : Boolean) return Array<ParseTree> {
        var nodes: Array<ParseTree> := Array<ParseTree> ()
        _findAllNodes(t, index, findTokens, &nodes)
        return nodes
    end ;

    public static procedure _findAllNodes (t : ParseTree;
                                    index : Integer; findTokens : Boolean; nodes : inout Array<ParseTree>) {
        -- check this node (the root) first
        if tnode : constant := t as? TerminalNode , findTokens then
            if tnode.getSymbol()!.getType() == index then
                nodes.append(t);
            end if;
        else
            if ctx : constant := t as? ParserRuleContext , not findTokens then
                if ctx.getRuleIndex() == index then
                    nodes.append(t);
                end if;
            end ;
        end ;
        -- check children
        length : constant := t.getChildCount()
        for i in 0..<length loop
            _findAllNodes(t.getChild(i) as! ParseTree, index, findTokens, &nodes)
        end loop;
    end ;

    public static function descendants (t : ParseTree) return Array<ParseTree> {
        var nodes: Array<ParseTree> := [t]

        let n: Integer := t.getChildCount()
        for i in 0..<n loop

            --nodes.addAll(descendants(t.getChild(i)));
            if child : constant := t.getChild(i) then
                nodes.concat(descendants(child as! ParseTree));
            end if;

        end loop;
        return nodes
    end ;

    -- Find smallest subtree of t enclosing range startTokenIndex .. stopTokenIndex
    -- inclusively using postorder traversal.  Recursive depth-first-search.
    -- 
    -- - Since: 4.5.1
    -- 
    public static procedure getRootOfSubtreeEnclosingRegion (t : ParseTree;
                                                      startTokenIndex : Integer;
                                                      stopTokenIndex : Integer) -> ParserRuleContext? {
        let n: Integer := t.getChildCount()

        for i in 0..<n loop
            --TODO t.getChild(i) null;
            --Added by janyou
            guard child : constant := t.getChild(i) as? ParseTree else {
                return null;
            end ;
            if r : constant := getRootOfSubtreeEnclosingRegion(child, startTokenIndex, stopTokenIndex) then
                return r;
            end if;
        end loop;
        if r : constant := t as? ParserRuleContext then
            if startTokenIndex >= r.getStart()!.getTokenIndex() and then -- is range fully contained in t?
                    stopTokenIndex <= r.getStop()!.getTokenIndex() {
                return r
            end ;
        end ;
        return null;
    end ;

    private procedure Init (This : …) is
begin
    end ;
end ;
