package harry_potter.game 
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import harry_potter.utils.LessonTypes;
	import harry_potter.assets.Global;
	import harry_potter.utils.DeckGeneration;
	import harry_potter.game.Card;
	import caurina.transitions.Tweener;
	import fano.utils.MessageWindow;
	import fano.utils.DelayedFunctionCall;
	
	public class Player extends Sprite {
		//Positioning constants
		private static const DECK_X:uint = 58;
		private static const DECK_Y:uint = 433;
		
		private static const HAND_X:uint  = 176 + Card.CARD_WIDTH * 0.5;
		private static const HAND_Y:uint = 518 + Card.CARD_HEIGHT * 0.5;
		private static const HAND_SPACING:uint = 10;
		
		private static const STARTING_X:uint = 13 + Card.CARD_WIDTH * 0.5;
		private static const STARTING_Y:uint = 518 + Card.CARD_HEIGHT * 0.5;
		
		private static const LESSONS_X:uint = 270 + Card.CARD_WIDTH * 0.5;
		private static const LESSONS_Y:uint = 353 + Card.CARD_HEIGHT * 0.5;
		private static const LESSONS_Y_SPACING:uint = 12;
		private static const LESSONS_X_SPACING:uint = 75;
		
		private static const DISCARD_PILE_X:uint  = 90;
		private static const DISCARD_PILE_Y:uint = 475 - Card.CARD_HEIGHT - 15;
		
		private static const CREATURES_X:uint = 504 + Card.CARD_WIDTH * 0.5;
		private static const CREATURES_Y:uint = 353 + Card.CARD_HEIGHT * 0.5;
		private static const CREATURES_X_SPACING:uint = 75;
		private static const CREATURES_Y_SPACING:uint = 50;
		
		private var stats:StatsPanel;
		
		//In play objects
		private var lessons:CardStack;
		private var creatures:CardStack;
		private var items:CardStack; //for later
		
		//Data structures
		private var deck:Deck;
		private var hand:Hand;
		private var discardPile:DiscardPile;
		
		//Player variables
		private var numLessons:int;
		private var hasType:Array; //size 5 array stating which lessons we have in play.
		private var damagePerTurn:int;
		
		private var starting_character:Card;
		
		/**TEMP**/ // ??
		public var oppositePlayer:Player;
		
		public function Player(_deck:Deck) {
			deck = _deck;
			init();
		}
		
		private function init():void {
			hand = new Hand();
			
			lessons = new CardStack();
			creatures = new CardStack();
			items = new CardStack();
			
			numLessons = 0;
			hasType = [0, 0, 0, 0, 0];
			discardPile = new DiscardPile();
			
			damagePerTurn = 0;
			
			stats = new StatsPanel();
			addChild(stats);
			
			stats.update(StatsPanel.LABEL_DECK, deck.getNumCards());
			
			switch(deck._mainLesson) {
				case LessonTypes.CARE_OF_MAGICAL_CREATURES:
					starting_character = new Card(DeckGeneration.CHARACTER_CREATURES);
					break;
				case LessonTypes.CHARMS:
					starting_character = new Card(DeckGeneration.CHARACTER_CHARMS);
					break;
				case LessonTypes.TRANSFIGURATION:
					starting_character = new Card(DeckGeneration.CHARACTER_TRANSFIGURATIONS);
					break;
				case LessonTypes.POTIONS:
					starting_character = new Card(DeckGeneration.CHARACTER_POTIONS);
					break;
				case LessonTypes.QUIDDITCH:
					starting_character = new Card(DeckGeneration.CHARACTER_QUIDDITCH);
					break;
				default:
					throw new Error("Invalid type at deck.mainLesson!");
			}
			
			//Add main character to displayList, probably separate into different function to clean up this code
			starting_character.x = STARTING_X;
			starting_character.y = STARTING_Y;
			starting_character.flip();
			starting_character.rotate();
			addChild(starting_character);
			
			deck.shuffle();
			deck.x = DECK_X;
			deck.y = DECK_Y;
			addChild(deck);
			deck.addEventListener(MouseEvent.CLICK, draw);
			
			
			// Draw Hand
			for (var i:int = 0; i < 7; i++) {
				new DelayedFunctionCall(draw, i * 200 + 400);
			}
		}
		
		private function adjustHandSpacing():void {
			//Create a shrink value depending on the number of cards in the hand.
			var num:int = hand.getNumCards();
			var shrinkValue:Number = 1;
			
			//Adjust value based on number of cards in the hand
			if (num >= 50) {
				shrinkValue = 0.15;
			}
			else if (num >= 33) {
				shrinkValue = 0.2;
			}
			else if (num >= 21) {
				shrinkValue = 0.3;
			}
			else if (num >= 15) {
				shrinkValue = 0.5;
			}
			else if (num >= 11) {
				shrinkValue = 0.7;
			}
			
			//Figure out the target X of the card based on the shrink value
			var targetX:int;
			for (var i:int = 0; i < hand.getNumCards(); i++) {
				targetX = HAND_X + i * ((Card.CARD_WIDTH + HAND_SPACING) * shrinkValue);
				//Tween it into place
				Tweener.addTween(hand.cardAt(i), { x: targetX, y: HAND_Y, time: 0.8, transition: "easeOutQuad" } );
				
			}
		}
		
		/**
		 * Draws a card from the player's deck and places it into his hand.
		 */
		public function draw(e:MouseEvent = null):void {
			//Animate here
			var thisCard:Card = deck.getTopCard();
			stats.update(StatsPanel.LABEL_DECK, deck.getNumCards());
			
			if (deck.getNumCards() == 0 || thisCard == null) {
				//lose!
				Global.console.print("Deck is out of cards!");
				removeChild(deck);
				return;
			}
			
			hand.add(thisCard);
			
			thisCard.addEventListener(MouseEvent.CLICK, playCard);
			
			/***Animation***/
			//The card begins at the deck x and y values
			thisCard.x = DECK_X + Card.CARD_WIDTH * 0.5;
			thisCard.y = DECK_Y + Card.CARD_HEIGHT * 0.5;
			
			addChild(thisCard);
			
			thisCard.flip();
			
			//Adjust the hand spacing, since the above card is already added to the hand array
			//the following function will be able to tween it to the right spot.
			adjustHandSpacing();
		}
		
		/**
		 * Causes the player to take damage by discarding cards from the top of his deck.
		 * @param	amount		The amount of damage to take.
		 * @param	animDelay	How long to wait (in seconds) before playing the animation (default = 0).
		 */
		public function takeDamage(amount:uint, animDelay:Number = 0):void {
			if (amount == 0) return;
			
			var card:Card;
			for (var i:int = 0; i < amount; i++) {
				card = deck.getTopCard();
				stats.update(StatsPanel.LABEL_DECK, deck.getNumCards());
				
				if (deck.getNumCards() == 0 || card == null) {
					//lose!
					Global.console.print("Deck is out of cards!");
					removeChild(deck);
					return;
				}
				
				/***Animation***/
				//The card begins at the deck x and y values
				card.x = DECK_X + Card.CARD_WIDTH * 0.5;
				card.y = DECK_Y + Card.CARD_HEIGHT * 0.5;
				
				addChild(card);
				card.alpha = 0;
				
				discard(card, animDelay + i * 0.3);
				
				card.flip();
			}
		}
		
		/**
		 * Attemps to play the card clicked by the player.
		 */
		public function playCard(e:MouseEvent):void {
			var thisCard:Card = Card(e.target); //grab a reference to the clicked card.
			
			//check card type and delegate task
			//Should we have a CardTypes enum? i.e. CardTypes.LESSON etc.?  **/
			switch(thisCard.type) {
				case "Lesson":
					playLesson(thisCard);
					break;
				case "Creature":
					playCreature(thisCard);
			}
		}
		
		/**
		 * Plays a lesson from the players hand.
		 * @param	card	A reference to the card to be played.
		 * @return			A boolean stating whether this card was played sucessfully.
		 */
		private function playLesson(card:Card):Boolean {
			//no checks needed, playing a lesson is always valid.
			hand.remove(card);
			adjustHandSpacing();
			card.removeEventListener(MouseEvent.CLICK, playCard);
			
			//update player variables
			numLessons++;
			
			//calculate targetX and targetY
			var targetX:int = LESSONS_X + (lessons.getNumCards() % 3) * LESSONS_X_SPACING;
			var targetY:int = LESSONS_Y + (int(lessons.getNumCards() / 3)) * LESSONS_Y_SPACING;
			
			//animate to proper location on the board.
			//move to top of display list
			setChildIndex(card, numChildren - 1);
			//Tween
			Tweener.addTween(card, {x: targetX, y:targetY, transition:"easeOutQuad", time: 0.7} );
			card.rotate();
			
			//finally, add it to the proper stack
			lessons.add(card);
			
			hasType[LessonTypes.convertToID(card.cardName)]++;
			stats.update(StatsPanel.LABEL_LESSONS, numLessons, hasType);
			
			rearrangeLessons();
			
			return true;
		}
		
		/**
		 * Plays a creature from the players hand.
		 * @param	card	A reference to the card to be played.
		 * @return			A boolean stating whether this card was played sucessfully.
		 */
		private function playCreature(card:Card):Boolean {
			//Must perform checks!
			var numCOMCLessons:int = hasType[LessonTypes.convertToID(LessonTypes.CARE_OF_MAGICAL_CREATURES)];
			if (numLessons < card.lessons_required[1]) {
				new MessageWindow(this, "Can't play that card!", "You do not have enough lessons to play this card!");
				return false;
			} 
			else if (numCOMCLessons < 1 || numCOMCLessons < card.lessonsToDiscardWhenPlayed) {
				new MessageWindow(this, "Can't play that card!", "You need more Care of Magical Creatures lessons in play \nto play this card!");
				return false;
			} 
			else if (creatures.getNumCards() >= 12) {
				new MessageWindow(this, "Can't play that card!", "You don't have enough room on the board to play another creature!");
				return false;
			}
			
			card.removeEventListener(MouseEvent.CLICK, playCard);
			
			//remove lessons from play
			discardLessons(LessonTypes.convertToID(LessonTypes.CARE_OF_MAGICAL_CREATURES), card.lessonsToDiscardWhenPlayed);
			
			//Place creature card on board
			card.rotate();
			
			//tween to x y location
			var targetX:int = CREATURES_X + CREATURES_X_SPACING * (creatures.getNumCards() % 4);
			var targetY:int = CREATURES_Y;
			
			if (creatures.getNumCards() >= 8) {
				targetY += CREATURES_Y_SPACING * 2;
			}
			else if (creatures.getNumCards() >= 4) {
				targetY += CREATURES_Y_SPACING;
			}
			
			Tweener.addTween(card, { x: targetX, y: targetY, time: 1, transition: "easeOutQuad" } );
			//adjust damage per turn value
			damagePerTurn += card.damagePerTurn;
			stats.update(StatsPanel.LABEL_CREATURES, damagePerTurn);
			//Add to appropriate data structure
			hand.remove(card);
			adjustHandSpacing();
			
			creatures.add(card);
			
			oppositePlayer.takeDamage(card.damageWhenPlayed, card.lessonsToDiscardWhenPlayed*0.2);
			return true;
		}
		
		/**
		 * Discards the given amount of lessons of the given type **ASSUMES THERE ARE ENOUGH LESSONS TO DISCARD**
		 * @param	type		Must be a LessonTypes constant
		 * @param	amount		Number of lessons to be discarded
		 */
		private function discardLessons(type:uint, amount:uint):void {
			if (amount == 0) return;
			
			var discarded:uint = 0;
			for (var i:int = 0; i < lessons.getNumCards(); i++) {
				if (LessonTypes.convertToID(lessons.cardAt(i).lesson_provides[0]) == type) {
					//Add to discard list
					discard(lessons.cardAt(i), discarded * 0.2);
					//rotate, since the lessons will be horizontal on the board
					lessons.cardAt(i).rotate(null, discarded*0.2);
					//Remove from lessons list
					lessons.remove(lessons.cardAt(i));
					//update player variables
					hasType[type]--;
					numLessons--;
					stats.update(StatsPanel.LABEL_LESSONS, numLessons, hasType);
					
					//break when we're done
					if (++discarded == amount) {
						break;
					}
				}
			}
			
			rearrangeLessons(discarded * 0.2);
		}
		
		/**
		 * Moves the given card to this player's discard file *DOES NOT ROTATE*
		 * @param	card		the card to be discarded.
		 * @param	animDelay	How long to wait (in seconds) before playing the animation (default = 0).
		 */
		private function discard(card:Card, animDelay:Number = 0):void {
			discardPile.add(card);
			//tween to location
			var targetX:int = DISCARD_PILE_X - discardPile.getNumCards() / 10;
			var targetY:int = DISCARD_PILE_Y - discardPile.getNumCards() / 10;
			
			Tweener.addTween(card, { x: targetX, y: targetY, alpha: 1, time: 0.5, delay: animDelay, transition: "easeOutQuad" } );
			//switch index to top so that it displays on top of the discard pile
			setChildIndex(card, numChildren - 1);
		}
		
		/**
		 * Rearranges the lessons to make them look neat on the board
		 * @param	animDelay	How long to wait (in seconds) before playing the animation (default = 0).
		 */
		private function rearrangeLessons(animDelay:Number = 0):void {
			lessons.sort();
			
			var targetX:int;
			var targetY:int;
			
			var thisCard:Card;
			for (var i:int = 0; i < lessons.getNumCards(); i++) {
				thisCard = lessons.cardAt(i);
				
				targetX = LESSONS_X + (i % 3) * LESSONS_X_SPACING;
				targetY = LESSONS_Y + (int(i / 3)) * LESSONS_Y_SPACING;
				
				setChildIndex(thisCard, numChildren - 1);
				
				//Only tween if the positions differ from the calculated ones.
				if (thisCard.x != targetX || thisCard.y != targetY) {
					Tweener.addTween(thisCard, { x: targetX, y:targetY, transition:"easeOutQuad", time: 0.7, delay: animDelay } );
				}
			}
		}
	}
}