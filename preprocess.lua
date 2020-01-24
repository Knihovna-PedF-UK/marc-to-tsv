for line in io.lines() do
  -- separate each field by blank line
  print(line)
  if line:match("%s*|") then print "" end
end
