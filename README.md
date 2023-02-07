# Nizubot Lua
 The new Nizubot written in Lua instead of C#.

# Installing required things
This bot runs on [Luvit](https://luvit.io/) and uses [Discordia](https://github.com/SinisterRectus/Discordia) with slash commands using [Discordia-Slash](https://github.com/GitSparTV/discordia-slash).

To setup everything you first need to install Luvit which you can do by reading [Luvits instructions](https://luvit.io/install.html).

Once Luvit is installed you can start to install all the bots dependencies. First make sure you are in the bots directory before running any commands.

To install Discordia you run this command:
```
lit install SinisterRectus/discordia
```
 
To install Discordia-Slash you run this command:
```
git clone https://github.com/GitSparTV/discordia-slash.git ./deps/discordia-slash
```
Discordia-Slash has a dependency which is [Discordia-Interactions](https://github.com/Bilal2453/discordia-interactions). 

To install Discordia-Interactions you run this command:
```
git clone https://github.com/Bilal2453/discordia-interactions.git ./deps/discordia-interactions
```

Once all that is done, create a file called "token" with no extensions and put your bot token in there.

You should now be able to run the bot by running this command:
```
luvit main.lua
```

# Contributing
Feel free to contribute to this project! When contributing you agree to license your contribution under the terms of the GPL-3.0 license.
