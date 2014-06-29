 --[[

	s:UI Fonts

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");

-----------------------------------------------------------------------------
-- Pixel Fonts
-----------------------------------------------------------------------------

-- Font Definitions
local tPixelFonts = {
	["04b_11"] = {
		[8] = {
			nLetterSpacing = 1,
			nLetterHeight = 6,
			-- [Letter] = { Sprite, Width }
			tLetters = {
				["0"] = { "04b_11_8_0", 7 },
				["1"] = { "04b_11_8_1", 4 },
				["2"] = { "04b_11_8_2", 7 },
				["3"] = { "04b_11_8_3", 7 },
				["4"] = { "04b_11_8_4", 7 },
				["5"] = { "04b_11_8_5", 7 },
				["6"] = { "04b_11_8_6", 7 },
				["7"] = { "04b_11_8_7", 7 },
				["8"] = { "04b_11_8_8", 7 },
				["9"] = { "04b_11_8_9", 7 },
				["."] = { "04b_11_8_Dot", 3 },
				["F"] = { "04b_11_8_F", 7 },
				["P"] = { "04b_11_8_P", 7 },
				["S"] = { "04b_11_8_S", 7 },
				["M"] = { "04b_11_8_M", 8 },
				["B"] = { "04b_11_8_B", 7 },
				["%"] = { "04b_11_8_Percent", 7 },
				[" "] = { "", 4 },
			},
		},
		[24] = {
			nLetterSpacing = 5,
			nLetterHeight = 20,
			-- [Letter] = { Sprite, Width }
			tLetters = {
				["0"] = { "04b_11_24_0", 24 },
				["1"] = { "04b_11_24_1", 12 },
				["2"] = { "04b_11_24_2", 24 },
				["3"] = { "04b_11_24_3", 24 },
				["4"] = { "04b_11_24_4", 24 },
				["5"] = { "04b_11_24_5", 24 },
				["6"] = { "04b_11_24_6", 24 },
				["7"] = { "04b_11_24_7", 24 },
				["8"] = { "04b_11_24_8", 24 },
				["9"] = { "04b_11_24_9", 24 },
				[":"] = { "04b_11_24_DoubleDot", 8 },
			},
		},
		[32] = {
			nLetterSpacing = 5,
			nLetterHeight = 27,
			-- [Letter] = { Sprite, Width }
			tLetters = {
				["0"] = { "04b_11_32_0", 32 },
				["1"] = { "04b_11_32_1", 16 },
				["2"] = { "04b_11_32_2", 32 },
				["3"] = { "04b_11_32_3", 32 },
				["4"] = { "04b_11_32_4", 32 },
				["5"] = { "04b_11_32_5", 32 },
				["6"] = { "04b_11_32_6", 32 },
				["7"] = { "04b_11_32_7", 32 },
				["8"] = { "04b_11_32_8", 32 },
				["9"] = { "04b_11_32_9", 32 },
				[":"] = { "04b_11_32_DoubleDot", 11 },
			},
		},
		[48] = {
			nLetterSpacing = 6,
			nLetterHeight = 30,
			-- [Letter] = { Sprite, Width }
			tLetters = {
				["0"] = { "04b_11_48_0", 36 },
				["1"] = { "04b_11_48_1", 18 },
				["2"] = { "04b_11_48_2", 36 },
				["3"] = { "04b_11_48_3", 36 },
				["4"] = { "04b_11_48_4", 36 },
				["5"] = { "04b_11_48_5", 36 },
				["6"] = { "04b_11_48_6", 36 },
				["7"] = { "04b_11_48_7", 36 },
				["8"] = { "04b_11_48_8", 36 },
				["9"] = { "04b_11_48_9", 36 },
				[":"] = { "04b_11_48_DoubleDot", 12 },
			},
		},
	},
};

-- Pixie Creation
local CreatePixelFont;
do
	local strlen, strsub, strrev, tostring = string.len, string.sub, string.reverse, tostring;

	local tAnchorPointsLeft = { 0, 0, 0, 0 };
	local tAnchorPointsRight = { 1, 0, 1, 0 };
	local tLastUpdate = {};

	local Draw = function(self, wndControl, strText, bAnchorRight, tColor)
		-- Skip if strText is identical to the last one
		if (tLastUpdate[wndControl] and tLastUpdate[wndControl] == strText) then return; end
		tLastUpdate[wndControl] = strText;

		local nTotalWidth = 0;

		if (bAnchorRight) then
			strText = strrev(strText);
		end

		-- Destroy old pixies
		wndControl:DestroyAllPixies();

		-- Add a pixie for every character
		for i = 1, strlen(strText) do
			local strChar = strsub(strText, i, i);
			local nCharWidth = self.tDefinitions.tLetters[tostring(strChar)][2];
			local nPosition = nTotalWidth + (nTotalWidth > 0 and self.tDefinitions.nLetterSpacing or 0);

			wndControl:AddPixie({
				strSprite = self.tDefinitions.tLetters[tostring(strChar)][1],
				loc = {
					fPoints = bAnchorRight and tAnchorPointsRight or tAnchorPointsLeft,
					nOffsets = bAnchorRight and { -nPosition - nCharWidth, 0, nPosition + nCharWidth, self.tDefinitions.nLetterHeight } or { nPosition, 0, nPosition + nCharWidth, self.tDefinitions.nLetterHeight },
				},
				cr = tColor,
			});

			nTotalWidth = nPosition + nCharWidth;
		end
	end

	CreatePixelFont = function(tDefinitions)
		local tFont = {};
		tFont.tDefinitions = tDefinitions;
		tFont.Draw = Draw;

		return tFont;
	end
end

function S:CreatePixelFont(strName, nSize)
	if (tPixelFonts[strName] and tPixelFonts[strName][nSize]) then
		return CreatePixelFont(tPixelFonts[strName][nSize]);
	else
		return false;
	end
end
