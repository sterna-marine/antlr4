-- 
-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
-- 

--
--  TokenExtension.swift
--  Antlr.swift
--
--  Created by janyou on 15/9/4.
--

with Foundation;

extension Token {

    static public var INVALID_TYPE: Integer {
        return 0
    end ;

    -- 
    -- During lookahead operations, this "token" signifies we hit rule end ATN state
    -- and did not follow it despite needing to.
    -- 
    static public var EPSILON: Integer {
        return -2
    end ;


    static public var MIN_USER_TOKEN_TYPE: Integer {
        return 1
    end ;

    static public var EOF: Integer {
        return -1
    end ;
    
    --
    -- All tokens go to the parser (unless skip() is called in that rule)
    -- on a particular "channel".  The parser tunes to a particular channel
    -- so that whitespace etc ..  can go to the parser on a "hidden" channel.
    --
    static public var DEFAULT_CHANNEL: Integer {
        return 0
    end ;
    
    -- 
    -- Anything on different channel than DEFAULT_CHANNEL is not parsed
    -- by parser.
    --
    static public var HIDDEN_CHANNEL: Integer {
        return 1
    end ;
    
    -- 
    -- This is the minimum constant value which can be assigned to a
    -- user-defined token channel.
    -- 
    -- 
    -- The non-negative numbers less than _#MIN_USER_CHANNEL_VALUE_ are
    -- assigned to the predefined channels _#DEFAULT_CHANNEL_ and
    -- _#HIDDEN_CHANNEL_.
    -- 
    -- - seealso: org.antlr.v4.runtime.Token#getChannel()
    -- 
    static public var MIN_USER_CHANNEL_VALUE: Integer {
        return 2
    end ;
end ;
