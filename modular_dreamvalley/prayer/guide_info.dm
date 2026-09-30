// Plain explanations for the Prayer guide. "p" in the numbers below is the
// request's strength: about 1 for an ordinary, well-made prayer, lower for a weak
// one, up to 2 or more for a mighty one.

/// intent = list(what it does, how subjects change it)
GLOBAL_LIST_INIT(prayer_intent_info, list(
	"heal" = list(
		"Closes wounds: heals about 20 x strength brute damage, 10 x strength burns, and knits open wounds. On the undead, holy gods burn instead (15 x strength) - Forbidden gods mend them.",
		"<b>burns</b> heals burns only, more of them. <b>bones</b> sets fractures. <b>blood</b> slows bleeding and restores lost blood. <b>poison</b>/<b>fever</b> work as Cleanse. <b>pain</b> numbs pain. <b>mind</b> calms. <b>fatigue</b> restores energy. <b>eyes</b> clears blindness. <b>hunger</b>/<b>thirst</b> feed and water. <b>the dead</b> tries to raise them."),
	"renew" = list(
		"Lasting healing: for about 30 seconds x strength the target heals a little brute and burn damage and knits wounds every two seconds.",
		"Works on anyone alive. Best from Healing gods."),
	"cleanse" = list(
		"Purges poison: removes toxin damage (20 x strength) and poisonous reagents in the blood.",
		"<b>fever</b>/<b>rot</b>/<b>infection</b> removes infection, poisoning and early necrosis from the organs. <b>fire</b> puts out flames. <b>mind</b> calms. <b>undead</b> burns an undead target. <b>eyes</b> clears sight. <b>drink</b> sobers. Hold <b>water</b> to make holy water, or <b>food</b> to bless it."),
	"shield" = list(
		"A divine ward: for about 45 seconds x strength the target gains Constitution and Willpower. A strong prayer also fortifies them, making all healing stronger.",
		"With a held <b>weapon</b>, blesses it instead (see Bless)."),
	"smite" = list(
		"Holy damage: 24 x strength burn damage, two and a half times that against the undead. A strong prayer also sets the target alight with divine fire. Asking to smite yourself works, and hurts.",
		"Naming the <b>undead</b> guarantees the bonus against them."),
	"banish" = list(
		"Tears at the undead: 30 x strength burn damage and knocks them down. Does nothing to the living.",
		""),
	"calm" = list(
		"Steadies a mind: restores sanity (15 x strength) and soothes stress.",
		"<b>pain</b> numbs pain for a while. <b>fire</b> puts out flames. With a <b>beast</b>, tames it (see Tame)."),
	"forgive" = list(
		"Lifts guilt: removes curses and the weight of sins from the target's mood and restores some sanity.",
		""),
	"courage" = list(
		"A steady heart: Willpower for about a minute x strength, and while it lasts the target's sanity cannot be shaken. Also ends dread.",
		""),
	"strengthen" = list(
		"God-given strength: Strength and Constitution for about a minute x strength.",
		"<b>fatigue</b> restores energy instead. With a held <b>weapon</b> or <b>gear</b>, blesses or mends it."),
	"rage" = list(
		"Holy fury: for about 30 seconds x strength the target is stronger and faster, feels no pain, and thinks less clearly. When it ends, they're exhausted.",
		""),
	"vigor" = list(
		"Tireless: restores energy now and keeps restoring it for about 40 seconds x strength.",
		""),
	"quicken" = list(
		"Haste: Speed for about 40 seconds x strength.",
		"With <b>crops</b>, makes them grow (see Grow)."),
	"weaken" = list(
		"Saps a foe: loses Strength and Speed for about 45 seconds x strength.",
		"<b>fatigue</b> drains their energy instead."),
	"curse" = list(
		"A curse: the target loses Fortune and Willpower for about two minutes x strength and feels its weight on their mood.",
		""),
	"bind" = list(
		"Holds the target in place for 2 seconds plus 3 x strength.",
		"<b>blood</b> stops bleeding instead."),
	"sleep" = list(
		"Blurs the target's eyes, and a strong enough prayer puts them to sleep for a few seconds. Asking it for yourself lets you sleep.",
		""),
	"wake" = list(
		"Wakes a sleeping or unconscious target and gives them a little energy.",
		""),
	"feed" = list(
		"Fills the belly (a good meal's worth x strength).",
		"<b>thirst</b> gives water instead. With <b>crops</b>, feeds the soil. With held <b>food</b>, blesses it."),
	"quench" = list(
		"Slakes thirst (a good drink's worth x strength).",
		"<b>fire</b> puts out flames."),
	"warm" = list(
		"Warms a cold body back towards normal.",
		""),
	"cool" = list(
		"Cools an overheated body, or puts out a burning one.",
		""),
	"light" = list(
		"A light gathers around the target for about a minute x strength.",
		""),
	"reveal" = list(
		"Clears blindness and blurred sight.",
		"<b>darkness</b> casts a wide light around the target instead."),
	"truth" = list(
		"Reads a heart: tells you whether the target is troubled, how steady their mind is, and which god they pray to. They feel it happen.",
		""),
	"blind" = list(
		"Darkens the target's eyes for a few seconds x strength.",
		""),
	"silence" = list(
		"Takes the target's voice for a while.",
		""),
	"speak" = list(
		"Gives a silenced target their voice back.",
		""),
	"bless" = list(
		"Good fortune: Fortune for about three minutes x strength, and a lift to the target's mood.",
		"With a held <b>weapon</b>, it glows and hits harder (+3 to +9) for about a minute x strength. With held <b>water</b>, makes holy water. With held <b>food</b>, blesses it. With <b>crops</b>, feeds the soil. With a <b>beast</b>, tames it."),
	"raise" = list(
		"Brings the dead back. Needs a very strong prayer (strength 1.3 or more) and a body that isn't too broken. Costs 400 devotion and wounds the one who asks. Death gods refuse outright.",
		""),
	"veil" = list(
		"The target fades until they are hard to see, for about 30 seconds x strength.",
		""),
	"tongues" = list(
		"The target understands every common language for about two minutes x strength.",
		""),
	"frighten" = list(
		"Dread: the target is slowed, shaking and losing sanity for about 20 seconds x strength.",
		""),
	"madden" = list(
		"Madness: the target stumbles about confused and hears things for about 15 seconds x strength.",
		""),
	"sicken" = list(
		"Makes the target sick: toxin damage, and a strong prayer makes them vomit.",
		""),
	"rot" = list(
		"Rot: the target takes toxin damage over time for about 40 seconds x strength, and their organs may begin to die.",
		""),
	"endure" = list(
		"Weathering: heat and cold can't harm the target for about two minutes x strength.",
		""),
	"nighteyes" = list(
		"Night eyes: the target sees in the dark for about a minute x strength.",
		""),
	"disarm" = list(
		"Wrenches the weapon from the target's hand. A weak prayer may fail.",
		""),
	"fell" = list(
		"Throws the target to the ground for a moment.",
		""),
	"repel" = list(
		"Hurls the target away from you, further with a stronger prayer.",
		""),
	"draw" = list(
		"Drags the target towards you.",
		""),
	"sober" = list(
		"Clears drink from the target's blood and head.",
		""),
	"grow" = list(
		"Waters and feeds all tilled soil within two steps of you.",
		""),
	"tame" = list(
		"A beast stops treating you as prey for about a minute x strength.",
		"Only works on beasts, not people."),
	"repair" = list(
		"Mends the item you're holding by a quarter of its durability x strength.",
		""),
	"kindle" = list(
		"Lights every hearth, lamp and candle around you. With nothing to light, a strong prayer sets the target alight instead.",
		""),
	"snuff" = list(
		"Puts out every light around you.",
		""),
	"seek" = list(
		"Tells you the direction and rough distance to the nearest of what you seek.",
		"<b>the dead</b> (default), <b>undead</b>, <b>beasts</b>, <b>foes</b> or <b>water</b>."),
	"hallow" = list(
		"Makes the ground around the target holy for about a minute x strength: it burns the undead standing on it, slowly heals the living, and counts as a holy place to pray.",
		""),
))

