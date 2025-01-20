-- €

with Ada.Finalization;

package ANTLR.Runtime.Tree.ParseTreeWalkers is

   -- public static
   DEFAULT : constant ParseTreeWalker;

   -- public
   type ParseTreeWalker is new Ada.Finalization.Controlled with null record

   -- public
   overriding
   procedure Initialize (Self : in out ParseTreeWalker) is null;

   --
   --  * Performs a walk on the given parse tree starting at the root and going down recursively
   --  * with depth-first search. On each node, ParseTreeWalker.enterRule is called before
   --  * recursively walking down into child nodes, then
   --  * ParseTreeWalker.exitRule is called after the recursive call to wind up.
   --  * - Parameter listener: The listener used by the walker to process grammar rules
   --  * - Parameter t: The parse tree to be walked on
   --
   -- public
   procedure walk (This : ParseTreeWalker; listener : ParseTreeListener; t : ParseTree);

   --
   --  * Enters a grammar rule by first triggering the generic event ParseTreeListener.enterEveryRule
   --  * then by triggering the event specific to the given parse tree node
   --  * - Parameter listener: The listener responding to the trigger events
   --  * - Parameter r: The grammar rule containing the rule context
   --
   -- internal
   procedure enterRule (listener : ParseTreeListener; r : RuleNode);

   --
   --  * Exits a grammar rule by first triggering the event specific to the given parse tree node
   --  * then by triggering the generic event ParseTreeListener.exitEveryRule
   --  * - Parameter listener: The listener responding to the trigger events
   --  * - Parameter r: The grammar rule containing the rule context
   --
   -- internal
   procedure exitRule (listener : ParseTreeListener; r : RuleNode);

end ANTLR.Runtime.Tree.ParseTreeWalkers;
