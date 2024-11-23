-- 
-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
-- 

--
--  LookupATNConfig.swift
--  objc2swiftwithswith
--
--  Created by janyou on 15/9/22.
--

with Foundation;

public type LookupATNConfig is new Hashable with null record;
{

    public let config: ATNConfig
    public init(old : ATNConfig) {
        -- dup
        config := old
    end ;

    public procedure hash (into hasher: inout Hasher) {
        hasher.combine(config.state.stateNumber)
        hasher.combine(config.alt)
        hasher.combine(config.semanticContext)
    end ;
end ;

public function ==(lhs: LookupATNConfig, rhs: LookupATNConfig) return Boolean is
begin
    if lhs.config === rhs.config then
        return true
    end ;

    return lhs.config.state.stateNumber == rhs.config.state.stateNumber and
            lhs.config.alt == rhs.config.alt and
            lhs.config.semanticContext == rhs.config.semanticContext
end ;
