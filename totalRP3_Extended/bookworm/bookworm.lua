----------------------------------------------------------------------------------
--- Total RP 3: Bookworm
--- Bookworm API
---	---------------------------------------------------------------------------
---	Copyright 2017 Renaud "Ellypse" Parize <ellypse@totalrp3.info> @EllypseCelwe
---
---	Licensed under the Apache License, Version 2.0 (the "License");
---	you may not use this file except in compliance with the License.
---	You may obtain a copy of the License at
---
---		http://www.apache.org/licenses/LICENSE-2.0
---
---	Unless required by applicable law or agreed to in writing, software
---	distributed under the License is distributed on an "AS IS" BASIS,
---	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
---	See the License for the specific language governing permissions and
---	limitations under the License.
----------------------------------------------------------------------------------

---@class Bookworm
local Bookworm = {};
TRP3_API.bookworm = Bookworm;

local function log(...)
	if not TRP3_DEBUG then
		return
	end;
	local tab = 1
	for i = 1, 10 do
		if GetChatWindowInfo(i) == "Logs" then
			tab = i
			break
		end
	end
	_G["ChatFrame" .. tab]:AddMessage("|cffaaaaaa[Total RP 3: Bookworm]|r " .. strjoin(" ", tostringall(...)));
end;

local function logEvent(event, ...)
	log(("|cff62D96B[EVENT FIRED : %s]|r"):format(event), ...);
end

local function logValue(valueName, ...)
	log(("|cff669EFF[%s]|r = "):format(valueName), ...);
end
local function logTexture(valueName, texture, ...)
	log(("|cff669EFF[%s]|r = "):format(valueName), ("\124T%s:20:20\124t"):format(texture or ""), ...);
end


