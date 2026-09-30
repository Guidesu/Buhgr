// The words a god listens for. A prayer is read clause by clause: each clause
// wants one intent (what is asked), usually a subject (what it is asked of),
// and may carry a target, qualifiers, offerings and a tone.
//
// Every list is form = meaning. Forms are matched as whole words or phrases,
// case-insensitive, after punctuation is stripped. Longer forms win over shorter.

// --- Intents: what is being asked --------------------------------------------

GLOBAL_LIST_INIT(prayer_intents, list(
	// healing
	"heal" = "heal", "heals" = "heal", "healing" = "heal", "mend" = "heal", "mends" = "heal",
	"restore" = "heal", "cure" = "heal", "knit" = "heal", "close" = "heal", "make whole" = "heal",
	"remedy" = "heal", "repair" = "heal", "patch" = "heal", "bind up" = "heal", "salve" = "heal",
	"tend" = "heal", "nurse" = "heal", "staunch" = "heal", "stop the bleeding" = "heal", "stem" = "heal", "rebuild" = "heal", "recover" = "heal",
	// cleansing
	"cleanse" = "cleanse", "purge" = "cleanse", "purify" = "cleanse", "wash" = "cleanse",
	"wash away" = "cleanse", "draw out" = "cleanse", "drive out" = "cleanse", "cast out" = "cleanse",
	"burn away" = "cleanse", "lift" = "cleanse", "take away" = "cleanse", "rid" = "cleanse",
	"clean" = "cleanse", "clear" = "cleanse", "expel" = "cleanse",
	// protection
	"shield" = "shield", "protect" = "shield", "guard" = "shield", "ward" = "shield",
	"shelter" = "shield", "keep safe" = "shield", "defend" = "shield", "watch over" = "shield",
	"cover" = "shield", "preserve" = "shield",
	// harm
	"smite" = "smite", "strike" = "smite", "punish" = "smite", "scourge" = "smite",
	"destroy" = "smite", "sunder" = "smite", "wrath" = "smite", "burn" = "smite",
	"crush" = "smite", "break" = "smite", "slay" = "smite", "unmake" = "smite",
	"rend" = "smite", "wound" = "smite", "judge" = "smite", "avenge" = "smite",
	// calm
	"calm" = "calm", "soothe" = "calm", "quiet" = "calm", "still" = "calm", "comfort" = "calm",
	"ease" = "calm", "console" = "calm", "settle" = "calm", "gentle" = "calm", "hush" = "calm",
	"steady" = "calm", "lighten" = "calm", "unburden" = "calm", "lift up" = "calm",
	// strength
	"strengthen" = "strengthen", "fortify" = "strengthen", "empower" = "strengthen",
	"steel" = "strengthen", "harden" = "strengthen",
	"bolster" = "strengthen", "invigorate" = "strengthen", "grant strength" = "strengthen",
	"give strength" = "strengthen", "lend strength" = "strengthen", "uphold" = "strengthen",
	"give me strength" = "strengthen", "grant me strength" = "strengthen", "grant me power" = "strengthen",
	"give me power" = "strengthen", "power" = "strengthen", "might" = "strengthen", "grant me might" = "strengthen", "lend me strength" = "strengthen", "grant me courage" = "strengthen",
	// speed
	"quicken" = "quicken", "hasten" = "quicken", "speed" = "quicken", "swift" = "quicken",
	"swiften" = "quicken", "lighten my feet" = "quicken", "carry" = "quicken",
	// weakening
	"weaken" = "weaken", "sap" = "weaken", "wither" = "weaken", "enfeeble" = "weaken",
	"slow" = "weaken", "humble" = "weaken", "drain" = "weaken", "tire" = "weaken",
	// restraint
	"bind" = "bind", "hold" = "bind", "chain" = "bind", "root" = "bind", "halt" = "bind",
	"stop" = "bind", "freeze in place" = "bind", "stay" = "bind", "fetter" = "bind",
	// sleep and wake
	"sleep" = "sleep", "slumber" = "sleep", "lull" = "sleep", "put to rest" = "sleep",
	"wake" = "wake", "rouse" = "wake", "awaken" = "wake", "stir" = "wake",
	// needs
	"feed" = "feed", "nourish" = "feed", "sate" = "feed", "fill" = "feed", "provide" = "feed",
	"quench" = "quench", "slake" = "quench",
	"warm" = "warm", "heat" = "warm", "thaw" = "warm",
	"cool" = "cool", "chill" = "cool", "extinguish" = "cool", "douse" = "cool", "put out" = "cool",
	// senses
	"light" = "light", "illuminate" = "light", "shine" = "light", "glow" = "light",
	"reveal" = "reveal", "show" = "reveal", "uncover" = "reveal", "lay bare" = "reveal",
	"open my eyes" = "reveal", "let me see" = "reveal", "clear my sight" = "reveal",
	"blind" = "blind", "darken" = "blind", "veil" = "blind", "cloud" = "blind",
	"silence" = "silence", "still their tongue" = "silence", "mute" = "silence", "gag" = "silence",
	// favour
	"bless" = "bless", "favour" = "bless", "favor" = "bless", "sanctify" = "bless",
	"anoint" = "bless", "grace" = "bless", "smile upon" = "bless", "look kindly" = "bless",
	"curse" = "curse", "damn" = "curse", "hex" = "curse", "blight" = "curse", "doom" = "curse",
	"forsake" = "curse", "condemn" = "curse", "plague" = "curse",
	// the dead
	"raise" = "raise", "resurrect" = "raise", "bring back" = "raise", "return" = "raise",
	"revive" = "raise", "breathe life" = "raise", "restore life" = "raise",
	// fury
	"enrage" = "rage", "fury" = "rage", "frenzy" = "rage", "rouse to fury" = "rage", "battle madness" = "rage",
	"berserk" = "rage", "blood rage" = "rage", "fill me with fury" = "rage", "let me rage" = "rage",
	// concealment
	"hide" = "veil", "conceal" = "veil", "cloak" = "veil", "shroud" = "veil", "make unseen" = "veil",
	"cloak in shadow" = "veil", "hide me" = "veil", "let me pass unseen" = "veil", "obscure" = "veil",
	// absolution
	"forgive" = "forgive", "absolve" = "forgive", "pardon" = "forgive", "redeem" = "forgive",
	"atone" = "forgive", "wash away sin" = "forgive", "lift this guilt" = "forgive", "release" = "forgive",
	// truth
	"compel truth" = "truth", "reveal truth" = "truth", "make them speak true" = "truth",
	"judge their heart" = "truth", "read their heart" = "truth", "know their heart" = "truth",
	"show me their heart" = "truth", "lay their soul bare" = "truth", "weigh their heart" = "truth",
	// tongues
	"let me understand" = "tongues", "grant tongues" = "tongues", "gift of tongues" = "tongues",
	"open my ears" = "tongues", "give me understanding" = "tongues", "let me speak their tongue" = "tongues",
	// terror
	"frighten" = "frighten", "terrify" = "frighten", "scare" = "frighten", "cow" = "frighten",
	"strike fear" = "frighten", "horrify" = "frighten", "fill with fear" = "frighten", "haunt" = "frighten",
	// madness
	"madden" = "madden", "confuse" = "madden", "bewilder" = "madden", "befuddle" = "madden",
	"derange" = "madden", "addle" = "madden", "scatter their thoughts" = "madden", "twist their mind" = "madden",
	// sickness
	"sicken" = "sicken", "nauseate" = "sicken", "make ill" = "sicken", "fester" = "sicken", "afflict" = "sicken",
	// decay
	"decay" = "rot", "wither flesh" = "rot", "blight flesh" = "rot", "corrupt" = "rot", "defile" = "rot",
	"let them rot" = "rot", "putrefy" = "rot",
	// lasting healing
	"renew" = "renew", "regenerate" = "renew", "slowly heal" = "renew", "keep healing" = "renew",
	"sustain" = "renew", "heal over time" = "renew", "tend through the night" = "renew", "watch and mend" = "renew",
	// vigour
	"vigor" = "vigor", "vigour" = "vigor", "keep me going" = "vigor", "tirelessness" = "vigor",
	"endurance" = "vigor", "persevere" = "vigor", "persistence" = "vigor", "persist" = "vigor",
	"grant me persistence" = "vigor", "stamina" = "vigor", "let me not tire" = "vigor", "second wind" = "vigor", "untiring" = "vigor",
	// courage
	"courage" = "courage", "bravery" = "courage", "give me courage" = "courage", "steady my heart" = "courage",
	"stout heart" = "courage", "valour" = "courage", "valor" = "courage", "embolden" = "courage", "hearten" = "courage",
	// weathering
	"endure the cold" = "endure", "endure the heat" = "endure", "weather" = "endure", "withstand" = "endure",
	"shelter from the cold" = "endure", "shelter from the heat" = "endure", "let me not freeze" = "endure",
	// night sight
	"night eyes" = "nighteyes", "see in the dark" = "nighteyes", "eyes of the owl" = "nighteyes",
	"darksight" = "nighteyes", "sight in darkness" = "nighteyes", "let me see in the night" = "nighteyes",
	// voice
	"give voice" = "speak", "loosen tongue" = "speak", "let them speak" = "speak", "restore voice" = "speak",
	"unmute" = "speak", "return their voice" = "speak",
	// disarming
	"disarm" = "disarm", "strike the blade from" = "disarm", "make them drop" = "disarm",
	"loosen their grip" = "disarm", "unarm" = "disarm", "break their grip" = "disarm",
	// felling
	"knock down" = "fell", "cast down" = "fell", "throw down" = "fell", "topple" = "fell",
	"bring low" = "fell", "fell" = "fell", "trip" = "fell",
	// pushing and pulling
	"repel" = "repel", "push away" = "repel", "drive back" = "repel", "cast away" = "repel", "hurl" = "repel",
	"draw near" = "draw", "pull" = "draw", "bring them to me" = "draw", "drag" = "draw", "draw them close" = "draw",
	// the restless dead
	"banish" = "banish", "exorcise" = "banish", "send back" = "banish", "return to the grave" = "banish",
	"lay to rest" = "banish", "cast out the dead" = "banish",
	// drink
	"sober" = "sober", "clear their head" = "sober", "clear my head" = "sober", "drive out the drink" = "sober",
	// growth
	"grow" = "grow", "bloom" = "grow", "ripen" = "grow", "make fertile" = "grow", "bless the soil" = "grow",
	"let it grow" = "grow", "make the fields bear" = "grow",
	// beasts
	"tame" = "tame", "pacify" = "tame", "soothe the beast" = "tame", "befriend" = "tame", "gentle the beast" = "tame",
	// making
	"reforge" = "repair", "sharpen" = "repair", "make it whole" = "repair", "restore this" = "repair",
	"soothe their wounds" = "heal", "take away the hurt" = "heal", "make them well" = "heal",
	"lay hands" = "heal", "binding" = "heal", "succour" = "heal", "succor" = "heal",
	"drive away" = "cleanse", "unburn" = "cleanse", "free them from" = "cleanse", "exorcism" = "cleanse",
	"stand before" = "shield", "stand between" = "shield", "turn aside" = "shield", "spare" = "shield",
	"strike down" = "smite", "bring ruin" = "smite", "rain fire" = "smite", "lay low" = "smite",
	"quell" = "calm", "pacify their heart" = "calm", "give peace" = "calm", "grant peace" = "calm",
	"make strong" = "strengthen", "lend might" = "strengthen", "give might" = "strengthen",
	"make swift" = "quicken", "give speed" = "quicken", "fleet" = "quicken",
	"cripple" = "weaken", "break their strength" = "weaken", "make weak" = "weaken",
	"entangle" = "bind", "ensnare" = "bind", "pin" = "bind", "hold them fast" = "bind",
	"give rest" = "sleep", "close their eyes" = "sleep", "let them dream" = "sleep",
	"feast" = "feed", "give bread" = "feed", "give water" = "quench", "wet their lips" = "quench",
	"warm their bones" = "warm", "cool their brow" = "cool", "shine upon" = "light", "lantern" = "light",
	"unveil" = "reveal", "expose" = "reveal", "cloud their eyes" = "blind", "take their sight" = "blind",
	"steal their voice" = "silence", "bless them" = "bless", "keep them" = "bless", "prosper" = "bless",
	"ill fortune" = "curse", "misfortune" = "curse", "bring woe" = "curse",
	"give back life" = "raise", "wake the dead" = "raise",
	// fire, given and taken away
	"kindle" = "kindle", "kindle a fire" = "kindle", "light the hearth" = "kindle", "set alight" = "kindle",
	"ignite" = "kindle", "light the candles" = "kindle", "bring fire" = "kindle", "give us fire" = "kindle",
	"light the lamps" = "kindle", "let there be fire" = "kindle",
	"snuff" = "snuff", "put out the lights" = "snuff", "douse the lights" = "snuff", "bring darkness" = "snuff",
	"let there be darkness" = "snuff", "let darkness fall" = "snuff", "quench the lights" = "snuff", "blot out" = "snuff",
	// finding
	"find" = "seek", "seek" = "seek", "locate" = "seek", "where is" = "seek", "where are" = "seek",
	"guide me to" = "seek", "show me the way to" = "seek", "lead me to" = "seek", "track" = "seek", "hunt for" = "seek",
	// holy ground
	"consecrate" = "hallow", "hallow" = "hallow", "sanctify this ground" = "hallow", "make this place holy" = "hallow",
	"bless this ground" = "hallow", "ward this place" = "hallow", "make holy" = "hallow", "sanctify this place" = "hallow",
	// more ways to ask: heal
	"cure them" = "heal", "heal them" = "heal", "heal me" = "heal", "make well" = "heal", "make them whole" = "heal", "restore the flesh" = "heal", "knit the flesh" = "heal", "seal the wound" = "heal", "close the wound" = "heal", "soothe the flesh" = "heal", "mend the flesh" = "heal", "lay your hands upon" = "heal", "lend your healing" = "heal", "pour out your mercy" = "heal", "sew them up" = "heal", "restore health" = "heal", "bring back their strength" = "heal", "undo the harm" = "heal",
	// more ways to ask: cleanse
	"purify them" = "cleanse", "cleanse them" = "cleanse", "cleanse me" = "cleanse", "wash clean" = "cleanse", "wash them clean" = "cleanse", "make pure" = "cleanse", "burn out" = "cleanse", "root out" = "cleanse", "strip away" = "cleanse", "scour" = "cleanse", "scrub away" = "cleanse", "draw forth" = "cleanse", "leach out" = "cleanse", "flush out" = "cleanse", "pull out the sickness" = "cleanse", "rid them of" = "cleanse", "deliver them from" = "cleanse", "free me from" = "cleanse",
	// more ways to ask: shield
	"protect them" = "shield", "protect me" = "shield", "keep them safe" = "shield", "keep me safe" = "shield", "be my shield" = "shield", "be their shield" = "shield", "hold back the blows" = "shield", "turn the blade" = "shield", "blunt the blade" = "shield", "stand guard" = "shield", "cover them" = "shield", "hide them from harm" = "shield", "ward off harm" = "shield", "wall of faith" = "shield", "safeguard" = "shield", "bulwark" = "shield", "keep from harm" = "shield", "harden their skin" = "shield",
	// more ways to ask: smite
	"strike them down" = "smite", "burn them" = "smite", "sear" = "smite", "scorch" = "smite", "blast" = "smite", "obliterate" = "smite", "annihilate" = "smite", "rain wrath" = "smite", "pour out your wrath" = "smite", "let them burn" = "smite", "cast them down in fire" = "smite", "crush them" = "smite", "break them" = "smite", "punish them" = "smite", "lash" = "smite", "scourge them" = "smite", "strike at" = "smite",
	// more ways to ask: calm
	"calm them" = "calm", "calm me" = "calm", "soothe them" = "calm", "soothe me" = "calm", "quiet their heart" = "calm", "be still" = "calm", "still their heart" = "calm", "give comfort" = "calm", "bring comfort" = "calm", "gentle their mind" = "calm", "rest their mind" = "calm", "ease their mind" = "calm", "ease my mind" = "calm", "lift the weight" = "calm", "bring serenity" = "calm", "serenity" = "calm", "tranquillity" = "calm", "peace be upon" = "calm",
	// more ways to ask: strengthen
	"make me strong" = "strengthen", "make them strong" = "strengthen", "strength to my arm" = "strengthen", "strength to their arm" = "strengthen", "give power" = "strengthen", "empower me" = "strengthen", "fortify me" = "strengthen", "bolster me" = "strengthen", "raise me up" = "strengthen", "lift me up" = "strengthen", "steel my arm" = "strengthen", "harden my arm" = "strengthen", "might of the gods" = "strengthen", "grant vigour to my arm" = "strengthen", "lend me your arm" = "strengthen",
	// more ways to ask: quicken
	"hasten me" = "quicken", "hasten them" = "quicken", "speed my feet" = "quicken", "speed their feet" = "quicken", "make me swift" = "quicken", "make them swift" = "quicken", "wings to my feet" = "quicken", "fleet of foot" = "quicken", "quick feet" = "quicken", "faster" = "quicken", "swiftness" = "quicken", "alacrity" = "quicken", "give me speed" = "quicken", "grant me speed" = "quicken", "run like the wind" = "quicken", "carry me swiftly" = "quicken", "lighten their feet" = "quicken",
	// more ways to ask: weaken
	"weaken them" = "weaken", "sap their strength" = "weaken", "drain their strength" = "weaken", "wither their arm" = "weaken", "let them falter" = "weaken", "make them falter" = "weaken", "let them stumble" = "weaken", "tire them" = "weaken", "exhaust them" = "weaken", "enervate" = "weaken", "sap them" = "weaken", "leach their strength" = "weaken", "let their arm fail" = "weaken", "bring weakness" = "weaken",
	// more ways to ask: bind
	"bind them" = "bind", "hold them" = "bind", "halt them" = "bind", "stop them" = "bind", "freeze them" = "bind", "root them" = "bind", "chain them" = "bind", "shackle" = "bind", "shackles" = "bind", "stay their feet" = "bind", "stay their hand" = "bind", "snare" = "bind", "trap them" = "bind", "still their limbs" = "bind", "hold them still" = "bind", "restrain" = "bind",
	// more ways to ask: sleep
	"put them to sleep" = "sleep", "send them to sleep" = "sleep", "bring sleep" = "sleep", "bring slumber" = "sleep", "sleep now" = "sleep", "sweet sleep" = "sleep", "drowse" = "sleep", "drowsiness" = "sleep", "lull them" = "sleep", "close their eyes in sleep" = "sleep", "grant rest" = "sleep", "let them rest" = "sleep", "soothe them to sleep" = "sleep", "dream" = "sleep",
	// more ways to ask: wake
	"wake them" = "wake", "wake up" = "wake", "wake me" = "wake", "rouse them" = "wake", "awaken them" = "wake", "bring them round" = "wake", "open their eyes" = "wake", "stir them" = "wake", "rise and wake" = "wake", "shake off sleep" = "wake", "call them back to waking" = "wake", "return to waking" = "wake", "come back to me" = "wake", "arise" = "wake", "get up" = "wake", "stand up" = "wake", "revive their senses" = "wake", "bring them to their senses" = "wake",
	// more ways to ask: feed
	"feed them" = "feed", "feed me" = "feed", "nourish them" = "feed", "nourish me" = "feed", "fill their belly" = "feed", "fill my belly" = "feed", "give us bread" = "feed", "give them bread" = "feed", "our daily bread" = "feed", "sate their hunger" = "feed", "sate my hunger" = "feed", "ease the hunger" = "feed", "end the hunger" = "feed", "satisfy" = "feed", "provision" = "feed", "sustenance" = "feed", "food for" = "feed", "a meal for" = "feed",
	// more ways to ask: quench
	"quench their thirst" = "quench", "quench my thirst" = "quench", "slake their thirst" = "quench", "slake my thirst" = "quench", "wet their throat" = "quench", "wet my throat" = "quench", "give them water" = "quench", "give me water" = "quench", "water for" = "quench", "a drink for" = "quench", "cool drink" = "quench", "refresh them" = "quench", "refresh me" = "quench", "ease the thirst" = "quench", "end the thirst" = "quench", "drink deep" = "quench", "let them drink" = "quench", "let me drink" = "quench",
	// more ways to ask: warm
	"warm them" = "warm", "warm me" = "warm", "warmth" = "warm", "bring warmth" = "warm", "give warmth" = "warm", "keep them warm" = "warm", "keep me warm" = "warm", "stoke their blood" = "warm", "heat their blood" = "warm", "chase the cold" = "warm", "drive out the cold" = "warm", "banish the cold" = "warm", "end the chill" = "warm", "shield from the frost" = "warm", "hearthwarmth" = "warm", "fire in their veins" = "warm", "let them be warm" = "warm",
	// more ways to ask: cool
	"cool them" = "cool", "cool me" = "cool", "cool their skin" = "cool", "ease the fever" = "cool", "break the fever" = "cool", "soothe the burn" = "cool", "chill their blood" = "cool", "bring coolness" = "cool", "a cool breeze" = "cool", "shade them" = "cool", "shade me" = "cool", "drive out the heat" = "cool", "end the heat" = "cool", "still the flames" = "cool", "drown the fire" = "cool", "quench the fire" = "cool", "put out the fire" = "cool",
	// more ways to ask: light
	"light my way" = "light", "light the way" = "light", "give light" = "light", "bring light" = "light", "let there be light" = "light", "shine your light" = "light", "a lamp for my feet" = "light", "illumine" = "light", "brighten" = "light", "radiance" = "light", "radiant light" = "light", "holy light" = "light", "dawn light" = "light", "glowing" = "light", "cast light" = "light", "show your light" = "light", "lighten the dark" = "light", "light for" = "light",
	// more ways to ask: reveal
	"reveal to me" = "reveal", "show me" = "reveal", "let me see what is hidden" = "reveal", "uncover the hidden" = "reveal", "lift the veil" = "reveal", "part the veil" = "reveal", "bring to light" = "reveal", "make plain" = "reveal", "make clear" = "reveal", "make known" = "reveal", "show what is hidden" = "reveal", "clear their sight" = "reveal", "restore their sight" = "reveal", "cure their blindness" = "reveal", "give sight" = "reveal",
	// more ways to ask: blind
	"blind them" = "blind", "strike them blind" = "blind", "take their eyes" = "blind", "darken their eyes" = "blind", "dim their sight" = "blind", "cloud their sight" = "blind", "put out their eyes" = "blind", "dazzle" = "blind", "blinding" = "blind", "veil their eyes" = "blind", "fog their eyes" = "blind", "let them not see" = "blind", "make them blind" = "blind", "rob them of sight" = "blind",
	// more ways to ask: silence
	"silence them" = "silence", "hush them" = "silence", "still their voice" = "silence", "take their tongue" = "silence", "stop their mouth" = "silence", "seal their lips" = "silence", "bind their tongue" = "silence", "choke their words" = "silence", "quiet them" = "silence", "let them not speak" = "silence", "make them mute" = "silence", "strike them dumb" = "silence", "rob them of speech" = "silence", "stifle" = "silence", "muzzle" = "silence",
	// more ways to ask: bless
	"bless me" = "bless", "bless us" = "bless", "bless all" = "bless", "give your blessing" = "bless", "grant your blessing" = "bless", "your blessing upon" = "bless", "grant favour" = "bless", "grant favor" = "bless", "show favour" = "bless", "show favor" = "bless", "fortune upon" = "bless", "good fortune" = "bless", "luck upon" = "bless", "good luck" = "bless", "bless this" = "bless", "bless their path" = "bless", "make fortunate" = "bless", "sanctify them" = "bless",
	// more ways to ask: curse
	"curse them" = "curse", "lay a curse" = "curse", "bring a curse" = "curse", "curse upon" = "curse", "damn them" = "curse", "hex them" = "curse", "blight them" = "curse", "doom them" = "curse", "bad luck upon" = "curse", "ill luck" = "curse", "woe upon" = "curse", "ruin upon" = "curse", "let them suffer" = "curse", "may they suffer" = "curse", "let misfortune find" = "curse", "let them be cursed" = "curse", "bring them low" = "curse",
	// more ways to ask: raise
	"raise them" = "raise", "raise the dead" = "raise", "rise again" = "raise", "let them rise" = "raise", "bring them back to life" = "raise", "call them back" = "raise", "return them to life" = "raise", "return their soul" = "raise", "give back their soul" = "raise", "undo their death" = "raise", "defy death" = "raise", "wake from death" = "raise", "breathe into them" = "raise", "life anew" = "raise", "second life" = "raise", "resurrection" = "raise",
	// more ways to ask: rage
	"rage within me" = "rage", "fire my blood" = "rage", "set my blood alight" = "rage", "boil my blood" = "rage", "war fury" = "rage", "battle fury" = "rage", "holy wrath within" = "rage", "let me be wrath" = "rage", "madness of battle" = "rage", "unleash me" = "rage", "unchain my anger" = "rage", "give me the fury" = "rage", "blood and fury" = "rage", "berserker" = "rage", "rampage" = "rage", "frenzied" = "rage",
	// more ways to ask: veil
	"hide them" = "veil", "hide us" = "veil", "conceal me" = "veil", "conceal them" = "veil", "cloak me" = "veil", "cloak them" = "veil", "shroud me" = "veil", "shroud them" = "veil", "veil me" = "veil", "veil them" = "veil", "make me unseen" = "veil", "let me go unseen" = "veil", "let none see me" = "veil", "turn their eyes from me" = "veil", "cover me in shadow" = "veil", "wrap me in darkness" = "veil", "vanish" = "veil", "invisible" = "veil", "unseen" = "veil",
	// more ways to ask: forgive
	"forgive me" = "forgive", "forgive them" = "forgive", "absolve me" = "forgive", "absolve them" = "forgive", "pardon me" = "forgive", "pardon them" = "forgive", "wash away my sins" = "forgive", "wash away their sins" = "forgive", "cleanse my soul" = "forgive", "cleanse their soul" = "forgive", "grant absolution" = "forgive", "absolution" = "forgive", "mercy for my sins" = "forgive", "redemption" = "forgive", "lift my guilt" = "forgive", "release me" = "forgive", "let me atone" = "forgive", "i repent" = "forgive", "i am sorry" = "forgive",
	// more ways to ask: truth
	"tell me the truth" = "truth", "show me the truth" = "truth", "the truth of their heart" = "truth", "let them not lie" = "truth", "strip their lies" = "truth", "expose their lies" = "truth", "what do they hide" = "truth", "what is in their heart" = "truth", "let me know them" = "truth", "judge them" = "truth", "weigh them" = "truth", "know their mind" = "truth", "see into them" = "truth", "see into their heart" = "truth", "reveal their intent" = "truth", "their true nature" = "truth",
	// more ways to ask: tongues
	"understand them" = "tongues", "let me understand them" = "tongues", "let me know their words" = "tongues", "their words" = "tongues", "their language" = "tongues", "their speech" = "tongues", "translate" = "tongues", "the gift of tongues" = "tongues", "every tongue" = "tongues", "all tongues" = "tongues", "speak their tongue" = "tongues", "speak in tongues" = "tongues", "open my ears to them" = "tongues", "grant me their language" = "tongues", "let me be understood" = "tongues",
	// more ways to ask: frighten
	"frighten them" = "frighten", "terrify them" = "frighten", "scare them" = "frighten", "fill them with dread" = "frighten", "terror upon" = "frighten", "fear upon" = "frighten", "let them fear" = "frighten", "make them afraid" = "frighten", "make them cower" = "frighten", "cowardice" = "frighten", "panic" = "frighten", "send them fleeing" = "frighten", "break their nerve" = "frighten", "shake their courage" = "frighten", "unnerve" = "frighten", "let them tremble" = "frighten", "horror" = "frighten",
	// more ways to ask: madden
	"madden them" = "madden", "confuse them" = "madden", "twist their thoughts" = "madden", "break their mind" = "madden", "cloud their mind" = "madden", "muddle" = "madden", "muddle their thoughts" = "madden", "fog their mind" = "madden", "madness upon" = "madden", "drive them mad" = "madden", "let them rave" = "madden", "unravel their mind" = "madden", "scramble" = "madden", "disorient" = "madden", "dizzy" = "madden", "delirium" = "madden", "lunacy" = "madden",
	// more ways to ask: sicken
	"sicken them" = "sicken", "make them sick" = "sicken", "sickness upon" = "sicken", "plague upon them" = "sicken", "pestilence" = "sicken", "disease upon" = "sicken", "fever upon" = "sicken", "let them sicken" = "sicken", "poison their gut" = "sicken", "turn their stomach" = "sicken", "nausea" = "sicken", "fill them with bile" = "sicken", "rot their gut" = "sicken", "let them retch" = "sicken", "fester within" = "sicken", "infect" = "sicken",
	// more ways to ask: rot
	"rot them" = "rot", "let their flesh rot" = "rot", "rot their flesh" = "rot", "decay them" = "rot", "wither them" = "rot", "corrupt their flesh" = "rot", "blacken their flesh" = "rot", "let them wither" = "rot", "gangrene" = "rot", "necrosis" = "rot", "putrefaction" = "rot", "spoil their blood" = "rot", "let the worms come" = "rot", "let them decay" = "rot", "ruin their body" = "rot", "curse their flesh" = "rot",
	// more ways to ask: renew
	"keep them whole" = "renew", "keep me whole" = "renew", "heal them slowly" = "renew", "heal me slowly" = "renew", "lasting healing" = "renew", "keep mending" = "renew", "go on mending" = "renew", "restore them over time" = "renew", "watch over their wounds" = "renew", "tend their wounds" = "renew", "soothe them through the night" = "renew", "grant renewal" = "renew", "renewal" = "renew", "regeneration" = "renew", "rebirth of flesh" = "renew", "steady healing" = "renew",
	// more ways to ask: vigor
	"keep me strong" = "vigor", "keep them strong" = "vigor", "give me vigour" = "vigor", "give me vigor" = "vigor", "give them vigour" = "vigor", "restore my energy" = "vigor", "restore their energy" = "vigor", "energy" = "vigor", "stamina for" = "vigor", "let them not tire" = "vigor", "tireless" = "vigor", "untiring legs" = "vigor", "wind in my lungs" = "vigor", "second breath" = "vigor", "endure the march" = "vigor", "carry me through" = "vigor",
	// more ways to ask: courage
	"give them courage" = "courage", "grant them courage" = "courage", "make me brave" = "courage", "make them brave" = "courage", "fearless" = "courage", "banish my fear" = "courage", "banish their fear" = "courage", "take away my fear" = "courage", "take away their fear" = "courage", "lion's heart" = "courage", "heart of a lion" = "courage", "steel my nerve" = "courage", "steady their nerve" = "courage", "stand firm" = "courage", "do not let me falter" = "courage", "bravery for" = "courage", "boldness" = "courage",
	// more ways to ask: endure
	"endure the storm" = "endure", "endure the winter" = "endure", "endure the desert" = "endure", "weather the storm" = "endure", "weather the cold" = "endure", "weather the heat" = "endure", "keep me from the cold" = "endure", "keep me from the heat" = "endure", "keep them from freezing" = "endure", "let me not burn in the sun" = "endure", "protect from the cold" = "endure", "protect from the heat" = "endure", "warm against the cold" = "endure", "cool against the heat" = "endure", "withstand the elements" = "endure",
	// more ways to ask: nighteyes
	"let me see in darkness" = "nighteyes", "eyes that pierce the dark" = "nighteyes", "sight in the night" = "nighteyes", "see through the dark" = "nighteyes", "pierce the darkness" = "nighteyes", "eyes of the cat" = "nighteyes", "eyes of the wolf" = "nighteyes", "cat's eyes" = "nighteyes", "owl's eyes" = "nighteyes", "night vision" = "nighteyes", "nightsight" = "nighteyes", "dark sight" = "nighteyes", "see by night" = "nighteyes", "let the dark not blind me" = "nighteyes", "see without light" = "nighteyes",
	// more ways to ask: speak
	"give them back their voice" = "speak", "give me back my voice" = "speak", "restore their speech" = "speak", "restore my speech" = "speak", "let them speak again" = "speak", "let me speak again" = "speak", "unbind their tongue" = "speak", "unbind my tongue" = "speak", "loose their tongue" = "speak", "loose my tongue" = "speak", "open their mouth" = "speak", "open their lips" = "speak", "return my voice" = "speak", "speak freely" = "speak", "let words flow" = "speak",
	// more ways to ask: disarm
	"disarm them" = "disarm", "take their weapon" = "disarm", "take their blade" = "disarm", "tear the weapon from" = "disarm", "knock the blade from" = "disarm", "strip their weapon" = "disarm", "make them drop their weapon" = "disarm", "weaken their grip" = "disarm", "their weapon falls" = "disarm", "let their weapon fall" = "disarm", "pry their fingers" = "disarm", "empty their hands" = "disarm", "unarm them" = "disarm", "steal their sword" = "disarm",
	// more ways to ask: fell
	"knock them down" = "fell", "cast them down" = "fell", "throw them down" = "fell", "bring them down" = "fell", "strike them to the ground" = "fell", "send them sprawling" = "fell", "trip them" = "fell", "sweep their legs" = "fell", "lay them flat" = "fell", "down with them" = "fell", "to the ground" = "fell", "let them fall" = "fell", "make them fall" = "fell", "drop them" = "fell", "floor them" = "fell", "topple them" = "fell",
	// more ways to ask: repel
	"push them away" = "repel", "drive them back" = "repel", "drive them away" = "repel", "throw them back" = "repel", "hurl them away" = "repel", "cast them off" = "repel", "send them flying" = "repel", "force them back" = "repel", "keep them away" = "repel", "keep them back" = "repel", "blast them back" = "repel", "away from me" = "repel", "get back" = "repel", "begone" = "repel", "stay back" = "repel", "thrust them away" = "repel",
	// more ways to ask: draw
	"pull them to me" = "draw", "pull them close" = "draw", "drag them to me" = "draw", "bring them near" = "draw", "draw them near" = "draw", "reel them in" = "draw", "haul them" = "draw", "yank them" = "draw", "call them to me" = "draw", "bring them here" = "draw", "pull them here" = "draw", "come to me" = "draw", "come hither" = "draw", "fetch them" = "draw",
	// more ways to ask: banish
	"banish them" = "banish", "banish the dead" = "banish", "banish the unholy" = "banish", "exorcise them" = "banish", "drive out the dead" = "banish", "cast out the unholy" = "banish", "send them back to the grave" = "banish", "back to the grave" = "banish", "return them to death" = "banish", "lay them to rest" = "banish", "grant them rest" = "banish", "give them peace" = "banish", "undo the undead" = "banish", "destroy the undead" = "banish", "purge the unholy" = "banish", "cleanse the dead" = "banish",
	// more ways to ask: sober
	"sober them" = "sober", "sober me" = "sober", "clear their mind" = "sober", "clear my mind" = "sober", "take away the drink" = "sober", "take the drink from them" = "sober", "wash out the wine" = "sober", "wash out the ale" = "sober", "make them sober" = "sober", "make me sober" = "sober", "sobriety" = "sober", "a clear head" = "sober", "steady their head" = "sober", "end the drunkenness" = "sober", "cure their drunkenness" = "sober",
	// more ways to ask: grow
	"make it grow" = "grow", "let the crops grow" = "grow", "let the seeds sprout" = "grow", "sprout" = "grow", "bloom and grow" = "grow", "fruitfulness" = "grow", "fertile ground" = "grow", "make fruitful" = "grow", "bless the harvest" = "grow", "rich harvest" = "grow", "abundant harvest" = "grow", "bountiful" = "grow", "ripen the crops" = "grow", "green the fields" = "grow", "water the fields" = "grow", "feed the soil" = "grow", "quicken the seeds" = "grow",
	// more ways to ask: tame
	"tame them" = "tame", "tame this beast" = "tame", "calm the beast" = "tame", "calm this animal" = "tame", "soothe this creature" = "tame", "make it gentle" = "tame", "make it friendly" = "tame", "be my friend" = "tame", "befriend this beast" = "tame", "turn its hunger away" = "tame", "let it not bite" = "tame", "let it follow me" = "tame", "make it mine" = "tame", "bond with" = "tame", "beast friend" = "tame", "animal friend" = "tame",
	// more ways to ask: repair
	"repair this" = "repair", "repair it" = "repair", "mend this" = "repair", "mend my gear" = "repair", "mend my armour" = "repair", "mend my armor" = "repair", "fix this" = "repair", "fix my blade" = "repair", "restore my weapon" = "repair", "make it new" = "repair", "make it strong again" = "repair", "reforge my blade" = "repair", "straighten" = "repair", "patch this" = "repair", "knit this together" = "repair", "whole again" = "repair",
	// more ways to ask: kindle
	"light a fire" = "kindle", "start a fire" = "kindle", "make a fire" = "kindle", "strike a flame" = "kindle", "bring flame" = "kindle", "kindle the hearth" = "kindle", "light the torches" = "kindle", "light the braziers" = "kindle", "set the fire" = "kindle", "fire for" = "kindle", "flame for" = "kindle", "warm hearth" = "kindle", "let the fire catch" = "kindle", "spark" = "kindle", "give me flame" = "kindle",
	// more ways to ask: snuff
	"put out the fires" = "snuff", "put out the torches" = "snuff", "snuff the candles" = "snuff", "snuff the lights" = "snuff", "kill the lights" = "snuff", "darken this place" = "snuff", "make it dark" = "snuff", "bring the night" = "snuff", "cover us in darkness" = "snuff", "blind the lamps" = "snuff", "let the flames die" = "snuff", "let the lights die" = "snuff", "extinguish the lights" = "snuff",
	// more ways to ask: seek
	"find them" = "seek", "find the dead" = "seek", "find the living" = "seek", "find my way to" = "seek", "show me where" = "seek", "where lies" = "seek", "where hides" = "seek", "where hide" = "seek", "point me to" = "seek", "lead me" = "seek", "guide me" = "seek", "track them" = "seek", "hunt them" = "seek", "sniff out" = "seek", "search for" = "seek", "seek out" = "seek", "reveal the way" = "seek", "the way to" = "seek",
	// more ways to ask: hallow
	"hallow this ground" = "hallow", "hallow this place" = "hallow", "consecrate this ground" = "hallow", "consecrate this place" = "hallow", "make this ground holy" = "hallow", "holy ground" = "hallow", "sacred ground" = "hallow", "bless this place" = "hallow", "sanctuary" = "hallow", "make sanctuary" = "hallow", "a place of refuge" = "hallow", "ward the ground" = "hallow", "sanctify the ground" = "hallow", "holy circle" = "hallow", "circle of protection" = "hallow", "keep this place" = "hallow",
	// Latin
	"sana vulnera" = "heal", "sanare" = "heal", "sanetur" = "heal", "cura" = "heal", "medere" = "heal", "restitue" = "heal",
	"integra" = "heal", "sana" = "heal", "purga" = "cleanse", "purifica" = "cleanse", "munda" = "cleanse",
	"expelle" = "cleanse", "eice" = "cleanse", "protege" = "shield", "tege" = "shield", "custodi" = "shield", "defende" = "shield",
	"tuere" = "shield", "praesidium" = "shield", "feri" = "smite", "percute" = "smite", "ure" = "smite", "contere" = "smite",
	"frange" = "smite", "interfice" = "smite", "occide" = "smite", "dele" = "smite", "puni" = "smite", "fulmina" = "smite",
	"ferio" = "smite", "pacifica" = "calm", "placa" = "calm", "sedate" = "calm", "tranquilla" = "calm", "quiesce" = "calm",
	"pax" = "calm", "animum da" = "courage", "confirma" = "courage", "aucia" = "courage", "fortitudo" = "courage", "da" = "courage",
	"vires da" = "strengthen", "robora" = "strengthen", "fortifica" = "strengthen", "corrobora" = "strengthen", "furore imple" = "rage", "furor" = "rage",
	"saevi" = "rage", "vigora" = "vigor", "recrea" = "vigor", "reficite" = "vigor", "accelera" = "quicken", "festina" = "quicken",
	"celeritas" = "quicken", "propera" = "quicken", "debilita" = "weaken", "infirma" = "weaken", "enerva" = "weaken", "anathema sit" = "curse",
	"maledic" = "curse", "maledico" = "curse", "exsecror" = "curse", "liga" = "bind", "alliga" = "bind", "vincula" = "bind",
	"siste" = "bind", "immobilis" = "bind", "dormi" = "sleep", "sopi" = "sleep", "somnus" = "sleep", "expergiscere" = "wake",
	"excita" = "wake", "evigila" = "wake", "pasce" = "feed", "ciba" = "feed", "nutri" = "feed", "sitim exstingue" = "quench",
	"bibe" = "quench", "cale" = "warm", "calefac" = "warm", "tepefac" = "warm", "refrigera" = "cool", "gela" = "cool",
	"fiat lux" = "light", "illumina" = "light", "lumen" = "light", "lux" = "light", "revela" = "reveal", "aperi" = "reveal",
	"ostende" = "reveal", "detege" = "reveal", "dic verum" = "truth", "veritas" = "truth", "caeca" = "blind", "excaeca" = "blind",
	"obscura" = "blind", "tace" = "silence", "sile" = "silence", "obmutesce" = "silence", "loquere" = "speak", "vela" = "veil",
	"occulta" = "veil", "absconde" = "veil", "intellege linguas" = "tongues", "terre" = "frighten", "perterre" = "frighten", "timete" = "frighten",
	"dementa" = "madden", "insanias" = "madden", "morbum da" = "sicken", "aegrota" = "sicken", "putresce" = "rot", "corrumpe" = "rot",
	"tabesce" = "rot", "dura" = "endure", "perdura" = "endure", "tolera" = "endure", "vide in tenebris" = "nighteyes", "oculos noctis" = "nighteyes",
	"arma cadant" = "disarm", "ex" = "disarm", "arma" = "disarm", "cade" = "fell", "prosterne" = "fell", "deice" = "fell",
	"repelle" = "repel", "pelle" = "repel", "abige" = "repel", "recede" = "repel", "ad me veni" = "draw", "trahe" = "draw",
	"attrahe" = "draw", "sobria" = "sober", "cresce" = "grow", "germina" = "grow", "floreat" = "grow", "doma" = "tame",
	"mansuefac" = "tame", "repara" = "repair", "restaura" = "repair", "refice" = "repair", "accende" = "kindle", "incende" = "kindle",
	"inflamma" = "kindle", "exstingue" = "snuff", "extingue" = "snuff", "quaere" = "seek", "inveni" = "seek", "sanctifica" = "hallow",
	"consecra" = "hallow", "redi ad vitam" = "raise", "resurge" = "raise", "suscita" = "raise", "vade retro" = "banish", "exorcizo" = "banish",
	"abi" = "banish", "benedic" = "bless", "benedico" = "bless", "ignosce" = "forgive", "remitte" = "forgive", "renova" = "renew",
))

