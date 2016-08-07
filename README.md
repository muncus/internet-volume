# Internet Volume Control.

:warning: this is a work in progress. :warning:

The internet is full of useful information, but with the rise of social media,
there is also a lot of time-wastey Skinnerbox-style sites that keep you coming
back with squirts of dopamine. To help curb this behavior, i've started
developing the Internet Volume Control, which helps give back some control over
how much Noise the internet can deliver.

## Overview

The actual control limiting is done by a custom DNS server, which responds
depending on what the current internet "volume" is. Sites which are very noisy
(e.g. Facebook), are cut off at all but the highest volume levels. Less noisy
sites continue to work, until you dial down the volume. At the lowest volume
level, nothing works.

The Volume Knob - really just a standalone control to manipulate the volume
level. Design still TBD, but could easily be built with a potentiometer and a
little wifi micro, like an esp8266, or a particle photon.

For storing the actual volume level, i'm using http://io.adafruit.com/
