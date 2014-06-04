// John Nguyen 
// Thomas Truong
// Anthony So
// ICS 168 Swarch on Androi - Java Server

/*
 * OscP5 and NetP5 Protocols used to setup the server
 * @NetAddressList - stores players IP
 */
import oscP5.*;
import netP5.*;
OscP5 oscP5;
NetAddressList myNetAddressList = new NetAddressList();

/*
 * @int myListeningPort - set server incoming message port to 32000
 */
int myListeningPort = 32000;

/*
 * Database
 */
Database datab;

/*
 * @String myConnectPattern - Message server look for from client to connect
 * @String myDisconnectPattern - Message server look for from client to disconnect
 */
String myConnectPattern = "Connecting...";
String myDisconnectPattern = "Disconnecting...";

/*
 * @String userName - string variable that store userName from db.getString()
 * @String passWord - string variable that stores password from db.getString()
 */
String userName;
String passWord;

//food coordinate
float[] xCoord;
float[] yCoord;

//cube position
float[] xCube;
float[] yCube;

int[] players;
int[] dir;
boolean started;
int s;

float[] rgb;

int p1score, p2score;
int[] score;
int[] wCube;
int[] hCube;
String[] IP;
boolean[] pStatus;
int cWidth, cHeight;


void setup() 
{

  p1score = 0;
  p2score = 0;
  pStatus = new boolean[2];
  wCube = new int[2];
  hCube = new int[2];
  IP = new String[2];
  pStatus[0] = false;
  pStatus[1] = false;
  IP[0] = null;
  IP[1] = null;
  cWidth = 50;
  cHeight = 50;
  for (int i = 0; i < 2; i++)
  {
    wCube[i] = cWidth;
    hCube[i] = cHeight;
  }
  score = new int[2];
  started = false;
  players = new int[3];
  dir = new int[3];
  dir[0] = 0; 
  dir[1] = 0; 
  dir[2]=0;

  /*
   * Creates a new oscP5 Instance using myListening Port
   * and is in TCP mode
   */
  oscP5 = new OscP5(this, myListeningPort, OscP5.TCP);
  frameRate(60);

  //database
  datab = new Database(this);
  datab.connect();

  xCoord = new float[4];
  yCoord = new float[4];

  for (int i = 0; i < 4; ++i)
  {
    xCoord[i] = random(15, displayWidth - 70);
    yCoord[i] = random(15, displayHeight - 60);
  }

  xCube = new float[2];
  yCube = new float[2];


  for (int i = 0; i < 2; ++i)
  {
    xCube[i] = random(15, displayWidth - 70);
    yCube[i] = random(15, displayHeight - 60);
  }

  rgb = new float[6];
  for (int i = 0; i < 6; ++i)
  {
    rgb[i] = random(255);
  }
}

void draw() 
{

  /*
   * constantly updates @ 60 frames for server functions
   */
  background(0);
  if (started)
  {
    if (myNetAddressList.size() > 0)
    {
      move();
      unitCollison();

      //There are 2 for loops so the order of the message sent comes to
      //the client in x_1, x_2, ..., x_n, y_1, y_2, ..., y_n format instead of
      //x_1, y_1, ..... x_n, y_n

        OscMessage m2 = new OscMessage("Move Objects");
      m2.add(myNetAddressList.list ().size());
      for (int k = 0; k < myNetAddressList.list ().size(); k++)
      {
        m2.add(xCube[k]);
      }    
      for (int l = 0; l < myNetAddressList.list ().size(); l++)
      {
        m2.add(yCube[l]);
      }
      if (pStatus[0] == false || pStatus[1] == false)
        m2.add(0);
      else 
        m2.add(1);
      oscP5.send(m2);

      unitCollison();
    }
  }
}

void move()
{
  for (int i = 1; i < myNetAddressList.list ().size()+1; i++)
  {

    if (dir[i] == 1)
    {
      xCube[i-1] -= 3;
    } 
    else if (dir[i] == -1)
    {
      xCube[i-1] += 3;
    } 
    else if (dir[i] == -2)
    {
      yCube[i-1] -= 3;
    } 
    else if (dir[i] == 2)
    {
      yCube[i-1] += 3;
    }
  }//end for
}

