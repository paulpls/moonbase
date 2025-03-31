--[[

    Send a notification upon collision

]]



local function F(self, entity, contact)
    if not world then return end

    local title = "Collision Detected"

    local text = table.concat{
        "Entity ", entity.id, " (", entity.__name, ")",
        " collided with ",
        "Entity ", self.id, " (", self.__name, ")",
    }

    world:notify(title, text)
end



return F
