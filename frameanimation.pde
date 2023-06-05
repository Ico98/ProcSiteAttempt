/* @pjs preload="VvTa+h.png"; */
//Frame-Based Animation
//dace.de 2022

//If I had read the web site properly I would have noticed the sprite dimensions to be 50x37 pixedls... not a very common size.

/* 'License Permissions:
    You can do:
    - You can use this asset for personal and commercial purpose. Credit is not required but would be appreciated. 
    - Modify to suit your needs.
    You cannot do:
    - Resell/redistribute this asset.' (https://rvros.itch.io/animated-pixel-hero, Nov 16, 2022) */

int interval = 100;
int ticksLast = 0;
PImage spriteSheet = null;
int frame = 0;
int locationStartX = 86;
int locationStartY = 58;
int tileSize = 76;

void setup()
{
  size(320, 240);
  textSize(40);
  noFill();
  spriteSheet = loadImage("VvTa+h.png");
  ticksLast = millis();
}

void draw()
{
  background(222, 128, 80);
  int delta = millis() - ticksLast;
  if (delta >= interval)
  {
    frame++;
    if (frame > 5) { frame = 0; }
    ticksLast += delta;
  }
  image(spriteSheet.get(locationStartX + (frame * tileSize), locationStartY, tileSize, tileSize), 60, 80);
}
