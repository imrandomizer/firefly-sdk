package
{
	import com.firefly.core.assets.LocalizationBundle;
	import com.firefly.core.components.GameApp;
	import com.in4ray.particle.journey.components.CompanySplash;
	import com.in4ray.particle.journey.locale.GameLocalizationBundle;
	import com.in4ray.particle.journey.screens.MainScreen;
	
	import flash.desktop.NativeApplication;
	import flash.events.Event;
	
	import starling.core.Starling;
	import starling.utils.VAlign;
	
	
	public class ParticleJourney extends GameApp
	{
		private var starling:Starling;
		
		public function ParticleJourney()
		{
			super(CompanySplash);
			
			setGlobalLayoutContext(768, 1360, VAlign.TOP);
			
			regNavigator(MainScreen);
			
			new GameLocalizationBundle().load().then(function ():void
			{
				trace();
			});
		}
		
		override protected function init():void
		{
			super.init();
			
			Starling.current.showStats = true;
			
			NativeApplication.nativeApplication.addEventListener(flash.events.Event.ACTIVATE, activate);
			NativeApplication.nativeApplication.addEventListener(flash.events.Event.DEACTIVATE, deactivate);
		}
		
		private function activate(evetn:flash.events.Event):void
		{
			stage.frameRate = 30;
		}
		
		private function deactivate(evetn:flash.events.Event):void
		{
			stage.frameRate = 1;
		}
	}
}