--[[                                      ]]--
--                                          -
--   Multicolor Awesome WM 3.5.+ config     --
--        github.com/copycat-killer         --
--                                          -
--[[                                      ]]--


-- {{{ Required Libraries

gears 	        = require("gears")
awful           = require("awful")
awful.rules     = require("awful.rules")
awful.autofocus = require("awful.autofocus")
wibox           = require("wibox")
beautiful       = require("beautiful")
naughty         = require("naughty")
vicious         = require("vicious")
scratch         = require("scratch")
perceptive      = require("perceptive")

-- }}}

-- {{{ Autostart

function run_once(cmd)
  findme = cmd
  firstspace = cmd:find(" ")
  if firstspace then
     findme = cmd:sub(0, firstspace-1)
  end
  awful.util.spawn_with_shell("pgrep -u $USER -x " .. findme .. " > /dev/null || (" .. cmd .. ")")
 end 

run_once("unclutter -idle 10")

-- }}}

-- {{{ Localization

os.setlocale(os.getenv("LANG"))

-- }}}

-- {{{ Error Handling

-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end

-- }}}

-- {{{ Variable Definitions

-- Useful Paths
home = os.getenv("HOME")
confdir = home .. "/.config/awesome"
scriptdir = confdir .. "/scripts/"
themes = confdir .. "/themes"
active_theme = themes .. "/multicolor"

-- Themes define colours, icons, and wallpapers
beautiful.init(active_theme .. "/theme.lua")

terminal = "urxvt"
editor = "vim"
editor_cmd = terminal .. " -e " .. editor
gui_editor = "geany -ps"
browser = "chromium"
mail = terminal .. " -e mutt "
chat = terminal .. " -e irssi "
tasks = terminal .. " -e htop "

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"
altkey = "Mod1"

-- Table of layouts to cover with awful.layout.inc, order matters.
layouts =
{
    awful.layout.suit.floating,             -- 1
    awful.layout.suit.tile,                 -- 2
    awful.layout.suit.tile.left,            -- 3
    awful.layout.suit.tile.bottom,          -- 4
    awful.layout.suit.tile.top,             -- 5
    awful.layout.suit.fair,                 -- 6
    awful.layout.suit.fair.horizontal,      -- 7
    awful.layout.suit.spiral,               -- 8
    awful.layout.suit.spiral.dwindle,       -- 9
    awful.layout.suit.max,                  -- 10
    --awful.layout.suit.max.fullscreen,     -- 11
    --awful.layout.suit.magnifier           -- 12
}

-- }}}

-- {{{ Wallpaper

if beautiful.wallpaper then
    for s = 1, screen.count() do
        gears.wallpaper.maximized(beautiful.wallpaper, s, true)
    end
end

-- }}}
                
-- {{{ Tags

-- Define a tag table which hold all screen tags.
tags = {
       names = { "web", "term", "docs", "media", "files", "other" },       
       layout = { layouts[1], layouts[3], layouts[4], layouts[1], layouts[7], layouts[1] } 
       }
for s = 1, screen.count() do
-- Each screen has its own tag table.
   tags[s] = awful.tag(tags.names, s, tags.layout)
end
-- }}}
 
myawesomemenu = {
--   { "manual", "terminator -x man awesome" },
--   { "edit config", "terminator -x vim /home/bradomyn/.config/awesome/rc.lua"},
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awful.util.getdir("config") .. "/rc.lua" },
   { "restart", awesome.restart },
   { "quit", awesome.quit },
   { "poweroff", "su -c poweroff" },
   { "reboot", "su -c reboot"},
   { "lock screen", "gnome-screensaver-command -l"}
}

rag_bag = {
	{ "Calculator", "gcalctool" },
	{ "vlc", vlc },
}

mysystem = {
    { "appearance" , "lxappearance" },
    { "cleaning" , "bleachbit" },
    { "powertop" , terminal .. " -e su -c powertop " },
    { "task manager" , tasks }
}

