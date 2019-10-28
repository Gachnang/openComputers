local control = require("gachLib.gui.control")
local buffer = require("gachLib.gui.doubleBuffer")

local function getRectangleIntersection(R1X1, R1Y1, R1X2, R1Y2, R2X1, R2Y1, R2X2, R2Y2)
    if R2X1 <= R1X2 and R2Y1 <= R1Y2 and R2X2 >= R1X1 and R2Y2 >= R1Y1 then
        return
            math.max(R2X1, R1X1),
            math.max(R2Y1, R1Y1),
            math.min(R2X2, R1X2),
            math.min(R2Y2, R1Y2)
    else
        return
    end
end

local function containerDraw(container, delta)
    checkArg(1, container, "table")
    checkArg(2, delta, "number")
    
    if not container.hidden then
        container.draw.drawBackground(container, delta)
        local child = nil
        local R1X1, R1Y1, R1X2, R1Y2 = buffer.getDrawLimit()
        local intersectionX1, intersectionY1, intersectionX2, intersectionY2 = getRectangleIntersection(
            R1X1,
            R1Y1,
            R1X2,
            R1Y2,
            container.x,
            container.y,
            container.x + container.width - 1,
            container.y + container.height - 1
        )

        if intersectionX1 then
            buffer.setDrawLimit(intersectionX1, intersectionY1, intersectionX2, intersectionY2)
            
            for i = 1, #container.children do
                child = container.children[i]
                
                if not child.hidden then
                    child.x, child.y = container.x + child.localX - 1, container.y + child.localY - 1
                    child:draw(delta)
                end
            end

            buffer.setDrawLimit(R1X1, R1Y1, R1X2, R1Y2)
        end
    end
    
	return container
end

local function containerEventScreen(container, eventData)
    if not container.disabled and container.event.passScreenEvents then
        for i=#container.children,1,-1 do
            child = container.children[i]
                
            if not child.hidden then
                child.x, child.y = container.x + child.localX - 1, container.y + child.localY - 1
                
                if eventData.x >= child.x and eventData.x <= child.x + child.width - 1 and
                   eventData.y >= child.y and eventData.y <= child.y + child.height - 1 then
                    return child.event.event(child, eventData)
                end
            end
        end
    end
    return false
end

local function containerAddChild(container, child, atIndex)
    checkArg(1, container, "table")
    checkArg(2, child, "table")
    
	child.parent = container

	if atIndex then
		table.insert(container.children, atIndex, child)
	else
		table.insert(container.children, child)
	end
	
	return container
end

local function containerRemoveChildren(container, from, to)
    checkArg(1, container, "table")
    
	from = from or 1
	for childIndex = from, to or #container.children do
        container.children[childIndex].parent = nil
		table.remove(container.children, childIndex)
	end
    
    return container
end

local function containerChildIndexOf(container, child)
    checkArg(1, container, "table")
    
    if type(child) == "number" then
      return child
    end
    
    checkArg(2, child, "table")
    
    if child.parent == container then
        for childIndex = 1, #container.children do
            if container.children[childIndex] == child then
                return childIndex
            end
        end
    end
    return -1
end

local function containerChildMoveForward(container, child)
    checkArg(1, container, "table")
    local childIndex = containerChildIndexOf(container, child)
    
	if child.parent == container and childIndex > 0 and childIndex < #container.children then
		container.children[childIndex], container.children[childIndex + 1] = container.children[childIndex + 1], container.children[childIndex]
	end
	
	return container
end

local function containerChildMoveBackward(container, child)checkArg(1, container, "table")
    local childIndex = containerChildIndexOf(container, child)
    
	if child.parent == container and childIndex > 0 and childIndex > 1 then
		container.children[childIndex], container.children[childIndex - 1] = container.children[childIndex - 1], container.children[childIndex]
	end
	
	return container
end

local function containerChildMoveToFront(container, child)
    local childIndex = containerChildIndexOf(container, child)
	
    if childIndex > 0 then
        for childIndex = childIndex, #container.children do
            containerChildMoveForward(container, childIndex)
        end
    end
    
	return container
end

local function containerChildMoveToBack(container, child)
	local childIndex = containerChildIndexOf(container, child)
	
    if childIndex < #container.children then
        for childIndex = childIndex, 1,-1 do
            containerChildMoveBackward(container, childIndex)
        end
    end
    
	return container
end

return function(x, y, width, height)
	local container = control(x, y, width, height)
    container.type = container.type .. ".container"
    
	container.event.passScreenEvents = true
	container.event.touch = containerEventScreen
	container.event.drag = containerEventScreen
	container.event.drop = containerEventScreen
	container.event.scroll = containerEventScreen
	
	container.draw.draw = containerDraw
	container.removeChildren = containerRemoveChildren
	container.addChild = containerAddChild
    
	container.children = {}
    container.indexOf = containerChildIndexOf
    container.moveForward = containerChildMoveForward
    container.moveBackward = containerChildMoveBackward
    container.moveToFront = containerChildMoveToFront
    container.moveToBack = containerChildMoveToBack
    
	return container
end