/// Intent phrases that already name what they act on.
GLOBAL_LIST_INIT(prayer_intent_implies, list(
	"stop the bleeding" = "blood", "staunch" = "blood", "stem" = "blood",
	"open my eyes" = "eyes", "let me see" = "eyes", "clear my sight" = "eyes",
	"still their tongue" = "tongue", "breathe life" = "dead", "restore life" = "dead",
	"extinguish" = "fire", "douse" = "fire", "put out" = "fire", "thaw" = "cold",
))

/// What an intent reaches for when the prayer names no subject.
GLOBAL_LIST_INIT(prayer_default_subject, list(
	"heal" = "wounds", "cleanse" = "poison", "shield" = "body", "smite" = "foe",
	"calm" = "mind", "strengthen" = "body", "quicken" = "body", "weaken" = "body",
	"bind" = "body", "sleep" = "body", "wake" = "body", "feed" = "hunger",
	"quench" = "thirst", "warm" = "cold", "cool" = "fire", "light" = "darkness",
	"reveal" = "eyes", "blind" = "eyes", "silence" = "tongue", "bless" = "body",
	"curse" = "body", "raise" = "dead",
	"rage" = "body", "veil" = "body", "forgive" = "sin", "truth" = "truth", "tongues" = "tongue",
	"frighten" = "mind", "madden" = "mind", "sicken" = "body", "rot" = "body", "renew" = "wounds",
	"vigor" = "fatigue", "courage" = "mind", "endure" = "cold", "nighteyes" = "eyes", "speak" = "tongue",
	"disarm" = "weapon", "fell" = "body", "repel" = "body", "draw" = "body", "banish" = "undead",
	"sober" = "drink", "grow" = "crops", "tame" = "beast", "repair" = "gear",
	"kindle" = "fire", "snuff" = "darkness", "seek" = "dead", "hallow" = "body",
))

