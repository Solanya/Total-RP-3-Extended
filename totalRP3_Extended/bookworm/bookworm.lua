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

local function init()

	local tinsert = tinsert;
	local pairs = pairs;

	local TRP3_DB = TRP3_DB;
	local ITEM_TEXT_FROM = ITEM_TEXT_FROM;

	local TRP3       = {
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
	local BookwormButton = TRP3_API.bookworm.button;
	---@type ItemTextReader
	local ItemTextReader = TRP3_API.bookworm.ItemTextReader;

	local ITEM_ADDED_TO_INVENTORY_SOUND = 1184;
	local ITEM_ON_USE_SOUND = 831;

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


	TRP3.registerHandler("ITEM_TEXT_READY", function()
		BookwormButton:Show();
		local itemIcon = ItemTextReader.getItemIcon() or "Interface\\ICONS\\" .. getIconForMaterial(ItemTextReader.getMaterial());
		BookwormButton:SetIcon(itemIcon);
		if documentAlreadyExists(ItemTextReader.getItem()) then
			BookwormButton:ShowCheckmark();
		end
	end);
	TRP3.registerHandler("ITEM_TEXT_CLOSED", function()
		BookwormButton:Hide();
	end);

	function Bookworm.onBookwormButtonClicked()
		local itemID;
		if documentAlreadyExists(ItemTextReader.getItem()) then
			itemID = fetchExistingDocument(ItemTextReader.getItem());
		else
			local item;
			local id = TRP3.generateID();
			itemID, item =  TRP3.createItem(TRP3.getDocumentItemData(id), id);

			local bookTitle = ItemTextReader.getItem();
			local bookAuthor = ItemTextReader.getAuthor();

			-- Add opening sound on use
			item.SC.onUse.ST["2"] = {
				["e"] = {
					{
						["id"] = "sound_id_self",
						["args"] = {
							"SFX",
							ITEM_ON_USE_SOUND,
						},
					},
				},
				["t"] = "list",
			};
			-- Indicate in effect 1 that the next effect is effect 2
			item.SC.onUse.ST["1"].n = "2";

			item.BA.NA = bookTitle;
			if bookAuthor then
				item.BA.LE = ITEM_TEXT_FROM .. " " .. bookAuthor;
			end

			-- Use the icon of the item or the default icon for the material of the book
			item.BA.IC = ItemTextReader.getItemIcon() or getIconForMaterial(ItemTextReader.getMaterial());

			local content = item.IN.doc;
			content.PA = {};

			local currentPageNumber = ItemTextReader.getPageNumber();

			if bookAuthor then
				bookTitle = bookTitle ..",\n" .. ITEM_TEXT_FROM .. " " .. bookAuthor;
			end

			ItemTextReader.goToFirstPage();

			if ItemTextReader.currentPageIsHTML() then
				tinsert(content.PA, {
					TX = TITLE_PAGE_TEMPLATE:format(ItemTextReader.getItem())
				});
				tinsert(content.PA, {
					TX = ItemTextReader.getText(),
					HTML = true
				});
			else
				if ItemTextReader.getNumberOfPages() > 1 then
					tinsert(content.PA, {
						TX = TITLE_PAGE_TEMPLATE:format(ItemTextReader.getItem())
					});
					tinsert(content.PA, {
						TX = NORMAL_PAGE_TEMPLATE .. ItemTextReader.getText()
					})
				else
					tinsert(content.PA, {
						TX = TITLED_PAGE_TEMPLATE:format(bookTitle) .. ItemTextReader.getText();
					})
				end
			end
			while(ItemTextReader.hasNextPage()) do
				ItemTextReader.nextPage();
				if ItemTextReader.currentPageIsHTML() then
					tinsert(content.PA, {
						TX = ItemTextReader.getText(),
						HTML = true
					});
				else
					tinsert(content.PA, {
						TX = NORMAL_PAGE_TEMPLATE .. ItemTextReader.getText()
					})
				end
			end
			ItemTextReader.goToPage(currentPageNumber);
		end

		TRP3.addItem(nil, itemID, { count = 1 });
		TRP3.playSound(ITEM_ADDED_TO_INVENTORY_SOUND);

		TRP3.fireEvent(TRP3.ON_OBJECT_UPDATED);
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