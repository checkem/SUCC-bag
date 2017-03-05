
function SUCC_bagDefaults()
	SUCC_bagOptions = {}
	SUCC_bagOptions.colors = {}
	SUCC_bagOptions.colors.highlight = {1, 0.2, 0.2 }
	SUCC_bagOptions.colors.quest = {0.96, 0.64, 0.94}
	SUCC_bagOptions.colors.ammo = {0.8, 0.8, 0.3}
	SUCC_bagOptions.colors.BG = {0.98, 0.95, 0}
	SUCC_bagOptions.colors.border = {1, 1, 1}
	SUCC_bagOptions.colors.backdrop = {0.3, 0.3, 0.3}
	SUCC_bagOptions.colors.bag = {}
	SUCC_bagOptions.colors.bag['Bag'] = {0.3, 0.3, 0.3}
	SUCC_bagOptions.colors.bag['Soul Bag'] = {0.678, 0.549, 1}
	SUCC_bagOptions.colors.bag['Herb Bag'] = {0.3, 0.8, 0.3}
	SUCC_bagOptions.colors.bag['Enchanting Bag'] = {0.5, 0.4, 0.8}
	SUCC_bagOptions.layout = {}
	SUCC_bagOptions.layout.texture = 'Default'
	SUCC_bagOptions.layout.spacing = 4
	SUCC_bagOptions.layout.bag ={}
	SUCC_bagOptions.layout.bag.columns = 8
	SUCC_bagOptions.layout.bag.type = 1
	SUCC_bagOptions.layout.bag.Keyring = 0
	SUCC_bagOptions.layout.bank ={}
	SUCC_bagOptions.layout.bank.columns = 8
	SUCC_bagOptions.layout.bank.type = 1
	SUCC_bagOptions.Clean_Up = 1
	return SUCC_bagOptions
end

-- debug
local function print(mes)
	DEFAULT_CHAT_FRAME:AddMessage(mes)
end

local function FrameTrimToSize(frame)
	local frameName = frame:GetName()
	local slot, height, width
	if not frame.size or frame.size == 0 then
		height = 64
		width = 256
	else
		local slot = frame.size + 1
		local button = getglobal(frameName .. 'Item'.. slot)
		while button do
			button:Hide()
			slot = slot + 1
			button = getglobal(frameName .. 'Item'.. slot)
		end
		if frame.size < frame.cols then
			width = (37 + frame.space) * frame.size + 14 - frame.space
		else
			width = (37 + frame.space) * frame.cols + 14 - frame.space
		end
		height = (37 + frame.space) * math.ceil(frame.size / frame.cols)  + 32 - frame.space
	end
	frame:SetWidth(width)
	frame:SetHeight(height)
end

local function TitleLayout(frame)
	if not frame.slotFrame then return end
	if frame.cuBag and SUCC_bagOptions.Clean_Up == 1 then
		frame.title:ClearAllPoints()
		frame.title:SetPoint('LEFT', frame.cuBag, 'RIGHT', 3, 0)
		if frame.layout == 1 then
			frame.cuBag:SetPoint('LEFT', frame.toggleButton, 'RIGHT', 3, 0)
		else
			frame.cuBag:SetPoint('TOPLEFT', 10, -6)
		end
		if not frame.cuBag:IsVisible() then frame.cuBag:Show() end
	elseif frame.layout == 1 then
		if frame.cuBag then frame.cuBag:Hide() end
		frame.title:ClearAllPoints()
		frame.title:SetPoint('LEFT', frame.toggleButton, 'RIGHT', 3, 0)
	else
		frame.toggleButton:Hide()
	end
end

local function SlotFrameSetup(frame)
	if frame.layout == 1 then
		frame.slotFrame:SetFrameLevel(0)
		frame.slotFrame:SetPoint('TOPRIGHT', frame, 'TOPLEFT', 8, -16)
		frame.slotFrame:SetBackdrop({
		bgFile = 'Interface\\AddOns\\SUCC-bag\\Textures\\marble',
		edgeFile = 'Interface\\AddOns\\SUCC-bag\\Textures\\BagSlotFrame',
		tile = true,
		tileSize = 128,
		edgeSize = 32,
		insets = {
			left = 5,
			right = 0,
			top = 5,
			bottom = 5
		}
		})
		frame.slotFrame:SetBackdropBorderColor(unpack(SUCC_bagOptions.colors.border))
		frame.slotFrame:SetBackdropColor(unpack(SUCC_bagOptions.colors.backdrop))
		frame.slotFrame:Hide()
	end
end

local function FrameLayout(frame)
	if not frame.size then return end
	local frameName = frame:GetName()
	if frame.slotCost then
		cols = SUCC_bagOptions.layout.bank.columns or 6
	else
		cols = SUCC_bagOptions.layout.bag.columns or 6
	end
	local space = SUCC_bagOptions.layout.spacing or 4
	frame.space = space
	frame.cols = cols
	local rows = math.ceil(frame.size / cols)
	local button = getglobal(frameName .. 'Item1')
	if button then
		local index = 1
		button:ClearAllPoints()
		button:SetPoint('TOPLEFT', frame, 9, -25)
		for i = 1, rows, 1 do
			for j = 1, cols, 1 do
				index = index + 1
				button = getglobal(frameName .. 'Item' .. index)
				if not button then break end
				button:ClearAllPoints()
				button:SetPoint('LEFT', frameName .. 'Item' .. index - 1, 'RIGHT', space, 0)
			end
			button = getglobal(frameName .. 'Item' .. index)
			if not button then break end
			button:ClearAllPoints()
			button:SetPoint('TOP', frameName .. 'Item' .. index - cols, 'BOTTOM', 0, -space)
		end
	end
	if frame.slotFrame and frame.layout == 1 then
		local totalslots = table.getn(frame.slotFrame.slot)
		local bagcols, slot = math.ceil(totalslots / rows), 2
		frame.slotFrame.slot[1]:ClearAllPoints()
		frame.slotFrame.slot[1]:SetPoint('TOPLEFT', frame.slotFrame, 7, -9)
		frame.slotFrame:SetWidth((37 + SUCC_bagOptions.layout.spacing) * bagcols + 14 - SUCC_bagOptions.layout.spacing)
		for i = 1, rows, 1 do
			if bagcols > 1 then
				for j = 2, bagcols, 1 do
					if not frame.slotFrame.slot[slot] then break end
					frame.slotFrame.slot[slot]:ClearAllPoints()
					frame.slotFrame.slot[slot]:SetPoint('LEFT', frame.slotFrame.slot[slot - 1], 'RIGHT', space, 0)
					slot = slot + 1
				end
			end
			if not frame.slotFrame.slot[slot] then
				frame.slotFrame:SetHeight((37 + SUCC_bagOptions.layout.spacing) * i  + 14 - SUCC_bagOptions.layout.spacing)
				break
			end
			frame.slotFrame.slot[slot]:ClearAllPoints()
			frame.slotFrame.slot[slot]:SetPoint('TOP', frame.slotFrame.slot[slot - bagcols], 'BOTTOM', 0, -space)
			slot = slot + 1
		end
	end
	FrameTrimToSize(frame)