// --- Subjects: what the intent acts on ------------------------------------------

GLOBAL_LIST_INIT(prayer_subjects, list(
	"wound" = "wounds", "wounds" = "wounds", "cut" = "wounds", "cuts" = "wounds", "gash" = "wounds",
	"gashes" = "wounds", "injury" = "wounds", "injuries" = "wounds", "flesh" = "wounds",
	"skin" = "wounds", "hurts" = "wounds", "bruise" = "wounds", "bruises" = "wounds", "body" = "body",
	"blood" = "blood", "bleeding" = "blood", "veins" = "blood", "bleed" = "blood", "lifeblood" = "blood",
	"bone" = "bones", "bones" = "bones", "fracture" = "bones", "fractures" = "bones", "broken" = "bones",
	"skull" = "bones", "limb" = "bones", "limbs" = "bones",
	"burn" = "burns", "burns" = "burns", "scorched" = "burns", "blisters" = "burns", "scald" = "burns",
	"poison" = "poison", "venom" = "poison", "toxin" = "poison", "toxins" = "poison", "bane" = "poison",
	"fever" = "fever", "infection" = "fever", "rot" = "fever", "plague" = "fever", "disease" = "fever",
	"sickness" = "fever", "illness" = "fever", "pox" = "fever", "corruption" = "fever", "sepsis" = "fever",
	"pain" = "pain", "agony" = "pain", "suffering" = "pain", "ache" = "pain", "torment" = "pain",
	"fear" = "mind", "terror" = "mind", "dread" = "mind", "mind" = "mind", "madness" = "mind",
	"sanity" = "mind", "thoughts" = "mind", "despair" = "mind", "grief" = "mind", "sorrow" = "mind",
	"heart" = "mind", "soul" = "mind", "spirit" = "mind", "nightmares" = "mind", "anger" = "mind",
	"fire" = "fire", "flames" = "fire", "flame" = "fire", "blaze" = "fire",
	"cold" = "cold", "frost" = "cold", "chill" = "cold", "winter" = "cold", "shivering" = "cold",
	"hunger" = "hunger", "belly" = "hunger", "starving" = "hunger", "starvation" = "hunger",
	"thirst" = "thirst", "dry lips" = "thirst", "parched" = "thirst",
	"weariness" = "fatigue", "fatigue" = "fatigue", "tiredness" = "fatigue", "exhaustion" = "fatigue",
	"breath" = "fatigue", "legs" = "fatigue", "strength" = "fatigue",
	"eyes" = "eyes", "sight" = "eyes", "vision" = "eyes", "blindness" = "eyes",
	"tongue" = "tongue", "voice" = "tongue", "mouth" = "tongue",
	"darkness" = "darkness", "shadow" = "darkness", "shadows" = "darkness", "night" = "darkness", "dark" = "darkness",
	"dead" = "dead", "corpse" = "dead", "departed" = "dead", "fallen" = "dead", "the dead" = "dead",
	"undead" = "undead", "unholy" = "undead", "abomination" = "undead", "restless dead" = "undead",
	"evil" = "undead", "demon" = "undead", "monster" = "undead", "beast" = "undead", "beasts" = "undead",
	"enemy" = "foe", "enemies" = "foe", "foe" = "foe", "foes" = "foe", "wicked" = "foe",
	"attacker" = "foe", "heretic" = "foe", "sinner" = "foe", "villain" = "foe", "brigand" = "foe",
	"water" = "water", "holy water" = "water", "this water" = "water", "the well" = "water",
	"weapon" = "weapon", "blade" = "weapon", "sword" = "weapon", "axe" = "weapon", "mace" = "weapon",
	"spear" = "weapon", "hammer" = "weapon", "my blade" = "weapon", "this blade" = "weapon", "arrows" = "weapon",
	"armor" = "gear", "armour" = "gear", "gear" = "gear", "mail" = "gear", "plate" = "gear",
	"helm" = "gear", "tools" = "gear", "this item" = "gear", "garments" = "gear", "clothes" = "gear",
	"crops" = "crops", "field" = "crops", "fields" = "crops", "garden" = "crops", "seeds" = "crops",
	"plants" = "crops", "soil" = "crops", "harvest" = "crops", "orchard" = "crops",
	"beast" = "beast", "beasts" = "beast", "animal" = "beast", "animals" = "beast", "creature" = "beast",
	"wolf" = "beast", "hound" = "beast", "bear" = "beast", "the wild" = "beast",
	"drink" = "drink", "drunkenness" = "drink", "ale" = "drink", "wine" = "drink", "the bottle" = "drink",
	"sin" = "sin", "sins" = "sin", "guilt" = "sin", "shame" = "sin", "wrongs" = "sin", "misdeeds" = "sin",
	"courage" = "mind", "nerve" = "mind", "resolve" = "mind",
	"heat" = "heat", "the heat" = "heat", "scorching" = "heat",
	"lies" = "truth", "falsehood" = "truth", "deceit" = "truth", "the truth" = "truth",
	"food" = "food", "bread" = "food", "meal" = "food", "this food" = "food", "this meal" = "food", "our bread" = "food",
	"light" = "darkness", "lights" = "darkness", "lamps" = "darkness", "candles" = "darkness",
	"graves" = "dead", "bodies" = "dead", "body of" = "dead",
	// Latin
	"vulnera" = "wounds", "vulnus" = "wounds", "plagae" = "wounds", "sanguis" = "blood", "sanguinem" = "blood", "cruor" = "blood",
	"ossa" = "bones", "os" = "bones", "fracta" = "bones", "ambusta" = "burns", "venenum" = "poison", "veneno" = "poison",
	"febris" = "fever", "morbus" = "fever", "dolor" = "pain", "dolorem" = "pain", "mens" = "mind", "mentem" = "mind",
	"animus" = "mind", "ignis" = "fire", "ignem" = "fire", "flamma" = "fire", "flammas" = "fire", "frigus" = "cold",
	"calor" = "heat", "aestus" = "heat", "fames" = "hunger", "sitis" = "thirst", "lassitudo" = "fatigue", "oculi" = "eyes",
	"oculos" = "eyes", "visus" = "eyes", "lingua" = "tongue", "vox" = "tongue", "tenebrae" = "darkness", "tenebras" = "darkness",
	"nox" = "darkness", "mortuus" = "dead", "mortuum" = "dead", "mortui" = "dead", "cadaver" = "dead", "inmortui" = "undead",
	"larvae" = "undead", "umbrae" = "undead", "hostis" = "foe", "hostem" = "foe", "inimicus" = "foe", "inimicum" = "foe",
	"aqua" = "water", "aquam" = "water", "gladius" = "weapon", "arma" = "weapon", "telum" = "weapon", "armatura" = "gear",
	"seges" = "crops", "agri" = "crops", "bestia" = "beast", "belua" = "beast", "peccatum" = "sin", "culpa" = "sin",
	"cibus" = "food", "panis" = "food", "corpus" = "body", "ebrietas" = "drink",
))

