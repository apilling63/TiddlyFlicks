-----------------------------------------------------------------------------------------
--
-- translations
--
-----------------------------------------------------------------------------------------
local t = {}

local language = "en"

local w =
{
    ["Escape from the Country"] =
    {
        ["en"] = "Escape from the Country",
        ["fr"] = "Dans la Nature",
    },
    ["Escape from the Moon"] =
    {
        ["en"] = "Escape from the Moon",
        ["fr"] = "Dans la Lune",
    },
    ["COMING SOON"] =
    {
        ["en"] = "COMING SOON!",
        ["fr"] = "PROCHAINEMENT!",
    }
}
 
function t.getPhrase(phrase)
	return w[phrase][language]
end

function t.setLanguage(lang)
	language = lang
end

return t