end

local function BagType (bagID)
	if bagID > 0 then
		local link = GetInventoryItemLink('player', ContainerIDToInventoryID(bagID))
		if(link) then
			local _, _, id = string.find(link, "item:(%d+)")
			local _, _, _, _, itemType, subType = GetItemInfo(id)
			if itemType == 'Quiver' then
				return unpack(SUCC_bagOptions.colors.ammo)
			else
				return unpack(SUCC_bagOptions.colors.bag[subType])
			end
		end
	else
		return unpack(SUCC_bagOptions.colors.bag.Bag)
	end
end

local function ItemUpdateBorder(button, option)
	if option then
		button:GetNormalTexture():SetVertexColor(unpack(SUCC_bagOptions.colors.highlight))
	elseif not button:GetParent().colorLocked then
		local bagID = button:GetParent():GetID()
		local link = GetContainerItemLink(bagID, button:GetID())
		if link then
			local _, _, id = string.find(link, "item:(%d+)")
			local n, _, q, _, _, t = GetItemInfo(id)
			if string.find(n, 'Mark of Honor') then
				button:GetNormalTexture():SetVertexColor(unpack(SUCC_bagOptions.colors.BG))
				return
			elseif t == 'Quest' then
				button:GetNormalTexture():SetVertexColor(unpack(SUCC_bagOptions.colors.quest))
				return
			elseif q > 1 then
				button:GetNormalTexture():SetVertexColor(GetItemQualityColor(q))
				return
			end
		end
		button:GetNormalTexture():SetVertexColor(BagType(bagID))
	end
end

local function HighlightBagSlots(bagID, option)
	local frame = getglobal('SUCC_bagDummyBag' .. bagID)
	if frame then
		local items = {frame:GetChildren()}
		if option then frame.colorLocked = 1 else  frame.colorLocked = nil end
		for _, item in pairs(items) do
			ItemUpdateBorder(item, option)
		end
	end
end

local function ItemUpdate(item)
	local texture, itemCount, readable, locked
	texture, itemCount, locked, _, readable = GetContainerItemInfo(item:GetParent():GetID(), item:GetID())
	ItemUpdateBorder(item)
	if texture then
		ContainerFrame_UpdateCooldown(item:GetParent():GetID() , item)
		item.hasItem = 1
	else
		getglobal(item:GetName() .. 'Cooldown'):Hide()
		item.hasItem = nil
	end
	SetItemButtonDesaturated(item, locked, 0.5, 0.5, 0.5)
	SetItemButtonTexture( item, texture )
	SetItemButtonCount( item, itemCount )
	local showSell = nil
	if GameTooltip:IsOwned(item) then
		if texture then
			local hasCooldown, repairCost = GameTooltip:SetBagItem(item:GetParent():GetID(),item:GetID())
			if ( InRepairMode() and (repairCost > 0) ) then
				GameTooltip:AddLine(TEXT(REPAIR_COST), "", 1, 1, 1)
				SetTooltipMoney(GameTooltip, repairCost)
				GameTooltip:Show()
			elseif ( MerchantFrame:IsShown() and not locked) then
				showSell = 1
			end
		else
			GameTooltip:Hide()
		end
		if showSell then
			ShowContainerSellCursor(item:GetParent():GetID(), item:GetID())
		elseif readable then
			ShowInspectCursor()
		else
			ResetCursor()
		end
	end
end

local function ItemCreate(name, parent)
	local button
	if parent:GetID() == -1 then
		button = CreateFrame('Button', name, parent, 'BankItemButtonGenericTemplate')
		CreateFrame('Model', name .. 'Cooldown', button, 'CooldownFrameTemplate')
	else
		button = CreateFrame('Button', name, parent, 'ContainerFrameItemButtonTemplate')
	end
	button:SetNormalTexture('Interface\\AddOns\\SUCC-bag\\Textures\\Slot')
	button.bg = button:CreateTexture(nil, 'BACKGROUND')
	button.bg:SetTexture[[Interface\PaperDoll\UI-Backpack-EmptySlot]]
	button.bg:SetAlpha(.75)
	button.bg:SetAllPoints()
	button:SetAlpha(parent:GetParent():GetAlpha())
	return button
end

local dummyBag = {}

local function CreateDummyBag(parent, bagID)
	local dummyBag = CreateFrame('Frame', 'SUCC_bagDummyBag' .. bagID, parent)
	dummyBag:SetID(bagID)
	return dummyBag
end