local function init()

	local tinsert = tinsert;
	local pairs = pairs;

	local TRP3_DB = TRP3_DB;
	local ITEM_TEXT_FROM = ITEM_TEXT_FROM;

	local TRP3_API       = {
		generateID           = TRP3_API.utils.str.id,
		getDocumentItemData  = TRP3_API.extended.tools.getDocumentItemData,
		createItem           = TRP3_API.extended.tools.createItem,
		addItem              = TRP3_API.inventory.addItem,
		playSound            = TRP3_API.ui.misc.playSoundKit,
		fireEvent            = TRP3_API.events.fireEvent,
		ON_OBJECT_UPDATED    = TRP3_API.events.ON_OBJECT_UPDATED,
		registerEffect       = TRP3_API.script.registerEffect,
		displayMessage       = TRP3_API.utils.message.displayMessage,
		messageTypes         = TRP3_API.utils.message.type,
		loc                  = TRP3_API.locale.getText,
		getClass             = TRP3_API.extended.getClass,
		registerEffectEditor = TRP3_API.extended.tools.registerEffectEditor,
		getBlankItemData     = TRP3_API.extended.tools.getBlankItemData,
		registerHandler      = TRP3_API.utils.event.registerHandler
	}

	---@type BookwormButton
	local BookwormButton = TRP3_API.bookworm.BookwormButton;
	---@type ItemTextReader
	local ItemTextReader = TRP3_API.bookworm.ItemTextReader;

	-- Default icons to use when the document is not from an item
	local DEFAULT_ICONS        = {
		Parchment = "INV_Misc_Book_03",
		Bronze    = "inv_misc_wartornscrap_plate",
		Silver    = "inv_misc_wartornscrap_plate",
		Stone     = "INV_Misc_StoneTablet_04",
		Marble    = "INV_Misc_StoneTablet_03",
		default   = "INV_Misc_Book_03",
	}

	local DOCUMENT_TYPES       = {
		Parchment = "Book",
		Bronze    = "Plaque",
		Silver    = "Plaque",
		Stone     = "Plaque",
		Marble    = "Plaque",
	}

	local TITLE_PAGE_TEMPLATE  = [[
{p:c}{/p}




{h1:c}{col:3f0100}%s{/col}{/h1}
{img:Interface\QUESTFRAME\UI-HorizontalBreak:256:64}
]]
	local NORMAL_PAGE_TEMPLATE = [[{img:Interface\QUESTFRAME\UI-HorizontalBreak:256:64}
]];
	local TITLED_PAGE_TEMPLATE = [[{p:c}{/p}
{h1:c}{col:3f0100}%s{/col}{/h1}
{img:Interface\QUESTFRAME\UI-HorizontalBreak:256:64}
]]

	local function getIconForMaterial(material)
		return DEFAULT_ICONS[material] or DEFAULT_ICONS.default;
	end

	local function fetchExistingDocument(documentName)
		for itemID, item in pairs(TRP3_DB.global) do
			if item.BA.NA == documentName then
				return itemID;
			end
		end
	end

	local function documentAlreadyExists(documentName)
		return fetchExistingDocument(documentName) ~= nil;
	end


	TRP3_API.registerHandler("ITEM_TEXT_READY", function()
		BookwormButton:Show();
		local itemIcon = ItemTextReader.getItemIcon() or "Interface\\ICONS\\" .. getIconForMaterial(ItemTextReader.getMaterial());
		BookwormButton:SetIcon(itemIcon);
		if documentAlreadyExists(ItemTextReader.getItem()) then
			BookwormButton:ShowCheckmark();
		end
	end);
	TRP3_API.registerHandler("ITEM_TEXT_CLOSED", function()
		BookwormButton:Hide();
	end);

	function Bookworm.onBookwormButtonClicked()
		local itemID;
		if documentAlreadyExists(ItemTextReader.getItem()) then
			itemID = fetchExistingDocument(ItemTextReader.getItem());
			logValue("Item already exists, adding to the inventory item", itemID);
		else

			local newItemID, item = TRP3_API.createItem(TRP3_API.getBlankItemData());
			itemID = newItemID;
			logValue("Created new item", itemID);

			-- Decorate item
			item.BA.NA = ItemTextReader.getItem();
			if ItemTextReader.hasAuthor() then
				item.BA.LE = ITEM_TEXT_FROM .. " " .. ItemTextReader.getAuthor();
			end

			--TODO Make TRP3: Extended accept texture IDs so we can use the actual items icon
			item.BA.IC = getIconForMaterial(ItemTextReader.getMaterial());

			local pages = {};
			local currentPageNumber = ItemTextReader.getPageNumber();

			ItemTextReader.goToFirstPage();
			tinsert(pages, ItemTextReader.getText());
			while (ItemTextReader.hasNextPage()) do
				ItemTextReader.nextPage();
				tinsert(pages, ItemTextReader.getText());
			end
			ItemTextReader.goToPage(currentPageNumber);

			-- Add opening sound on use
			item.SC = {
				onUse = {
					ST = {
						["1"] = {
							["e"] = {
								{
									["id"]   = "sound_id_self",
									["args"] = {
										"SFX",
										831,
									},
								},
							},
							["t"] = "list",
							["n"] = "2"
						},
						["2"] = {
							["e"] = {
								{
									["id"]   = "document_show_html",
									["args"] = {
										name   = ItemTextReader.getItem(),
										author = ItemTextReader.getAuthor(),
										pages  = pages
									},
								},
							},
							["t"] = "list",
						}
					}
				}
			};
		end

		TRP3_API.addItem(nil, itemID, { count = 1 });
		TRP3_API.playSound(1184);

		TRP3_API.fireEvent(TRP3_API.ON_OBJECT_UPDATED);

		return true
	end

	BookwormButton.init();
	ItemTextReader.init();
end

TRP3_API.module.registerModule(
{
	["name"]         = "Bookworm",
	["description"]  = "Copy in-game books and other readable items as Total RP 3: Extended items.",
	["version"]      = 1.000,
	["id"]           = "trp3_bookworm",
	["onStart"]      = init,
	["minVersion"]   = 25,
	["requiredDeps"] = {
		{ "trp3_extended", 0.9 },
	}
});