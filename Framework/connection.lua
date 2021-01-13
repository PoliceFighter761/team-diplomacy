local Connection = {}
Connection.__index = Connection

function Connection.new(game)
    local self = setmetatable({}, Connection)

    self.Functions = {}

    return self
end

function Connection:Fire(...)
    for i, Function in pairs(self.Functions) do
        Function(...)
    end
end

function Connection:GetActiveConnections()
    return #self.Functions
end

function Connection:Connect(f)
    local index = table.maxn(self.Functions) + 1

    self.Functions[index] = f

    return {
        ["Disconnect"] = function()
            self.Functions[index] = nil
        end
    }
end

return Connection