local function AddBag(frame, bagID)
	if not dummyBag[bagID] then
		dummyBag[bagID] = CreateDummyBag(frame, bagID)
	end
	if dummyBag.removed == bagID then dummyBag.removed = nil return end
	local frameName = frame:GetName()
	local slot = frame.size
	local bagSize
	if(bagID == KEYRING_CONTAINER) then
		bagSize = GetKeyRingSize()
	else
		bagSize = GetContainerNumSlots(bagID)
	end
	dummyBag[bagID].size = bagSize
	for index = 1, bagSize, 1 do
		slot = slot + 1
		local item = getglobal( frameName .. 'Item'.. slot) or ItemCreate(frameName .. 'Item'.. slot, dummyBag[bagID])
		item:SetID(index)
		item:SetParent(dummyBag[bagID])
		item:Show()
		ItemUpdate(item)
	end
	frame.size = frame.size + bagSize
end

local function FrameGenerate(frame)
	frame.size = 0
	local frameName = frame:GetName()
	if frame.moneyFrame then
		MoneyFrame_Update(frameName .. 'MoneyFrame', GetMoney())
	end
	for _, bagID in pairs(frame.bags) do
		AddBag(frame, bagID)
	end
	FrameLayout(frame)
	frame:Show()
end

local function RemoveBag(frame, bagID, bagSize)
	if dummyBag[bagID] and dummyBag[bagID].size ~= bagSize then
		FrameGenerate(frame)
		return 1
	else
		return nil
	end
end

function FrameUpdate(frame, bagID)
	local frameName = frame:GetName()
	local startSlot = 1
	local endSlot
	if not bagID then
		endSlot = frame.size
	else
		if bagID == KEYRING_CONTAINER then
			endSlot = GetKeyRingSize()
			frameName = SUCC_bag.keyring:GetName()
		else
			if not frame.size or RemoveBag(frame, bagID, GetContainerNumSlots(bagID)) then return end
			for _, bag in pairs(frame.bags) do
				if bag == bagID then
					endSlot = startSlot + GetContainerNumSlots(bag) - 1
					break
				else
					startSlot = startSlot + GetContainerNumSlots(bag)
				end
			end
		end
	end
	for slot = startSlot, endSlot do
		local item = getglobal(frameName .. 'Item' .. slot)
		if item then
			ItemUpdate(item)
		end
	end
end

local function FrameUpdateLock(frame)
	if not frame.size then return end
	local frameName = frame:GetName()
	for slot = 1, frame.size do
		local item = getglobal(frameName .. 'Item' .. slot)
		local _, _, locked = GetContainerItemInfo(item:GetParent():GetID(), item:GetID())
		SetItemButtonDesaturated(item, locked, 0.5, 0.5, 0.5)
	end
end

local function Essentials(frame)
	local t = frame:GetName()
	frame:SetScript('OnMouseDown', function() this:StartMoving() end)
	frame:SetScript('OnMouseUp', function() this:StopMovingOrSizing() end)
	frame:SetToplevel()
	frame:EnableMouse()
	frame:SetMovable()
	frame:SetClampedToScreen()
	frame:SetBackdrop({
		bgFile = 'Interface\\AddOns\\SUCC-bag\\Textures\\marble',
		edgeFile = 'Interface\\AddOns\\SUCC-bag\\Textures\\BagFrame',
		tile = true,
		tileSize = 128,
		edgeSize = 32,
		insets = {
			left = 5,
			right = 5,
			top = 22,
			bottom = 5
		},
	})
	frame:SetBackdropBorderColor(unpack(SUCC_bagOptions.colors.border))
	frame:SetBackdropColor(unpack(SUCC_bagOptions.colors.backdrop))
	frame:Hide()
	tinsert(UISpecialFrames, t)
	frame.closeButton = CreateFrame('Button', t .. 'CloseButton', frame, 'UIPanelCloseButton')
	frame.closeButton:SetPoint('TOPRIGHT', frame, 4, 4)
	frame.closeButton:SetScript('OnClick', function() SBFrameClose(frame) end)
	frame.title = frame:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
	frame.title:SetPoint('TOPLEFT', frame, 11, -6)
	frame.title.t = string.sub(t, 9, -1)
	frame.title:SetText(frame.title.t ~= '' and frame.title.t ~= nil and frame.title.t or 'Bag')
	if frame.slotFrame then
		SlotFrameSetup(frame)
		frame.toggleButton = CreateFrame('Button', t .. 'ToggleButton', frame)
		frame.toggleButton:SetHeight(12)
		frame.toggleButton:SetWidth(12)
		frame.toggleButton:SetPoint('TOPLEFT', 10, -6)
		frame.toggleButton:SetNormalTexture('Interface\\QuestFrame\\UI-Quest-BulletPoint')
		frame.toggleButton:SetHighlightTexture('Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight')
		frame.toggleButton:SetPushedTexture('Interface\\QuestFrame\\UI-Quest-BulletPoint')
		frame.toggleButton:GetNormalTexture():SetTexCoord(0.25, 0.75, 0.25, 0.75)
		frame.toggleButton:RegisterForClicks('LeftButtonUp', 'RightButtonUp')
		frame.toggleButton:SetScript('OnClick', function()
			local slotFrame = frame.slotFrame
			if arg1 == 'RightButton' then
				ToggleKeyRing()
			else
				if slotFrame:IsVisible() then
					slotFrame:Hide()
				else
					slotFrame:Show()
				end
			end
		end)
		frame.toggleButton:SetScript('OnEnter', function()
			GameTooltip:SetOwner(this, 'ANCHOR_LEFT')
			GameTooltip:AddLine('Left Click: Open bags', 1, 1, 1)
			GameTooltip:AddLine('Right Click: Open keyring' , 0.3, 0.8, 1)
			GameTooltip:Show()
		end)
		frame.toggleButton:SetScript('OnLeave', function() GameTooltip:Hide() end)
		if Clean_Up then
			frame.cuBag = CreateFrame('Button', t .. 'CU_button', frame)
			frame.cuBag:SetHeight(12)
			frame.cuBag:SetWidth(12)
			frame.cuBag:SetNormalTexture('Interface\\QuestFrame\\UI-Quest-BulletPoint')
			frame.cuBag:SetHighlightTexture('Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight')
			frame.cuBag:SetPushedTexture('Interface\\QuestFrame\\UI-Quest-BulletPoint')
			frame.cuBag:GetNormalTexture():SetVertexColor(0.1, 1, 0.3)
			frame.cuBag:GetNormalTexture():SetTexCoord(0.25, 0.75, 0.25, 0.75)
			frame.cuBag:RegisterForClicks('LeftButtonUp', 'RightButtonUp')
			frame.cuBag:SetScript('OnClick', function()
				local c = frame.title.t ~= '' and frame.title.t ~= nil and string.lower(frame.title.t) or 'bags'
				if arg1 == 'RightButton' then
					Clean_Up(c, 1)
				else
					Clean_Up(c)
				end
			end)
			frame.cuBag:SetScript('OnEnter', function()
				GameTooltip:SetOwner(this, 'ANCHOR_LEFT')
				GameTooltip:AddLine('Left Click: Sort', 1, 1, 1)
				GameTooltip:AddLine('Right Click: Reverse order' , 0.3, 0.8, 1)
				GameTooltip:Show()
			end)
			frame.cuBag:SetScript('OnLeave', function() GameTooltip:Hide() end)
		end
		frame.slotFrame:SetScript('OnHide', function() frame.toggleButton:GetNormalTexture():SetVertexColor(1, 1, 1) end)
		frame.slotFrame:SetScript('OnShow', function() frame.toggleButton:GetNormalTexture():SetVertexColor(1, 0, 0) end)
		TitleLayout(frame)
		frame.moneyFrame = CreateFrame('Frame', t .. 'MoneyFrame', frame, 'SmallMoneyFrameTemplate')
		frame.moneyFrame:SetPoint('RIGHT', frame.closeButton, 'LEFT', 12, 0)
	end
