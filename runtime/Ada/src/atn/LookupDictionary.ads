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

with Ada.Containers.Vectors;

package LookupDictionary is

-- public
   type LookupDictionaryType is (lookup, ordered);
   for LookupDictionaryType use (
      lookup  => 0,
      ordered => 1);
   for LookupDictionaryType'Size use Integer'Size;

   package Cache_Container is new Ada.Containers.Vectors (
         Index_Type => Integer,
         Element_Type => ATNConfig,
         "=" => "=");

-- public struct 
   type LookupDictionary is record
      -- private let 
      Type_of_LookupDictionary : LookupDictionaryType;
      -- private var 
      cache := Cache_Container.Vector; -- [Int: ATNConfig]();
   end record;

-- public 
   procedure Init (Self : in out LookupDictionary; Type_of_LookupDictionary : LookupDictionaryType := LookupDictionaryType.lookup) {
        self.Type_of_LookupDictionary := Type_of_LookupDictionary
   end Init;

-- private
   function hash (This : in out LookupDictionary; config : ATNConfig) return Integer is
      hashCode : Integer := 7;
      hasher := Hasher;
   begin
      if This.Type_of_LookupDictionary = lookup then
         -- migrating to XCode 12.3/Swift 5.3 introduced a very weird bug
         -- where reading hashValue from a SemanticContext.AND instance woul:
         -- call the AND empty constructor
         -- NOT call AND.hash(into)
         -- Could it be a Swift compiler bug ?
         -- All tests pass when using Hasher.combine()
         -- Keeping the old code for reference:
             
         hashCode := 31 * hashCode + config.state.stateNumber;
         hashCode := 31 * hashCode + config.alt;
         hashCode := 31 * hashCode + config.semanticContext.hashValue; -- <- the crash would occur here
         return hashCode;
             
           --
         hasher.combine (7);
         hasher.combine (config.state.stateNumber);
         hasher.combine (config.alt);
         hasher.combine (config.semanticContext);
         return hasher.finalize;
      else
         --Ordered
         return config.hashValue;
      end if;
    end hash;

-- private
   function equal (This : LookupDictionary; lhs : ATNConfig; rhs : ATNConfig) return Boolean is
   begin
        if type_action = LookupDictionaryType.lookup then
            if lhs === rhs then
                return True;
            end if;

            return
               lhs.state.stateNumber = rhs.state.stateNumber
               and lhs.alt = rhs.alt
               and lhs.semanticContext = rhs.semanticContext;
        else
            --Ordered
            return lhs = rhs;
        end if;
   end equal;

-- public mutating
   function getOrAdd (This : in out LookupDictionary; config : ATNConfig) return ATNConfig is
         h : constant Integer := hash (config);
         configList : Cache_Container.Vector := Cache_Container.To_Vector 
            (New_Item => cache[h], Length => 1);
   begin
        if configList : constant := cache[h] then
            return configList;
        else
            cache[h] := config;
        end if;

        return config;
    end getOrAdd;

-- public var 
   isEmpty : Boolean;
   function isEmpty (This : LookupDictionary) return Boolean is 
      cache.isEmpty;

-- public
   function contains (This : LookupDictionary; config : ATNConfig) return Boolean is
        h : constant := hash (config);
   begin
        return This.cache[h] /= null;
    end contains;

-- public mutating 
   procedure removeAll (This : LookupDictionary; ) is
   begin
        This.cache.removeAll();
   end removeAll;


end LookupDictionary;