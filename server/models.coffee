Bot = null
Tournament = null
Fighter = null
Match = null

defineModels = (mongoose, fn) ->
    Schema = mongoose.Schema
    ObjectID = Schema.ObjectId

    # Model: Bot
    Bot = new Schema
        total_matches: Number
        correct: Number
        wrong: Number
        correct_rate: Number
        net_gain: Number

    Tournament = new Schema
        name: String

    Fighter = new Schema
        name: String
        total_matches: Number
        wins: Number
        losses: Number
        wagered: Number
        net_payout: Number
        roi: Number
        tournaments: [ {type: ObjectID, ref: 'Tournament'} ]
        matches: [ {type: ObjectID, ref: 'Match'} ]

    Match = new Schema
        winner: {type: ObjectID, ref: 'Fighter'}
        loser: {type: ObjectID, ref: 'Fighter'}
        time: Date
        length: Number
        tournament: {type: ObjectID, ref: 'Tournament'}
        winner_bet: Number
        loser_bet: Number

    mongoose.model 'Bot', Bot
    mongoose.model 'Tournament', Tournament
    mongoose.model 'Fighter', Fighter
    mongoose.model 'Match', Match

    fn()

exports.defineModels = defineModels