mymainmenu = awful.menu({ items = {
	{ "open terminal", terminal },
    { "chromium", "chromium --allow-outdated-plugins --memory-model=low" },
    { "Rag-Bag",ragbag  },
	{ "spotify", "spotify" },
	{ "system", mysystem },
	{ "awesome", myawesomemenu, beautiful.awesome_icon }
 }
 })


mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })
-- }}}

-- {{{ Wibox

-- Colours
coldef  = "</span>"
colwhi  = "<span color='#b2b2b2'>"
colbwhi = "<span color='#ffffff'>"
blue = "<span color='#7493d2'>"
yellow = "<span color='#e0da37'>"
purple = "<span color='#e33a6e'>"
lightpurple = "<span color='#eca4c4'>"
azure = "<span color='#80d9d8'>"
green = "<span color='#87af5f'>"
lightgreen = "<span color='#62b786'>"
red = "<span color='#e54c62'>"
orange = "<span color='#ff7100'>"
brown = "<span color='#db842f'>"
fuchsia = "<span color='#800080'>"
gold = "<span color='#e7b400'>"

-- Textclock widget
clockicon = wibox.widget.imagebox()
clockicon:set_image(beautiful.widget_clock)
mytextclock = awful.widget.textclock("<span color='#7788af'>%A %d %B</span> " .. blue .. "</span><span color=\"#343639\">></span> <span color='#de5e1e'>%H:%M</span> ")

-- Calendar attached to the textclock
local os = os
local string = string
local table = table
local util = awful.util

char_width = nil
text_color = theme.fg_normal or "#FFFFFF"
today_color = theme.fg_focus or "#00FF00"
calendar_width = 21

local calendar = nil
local offset = 0

local data = nil

local function pop_spaces(s1, s2, maxsize)
   local sps = ""
   for i = 1, maxsize - string.len(s1) - string.len(s2) do
      sps = sps .. " "
   end
   return s1 .. sps .. s2
end

local function create_calendar()
   offset = offset or 0

   local now = os.date("*t")
   local cal_month = now.month + offset
   local cal_year = now.year
   if cal_month > 12 then
      cal_month = (cal_month % 12)
      cal_year = cal_year + 1
   elseif cal_month < 1 then
      cal_month = (cal_month + 12)
      cal_year = cal_year - 1
   end

   local last_day = os.date("%d", os.time({ day = 1, year = cal_year,
                                            month = cal_month + 1}) - 86400)
   local first_day = os.time({ day = 1, month = cal_month, year = cal_year})
   local first_day_in_week =
      os.date("%w", first_day)
   local result = "do lu ma me gi ve sa\n"
   for i = 1, first_day_in_week do
      result = result .. "   "
   end

   local this_month = false
   for day = 1, last_day do
      local last_in_week = (day + first_day_in_week) % 7 == 0
      local day_str = pop_spaces("", day, 2) .. (last_in_week and "" or " ")
      if cal_month == now.month and cal_year == now.year and day == now.day then
         this_month = true
         result = result ..
            string.format('<span weight="bold" foreground = "%s">%s</span>',
                          today_color, day_str)
      else
         result = result .. day_str
      end
      if last_in_week and day ~= last_day then
         result = result .. "\n"
      end
   end

   local header
   if this_month then
      header = os.date("%a, %d %b %Y")
   else
      header = os.date("%B %Y", first_day)
   end
   return header, string.format('<span font="%s" foreground="%s">%s</span>',
                                theme.font, text_color, result)
end

local function calculate_char_width()
   return beautiful.get_font_height(theme.font) * 0.555
end

function hide()
   if calendar ~= nil then
      naughty.destroy(calendar)
      calendar = nil
      offset = 0
   end
end

function show(inc_offset)
   inc_offset = inc_offset or 0

   local save_offset = offset
   hide()
   offset = save_offset + inc_offset

   local char_width = char_width or calculate_char_width()
   local header, cal_text = create_calendar()
   calendar = naughty.notify({ title = header,
                               text = cal_text,
                               timeout = 0, hover_timeout = 0.5,
                            })
end

mytextclock:connect_signal("mouse::enter", function() show(0) end)
mytextclock:connect_signal("mouse::leave", hide)
mytextclock:buttons(util.table.join( awful.button({ }, 1, function() show(-1) end),
                                     awful.button({ }, 3, function() show(1) end)))

-- Vicious weather widget
weathericon = wibox.widget.imagebox()
weathericon:set_image(theme.confdir .. "/widgets/dish.png")
weatherwidget = wibox.widget.textbox()
perceptive.register(643787)

weather_t = awful.tooltip({ objects = { weatherwidget },})

vicious.register(weatherwidget, vicious.widgets.weather,
                function (widget, args)
                    weather_t:set_text("City: " .. args["{city}"] .."\nWind: " .. args["{windkmh}"] .. "km/h " 
                                                .. args["{wind}"] .. "\nSky: " .. args["{sky}"] .. "\nHumidity: " 
                                                .. args["{humid}"] .. "%")
                    return args["{tempc}"] .. "C"
                end, 1800, "EDDF")

-- spotify 
    spotifywidget = wibox.widget.textbox()
    
    vicious.register( spotifywidget, vicious.widgets.spotify, function ( widget, args)
        if args["{State}"] == 'Playing' then
            return '<span color="green">' .. args["{Artist}"] .. ' - ' .. args["{Title}"] .. '</span>'
        else
            return ''
        end
    end, 10)
-- /home fs widget
fshicon = wibox.widget.imagebox()
fshicon:set_image(theme.confdir .. "/widgets/fs.png")
fshwidget = wibox.widget.textbox()
    vicious.register(fshwidget, vicious.widgets.fs,
    function (widget, args)
        if args["{/home used_p}"] >= 95 and args["{/home used_p}"] < 99 then
            return colwhi .. args["{/home used_p}"] .. "%" .. coldef
        elseif args["{/home used_p}"] >= 99 and args["{/home used_p}"] <= 100 then
            naughty.notify({ title = "Attenzione", text = "Partizione /home esaurita!\nFa' un po' di spazio.",
                             timeout = 10,
                             position = "top_right",
                             fg = beautiful.fg_urgent,
                             bg = beautiful.bg_urgent })
            return colwhi .. args["{/home used_p}"] .. "%" .. coldef
        else
            return azure .. args["{/home used_p}"] .. "%" .. coldef
        end
    end, 3600)

local infos = nil

function remove_info()
    if infos ~= nil then 
        naughty.destroy(infos)
        infos = nil
    end
end

function add_info()
    remove_info()
    local capi = {
		mouse = mouse,
		screen = screen
	  }
    local cal = awful.util.pread(scriptdir .. "dfs")
    cal = string.gsub(cal, "          ^%s*(.-)%s*$", "%1")
    infos = naughty.notify({
        text = string.format('<span font_desc="%s">%s</span>', "Terminus", cal),
      	timeout = 0,
        position = "top_right",
        margin = 10,
        height = 170,
        width = 585,
		  screen	= capi.mouse.screen
    })
end

fshwidget:connect_signal('mouse::enter', function () add_info() end)
fshwidget:connect_signal('mouse::leave', function () remove_info() end)

-- Uptime
uptimeicon = wibox.widget.imagebox()
uptimeicon:set_image(beautiful.widget_uptime)
uptimewidget = wibox.widget.textbox()
vicious.register(uptimewidget, vicious.widgets.uptime, brown .. "$2.$3" .. coldef,60)

-- Gmail widget
mygmail = wibox.widget.textbox()
gmail_t = awful.tooltip({ objects = { mygmail },})
mygmailimg = wibox.widget.imagebox(beautiful.widget_gmail)

vicious.register(mygmail, vicious.widgets.mutt,"$1%", 300)

--vicious.register(mygmail, vicious.widgets.gmail,
--                function (widget, args)
--                    gmail_t:set_text(args["{subject}"])
--                    gmail_t:add_to_object(mygmailimg)
--                    return args["{count}"]
--                 end, 2)
mygmail:buttons(awful.util.table.join(awful.button({ }, 1, function () awful.util.spawn(mail, false) end)))

-- CPU widget
cpuicon = wibox.widget.imagebox()
cpuicon:set_image(beautiful.widget_cpu)
cpuwidget = wibox.widget.textbox()
vicious.register(cpuwidget, vicious.widgets.cpu, "$1", 10)
cpuicon:buttons(awful.util.table.join(awful.button({ }, 1, function () awful.util.spawn(tasks, false) end)))

-- Temp widget
tempicon = wibox.widget.imagebox()
tempicon:set_image(beautiful.widget_temp)
tempicon:buttons(awful.util.table.join(
    awful.button({ }, 1, function () awful.util.spawn(terminal .. " -e su -c powertop ", false) end)
    ))
   tempwidget = wibox.widget.textbox()
   vicious.register(tempwidget, vicious.widgets.thermal_easy, "<span color=\"#f1af5f\">$1 C</span>", 60, {"", "core"} )

-- Battery widget
baticon = wibox.widget.imagebox()
baticon:set_image(beautiful.widget_batt)
batwidget = wibox.widget.textbox()
vicious.register( batwidget, vicious.widgets.bat, "$2", 60, "BAT0")

function batstate()

     local file = io.open("/sys/class/power_supply/BAT0/status", "r")

     if (file == nil) then
     	  return "Cable plugged"
     end

     local batstate = file:read("*line")
     file:close()

     if (batstate == 'Discharging' or batstate == 'Charging') then
          return batstate
     else
          return "Fully charged"
     end
end

batwidget = wibox.widget.textbox()
vicious.register(batwidget, vicious.widgets.bat,
     function (widget, args)
          -- plugged
          if (batstate() == 'Cable plugged') then return "AC "
          -- critical
          elseif (args[2] <= 5 and batstate() == 'Discharging') then
               naughty.notify({
                    text = "sto per spegnermi...",
                    title = "Carica quasi esaurita!",
                    position = "top_right",
                    timeout = 1,
                    fg="#000000",
                    bg="#ffffff",
                    screen = 1,
                    ontop = true,
               })
          -- low
          elseif (args[2] <= 10 and batstate() == 'Discharging') then
               naughty.notify({
                    text = "attacca il cavo!",
                    title = "Carica bassa",
                    position = "top_right",
                    timeout = 1,
                    fg="#ffffff",
                    bg="#262729",
                    screen = 1,
                    ontop = true,
               })
          end
          return " " .. args[2] .. "% "
     end, 60, 'BAT0')

-- Volume widget
volicon = wibox.widget.imagebox()
volicon:set_image(beautiful.widget_vol)
volumewidget = wibox.widget.textbox()
vicious.register(volumewidget, vicious.widgets.volume, blue .. "$1%" .. coldef,  0, "Master")

-- Net widget
netdownicon = wibox.widget.imagebox()
netdownicon:set_image(beautiful.widget_netdown)
netdownicon.align = "middle"
netdowninfo = wibox.widget.textbox()
--vicious.register(netdowninfo, vicious.widgets.net, green .. "${wlan0 down_kb}" .. coldef, 1)
vicious.register(netdowninfo, vicious.widgets.net, green .. "${eth0 down_kb}" .. coldef, 15)
netupicon = wibox.widget.imagebox()
netupicon:set_image(beautiful.widget_netup)
netupicon.align = "middle"
netupinfo = wibox.widget.textbox()
--vicious.register(netupinfo, vicious.widgets.net, red .. "${wlan0 up_mb}" .. coldef, 1)
vicious.register(netupinfo, vicious.widgets.net, green .. "${eth0 up_kb}" .. coldef, 15)

-- Memory widget
memicon = wibox.widget.imagebox()
memicon:set_image(beautiful.widget_mem)
memwidget = wibox.widget.textbox()
vicious.register(memwidget, vicious.widgets.mem, yellow .. "$2M" .. coldef, 60)

-- MPD Widget
--mpdwidget = wibox.widget.textbox()
--mpdicon = wibox.widget.imagebox()
--mpdicon:set_image(theme.confdir .. "/widgets/note.png")
--
--vicious.register(mpdwidget, vicious.widgets.mpd,
--function(widget, args)
--	-- play
--	if (args["{state}"] == "Play") then
--		return red .. args["{Title}"] .. coldef .. colwhi .. " - " .. coldef .. colwhi  .. 
--		args["{Artist}"] .. coldef
--	-- pause
--	elseif (args["{state}"] == "Pause") then
--		return red .. "mpd</span>" .. colwhi .." paused</span>"
--	-- stop
--	elseif (args["{state}"] == "Stop") then
--		return red .. "mpd</span>" .. colwhi .." stopped</span>"
--	-- not running
--	else
--		return red .. "mpd</span>" .. colwhi .." off</span>"
--	end
--	end, 1)

-- Spacer
spacer = wibox.widget.textbox(" ")

-- }}}

