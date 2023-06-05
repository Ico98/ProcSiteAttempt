
//Frogger with Classes sans collision detection yet
//Dace 2021

int gridSize = 64;
Frog froggie = new Frog(7 * gridSize);
Truck truckTop = new Truck(2 * gridSize, 11.7);  //maybe use an array for the trucks
Truck truckBottom = new Truck(5 * gridSize, 3.7);

void setup()
{
  size(640, 512);
  noStroke();
}

void drawField()
{
  background(0, 80, 0);
  for (int j = 0; j < height; j += gridSize)
  {
    for (int i = 0; i < width; i += gridSize)
    {
      fill(0, 120, 0);
      rect(i, j, gridSize, gridSize, 16);
      fill(0, 180, 0);
      rect(i + (gridSize * 0.25), j + (gridSize * 0.25), gridSize * 0.5, gridSize * 0.5);
    }
  }
}

void keyPressed()
{
  if (key == CODED)
  {
    if (keyCode == UP) { froggie.moveUp(); }  //note that this style of movement relies on the system's key repeat feature which might be different on different systems, and is beyond the program's control
    else if (keyCode == DOWN) { froggie.moveDown(); }
    else if (keyCode == LEFT) { froggie.moveLeft(); }
    else if (keyCode == RIGHT) { froggie.moveRight(); }
  }
}

void draw()
{
  drawField();
  froggie.display();
  truckTop.display();
  truckTop.update();
  truckBottom.display();
  truckBottom.update();
}


class Frog
{
  int posX = 0;
  int posY = 0;

  Frog(int initialPosY)
  {
    posY = initialPosY;
  }

  void display()
  {
    fill(220, 200, 0);
    ellipse(posX + (gridSize * 0.5), posY + (gridSize * 0.5), gridSize, gridSize);  //could use an image, of course...
  }

  void moveUp()
  {
    posY -= gridSize;
    if (posY < 0) { posY = 0; }
  }

  void moveDown()
  {
    posY += gridSize;
    if (posY >= height) { posY = height - gridSize; }
  }

  void moveLeft()
  {
    posX -= gridSize;
    if (posX < 0) { posX = 0; }
  }

  void moveRight()
  {
    posX += gridSize;
    if (posX >= width) { posX = width - gridSize; }
  }


}


class Truck
{
  float posX = 0;
  int posY = 0;
  float speed = 0;

  Truck(int initialPosY, float initialSpeed)
  {
    posY = initialPosY;
    speed = initialSpeed;
  }

  void display()
  {
    fill(220);
    rect(posX, posY, gridSize * 4, gridSize);
  }

  void update()
  {
    posX += speed;
    if ((posX + (gridSize * 4) < 0) || (posX >= width)) { speed = -speed; }
  }
}
