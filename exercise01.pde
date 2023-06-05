/* @pjs preload="level.txt",
"tilesheet.png"; */
editor ed;

void settings()
{
  size(WIDTH, HEIGHT);
}

void setup()
{
 ed = new editor();
}

void draw()
{
  background(BG_LEVEL);
   
  ed.displayLevel();
  ed.displayEditortiles();
  ed.displayInfoBar();
  ed.highlight(mouseX, mouseY);
}

//gives the offset with which the level must be displayed
//each mousewheel movement moves the level of half the size of a tile
void mouseWheel(MouseEvent event)
{
  ed.setOffsetX((TILESIZE/2) * event.getCount());
}

void mouseClicked()
{
  ed.checkSelection(mouseX, mouseY);
}

void mouseDragged()
{
  ed.checkDragging(mouseX, mouseY);
}

//a multi-purpose button class

class button
{
  private String label;
  private float posX;
  private float posY;
  private float sizeX;
  private float sizeY;
  private color bg_color;
  private color label_color;
  
  
  button(String label, float posX, float posY, float sizeX, float sizeY)
  {
    this.label = label;
    this.posX = posX;
    this.posY = posY;
    this.sizeX = sizeX;
    this.sizeY = sizeY;
  }
   
  void display()
  {
   fill(bg_color);
   stroke(0,0,0);
   rect(posX, posY, sizeX, sizeY);
   fill(label_color);
   text(label, posX + (sizeX/8), posY + (sizeY/8), sizeX - (sizeX/4), sizeY - (sizeY/4));
  }
  
  //check if the given position is inside the button area
  boolean check(float x, float y)
  {
    if ( (x > posX) && (x < posX + sizeX) && (y > posY) && (y < posY + sizeY) )
      return true;
    return false;
  }
  
  
  void setBgColor(color bg_color)
  {
    this.bg_color = bg_color;
  }
  /* TODO cancella
  void setLabelColor(color label_color)
  {
    this.label_color = label_color;
  }
  */

}

//level
String LEVELFILE = "level.txt";


//editor
color BG_LEVEL = color(200);
color BG_TILESHEET = color(200, 50, 150);
color BG_INFOBAR = color(150, 100, 200);
color HL_COLOR = color(255, 255, 0);
color SELECTED = color(255, 0, 0);
color SB_STANDARD = color(255, 255, 255);


//tiles
int STARTASCII = 46;
String TILESHEET = "tilesheet.png";
int TILESIZE = 32;

//sizes
int VERTICALTILES = 8;
int HORIZONTALTILES = 10;
int INFOBARSIZE = TILESIZE;
int WIDTH = HORIZONTALTILES * TILESIZE; //320;
int HEIGHT = VERTICALTILES * TILESIZE * 2 + INFOBARSIZE; //256;

//class that represents the level editor
//all the functionalities pass trhough this class
//so it works as a manager class that sets up the editor
//and forwards the input to the necessary objects

class editor
{
  //objects that hold the level shown and the "editor tiles" section
  private level lev;
  private editortiles edt;
  
  //the selected tile and the higlighted one
  private edtile selectedTile;
  private tile hltile;
  
  //infobar variables
  private String infoText;
  private button sb;
  
  private float offsetX;
  private int rightBorderOffset;
  private PImage tilesheet;
  
  editor()
  {
    infoText = new String();
    offsetX = 0;
    selectedTile = null;
    tilesheet = loadImage(TILESHEET);
    
    //load and setup the level
    String[] lines = loadStrings(LEVELFILE);
    rightBorderOffset = (lines[0].length() * TILESIZE * -1) + (TILESIZE * HORIZONTALTILES);
    lev = new level(lines, tilesheet);
    
    //load and setup the tilesheet
    edt = new editortiles(tilesheet, 0, TILESIZE * VERTICALTILES);
    
    //setup the info bar
    
    infoText = "Level loaded from data/" + LEVELFILE;
    
    //setup the save button
    sb = new button("Save", 4, (TILESIZE * VERTICALTILES) + tilesheet.height + 4, TILESIZE*3, TILESIZE - 8);
    sb.setBgColor(SB_STANDARD);
    
  }
  
  void displayLevel()
  {
    lev.display();
  }
  
  void displayEditortiles()
  {
    fill(BG_TILESHEET);
    noStroke();
    rect(0, TILESIZE * VERTICALTILES, tilesheet.width, tilesheet.height);
    edt.display();
    if (selectedTile != null)
      selectedTile.displaySelection();
  }
  
  void displayInfoBar()
  {
    fill(BG_INFOBAR);
    noStroke();
    rect(0, (TILESIZE * VERTICALTILES) + tilesheet.height, tilesheet.width, TILESIZE);
    
    //display save button
    sb.display();
    
    //display tile info
    text(infoText, sb.posX + (sb.sizeX) + 2, sb.posY + (sb.sizeY/8), WIDTH, sb.sizeY - (sb.sizeY/4) );
  }
  
