import java.util.concurrent.TimeUnit;
import java.io.*;

import javax.swing.JOptionPane;

import org.openqa.selenium.*;
import org.openqa.selenium.MutableCapabilities;
import org.openqa.selenium.By;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.firefox.*;
import org.openqa.selenium.firefox.FirefoxProfile;
import org.openqa.selenium.firefox.FirefoxDriver;
import org.openqa.selenium.interactions.Actions;
import org.openqa.selenium.Keys;

import org.jsoup.*;
import org.jsoup.Jsoup;
import org.jsoup.parser.*;
import org.jsoup.helper.Validate;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.select.Elements;

WebDriver driver = new FirefoxDriver();
JavascriptExecutor js;



//todo
//read spread sheet of url,max bid
//create arraylist url,max bid, current bid

ArrayList<ArrayList<String>> LISTINGS = new ArrayList<ArrayList<String>>();

void setup()
  {
    driver.get( "https://www.slapsale.com/ss/#!/signIn" );
    JOptionPane.showMessageDialog( null, "You have 60 seconds to type in your login details", "LOGIN", JOptionPane.INFORMATION_MESSAGE );
    
    LISTINGS = new ArrayList<ArrayList<String>>();
    try
      {
        BufferedReader br = new BufferedReader( new FileReader( new File( "SLAPSALESCRAPER.csv" ) ) );
        String line = br.readLine();
        
        int i = 0;
        
        while( line != null )
          {
            try
              {
                driver.get( line.split( "," )[ 6 ] );
                Thread.sleep( 2000 );
                Document doc = Jsoup.parse( driver.getPageSource() );
                
                String TIMETOEND;
                String PRICE;
                try
                  {
                    TIMETOEND = doc.getElementsByClass( "col-sm-8 non-edit" ).get( 0 ).text();
                  }
                catch( Exception e )
                  {
                     TIMETOEND = "";
                  }
                  
                try
                  {
                    PRICE = doc.getElementsByClass( "member-header-large ng-binding" ).get( 1 ).text().replace( "US $", "" );
                  }
                catch( Exception e )
                  {
                    PRICE = "";
                  }
                  
                if( Double.parseDouble( PRICE ) < ( Double.parseDouble( line.split( "," )[ 1 ] )*0.2 ) && TIMETOEND.split( "," )[ 0 ].contains( "11h" ) )
                  {
                    ArrayList<String> LISTING = new ArrayList<String>();
                    
                    LISTING.add( line.split( "," )[ 6 ] );
                    LISTING.add( ""+( Double.parseDouble( line.split( "," )[ 1 ] )*0.2 ) );
                    LISTING.add( PRICE );
                    LISTING.add( TIMETOEND.split( "," )[ 0 ] );
                    LISTINGS.add( LISTING );
                    
                    
                    println( ( Double.parseDouble( line.split( "," )[ 1 ] )*0.2 ) + "," + PRICE + "," + TIMETOEND.split( "," )[ 0 ] + "," + line.split( "," )[ 6 ] );
                  }
              }
            catch( Exception e )
              {
                
              }
              
            i++;
            line = br.readLine();
          }
          
        br.close();
      }
     catch( Exception e )
       {
         
       }
     
     int i = 0;
     for( ArrayList<String> LIST : LISTINGS )
       {
         println( LIST.get( 0 ) + "," + LIST.get( 1 ) );
         
         driver.get( LIST.get( 0 ) );
         driver.manage().timeouts().setScriptTimeout( 1, TimeUnit.SECONDS );
         js = ( JavascriptExecutor ) driver;
         
         try
           {
             Thread.sleep( 2000 );
           }
         catch( Exception e )
           {
           }
           
         ExecuteJavaScript( js, "document.getElementsByClassName( \"btn btn-primary\" )[2].click();" );
         
         
         try
           {
             double CurrentMaxBid = ( Double.parseDouble( LIST.get( 2 ) ) );
                 
             Document doc = Jsoup.parse( driver.getPageSource() );
             
             if( CurrentMaxBid < ( Double.parseDouble( doc.getElementsByClass( "member-header-large ng-binding" ).get( 1 ).text().replaceAll( "[^\\d-]", "" ) )/100 ) )
               {
                 ExecuteJavaScript( js, "document.getElementsByClassName( \"form-control input-inline-100 ng-pristine ng-untouched ng-valid ng-empty\" )[0].value=\"" + ( Double.parseDouble( doc.getElementsByClass( "member-header-large ng-binding" ).get( 1 ).text().replaceAll( "[^\\d-]", "" ) )/100 + 5 ) + "\"" );
                 CurrentMaxBid += 5;
                 LISTINGS.get( i ).set( 3, ""+CurrentMaxBid );
                 //ExecuteJavaScript( js, "document.getElementById( \"submitBidButton\" ).click();" );
                 println( "PLACED BID" );
                 Thread.sleep( 10000 );
               }
           }
         catch( Exception e )
           {
           }
           
         i++;
       }
     //document.getElementsByClassName( "member-header-large ng-binding" )[1].textContent
  }

void ExecuteJavaScript( JavascriptExecutor _js_, String code )
  {
    try
      {
        _js_.executeAsyncScript( code );
      }
    catch( Exception e )
      {
        //e.printStackTrace();
      }
  }
