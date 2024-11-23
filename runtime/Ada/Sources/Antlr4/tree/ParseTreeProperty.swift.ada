-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
--
with Foundation;

public class ParseTreeProperty<V> {
  var annotations := Dictionary<ObjectIdentifier, V> ()
  
  public procedure Init (This : …) is
beginend ;
  
  open function get (node : ParseTree) return V? { return annotations[ObjectIdentifier(node)] end ;
  open procedure put (node : ParseTree; value : V) { annotations[ObjectIdentifier(node)] := value end ;
  open procedure removeFrom (node : ParseTree) { annotations.removeValue(forKey: ObjectIdentifier(node)) end ;
end ;
