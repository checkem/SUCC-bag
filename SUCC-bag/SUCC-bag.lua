local bagCols, bagSpacing = 8, 4

-- debug
local function print(mes)
	DEFAULT_CHAT_FRAME:AddMessage(mes)
end

local function SetMoneyFrameColor(frameName, r, g, b)
	local goldButton = getglobal(frameName.."GoldButton");
	local silverButton = getglobal(frameName.."SilverButton");
	local copperButton = getglobal(frameName.."CopperButton");

	goldButton:SetTextColor(r, g, b);
	silverButton:SetTextColor(r, g, b);
	copperButton:SetTextColor(r, g, b);
end

local function BagType (bagID)
	if( bagID <= 0 ) then return nil end
	local id;
	local link = GetInventoryItemLink("player", ContainerIDToInventoryID(bagID) )
	if(link) then
		_, _, id = string.find(link, "item:(%d+)")
	end
	if(id) then
		local _, _, _, _, itemType, subType = GetItemInfo(id)
		if itemType == 'Quiver' or subType == 'Soul Bag' then
			return 1
		elseif  itemType == 'Container' and not (subType == 'Bag' or subType == 'Soul Bag') then
			return 2
		else
			return nil
		end
	end
	return nil
end

local function BankUpdateBagSlotStatus()
	local slots,full = GetNumBankSlots()
	for i=1, NUM_BANKBAGSLOTS, 1 do
		local button = getglobal("SUCC_bagBBag"..i);
		local tooltipText;
		if ( button ) then
			if ( i <= slots ) then
				SetItemButtonTextureVertexColor(button, 1.0,1.0,1.0);
				button.tooltipText = BANK_BAG;
			else
				SetItemButtonTextureVertexColor(button, 1.0,0.1,0.1);
				button.tooltipText = BANK_BAG_PURCHASE;
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
		SetMoneyFrameColor("SUCC_bagBDetailMoneyFrame", 1.0, 1.0, 1.0);
	else
		SetMoneyFrameColor("SUCC_bagBDetailMoneyFrame", 1.0, 0.1, 0.1)
	end
	MoneyFrame_Update('SUCC_bagBDetailMoneyFrame', cost)
end

local function ItemCreate(name, parent)
	local button
	if parent:GetID() == -1 then
		button = CreateFrame("Button", name, parent, 'BankItemButtonGenericTemplate')
		CreateFrame('Model', name .. 'Cooldown', button, 'CooldownFrameTemplate')
	else
		button = CreateFrame("Button", name, parent, 'ContainerFrameItemButtonTemplate');
	end
	button:SetNormalTexture('Interface\\AddOns\\SUCC-bag\\Textures\\Slot')
	button.bg = button:CreateTexture(nil, 'BACKGROUND')
	button.bg:SetTexture[[Interface\PaperDoll\UI-Backpack-EmptySlot]]
	button.bg:SetAlpha(.75)
	button.bg:SetAllPoints()
	button:SetAlpha(parent:GetParent():GetAlpha());
	button:RegisterForClicks("LeftButtonUp", "RightButtonUp");
	button:RegisterForDrag("LeftButton");
	return button;
end

local function ItemUpdateBorder(button, option)
	local color = {r = 1, g = 1, b = 1}
	if option then
		button:GetNormalTexture():SetVertexColor(1, 0, 0)
	elseif not button:GetParent().colorLocked then
		local bagID = button:GetParent():GetID()
		local link = GetContainerItemLink(bagID, button:GetID())
		local q
		if link then
			local _, _, istring         = string.find(link, '|H(.+)|h')
			_, _, q, _, _, type   = GetItemInfo(istring)
		end
		if q and q > 1 then
			button:GetNormalTexture():SetVertexColor(GetItemQualityColor(q))
		else
			local bagType = BagType(bagID)
			if bagType == 1 then
				button:GetNormalTexture():SetVertexColor(1, 1, 0)
			elseif bagType == 2 then
				button:GetNormalTexture():SetVertexColor(0, 1, 0)
			else
				button:GetNormalTexture():SetVertexColor(0.3, 0.3, 0.3)
			end
		end
	end
end

