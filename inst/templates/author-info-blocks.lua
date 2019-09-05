--[[
affiliation-blocks – generate title components

Copyright © 2017–2019 Albert Krewinkel

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
local utils = require 'pandoc.utils'
local stringify = utils.stringify

local default_marks
local default_marks = {
  corresponding_author = FORMAT == 'latex'
    and {pandoc.RawInline('latex', '*')}
    or {pandoc.Str '✉'},
  equal_contributor = FORMAT == 'latex'
    and {pandoc.RawInline('latex', '$\\dagger{}$')}
    or {pandoc.Str '*'},
}

local function intercalate(lists, elem)
  local result = List:new{}
  for i = 1, (#lists - 1) do
    result:extend(lists[i])
    result:extend(elem)
  end
  if #lists > 0 then
    result:extend(lists[#lists])
  end
  return result
end

--- Check whether the given author is a corresponding author
local function is_corresponding_author(author)
  return author.correspondence and author.email
end

--- Create inlines for a single author (includes all author notes)
local function author_inline_generator (get_mark)
  return function (author)
    local author_marks = List:new{}
    if author.equal_contributor then
      author_marks[#author_marks + 1] = get_mark 'equal_contributor'
    end
    local idx_str
    for _, idx in ipairs(author.institute) do
      if type(idx) ~= 'table' then
        idx_str = tostring(idx)
      else
        idx_str = stringify(idx)
      end
      author_marks[#author_marks + 1] = {pandoc.Str(idx_str)}
    end
    if is_corresponding_author(author) then
      author_marks[#author_marks + 1] = get_mark 'corresponding_author'
    end
    local res = List.clone(author.name)
    res[#res + 1] = pandoc.Superscript(intercalate(author_marks, {pandoc.Str ','}))
    return res
  end
end

local function is_equal_contributor (author)
  return author.equal_contributor
end

--- Create equal contributors note.
local function create_equal_contributors_block(authors, mark)
  local has_equal_contribs = List:new(authors):find_if(is_equal_contributor)
  if not has_equal_contribs then
    return nil
  end
  local contributors = {
    pandoc.Superscript(mark'equal_contributor'),
    pandoc.Space(),
    pandoc.Str 'These authors contributed equally to this work.'
  }
  return List:new{pandoc.Para(contributors)}
end

--- Generate a block list all affiliations, marked with arabic numbers.
local function create_affiliations_blocks(affiliations)
  local affil_lines = List:new(affiliations):map(
    function (affil, i)
      local num_inlines = List:new{
        pandoc.Superscript{pandoc.Str(tostring(i))},
        pandoc.Space()
      }
      return num_inlines .. affil.name
    end
                                                )
  return {pandoc.Para(intercalate(affil_lines, {pandoc.LineBreak()}))}
end

--- Generate a block element containing the correspondence information
local function create_correspondence_blocks(authors, mark)
  local corresponding_authors = List:new{}
  for _, author in ipairs(authors) do
    if is_corresponding_author(author) then
      local mailto = 'mailto:' .. pandoc.utils.stringify(author.email)
      local author_with_mail = List:new(
        author.name .. List:new{pandoc.Space(),  pandoc.Str '<'} ..
        author.email .. List:new{pandoc.Str '>'}
      )
      local link = pandoc.Link(author_with_mail, mailto)
      table.insert(corresponding_authors, {link})
    end
  end
  if #corresponding_authors == 0 then
    return nil
  end
  local correspondence = List:new{
    pandoc.Superscript(mark'corresponding_author'),
    pandoc.Space(),
    pandoc.Str'Correspondence:',
    pandoc.Space()
  }
  local sep = List:new{pandoc.Str',',  pandoc.Space()}
  return {
    pandoc.Para(correspondence .. intercalate(corresponding_authors, sep))
  }
end

--- Generate a list of inlines containing all authors.
local function create_authors_inlines(authors, mark)
  local inlines_generator = author_inline_generator(mark)
  local inlines = List:new(authors):map(inlines_generator)
  local and_str = List:new{pandoc.Space(), pandoc.Str'and', pandoc.Space()}

  local last_author = inlines[#inlines]
  inlines[#inlines] = nil
  local result = intercalate(inlines, {pandoc.Str ',', pandoc.Space()})
  if #authors > 1 then
    result:extend(List:new{pandoc.Str ","} .. and_str)
  end
  result:extend(last_author)
  return result
end

return {
  {
    Pandoc = function (doc)
      local meta = doc.meta
      local body = List:new{}

      local mark = function (mark_name) return default_marks[mark_name] end

      body:extend(create_equal_contributors_block(doc.meta.author, mark) or {})
      body:extend(create_affiliations_blocks(doc.meta.institute) or {})
      body:extend(create_correspondence_blocks(doc.meta.author, mark) or {})
      body:extend(doc.blocks)

      -- Overwrite authors with formatted values. We use a single, formatted
      -- string for most formats. LaTeX output, however, looks nicer if we
      -- provide a authors as a list.
      meta.author = FORMAT:match 'latex'
        and pandoc.MetaList(doc.meta.author):map(author_inline_generator(mark))
        or pandoc.MetaInlines(create_authors_inlines(doc.meta.author, mark))
      -- Institute info is now baked into the affiliations block.
      meta.institute = nil

      return pandoc.Pandoc(body, meta)
    end
  }
}