-- {{{ Layout

-- Create a wibox for each screen and add it
mywibox = {}
mybottomwibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  -- Without this, the following
                                                  -- :isvisible() makes no sense
                                                  c.minimized = false
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

for s = 1, screen.count() do
    
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt()

    
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                            awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                            awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                            awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                            awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))

    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

    -- Create the upper wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s, height = 20 }) 
    --border_width = 0, height =  20 })
        
    -- Widgets that are aligned to the upper left
    local left_layout = wibox.layout.fixed.horizontal()
    --left_layout:add(spacer)
    --left_layout:add(mylauncher)
    --left_layout:add(spacer)
    left_layout:add(mytaglist[s])
    left_layout:add(mypromptbox[s])
    --left_layout:add(spacer)
    --left_layout:add(mpdicon)
    --left_layout:add(mpdwidget)
    left_layout:add(spotifywidget)
    --left_layout:add(spacer)

    -- Widgets that are aligned to the upper right
    local right_layout = wibox.layout.fixed.horizontal()
    if s == 1 then right_layout:add(wibox.widget.systray()) end
    right_layout:add(netdownicon)
    right_layout:add(netdowninfo)
    right_layout:add(spacer)
    right_layout:add(netupicon)
    right_layout:add(netupinfo)
    right_layout:add(spacer)
    right_layout:add(volicon)
    right_layout:add(volumewidget)
    right_layout:add(spacer)
    right_layout:add(memicon)
    right_layout:add(memwidget)
    right_layout:add(spacer)
    right_layout:add(cpuicon)
    right_layout:add(cpuwidget)
    right_layout:add(spacer)
    right_layout:add(fshicon)
    right_layout:add(fshwidget)
    right_layout:add(spacer)
    right_layout:add(uptimeicon)
    right_layout:add(uptimewidget) 
    right_layout:add(spacer)
    right_layout:add(weathericon)
    right_layout:add(perceptive.icon)
    right_layout:add(perceptive.widget)
    right_layout:add(spacer)
    right_layout:add(weatherwidget)
    right_layout:add(spacer)
    right_layout:add(tempicon)
    right_layout:add(tempwidget)
    right_layout:add(spacer)
    right_layout:add(mygmailimg)
    right_layout:add(mygmail)
    right_layout:add(spacer)     
    right_layout:add(baticon)
    right_layout:add(batwidget)
    right_layout:add(spacer)
    right_layout:add(clockicon)
    right_layout:add(mytextclock)
    --right_layout:add(mylayoutbox[s])

    -- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    --layout:set_middle(mytasklist[s])
    layout:set_right(right_layout)
    
    mywibox[s]:set_widget(layout)

    -- Create the bottom wibox
    mybottomwibox[s] = awful.wibox({ position = "bottom", screen = s, border_width = 0, height = 20 })
    --mybottomwibox[s].visible = false
            
    -- Widgets that are aligned to the bottom left
    bottom_left_layout = wibox.layout.fixed.horizontal()
    bottom_left_layout:add(spacer)
                        
    -- Widgets that are aligned to the bottom right
    bottom_right_layout = wibox.layout.fixed.horizontal()
    bottom_right_layout:add(spacer)
    bottom_right_layout:add(mylayoutbox[s])
                                            
    -- Now bring it all together (with the tasklist in the middle)
    bottom_layout = wibox.layout.align.horizontal()
    bottom_layout:set_left(bottom_left_layout)
    bottom_layout:set_middle(mytasklist[s])
    bottom_layout:set_right(bottom_right_layout)
    mybottomwibox[s]:set_widget(bottom_layout)

