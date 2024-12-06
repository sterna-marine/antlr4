-- €

-- public
type WritableToken is interface and Token;
    procedure setText (text : String);

    procedure setType (tType : Token_Kind);

    procedure setLine (line : Integer);

    procedure setCharPositionInLine (pos : Integer);

    procedure setChannel (Channel : Channel_Number);

    procedure setTokenIndex (index : Integer);
end if;
