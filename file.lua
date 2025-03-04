local function fetchVersionData(callback)
    local versionURL = "https://raw.githubusercontent.com/Wizaardd/MVS_Version/main/versions.json" -- 📌 URL düzeltildi

    PerformHttpRequest(versionURL, function(code, data, headers)
        if not data or code ~= 200 then
            print("^1[🔍 Version Check] ❌ Failed to retrieve version information. HTTP Error Code: " .. code .. "^0")
            return
        end

        local success, parsedData = pcall(json.decode, data) -- 📌 Hata kontrolü eklendi

        if not success or type(parsedData) ~= 'table' then
            print("^1[🔍 Version Check] ⚠️ Received invalid version data.^0")
            return
        end

        callback(parsedData)
    end, "GET", "", {["Content-Type"] = "application/json"})
end

local function fetchLinksData(callback)
    local linksURL = "https://raw.githubusercontent.com/Wizaardd/MVS_Version/main/links.json" -- 📌 URL düzeltildi

    PerformHttpRequest(linksURL, function(code, data, headers)
        if not data or code ~= 200 then
            print("^1[🔗 Link Check] ❌ Failed to retrieve link information. HTTP Error Code: " .. code .. "^0")
            return
        end

        local success, parsedData = pcall(json.decode, data) -- 📌 Hata kontrolü eklendi

        if not success or type(parsedData) ~= 'table' then
            print("^1[🔗 Link Check] ⚠️ Received invalid link data.^0")
            return
        end

        callback(parsedData)
    end, "GET", "", {["Content-Type"] = "application/json"})
end

local function checkAllVersions()
    fetchVersionData(function(versionData)
        local scriptResourceName = GetCurrentResourceName()

        for resourceName, remoteVersion in pairs(versionData) do
            Citizen.Wait(200)

            if resourceName == scriptResourceName then
                local currentVersion = GetResourceMetadata(resourceName, 'version', 0)

                if not currentVersion then
                    print("^1[🔍 Version Check] ❌ No version metadata found for " .. resourceName .. "^0")
                    return
                end
                
                if currentVersion and remoteVersion then
                    if currentVersion ~= remoteVersion then
                        print("^1[❌ ".. resourceName .."] 🚀 A new version is available! (Current: ^2" .. currentVersion .. "^1, Remote: ^3" .. remoteVersion .. "^1) Please update via Keymaster or Discord.^0")
                    else
                        print("^2[✅ ".. resourceName .."] 🎉 You are using the latest version! (Version: ^3" .. currentVersion .. "^2)^0")
                    end
                else
                    print("^3[🔍 Version Check] ⚠️ Unable to retrieve version details for " .. resourceName .. ".^0")
                end
            end
        end
    end)

    fetchLinksData(function(links)
        print("^5[🔗 Links] 🌐 Tebex Store: ^4" .. links.tebex .. "^0")
        print("^5[🔗 Links] 📖 Documentation: ^4" .. links.docs .. "^0")
        print("^5[🔗 Links] 💬 Discord: ^4" .. links.discord .. "^0")
    end)
end

Citizen.CreateThread(function()
    Citizen.Wait(5000)
    checkAllVersions()
end)