void unitCollison()
{
  int pOneCenter = (int)(25 /3); // makes sure the bounds are updated before checking for collision.

  for (int h = 0; h < myNetAddressList.list ().size(); h++)
  {
    for (int i = 0; i < 4; i++)
    {
      if ((xCube[h]+hCube[h] - 15  >= xCoord[i]  && xCube[h] <= xCoord[i] + 35) 
        && (yCube[h]+wCube[h]   >= yCoord[i] &&  yCube[h]  <= yCoord[i]  + 35))
      {
        OscMessage food = new OscMessage("Food respawn");
        xCoord[i] = random(15, displayWidth - 70);
        yCoord[i] = random(15, displayHeight - 60);
        food.add(i);
        food.add(xCoord[i]);
        food.add(yCoord[i]);
        food.add(h);
        if (h + 1 == 1)
        {
          p1score += 1;
          food.add(p1score);
          score[h] = p1score;
        }
        else if (h + 1 == 2)
        {
          p2score += 1;
          food.add(p2score);
          score[h] = p2score;
        }

        hCube[h] = cHeight + (score[h] * 10);
        wCube[h] = cWidth + (score[h] * 10);

        oscP5.send(food);
        println("hit! " + " xCoord[i]: " + xCoord[i] + " yCoord[i]: "+ yCoord[i]);
      }
      else if ( ((xCube[h]+ wCube[h] > 1920 - 100)|| (xCube[h] + 10 < 0) || 
        (yCube[h] + hCube[h] > 1080) || yCube[h] + 10 < 0) && pStatus[h] != false)
      {
        OscMessage edge = new OscMessage("Edge Collison");
        xCube[h] = random(25, displayWidth - 70);
        yCube[h] = random(25, displayHeight - 60);
        edge.add(xCube[h]);
        edge.add(yCube[h]);
        edge.add(h);

        if (h+1 == 1)
        {
          p1score = 0;
          edge.add(p1score);
          score[h] = p1score;
        }
        else if (h+1 == 2)
        {
          p2score = 0;
          edge.add(p2score);
          score[h] = p2score;
        }

        hCube[h] = cHeight;
        wCube[h] = cWidth;

        oscP5.send(edge);
      }
      else
      {
        if (p1score > p2score)
        {
          if ((xCube[0] + hCube[0] - 15 >= xCube[1] && xCube[0] <= xCube[1] + hCube[1]) &&
            (yCube[0] + wCube[0] >= yCube[1] && yCube[0] <= yCube[1] + wCube[1]))
          {
            OscMessage playerC = new OscMessage("Player Collison");
            xCube[1] = random(25, displayWidth - 70);
            yCube[1] = random(25, displayHeight - 60);
            playerC.add(xCube[1]);
            playerC.add(yCube[1]);
            playerC.add(0);
            p1score += 10;
            p2score = 0;
            playerC.add(p1score);
            playerC.add(p2score);
            oscP5.send(playerC);
            hCube[h] = cHeight + (score[h] * 10);
            wCube[h] = cWidth + (score[h] * 10);
          }
        }
        else if (p2score > p1score)
        {
          if ((xCube[1] + hCube[1] - 15 >= xCube[0] 
            && xCube[1] <= xCube[0] + hCube[0]) &&
            (yCube[1] + wCube[1] >= yCube[0] && yCube[1] <= yCube[0] + wCube[0]))
          {

            OscMessage playerC = new OscMessage("Player Collison");


            xCube[0] = random(25, displayWidth - 70);
            yCube[0] = random(25, displayHeight - 60);
            playerC.add(xCube[0]);
            playerC.add(yCube[0]);
            playerC.add(1);
            p1score = 0;
            p2score += 10;
            playerC.add(p2score);
            playerC.add(p1score);
            oscP5.send(playerC);

            hCube[h] = cHeight + (score[h] * 10);
            wCube[h] = cWidth + (score[h] * 10);
          }
        }
        else if (p2score == p1score)
        {
          if ((xCube[1] + hCube[1] - 15 >= xCube[0] 
            && xCube[1] <= xCube[0] + hCube[0]) &&
            (yCube[1] + wCube[1] >= yCube[0] && yCube[1] <= yCube[0] + wCube[0]) ||
            (xCube[0] + hCube[0] - 15 >= xCube[1] && xCube[0] <= xCube[1] + hCube[1]) &&
            (yCube[0] + wCube[0] >= yCube[1] && yCube[0] <= yCube[1] + wCube[1]))
          {
            OscMessage pce = new OscMessage("Player Collison Tie");


            xCube[0] = random(25, displayWidth - 70);
            yCube[0] = random(25, displayHeight - 60);
            score[0] = 0;
            xCube[1] = random(25, displayWidth - 70);
            yCube[1] = random(25, displayHeight - 60);
            score[1] = 0;
            for (int k = 0; k < myNetAddressList.list ().size(); k++)
            {
              pce.add(xCube[k]);
            }    
            for (int l = 0; l < myNetAddressList.list ().size(); l++)
            {
              pce.add(yCube[l]);
            }

            oscP5.send(pce);
          }
        }
      }
    }
  }
}

