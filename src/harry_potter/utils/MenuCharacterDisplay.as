package harry_potter.utils 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.Font;
	import harry_potter.assets.Global;
	import fano.utils.ToolTip;
	
	/**
	 * Simple class to display the starting character to the player based on the main menu
	 */
	public class MenuCharacterDisplay extends Sprite {
		
		//constant to switch to the cardback image
		public static const CARDBACK:int = 10;
		
		//descriptions for the various characters, to be used with our tooltip class
		private static const CREATURES_DESCRIPTION:String = "Ron, Youngest Brother\nIf you have no cards in your hand, you may use an action to draw 5 cards.";
		private static const CHARMS_DESCRIPTION:String = "The Famous Harry Potter\nBefore each of your turns, if there are 4 or fewer cards in your hand, you may draw a card.";
		private static const TRANSFIGURATION_DESCRIPTION:String = "Hermione Granger\nIf you already have 2 or more lessons in play, then whenever you use an Action to play a lesson card, you may play 2 lesson cards instead of 1.";
		private static const POTIONS_DESCRIPTION:String = "Draco Malfoy, Slytherin\nOnce during each of your turns, when you use an Action to play an Item card, you get 1 more Action that turn.";
		private static const QUIDDITCH_DESCRIPTION:String = "Oliver Wood\nOnce per game, when 1 of your spell cards that needs Quidditch power does damage, you may have it do 8 more damage.";
		
		private var toolTip:ToolTip;
		
		private var gfxBitmap:Bitmap;
		private var gfxBMD:BitmapData;
		private var blitRect:Rectangle;
		private var description:String;
		
		private var _parent:Sprite;
		
		public function MenuCharacterDisplay(_parent:Sprite) {
			toolTip = ToolTip.createToolTip(_parent, new Global.Arial(), 0x000000, 0.8, ToolTip.ROUND_TIP, 0xFFFFFFFF, 10);
			addEventListener(MouseEvent.ROLL_OVER, showToolTip);
			addEventListener(MouseEvent.ROLL_OUT, hideToolTip);
			
			//instantiate our embeded graphics into a bitmapdata object
			gfxBMD = new Global.StartingChars().bitmapData;
			
			//instantiate our rectangle
			blitRect = new Rectangle(0, 0, 67, 48);
			
			//add our bitmap to the sprite with a blank BMD
			gfxBitmap = new Bitmap(new BitmapData(67, 48));
			addChild(gfxBitmap);
			
			//call our switch function to copy the correct pixels onto the image
			switchChar(CARDBACK);
		}
		
		/**
		 * Switches the graphic for the main character based on the parameter.
		 * @param	lessonType Accepted values are LessonTypes constants or MenuCharacterDisplay.CARDBACK for the cardback image.
		 */
		public function switchChar(lessonType:int):void {
			
			//adjust the blitRect x and y properties based on which lesson is selected
			switch(lessonType) {
				case LessonTypes.CARE_OF_MAGICAL_CREATURES:
					description = CREATURES_DESCRIPTION;
					blitRect.x = 136;
					blitRect.y = 0;
					break;
				case LessonTypes.CHARMS:
					description = CHARMS_DESCRIPTION;
					blitRect.x = 68;
					blitRect.y = 0;
					break;
				case LessonTypes.TRANSFIGURATION:
					description = TRANSFIGURATION_DESCRIPTION;
					blitRect.x = 136;
					blitRect.y = 49;
					break;
				case LessonTypes.POTIONS:
					description = POTIONS_DESCRIPTION;
					blitRect.x = 0;
					blitRect.y = 49;
					break;
				case LessonTypes.QUIDDITCH:
					description = QUIDDITCH_DESCRIPTION;
					blitRect.x = 68;
					blitRect.y = 49;
					break;
				case CARDBACK:
					description = "";
					blitRect.x = 0;
					blitRect.y = 0;
					break;
				default:
					trace("invalid parameter to MenuCharacterDisplay");
					return;
			}
			
			//copy the appropriate pixels to the image
			gfxBitmap.bitmapData.lock();
			gfxBitmap.bitmapData.copyPixels(gfxBMD, blitRect, new Point());
			gfxBitmap.bitmapData.unlock();
		}
		
		public function showToolTip(e:MouseEvent):void {
			
			if (description != "") {
				toolTip.addTip(description);
			}
		}
		
		public function hideToolTip(e:MouseEvent):void {
			
			if (description != "") {
				toolTip.removeTip();
			}
		}
	}
}