
-- global function for comparing any values
function compare_values(val1, val2)
	local type1 = type(val1)
	local type2 = type(val2)
	if type1 ~= type2 then
		return false
	end

	-- check for NaN
	if type1 == "number" and val1 ~= val1 and val2 ~= val2 then
		return true
	end

	if type1 ~= "table" then
		return val1 == val2
	end

	-- check_keys stores all the keys that must be checked in val2
	local check_keys = {}
	for k, _ in pairs(val1) do
		check_keys[k] = true
	end

	for k, _ in pairs(val2) do
		if not check_keys[k] then
			return false
		end

		if not compare_values(val1[k], val2[k]) then
			return false
		end

		check_keys[k] = nil
	end

	for k, _ in pairs(check_keys) do
		-- Not the same if any keys from val1 were not found in val2
		return false
	end

	return true
end
