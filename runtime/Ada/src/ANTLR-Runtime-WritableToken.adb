-- €

-- public
type WritableToken is interface and Token;
    procedure setText (text : String);

    procedure setType (ttype : Integer);

    procedure setLine (line : Integer);

    procedure setCharPositionInLine (pos : Integer);

    procedure setChannel (channel : Integer);

    procedure setTokenIndex (index : Integer);
end if;
