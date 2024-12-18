---https://github.com/Project-Zomboid-Community-Modding/pz-community-modding/issues/60
---Credit to Diakon5 (Daikon454) & Chuck (chuck)

require "OptionScreens/CharacterCreationProfession"
--(trait:isRemoveInMP() and not isClient()
local mutualyExclusive = CharacterCreationProfession.mutualyExclusive
function CharacterCreationProfession:mutualyExclusive(trait, bAdd)
    mutualyExclusive(self, trait, bAdd)

    for i = 0, trait:getMutuallyExclusiveTraits():size() - 1 do
        local exclusiveTrait = trait:getMutuallyExclusiveTraits():get(i)
        exclusiveTrait = TraitFactory.getTrait(exclusiveTrait)

        if exclusiveTrait:isRemoveInMP() and isClient() then
            if exclusiveTrait:getCost() > 0 then
                self.listboxTrait:removeItem(exclusiveTrait:getLabel())
            else
                self.listboxBadTrait:removeItem(exclusiveTrait:getLabel())
            end
        end

    end
end