require("core.platform.common")

if vim.fn.has("mac") == 1 then
	require("core.platform.macos")
elseif vim.fn.has("win32") == 1 then
	require("core.platform.windows")
elseif vim.fn.has("unix") == 1 then
	require("core.platform.linux")
end