/// subject = what naming it means
GLOBAL_LIST_INIT(prayer_subject_info, list(
	"wounds" = "Cuts, gashes and torn flesh.",
	"body" = "The whole person; the default for most blessings and curses.",
	"blood" = "Bleeding and lost blood.",
	"bones" = "Broken bones.",
	"burns" = "Burned flesh.",
	"poison" = "Toxins and venom in the blood.",
	"fever" = "Infection, rot, sickness and early necrosis in the organs.",
	"pain" = "Pain itself - numbing it.",
	"mind" = "Sanity, fear, grief and stress.",
	"fire" = "Flames on a body, or lights to kindle.",
	"cold" = "A chilled body.",
	"heat" = "An overheated body.",
	"hunger" = "An empty belly.",
	"thirst" = "A dry throat.",
	"fatigue" = "Spent energy.",
	"eyes" = "Sight - blindness and blur.",
	"tongue" = "A voice.",
	"darkness" = "The dark around someone, or lights to snuff.",
	"dead" = "Corpses - to raise, or to seek.",
	"undead" = "The unholy and the restless dead.",
	"foe" = "An enemy; the default for harmful requests.",
	"water" = "Water you're holding - to make holy water.",
	"weapon" = "The weapon you're holding - to bless, mend, or strike from a foe's hand.",
	"gear" = "Armour, tools or anything else you're holding - to mend.",
	"crops" = "Tilled soil within two steps of you.",
	"beast" = "An animal - to tame.",
	"drink" = "Drunkenness.",
	"sin" = "Guilt and curses.",
	"truth" = "What someone hides.",
	"food" = "Food you're holding - to bless.",
))
