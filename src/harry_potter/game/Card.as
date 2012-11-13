package harry_potter.game 
{
	import caurina.transitions.Tweener;
	import fano.utils.ToolTip;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import harry_potter.assets.Global;
	
	
	/**
	 * ...
	 * @author Stefano Fiumara
	 */
	public class Card extends Sprite {
		/*CLASS VARIABLES*/
		//static variable to hold cardback bitmapdata, which will be used by every instance of Card. Instantiated and loaded in Main.as
		public static var cardBack:BitmapData;
		//card library variables
		public static var library:XML;
		//reference to sprite sheet
		public static var spriteSheet:Bitmap;
		
		/*CARD VARIABLES*/
		//The title of the card
		public var cardName:String;
		//Card description
		public var description:String;
		//Card type (Creature, Lesson, Spell, etc.)
		public var type:String;
		//Bitmap to hold our card graphic.
		private var cardGfx:Bitmap;
		//Bitmap data reference for this card's graphic.
		private var cardBitmapData:BitmapData;
		//Whether the card is face up or face down.
		public var faceUp:Boolean;
		//Whether the card is horizontally oriented or not
		public var horizontal:Boolean;
		
		//instance of the tool tip class
		private var toolTip:ToolTip;
		private var showingTooltip:Boolean;
		
		/**
		 * Creates a basic card object, we may derive from this class later if needed.
		 * @param	_name 		The formal title of the card to be loaded
		 */
		public function Card(_name:String) {
			cardName = _name;
			horizontal = false; //all start out this way
			faceUp = false; //start face down
			
			//get card info from xml
			var xmlData:XMLList = library.Card.(@title == cardName);
			
			if (xmlData.length() != 1) {
				throw new Error("Could not find card name OR more than one card name was found (check library.xml)");
			}
			
			//graphics
			var cardX:int = int(xmlData.GFXPosition.x) - 1;
			var cardY:int = int(xmlData.GFXPosition.y) - 1;
			cardX *= 48; //width of card
			cardY *= 67; //height of card
			var sourceRect:Rectangle = new Rectangle(cardX, cardY, 48, 67);
			
			cardBitmapData = new BitmapData(48, 67);
			cardBitmapData.copyPixels(spriteSheet.bitmapData, sourceRect, new Point(0, 0));
			
			cardGfx = new Bitmap(cardBack.clone());
			//center the x and y of the bitmap on the container for easy rotation and flipping.
			cardGfx.x -= cardGfx.width / 2;
			cardGfx.y -= cardGfx.height / 2;
			addChild(cardGfx);
			
			//Filling the attributes from the XML
			description = String(xmlData.description);
			
			
			//Initialize the tooltip
			showingTooltip = false;
			toolTip = ToolTip.createToolTip(this.parent, new Global.Arial(), 0x000000, 0.8, ToolTip.ROUND_TIP, 0xFFFFFFFF, 10);
			addEventListener(MouseEvent.MOUSE_OVER, showToolTip);
			addEventListener(MouseEvent.MOUSE_OUT, hideToolTip);
			
			
			//testing flip/rotate function
			addEventListener(MouseEvent.CLICK, rotate);
			
		}
		
		/**
		 * Switches the bitmapdata of the card face with the bitmapdata of the card back.
		 * @param	e MouseEvent object for testing purposes, can remove this later
		 */
		public function flip(e:MouseEvent = null):void {
			trace("flipping");
			Tweener.addTween(this, { scaleX: 0, time: 0.1, onComplete: switchGFX, transition: "linear" } );
			Tweener.addTween(this, { scaleX: 1, time: 0.1, delay: 0.15, transition: "linear" } );
		}
		
		//Helper for flip function.
		private function switchGFX():void {
			//Here we swap the bitmap graphics mid-tween so it seems like a seamless transition.
			trace(faceUp);
			cardGfx.bitmapData.lock();
			if (faceUp) {
				cardGfx.bitmapData.copyPixels(cardBack, new Rectangle(0, 0, 48, 67), new Point(0, 0));
			} else {
				cardGfx.bitmapData.copyPixels(cardBitmapData, new Rectangle(0, 0, 48, 67), new Point(0, 0));
			}
			cardGfx.bitmapData.unlock();
			
			faceUp = !faceUp;
		}
		
		/**
		 * Rotates the card from the horizontal position to the vertical position.
		 * @param	e MouseEvent object for testing purposes, can be removed later
		 */
		public function rotate(e:MouseEvent = null):void {
			var targetRotation:int;
			
			(horizontal) ? targetRotation = 0 : targetRotation = 90;
			
			Tweener.addTween(this, { rotation: targetRotation, time:0.2 } );
			horizontal = !horizontal;
		}
		
		public function showToolTip(e:MouseEvent):void {
			
			if (!Tweener.isTweening(this) && faceUp && !showingTooltip) {
				toolTip.addTip(description);
				showingTooltip = true;
			}
		}
		
		public function hideToolTip(e:MouseEvent):void {
			
			if (showingTooltip) {
				toolTip.removeTip();
				showingTooltip = false;
			}
		}
		
		public function playCard():void {
			//stub to override?
			//or maybe this function belongs in the Player class
		}
	}
}