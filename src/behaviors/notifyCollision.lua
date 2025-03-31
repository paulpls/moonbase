--[[

    Send a notification upon collision

]]



local function F(self, entity, contact, normal, tangent)
    if not world then return end

    local title = "Collision Detected"

    local text = table.concat{
        "Entity ", entity.id, " (", entity.__name, ")",
        " collided with ",
        "Entity ", self.id, " (", self.__name, ")",
        "\nNormal: ", tostring(normal), "",
        "\nTangent: ", tostring(tangent), "",
    }

    world:notify(title, text)
end



return F
