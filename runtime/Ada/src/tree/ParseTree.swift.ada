-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
--


-- An interface to access the tree of _org.antlr.v4.runtime.RuleContext_ objects created
-- during a parse that makes the data structure look like a simple parse tree.
-- This node represents both internal nodes, rule invocations,
-- and leaf nodes, token matches.
-- 
-- The payload is either a _org.antlr.v4.runtime.Token_ or a _org.antlr.v4.runtime.RuleContext_ object.
--
-- public
type ParseTree is interface and SyntaxTree and CustomStringConvertible and CustomDebugStringConvertible;
    -- Set the parent for this leaf node.
    procedure setParent (parent : RuleContext)

    -- The _org.antlr.v4.runtime.tree.ParseTreeVisitor_ needs a double dispatch method.
    function accept<T> (visitor : ParseTreeVisitor<T>) return T?

    -- Return the combined text of all leaf nodes. Does not get any
    -- off-channel tokens (if any) so won't return whitespace and
    -- comments if they are sent to parser on hidden channel.
    function getText () return String

    -- Specialize toStringTree so that it can print out more information
    -- based upon the parser.
    function toStringTree (parser : Parser) return String

    -- Equivalent to `getChild(index)! as! ParseTree`
    subscript(index : Integer) return ParseTree is
begin get end if;
end if;
