-- €

with Ada.Wide_Wide_Text_IO;
with Aspect;

use Ada;
use Aspect;

with ANTLR.Runtime.Token_Protocol;

package body ANTLR.Runtime.Recognizers is

   function getRuleNames (This : Recognizer) return UString_List is
      raise PROGRAM_ERROR with "ANTLR.Runtime.Recognizer.getRuleNames() must be overridden";
   end getRuleNames;

   function getVocabulary (This : Recognizer) return Vocabulary is
   begin
      raise PROGRAM_ERROR with "ANTLR.Runtime.Recognizer.getVocabulary() must be overridden";
   end getVocabulary;

   function getTokenTypeMap (This : Recognizer) return TokenID_Map is
   begin
      return TokenTypeMap (This);
   end getTokenTypeMap;

   function TokenTypeMap (This : Recognizer) return TokenID_Map --TOFIX
      vocabulary : constant Vocabulary := getVocabulary (This);
      result : TokenID_Map;
      length : constant := This.getATN.maxTokenType;
   begin
      for i in 0 .. length loop

         literalName : constant := vocabulary.getLiteralName (i);
         if Is_Valid (literalName) then
               result.insert (Key => literalName, New_Item => i);
         end if;

         symbolicName : constant := vocabulary.getSymbolicName (i)
         if Is_Valid (symbolicName) then
               result.insert (Key => symbolicName, New_Item => i);
         end if;
      end loop;

      result.Insert (Key => "EOF", New_Item => CommonToken.EOF);

      return result;
   end TokenTypeMap;

   function ruleIndexMap (This : Recognizer) return Rules_Map is --TOFIX
      ruleNames : constant UString_List := getRuleNames (This);
   begin
      return Utils.toMap (ruleNames);
   end ruleIndexMap;

   function getSerializedATN (This : Recognizer) return Integer_List is
      raise PROGRAM_ERROR with "there is no serialized ATN";
   end getSerializedATN;

   function getGrammarFileName (This : Recognizer) return UString is
   begin
      raise PROGRAM_ERROR with "ANTLR.Runtime.Recognizer.getGrammarFileName() must be overridden";
   end getGrammarFileName;

   function getATN (This : Recognizer) return ATN is
   begin
      raise PROGRAM_ERROR with "ANTLR.Runtime.Recognizer.getATN() must be overridden";
   end getATN;

   procedure setInterpreter (This : Recognizer; interpreter : ATNInterpreter) is
   begin
      This._interp := interpreter;
   end setInterpreter;

   function getErrorHeader (This : Recognizer; e : RecognitionException) return UString is
      offending : constant := e.getOffendingToken ();
      line : constant := offending.getLine ();
      charPositionInLine : constant := offending.getCharPositionInLine ();
   begin
      return "line " & line'Image & ':' & charPositionInLine'Image & ""
   end getErrorHeader;

   procedure addErrorListener (This : Recognizer; listener : ANTLRErrorListener) is
   begin
      This._listeners.append (listener);
   end addErrorListener;

   procedure removeErrorListener (This : Recognizer; listener : ANTLRErrorListener) is
      procedure Closure (Param_0 : <>) is
      begin
         Param_0 !== listener;
      end Closure;
   begin
      This._listeners := This._listeners.filter ()) {Closure'Access};
   end removeErrorListener;

   procedure removeErrorListeners (This : Recognizer) is
   begin
      This._listeners.removeAll ();
   end removeErrorListeners;

   procedure action (This : Recognizer;
                     localctx : Optional_RuleContext;
                     ruleIndex : Integer;
                     actionIndex : Integer) is
   begin
      null;
   end action;

   procedure setState (This : Recognizer; atnState : ATStates.State) is
   begin
      if Is_Active (Aspect.DEBUG) then
         Wide_Wide_Text_IO.Put_Line (Standard_Error, "setState " & atnState'Image);
      end if;
      This._stateNumber := atnState;
      if Is_Active (TRACE) and then traceATNStates then
         This.ctx.trace (atnState);
      end if;

   end setState;

   function getInputStream (This : Recognizer) return Optional_IntStream is
   begin
      raise PROGRAM_ERROR with "ANTLR.Runtime.Recognizer.getInputStream() must be overridden";
   end getInputStream;

   procedure setInputStream (This : Recognizer; input : IntStream) is
   begin
      raise PROGRAM_ERROR with "ANTLR.Runtime.Recognizer.setInputStream() must be overridden";
   end setInputStream;

   function getTokenFactory (This : Recognizer; This : Recognizer) return TokenFactory is
   begin
      raise PROGRAM_ERROR with "ANTLR.Runtime.Recognizer.getTokenFactory() must be overridden";
   end getTokenFactory;

   procedure setTokenFactory (This : Recognizer; input : TokenFactory) is
   begin
      raise PROGRAM_ERROR with "ANTLR.Runtime.Recognizer.setTokenFactory() must be overridden";
   end setTokenFactory;

end ANTLR.Runtime.Recognizers;
