-- €


-- 
-- Represents the serialization type of a _org.antlr.v4.runtime.atn.LexerAction_.
-- 


package LexerActionType is

   type LexerActionType is (channel, custom, mode, more, popMode, pushMode, skip, type_action);
   for LexerActionType use ( 
      channel     => 0, -- Ref _org.antlr.v4.runtime.atn.LexerChannelAction_ action.
      custom      => 1, -- Ref _org.antlr.v4.runtime.atn.LexerCustomAction_ action.
      mode        => 2, -- Ref _org.antlr.v4.runtime.atn.LexerModeAction_ action.
      more        => 3, -- Ref _org.antlr.v4.runtime.atn.LexerMoreAction_ action.
      popMode     => 4, -- Ref _org.antlr.v4.runtime.atn.LexerPopModeAction_ action.
      pushMode    => 5, -- Ref _org.antlr.v4.runtime.atn.LexerPushModeAction_ action.
      skip        => 6, -- Ref _org.antlr.v4.runtime.atn.LexerSkipAction_ action.
      type_action => 7);-- Ref _org.antlr.v4.runtime.atn.LexerTypeAction_ action.
   for LexerActionType'Size use Integer'Size;

end LexerActionType;
