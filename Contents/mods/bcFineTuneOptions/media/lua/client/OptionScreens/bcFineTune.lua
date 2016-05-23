require "OptionScreens/SandboxOptions"

bcFineTune = {}

SandboxOptionsScreen.setSandboxVars = function(self)
	local options = getSandboxOptions()
	self:settingsFromUI(options)
	local waterShut = bcUtils.split(bcFineTune.WaterShut:getText(), "-");
	local min = tonumber(waterShut[1]);
	local max = tonumber(waterShut[2]);
	if max == nil then
		waterShut = min or ZombRand(0, 30); -- default if unparseable
	else
		waterShut = ZombRand(min or 0, max or 30); -- see above
	end

	local elecShut = bcUtils.split(bcFineTune.ElecShut:getText(), "-");
	local min = tonumber(elecShut[1]);
	local max = tonumber(elecShut[2]);
	if max == nil then
		elecShut = min or ZombRand(0, 30); -- default if unparseable
	else
		elecShut = ZombRand(min or 0, max or 30); -- see above
	end
	options:set("WaterShutModifier", waterShut);
	options:set("ElecShutModifier", elecShut);
	options:toLua();
end

SandboxOptionsScreen.settingsToUI = function(self, options)
	for i=1,options:getNumOptions() do
		local option = options:getOptionByIndex(i-1)
		local control = self.controls[option:getName()]
		if control then
			if option:getType() == "boolean" then
				control.selected[1] = option:getValue()
			elseif option:getType() == "double" then
				control:setText(option:getValueAsString())
			elseif option:getType() == "enum" then
				control.selected = option:getValue()
			elseif option:getType() == "integer" then
				control:setText(option:getValueAsString())
			elseif option:getType() == "string" then
				control:setText(option:getValue())
			elseif option:getType() == "text" then
				control:setText(option:getValue())
			end
		end
	end
	for _,groupBox in pairs(self.groupBox) do
		groupBox:settingsToUI(options)
	end
end

bcFineTune.createPanel = SandboxOptionsScreen.createPanel;
SandboxOptionsScreen.createPanel = function(self, page)
	local panel = bcFineTune.createPanel(self, page);
	bcFineTune.checkForShutModifier(panel.children);
	return panel;
end

function bcFineTune.checkForShutModifier(t)
	local addMe = {};
	for _,el in pairs(t) do
		if el.onChangeArgs then -- only ISComboBox has this
			if el.onChangeArgs[1] == "WaterShut" then
				local control = ISTextEntryBox:new("0-30", el:getX(), el:getY(), el:getWidth(), el:getHeight());
				control.font = UIFont.Medium
				control:initialise()
				control:instantiate()
				control:setMultipleLine(false)
				table.insert(addMe, {el.parent, control});
				bcFineTune.WaterShut = control;
				el:setVisible(false);
			elseif el.onChangeArgs[1] == "ElecShut" then
				local control = ISTextEntryBox:new("0-30", el:getX(), el:getY(), el:getWidth(), el:getHeight());
				control.font = UIFont.Medium
				control:initialise()
				control:instantiate()
				control:setMultipleLine(false)
				table.insert(addMe, {el.parent, control});
				bcFineTune.ElecShut = control;
				el:setVisible(false);
			end
		else
			if type(el.children) == "table" then
				bcFineTune.checkForShutModifier(el.children);
			end
		end
	end

	for _,a in pairs(addMe) do
		a[1]:addChild(a[2]);
	end
end
