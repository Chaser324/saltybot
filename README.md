# SaltyBot
## Automated SaltyBet stat tracking and betting.

*NOTE: Development on this project has been discontinued.*

*The SaltyBet Terms of Service prohibit automated betting and the site has been modified to make it 
much more difficult to perform stat tracking or intelligent automated betting.*

SaltyBot is intended to track the performance of fighters on the fake money gambling site 
[SaltyBet](http://www.saltybet.com/) and automatically place bets based on the fight history of
the competitors.

The basic approach is to build SaltyBot as two separate components:

* A site scraper for interacting with the SaltyBet website written as a [CasperJS](http://casperjs.org/) based script.
* A very simple NodeJS server that manages all of the data in a MongoDB database and accepts GET/POST/PUT requests from the scraper to access and update data. An front-end interface could be added to make this info publicly available and easily accessible.
