# Nizubot Lua
 The new Nizubot written in Lua instead of C#.

# Installing required things
This bot runs on [Luvit](https://luvit.io/) and uses [Discordia](https://github.com/SinisterRectus/Discordia) with slash commands using [Discordia-Slash](https://github.com/GitSparTV/discordia-slash).
(Please note that my bot uses my custom forks of Discordia and Discordia-Slash, which include additional features I use. Although I submit pull requests for these features, they may not have been accepted yet. The installation commands in this README will install my forks, not the original repositories.)

To setup everything you first need to install Luvit which you can do by reading [Luvits instructions](https://luvit.io/install.html).

Once Luvit is installed you can start to install all the bots dependencies. First make sure you are in the bots directory before running any commands.

To install the Discordia fork, run the following commands:
```
lit install SinisterRectus/discordia #This is to install all dependencies of Discordia.
```
Now you need to remove discordia from the deps folder to then install the fork. (Keep all the other stuff in the deps folder)
```
git clone https://github.com/InZan123/discordia.git ./deps/discordia #This is to install the actual fork
```
 
To install the Discordia-Slash fork you run this command:
```
git clone https://github.com/InZan123/discordia-slash.git ./deps/discordia-slash
```
Discordia-Slash has a dependency which is [Discordia-Interactions](https://github.com/Bilal2453/discordia-interactions). 

To install Discordia-Interactions you run this command:
```
git clone https://github.com/Bilal2453/discordia-interactions.git ./deps/discordia-interactions
```

http-codec has an annoying issue which sometimes prevents the bot from starting. The issue was fixed in http-codec 3.0.7. To update it simply delete deps/http-codec.lua an then run this command:
```
lit install luvit/http-codec
```

This bot also uses coro-spawn. Here's how you install that.
```
lit install creationix/coro-spawn
```

If when running the bot you incounter an issue with Discordia-Slash or with Discordia, try updating them by running the following commands:
```
git -C ./deps/discordia-slash pull
```
```
git -C ./deps/discordia pull
```

Once all that is done, create a file called "token" with no extensions and put your bot token in there.

You should now be able to run the bot by running this command:
```
luvit main.lua
```

# Contributing
Feel free to contribute to this project! When contributing you agree to license your contribution under the terms of the GPL-3.0 license.
