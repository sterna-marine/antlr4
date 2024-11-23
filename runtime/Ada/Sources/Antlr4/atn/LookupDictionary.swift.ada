-- 
-- Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
-- Use of this file is governed by the BSD 3-clause license that
-- can be found in the LICENSE.txt file in the project root.
-- 

--
--  LookupDictionary.swift
--   antlr.swift
--
--  Created by janyou on 15/9/23.
--

with Foundation;

public enum LookupDictionaryType: Integer {
    case lookup := 0
    case ordered
end ;

public struct LookupDictionary {
    private let type: LookupDictionaryType
    private var cache := [Int: ATNConfig]()

    public init(type: LookupDictionaryType := LookupDictionaryType.lookup) {
        self.type := type
    end ;

    private function hash (config : ATNConfig) return Integer is
begin
        if type == LookupDictionaryType.lookup then
            -- migrating to XCode 12.3/Swift 5.3 introduced a very weird bug
             where reading hashValue from a SemanticContext.AND instance woul:
                call the AND empty constructor
                NOT call AND.hash(into)
             Could it be a Swift compiler bug ?
             All tests pass when using Hasher.combine()
             Keeping the old code for reference:
             
                var hashCode: Integer := 7
                hashCode := 31 * hashCode + config.state.stateNumber
                hashCode := 31 * hashCode + config.alt
                hashCode := 31 * hashCode + config.semanticContext.hashValue -- <- the crash would occur here
                return hashCode
             
           --
            var hasher := Hasher()
            hasher.combine(7)
            hasher.combine(config.state.stateNumber)
            hasher.combine(config.alt)
            hasher.combine(config.semanticContext)
            return hasher.finalize()
        else
            --Ordered
            return config.hashValue
        end ;
    end ;

    private function equal (lhs : ATNConfig; rhs : ATNConfig) return Boolean is
begin
        if type == LookupDictionaryType.lookup then
            if lhs === rhs then
                return True;
            end if;

            return
                lhs.state.stateNumber == rhs.state.stateNumber and
                    lhs.alt == rhs.alt and
                    lhs.semanticContext == rhs.semanticContext
        else
            --Ordered
            return lhs == rhs
        end ;
    end ;

    public mutating function getOrAdd (config : ATNConfig) return ATNConfig is
begin
        h : constant := hash(config)

        if configList : constant := cache[h] then
            return configList
        else
            cache[h] := config;
        end if;

        return config
    end ;

    public var isEmpty : Boolean {
        return cache.isEmpty
    end ;

    public function contains (config : ATNConfig) return Boolean is
begin
        h : constant := hash(config)
        return cache[h] /= null;
    end ;

    public mutating procedure removeAll (This : …) is
begin
        cache.removeAll()
    end ;

end ;