local function HighlightBagSlots(bagID, option)
	local frame = getglobal('SUCC_bagDummyBag' .. bagID) or getglobal('SUCC_bagBankBagFrameDummyBag' .. bagID)
	if frame then
		local items = {frame:GetChildren()}
		if option then frame.colorLocked = 1 else  frame.colorLocked = nil end
		for _, item in pairs(items) do
			ItemUpdateBorder(item, option)
		end
	end
end

local function ItemUpdateCooldown(container, button)
	local cooldown = getglobal(button:GetName().."Cooldown")
	local start, duration, enable = GetContainerItemCooldown( container, button:GetID() )
	CooldownFrame_SetTimer(cooldown, start, duration, enable)
	if ( duration > 0 and enable == 0 ) then
		SetItemButtonTextureVertexColor(button, 0.4, 0.4, 0.4)
	end
end

local function ItemUpdate(item)
	local texture, itemCount, readable, locked
	texture, itemCount, locked, _, readable = GetContainerItemInfo(item:GetParent():GetID(), item:GetID())
	ItemUpdateBorder(item)
	if texture then
		ItemUpdateCooldown(item:GetParent():GetID() , item)
	else
		getglobal(item:GetName() .. "Cooldown"):Hide()
	end
	SetItemButtonDesaturated(item, locked, 0.5, 0.5, 0.5)
	SetItemButtonTexture( item, texture )
	SetItemButtonCount( item, itemCount )
end

local dummyBag = {}

local function CreateDummyBag(parent, bagID)
	local dummyBag = CreateFrame("Frame", parent:GetName() .. "DummyBag" .. bagID, parent)
	dummyBag:SetID(bagID)
	return dummyBag
end

local function AddBag(frame, bagID)
	if not dummyBag[bagID] then
		dummyBag[bagID] = CreateDummyBag(frame, bagID)
	end
	
	if dummyBag.removed == bagID then dummyBag.removed = nil return end
	local frameName = frame:GetName();
	local slot = frame.size;
	local bagSize;

	if(bagID == KEYRING_CONTAINER) then
		bagSize = GetKeyRingSize()
	else
		bagSize = GetContainerNumSlots(bagID)
	end
	dummyBag[bagID].size = bagSize
	for index = 1, bagSize, 1 do
		slot = slot + 1;
		local item = getglobal( frameName .. "Item".. slot) or ItemCreate(frameName .. "Item".. slot, dummyBag[bagID]);
		item:SetID(index);
		item:SetParent(dummyBag[bagID]);
		item:Show();
		ItemUpdate(item);
		if frame == SUCC_bag.bank.bagFrame and SUCC_bag.bank.slot[bagID - 4]:GetChecked() then
			HighlightBagSlots(bagID, 'highlight')
		end
	end
	frame.size = frame.size + bagSize;
end

local function FrameTrimToSize(frame)
	if not frame.space then return end
	local frameName = frame:GetName()
	local slot, height
	if frame.size then
		local slot = frame.size + 1
		local button = getglobal(frameName .. "Item".. slot)

		while button do
			button:Hide()
			slot = slot + 1
			button = getglobal(frameName .. "Item".. slot)
		end
	end
	if not frame.size or frame.size == 0 then
		height = 64
		frame:SetWidth(256)
	else
		if frame.size < frame.cols then
			frame:SetWidth((37 + frame.space) * frame.size + 14 - frame.space)
		else
			frame:SetWidth((37 + frame.space) * frame.cols + 14 - frame.space)
		end
		height = (37 + frame.space) * math.ceil(frame.size / frame.cols)  + 32 - frame.space
		if frameName == 'SUCC_bagBank' then height = height + 83 end
		if frameName == 'SUCC_bagBankBagFrame' then height = (37 + frame.space) * 6 + 14 - frame.space end
	end
	frame:SetHeight(height)
end

local function OrganizeBagSlotFrame(frame, rows)
	if not frame.bagFrame or not frame.bagFrame.slot then return end
	local curCols, curRows, curCol, curRow = 0, 0, 1, 1
	if rows < 2 then
		curCols = 4
		curRows = 1
	elseif rows < 4 then
		curCols = 2
		curRows = 2
	else
		curCols = 1
		curRows = 4
	end
	frame.bagFrame:SetHeight((37 + bagSpacing) * curRows  + 14 - bagSpacing)
	frame.bagFrame:SetWidth((37 + bagSpacing) * curCols + 14 - bagSpacing)
	for i, bagSlot in pairs(frame.bagFrame.slot) do
		bagSlot:ClearAllPoints()
		bagSlot:SetPoint('TOPLEFT', frame.bagFrame, (37 + bagSpacing) * (curCol - 1) + 7, 0 - (37 + bagSpacing) * (curRow - 1) - 9)
		curCol = curCol + 1
		if curCol > curCols then
			curCol, curRow = 1, curRow + 1
		end
	end
