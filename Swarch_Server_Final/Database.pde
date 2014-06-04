/*
 * SQLite DB
 * Uses BezierSQLib for Processing
 */
import java.sql.*;
import de.bezier.data.sql.*;
  
SQLite db;

public class Database
{ 

  public Database(Swarch_Server_1 ss)
  {
      /*
       * Creates a instance of SQLite that opens
       * an account database file which currently
       * holds a table "table1" and "player" 
       * and "password" columns
       */
      db = new SQLite(ss, "account.db"); //opens the account database file
  }
  
  boolean isConnected()
  {
    return db.connect();
  }
  
  void connect()
  {
    if (db.connect())
    {
  
      //Example of how to insert into table
      //db.query(" insert into table1 values ('anthony', '123')");
  
      //How to delete the entire table1
      //db.query("delete from table1");
  
      //list table names
      db.query( "SELECT name as \"Name\" FROM SQLITE_MASTER where type=\"table\"" );

      while (db.next ())
      {
        println(db.getString("Name") );
      }

      //read from "table1"
      db.query( "SELECT * FROM table1" );
  
      //print out user and password in the database when server starts up.
      while (db.next ())
      {
        print("Username: " + db.getString("Player") + " Password: " + db.getString("Password"));
        println();
      }
    }
  }
  
  
  String userName(String user)
  {
    if (db.connect())
    {
     //Look for userName in Player and store it in userName
     db.query("SELECT * FROM table1 where player = '" +user +"'");
     return db.getString("Player");
    }
    else
    return "Databaseisnotconnected";
  }
  
  String password(String user, String pass)
  {
    if(db.connect())
    {
      //Query for a player and password that matches in both columns and store in passWord
      db.query("SELECT * FROM table1 where player = '" + user +"' and password = '" + pass + "'");
      return db.getString("Password");
    }
    else
    return "Databaseisnotconnected";
  }
  
  void addToDb(String user, String pass)
  {
    if(db.connect())
    {
       db.query("INSERT into table1 values ('"+user+"', '"+pass+"')");
    }

  }
}