end

-- }}}

-- {{{ Mouse Bindings

root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))

-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(

    -- Capture a screenshot
    awful.key({ altkey }, "p", function() awful.util.spawn("screenshot",false) end),

    -- Move clients
    awful.key({ altkey }, "Next",  function () awful.client.moveresize( 1,  1, -2, -2) end),
    awful.key({ altkey }, "Prior", function () awful.client.moveresize(-1, -1,  2,  2) end),
    awful.key({ altkey }, "Down",  function () awful.client.moveresize(  0,  1,   0,   0) end),
    awful.key({ altkey }, "Up",    function () awful.client.moveresize(  0, -1,   0,   0) end),
    awful.key({ altkey }, "Left",  function () awful.client.moveresize(-1,   0,   0,   0) end),
    awful.key({ altkey }, "Right", function () awful.client.moveresize( 1,   0,   0,   0) end),
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "w", function () mymainmenu:show({keygrabber=true}) end),

    -- Show/Hide Wibox
    awful.key({ modkey }, "p", function ()
    mywibox[mouse.screen].visible = not mywibox[mouse.screen].visible end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey,           }, "b",      function () awful.util.spawn("chromium") end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),
    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)     end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)     end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)       end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)       end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)          end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)          end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1)  end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1)  end),
    awful.key({ modkey, "Control" }, "n", awful.client.restore),

    -- Dropdown terminal
    awful.key({ modkey,	          }, "z",     function () scratch.drop(terminal) end),
    
    -- Volume control
    awful.key({ "Control" }, "Up", function ()
                                       awful.util.spawn("amixer set Master playback 1%+", false )
                                       vicious.force({ volumewidget })
                                   end),
    awful.key({ "Control" }, "Down", function ()
                                       awful.util.spawn("amixer set Master playback 1%-", false )
                                       vicious.force({ volumewidget })
                                     end),
    awful.key({ "Control" }, "m", function ()
                                       awful.util.spawn("amixer set Master playback mute", false )
                                       vicious.force({ volumewidget })
                                     end),
    awful.key({ "Control" }, "u", function () 
                                      awful.util.spawn("amixer set Master playback unmute", false )
                                       vicious.force({ volumewidget })
                                  end),
    awful.key({ altkey, "Control" }, "m", function () 
                                              awful.util.spawn("amixer set Master playback 100%", false )
                                              vicious.force({ volumewidget })
                                          end),

    -- Music control
    awful.key({ altkey, "Control" }, "Up", function () 
                                              awful.util.spawn( "mpc toggle", false ) 
                                              vicious.force({ mpdwidget } )
                                           end),
    awful.key({ altkey, "Control" }, "Down", function () 
                                                awful.util.spawn( "mpc stop", false ) 
                                                vicious.force({ mpdwidget } )
                                             end ),
    awful.key({ altkey, "Control" }, "Left", function ()
                                                awful.util.spawn( "mpc prev", false )
                                                vicious.force({ mpdwidget } )
                                             end ),
    awful.key({ altkey, "Control" }, "Right", function () 
                                                awful.util.spawn( "mpc next", false )
                                                vicious.force({ mpdwidget } )
                                              end ),

    -- Copy to clipboard
    awful.key({ modkey,        }, "c",      function () os.execute("xsel -p -o | xsel -i -b") end),

    -- User programs
    awful.key({ modkey,        }, "q",      function () awful.util.spawn( "dwb", false ) end),
    awful.key({ modkey,        }, "a",      function () awful.util.spawn( "midori", false ) end),
    awful.key({ modkey,        }, "s",      function () awful.util.spawn(gui_editor) end),
    awful.key({ modkey, 	     }, "t", 	    function () awful.util.spawn( "thunderbird", false ) end),
    awful.key({ modkey,        }, "d", 	    function () awful.util.spawn( "spacefm", false ) end),
    
    -- Prompt
    awful.key({ modkey }, "r", function () mypromptbox[mouse.screen]:run() end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber));
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        screen = mouse.screen
                        if tags[screen][i] then
                            awful.tag.viewonly(tags[screen][i])
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      screen = mouse.screen
                      if tags[screen][i] then
                          awful.tag.viewtoggle(tags[screen][i])
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][i])
                      end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.toggletag(tags[client.focus.screen][i])
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)

