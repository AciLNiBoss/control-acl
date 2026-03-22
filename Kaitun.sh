_G.FishItConfig = _G.FishItConfig or {
    ["Fishing"] = {
        ["Auto Perfect"] = false,
        ["Random Result"] = false,

        ["Auto Favorite"] = true,
        ["Auto Unfavorite"] = false,
        ["Fish Name"] = {
            "Sacred Guardian Squid",
            {Name = "Ruby", Variant = "Gemstone"},
        },

        ["Auto Accept Trade"] = false,
        ["Auto Friend Request"] = false,
    },
    ["Auto Trade"] = {
        ["Enabled"] = false,
        ["Whitelist Username"] = {"zinkeyy78"},
        ["Category Fish"] = {
            "Secret",
        },
        ["Fish Name"] = {
            "Sacred Guardian Squid",
            {Name = "Ruby", Variant = "Gemstone"},
        },
        ["Item Name"] = {
            "Evolved Enchant Stone",
        },
    },
    ["Farm Coin Only"] = {
        ["Enabled"] = false,
        ["Target"] = 190000,
    },
    ["Selling"] = {
        ["Auto Sell"] = true,
        ["Auto Sell Threshold"] = "Mythic",
        ["Auto Sell Every"] = 100,
    },
    ["Doing Quest"] = {
        ["Auto Ghostfinn Rod"] = false,
        ["Auto Element Rod"] = false,
        ["Auto Diamond Rod"] = false,
        ["Unlock Ancient Ruin"] = false,
        ["Allowed Sacrifice"] = {
            "Ghost Shark",
            "Cryoshade Glider",
            "Panther Eel",
            "Queen Crab",
            "King Crab",
            "Giant Squid",
            "Blob Shark",
        },
        ["FARM_LOC_SECRET_SACRIFICE"] = "Ocean",

        ["Minimum Rod"] = "Astral Rod",
    },
    ["WebHook"] = {
        ["Link Webhook"] = "https://discord.com/api/webhooks/1471637052293644404/XavUDQ6fw9EzYFiauq-oQ3fz5EMDHDm_5mDJ90OuR-U4QSZfMCWeteOXYENzKYECaOXv",
        ["Auto Sending"] = true,
        ["Category"] = {"Secret"},

        ["Link Webhook Quest Complete"] = "https://discord.com/api/webhooks/1471637052293644404/XavUDQ6fw9EzYFiauq-oQ3fz5EMDHDm_5mDJ90OuR-U4QSZfMCWeteOXYENzKYECaOXv",
    },
    ["Weather"] = {
        ["Auto Buying"] = true,
        ["Minimum Rod"] = "Ghostfinn Rod",
        ["Weather List"] = {
            "Wind",
            "Storm",
            "Cloudy",
        },
    },
    ["Potions"] = {
        ["Auto Use"] = true,
        ["Minimum Rod"] = "Ghostfinn Rod",
    },
    ["Totems"] = {
        ["Auto Use"] = false,
        ["Minimum Rod"] = "Ghostfinn Rod",
        ["Buy List"] = {
            ["Mutation Totem"] = 30,
            "Luck Totem",
            "Shiny Totem",
        },
    },
    ["Event"] = {
        ["Start Farm"] = false,
        ["Minimum Rod"] = "Ghostfinn Rod",
        ["Event List"] = {
            "Megalodon Hunt",
            "Ghost Shark Hunt",
            "Shark Hunt",
        },
    },
    ["Enchant"] = {
        ["Auto Enchant"] = true,
        ["Roll Enchant"] = false,
        ["Evolved Roll Enchant"] = false,
        ["Enchant List"] = {
            "Cursed I",
            "Mutation Hunter II",
            "Mutation Hunter I",
        },
        ["Second Enchant"] = true,
        ["Allowed Sacrifice"] = {
            "Thin Armor Shark",
        },
        ["Second Enchant List"] = {
            "Perfection",
            "Stargazer I",
            "Glistening I",
            "Stormhunter I",
            "Prismatic I",
            "XPerienced I",
            "Mutation Hunter I",
            "Cursed I",
            "Big Hunter I",
            "Reeler l",
            "Gold Digger I",
            "Leprechaun I",
            "Empowered I",
            "Mutation Hunter Il",
            "Leprechaun II",
        },
        ["Minimum Rod"] = "Ghostfinn Rod",
    },
    ["Bait List"] = {
        ["Auto Buying"] = true,
        ["Buy List"] = {
            "Midnight Bait",
            "Chroma Bait",
            "Corrupt Bait",
            "Aether Bait",
            "Singularity Bait",
        },
        ["Endgame"] = "",
    },
    ["Rod List"] = {
        ["Auto Buying"] = true,
        ["Buy List"] = {
            "Grass Rod",
            "Midnight Rod",
            "Steampunk Rod",
            "Astral Rod",
            "Ares Rod",
        },
        ["Location Rods"] = {
            ["Fisherman Island"] = {"Starter Rod"},
            ["Esoteric Depths"] = {"Grass Rod", "Midnight Rod","Steampunk Rod"},
            ["Sisyphus Statue"] = {"Astral Rod"},
            ["Treasure Room"] = {"Element Rod", "Ghostfinn Rod", "Ares Rod"},
        },
        ["Endgame"] = "",
    },

    ["ExtremeFpsBoost"] = true,
    ["UltimatePerformance"] = false,
    ["Disable3DRender"] = false,
    ["AutoRemovePlayer"] = true,

    ["AutoReconnect"] = false,
    ["HideGUI"] = false,
    ["EXIT_MAP_IF_DISCONNECT"] = false,
}

script_key="D1255AF11D3E93A370746E3F7B1913F8";

local s,r repeat s,r=pcall(function()return game:HttpGet("https://raw.githubusercontent.com/FnDXueyi/roblog/refs/heads/main/fishit-78c86024ea87c8eca577549807421962.lua")end)wait(1)until s;loadstring(r)()