end

local function BankUpdateBagSlotStatus()
	local slots, full = GetNumBankSlots()
	for i=1, NUM_BANKBAGSLOTS, 1 do
		local button = getglobal('SUCC_bagBBag'..i)
		local tooltipText
		if ( button ) then
			if ( i <= slots ) then
				SetItemButtonTextureVertexColor(button, 1.0,1.0,1.0)
				button.tooltipText = BANK_BAG
				button.buy = nil
			else
				SetItemButtonTextureVertexColor(button, 1.0,0.1,0.1)
				button.tooltipText = BANK_BAG_PURCHASE
				button.buy = 1
			end
		end
	end
	if(full) then
		SUCC_bag.bank.slotCost:Hide()
		return
	end
	local cost = GetBankSlotCost(numSlots)
	SUCC_bag.bank.nextSlotCost = cost
	if( GetMoney() >= cost ) then
		SetMoneyFrameColor('SUCC_bagBDetailMoneyFrame', 1.0, 1.0, 1.0)
	else
		SetMoneyFrameColor('SUCC_bagBDetailMoneyFrame', 1.0, 0.1, 0.1)
	end
	MoneyFrame_Update('SUCC_bagBDetailMoneyFrame', cost)
end

local function PrepareBank(frame)
	if frame.bank then return frame.bank end
	frame.bank = CreateFrame('Frame', 'SUCC_bagBank', UIParent)
	frame.bank:SetPoint('TOPLEFT', 53, -116)
	frame.bank.layout = SUCC_bagOptions.layout.bank.type
	frame.bank.bags = frame.bank.layout == 1 and {-1, 5, 6, 7, 8, 9, 10} or {-1}
	frame.bank.slotFrame = CreateFrame('Frame', 'SUCC_bagBankSlotFrame', frame.bank)
	frame.bank.slotFrame.slot = {}
	for i = 1, NUM_BANKBAGSLOTS, 1 do
		frame.bank.slotFrame.slot[i] = CreateFrame('CheckButton', 'SUCC_bagBBag' .. i, frame.bank.slotFrame, 'BankItemButtonBagTemplate')
		frame.bank.slotFrame.slot[i]:SetID(i + 4)
		frame.bank.slotFrame.slot[i]:SetNormalTexture('Interface\\AddOns\\SUCC-bag\\Textures\\Slot')
		frame.bank.slotFrame.slot[i]:SetCheckedTexture('Interface\\Buttons\\CheckButtonHilight')
		frame.bank.slotFrame.slot[i]:SetScript('OnClick', function()
			if this.buy then
				this:SetChecked(not this:GetChecked())	-- slot name issue
				PlaySound('igMainMenuOption')
				StaticPopup_Show('CONFIRM_BUY_SUCCBANK_SLOT')
				return
			end
			if not CursorHasItem() then
				if ( IsShiftKeyDown() ) then
					PickupBagFromSlot(this:GetInventorySlot())
					this:SetChecked(not this:GetChecked())	-- slot name issue
				else
					if not this:GetChecked() then
						HighlightBagSlots(this:GetID())
					else
						HighlightBagSlots(this:GetID(), 'highlight')
					end
					PlaySound('BAGMENUBUTTONPRESS')
				end
			else
				this:SetChecked(not this:GetChecked())
				PutItemInBag(this:GetInventorySlot())
			end
		end)
		frame.bank.slotFrame.slot[i]:SetScript('OnReceiveDrag', function()
			PutItemInBag(this:GetInventorySlot())
		end)
		frame.bank.slotFrame.slot[i]:SetScript('OnEnter', function()
			HighlightBagSlots(this:GetID(), 'highlight')
			GameTooltip:SetOwner(this, 'ANCHOR_RIGHT')
			if ( not GameTooltip:SetInventoryItem('player', this:GetInventorySlot()) ) then
					GameTooltip:SetText(this.tooltipText)
			end
			CursorUpdate()
		end)
		frame.bank.slotFrame.slot[i]:SetScript('OnLeave', function()
			if not this:GetChecked() then
				HighlightBagSlots(this:GetID())
			end
			GameTooltip:Hide()
			ResetCursor()
		end)
	end
	frame.bank.slotCost = CreateFrame('Frame', 'SUCC_bagBDetailMoneyFrame', frame.bank.slotFrame, 'SmallMoneyFrameTemplate')
	frame.bank.slotCost.info = {
		UpdateFunc = function()
			return frame.bank.slotCost.staticMoney
		end,
		collapse = 1,
	}
	frame.bank.slotCost.moneyType = 'STATIC'
	frame.bank.slotCost.small = 1
	getglobal('SUCC_bagBDetailMoneyFrameGoldButton'):EnableMouse(false)
	getglobal('SUCC_bagBDetailMoneyFrameSilverButton'):EnableMouse(false)
	getglobal('SUCC_bagBDetailMoneyFrameCopperButton'):EnableMouse(false)
	MoneyFrame_Update('SUCC_bagBDetailMoneyFrame', frame.bank.slotCost.info.UpdateFunc())
	StaticPopupDialogs['CONFIRM_BUY_SUCCBANK_SLOT'] = {
		text = TEXT(CONFIRM_BUY_BANK_SLOT),
		button1 = TEXT(YES),
		button2 = TEXT(NO),
		OnAccept = function()
			PurchaseSlot()
		end,
		OnShow = function()
			MoneyFrame_Update(this:GetName()..'MoneyFrame', frame.bank.nextSlotCost)
		end,
		hasMoneyFrame = 1,
		timeout = 0,
		hideOnEscape = 1,
	}
	Essentials(frame.bank)
	frame.bank:SetScript('OnHide', function()
		CloseBankFrame()
		PlaySound('igMainMenuClose')
	end)
	return frame.bank
