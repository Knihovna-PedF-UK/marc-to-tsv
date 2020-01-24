
local trim = function(s)
  return s:gsub("^%s*", ""):gsub("%s*$","")
end

local records = {}
local current_record, current_field

local fields = {
  ["245"] = true,
  ["Z30"] = true,
  ["264"] = true,
  ["260"] = true
}

local function start_record(current)
  records[#records+1] = current
  return {}
end

local function test_header(line)
  -- read first three chars
  local number = line:sub(1,3)
  return fields[number]
end

local function parse_header(line)
  local number = line:sub(1,3)
  local first = line:sub(4,4)
  local second = line:sub(5,5)
  return {number  = number, first = first, second = second, subfields = {}, field_string = ""}

end

local function parse_subfields(str)
  local subfields = {}
  for label, subfield in str:gmatch("|(.)%s*([^|]+)") do
    subfields[label] = trim(subfield)
  end
  return subfields
end

local function read_field(line, current_field, current_record)
  if line == "" then
    current_field.subfields = parse_subfields(current_field.field_string)
    current_record[#current_record+1] = current_field
    return nil
  else
    current_field.field_string = current_field.field_string .. line
  end
  return current_field
end



for line in io.lines() do
  -- remove white space on the line
  local line = trim(line)

  -- field delimiter
  if line=="*****" then
    current_record = start_record(current_record)
  elseif not current_field and test_header(line) then
    current_field  = parse_header(line)
  elseif current_field then
    current_field = read_field(line, current_field, current_record)
  end

end

-- insert the last record
start_record(current_record)

for r,record in ipairs(records) do
  local authors, title, place, year, publisher
  for _,field in ipairs(record) do
    local subfields = field.subfields
    if field.number == "245" then
      -- concat title and subtitle 
      title = table.concat({subfields.a or "", subfields.b or ""},"")
      -- remove the trailing slash from MARC
      title = title:gsub("%s*/%s*$", "")
      authors = subfields.c
    elseif (field.number == "264" and field.second == "1") or field.number == "260" then
      publisher = subfields.b 
      year = subfields.c
    elseif field.number == "Z30" then
      -- print only our books
      if subfields["1"] == "PEDFR" then
        print(r, authors, title, publisher, year, subfields["3"], subfields["6"])
      end

    end
  end
  -- print(author or "", title)
    
end
