-- €

package ANTLR.Runtime.Tree.ParseTreeListener_Protocol is


   -- public
   type ParseTreeProperty<V> is tagged with record
      annotations := Dictionary<ObjectIdentifier, V> ();
   end record;

   -- public
   overriding
   procedure Initialize (Self : in out ParseTreeProperty) is null;

  -- open
   function get (This : ParseTreeProperty; node : ParseTree) return Optional_V is
   begin
      return annotations.Element (ObjectIdentifier (node));
   end get;

   -- open
   procedure put (This : ParseTreeProperty; node : ParseTree; value : V) is
   begin
      annotations.Element (ObjectIdentifier (node)) := value;
   end put;

   -- open
   procedure removeFrom (This : ParseTreeProperty; node : ParseTree) is
   begin 
      annotations.removeValue (forKey => ObjectIdentifier (node));
   end removeFrom;
end ParseTreeListener_Protocol;
