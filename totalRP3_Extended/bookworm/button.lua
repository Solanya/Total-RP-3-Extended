----------------------------------------------------------------------------------
--- Total RP 3: Bookworm
--- Button API
---	---------------------------------------------------------------------------
---	Copyright 2017 Renaud "Ellypse" Parize @EllypseCelwe <ellypse@totalrp3.info>
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

---@class BookwormButton
local BookwormButton = {};
TRP3_API.bookworm.button = BookwormButton;

Bookworm.Button = {};

function BookwormButton.init()

	local button = TRP3_BookwormButton;
	local SetCursor = SetCursor;
	local GameTooltip = GameTooltip;
	local onBookwormButtonClicked = TRP3_API.bookworm.onBookwormButtonClicked;

	function BookwormButton:Show()
		button:Show();
	end

	function BookwormButton:ShowCheckmark()
		button.icon:SetVertexColor(0.5, 0.5, 0.5);
		button.checked:Show();
	end

	function BookwormButton:HideCheckmark()
		button.icon:SetVertexColor(1, 1, 1);
		button.checked:Hide();
	end

	function BookwormButton:Hide()
		button:Hide();
		BookwormButton:HideCheckmark();
	end

	function BookwormButton:SetIcon(icon)
		button.icon:SetTexture(icon);
	end

	local function showTooltip()
		GameTooltip:SetOwner(button, "ANCHOR_RIGHT") --Set our button as the tooltip's owner and attach it to the top right corner of the button.
		if button.checked:IsVisible() then
			GameTooltip:SetText("Item already exists. Click to add a copy to your main inventory.", nil, nil, nil, nil, true)
		else
			GameTooltip:SetText("Copy item to Total RP 3. ", nil, nil, nil, nil, true);
		end
		GameTooltip:Show() --Show the tooltip
	end


	button:SetScript("OnClick", function()
		if onBookwormButtonClicked() then
			BookwormButton:ShowCheckmark()
			GameTooltip:SetText("Item already exists. Click to add a copy to your main inventory.", nil, nil, nil, nil, true)
		else
			-- TODO Something went wrong, display error
		end
	end)
	button:SetScript("OnEnter", function()
		button.highlight:Show();
		SetCursor("Interface\\CURSOR\\Pickup");
		showTooltip();
	end);
	button:SetScript("OnLeave", function()
		button.highlight:Hide();
		SetCursor(nil);
		GameTooltip:Hide();
	end);
end