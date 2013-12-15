express = require 'express'
path = require 'path'
mongoose = require 'mongoose'
models = require './models'

Bot = null
Tournament = null
Fighter = null
Match = null

db = null

app = express()

allowCrossDomain = (req, res, next) ->
    res.header 'Access-Control-Allow-Origin', '*'
    res.header 'Access-Control-Allow-Methods', 'GET,PUT,POST,DELETE'
    res.header 'Access-Control-Allow-Headers', 'Content-Type, Authorization'

    if 'OPTIONS' == req.method
        res.send 200
    else
        next()

app.configure ->
    app.use express.bodyParser()
    app.use express.methodOverride()
    app.use app.router
    app.use allowCrossDomain
    app.use express.errorHandler {dumpExceptions: true, showStack: true}

models.defineModels mongoose, ->
    app.Bot = Bot = mongoose.model 'Bot'
    app.Tournament = Tournament = mongoose.model 'Tournament'
    app.Fighter = Fighter = mongoose.model 'Fighter'
    app.Match = Match = mongoose.model 'Match'
    db = mongoose.connect 'mongodb://localhost/salty_db'



app.get '/api', (req, res) ->
    res.send 'API is running'



app.get '/api/bot', (req, res) ->
    return Bot.find (err, botinfo) ->
        if !err
            return res.send botinfo
        else
            return console.log err

app.put '/api/bot', (req, res) ->
    return Bot.findOne (err, bot) ->
        bot.correct = req.body.correct
        bot.wrong = req.body.wrong
        bot.total_matches = (req.body.correct + req.body.wrong)
        bot.net_gain = req.body.net_gain
        
        if bot.total_matches > 0
            bot.correct_rate = bot.correct / bot.total_matches
        else
            bot.correct_rate = 0

        return bot.save (err) ->
            if !err
                console.log 'bot updated'
            else
                console.log err
            return res.send bot

# app.get '/api/bot/init', (req, res) ->
#     bot = new Bot
#         total_matches: 0
#         correct: 0
#         wrong: 0
#         correct_rate: 0
#         net_gain: 0
#     bot.save (err) ->
#         if !err
#             return console.log 'created'
#         else
#             return console.log err
#     return res.send bot

app.get '/api/fighter', (req, res) ->
    return Fighter.find (err, fighters) ->
        if !err
            return res.send fighters
        else
            return console.log err

app.get '/api/fighter/:name', (req, res) ->
    return Fighter.findOne {name: req.params.name}, (err, fighter) ->
        if !err
            return res.send fighter
        else
            return console.log err

app.post '/api/fighter', (req, res) ->
    fighter = new Fighter
        name: req.body.name
        total_matches: req.body.wins + req.body.losses
        wins: req.body.wins
        losses: req.body.losses
        wagered: req.body.wagered
        net_payout: req.body.net_payout
        roi: if req.body.wagered > 0 then req.body.net_payout / req.body.wagered else 0 
        tournaments: req.body.tournaments
        matches: req.body.matches
    fighter.save (err) ->
        if !err
            return console.log 'created fighter'
        else
            return console.log err
    res.send fighter

app.put '/api/fighter/:name', (req, res) ->
    return Fighter.findOne {name: req.params.name}, (err, fighter) ->
        fighter.wins = req.body.wins
        fighter.losses = req.body.losses
        fighter.total_matches = req.body.wins + req.body.losses
        wagered: req.body.wagered
        net_payout: req.body.net_payout
        roi: if req.body.wagered > 0 then req.body.net_payout / req.body.wagered else 0 
        tournaments: req.body.tournaments
        matches: req.body.matches

        return fighter.save (err) ->
            if !err
                console.log 'fighter updated'
            else
                console.log err
            return res.send fighter

app.get '/api/match', (req, res) ->
    return Match.find (err, matches) ->
        if !err
            return res.send matches
        else
            return console.log err

app.get '/api/match/:id', (req, res) ->
    return Match.findById req.params.id, (err, match) ->
        if !err
            return res.send match
        else
            return console.log err

app.post '/api/match', (req, res) ->
    match = new Match
        winner: req.body.winner
        loser: req.body.loser
        time: req.body.time
        length: req.body.length
        tournament: req.body.tournament
        winner_bet: req.body.winner_bet
        loser_bet: req.body.loser_bet
    match.save (err) ->
        if !err
            return console.log 'created match'
        else
            return console.log err
    return res.send match

app.get '/api/tournament', (req, res) ->
    return Tournament.find (err, tournaments) ->
        if !err
            return res.send tournaments
        else
            return console.log err

app.get '/api/tournament/:id', (req, res) ->
    return Tournament.findById req.params.id, (err, tournament) ->
        if !err
            return res.send tournament
        else
            return console.log err

app.post '/api/tournament', (req, res) ->
    tournament = new Tournament
        name: req.body.name
    tournament.save (err) ->
        if !err
            return console.log 'created tournament'
        else
            return console.log err


port = 4711
app.listen port, ->
    console.log 'Server running on port %d in %s mode', port, app.settings.env