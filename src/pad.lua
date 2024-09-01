--[[pod_format="raw",created="2024-08-21 13:09:32",modified="2024-08-21 15:18:33",revision=289]]
function left_pad(s, len, pad)
	if not pad then pad = " " end
	while #s < len do
		s = pad .. s
	end

	return s
end

function right_pad(s, len, pad)
	if not pad then pad = " " end
	while #s < len do
		s = s .. pad
	end

	return s
end