// --- Targets: who the clause is for ---------------------------------------------

GLOBAL_LIST_INIT(prayer_targets, list(
	"me" = "self", "myself" = "self", "mine" = "self", "upon me" = "self", "for me" = "self", "your servant" = "self",
	"him" = "chosen", "her" = "chosen", "them" = "chosen", "this one" = "chosen", "this soul" = "chosen",
	"my friend" = "chosen", "my brother" = "chosen", "my sister" = "chosen", "this child" = "chosen",
	"all" = "all", "everyone" = "all", "us" = "all", "all present" = "all", "these" = "all",
	"all here" = "all", "all of us" = "all", "those around me" = "all", "the faithful" = "all", "my family" = "all", "my children" = "all", "my people" = "all", "this house" = "all", "this village" = "all",
	// Latin
	"mihi" = "self", "mei" = "self", "ego" = "self", "eum" = "chosen", "eam" = "chosen", "hunc" = "chosen",
	"hanc" = "chosen", "illum" = "chosen", "illam" = "chosen", "omnes" = "all", "nos" = "all", "cunctos" = "all",
	"universos" = "all",
))

// --- Qualifiers: how much, how fast, how long ------------------------------------

/// Each is list(power multiplier, cost multiplier, duration multiplier).
GLOBAL_LIST_INIT(prayer_qualifiers, list(
	"gently" = list(0.6, 0.5, 1), "softly" = list(0.6, 0.5, 1), "a little" = list(0.6, 0.5, 1),
	"lightly" = list(0.7, 0.6, 1), "slowly" = list(0.8, 0.7, 1.5),
	"fully" = list(1.4, 1.7, 1), "utterly" = list(1.5, 1.8, 1), "completely" = list(1.4, 1.7, 1),
	"wholly" = list(1.4, 1.7, 1), "entirely" = list(1.4, 1.7, 1), "with all your might" = list(1.6, 2, 1),
	"swiftly" = list(0.9, 1.1, 1), "now" = list(0.9, 1.1, 1), "at once" = list(0.9, 1.2, 1),
	"for a time" = list(1, 1.2, 2), "until dawn" = list(1, 1.5, 3), "linger" = list(1, 1.2, 2),
	"forever" = list(1, 2, 3), "always" = list(1, 1.4, 2),
	"just a little" = list(0.5, 0.4, 1), "barely" = list(0.5, 0.4, 1), "carefully" = list(0.8, 0.8, 1),
	"mightily" = list(1.3, 1.5, 1), "greatly" = list(1.3, 1.5, 1), "with fury" = list(1.3, 1.6, 0.7),
	"for a while" = list(1, 1.2, 1.8), "through the night" = list(1, 1.5, 2.5), "for a moment" = list(1.1, 0.8, 0.5),
	"until i return" = list(1, 1.4, 2.2), "as long as you will" = list(1, 1.3, 2),
	// Latin
	"maxime" = list(1.4, 1.7, 1), "magna vi" = list(1.5, 1.8, 1), "toto robore" = list(1.6, 2, 1), "leniter" = list(0.6, 0.5, 1), "paulum" = list(0.6, 0.5, 1), "statim" = list(0.9, 1.2, 1),
	"celeriter" = list(0.9, 1.1, 1), "diu" = list(1, 1.3, 2), "in aeternum" = list(1, 2, 3), "usque ad lucem" = list(1, 1.5, 3),
))

