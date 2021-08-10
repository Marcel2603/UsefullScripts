# UsefullScripts
This repo contains scripts, which can be used by any Ubuntu PC

# Gradle.sh
This skript installs Gradle under `$HOME/.local/opt/gradle` and greate a symlink to `$HOME/.local/bin/gradle`

After that it just shows `gradle -v`. 

IMPORTANT: You need to extend your `$PATH` with the `$HOME/.local/bin`-folder (the script will remind you ;) )

## Usage
You just can execute the script. It will install gradle with the version 7.1.1

If you want a different version, simple execute `./gradle.sh $VERSION`