void oscEvent(OscMessage theOscMessage)
{
  /* Check to see if client messages fits any of the server patterns */
  if (theOscMessage.addrPattern().equals(myConnectPattern)) 
  {
    connect(theOscMessage.netAddress().address());

    //testing send message was successful
    OscMessage m = new OscMessage("Connection Successful!");
    //This sends the above message to all clients connected.
    oscP5.send(m, theOscMessage.tcpConnection());
  } 
  else if (theOscMessage.addrPattern().equals("Disconnecting..."))
  {
    disconnect(theOscMessage.netAddress().address());
  }
  else if (theOscMessage.addrPattern().equals("Reconnecting..."))
  {
    connect(theOscMessage.netAddress().address());
  }
  else if (theOscMessage.addrPattern().equals("Direction"))
  {
    dir[theOscMessage.get(0).intValue()] = theOscMessage.get(1).intValue();
  }
  //handles user registration
  //check that if incoming message is not blank run the code inside
  else if (!theOscMessage.get(0).stringValue().equals(""))
  {
    if (datab.isConnected())
    {
      userName = datab.userName(theOscMessage.get(0).stringValue());
      passWord = datab.password(theOscMessage.get(0).stringValue(), theOscMessage.get(1).stringValue());
      println(userName + " " + passWord);
      /*
       * if Player doesn't exist in the database
       * print out a comment to console giving current state
       * Insert into table the current userName/Password from client
       * Send to client a Successful registration and start the game
       */
      if (userName == null) 
      {
        println("Player is not in the database yet");
        //add player
        datab.addToDb(theOscMessage.get(0).stringValue(), theOscMessage.get(1).stringValue());

        OscMessage m2 = new OscMessage("Authenticated");
        for (int i = 0; i < 4; ++i)
        {
          m2.add(xCoord[i]);
          println("x:" + xCoord[i]);
        }
        for (int j = 0; j < 4; ++j)
        {
          m2.add(yCoord[j]);
          println("y:" + yCoord[j]);
        }
        m2.add(myNetAddressList.list().size());
        for (int k = 0; k < myNetAddressList.list ().size(); k++)
        {
          m2.add(xCube[k]);
          println("x cube:" + xCube[k]);
        }    
        for (int l = 0; l < myNetAddressList.list ().size(); l++)
        {
          m2.add(yCube[l]);
          println("y cube:" + yCube[l]);
        }
        for (int i = 0; i < 6; ++i)
        {
          m2.add(rgb[i]);
        }

        oscP5.send(m2, theOscMessage.tcpConnection());
        started = true;
      }
      /*
       * if both userName and Password are correct
       * print to console giving current state
       * then the player exist in the database that matches the criteria
       * authenticate the player and continue on to the game
       */
      else if (userName != null && passWord != null)
      {
        println("Player Exist and Password Match");
        //authenticate player

        OscMessage m2 = new OscMessage("Authenticated");
        for (int i = 0; i < 4; ++i)
        {
          m2.add(xCoord[i]);
          println("x:" + xCoord[i]);
        }
        for (int j = 0; j < 4; ++j)
        {
          m2.add(yCoord[j]);
          println("y:" + yCoord[j]);
        }
        m2.add(myNetAddressList.list ().size());
        for (int k = 0; k < myNetAddressList.list ().size(); k++)
        {
          m2.add(xCube[k]);
          println("x cube:" + xCube[k]);
        }    
        for (int l = 0; l < myNetAddressList.list ().size(); l++)
        {
          m2.add(yCube[l]);
          println("y cube:" + yCube[l]);
        }
        for (int i = 0; i < 6; ++i)
        {
          m2.add(rgb[i]);
        }

        oscP5.send(m2, theOscMessage.tcpConnection());
        started = true;
      }
      /*
       * If player exist but the incorrect password is given
       * print to console giving current state
       * send to client that an incorrect password was given
       * client will handle a try again password field
       */
      else if (userName != null && passWord == null)
      {
        println("Player Exist, but Password Doesn't Match");
        //send login screen again
        OscMessage m3 = new OscMessage("Incorrect Password");
        oscP5.send(m3, theOscMessage.tcpConnection());
      }
      //Disocnnection function
      else if (theOscMessage.addrPattern().equals(myDisconnectPattern)) 
      {
      }
      //if none of above match than message all clients.
      else 
      {
        oscP5.send(theOscMessage, theOscMessage.tcpConnection());
      }
    }
  }
}


