# PWDev README

## The Problem

So here's the deal: I sometimes clone other people's repos to play with their code or test things out. It's rare that these have a flake and I refuse to put dev tools in my global environment. But I don't want to have to build a flake for every project I download just to try running it.

## The Solution

To make my life easier, I'm setting up some default basic environments for different languages that have the libraries and tools I'll likely need much of the time. I can "install" other things I may need as one-offs if required. So if I clone a rust project and just want some basic rust tools, I just use `nix develop github:zmre/pwdev#rust`. For typescript on node24, I just do `nix develop github:zmre/pwdev#ts24`. 

That's it. I'll add more languages and probably more generally unnecessary libraries and tools with time to increase my chances of success and to make this more useful to me.
