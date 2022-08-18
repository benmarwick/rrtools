--[[
ScholarlyMeta – normalize author/affiliation meta variables

Copyright (c) 2017-2021 Albert Krewinkel, Robert Winkler

Permission to use, copy, modify, and/or distribute this software for any purpose
with or without fee is hereby granted, provided that the above copyright notice
and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND
FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS
OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER
TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF
THIS SOFTWARE.
]]
local List = require 'pandoc.List'

--- Returns the type of a metadata value.
--
-- @param v a metadata value
-- @treturn string one of `Blocks`, `Inlines`, `List`, `Map`, `string`, `boolean`
local function metatype (v)
  if PANDOC_VERSION <= '2.16.2' then
    local metatag = type(v) == 'table' and v.t and v.t:gsub('^Meta', '')
    return metatag and metatag ~= 'Map' and metatag or type(v)
  end
  return pandoc.utils.type(v)
end

local type = pandoc.utils.type or metatype


-- Split a string at commas.
local function comma_separated_values(str)
  local acc = List:new{}
  for substr in str:gmatch('([^,]*)') do
    acc[#acc + 1] = substr:gsub('^%s*', ''):gsub('%s*$', '') -- trim
  end
  return acc
end

--- Ensure the return value is a list.
local function ensure_list (val)
  if type(val) == 'List' then
    return val
  elseif type(val) == 'Inlines' then
    -- check if this is really a comma-separated list
    local csv = comma_separated_values(pandoc.utils.stringify(val))
    if #csv >= 2 then
      return csv
    end
    return List:new{val}
  elseif type(val) == 'table' and #val > 0 then
    return List:new(val)
  else
    -- Anything else, use as a singleton (or empty list if val == nil).
    return List:new{val}
  end
end

--- Returns a function which checks whether an object has the given ID.
local function has_id (id)
  return function(x) return x.id == id end
end

--- Copy all key-value pairs of the first table into the second iff there is no
-- such key yet in the second table.
-- @returns the second argument
function add_missing_entries(a, b)
  for k, v in pairs(a) do
    b[k] = b[k] or v
  end
  return b
end

--- Create an object with a name. The name is either taken directly from the
-- `name` field, or from the *only* field name (i.e., key) if the object is a
-- dictionary with just one entry. If neither exists, the name is left unset
-- (`nil`).
function to_named_object (obj)
  local named = {}
  if type(obj) == 'Inlines' then
    -- Treat inlines as the name
    named.name = obj
    named.id = pandoc.utils.stringify(obj)
  elseif type(obj) ~= 'table' then
    -- if the object isn't a table, just use its value as a name.
    named.name = pandoc.MetaInlines{pandoc.Str(tostring(obj))}
    named.id = tostring(obj)
  elseif obj.name ~= nil then
    -- object has name attribute → just create a copy of the object
    add_missing_entries(obj, named)
    named.id = pandoc.utils.stringify(named.id or named.name)
  elseif next(obj) and next(obj, next(obj)) == nil then
    -- Single-entry table. The entry's key is taken as the name, the value
    -- contains the attributes.
    key, attribs = next(obj)
    if type(attribs) == 'string' or type(attribs) == 'Inlines' then
      named.name = attribs
    else
      add_missing_entries(attribs, named)
      named.name = named.name or pandoc.MetaInlines{pandoc.Str(tostring(key))}
    end
    named.id = named.id and pandoc.utils.stringify(named.id) or key
  else
    -- this is not a named object adhering to the usual conventions.
    error('not a named object: ' .. tostring(obj))
  end
  return named
end

--- Resolve institute placeholders to full named objects
local function resolve_institutes (institute, known_institutes)
  local unresolved_institutes
  if institute == nil then
    unresolved_institutes = {}
  elseif type(institute) == "string" or type(institute) == "number" then
    unresolved_institutes = {institute}
  else
    unresolved_institutes = institute
  end

  local result = List:new{}
  for i, inst in ipairs(unresolved_institutes) do
    result[i] =
      known_institutes[tonumber(inst)] or
      known_institutes:find_if(has_id(pandoc.utils.stringify(inst))) or
      to_named_object(inst)
  end
  return result
end

--- Insert a named object into a list; if an object of the same name exists
-- already, add all properties only present in the new object to the existing
-- item.
function merge_on_id (list, namedObj)
  local elem, idx = list:find_if(has_id(namedObj.id))
  local res = elem and add_missing_entries(namedObj, elem) or namedObj
  local obj_idx = idx or (#list + 1)
  -- return res, obj_idx
  list[obj_idx] = res
  return res, #list
end

--- Flatten a list of lists.
local function flatten (lists)
  local result = List:new{}
  for _, lst in ipairs(lists) do
    result:extend(lst)
  end
  return result
end

--- Canonicalize authors and institutes
local function canonicalize(raw_author, raw_institute)
  local institutes = ensure_list(raw_institute):map(to_named_object)
  local authors = ensure_list(raw_author):map(to_named_object)

  for _, author in ipairs(authors) do
    author.institute = resolve_institutes(
      ensure_list(author.institute),
      institutes
    )
  end

  -- Merge institutes defined in author objects with those defined in the
  -- top-level list.
  local author_insts = flatten(authors:map(function(x) return x.institute end))
  for _, inst in ipairs(author_insts) do
    merge_on_id(institutes, inst)
  end

  -- Add list indices to institutes for numbering and reference purposes
  for idx, inst in ipairs(institutes) do
    inst.index = pandoc.MetaInlines{pandoc.Str(tostring(idx))}
  end

  -- replace institutes with their indices
  local to_index = function (inst)
    return tostring(select(2, institutes:find_if(has_id(inst.id))))
  end
  for _, author in ipairs(authors) do
    author.institute = pandoc.MetaList(author.institute:map(to_index))
  end

  return authors, institutes
end


return {
  {
    Meta = function(meta)
      meta.author, meta.institute = canonicalize(meta.author, meta.institute)
      return meta
    end
  }
}
