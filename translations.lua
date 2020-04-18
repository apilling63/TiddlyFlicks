-----------------------------------------------------------------------------------------
--
-- translations
--
-----------------------------------------------------------------------------------------
local t = {}

local language = "en"

local w =
{
	["Escape from the Country"] =
    	{
	        ["en"] = "Escape from the Country",
        	["fr"] = "Fuir le pays",
    	},

	["Escape from the Moon"] =
    	{
	        ["en"] = "Escape from the Moon",
        	["fr"] = "S'échapper de la lune",
    	},

	["COMING SOON"] =
	{
        	["en"] = "COMING SOON!",
	        ["fr"] = "À venir!",
    	},

	["RATE"] =
	{
        	["en"] = "Would you like to rate him?",
	        ["fr"] = "Vous souhaitez noter lui?",
	},

	["OPINION"] =
	{
        	["en"] = "Tiddly values your opinion.",
	        ["fr"] = "Tiddly valorise votre opinion.",
	},

	["SURE"] =
	{
        	["en"] = "Sure!",
	        ["fr"] = "Sûr!",
	},

	["MAYBE LATER"] =
	{
        	["en"] = "Maybe later",
	        ["fr"] = "Peut-être plus tard",
	},

	["SORRY"] =
	{
        	["en"] = "Sorry",
	        ["fr"] = "Désolé",
	},

	["CLICK TO UNLOCK"] =
	{
        	["en"] = "Click to unlock",
	        ["fr"] = "Cliquez pour déverrouiller",
	},

	["DEVICE NO IAP"] =
	{
        	["en"] = "In app purchases not supported on this system or device. Please activate purchases and try again via the levels page",
	        ["fr"] = "Les achats app non pris en charge sur ce système ou dispositif. Veuillez activer les achats et essayez de nouveau via la page de niveaux",
	},

	["IAP SUCCESS"] =
	{
        	["en"] = "The purchase was successful",
	        ["fr"] = "L'achat a été un succès",
	},

	["IAP CANCELLED"] =
	{
        	["en"] = "The purchase was cancelled, you will not be charged",
	        ["fr"] = "L'achat a été annulé, vous paierez pas",
	},

	["IAP FAILED"] =
	{
        	["en"] = "The purchase failed, you will not be charged",
	        ["fr"] = "L'achat a échoué, vous paierez pas",
	},

	["IAP DID NOT SUCCEED"] =
	{
        	["en"] = "The purchase did not succeed, you will not be charged",
	        ["fr"] = "L'achat n'a pas réussi, vous paierez pas",
	},

	["SYSTEM IAP"] =
	{
        	["en"] = "You can't make purchases on this system",
	        ["fr"] = "Vous ne pouvez pas effectuer des achats sur ce système",
	},


	["PURCHASE"] =
	{
        	["en"] = "Purchase",
	        ["fr"] = "L'achat",
	},

	["HOW TO 1"] =
	{
        	["en"] = "Hi there!",
	        ["fr"] = "Salut!",
	},

	["HOW TO 2"] =
	{
        	["en"] = "I'm Tiddly and I need your help",
	        ["fr"] = "Je suis Tiddly et j'ai besoin de votre aide",
	},

	["HOW TO 3"] =
	{
        	["en"] = "I'm Tiddly and I need your help",
	        ["fr"] = "Je suis Tiddly et j'ai besoin de votre aide",
	},

	["HOW TO POT"] =
	{
        	["en"] = "POT",
	        ["fr"] = "POT",
	},

	["HOW TO 3"] =
	{
        	["en"] = "Use your skill to get me",
	        ["fr"] = "Utilisez vos compétences pour me",
	},

	["HOW TO 4"] =
	{
        	["en"] = "into the pot on each level",
	        ["fr"] = "mettre dans le pot sur chaque niveau",
	},

	["HOW TO 5"] =
	{
        	["en"] = "When I'm stationary you can use",
	        ["fr"] = "Lorsque je suis immobile, vous pouvez",
	},

	["HOW TO 6"] =
	{
        	["en"] = "the flicker to flick me forward",
	        ["fr"] = "utiliser le scintillement à feuilleter moi avant",
	},

	["HOW TO 7"] =
	{
        	["en"] = "The upward motion determines trajectory.",
	        ["fr"] = "Le mouvement ascendant détermine la trajectoire.",
	},

	["HOW TO 8"] =
	{
        	["en"] = "The bottom of my face gives a steep flick",
	        ["fr"] = "Le bas de mon visage donne une pichenette raide",
	},

	["HOW TO 9"] =
	{
        	["en"] = "The top of my face gives",
	        ["fr"] = "Le haut de mon visage donne",
	},

	["HOW TO 11"] =
	{
        	["en"] = "The downward motion determines distance.",
	        ["fr"] = "Le mouvement vers le bas détermine la distance.",
	},

	["HOW TO 12"] =
	{
        	["en"] = "The further you go the further the flick",
	        ["fr"] = "Plus vous allez plus le film",
	},

	["HOW TO 13"] =
	{
        	["en"] = "And please watch out for dangers!",
	        ["fr"] = "Et s'il vous plaît faites attention aux dangers!",
	},

	["HOW TO 14"] =
	{
        	["en"] = "Let's go!",
	        ["fr"] = "Allons-y!",
	},

	["HOW TO 10"] =
	{
        	["en"] = "a shallow flick",
	        ["fr"] = "une pichenette peu profonde",
	},

	["MASTER"] =
	{
        	["en"] = "TIDDLY MASTER!!",
	        ["fr"] = "TIDDLY MASTER!!",
	},

	["UNLOCK"] =
	{
        	["en"] = "Unlock",
	        ["fr"] = "Déverrouiller",
	},

	["TRIUMPH"] =
	{
        	["en"] = "A TIDDLY TRIUMPH!!",
	        ["fr"] = "UN TRIOMPHE TIDDLY!!",
	},

	["OUT OF BOUNDS"] =
	{
        	["en"] = "OUT OF BOUNDS!!",
	        ["fr"] = "HORS DES LIMITES!!",
	},

	["STUNG"] =
	{
        	["en"] = "TIDDLY GOT STUNG!!",
	        ["fr"] = "Tiddly a été piqué!!",
	},

	["SHOCK"] =
	{
        	["en"] = "TIDDLY GOT SHOCKED!!",
	        ["fr"] = "Tiddly suis choqué!!",
	},

	["RESTART"] =
	{
        	["en"] = "Tiddly must head back to the start",
	        ["fr"] = "Tiddly doit diriger au début",
	},

	["HAVE A GO"] =
	{
        	["en"] = "Have a go at the next level!",
	        ["fr"] = "Avoir un aller au niveau suivant!",
	},

	["LEVEL"] =
	{
        	["en"] = "Level ",
	        ["fr"] = "Niveau ",
	},

	["TIP 1A"] =
	{
        	["en"] = "TIP: the further you flick",
	        ["fr"] = "Astuce : plus vous feuilleter",
	},

	["TIP 1B"] =
	{
        	["en"] = "the further Tiddly travels",
	        ["fr"] = "plus Tiddly voyages",
	},

	["TIP 2A"] =
	{
        	["en"] = "TIP: Flick down from the bottom of",
	        ["fr"] = "Astuce : Flick vers le bas par le",
	},

	["TIP 2B"] =
	{
        	["en"] = "the face for a steep trajectory",
	        ["fr"] = "bas du visage pour une trajectoire raide",
	},

	["TIP 3A"] =
	{
        	["en"] = "TIP: Flick down from the top",
	        ["fr"] = "Astuce : Effleurez vers le bas par le haut",
	},

	["TIP 3B"] =
	{
        	["en"] = "of the face for a shallow trajectory",
	        ["fr"] = "du visage pour une trajectoire peu profonde",
	},


	["TIP 4A"] =
	{
        	["en"] = "TIP: Wasps hurt - avoid them",
	        ["fr"] = "Astuce : Les guêpes blessés - éviter",
	},

	["TIP 5A"] =
	{
        	["en"] = "TIP: The centre of flowers have",
	        ["fr"] = "Astuce : Le centre de fleurs ont",
	},

	["TIP 5B"] =
	{
        	["en"] = "special powers",
	        ["fr"] = "des pouvoirs spéciaux",
	},


	["TIP 6A"] =
	{
        	["en"] = "TIP: Tiddly needs to interact with objects",
	        ["fr"] = "ASTUCE: Tiddly besoin d'interagir avec",
	},

	["TIP 6B"] =
	{
        	["en"] = "to remove covers from the target pot",
	        ["fr"] = "des objets pour retirer les caches du pot cible",
	},

	["CONGRATS UNLOCK"] =
	{
        	["en"] = "Congratulations upon completing the first 32 levels of Tiddly Flicks Escape from the Country - you're a true Tiddly Master! Continue the fun by unlocking some more levels",
	        ["fr"] = "Félicitations à la fin des première 32 niveaux de Tiddly Flicks fuire le pays - vous êtes un vrai Maître Tiddly ! Continuer la fete en déverrouillant des niveaux supplémentaires.",
	},


}
 
function t.getPhrase(phrase)
	return w[phrase][language]
end

function t.setLanguage(lang)
	language = lang
end

return t