  void setOffsetX(float off)
  {
    offsetX -= off;
    if (offsetX > 0)
      offsetX = 0;
    if (offsetX < rightBorderOffset)
      offsetX = rightBorderOffset;
    lev.setOffsetX(offsetX);
  }
  
  //highlight the tile that matches the given position
  void highlight(float x, float y)
  {
    if (y >= TILESIZE * VERTICALTILES) 
    {
      //in the editor tiles
      
      hltile = edt.highlight(x, y);

      if (hltile != null)
      {
        infoText = "Code " + char(hltile.getType());
        
        //show the editor tile in bigger size
        float spx = WIDTH - (TILESIZE * 2);
        float spy = 0;
        noStroke();
        fill(BG_TILESHEET);
        rect(spx, spy, TILESIZE*2, TILESIZE*2);
        image(hltile.getRefTile(), spx, spy, TILESIZE * 2, TILESIZE * 2);
      }
    }
    else
    {
      //in the level tiles
      
      hltile = lev.highlight(x, y);
      if (hltile != null)
        infoText = "Code " + char(hltile.getType());
    }
  }
  
  void saveLevel()
  {
    String[] toSave = new String[lev.rows];
    for (int i = 0; i < toSave.length; i++)
    {  
      toSave[i] = "";
    }
    for (tile t : lev.tiles)
      toSave[int(t.getPosY() / TILESIZE)] += char(t.getType());
    saveStrings("data/" + LEVELFILE, toSave);
    infoText = "Level saved to data/" + LEVELFILE;
      
  }
  
  void checkSelection(float x, float y)
  {
    //avoid interacting outside the canvas
    //probably not useful, but let's use a safe approach
    if ( (x < 0) || (x > WIDTH) )
      return;
  
    if (y >= TILESIZE * VERTICALTILES)
    {
      //given position is inside the editor part
      
      //check if using the save button
      if ( y > (TILESIZE * VERTICALTILES) + tilesheet.height)
      {
        if (sb.check(x, y))
        {
          saveLevel();
          sb.setBgColor(SB_STANDARD);
        }
      }
      
      //check if selecting an editor tile
      edtile t = edt.selectTile(x, y);
      if (t == null)
        return; //no editor tile has been selected
      if (selectedTile != null)
        selectedTile.setSelected(false); //TODO: is this really important?
      selectedTile = t;
      selectedTile.setSelected(true);
    }
    else
    {
      //given position is inside the level part
      if (selectedTile != null)
      {
        lev.replaceTile(x, y, selectedTile);
        //a change has been made so the save button "state" changes, indicating not saved changes have been made
        sb.setBgColor(SELECTED);       
      }
    }
  }
  
  void checkDragging(float x, float y)
  {
    //avoid interacting outside the canvas
    if ( (x < 0) || (x > WIDTH) )
      return;
    //if inside the canvas
    if ( (y < TILESIZE * VERTICALTILES) && (selectedTile != null) )
    {
      lev.replaceTile(x, y, selectedTile);
      sb.setBgColor(SELECTED);
    }
  }
  
}

//a class made for managing editor tiles, namely the ones you can select and
//put in place of others in the actual level

class editortiles
{
  private edtile[] tiles;
  
  editortiles(PImage tilesheet, float startPosX, float startPosY)
  {
    //create tiles
    tiles = new edtile[(tilesheet.width / TILESIZE) * (tilesheet.height / TILESIZE)];
    for (int i = 0; i < tiles.length; i++)
    {
      tiles[i] = new edtile();
    }
    
    //initialize tiles
    int type = STARTASCII;
    int tileNumber = 0;
    for (int y = 0; y < (tilesheet.height / TILESIZE); y++)
    {
      for (int x = 0; x < (tilesheet.width / TILESIZE); x++)
      {
        tiles[tileNumber].init(tilesheet, tileNumber, (startPosX + (x * TILESIZE)), (startPosY + (y * TILESIZE)), type);
        type++;
        tileNumber++;
      }
    }
  }
  
  void display()
  {
    for (tile t : tiles)
      t.display();
  }
  
  //higlight a tile only if the given position is inside its area
  tile highlight(float x, float y)
  {
    for (tile t : tiles)
    {
      if (t.check(x, y))
      {
        t.highlight();
        return t;
      }
    }
    return null;
  }
  
  //function that should be called when attempting to select a tile
  edtile selectTile(float x, float y)
  {
    for (edtile t : tiles)
    {
      if (t.check(x, y))
        return t;
    }
    return null;
  }
  