// --- Offerings: what the supplicant gives up -------------------------------------

/// offering = list(kind, power bonus)
GLOBAL_LIST_INIT(prayer_offerings, list(
	"take my blood" = list("blood", 0.5), "my blood" = list("blood", 0.4), "i bleed for you" = list("blood", 0.5),
	"take my strength" = list("stamina", 0.3), "my strength" = list("stamina", 0.25),
	"take my breath" = list("stamina", 0.3), "my breath" = list("stamina", 0.2),
	"take my years" = list("flesh", 0.6), "take my life" = list("flesh", 0.8), "my flesh" = list("flesh", 0.5),
	"take my pain" = list("flesh", 0.4), "take my sight" = list("sight", 0.4),
	"take my faith" = list("devotion", 0.4), "take my devotion" = list("devotion", 0.4),
	"all that i am" = list("devotion", 0.6), "take what you will" = list("gamble", 0.7),
	"i offer" = list("item", 0), "accept this" = list("item", 0), "take this offering" = list("item", 0),
	"this offering" = list("item", 0), "take this gift" = list("item", 0), "i give you this" = list("item", 0),
	"take my tears" = list("stamina", 0.15), "take my sleep" = list("stamina", 0.2),
	"i sacrifice my blood" = list("blood", 0.5), "i offer my blood" = list("blood", 0.5), "take of my blood" = list("blood", 0.5),
	"i sacrifice my strength" = list("stamina", 0.3), "take my stamina" = list("stamina", 0.3), "my stamina" = list("stamina", 0.25),
	"take my energy" = list("stamina", 0.3), "my energy" = list("stamina", 0.25), "take my vigor" = list("stamina", 0.3),
	"take my sweat" = list("stamina", 0.2), "i sacrifice my flesh" = list("flesh", 0.6), "take my flesh" = list("flesh", 0.6),
	"take my eyes" = list("sight", 0.4), "i sacrifice my sight" = list("sight", 0.4),
	// Latin
	"sanguinem meum" = list("blood", 0.5), "cape sanguinem meum" = list("blood", 0.5), "vires meas" = list("stamina", 0.3), "cape vires meas" = list("stamina", 0.3), "carnem meam" = list("flesh", 0.6), "oculos meos" = list("sight", 0.4),
	"fidem meam" = list("devotion", 0.4), "hoc donum" = list("item", 0), "accipe hoc" = list("item", 0),
))

