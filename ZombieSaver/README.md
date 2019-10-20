#  ZombieSaver

Around 15 years ago I came across a cool little zombie simulation, written as a Java applet. It still lives on the web at https://kevan.org/proce55ing/zombies/ although most browsers won't run it anymore. Basically, you start out with a bunch of humans and one zombie and slowly the human population turns into zombies (or do they?).

I thought it would be cool to turn it into an OS X screen saver - Apple had recently released a template project in XCode for creating screen savers, so I ported it to Objective-C and added a few modifications of my own. It worked great, except it was a bit slow on larger sceens (technical details below for those who care).

Over the years, I had it on my systems at home until one day it stopped working. I tried fixing it to work with modern versions of OS X but never got around to finishing it. Then swift came out and I figured I'd port it again for fun.

ZombieSaver should run on Catalina and Mojave, and maybe earlier versions of OS X. It will work on both retina and non-retina displays but not both at the same time.

Anyway, the original simulation instructions follow, along with my modifications (in bold)

Simulation Rules

Zombies are **red**, move very slowly and change direction randomly and frequently unless they can see something moving in front of them, in which case they start walking towards it. After a while they get bored and wander randomly again.

If a zombie finds a human standing directly in front of it, it bites and infects them; the human immediately joins the ranks of the undead.

Humans are **green** and run five times as fast as zombies, occasionally changing direction at random. If they see a zombie directly in front of them, they turn around and panic.

Panicked humans are **yellow** and run twice as fast as other humans. If a humans sees another panicked human, it starts panicking as well. A panicked humans who has seen nothing to panic about for a while will calm down again.

The simulation starts with a bunch of humans and one zombie.

Controls

**Press n to toggle between buildings and no buildings.**
Press s to alter the simulation speed.
Press space to uninfect all but **the starting number of zombies**.
Press z to reset to a new city.
Press + and - to adjust population by 100 (minimum of 100, maximum of 10,000).
Press p to toggle complete panic (as in v1).)
**Press l to toggle labels visibility**
**Press 1 through 5 to set the starting number of zombies and reset the simulation**
Press f to pause/unpause the simulation
**Press c to temporarily draw a circle around each zombie**

Notes:

The simulation will create an initial number of humans based on the size of your display, roughly 2000 beings for every 1000 points of horizontal resolution. More beings will make the simulation run slower, while less beings will speed things up. Macs released in the last 2-3 years will certainly perform much better than older Macs (Technical note: beings "look" around by examining the color of the pixels in front of them for a short distance. The code uses the getPixel function of NSBitMapImageRep, which I suspect under the covers just uses pointer arithmetic to find and read the appropriate pixel. I tried direct pointer access myself hoping it would be faster, but it didn't seem any faster. In the Objective-C days, using NSReadPixel was **definitely** slower than reading the bitmap directly. The applet runs screaming fast, but it's just drawing into a tiny view, whereas we all have retina displays with millions of pixels).

Known Issues:

Having a setup that uses a retina and a non-retina display simultaneously will not work properly.
It is possible to create a city with humans cut off from other humans. It doesn't happen often, but it can.

