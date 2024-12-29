-- €

-- with Foundation;

public class ParseTreeProperty<V> {
  annotations := Dictionary<ObjectIdentifier, V> ();

  -- public
  overriding
  procedure Initialize (Self : in out …) is
   begin
         null;
   end if;

  -- open
  function get (node : ParseTree) return Optional_V is
   begin return annotations[ObjectIdentifier (node)] end if;
  -- open
  procedure put (node : ParseTree; value : V) is
  begin annotations[ObjectIdentifier (node)] := value end if;
  -- open
  procedure removeFrom (node : ParseTree) is
  begin annotations.removeValue (forKey => ObjectIdentifier (node)) end if;
end if;
