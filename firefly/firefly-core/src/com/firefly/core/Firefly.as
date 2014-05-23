// =================================================================================================
//
//	Firefly Framework
//	Copyright 2013 in4ray. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package com.firefly.core
{
	import com.firefly.core.async.Completer;
	import com.firefly.core.async.Future;
	import com.firefly.core.audio.AudioMixer;
	import com.firefly.core.consts.SystemType;
	import com.firefly.core.layouts.helpers.LayoutContext;
	import com.firefly.core.utils.Log;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.system.Capabilities;
	import flash.utils.getTimer;
	
	import starling.animation.Juggler;
	import starling.utils.HAlign;
	import starling.utils.VAlign;
	
	use namespace firefly_internal;
	
	/** Firefly core class with configurations. */
	public class Firefly
	{
		/** Maximum texture size needed for calculation of content scale. */
		private static const MAX_TEXTURE_SIZE:Number = 4096;
		private static var _current:Firefly;
		
		private var _main:Sprite;
		private var _stageWidth:Number;
		private var _stageHeight:Number;
		private var _defaultFrameRate:Number;
		private var _textureScale:Number;
		private var _contentScale:Number;
		private var _layoutContext:LayoutContext;
		private var _audioMixer:AudioMixer;
		private var _completer:Completer;
		private var _systemType:String;
		private var _dpi:Number;
		private var _initialzed:Boolean;
		
		private var _juggler:Juggler;
		
		/** Constructor.
		 *  @param main Application entry point. */
		public function Firefly(main:Sprite)
		{
			_main = main;
			_current = this;
			_defaultFrameRate = _main.stage.frameRate;
			
			// define operating system
			if (Capabilities.version.indexOf('IOS') > -1)
				_systemType = SystemType.IOS;
			else if (Capabilities.version.indexOf('AND') > -1)
				_systemType = SystemType.ANDROID;
			else if(Capabilities.playerType == "Desktop")
				_systemType = SystemType.DESKTOP;
			else
				_systemType = SystemType.WEB;
			// define dpi
			var serverString:String = unescape(Capabilities.serverString);
			_dpi = Number(serverString.split("&DP=", 2)[1]);
			
			_main.stage.addEventListener(flash.events.Event.RESIZE, onResize);
		}
		
		/** Version of Firefly SDK. */
		public static function get version():String { return "1.1"; }
		
		/** Current instance of Firefly class. */
		public static function get current():Firefly { return _current; }
		
		/** Application entry point. */
		public function get main():Sprite { return _main; }
		
		/** Width of the stage. */
		public function get stageWidth():Number { return _stageWidth; }
		
		/** Height of the stage. */
		public function get stageHeight():Number { return _stageHeight; }
		
		/** Scale factor of content. */
		public function get contentScale():Number { return _contentScale; }
		
		/** Scale factor of textures. */
		public function get textureScale():Number { return _textureScale; }
		
		/** Layout context of the the application. */
		public function get layoutContext():LayoutContext { return _layoutContext; }
		
		/** Type of operating system on which runs application. */
		public function get systemType():String { return _systemType; }
		
		/** DPI of device. */
		public function get dpi():Number { return _dpi; }
		
		/** Audio mixer which manages all registered music and sounds. */
		public function get audioMixer():AudioMixer { return _audioMixer; }
		
		/** Status of Firefly initialization. */
		public function get initialized():Boolean { return _initialzed; }
		
		/** Firefly global juggler. */
		public function get juggler():Juggler { return _juggler; }
		
		/** Start initialization of Firefly.
		 *  @return Future object for callback. */
		public function start():Future
		{
			_completer = new Completer();
			
			var time:uint = getTimer();
			if (time >= 1000)
				Future.nextFrame().then(timerComplete);
			else
				Future.delay((1000 - time)/1000).then(timerComplete);
			
			return _completer.future;
		}
		
		/** init juggler and add it into parent if specified 
		 *  @param parentJuggler Parent juggler object (e.g. Starling.juggler) */
		public function initJuggler(parentJuggler:Juggler=null):void
		{
			_juggler = new Juggler();
			
			if(parentJuggler)
				parentJuggler.add(_juggler);
		}
		
		/** Set global layout of the application.
		 *  @param designWidth Design width of the application.
		 *  @param designHeight Design height of the application.
		 *  @param vAlign Vertical align of layout.
		 *  @param hAlign Horizontal align of layout. */		
		public function setLayoutContext(designWidth:Number, designHeight:Number, vAlign:String = VAlign.CENTER, hAlign:String = HAlign.CENTER):void
		{
			_layoutContext = LayoutContext.withDesignSize(designWidth, designHeight, vAlign, hAlign);
		}
		
		/** @private */
		private function timerComplete():void
		{
			updateSize(_main.stage.stageWidth, _main.stage.stageHeight);
			
			_audioMixer = new AudioMixer();
			_initialzed = true;
			
			_completer.complete();
		}

		/** @private */
		private function onResize(event:Event):void
		{
			updateSize(_main.stage.stageWidth, _main.stage.stageHeight);
		}
		
		/** @private 
		 *  @param stage Instance of stage.*/
		firefly_internal function updateSize(stageWidth:Number, stageHeight:Number):void
		{
			CONFIG::debug {
				if(!layoutContext)
					Log.error("Layout Context is not set. Use setGlobalLayoutContext() function to set game app design size.");
			};
			// calculate stage width/height, content and texture scales
			_stageWidth = stageWidth;
			_stageHeight = stageHeight;
			_contentScale = 1 / Math.max(1, Math.max(stageWidth / layoutContext.designWidth, stageHeight / layoutContext.designHeight));
			_textureScale= Math.min(1 ,Math.max(stageWidth / layoutContext.designWidth, stageHeight / layoutContext.designHeight));
		}
	}
}