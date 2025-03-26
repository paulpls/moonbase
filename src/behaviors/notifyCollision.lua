--[[

    Send a notification upon collision

]]



local function F(self, entity)
    if not world then return end

    local message = table.concat{
        "Entity ", entity.id, " (", entity.__name, ")",
        " collided with ",
        "Entity ", self.id, " (", self.__name, ")",
    }

    world:notify(message)
end



return F