/*
 * Handles new players connecting
 * If player isn't in the player ip address list
 * they are added. Otherwise they are connected.
 */
private void connect(String theIPaddress) 
{

  if (IP[0] == null)
  {
    xCube[0] = random(25, displayWidth - 70);
    yCube[0] = random(25, displayHeight - 60);
    IP[0] = theIPaddress;
    pStatus[0] = true;
    OscMessage m3 = new OscMessage("Disconnect");
    m3.add(1);
    m3.add(0);
    oscP5.send(m3);
  }
  else
  {
    xCube[1] = random(25, displayWidth - 70);
    yCube[1] = random(25, displayHeight - 60);
    IP[1] = theIPaddress;
    pStatus[1] = true;
    OscMessage m3 = new OscMessage("Disconnect");
    m3.add(2);
    m3.add(0);
    oscP5.send(m3);
  }

  if (!myNetAddressList.contains(theIPaddress, myListeningPort)) 
  {
    myNetAddressList.add(new NetAddress(theIPaddress, myListeningPort));

    println("### adding "+theIPaddress+" to the player list.");
  } 
  else 
  {
    println("### adding "+theIPaddress+" to the player list.");
  }
  println("### currently there are "+myNetAddressList.list().size()+" remote locations connected.");
}


private void disconnect(String theIPaddress) 
{
  if (IP[0].equals(theIPaddress))
  {
    xCube[0] = -100;
    yCube[0] = -100;
    IP[0] = null;
    pStatus[0] = false;
    OscMessage m3 = new OscMessage("Disconnect");
    m3.add(1);
    m3.add(0);
    oscP5.send(m3);
  }
  else
  {
    xCube[1] = -100;
    yCube[1] = -100;
    IP[1] = null;
    pStatus[1] = false;
    OscMessage m3 = new OscMessage("Disconnect");
    m3.add(2);
    m3.add(0);
    oscP5.send(m3);
  }
  if (myNetAddressList.contains(theIPaddress, myListeningPort)) 
  { 
    // myNetAddressList.remove(theIPaddress, myListeningPort);
    println("### removing "+theIPaddress+" from the list.");
  } 
  else 
  {
    println("### removing "+theIPaddress+" from the list.");
  }
  //println("### currently there are "+myNetAddressList.list().size());
}

