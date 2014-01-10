package views
{
	import com.in4ray.gaming.analytics.IAnalytics;
	import com.in4ray.gaming.components.Button;
	import com.in4ray.gaming.components.Quad;
	import com.in4ray.gaming.components.Sprite;
	import com.in4ray.gaming.core.SingletonLocator;
	import com.in4ray.gaming.events.BindingEvent;
	import com.in4ray.gaming.events.ViewStateEvent;
	import com.in4ray.gaming.layouts.$bottom;
	import com.in4ray.gaming.layouts.$height;
	import com.in4ray.gaming.layouts.$right;
	import com.in4ray.gaming.layouts.$width;
	
	import consts.ViewStates;
	
	import model.GameModel;
	
	import sounds.SoundBundle;
	
	import starling.events.Event;
	
	import textures.CommonTextures;
	
	
	/**
	 * Game view.
	 */	
	public class GameView extends Sprite
	{
		private var commonTextureBundle:CommonTextures;
		private var gameModel:GameModel;
		private var analytics:IAnalytics;
		
		/**
		 * Constructor.
		 */		
		public function GameView()
		{
			super();
			
			analytics = SingletonLocator.getInstance(IAnalytics);
			
			gameModel = GameModel.getInstance();
			gameModel.pause.bindListener(pauseHandler);
			
			// Get reference on game Textures
			commonTextureBundle = new CommonTextures();
			
			var quad:Quad = new Quad(0xffffff);
			addElement(quad, $width(100).pct, $height(100).pct);
			
			// Game Pause
			var pauseBtn:Button = new Button(commonTextureBundle.pauseUpButton, "", commonTextureBundle.pauseDownButton, new SoundBundle().click);
			pauseBtn.addEventListener(Event.TRIGGERED, pauseMenuHandler);
			addElement(pauseBtn, $right(20).rcpx, $bottom(20).rcpx);
		}
		
		private function pauseMenuHandler(e:Event):void
		{
			analytics.log("Game", "Pause");
			dispatchEvent(new ViewStateEvent(ViewStateEvent.OPEN_POPUP, ViewStates.PAUSE));
		}
		
		private function pauseHandler(e:BindingEvent):void
		{
			
		}
	}
}