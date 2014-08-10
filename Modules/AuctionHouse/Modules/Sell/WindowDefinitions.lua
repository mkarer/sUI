--[[

	s:UI Auction House: Sell Module

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local AuctionHouse = S:GetModule("AuctionHouse");
local M = AuctionHouse:GetModule("Sell");

-----------------------------------------------------------------------------

local function ShowItemTooltip(self, wndHandler, wndControl) -- Build on mouse enter and not every hit to save computation time
	if (wndHandler ~= wndControl) then return; end
	local itemCurr = wndControl:GetParent():GetData();
	if (not itemCurr) then return; end
	Tooltip.GetItemTooltipForm(self, wndControl, itemCurr, { bPrimary = true, bSelling = false, itemModData = nil, itemCompare = itemCurr:GetEquippedItemForItemType() });
end

local function HideItemTooltip(self, wndHandler, wndControl)
	if (wndHandler ~= wndControl) then return; end
	wndControl:SetTooltipDoc(nil);
end

local function ShowItemPreview(self, wndHandler, wndControl, eMouseButton)
	if (wndHandler ~= wndControl) then return; end
	local itemCurr = wndControl:GetParent():GetData();
	if (not itemCurr) then return; end

	if (Apollo.IsControlKeyDown() and eMouseButton == GameLib.CodeEnumInputMouse.Right) then
		if (itemCurr:GetHousingDecorInfoId() ~= nil and itemCurr:GetHousingDecorInfoId() ~= 0) then
			Event_FireGenericEvent("DecorPreviewOpen", itemCurr:GetHousingDecorInfoId());
		else
			self.ItemPreviewImproved:OnShowItemInDressingRoom(itemCurr);
		end
	end
end

-----------------------------------------------------------------------------

function M:InitializeWindowDefinitions()
	if (self.tWindowDefinitions) then return; end

	self.tWindowDefinitions = {
		AnchorPoints = { 0, 0, 1, 1 },
		AnchorOffsets = { 4, 4, -4, -4 },
		IgnoreMouse = 1,
		Children = {
			-- Sellable Items Tree
			{
				Name = "TreeView",
				Class = "Window",
				Font = AuctionHouse.DB.strFont,
				AnchorPoints = { 0, 0, 0, 1 },
				AnchorOffsets = { 0, 0, AuctionHouse.GUI.nPanelWidthLeft, 0 },
				VScroll = true,
				AutoHideScroll = false,
				Template = "Holo_ScrollListSmall",
				Border = true,
				Sprite = "ClientSprites:WhiteFill",
				BGColor = "ff121314",
				Picture = true,
				UseTemplateBG = false,
				IgnoreMouse = 0,
			},
			-- Post Item Form
			{
				Name = "ListItemForm",
				AnchorPoints = { 0, 0, 0, 0 },
				AnchorOffsets = { AuctionHouse.GUI.nPanelWidthLeft + AuctionHouse.GUI.nControlPadding, 0, AuctionHouse.GUI.nPanelWidthLeft + AuctionHouse.GUI.nControlPadding + 440, 168 },
				Border = true,
	--			Picture = true,
	--			Sprite = "BK3:UI_BK3_Holo_InsetDivider",
				Children = {
					-- Item Name
					{
						Name = "ItemName",
						Font = AuctionHouse.DB.strFontLarge,
						Text = "PlaceHolder:ItemName",
						AnchorPoints = { 0, 0, 1, 0 },
						AnchorOffsets = { 80, 22, -AuctionHouse.GUI.nControlPadding, 22 + 20 },
					},
					-- Item Family
					{
						Name = "ItemFamily",
						Font = AuctionHouse.DB.strFont,
						Text = "PlaceHolder:ItemFamily",
						AnchorPoints = { 0, 0, 1, 0 },
						AnchorOffsets = { 80, 46, -AuctionHouse.GUI.nControlPadding, 46 + 20 },
					},
					-- Icon
					{
						Name = "IconContainer",
						AnchorPoints = { 0, 0, 0, 0 },
						AnchorOffsets = { 20, 20, AuctionHouse.GUI.nIconSizeBig + 2 * AuctionHouse.GUI.nIconBorderBig + 20, AuctionHouse.GUI.nIconSizeBig + 2 * AuctionHouse.GUI.nIconBorderBig + 20 },
						Picture = true,
						Sprite = "ClientSprites:WhiteFill",
						Events = {
							MouseEnter = ShowItemTooltip,
							MouseExit = HideItemTooltip,
							MouseButtonUp = self.ItemPreviewImproved and ShowItemPreview or nil,
						},
						Children = {
							-- Icon
							{
								Name = "Icon",
								AnchorPoints = { 0, 0, 1, 1 },
								AnchorOffsets = { AuctionHouse.GUI.nIconBorderBig, AuctionHouse.GUI.nIconBorderBig, -AuctionHouse.GUI.nIconBorderBig, -AuctionHouse.GUI.nIconBorderBig },
								BGColor = "white",
								Picture = true,
							},
						},
						Pixies = {
							-- Count
							{
								AnchorPoints = { 0, 0, 1, 1 },
								AnchorOffsets = { AuctionHouse.GUI.nIconBorderBig, AuctionHouse.GUI.nIconBorderBig, -AuctionHouse.GUI.nIconBorderBig -2, -AuctionHouse.GUI.nIconBorderBig -1 },
								Text = strCount,
								DT_RIGHT = true,
								DT_BOTTOM = true,
								Font = "CRB_Interface9_O",
							},
							-- Background
							{
								AnchorPoints = { 0, 0, 1, 1 },
								AnchorOffsets = { AuctionHouse.GUI.nIconBorderBig, AuctionHouse.GUI.nIconBorderBig, -AuctionHouse.GUI.nIconBorderBig, -AuctionHouse.GUI.nIconBorderBig },
								BGColor = "black",
								Sprite = "ClientSprites:WhiteFill",
							},
						},
					},
					-- Vendor
					{
						Class = "CashWindow",
						Name = "Vendor",
						AnchorPoints = { 0, 0, 0, 0 },
						AnchorOffsets = { 80, 76, 280, 76 + 20 },
						DT_RIGHT = true,
						DT_VCENTER = true,
						Font = AuctionHouse.DB.strFont,
						AllowEditing = false,
					},
					-- Bid
					{
						Class = "CashWindow",
						Name = "Bid",
						AnchorPoints = { 0, 0, 0, 0 },
						AnchorOffsets = { 80, 102, 280, 102 + 20 },
						DT_RIGHT = true,
						DT_VCENTER = true,
						Font = AuctionHouse.DB.strFont,
						AllowEditing = true,
						Events = { CashWindowAmountChanged = "OnChangeBidAmount" },
					},
					-- Buyout
					{
						Class = "CashWindow",
						Name = "Buyout",
						AnchorPoints = { 0, 0, 0, 0 },
						AnchorOffsets = { 80, 128, 280, 128 + 20 },
						DT_RIGHT = true,
						DT_VCENTER = true,
						Font = AuctionHouse.DB.strFont,
						AllowEditing = true,
						Events = { CashWindowAmountChanged = "OnChangeBidAmount" },
					},
					-- List Item Button
					{
						Class = "ActionConfirmButton",
						Name = "BtnListItem",
						AnchorPoints = { 0, 0, 1, 0 },
						AnchorOffsets = { 282 + AuctionHouse.GUI.nControlPadding, 102, 0, 152 },
						Base = "BK3:btnHolo_ListView_Mid",
						Text = AuctionHouse.L.PostItem,
						DT_VCENTER = true,
						DT_CENTER = true,
						Font = AuctionHouse.DB.strFont,
					},
				},
				Pixies = {
					-- Vendor Price
					{
						Font = AuctionHouse.DB.strFont,
						Text = "Vendor:",
						AnchorPoints = { 0, 0, 0, 0 },
						AnchorOffsets = { 0, 76, AuctionHouse.GUI.nIconSizeBig + 2 * AuctionHouse.GUI.nIconBorderBig + 20, 76 + 20 },
						DT_RIGHT = true,
						DT_VCENTER = true,
					},
					-- Bid
					{
						Font = AuctionHouse.DB.strFont,
						Text = "Bid:",
						AnchorPoints = { 0, 0, 0, 0 },
						AnchorOffsets = { 0, 102, AuctionHouse.GUI.nIconSizeBig + 2 * AuctionHouse.GUI.nIconBorderBig + 20, 102 + 20 },
						DT_RIGHT = true,
						DT_VCENTER = true,
					},
					{
						Sprite = "BK3:UI_BK3_Holo_InsetDivider",
						AnchorPoints = { 0, 0, 0, 0 },
						AnchorOffsets = { 78, 100, 280, 100 + 20 + 4 },
					},
					-- Buyout
					{
						Font = AuctionHouse.DB.strFont,
						Text = "Buyout:",
						AnchorPoints = { 0, 0, 0, 0 },
						AnchorOffsets = { 0, 128, AuctionHouse.GUI.nIconSizeBig + 2 * AuctionHouse.GUI.nIconBorderBig + 20, 128 + 20 },
						DT_RIGHT = true,
						DT_VCENTER = true,
					},
					{
						Sprite = "BK3:UI_BK3_Holo_InsetDivider",
						AnchorPoints = { 0, 0, 0, 0 },
						AnchorOffsets = { 78, 126, 280, 126 + 20 + 4 },
					},
				},
			},
		},
	};
end
