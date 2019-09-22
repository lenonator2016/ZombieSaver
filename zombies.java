import java.applet.*; 
import java.awt.*; 
import java.awt.image.*; 
import java.awt.event.*; 
import java.io.*; 
import java.net.*; 
import java.text.*; 
import java.util.*; 
import java.util.zip.*; 

public class zombies extends BApplet {
// Zombie Infection Simulation
// Kevan Davis, 16/8/03

int freeze;
int num=1000;
int speed=1;
int panic=5;
int human;
int panichuman;
int zombie;
int wall;
Being[] beings = new Being[4000];

void setup() 
{ 
  int x,y; 
  size(250,250); 
  human=color(200,0,200);
  panichuman=color(255,120,255);
  zombie=color(155,155,155);
  wall=color(50,50,60);

  noBackground(); 

  fill(color(0,0,0));
  rect(0,0,width,height); 
  fill(wall);
  stroke(color(0,0,0));
  for (int i=0; i<100; i++)
  {
    rect((int)random(width-1)+1, (int)random(height-1)+1,
         (int)random(60)+10, (int)random(60)+10); 
  }
  fill(color(0,0,0));
  for (int i=0; i<30; i++)
  {
    rect((int)random(width-1)+1, (int)random(height-1)+1,
         (int)random(20)+20,(int)random(20)+20); 

    x=(int)random(width-1)+1;
    y=(int)random(height-1)+1;
  }

  for(int i=0; i<4000; i++)
  { beings[i] = new Being(); beings[i].position(); }
  beings[1].infect();
  freeze=0;
} 
 
void loop() 
{ 
  if (freeze==0)
  {
    for(int i=0; i<num; i++) { 
      beings[i].move(); 
    } 
    if (speed==2) { delay(20); }
    else if (speed==3) { delay(50); }
    else if (speed==4) { delay(100); }
  }
} 

int look(int x, int y,int d,int dist)
{
  for(int i=0; i<dist; i++)
  {
    if (d==1) { y--; }
    if (d==2) { x++; }
    if (d==3) { y++; }
    if (d==4) { x--; }

    if (x>width-1 || x<1 || y>height-1 || y<1)
    { return 3; }
    else if (getPixel(x,y) == wall)
    { return 3; }
    else if (getPixel(x,y) == panichuman)
    { return 4; }
    else if (getPixel(x,y) == human)
    { return 2; }
    else if (getPixel(x,y) == zombie)
    { return 1; }
  }
  return 0;
}

void keyPressed() 
{ 
  if(key == ' ')
  {
    for(int i=0; i<num; i++)
    { beings[i].uninfect(); }
    beings[1].infect();
  } 
  if(key == 's' || key == 'S')
  {
    speed++;
    if (speed>4) { speed=1; }
  }
  if(key == 'p' || key == 'P')
  {
    panic = 5 - panic;
  }
  if(key == 'g' || key == 'G')
  {
    if (zombie==color(155,155,155))
    { zombie=color(0,255,0); }
    else
    { zombie=color(155,155,155); }
  }
  if(key == '+' && num < 4000) { num += 100; key='z'; }
  if(key == '-' && num > 100) { num -= 100; key='z'; }
  if(key == 'z' || key == 'Z')
  {
    freeze=1;
    setup(); 
  }
}

class Being
{ 
  int xpos, ypos, dir;
  int type, active;

  Being()
  {
    dir = (int)random(4)+1;
    type = 2;
    active = 0;
  }

  void position()
  {
    for (int ok=0; ok<100; ok++)
    {
      xpos = (int)random(width-1)+1; 
      ypos = (int)random(height-1)+1;
      if (getPixel(xpos,ypos)==color(0,0,0)) { ok = 100; }
    }
  }

  void infect(int x, int y)
  {
    if (x==xpos && y==ypos)
    { type = 1; }
  }

  void infect()
  { type = 1; setPixel(xpos, ypos, zombie); }

  void uninfect()
  { type = 2; }

  void move()
  {
    int r = (int)random(10);
    if ((type==2 && (active>0 || r>panic)) ||
        r==1)
    {
      setPixel(xpos, ypos, color(0,0,0));

      if (look(xpos,ypos,dir,1)==0)
      {
        if (dir==1) { ypos--; }
        if (dir==2) { xpos++; }
        if (dir==3) { ypos++; }
        if (dir==4) { xpos--; }
      }
      else
      {
        dir = (int)random(4)+1; 
      }

      if (type == 1)
      { setPixel(xpos, ypos, zombie); }
      else if (active > 0)
      { setPixel(xpos, ypos, panichuman); }
      else
      { setPixel(xpos, ypos, human); }
      if (active>0) {active--;}
    }

    int target = look(xpos,ypos,dir,10);

    if (type==1)
    {
      if (target==2 || target==4) { active = 10; }

      if (active==0 && target!=1) { dir = (int)random(4)+1; }
 
      int victim = look(xpos,ypos,dir,1);
      if (victim == 2 || victim==4)
      {
        int ix = xpos; int iy = ypos;
        if (dir==1) { iy--; }
        if (dir==2) { ix++; }
        if (dir==3) { iy++; }
        if (dir==4) { ix--; }
        for(int i=0; i<num; i++)
        { 
          beings[i].infect(ix,iy); 
        }
      }  
    }
    if (type==2)
    {
      if (target==1 || target==4)
      { active=10; }
      if (target==1)
      {       
        dir = dir + 2; if (dir>4) { dir = dir - 4; } 
      }
      if ((int)random(8)==1) { dir = (int)random(4)+1; }
    }
  }
}
}