/// Offerings of the body: kind = list(what is given, what it costs you). Their
/// value also eases the devotion a prayer asks.
GLOBAL_LIST_INIT(prayer_offering_info, list(
	"blood" = list("some of your blood", "You bleed from the palms and lose some blood (never below what keeps you alive)."),
	"stamina" = list("your strength", "Your energy drains away, leaving you tired."),
	"flesh" = list("your flesh", "Your body takes a wound (15 brute damage)."),
	"sight" = list("your sight", "You go blind for a short while."),
	"devotion" = list("your faith", "Twenty devotion more is spent on the prayer. Makes the answer stronger, but does not make it cheaper."),
	"gamble" = list("whatever the god wants", "A gamble. The god may give nothing at all, half, or far more than you asked."),
	"item" = list("what you hold in your hand", "The item in your active hand is destroyed. A fitting gift is worth more."),
))

/// Offerings that ease the devotion a prayer asks.
GLOBAL_LIST_INIT(prayer_sacrifice_kinds, list("blood", "stamina", "flesh", "sight", "item"))

/// Cost multiplier for what was sacrificed: up to 60% off.
/proc/prayer_sacrifice_discount(sacrificed)
	return 1 - min(0.6, sacrificed * 0.5)

// --- Tone ----------------------------------------------------------------------