end

local function FrameLayout(frame, cols, space)
	if not frame.size then return end
	local frameName = frame:GetName()
	if frameName == 'SUCC_bagBankBagFrame' then
		cols = math.ceil(frame.size / 6)
	elseif not cols then
		cols = bagCols
	end
	if not space then
		space = bagSpacing
	end
	local rows = math.ceil(frame.size / cols)
	local index = 1
	frame.cols = cols
	frame.space = space
	local button = getglobal(frameName .. "Item1")
	if button then
		button:ClearAllPoints()
		if frameName == 'SUCC_bagBankBagFrame' then
			button:SetPoint("TOPLEFT", frame, 8, -6)
		else
			button:SetPoint("TOPLEFT", frame, 9, -25)
		end
		for i = 1, rows, 1 do
			for j = 1, cols, 1 do
				index = index + 1
				button = getglobal(frameName .. "Item" .. index)
				if not button then break end
				button:ClearAllPoints()
				button:SetPoint("LEFT", frameName .. "Item" .. index - 1, "RIGHT", space, 0)
			end
			button = getglobal(frameName .. "Item" .. index)
			if not button then break end
			button:ClearAllPoints()
			button:SetPoint("TOP", frameName .. "Item" .. index - cols, "BOTTOM", 0, -space)
		end
	end
	FrameTrimToSize(frame)
	if frameName == 'SUCC_bag' then
		OrganizeBagSlotFrame(frame, rows)
	end
end

local function FrameGenerate(frame)
	frame.size = 0
	local frameName = frame:GetName()
	if frame.moneyFrame then
		MoneyFrame_Update(frameName .. "MoneyFrame", GetMoney())
	end

	for _, bagID in pairs(frame.bags) do
		AddBag(frame, bagID)
	end

	if frame == SUCC_bag.bank.bagFrame and frame.size == 0 then
		frame:Hide()
		return
	end
	FrameLayout(frame, frame.cols, bagSpacing)
	frame:Show()
end

local function RemoveBag(frame, bagID, bagSize)
	if dummyBag.removed or (dummyBag[bagID] and dummyBag[bagID].size ~= bagSize) then
		FrameGenerate(frame)
		return 1
	else
		return nil
	end
end

local function FrameUpdate(frame, bagID)
	local bagSize = GetContainerNumSlots(bagID)
	if not frame.size or RemoveBag(frame, bagID, bagSize) then return end
	local frameName = frame:GetName()
	local startSlot = 1
	local endSlot
	local bags = frame.bags
	if not bagID then
		endSlot = frame.size
	else
		if bagID == KEYRING_CONTAINER then
			endSlot = GetKeyRingSize()
			frameName = SUCC_bag.keyring:GetName()
		else
			for _, bag in pairs(bags) do
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
		local item = getglobal(frameName .. "Item" .. slot)
		if item then
			ItemUpdate(item)
		end
	end
end

local function FrameUpdateLock(frame)
	if not frame.size then return end
	local frameName = frame:GetName()
	for slot = 1, frame.size do
		local item = getglobal(frameName .. "Item" .. slot)
		local _, _, locked = GetContainerItemInfo(item:GetParent():GetID(), item:GetID())
		SetItemButtonDesaturated(item, locked, 0.5, 0.5, 0.5)
	end
end

local function Load(eventFrame)
	eventFrame:RegisterEvent("BAG_CLOSED")
	eventFrame:RegisterEvent("BAG_UPDATE")
	eventFrame:RegisterEvent("ITEM_LOCK_CHANGED")
	eventFrame:RegisterEvent("BAG_UPDATE_COOLDOWN")
	eventFrame:RegisterEvent("CURSOR_UPDATE")
	eventFrame:RegisterEvent("BANKFRAME_OPENED")
	eventFrame:RegisterEvent("BANKFRAME_CLOSED")
	eventFrame:RegisterEvent("PLAYERBANKBAGSLOTS_CHANGED")
end