end

local function OnEvent()
	if event == 'BAG_UPDATE' or event == 'BAG_UPDATE_COOLDOWN' then
		if dummyBag[arg1] then
			FrameUpdate(dummyBag[arg1]:GetParent(), arg1)
		end
	elseif event == 'BAG_CLOSED' then
		if dummyBag[arg1] then
			dummyBag.removed = arg1
			dummyBag[arg1].size = 0
			local parent = dummyBag[arg1]:GetParent()
			if parent:IsVisible() then
				FrameGenerate(parent)
			end
		end
	elseif event == 'ITEM_LOCK_CHANGED' then
		if this:IsVisible() then
			FrameUpdateLock(this)
		end
	elseif event == 'BANKFRAME_OPENED' then
		this:RegisterEvent('PLAYERBANKSLOTS_CHANGED')
		this:RegisterEvent('PLAYER_MONEY')
		SBFrameOpen(this, 1)
		SBFrameOpen(this.bank)
		BankUpdateBagSlotStatus()
	elseif event == 'BANKFRAME_CLOSED' then
		this:UnregisterEvent('PLAYERBANKSLOTS_CHANGED')
		this:UnregisterEvent('PLAYER_MONEY')
		SBFrameClose(this, 1)
		SBFrameClose(SUCC_bag.bank)
	elseif event == 'PLAYERBANKSLOTS_CHANGED' then
		FrameUpdate(SUCC_bag.bank, -1)
	elseif ( event == 'PLAYER_MONEY' or event == 'PLAYERBANKBAGSLOTS_CHANGED' ) then
		BankUpdateBagSlotStatus()
	elseif event == 'ADDON_LOADED' and arg1 == 'SUCC-bag' then
		SUCC_bagOptions = SUCC_bagOptions or SUCC_bagDefaults()
		this:UnregisterEvent('ADDON_LOADED')
		BankFrame:UnregisterEvent('BANKFRAME_OPENED')
		this:RegisterEvent('BAG_CLOSED')
		this:RegisterEvent('BAG_UPDATE')
		this:RegisterEvent('ITEM_LOCK_CHANGED')
		this:RegisterEvent('BAG_UPDATE_COOLDOWN')
		this:RegisterEvent('CURSOR_UPDATE')
		this:RegisterEvent('BANKFRAME_OPENED')
		this:RegisterEvent('BANKFRAME_CLOSED')
		this.layout = SUCC_bagOptions.layout.bag.type
		this.bags = this.layout == 1 and {0, 1, 2, 3, 4} or {0}
		Essentials(this)
		Essentials(this.keyring)
		PrepareBank(this)
		ToggleBag = function() SBFrameToggle(SUCC_bag) end
		ToggleBackpack = ToggleBag
		OpenAllBags = ToggleBag
		OpenBag = function() SBFrameOpen(SUCC_bag) end
		OpenBackpack = OpenBag
		CloseBag = function() SBFrameClose(SUCC_bag) end
		CloseBackpack = CloseBag
		CloseAllBags = function() SBFrameClose(SUCC_bag) end
		ToggleKeyRing = function() SBFrameToggle(SUCC_bag.keyring) end
		-- configuration
		SLASH_SUCC_BAG1 = '/succbag'
		print('|cFFF6A3EFSUCC-bag loaded. /succbag - configuration')
	end
end

