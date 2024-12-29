-- €

with Ada.Containers.Vectors;

package ANTLR.Runtime.ATN.LexerAction is

   --
   -- Represents a single action which can be executed following the successful
   -- match of a lexer rule. Lexer actions are used for both embedded action syntax
   -- and ANTLR 4's new lexer command syntax.
   --

   -- public
   type LexerAction is new Hashable with null record;

   package Container is new Ada.Cantainers.Vector (
      Index_Type : Natural;
      Element_Type : LexerAction;
      "=" : "=");

   --
   -- Gets the serialization type of the lexer action.
   --
   -- * returns: The serialization type of the lexer action.
   --
   -- public
   function getActionType (This : LexerAction) return LexerActionType with No_Return;

   --
   -- Gets whether the lexer action is position-dependent. Position-dependent
   -- actions may have different semantics depending on the _org.antlr.v4.runtime.CharStream_
   -- index at the time the action is executed.
   --
   -- Many lexer commands, including `type`, `skip`, and
   -- `more`, do not check the input index during their execution.
   -- Actions like this are position-independent, and may be stored more
   -- efficiently as part of the _org.antlr.v4.runtime.atn.LexerATNConfig#lexerActionExecutor_.
   --
   -- * returns: `True` if the lexer action semantics can be affected by the
   -- position of the input _org.antlr.v4.runtime.CharStream_ at the time it is executed;
   -- otherwise, `False`.
   --
   -- public
   function isPositionDependent (This : LexerAction) return Boolean with No_Return;

   --
   -- Execute the lexer action in the context of the specified _org.antlr.v4.runtime.Lexer_.
   --
   -- For position-dependent actions, the input stream must already be
   -- positioned correctly prior to calling this method.
   --
   -- * parameter lexer: The lexer instance.
   --
   -- public
   procedure execute (This : LexerAction; lexer : Lexer) with No_Return;

   -- public
   procedure hash (This : LexerAction; hasher : in out Hasher) with No_Return;

   -- public
   function "=" (Lhs, Rhs : LexerAction) return Boolean with No_Return;

end ANTLR.Runtime.ATN.LexerAction;