  /* TODO cancella
  edtile[] getEdtiles()
  {
    return tiles;
  }
  */
}

//class that represents an editor tile, namely one that can
//replace a tile in the actual level

class edtile extends tile
{
  private boolean selected;  //is it useful?
  
  edtile()
  {
    super();
    selected = false;
  }
  
  void displaySelection()
  {
    noFill();
    stroke(SELECTED);
    strokeWeight(2);
    rect(posX + 1, posY + 1, TILESIZE - 2, TILESIZE - 2);  
  }
  
  boolean getSelected()
  {
    return selected;
  }
  
  void setSelected(boolean selected)
  {
    this.selected = selected;
  }
}

//a class for managing the tiles of the level shown
//the level can be of any horizontal length
//but vertical length must be 8 tiles

class level
{
  private tile[] tiles;
  private int columns;
  private int rows;
  
  level(String[] lines, PImage tilesheet)
  {
    rows = lines.length;
    columns = lines[0].length();
    
    //create tiles
    tiles = new tile[rows * columns];
    for (int i = 0; i < tiles.length; i++)
    {
      tiles[i] = new tile();
    }
    
    //initialize tiles
    int tileNumber = 0;
    for (int y = 0; y < rows; y++)
    {
      for (int x = 0; x < columns; x++)
      {
        tiles[tileNumber].init(tilesheet, tileNumber, x * TILESIZE, y * TILESIZE, int(lines[y].charAt(x)));
        tileNumber++;
      }
    }
  }

  void setOffsetX(float offsetX)
  {
    for (tile t: tiles)
      t.setOffsetX(offsetX);
  }
  
  void display()
  {
    for (tile t : tiles)
      t.display();
  }
  
  //higlight a tile only if the given position is inside its area
  tile highlight(float x, float y)
  {
    for (tile t : tiles)
    {
      if (t.check(x, y))
      {
        t.highlight();
        return t;
      }
    }
    return null;
  }
  
  //replace a tile with the provided one only if the position is inside its area
  void replaceTile(float x, float y, tile et)
  {
    for (tile t : tiles)
      if (t.check(x, y))
      {
        t.setType(et.getType());
        t.setRefTile(et.getRefTile());
      }
  }
  
  /* TODO cancella
  tile[] getTiles()
  {
    return tiles;
  }
  
  int getColumns()
  {
    return columns;
  }
  
  int getRows()
  {
    return rows;
  }
  */
}

//class that represents a tile

class tile
{
  protected float initialPosX;
  protected float posX;
  protected float posY;
  protected int tileNumber; //TODO: is this really useful?
  protected int type = -1;
  protected PImage refTile;
  
  tile()
  {}
  
  void init (PImage tilesheet, int tileNumber, float posX, float posY, int type)
  {
    this.tileNumber = tileNumber;
    this.posX = posX;
    this.initialPosX = posX;
    this.posY = posY;
    this.type = type;
    int asciiCode = type - STARTASCII;
    int sheetX = asciiCode % (tilesheet.width / TILESIZE);
    int sheetY = asciiCode / (tilesheet.width / TILESIZE);
    refTile = tilesheet.get(sheetX * TILESIZE, sheetY * TILESIZE, TILESIZE, TILESIZE);
  }
  
  void setOffsetX(float offsetX)
  {
    posX = initialPosX + offsetX;
  }
  
  void display()
  {
    image(refTile, posX, posY);
  }
  
  void highlight()
  {
    noFill();
    stroke(HL_COLOR);
    strokeWeight(2);
    rect(posX + 1, posY + 1, TILESIZE - 2, TILESIZE - 2);
  }  
  
  //check if the given position is inside the tile
  boolean check(float x, float y)
  {
    return ( (x > posX) && (x < posX + TILESIZE) && (y > posY) && (y < posY + TILESIZE) );
  }
  
  //getter (not all used)
  float getInitialPosX()
  {
    return initialPosX;
  }
  
  float getPosX()
  {
    return posX;
  }
  
  float getPosY()
  {
    return posY;
  }
  
  int getTileNumber()
  {
    return tileNumber;
  }
  
  int getType()
  {
    return type;
  }
  
  PImage getRefTile()
  {
    return refTile;
  }
  
  //setter (not all used)
  void setInitialPosX(float initialPosX)
  {
    this.initialPosX = initialPosX;
  }
  
  void setPosX(float posX)
  {
    this.posX = posX;
  }
  
  void setPosY(float posY)
  {
    this.posY = posY;
  }
  
  
  void setTileNumber(int tileNumber)
  {
    this.tileNumber = tileNumber;
  }
  
  void setType(int type)
  {
    this.type = type;
  }
  
  void setRefTile(PImage refTile)
  {
    this.refTile = refTile;
  }
  
}
