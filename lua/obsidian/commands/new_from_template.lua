local util = require "obsidian.util"
local log = require "obsidian.log"

---@param client obsidian.Client
return function(client, data)
  if not client:templates_dir() then
    log.err "Templates folder is not defined or does not exist"
    return
  end

  local picker = client:picker()
  if not picker then
    log.err "No picker configured"
    return
  end

  ---@type obsidian.Note
  local note
  if data.args and data.args ~= "" then
    local args = vim.split(data.args, " ", { trimempty = true })
    if #args == 1 then
      note = client:create_note { title = args[1], no_write = true }
    elseif #args >= 2 then
      note = client:create_note { title = args[1], template = args[2], no_write = true }
    end
  else
    local title = util.input("Enter title or path (optional): ", { completion = "file" })
    if not title then
      log.warn "Aborted"
      return
    elseif title == "" then
      title = nil
    end
    note = client:create_note { title = title, no_write = true }
  end

  -- Open the note in a new buffer.
  client:open_note(note, { sync = true })

  picker:find_templates {
    callback = function(name)
      client:write_note_to_buffer(note, { template = name })
    end,
  }
end
