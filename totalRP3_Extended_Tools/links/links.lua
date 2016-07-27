----------------------------------------------------------------------------------
-- Total RP 3: Extended features
--	---------------------------------------------------------------------------
--	Copyright 2015 Sylvain Cossement (telkostrasz@totalrp3.info)
--
--	Licensed under the Apache License, Version 2.0 (the "License");
--	you may not use this file except in compliance with the License.
--	You may obtain a copy of the License at
--
--		http://www.apache.org/licenses/LICENSE-2.0
--
--	Unless required by applicable law or agreed to in writing, software
--	distributed under the License is distributed on an "AS IS" BASIS,
--	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--	See the License for the specific language governing permissions and
--	limitations under the License.
----------------------------------------------------------------------------------

local Globals, Events, Utils = TRP3_API.globals, TRP3_API.events, TRP3_API.utils;
local tostring, strtrim, tinsert, table, pairs, assert, wipe = tostring, strtrim, tinsert, table, pairs, assert, wipe;
local loc = TRP3_API.locale.getText;
local setTooltipForSameFrame = TRP3_API.ui.tooltip.setTooltipForSameFrame;
local stEtN = Utils.str.emptyToNil;

local editor = TRP3_LinksEditor;
local toolFrame;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Logic
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local LINK_LIST_WIDTH = 300;

local function decorateLinkElement(frame, index)
	local structureInfo = editor.structure[index];

	frame.Name:SetText(structureInfo.text);
	frame.Icon:SetTexture(structureInfo.icon);
	setTooltipForSameFrame(frame, "TOP", 0, -5, structureInfo.text, structureInfo.tt);

	TRP3_API.ui.listbox.setupListBox(frame.select, editor.workflowListStructure, function(value)
		toolFrame.specificDraft.LI[structureInfo.field] = stEtN(value);
	end, nil, LINK_LIST_WIDTH, true);
	TRP3_ScriptEditorNormal.safeLoadList(frame.select, editor.workflowIDs, toolFrame.specificDraft.LI[structureInfo.field] or "");
end

function editor.load(structure)
	assert(toolFrame.specificDraft, "specificDraft is nil");
	assert(toolFrame.specificDraft.SC, "specificDraft is nil");

	local data = toolFrame.specificDraft;
	if not data.LI then
		data.LI = {};
	end

	editor.workflowIDs = {};
	editor.workflowListStructure = TRP3_ScriptEditorNormal.reloadWorkflowlist(editor.workflowIDs);
	editor.structure = structure;

	TRP3_API.ui.list.initList(editor.links, editor.structure, editor.links.slider);
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- INIT
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

function editor.init(ToolFrame)
	toolFrame = ToolFrame;

	editor.links.title:SetText(loc("WO_EVENT_LINKS"));
	editor.links.triggers:SetText(loc("WO_LINKS_TRIGGERS"));

	-- List
	editor.links.widgetTab = {};
	for i=1, 5 do
		local line = editor.links["slot" .. i];
		tinsert(editor.links.widgetTab, line);
	end
	editor.links.decorate = decorateLinkElement;
	TRP3_API.ui.list.handleMouseWheel(editor.links, editor.links.slider);
	editor.links.slider:SetValue(0);
	editor.workflowIDs = {};

end