SUCC_bag = CreateFrame('Frame', 'SUCC_bag', UIParent)
SUCC_bag:SetPoint('BOTTOMRIGHT', UIParent, -55, 55)
SUCC_bag:RegisterEvent('ADDON_LOADED')
SUCC_bag:SetScript('OnEvent', OnEvent)
SUCC_bag.slotFrame = CreateFrame('Frame', 'SUCC_bagSlotFrame', SUCC_bag)
SUCC_bag.slotFrame.slot = {}
for i = 1, NUM_BAG_SLOTS, 1 do
	SUCC_bag.slotFrame.slot[i] = CreateFrame('CheckButton', 'SUCC_bagIBag' .. i - 1 ..'Slot', SUCC_bag.slotFrame, 'BagSlotButtonTemplate')
	SUCC_bag.slotFrame.slot[i]:SetNormalTexture('Interface\\AddOns\\SUCC-bag\\Textures\\Slot')
	SUCC_bag.slotFrame.slot[i]:SetScript('OnClick', function()
		local bagID = this:GetID()
		if not CursorHasItem() then
			if ( IsShiftKeyDown() ) then
				BagSlotButton_OnDrag()
			else
				PlaySound('BAGMENUBUTTONPRESS')
				if not this:GetChecked() then
					HighlightBagSlots(bagID - 19)
				else
					HighlightBagSlots(bagID - 19, 'highlight')
				end
			end
		else
			this:SetChecked(not this:GetChecked())
			PutItemInBag(bagID)
		end
	end)
	SUCC_bag.slotFrame.slot[i]:SetScript('OnEnter', function()
		HighlightBagSlots(this:GetID() - 19, 'highlight')
		BagSlotButton_OnEnter()
	end)
	SUCC_bag.slotFrame.slot[i]:SetScript('OnLeave', function()
		if not this:GetChecked() then
			HighlightBagSlots(this:GetID() - 19)
		end
		GameTooltip:Hide()
		ResetCursor()
	end)
	SUCC_bag.slotFrame.slot[i]:SetScript('OnReceiveDrag', function()
		PutItemInBag(this:GetID())
	end)
end

SUCC_bag.keyring = CreateFrame('Frame', 'SUCC_bagKeyring', UIParent)
SUCC_bag.keyring:SetPoint('BOTTOMRIGHT', UIParent, -55, 55)
SUCC_bag.keyring.bags = {-2}
SUCC_bag.keyring:SetScript('OnShow', function()
	if SUCC_bag:IsVisible() then
		this:ClearAllPoints()
		this:SetPoint('BOTTOMLEFT', SUCC_bag, 'TOPLEFT', 0, 0)
	end
	PlaySound('KeyRingOpen')
end)

-- overrides
function SBFrameOpen(frame, automatic)
	FrameGenerate(frame)
	if frame and not automatic then
		frame.manOpened = 1
	end
end

function SBFrameClose(frame, automatic)
	if not(automatic and frame.manOpened) then
		frame:Hide()
		frame.manOpened = nil
	end
end

function SBFrameToggle(frame)
	if frame:IsVisible() then
		SBFrameClose(frame)
	else
		SBFrameOpen(frame)
	end
end


-- configuration

local menu

local function SlidersState(frame, disable)
	local frameName = frame:GetName()
	local thumb = getglobal(frameName .. 'Thumb')
	local string = getglobal(frameName .. 'Text')
	local low = getglobal(frameName .. 'Low')
	local high = getglobal(frameName .. 'High')
	if disable == 1 then
		thumb:Hide()
		string:SetVertexColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b)
		low:SetVertexColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b)
		high:SetVertexColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b)
		frame:EnableMouse(false)
	else
		thumb:Show()
		string:SetVertexColor(NORMAL_FONT_COLOR.r , NORMAL_FONT_COLOR.g , NORMAL_FONT_COLOR.b)
		low:SetVertexColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
		high:SetVertexColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
		frame:EnableMouse()
	end
end

local function SetLayout()
	local l, n = this:GetValue(), this:GetName()
	local typeString = string.sub(n, 1, -7)
	SUCC_bagOptions.layout[typeString].type = l
	SlidersState(menu[typeString].columns, l)
end

local function SetColumns()
	local l, n = this:GetValue(), string.sub(this:GetName(), 5, -8)
	SUCC_bagOptions.layout[n].columns = l
	if n == 'bag' then FrameLayout(SUCC_bag) else FrameLayout(SUCC_bag.bank) end
end

local function SetColor()
	local r, g, b = ColorPickerFrame:GetColorRGB()
	ColorPickerFrame.frame.swatch:SetVertexColor(r, g, b)
	ColorPickerFrame.frame.func(r, g, b)
end

local function ResetColor(reset)
	local r, g, b = unpack(reset)
	ColorPickerFrame.frame.swatch:SetVertexColor(r, g, b)
	ColorPickerFrame.frame.func(r, g, b)
end

local function ColorPicker(frame, reset)
	ColorPickerFrame:ClearAllPoints()
	ColorPickerFrame:SetPoint('LEFT', menu, 'RIGHT')
	ColorPickerFrame:SetToplevel()
	ColorPickerFrame.frame = frame
	ColorPickerFrame.func = SetColor
	ColorPickerFrame.cancelFunc = ResetColor
	ColorPickerFrame:SetColorRGB(unpack(reset))
	ColorPickerFrame.previousValues = reset
	ShowUIPanel(ColorPickerFrame)
end

