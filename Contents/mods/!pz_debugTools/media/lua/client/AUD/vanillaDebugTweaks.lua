local ISPlayerStatsUI_onOptionMouseDown = ISPlayerStatsUI.onOptionMouseDown
function ISPlayerStatsUI:onOptionMouseDown(button, x, y)

    if button.internal == "ADDXP" then
        local modal = ISPlayerStatsAddXPUI:new(self.x + 200, self.y + 200, 300, 250, nil, ISPlayerStatsUI.onAddXP)
        modal:initialise()
        modal:addToUIManager()
        table.insert(ISPlayerStatsUI.instance.windows, modal)

        if self.selectedPerk.perk then
            for n,perk in pairs(modal.perkList) do
                if perk == self.selectedPerk.perk then
                    modal.combo.selected = n
                end
            end
        end

        return
    end

    ISPlayerStatsUI_onOptionMouseDown(self, button, x, y)
end