local function OnEvent()
	if event == "BAG_UPDATE" or event == "BAG_UPDATE_COOLDOWN" then
		if dummyBag[arg1] then
			FrameUpdate(dummyBag[arg1]:GetParent(), arg1)
		end
	elseif event == 'BAG_CLOSED' then
		if dummyBag[arg1] then
			dummyBag.removed = arg1
			dummyBag[arg1].size = 0
		end
		if arg1 > 4 and SUCC_bag.bank.bagFrame:IsVisible() then
			RemoveBag(SUCC_bag.bank.bagFrame, arg1)
		elseif this:IsVisible() then
			RemoveBag(this, arg1)
		end
	elseif event == "ITEM_LOCK_CHANGED" then
		if this:IsVisible() then
			FrameUpdateLock(this)
		end
	elseif event == 'BANKFRAME_OPENED' then
		OpenBag()
		FrameOpen(SUCC_bag.bank)
		BankUpdateBagSlotStatus()
		this:RegisterEvent("PLAYERBANKSLOTS_CHANGED")
		this:RegisterEvent("PLAYER_MONEY")
	elseif event == 'BANKFRAME_CLOSED' then
		CloseBag()
		FrameClose(SUCC_bag.bank)
		this:UnregisterEvent("PLAYERBANKSLOTS_CHANGED")
		this:UnregisterEvent("PLAYER_MONEY")
	elseif event == 'PLAYERBANKSLOTS_CHANGED' then
		FrameUpdate(SUCC_bag.bank, -1)
	elseif ( event == "PLAYER_MONEY" or event == "PLAYERBANKBAGSLOTS_CHANGED" ) then
		BankUpdateBagSlotStatus()
	elseif event == "ADDON_LOADED" and arg1 == "SUCC-bag" then
		this:UnregisterEvent("ADDON_LOADED")
		BankFrame:UnregisterEvent("BANKFRAME_OPENED")
		Load(this)
	end
end

local function FrameTextures(tFrame)
	local bagBackdrop = {
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
	}
	}
	tFrame:SetBackdrop(bagBackdrop)
	-- close button
	tFrame.closeButton = CreateFrame('Button', tFrame:GetName() .. 'CloseButton', tFrame, 'UIPanelCloseButton')
	tFrame.closeButton:SetPoint('TOPRIGHT', tFrame, 4, 4)
	tFrame.closeButton:SetScript('OnClick', function() tFrame:Hide() end)
end

SUCC_bag = CreateFrame('Frame', 'SUCC_bag', UIParent)
SUCC_bag:Hide()
SUCC_bag:RegisterEvent("ADDON_LOADED")
SUCC_bag:SetScript("OnEvent", OnEvent)
SUCC_bag:SetFrameStrata('MEDIUM')
SUCC_bag:SetToplevel(true)
SUCC_bag:EnableMouse()
SUCC_bag:SetMovable()
SUCC_bag:SetClampedToScreen()
FrameTextures(SUCC_bag)
SUCC_bag:SetPoint('TOPLEFT', UIParent, 'CENTER', -200, 200)
tinsert(UISpecialFrames, 'SUCC_bag')
SUCC_bag:SetScript('OnMouseDown', function() this:StartMoving() end)
SUCC_bag:SetScript('OnMouseUp', function() this:StopMovingOrSizing() end)
SUCC_bag:SetScript('OnShow', function() PlaySound('igBackPackOpen') end)
SUCC_bag:SetScript('OnHide', function() PlaySound('igBackPackClose') SUCC_bag.bagFrame:Hide() end)
SUCC_bag.bags = {0, 1, 2, 3, 4}
SUCC_bag.cols = bagCols

SUCC_bag.moneyFrame = CreateFrame('Frame', 'SUCC_bagMoneyFrame', SUCC_bag, 'SmallMoneyFrameTemplate')
SUCC_bag.moneyFrame:SetHeight(14)
SUCC_bag.moneyFrame:SetWidth(206)
SUCC_bag.moneyFrame:SetPoint('RIGHT', SUCC_bag.closeButton, 'LEFT', 12, 0)

