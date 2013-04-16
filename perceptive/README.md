Perceptive, a weather notification module for Awesome 3.5+
================================

Perceptive is a module for Awesome WM for brief and compact
weather notification via naughty lib and Yahoo! Weather API.

This fork introduces: 

- **Celsius/Fahrenheit selection**
- **A widget set**
- **Nice icons** updating at forecast changes and day/night cycle
- **Localization support** 
- **no need of python and /tmp/** just Lua

Usage
-----
Clone perceptive repository into your $XDG_CONFIG_HOME/awesome (Awesome config dir).
Then, add in your rc.lua :

    require("perceptive")
    perceptive.register(123456)

Where the function argument is so-called WOEID code of your city.
To obtain it you can google 'yahoo weather %CITYNAME%' and follow the first link.
It will look like http://weather.yahoo.com/united-states/california/san-diego-2487889/
and the last number in that link will be the ID you need.

Default units and text widget color are Celsius and #D7D7D7, but they can be changed.
If you just want to change the color, add a second argument like this:

    perceptive.register(123456, "#EEEEEE")

If you want to set Fahrenheit units, add a third argument like this:

    perceptive.register(123456, "#EEEEEE", "f")

Color argument can be *nil* if you don't want to change it.

Finally, add perceptive to your wibox of choice, for instance:

    right_layout:add(perceptive.icon)
    right_layout:add(perceptive.widget)

If you just want the notification attached to an existent widget, use *attach* instead:

    perceptive.attach(*yourwidget*, 123456)

or 

    perceptive.attach(*yourwidgetagain*, 123456, "f")

You can also create a shortcut for the weather popup. In my rc.lua I've got this:

    awful.key({ altkey,  }, "w", function () perceptive.show_weather(5) end) 

Where altkey is set right below modkey like this:

    altkey = "Mod1"

So I can call the popup for 5 seconds pressing Alt+w.

Localization
-----
The default language is English, but if you wish to have a localization, you
have to add a proper file in ``localizations``. You'll find a
template to fill in the subdirectory. 

Once you're done, rename it like your locale id, without ".utf8". In my case:

    $ lua
    Lua 5.2.1  Copyright (C) 1994-2012 Lua.org, PUC-Rio
    > print(os.getenv("LANG"))
    it_IT.utf8
    > 

so my file (Italian localization) has been named "it_IT".

**NOTE:** If you create a localization, feel free to send me! I will add it.

Screenshot
-----
![Screenshot][1]

[1]: http://i.imgur.com/ycLqp26.png

License
-----
<a href="http://www.wtfpl.net"><img src="http://www.wtfpl.net/wp-content/uploads/2012/12/logo-220x1601.png"/></a>