local function CreateMenuFrame()
	local function color(n, l, c, r, a)
		local k = CreateFrame('Button', n, menu)
		k:SetWidth(90)
		k:SetHeight(16)
		if r then k:SetPoint(a and 'TOP' or 'LEFT', r, a and 'BOTTOM' or 'RIGHT', a and 0 or 20, 0) end
		k.t = k:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
		k.t:SetPoint('Left', k)
		k.t:SetText(l .. ':')
		k.swatch = k:CreateTexture(k:GetName() .. 'SwatchBg', 'BACKGROUND')
		k.swatch:SetTexture('Interface\\ChatFrame\\ChatFrameColorSwatch')
		k.swatch:SetPoint('RIGHT', k)
		k.swatch:SetWidth(16)
		k.swatch:SetHeight(16)
		k.swatch:SetVertexColor(unpack(c))
		k:SetScript('OnClick', function() ColorPicker(this, c) end)
		return k
	end

	local function slider(n, l, s, v, r, a)
		local k = CreateFrame('Slider', n, menu, 'OptionsSliderTemplate')
		k:SetWidth(90)
		k:SetHeight(20)
		if r then k:SetPoint(a and 'TOP' or 'LEFT', r, a and 'BOTTOM' or 'RIGHT', a and 0 or 20, a and -25 or 0) end
		k:SetMinMaxValues(unpack(s))
		k:SetValue(v[1])
		k:SetValueStep(v[2])
		getglobal(n .. 'Text'):SetText(l[1])
		getglobal(n .. 'Low'):SetText(l[2])
		getglobal(n .. 'High'):SetText(l[3])
		return k
	end

	menu = CreateFrame('Frame', 'SUCC_bagMenu', UIParent)
	menu:SetWidth(270) menu:SetHeight(320)
	menu:SetPoint('CENTER', UIParent)
	menu:SetBackdrop(
		{
			bgFile   = 'Interface\\Tooltips\\UI-Tooltip-Background',
			edgeFile = 'Interface\\DialogFrame\\UI-DialogBox-Border',
			insets   = {left = 11, right = 12, top = 12, bottom = 11},
		}
	)
	menu:SetBackdropColor(0, 0, 0, .7)
	menu:SetToplevel()
	menu:SetMovable()
	menu:SetUserPlaced(false)
	menu:RegisterForDrag('LeftButton')
	menu:EnableMouse()
	menu:SetScript('OnDragStart', function() menu:StartMoving() end)
	menu:SetScript('OnDragStop', function() menu:StopMovingOrSizing() end)
	menu:Hide()
	tinsert(UISpecialFrames, 'SUCC_bagMenu')

	menu.header = menu:CreateTexture(nil, 'ARTWORK')
	menu.header:SetWidth(256) menu.header:SetHeight(64)
	menu.header:SetPoint('TOP', menu, 0, 12)
	menu.header:SetTexture('Interface\\DialogFrame\\UI-DialogBox-Header')
	menu.header.t = menu:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
	menu.header.t:SetPoint('TOP', menu.header, 0, -14)
	menu.header.t:SetText('SUCC-bag options')

	menu.bag = {}
	menu.bank = {}

	menu.bag.layout = slider('SBC_bagLayout', {'Bag layout', 'SUCC', 'jnt'}, {0, 1}, {SUCC_bagOptions.layout.bag.type, 1})
	menu.bag.layout:SetPoint('TOPLEFT', menu, 35, -45)
	menu.bag.layout:SetScript('OnValueChanged', SetLayout)

	menu.bank.layout = slider('SBC_bankLayout', {'Bank layout', 'SUCC', 'jnt'}, {0, 1}, {SUCC_bagOptions.layout.bank.type, 1}, menu.bag.layout)
	menu.bank.layout:SetScript('OnValueChanged', SetLayout)

-- until next update
	SlidersState(menu.bag.layout, 1)
	SlidersState(menu.bank.layout, 1)
