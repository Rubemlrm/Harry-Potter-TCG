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
		private static const LESSONS_Y:uint = 356 + Card.CARD_HEIGHT * 0.5;
		private static const LESSONS_Y_SPACING:uint = 12;
		private static const LESSONS_X_SPACING:uint = 75;
		
		private var deck:Deck;
		private var hand:Hand;
		private var discard:Discard;
		
		private var stats:StatsPanel;
		
		//In play objects
		private var lessons:CardStack;
		private var creatures:CardStack; //for later
		private var items:CardStack; //for later
		
		//Player variables
		private var numLessons:int;
		private var hasType:Array; //size 5 array stating which lessons we have in play.
		
		private var starting_character:Card;
		
		public function Player(_deck:Deck) {
			deck = _deck;
			init();
		}
		
		private function init():void {
			hand = new Hand();
			//Not sure if we'll do any display stuff in the hand class
			//hand.x = HAND_X;
			//hand.y = HAND_Y;
			//addChild(hand);
			
			lessons = new CardStack();
			creatures = new CardStack();
			items = new CardStack();
			
			numLessons = 0;
			hasType = [0, 0, 0, 0, 0];
			discard = new Discard();
			
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
			//TO DO - Add main character to displayList, probably separate into different function to clean up this code
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
			var shrinkValue:Number;
			if (num < 11) {
				shrinkValue = 1;
			} else if (num >= 11 && num < 15) {
				shrinkValue = 0.7;
			} else if (num >= 15 && num < 21) {
				shrinkValue = 0.5;
			} else if (num >= 21 && num < 33) {
				shrinkValue = 0.3;
			} else if (num >= 33 && num < 50) {
				shrinkValue = 0.2;
			} else {
				shrinkValue = 0.15;
			}
			
			//Figure out the target X of the card based on the shrink value
			var targetX:int;
			for (var i:int = 0; i < hand.getNumCards(); i++) {
				targetX = HAND_X + i * ((Card.CARD_WIDTH + HAND_SPACING) * shrinkValue);
				//Tween it into place
				Tweener.addTween(hand.cardAt(i), {x: targetX, y: HAND_Y, time:0.8, transition:"easeOutQuad"} );
			}
		}
		
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
		
		public function playLesson(card:Card):void {
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
			//checkLessonTypes();
			hasType[LessonTypes.convertToID(card.cardName)]++;
			stats.update(StatsPanel.LABEL_LESSONS, numLessons, hasType);
			rearrangeLessons();
		}
		
		public function playCreature(card:Card):Boolean {
			//Must perform checks!
			var numCOMCLessons:int = hasType[LessonTypes.convertToID(LessonTypes.CARE_OF_MAGICAL_CREATURES)];
			if (numLessons < card.lessons_required[1]) {
				new MessageWindow(this, "Can't play that card!", "You do not have enough lessons to play this card!");
				return false;
			} else if (numCOMCLessons < 1 || numCOMCLessons < card.lessonsToDiscardWhenPlayed) {
				new MessageWindow(this, "Can't play that card!", "You need more Care of Magical Creatures lesson in play \nto play this card!");
				return false;
			}
			
			Global.console.print("Played Creature!");
			//remove lessons from play
				//rotate
				//tween to x y location
				//remove from lessons list
				//add to discard list
				//hide previous graphic for performance?
			//play creature card
				//rotate
				//tween to x y location
				//adjust damage per turn value
				//remove from hand list
				//add to creatures list
		}
		
		public function rearrangeLessons():void {
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
					Tweener.addTween(thisCard, { x: targetX, y:targetY, transition:"easeOutQuad", time: 0.7 } );
				}
			}
		}
	}
}