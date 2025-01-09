-- €

with Ada.Finalization;
with Ada.Strings;

package ANTLR.Runtime.DFA.Serializers is

   --
   -- A DFA walker that knows how to dump them to serialized strings.
   --

   -- public
   type DFASerializer is new Ada.Finalization.Controlled with
   record
      -- private
      dfa : DFA; -- constant
      -- private
      vocabulary : Vocabulary; -- constant
   end record;

   subtype Object is DFASerializer;
   type Class is access all Object;
   type Class_Wide is access all Object'Class;

   -- public
   procedure Initialize (Self : in out DFASerializer; dfa : DFA; vocabulary : Vocabulary);

   subtype Sink is Ada.Strings.Text_Buffers.Root_Buffer_Type;
   procedure Put_Image_DFASerializer (S : in out Sink'Class; X : DFASerializer);
   for DFASerializer'Put_Image use Put_Image_DFASerializer;
   -- public
   function Description (This : DFASerializer) return UString;

   -- internal
   function getEdgeLabel (This : DFASerializer; i : Integer) return UString;

   -- internal
   function getStateString (This : DFASerializer; s : DFAState) return UString;

end ANTLR.Runtime.DFA.Serializers;
