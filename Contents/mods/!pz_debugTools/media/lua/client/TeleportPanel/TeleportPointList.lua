require "ISUI/ISCollapsableWindow"
require "InitToolBar"

AUD.TeleportPointExplorer = {}
AUD.TeleportPointExplorer.FavFileList = {}


TeleportPointList = ISScrollingListBox:derive("TeleportPointList")


function TeleportPointList:onMouseDoubleClickFile(item)
    if not item then return end

    local player = getSpecificPlayer(0)
    if not player then return end
    if isClient() then
        SendCommandToServer("/teleportto " .. tostring(item[1]) .. "," .. tostring(item[2]) .. ",0")
    else
        player:teleportTo(item[1], item[2], 0.0)
    end
end


function TeleportPointList:doDrawItem(y, item, alt)
    if y + self:getYScroll() >= self.height then return y + item.height end
    if y + item.height + self:getYScroll() <= 0 then return y + item.height end

    if self.selected == item.index then
        self:drawRect(0, (y), self:getWidth(), self.itemheight-1, 0.3, 0.7, 0.35, 0.15);

    end
    self:drawRectBorder(0, (y), self:getWidth(), self.itemheight, 0.5, self.borderColor.r, self.borderColor.g, self.borderColor.b);
    
    self:drawText(item.text, 15, y + (item.height - self.fontHgt) / 2, 0.9, 0.9, 0.9, 0.9, UIFont.Small);
    y = y + self.itemheight;
    return y;
end

function TeleportPointList:onMouseWheel(del)
    self:setYScroll(self:getYScroll() - (del*self.itemheight*6));
    return true;
end
