
local trim = function(s)
  return s:gsub("^%s*", ""):gsub("%s*","")
end

local records = {}
local current_record
local read_field = false

local function start_record(current)
  records[#records+1] = current
  return {}
end




for line in io.lines() do

  if line=="*****" then
    current_record = start_record(current_record)
  end

end

-- insert the last record
start_record(current_record)

print(#records)