-- }}}

-- {{{ Rules

awful.rules.rules = {
     -- All clients will match this rule.
     { rule = { },
       properties = { border_width = beautiful.border_width,
                      border_color = beautiful.border_normal,
                      focus = true,
                      keys = clientkeys,
                      buttons = clientbuttons,
	                  size_hints_honor = false
                     }
    },
   
    { rule = { class = "MPlayer" },
      properties = { floating = true } },

    { rule = { class = "Dwb" },
          properties = { tag = tags[1][1],
          			     maximized_vertical=true,
          			     maximized_horizontal=true } },

    { rule = { class = "Geany" },
          properties = { tag = tags[1][2] } },

	  { rule = { class = "Zathura" },
     	  properties = { tag = tags[1][3] } },

    { rule = { class = "Dia" },
          properties = { tag = tags[1][4], 
          floating = true } },

    { rule = { class = "Gimp" },
          properties = { tag = tags[1][4],
          floating = true } },

    { rule = { class = "Inkscape" },
          properties = { tag = tags[1][4] } },      

    { rule = { class = "Rtorrent" },
          properties = { tag = tags[1][6] } },

    { rule = { class = "Torrent-search" },
          properties = { tag = tags[1][6] } },
}

-- }}}

-- {{{ Signals

-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
    -- Enable sloppy focus
    c:connect_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end

    local titlebars_enabled = false
    if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
        -- Widgets that are aligned to the left
        local left_layout = wibox.layout.fixed.horizontal()
        left_layout:add(awful.titlebar.widget.iconwidget(c))

        -- Widgets that are aligned to the right
        local right_layout = wibox.layout.fixed.horizontal()
        right_layout:add(awful.titlebar.widget.floatingbutton(c))
        right_layout:add(awful.titlebar.widget.maximizedbutton(c))
        right_layout:add(awful.titlebar.widget.stickybutton(c))
        right_layout:add(awful.titlebar.widget.ontopbutton(c))
        right_layout:add(awful.titlebar.widget.closebutton(c))

        -- The title goes in the middle
        local title = awful.titlebar.widget.titlewidget(c)
        title:buttons(awful.util.table.join(
                awful.button({ }, 1, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.move(c)
                end),
                awful.button({ }, 3, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.resize(c)
                end)
                ))

        -- Now bring it all together
        local layout = wibox.layout.align.horizontal()
        layout:set_left(left_layout)
        layout:set_right(right_layout)
        layout:set_middle(title)

        awful.titlebar(c):set_widget(layout)
    end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

-- }}}