-- end

	menu.bag.columns = slider('SBC_bagColumns', {'Bag Columns', '4', '32'}, {4, 32}, {SUCC_bagOptions.layout.bag.columns, 1}, menu.bag.layout, 1)
	menu.bag.columns:SetScript('OnValueChanged', SetColumns)
	-- SlidersState(menu.bag.columns, SUCC_bagOptions.layout.bag.type)

	menu.bank.columns = slider('SBC_bankColumns', {'Bank Columns', '4', '32'}, {4, 32}, {SUCC_bagOptions.layout.bank.columns, 1}, menu.bag.columns)
	menu.bank.columns:SetScript('OnValueChanged', SetColumns)
	-- SlidersState(menu.bank.columns, SUCC_bagOptions.layout.bank.type)

	menu.spacing = slider('SBC_itemSpacing', {'Item spacing', '0', '20'}, {0, 20}, {SUCC_bagOptions.layout.spacing, 1}, menu.bag.columns, 1)
	menu.spacing:SetScript('OnValueChanged', function()
		local l, n = this:GetValue(), string.sub(this:GetName(), 1, -8)
		SUCC_bagOptions.layout.spacing = l
		if SUCC_bag:IsVisible() then FrameLayout(SUCC_bag) end
		if SUCC_bag.bank:IsVisible() then FrameLayout(SUCC_bag.bank) end
		if SUCC_bag.keyring:IsVisible() then FrameLayout(SUCC_bag.keyring) end
	end)

	menu.border = color('SBC_borderColor', 'Border', SUCC_bagOptions.colors.border)
	menu.border:SetPoint('TOP', menu.spacing, 'BOTTOM', 0, -25)
	menu.border.func = function(r, g, b)
		SUCC_bagOptions.colors.border = {r, g, b}
		SUCC_bag:SetBackdropBorderColor(r, g, b)
		SUCC_bag.bank:SetBackdropBorderColor(r, g, b)
		SUCC_bag.keyring:SetBackdropBorderColor(r, g, b)
		SUCC_bag.slotFrame:SetBackdropBorderColor(r, g, b)
		SUCC_bag.bank.slotFrame:SetBackdropBorderColor(r, g, b)
	end

	menu.backdrop  = color('SBC_backdropColor', 'Backdrop', SUCC_bagOptions.colors.backdrop, menu.border)
	menu.backdrop.func = function(r, g, b)
		SUCC_bagOptions.colors.backdrop = {r, g, b}
		SUCC_bag:SetBackdropColor(r, g, b)
		SUCC_bag.bank:SetBackdropColor(r, g, b)
		SUCC_bag.keyring:SetBackdropColor(r, g, b)
		SUCC_bag.slotFrame:SetBackdropColor(r, g, b)
		SUCC_bag.bank.slotFrame:SetBackdropColor(r, g, b)
	end

	menu.item = color('SBC_itemColor', 'Item border', SUCC_bagOptions.colors.bag.Bag, menu.border, 1)
	menu.item.func = function(r, g, b)
		SUCC_bagOptions.colors.bag.Bag = {r, g, b}
		if SUCC_bag:IsVisible() then FrameUpdate(SUCC_bag) end
		if SUCC_bag.bank:IsVisible() then FrameUpdate(SUCC_bag.bank) end
		if SUCC_bag.keyring:IsVisible() then FrameUpdate(SUCC_bag.keyring) end
	end

	menu.quest = color('SBC_questColor', 'Quest item', SUCC_bagOptions.colors.quest, menu.item)
	menu.quest.func = function(r, g, b)
		SUCC_bagOptions.colors.quest = {r, g, b}
		if SUCC_bag:IsVisible() then FrameUpdate(SUCC_bag) end
		if SUCC_bag.bank:IsVisible() then FrameUpdate(SUCC_bag.bank) end
	end

	menu.highlight = color('SBC_highlightColor', 'Highlight', SUCC_bagOptions.colors.highlight, menu.item, 1)
	menu.highlight.func = function(r, g, b)
		SUCC_bagOptions.colors.highlight = {r, g, b}
		if SUCC_bag:IsVisible() then FrameUpdate(SUCC_bag) end
		if SUCC_bag.bank:IsVisible() then FrameUpdate(SUCC_bag.bank) end
	end

	menu.ammo = color('SBC_ammoColor', 'Ammo bag', SUCC_bagOptions.colors.ammo, menu.highlight)
	menu.ammo.func = function(r, g, b)
		SUCC_bagOptions.colors.ammo = {r, g, b}
		if SUCC_bag:IsVisible() then FrameUpdate(SUCC_bag) end
		if SUCC_bag.bank:IsVisible() then FrameUpdate(SUCC_bag.bank) end
	end

	menu.soul = color('SBC_soulColor', 'Soul bag', SUCC_bagOptions.colors.bag['Soul Bag'], menu.highlight, 1)
	menu.soul.func = function(r, g, b)
		SUCC_bagOptions.colors.bag['Soul Bag'] = {r, g, b}
		if SUCC_bag:IsVisible() then FrameUpdate(SUCC_bag) end
		if SUCC_bag.bank:IsVisible() then FrameUpdate(SUCC_bag.bank) end
	end

	menu.herb = color('SBC_herbColor', 'Herb bag', SUCC_bagOptions.colors.bag['Herb Bag'], menu.soul)
	menu.herb.func = function(r, g, b)
		SUCC_bagOptions.colors.bag['Herb Bag'] = {r, g, b}
		if SUCC_bag:IsVisible() then FrameUpdate(SUCC_bag) end
		if SUCC_bag.bank:IsVisible() then FrameUpdate(SUCC_bag.bank) end
	end

	menu.enchanting = color('SBC_enchantingColor', 'Enchanting', SUCC_bagOptions.colors.bag['Enchanting Bag'], menu.soul, 1)
	menu.enchanting.func = function(r, g, b)
		SUCC_bagOptions.colors.bag['Enchanting Bag'] = {r, g, b}
		if SUCC_bag:IsVisible() then FrameUpdate(SUCC_bag) end
		if SUCC_bag.bank:IsVisible() then FrameUpdate(SUCC_bag.bank) end
	end

	menu.bg = color('SBC_BGColor', 'BG marks', SUCC_bagOptions.colors.BG, menu.enchanting)
	menu.bg.func = function(r, g, b)
		SUCC_bagOptions.colors.BG = {r, g, b}
		if SUCC_bag:IsVisible() then FrameUpdate(SUCC_bag) end
		if SUCC_bag.bank:IsVisible() then FrameUpdate(SUCC_bag.bank) end
	end

	if Clean_Up then
		menu.cleanup = CreateFrame('CheckButton', 'SBC_cleanUp', menu, 'UICheckButtonTemplate')
		menu.cleanup:SetHeight(25)
		menu.cleanup:SetWidth(25)
		menu.cleanup:SetPoint('TOPRIGHT', menu.bank.columns, 'BOTTOMRIGHT', 0, -22)
		menu.cleanup:SetChecked(SUCC_bagOptions.Clean_Up)
		menu.cleanup:SetScript('OnClick', function()
			if this:GetChecked() == 1 then
				SUCC_bagOptions.Clean_Up = 1
			else
				SUCC_bagOptions.Clean_Up = nil
			end
			TitleLayout(SUCC_bag)
			TitleLayout(SUCC_bag.bank)
		end)
		menu.cleanup.t = menu.cleanup:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
		menu.cleanup.t:SetPoint('RIGHT', menu.cleanup, 'LEFT', 10, 0)
		menu.cleanup.t:SetWidth(90)
		menu.cleanup.t:SetText('Clean_Up button:')
	end

	menu.close = CreateFrame('Button', nil, menu, 'UIPanelButtonTemplate')
	menu.close:SetWidth(100) menu.close:SetHeight(25)
	menu.close:SetText('Close')
	menu.close:SetPoint('BOTTOMRIGHT', menu, -25, 20)
	menu.close:SetScript('OnClick', function() menu:Hide() end)

	menu.reset = CreateFrame('Button', nil, menu, 'UIPanelButtonTemplate')
	menu.reset:SetWidth(100) menu.reset:SetHeight(25)
	menu.reset:SetText('Reset')
	menu.reset:SetPoint('BOTTOMLEFT', menu, 25, 20)
	menu.reset:SetScript('OnClick', function()
		SUCC_bagOptions = SUCC_bagDefaults()
		menu.border.func(unpack(SUCC_bagOptions.colors.border))
		menu.backdrop.func(unpack(SUCC_bagOptions.colors.backdrop))
		menu.bag.layout:SetValue(SUCC_bagOptions.layout.bag.type)
		menu.bank.layout:SetValue(SUCC_bagOptions.layout.bank.type)
		menu.bag.columns:SetValue(SUCC_bagOptions.layout.bag.columns)
		menu.bank.columns:SetValue(SUCC_bagOptions.layout.bank.columns)
		menu.spacing:SetValue(SUCC_bagOptions.layout.spacing)
		if SUCC_bag:IsVisible() then FrameGenerate(SUCC_bag) end
		if SUCC_bag.bank:IsVisible() then FrameGenerate(SUCC_bag.bank) end
		if SUCC_bag.keyring:IsVisible() then FrameGenerate(SUCC_bag.keyring) end
	end)
end

SlashCmdList['SUCC_BAG'] = function()
	if not menu then CreateMenuFrame() end
	if menu:IsShown() then menu:Hide() else menu:Show() end
end
