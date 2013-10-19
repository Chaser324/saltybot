# saltybot

*Note: Development on this project has been discontinued.*
*The SaltyBet TOS prohibits automated betting and the site has been modified to make it 
much more difficult to perform stat tracking or intelligent automatic bets.*

SaltyBot is intended to track the performance of fighters on the fake money gambling site 
[SaltyBet](http://www.saltybet.com/) and automatically place bets based on the fight history of
the competitors.

The basic approach is to build SaltyBot as two separate components:

* A site scraper for interacting with the SaltyBet website written as a CasperJS based script. If you've never used CasperJS, it's an offshoot of PhantomJS which is essentially just a headless WebKit browser. It's generally used for testing web apps, but I've found it to be extremely useful for web scraping, too.
* A very simple NodeJS server that manages all of the data in a MongoDB database and accepts GET/POST/PUT requests from the CasperJS scraper to access and update data. Part of my thought process for separating this portion out is that I could potentially build a nice looking interface and throw it up on a public webserver so that everyone could have access to this data.