GLOBAL_LIST_INIT(prayer_humble_words, list(
	"please", "i beg", "beseech", "i beseech", "humbly", "mercy", "have mercy", "i pray", "grant",
	"i ask", "thank you", "thanks", "blessed", "praise", "glory", "amen", "so be it", "forgive",
	"if it pleases you", "unworthy", "your will", "thy will", "i kneel", "on my knees", "hallowed",
	"merciful", "kind", "gracious",
	"lord", "lady", "mother", "father", "holy one", "almighty", "blessed be", "in your name", "i trust you",
	"i am yours", "your servant", "i am nothing", "hear my prayer", "hear me", "i love you", "sweet",
	// Latin
	"precor", "oro", "obsecro", "domine", "domina", "misericordia", "miserere", "gratias", "quaeso", "te rogo", "deo gratias",
))

GLOBAL_LIST_INIT(prayer_arrogant_words, list(
	"i command", "command", "i demand", "demand", "obey", "i order", "you must", "must",
	"i require", "do it", "i deserve", "you owe me", "hear me now", "listen to me",
	"i insist", "right now", "no more waiting", "you will", "or else", "i am owed",
	// Latin
	"impero", "iubeo", "necesse est", "oboedi",
))

/// Domains whose gods respect a firm voice.
GLOBAL_LIST_INIT(prayer_bold_domains, list(/datum/domain/war, /datum/domain/trickery, /datum/domain/forbidden, /datum/domain/law))

// --- Domain affinity -------------------------------------------------------------

/// domain type = list(intent = multiplier). Missing intents are 1. Zero means the god refuses.
GLOBAL_LIST_INIT(prayer_domain_affinity, list(
	/datum/domain/sun = list("smite" = 1.3, "light" = 1.5, "reveal" = 1.3, "warm" = 1.4, "cleanse" = 1.2, "blind" = 0.5, "curse" = 0.6, "raise" = 0.6),
	/datum/domain/law = list("bind" = 1.5, "silence" = 1.3, "reveal" = 1.3, "shield" = 1.2, "smite" = 1.2, "curse" = 0.7, "raise" = 0.4),
	/datum/domain/war = list("strengthen" = 1.5, "smite" = 1.4, "quicken" = 1.3, "shield" = 1.2, "heal" = 0.8, "calm" = 0.6, "sleep" = 0.5, "raise" = 0.3),
	/datum/domain/hearth = list("feed" = 1.6, "quench" = 1.5, "warm" = 1.5, "calm" = 1.3, "shield" = 1.3, "heal" = 1.1, "smite" = 0.6, "curse" = 0.4, "raise" = 0.3),
	/datum/domain/harvest = list("feed" = 1.8, "heal" = 1.2, "bless" = 1.3, "quench" = 1.2, "smite" = 0.5, "curse" = 0.8, "raise" = 0.6),
	/datum/domain/death = list("calm" = 1.3, "sleep" = 1.5, "smite" = 1.2, "weaken" = 1.3, "curse" = 1.2, "heal" = 0.7, "raise" = 0),
	/datum/domain/sea = list("quench" = 1.8, "cool" = 1.6, "bind" = 1.2, "cleanse" = 1.3, "warm" = 0.5),
	/datum/domain/moon = list("sleep" = 1.5, "reveal" = 1.4, "blind" = 1.3, "calm" = 1.2, "light" = 1.1),
	/datum/domain/love = list("calm" = 1.6, "bless" = 1.4, "heal" = 1.2, "strengthen" = 1.1, "smite" = 0.4, "curse" = 0.8),
	/datum/domain/trickery = list("blind" = 1.5, "silence" = 1.3, "quicken" = 1.4, "curse" = 1.2, "bless" = 1.1, "heal" = 0.8),
	/datum/domain/trade = list("bless" = 1.4, "feed" = 1.2, "quicken" = 1.2, "reveal" = 1.2, "smite" = 0.6),
	/datum/domain/craft = list("strengthen" = 1.4, "shield" = 1.4, "heal" = 1.1, "warm" = 1.2, "curse" = 0.6),
	/datum/domain/knowledge = list("reveal" = 1.7, "calm" = 1.3, "wake" = 1.3, "light" = 1.2, "smite" = 0.7),
	/datum/domain/healing = list("heal" = 1.6, "cleanse" = 1.6, "calm" = 1.2, "wake" = 1.2, "raise" = 1, "smite" = 0.4, "curse" = 0.7),
	/datum/domain/wilds = list("quicken" = 1.4, "strengthen" = 1.3, "bind" = 1.3, "feed" = 1.2, "heal" = 1.1, "cleanse" = 1.1),
	/datum/domain/forbidden = list("curse" = 1.7, "weaken" = 1.5, "smite" = 1.3, "blind" = 1.3, "raise" = 1.2, "heal" = 0.6, "bless" = 0.4, "cleanse" = 0.5),
))

/// Plain-language god replies when a god refuses an intent outright.
GLOBAL_LIST_INIT(prayer_refusals, list(
	"raise" = "The dead are the dead. Your god will not be asked to undo that.",
))

