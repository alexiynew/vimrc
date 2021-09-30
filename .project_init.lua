local M = {}

function _G.async_run(command)

    local function on_exit(id, data, event)
        vim.fn.setqflist({}, 'a', {
            nr = "$",
            lines = data
        })
        vim.cmd('cbottom')
    end

    local function on_data(id, data, event)

        if data[#data] == '' then
            table.remove(data, #data)
        end

        vim.fn.setqflist({}, 'a', {
            nr = "$",
            lines = data
        })
        vim.cmd('cbottom')
    end


    vim.cmd('copen')
    vim.fn.setqflist({}, ' ', { title = command })

    local job_id = vim.fn.jobstart(command, {
        cwd = vim.fn.getcwd(),
		on_exit = on_exit,
		on_stdout = on_data,
		on_stderr = on_data,
    })

    if job_id == 0 then
        print('invalid aruments')
    elseif job_id == -1 then
        print(command .. 'is not executable')
    else
        print('Job started: ' .. job_id)
    end

end

function _G.sync_run(command)

    vim.cmd('copen')
    vim.cmd('cexpr system("' .. command .. '")')

end


M.setup = function()
    vim.opt.makeprg ='cmake --build ./build'

    vim.cmd('command! Make call v:lua.async_run("cmake --build ./build")')
    vim.cmd('command! Test call v:lua.async_run("cmake --build ./build -t check")')
    vim.cmd('command! Run call v:lua.async_run("./build/test/window_focus")')
end

return M

