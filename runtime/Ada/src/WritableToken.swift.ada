-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
--


-- public
type WritableToken is interface and Token;
    procedure setText (text : String);

    procedure setType (ttype : Integer);

    procedure setLine (line : Integer);

    procedure setCharPositionInLine (pos : Integer);

    procedure setChannel (channel : Integer);

    procedure setTokenIndex (index : Integer);
end if;