SUCC_bag.bagFrame = CreateFrame('Frame', 'SUCC_bagBagFrame', SUCC_bag)
SUCC_bag.bagFrame:SetFrameLevel(0)
SUCC_bag.bagFrame:SetPoint('TOPRIGHT', SUCC_bag, 'TOPLEFT', 8, -16)
local bfBackdrop = {
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
}
SUCC_bag.bagFrame:SetBackdrop(bfBackdrop)
SUCC_bag.bagFrame:Hide()
SUCC_bag.bagFrame.slot = {}
for i = 1, 4, 1 do
	SUCC_bag.bagFrame.slot[i] = CreateFrame('CheckButton', 'SUCC_bagSBag' .. i - 1 ..'Slot', SUCC_bag.bagFrame, 'BagSlotButtonTemplate')
	SUCC_bag.bagFrame.slot[i]:SetNormalTexture('Interface\\AddOns\\SUCC-bag\\Textures\\Slot')
	SUCC_bag.bagFrame.slot[i]:SetScript('OnClick', function()
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
	SUCC_bag.bagFrame.slot[i]:SetScript('OnEnter', function()
		HighlightBagSlots(this:GetID() - 19, 'highlight')
		BagSlotButton_OnEnter()
	end)
	SUCC_bag.bagFrame.slot[i]:SetScript('OnLeave', function()
		if not this:GetChecked() then
			HighlightBagSlots(this:GetID() - 19)
		end
		GameTooltip:Hide()
		ResetCursor()
	end)
	SUCC_bag.bagFrame.slot[i]:SetScript('OnReceiveDrag', function()
	PutItemInBag(this:GetID())
	end)
end

SUCC_bag.toggleButton = CreateFrame('Button', 'SUCC_bagToggleButton', SUCC_bag)
SUCC_bag.toggleButton:SetHeight(16)
SUCC_bag.toggleButton:SetWidth(16)
SUCC_bag.toggleButton:SetPoint('TOPLEFT', 8, -4)
SUCC_bag.toggleButton:SetNormalTexture('Interface\\GroupFrame\\UI-Group-MasterLooter')
SUCC_bag.toggleButton:SetHighlightTexture('Interface\\GroupFrame\\UI-Group-MasterLooter')
SUCC_bag.toggleButton:RegisterForClicks("LeftButtonUp", "RightButtonUp")
SUCC_bag.toggleButton:SetScript('OnClick', function()
	local bagFrame = SUCC_bag.bagFrame
	if arg1 == 'RightButton' then
		ToggleKeyRing()
	else
		if bagFrame:IsVisible() then
			SUCC_bag.toggleButton:GetNormalTexture():SetVertexColor(1, 1, 1);
			bagFrame:Hide()
		else
			SUCC_bag.toggleButton:GetNormalTexture():SetVertexColor(1, 0, 0);
			bagFrame:Show()
		end
	end
end)
SUCC_bag.toggleButton:SetScript('OnEnter', function()
	GameTooltip:SetOwner(this, 'ANCHOR_LEFT')
	GameTooltip:AddLine('Left Click: Open bags', 1, 1, 1)
	GameTooltip:AddLine('Right Click: Open keyring' , 0.3, 0.8, 1)
	GameTooltip:Show()
end)
SUCC_bag.toggleButton:SetScript('OnLeave', function() GameTooltip:Hide() end)

local cuOffset = 0

if Clean_Up then
	SUCC_bag.cuBag = CreateFrame('Button', 'SUCC_bagCuBag', SUCC_bag)
	SUCC_bag.cuBag:SetHeight(12)
	SUCC_bag.cuBag:SetWidth(25)
	SUCC_bag.cuBag:SetPoint('TOPLEFT', 25, -8)
	SUCC_bag.cuBag:SetNormalTexture('Interface\\Buttons\\UI-SortArrow')
	SUCC_bag.cuBag:SetHighlightTexture('Interface\\Buttons\\UI-SortArrow')
	SUCC_bag.cuBag:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	SUCC_bag.cuBag:SetScript('OnClick', function()
		local bagFrame = SUCC_bag.bagFrame
		if arg1 == 'RightButton' then
			Clean_Up('bags', 1)
		else
			Clean_Up'bags'
		end
	end)
	SUCC_bag.cuBag:SetScript('OnEnter', function()
		GameTooltip:SetOwner(this, 'ANCHOR_LEFT')
		GameTooltip:AddLine('Left Click: Sort bags', 1, 1, 1)
		GameTooltip:AddLine('Right Click: Reverse order' , 0.3, 0.8, 1)
		GameTooltip:Show()
	end)
	SUCC_bag.cuBag:SetScript('OnLeave', function() GameTooltip:Hide() end)
	cuOffset = 14
end

SUCC_bag.title = SUCC_bag:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
SUCC_bag.title:SetPoint('LEFT', SUCC_bag.toggleButton, 'RIGHT', 2 + cuOffset, 0)
SUCC_bag.title:SetText'Bag'

-- keyring
SUCC_bag.keyring = CreateFrame('Frame', 'SUCC_bagKeyring', UIParent)
SUCC_bag.keyring:Hide()
SUCC_bag.keyring:SetFrameStrata('MEDIUM')
SUCC_bag.keyring:SetToplevel(true)
SUCC_bag.keyring:EnableMouse()
SUCC_bag.keyring:SetMovable()
SUCC_bag.keyring:SetClampedToScreen()
FrameTextures(SUCC_bag.keyring)
tinsert(UISpecialFrames, 'SUCC_bagKeyring')
SUCC_bag.keyring:SetScript('OnMouseDown', function() this:StartMoving() end)
SUCC_bag.keyring:SetScript('OnMouseUp', function() this:StopMovingOrSizing() end)
SUCC_bag.keyring:SetScript('OnShow', function()
	if SUCC_bag:IsVisible() then
		this:ClearAllPoints()
		this:SetPoint('BOTTOMLEFT', SUCC_bag, 'TOPLEFT', 0, 0)
	end
	PlaySound('KeyRingOpen')
end)
SUCC_bag.keyring:SetScript('OnHide', function() PlaySound('KeyRingClose') end)
SUCC_bag.keyring.bags = {-2}
SUCC_bag.keyring.cols = bagCols

SUCC_bag.keyring.title = SUCC_bag.keyring:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
SUCC_bag.keyring.title:SetPoint('TOPLEFT', SUCC_bag.keyring, 11, -6)
SUCC_bag.keyring.title:SetText'Keyring'

-- bank
SUCC_bag.bank = CreateFrame('Frame', 'SUCC_bagBank', UIParent)
SUCC_bag.bank:Hide()
SUCC_bag.bank:SetFrameStrata('MEDIUM')
SUCC_bag.bank:SetToplevel(true)
SUCC_bag.bank:EnableMouse()
SUCC_bag.bank:SetMovable()
SUCC_bag.bank:SetClampedToScreen()
FrameTextures(SUCC_bag.bank)
tinsert(UISpecialFrames, 'SUCC_bagBank')
SUCC_bag.bank:SetScript('OnMouseDown', function() this:StartMoving() end)
SUCC_bag.bank:SetScript('OnMouseUp', function() this:StopMovingOrSizing() end)
SUCC_bag.bank:SetScript('OnShow', function()
	this:ClearAllPoints()
	this:SetPoint('LEFT', UIParent, 'LEFT', 115, 0)
	PlaySound('KeyRingClose')
end)
SUCC_bag.bank:SetScript('OnHide', function()
	CloseBankFrame()
	SUCC_bag.bank.bagFrame:Hide()
	PlaySound("igMainMenuClose")
end)
SUCC_bag.bank.bags = {-1}
SUCC_bag.bank.cols = 6

if Clean_Up then
	SUCC_bag.bank.cuBag = CreateFrame('Button', 'SUCC_bagCuBank', SUCC_bag.bank)
	SUCC_bag.bank.cuBag:SetHeight(12)
	SUCC_bag.bank.cuBag:SetWidth(25)
	SUCC_bag.bank.cuBag:SetPoint('TOPLEFT', 12, -8)
	SUCC_bag.bank.cuBag:SetNormalTexture('Interface\\Buttons\\UI-SortArrow')
	SUCC_bag.bank.cuBag:SetHighlightTexture('Interface\\Buttons\\UI-SortArrow')
	SUCC_bag.bank.cuBag:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	SUCC_bag.bank.cuBag:SetScript('OnClick', function()
		local bagFrame = SUCC_bag.bagFrame
		if arg1 == 'RightButton' then
			Clean_Up('bank', 1)
		else
			Clean_Up'bank'
		end
	end)
	SUCC_bag.bank.cuBag:SetScript('OnEnter', function()
		GameTooltip:SetOwner(this, 'ANCHOR_LEFT')
		GameTooltip:AddLine('Left Click: Sort bank', 1, 1, 1)
		GameTooltip:AddLine('Right Click: Reverse order' , 0.3, 0.8, 1)
		GameTooltip:Show()
	end)
	SUCC_bag.bank.cuBag:SetScript('OnLeave', function() GameTooltip:Hide() end)
	cuOffset = 18
end

SUCC_bag.bank.title = SUCC_bag.bank:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
SUCC_bag.bank.title:SetPoint('TOPLEFT', SUCC_bag.bank, 11 + cuOffset, -6)
SUCC_bag.bank.title:SetText'Bank'

SUCC_bag.bank.moneyFrame = CreateFrame('Frame', 'SUCC_bagBankMoneyFrame', SUCC_bag.bank, 'SmallMoneyFrameTemplate')
SUCC_bag.bank.moneyFrame:SetHeight(14)
SUCC_bag.bank.moneyFrame:SetWidth(206)
SUCC_bag.bank.moneyFrame:SetPoint('RIGHT', SUCC_bag.bank.closeButton, 'LEFT', 12, 0)

SUCC_bag.bank.bagFrame = CreateFrame('Frame', 'SUCC_bagBankBagFrame', SUCC_bag.bank)
SUCC_bag.bank.bagFrame:SetFrameLevel(0)
SUCC_bag.bank.bagFrame:SetPoint('TOPLEFT', SUCC_bag.bank, 'TOPRIGHT', -6, -19)
local bbfBackdrop = {
  bgFile = 'Interface\\AddOns\\SUCC-bag\\Textures\\marble',
  edgeFile = 'Interface\\AddOns\\SUCC-bag\\Textures\\BankBagFrame',
  tile = true,
  tileSize = 128,
  edgeSize = 32,
  insets = {
	left = 0,
	right = 5,
	top = 5,
	bottom = 5
  }
}
SUCC_bag.bank.bagFrame:SetBackdrop(bbfBackdrop)
SUCC_bag.bank.bagFrame:Hide()
-- todo
SUCC_bag.bank.bagFrame.bags = {5, 6, 7, 8, 9, 10}
SUCC_bag.bank.bagFrame.cols = 6

SUCC_bag.bank.slotTitle = SUCC_bag.bank:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
SUCC_bag.bank.slotTitle:SetPoint('BOTTOMLEFT', SUCC_bag.bank, 'BOTTOMLEFT', 11, 55)
SUCC_bag.bank.slotTitle:SetJustifyH('LEFT')
SUCC_bag.bank.slotTitle:SetText('Left Click: Toggle bags|nRight Click: Toggle highlight')

SUCC_bag.bank.slotCost = CreateFrame('Frame', 'SUCC_bagBDetailMoneyFrame', SUCC_bag.bank, 'SmallMoneyFrameTemplate')
SUCC_bag.bank.slotCost:SetPoint('BOTTOMRIGHT', SUCC_bag.bank, 'BOTTOMRIGHT', 4, 54)
SUCC_bag.bank.slotCost.info = {
	UpdateFunc = function()
		return SUCC_bag.bank.slotCost.staticMoney;
	end,
	collapse = 1,
}
SUCC_bag.bank.slotCost.moneyType = 'STATIC'
SUCC_bag.bank.slotCost.small = 1
getglobal('SUCC_bagBDetailMoneyFrameGoldButton'):EnableMouse(false)
getglobal('SUCC_bagBDetailMoneyFrameSilverButton'):EnableMouse(false)
getglobal('SUCC_bagBDetailMoneyFrameCopperButton'):EnableMouse(false)
MoneyFrame_Update('SUCC_bagBDetailMoneyFrame', SUCC_bag.bank.slotCost.info.UpdateFunc())

StaticPopupDialogs["CONFIRM_BUY_SUCCBANK_SLOT"] = {
	text = TEXT(CONFIRM_BUY_BANK_SLOT),
	button1 = TEXT(YES),
	button2 = TEXT(NO),
	OnAccept = function()
		PurchaseSlot();
	end,
	OnShow = function()
		MoneyFrame_Update(this:GetName().."MoneyFrame", SUCC_bag.bank.nextSlotCost);
	end,
	hasMoneyFrame = 1,
	timeout = 0,
	hideOnEscape = 1,
}

SUCC_bag.bank.slotCostTitle = SUCC_bag.bank.slotCost:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
SUCC_bag.bank.slotCostTitle:SetPoint('BOTTOMRIGHT', SUCC_bag.bank.slotCost, 'TOPRIGHT', -13, 0)
SUCC_bag.bank.slotCostTitle:SetJustifyH('RIGHT')
SUCC_bag.bank.slotCostTitle:SetText('Slot cost')

SUCC_bag.bank.slot = {}
for i = 1, NUM_BANKBAGSLOTS, 1 do
	SUCC_bag.bank.slot[i] = CreateFrame('CheckButton', 'SUCC_bagBBag' .. i, SUCC_bag.bank, 'BankItemButtonBagTemplate')
	SUCC_bag.bank.slot[i]:SetID(i + 4)
	SUCC_bag.bank.slot[i]:SetNormalTexture('Interface\\AddOns\\SUCC-bag\\Textures\\Slot')
	SUCC_bag.bank.slot[i]:SetPoint('BOTTOMLEFT', SUCC_bag.bank, 'BOTTOMLEFT', (37 + bagSpacing) * (i - 1) + 9, 8)
	SUCC_bag.bank.slot[i]:SetCheckedTexture('Interface\\Buttons\\CheckButtonHilight')
	SUCC_bag.bank.slot[i].color = {math.random ( 0, 10 ) / 10, math.random ( 0, 10 ) / 10, math.random ( 0, 10 ) / 10}
	SUCC_bag.bank.slot[i]:GetNormalTexture():SetVertexColor(SUCC_bag.bank.slot[i].color[1], SUCC_bag.bank.slot[i].color[2], SUCC_bag.bank.slot[i].color[3])
	SUCC_bag.bank.slot[i]:SetScript('OnClick', function()
		if this.buy then
			this:SetChecked(not this:GetChecked())	-- slot name issue
			PlaySound("igMainMenuOption")
			StaticPopup_Show("CONFIRM_BUY_SUCCBANK_SLOT")
			return
		end
		if not CursorHasItem() then
			if arg1 == 'RightButton' and  SUCC_bag.bank.bagFrame:IsVisible() then
				if not this:GetChecked() then
					HighlightBagSlots(this:GetID())
				else
					HighlightBagSlots(this:GetID(), 'highlight')
				end
			else
				if ( IsShiftKeyDown() ) then
					this:SetChecked(not this:GetChecked())	-- slot name issue
					PickupBagFromSlot(this:GetInventorySlot());
				else
					this:SetChecked(not this:GetChecked())
					FrameToggle(SUCC_bag.bank.bagFrame)
					PlaySound("BAGMENUBUTTONPRESS");
				end
			end
		else
			this:SetChecked(not this:GetChecked())
			PutItemInBag(this:GetInventorySlot())
		end
	end)
	SUCC_bag.bank.slot[i]:SetScript('OnReceiveDrag', function()
		PutItemInBag(this:GetInventorySlot())
	end)
	SUCC_bag.bank.slot[i]:SetScript('OnEnter', function()
		HighlightBagSlots(this:GetID(), 'highlight')
		GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
		if ( not GameTooltip:SetInventoryItem("player", this:GetInventorySlot()) ) then
				GameTooltip:SetText(this.tooltipText)
		end
		CursorUpdate()
	end)
	SUCC_bag.bank.slot[i]:SetScript('OnLeave', function()
		if not this:GetChecked() then
			HighlightBagSlots(this:GetID())
		end
		GameTooltip:Hide()
		ResetCursor()
	end)
end

-- overrides
-- bank overridden at events
function FrameOpen(frame, automatic)
	FrameGenerate(frame)
	if frame and not automatic then
		frame.manOpened = 1
	end
end

function FrameClose(frame, automatic)
	if not(automatic and frame.manOpened) then
		frame:Hide()
		frame.manOpened = nil
	end
end

function FrameToggle(frame)
	if frame:IsVisible() then
		FrameClose(frame)
	else
		FrameOpen(frame)
	end
end

ToggleBag = function() FrameToggle(SUCC_bag) end
ToggleBackpack = ToggleBag
OpenAllBags = ToggleBag
OpenBag = function() FrameOpen(SUCC_bag, 1) end
OpenBackpack = OpenBag
CloseBag = function() FrameClose(SUCC_bag, 1) end
CloseBackpack = CloseBag
CloseAllBags = function() FrameClose(SUCC_bag) end
ToggleKeyRing = function() FrameToggle(SUCC_bag.keyring, keyring) end