/// Words of love or kinship; when praying for another, some gods care.
GLOBAL_LIST_INIT(prayer_affection_words, list(
	"love", "beloved", "friend", "my child", "child", "brother", "sister", "dear", "darling", "my heart",
	"husband", "wife", "companion", "comrade", "mother", "father", "kin",
))

/// Extra affinity for the new requests. domain type = list(intent = multiplier)
GLOBAL_LIST_INIT(prayer_domain_affinity_ext, list(
	/datum/domain/sun = list("kindle" = 1.6, "hallow" = 1.4, "snuff" = 0.3, "banish" = 1.6, "nighteyes" = 0.6, "veil" = 0.4, "truth" = 1.3, "courage" = 1.2, "rot" = 0.3),
	/datum/domain/law = list("hallow" = 1.3, "truth" = 1.7, "forgive" = 1.3, "disarm" = 1.3, "fell" = 1.2, "courage" = 1.2, "madden" = 0.4, "veil" = 0.5),
	/datum/domain/war = list("rage" = 1.7, "courage" = 1.5, "vigor" = 1.4, "fell" = 1.4, "disarm" = 1.4, "repel" = 1.3, "frighten" = 1.3, "forgive" = 0.5, "tame" = 0.6),
	/datum/domain/hearth = list("kindle" = 1.5, "renew" = 1.4, "endure" = 1.5, "forgive" = 1.3, "sober" = 1.3, "courage" = 1.2, "rot" = 0.2, "frighten" = 0.4),
	/datum/domain/harvest = list("grow" = 2, "renew" = 1.3, "tame" = 1.3, "endure" = 1.2, "rot" = 0.3),
	/datum/domain/death = list("seek" = 1.6, "hallow" = 1.3, "banish" = 1.7, "frighten" = 1.4, "rot" = 1.3, "truth" = 1.2, "forgive" = 1.2, "renew" = 0.5, "grow" = 0.4),
	/datum/domain/sea = list("endure" = 1.4, "repel" = 1.4, "draw" = 1.4, "sicken" = 1.2, "sober" = 1.2),
	/datum/domain/moon = list("snuff" = 1.5, "seek" = 1.3, "veil" = 1.7, "nighteyes" = 1.7, "madden" = 1.4, "tongues" = 1.2, "truth" = 1.1),
	/datum/domain/love = list("forgive" = 1.5, "courage" = 1.3, "tame" = 1.4, "renew" = 1.3, "truth" = 1.2, "frighten" = 0.4, "rot" = 0.2),
	/datum/domain/trickery = list("veil" = 1.6, "madden" = 1.5, "disarm" = 1.5, "tongues" = 1.4, "truth" = 0.6, "draw" = 1.3),
	/datum/domain/trade = list("tongues" = 1.7, "truth" = 1.3, "sober" = 1.2, "repair" = 1.3, "vigor" = 1.2),
	/datum/domain/craft = list("kindle" = 1.3, "repair" = 2, "endure" = 1.3, "vigor" = 1.3, "courage" = 1.1),
	/datum/domain/knowledge = list("seek" = 1.4, "tongues" = 1.8, "truth" = 1.6, "nighteyes" = 1.2, "madden" = 1.2, "sober" = 1.2),
	/datum/domain/healing = list("renew" = 1.8, "sober" = 1.4, "vigor" = 1.3, "sicken" = 1.1, "rot" = 0.5),
	/datum/domain/wilds = list("seek" = 1.4, "tame" = 1.8, "grow" = 1.5, "nighteyes" = 1.4, "rage" = 1.3, "endure" = 1.4, "veil" = 1.2),
	/datum/domain/forbidden = list("snuff" = 1.6, "hallow" = 0.3, "rot" = 1.8, "madden" = 1.6, "sicken" = 1.5, "frighten" = 1.5, "banish" = 0.3, "forgive" = 0.3, "renew" = 0.7),
))

/// Held items that make a fitting offering. item type = list(domain types it pleases most)
GLOBAL_LIST_INIT(prayer_item_offerings, list(
	/obj/item/roguecoin = list(/datum/domain/trade, /datum/domain/law),
	/obj/item/reagent_containers/food = list(/datum/domain/harvest, /datum/domain/hearth),
	/obj/item/rogueweapon = list(/datum/domain/war, /datum/domain/craft),
	/obj/item/book = list(/datum/domain/knowledge, /datum/domain/law),
	/obj/item/candle = list(/datum/domain/sun, /datum/domain/moon, /datum/domain/death),
	/obj/item/roguegem = list(/datum/domain/trade, /datum/domain/craft, /datum/domain/forbidden),
	/obj/item/flowercrown = list(/datum/domain/love, /datum/domain/harvest),
	/obj/item/natural/bone = list(/datum/domain/death, /datum/domain/forbidden),
	/obj/item/organ = list(/datum/domain/forbidden, /datum/domain/death, /datum/domain/wilds),
	/obj/item/reagent_containers/glass = list(/datum/domain/sea, /datum/domain/hearth, /datum/domain/healing),
))

/// Latin forms: the old tongue the Weave was first bound in. Incantations spoken
/// in it are heard better (incantation.dm).
GLOBAL_LIST_INIT(latin_forms, list(
	"abi", "abige", "absconde", "accelera", "accende", "accipe hoc", "ad me veni", "aegrota", "aestus", "agri",
	"alliga", "ambusta", "anathema sit", "anima", "animum da", "animus", "aperi", "aperi portas", "aqua", "aquam",
	"arcana", "arcanum", "arma", "arma cadant", "armatura", "attrahe", "aucia", "belua", "benedic", "benedico",
	"bestia", "bibe", "cadaver", "cade", "caeca", "caelum", "cale", "calefac", "calor", "cape sanguinem meum",
	"cape vires meas", "carnem meam", "celeritas", "celeriter", "chao", "ciba", "cibus", "confirma", "consecra", "contere",
	"corpus", "corrobora", "corrumpe", "cresce", "cruor", "culpa", "cunctos", "cura", "custodi", "da",
	"debilita", "defende", "deice", "dele", "dementa", "deo gratias", "detege", "dic verum", "diu", "dolor",
	"dolorem", "doma", "domina", "domine", "dormi", "dura", "eam", "ebrietas", "ego", "ego sum",
	"eice", "enerva", "eum", "evigila", "ex", "ex nihilo", "excaeca", "excita", "exorcizo", "expelle",
	"expergiscere", "exsecror", "exstingue", "extingue", "fames", "febris", "feri", "ferio", "festina", "fiat",
	"fiat lux", "fidem meam", "flamma", "flammas", "floreat", "fortifica", "fortitudo", "fracta", "frange", "frigus",
	"fulmen", "fulmina", "furor", "furore imple", "gela", "germina", "glacies", "gladius", "gratias", "hanc",
	"hoc donum", "hostem", "hostis", "hunc", "ignem", "ignis", "ignosce", "illam", "illum", "illumina",
	"immobilis", "impero", "in", "in aeternum", "in nomine", "incende", "infirma", "inflamma", "inimicum", "inimicus",
	"inmortui", "insanias", "integra", "intellege linguas", "interfice", "inveni", "invoco", "iubeo", "larvae", "lassitudo",
	"leniter", "liga", "lingua", "loquere", "lumen", "luna", "lux", "magia", "magna vi",
	"maledic", "maledico", "mansuefac", "maxime", "medere", "mei", "mens", "mentem", "mihi", "miserere",
	"misericordia", "morbum da", "morbus", "mortui", "mortuum", "mortuus", "munda", "necesse est", "nihilo", "nomine",
	"nos", "nox", "nutri", "obmutesce", "oboedi", "obscura", "obsecro", "occide", "occulta", "oculi",
	"oculos", "oculos meos", "oculos noctis", "omnes", "ordo", "ordo ab chao", "oro", "os", "ossa", "ostende",
	"pacifica", "panis", "pasce", "paulum", "pax", "peccatum", "pelle", "per", "percute", "perdura",
	"perterre", "placa", "plagae", "portas", "potestas", "praesidium", "precor", "propera", "prosterne", "protege",
	"puni", "purga", "purifica", "putresce", "quaere", "quaeso", "quiesce", "recede", "recrea", "redi ad vitam",
	"refice", "reficite", "refrigera", "remitte", "renova", "repara", "repelle", "restaura", "restitue", "resurge",
	"revela", "robora", "saevi", "sana", "sana vulnera", "sanare", "sanctifica", "sanetur", "sanguinem", "sanguinem meum",
	"sanguis", "saxum", "sedate", "seges", "sile", "siste", "sitim exstingue", "sitis", "sobria", "sol",
	"somnus", "sopi", "spiritus", "statim", "stella", "sum", "suscita", "tabesce", "tace", "te rogo",
	"tege", "telum", "tenebrae", "tenebras", "tepefac", "terra", "terre", "timete", "tolera", "toto robore",
	"trahe", "tranquilla", "tuere", "umbra", "umbrae", "universos", "ure", "usque ad lucem", "vade retro", "vela",
	"veneno", "venenum", "veni", "ventus", "veritas", "vici", "vide in tenebris", "vidi", "vigora", "vincula",
	"vires da", "vires meas", "visus", "voco", "vox", "vulnera", "vulnus",
))
