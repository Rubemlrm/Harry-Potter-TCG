package harry_potter.utils 
{
	import com.bit101.components.TextArea;
	import flash.display.Sprite;
	import flash.display.DisplayObjectContainer;
	import com.bit101.components.Window;
	import flash.events.KeyboardEvent;
	
	/**
	 * A console that can be toggled on and off, used to keep track of events that happen in game
	 * @author Stefano Fiumara
	 */
	public class Console extends Sprite 
	{
		private var window:Window;
		private var consoleText:TextArea;
		private var parentSprite:DisplayObjectContainer; //keep a reference to the parent object
		private var showing:Boolean; //if we are currently showing the console
		/**
		 * Creates the console object
		 * @param   _parent The parent display object that will contain the console
		 * @param	x The X coordinate of this object, default is 0
		 * @param	y The Y coordinate of this object, default is 0
		 * @param	_visible Whether or not this object should be visible when it is first initialized, default is false.
		 */
		public function Console(_parent:DisplayObjectContainer=null, _x:int = 0, _y:int = 0, _visible:Boolean = false) {
			window = new Window(this, _x, _y, "Console");
			consoleText = new TextArea(window);
			window.setSize(300, 200);
			consoleText.setSize(300, 180);
			consoleText.editable = false;
			parentSprite = _parent;
			showing = _visible;
		}
		
		/**
		 * Prints the specified string to the console
		 */
		public function print(_text:String):void {
			consoleText.text += '\n' + _text;
		}
		
		/**
		 * Toggles the visibility of the console
		 */
		public function toggle(e:KeyboardEvent = null):void {
			if(e.keyCode == 192) {
				if (showing) {
					parentSprite.removeChild(this);
				} else {
					parentSprite.addChild(this);
				}
				
				showing = !showing;
			}
		}
		
		public function clear():void {
			consoleText.text = "";
		}
	}

}