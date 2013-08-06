
#================================================================================
# REQUIRE
#================================================================================

# Import confidential data/functions
userinfo = require './userinfo'

casper = require('casper').create 
    #verbose: true
    #logLevel: "debug"
    pageSettings: { loadImages: false, loadPlugins: false }

utils = require('utils')
f = utils.format

#================================================================================
# CONSTANTS
#================================================================================

loginUrl = 'http://www.saltybet.com/authenticate?signin=1'
baseUrl = 'http://www.saltybet.com/'

betStatusOpen = 'bets are open'
betStatusBlueWins = 'payouts to team blue'
betStatusRedWins = 'payouts to team red'
betStatusClosed = 'bets are locked until the next match'

#================================================================================
# VARIABLES
#================================================================================

currentTournament = ''

redFigher = ''
blueFigher = ''
redBet = 0
blueBet = 0

wagerFigther = ''
wagerAmount = 0
matchLength = 0

matchStartTime = 0

#================================================================================
#================================================================================
# Extending Casper functions for realizing label() and goto() - Allows for infinite loop
# See: https:#github.com/yotsumoto/casperjs-goto

casper.checkStep = (self, onComplete) ->
    if (self.pendingWait || self.loadInProgress)
        return
    self.current = self.step
    step = self.steps[self.step++]
    if utils.isFunction(step)
        self.runStep(step)
        step.executed = true
    else
        self.result.time = new Date().getTime() - self.startTime
        self.log(f("Done %s steps in %dms", self.steps.length, self.result.time), "info")
        clearInterval(self.checker)
        self.emit('run.complete')
        if utils.isFunction(onComplete)
            try
                onComplete.call(self, self)
            catch err
                self.log("Could not complete final step: " + err, "error")
        else
            self.exit()

casper.then = (step) ->
    if !@started
        throw new CasperError("Casper not started please use Casper#start")
    if !utils.isFunction(step)
        throw new CasperError("You can only define a step as a function")
    if @checker is null
        step.level = 0
        @steps.push(step)
        step.executed = false
        @emit('step.added', step)
    else
        if !@steps[@current].executed
            try
                step.level = @steps[@current].level + 1   # Changed:  (@step-1) is not always current navigation step
            catch e
                step.level = 0
            insertIndex = @step
            while @steps[insertIndex] && step.level is @steps[insertIndex].level
                insertIndex++
            @steps.splice(insertIndex, 0, step)
            step.executed = false
            @emit('step.added', step)
    return this

casper.label = ( labelname ) ->
    step = new Function('"empty function for label: ' + labelname + ' "')
    step.label = labelname
    @then(step)

casper.goto = ( labelname ) ->
    for i in [0...@steps.length] by 1
        if @steps[i].label == labelname
            @step = i

# End of Extending Casper functions for realizing label() and goto()
#================================================================================
#================================================================================


#================================================================================
# UTILITY FUNCTIONS
#================================================================================


#================================================================================
# STEP 1 - Sign into SaltyBet
#================================================================================
casper.start loginUrl, ->
    @fill 'form#signinform', { 'email': userinfo.username, 'pword': userinfo.password }, true


#================================================================================
# STEP 2 - Place Bets
#================================================================================
casper.label "PLACE_BETS"

# Wait for betting to be open
casper.wait 3000
casper.then ->
    betStatus = @evaluate -> $('#betstatus').text()
    if (betStatus.toLowerCase().indexOf betStatusOpen) < 0
        @goto "PLACE_BETS"
    
# Place bet
casper.then ->
    redFigher = @evaluate -> $('#p1name').text()
    blueFigher = @evaluate -> $('#p2name').text()

    wagerAmount = 10
    wagerFigther = redFigher

    @echo 'Current Match: ' + redFigher + ' vs ' + blueFigher
    @echo 'Betting ' + wagerAmount + ' on ' + wagerFigther

    @evaluate ((amount) -> $('#wager').val(amount)), wagerAmount
    if wagerFigther is redFigher
        @click 'input.betbuttonred'
    else if wagerFigther is blueFigher
        @click 'input.betbuttonblue'
    

#================================================================================
# STEP 3 - Get Betting Details
#================================================================================
casper.label "BETTING_CLOSED"

# Wait for betting to be open
casper.wait 3000
casper.then ->
    betStatus = @evaluate -> $('#betstatus').text()
    if (betStatus.toLowerCase().indexOf betStatusClosed) < 0
        @goto "BETTING_CLOSED"

casper.then ->
    @echo 'Getting betting details'
    redBet = @evaluate -> $('#player1wager').text()
    blueBet = @evaluate -> $('#player2wager').text()
    redBet = redBet.slice(1)
    blueBet = blueBet.slice(1)
    matchStartTime = new Date()


#================================================================================
# STEP 4 - Get Match Results
#================================================================================
casper.label "GET_RESULTS"

casper.wait 3000
casper.then ->
    matchComplete = false
    winner = ''
    loser = ''
    winBet = 0
    loseBet = 0
    betStatus = @evaluate -> $('#betstatus').text()

    if (betStatus.toLowerCase().indexOf betStatusRedWins) >= 0
        matchComplete = true
        winner = redFigher
        loser = blueFigher
        winBet = redBet
        loseBet = blueBet
    else if (betStatus.toLowerCase().indexOf betStatusBlueWins) >= 0
        matchComplete = true
        winner = blueFigher
        loser = redFigher
        winBet = blueBet
        loseBet = redBet
    else if (betStatus.toLowerCase().indexOf betStatusOpen) >= 0
        @goto "PLACE_BETS"
    else
        @goto "GET_RESULTS"

    if matchComplete is true
        matchLength = new Date().getTime() - matchStartTime.getTime()
        @echo 'Winner: ' + winner + '(' + winBet + ')'
        @echo 'Loser: ' + loser + '(' + loseBet + ')'
        @echo 'Match Length: ' + matchLength

casper.then ->
    @goto "PLACE_BETS"



casper.run()
