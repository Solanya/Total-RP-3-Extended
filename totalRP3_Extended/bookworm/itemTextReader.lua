----------------------------------------------------------------------------------
---  Total RP 3: Bookworm
---  ItemTextReader API
---  A layer of abstraction on top of WoW's API for getting info about an Item Text item.
---    ---------------------------------------------------------------------------
---    Copyright 2017 Renaud "Ellypse" Parize @EllypseCelwe <ellypse@totalrp3.info>
---
---    Licensed under the Apache License, Version 2.0 (the "License");
---    you may not use this file except in compliance with the License.
---    You may obtain a copy of the License at
---
---        http://www.apache.org/licenses/LICENSE-2.0
---
---    Unless required by applicable law or agreed to in writing, software
---    distributed under the License is distributed on an "AS IS" BASIS,
---    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
---    See the License for the specific language governing permissions and
---    limitations under the License.
----------------------------------------------------------------------------------


---@class ItemTextReader
local ItemTextReader = {};
TRP3_API.bookworm.ItemTextReader = ItemTextReader;

function ItemTextReader.init()

	-- Local import of global functions
	local ItemTextGetMaterial = ItemTextGetMaterial;
	local find = string.find;

	-- Get the number of the current page
	ItemTextReader.getPageNumber = ItemTextGetPage;
	-- Go to previous page
	ItemTextReader.previousPage = ItemTextPrevPage;
	-- Go to next page
	ItemTextReader.nextPage = ItemTextNextPage;
	-- Return true if a next page exists
	ItemTextReader.hasNextPage = ItemTextHasNextPage;
	-- Get the name of the item (book; parchment; letter; plaque)
	ItemTextReader.getItem = ItemTextGetItem;

	---Get information about an item by its name
	function ItemTextReader.getInfo()
		return GetItemInfoInstant(ItemTextReader.getItem());
	end
	-- Get the name of the creator of the letter; if there is one
	ItemTextReader.getAuthor = ItemTextGetCreator;
	-- Get the text from the page being displayed
	ItemTextReader.getText = ItemTextGetText;

	---Return true if an author exists for the document (only for letters)
	---@return boolean
	function ItemTextReader.hasAuthor()
		return ItemTextReader.getAuthor() ~= nil;
	end

	---Return the type of material for the document
	---Parchment, Bronze, Silver, Stone or Marble
	---@return string
	function ItemTextReader.getMaterial()
		return ItemTextGetMaterial() or "Parchment";
	end

	---Go back to the first page of the book
	function ItemTextReader.goToFirstPage()
		while ItemTextReader.getPageNumber() > 1 do
			ItemTextReader.previousPage();
		end
	end

	---Go to the last page of the book
	function ItemTextReader.goToLastPage()
		while ItemTextReader.hasNextPage() do
			ItemTextReader.nextPage();
		end
	end

	---Go to a specific page in the book
	---@param pageNumer number
	function ItemTextReader.goToPage(pageNumer)
		ItemTextReader.goToFirstPage();
		while ItemTextReader.getPageNumber() ~= pageNumer do
			ItemTextReader.nextPage();
		end
	end

	---Checkif the text item currently opened contains HTML text instead of plain text
	---@return boolean
	function ItemTextReader.currentPageIsHTML()
		local text = ItemTextReader.getText();
		return find(text, "<HTML>") == 1;
	end

	---Returns the number of pages in the text item currently opened
	---@return number
	function ItemTextReader.getNumberOfPages()
		local currentPage = ItemTextReader.getPageNumber();
		local numberOfPages = 1;
		ItemTextReader.goToFirstPage();
		while (ItemTextReader.hasNextPage()) do
			numberOfPages = numberOfPages + 1;
			ItemTextReader.nextPage();
		end
		ItemTextReader.goToPage(currentPage);
		return numberOfPages;
	end

	---Return the icon of the item used to display the document
	---@return number
	function ItemTextReader.getItemIcon()
		local itemID, itemType, itemSubType, itemEquipLoc, iconFileDataID, itemClassID, itemSubClassID = ItemTextReader.getInfo();
		return iconFileDataID;
	end
end