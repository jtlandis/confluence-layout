
-- Reformat all heading text 

local ColCount = 0

local GridCols = {}
local ColumnCols = {}
local ColType = {columns = ColumnCols, grid = GridCols} --, "g-col-4" = true, "g-col-8" = true}

GridCols["g-col-6"] = true
GridCols["g-col-4"] = true
GridCols["g-col-8"] = true
GridCols["g-col-2"] = true
ColumnCols["column"] = true

function ParentCol(element)
  if (element and element.classes and #element.classes >0) then
    for _, class in pairs(element.classes) do
      if ColType[class] ~= nil then
        return class
      end
    end
  end
  return nil
end

function isParentCol(element)
  return ParentCol(element) ~= nil
end

function ColClass(element) 
  if (element and element.classes and #element.classes >0) then
    for _, class in pairs(element.classes) do
      if GridCols[class] ~= nil or ColumnCols[class] ~= nil then
        return class
      end
    end
  end
  return nil
end

local ConflLayoutPre = '<ac:layout-section ac:type="x">'
local ConflLayoutPost = "</ac:layout-section>"

function collectColClass(element)
  local l = {}
  local class = nil
  for _, e in pairs(element.content) do
    class = ColClass(e)
    if class ~= nil then
      table.insert(l, class)
    end
  end
  return l
end

function conflrPreSubType(replace)
  return pandoc.RawBlock('confluence', string.gsub(ConflLayoutPre, "x", {x = replace}))
end
  
function handelParent(element)
  local classes = collectColClass(element)
  local thisClass = ParentCol(element)
  local inlines = element.content
  local pre = nil
  if ColCount == 1 then
    pre = conflrPreSubType("single")
  elseif ColCount == 2 then
    if thisClass=="grid" then
      if classes[1] == "g-col-4" then
        -- assume left margin
        pre = conflrPreSubType("two_left_sidebar")
      elseif classes[1] == "g-col-6" then
        -- assume even
        pre = conflrPreSubType("two_equal")
      elseif classes[1] == "g-col-8" then
        pre = conflrPreSubType("two_right_sidebar")
      else
        -- when the first column collected doesnt have these classes, 
        -- default to even
        pre = conflrPreSubType("two_equal")
      end
    else 
      -- in Columns parent, we would need to inspect class attrib for width
      -- it is easier to assume even for now
      pre = conflrPreSubType("two_equal")
    end
  elseif ColCount == 3 then
    if thisClass=="grid" then
      if classes[2]=="g-col-8" then
        pre = conflrPreSubType("three_with_sidebars")
      else
        pre = conflrPreSubType("three_equal")
      end
    else
      pre = conflrPreSubType("three_equal")
    end
  else
    -- we have counted more than 3 internal divs with 
    -- the correct class. default to single layout
    pre = conflrPreSubType("single")
  end
  table.insert(inlines, 1, pre)
  table.insert(inlines, pandoc.RawBlock('confluence', ConflLayoutPost))
  ColCount = 0
  return element
end
    

function Div(element)
  local inlines = element.content
  local class = ColClass(element)
  
  if class ~= nil then
    local pre = pandoc.RawBlock('confluence', "<ac:layout-cell>")
    table.insert(inlines, 1, pre)
    table.insert(inlines, pandoc.RawBlock('confluence', "</ac:layout-cell>"))
    ColCount = ColCount + 1
    return element
  end
 
  if isParentCol(element) then
    element = handelParent(element)
    return element
  end
  
  
end

