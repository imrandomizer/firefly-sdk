// =================================================================================================
//
//	Firefly Framework
//	Copyright 2013 in4ray. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package com.firefly.core.effects
{
	import com.firefly.core.async.Completer;
	import com.firefly.core.async.Future;
	import com.firefly.core.async.helpers.Progress;
	import com.firefly.core.effects.easing.IEaser;
	import com.firefly.core.effects.easing.Linear;
	
	import starling.animation.Juggler;
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.core.starling_internal;
	import starling.display.DisplayObject;
	
	use namespace starling_internal;
	
	public class Animation implements IAnimation
	{
		private var _easier:IEaser = new Linear();
		private var _juggler:Juggler;
		private var _target:Object;
		private var _duration:Number;
		private var _loop:Boolean;
		private var _disposeOnComplete:Boolean;
		private var _tween:Tween;
		private var _isPlaying:Boolean;
		private var _isPause:Boolean;
		private var _completer:Completer;
		private var _progress:Progress
		private var _delay:Number;
		
		public function Animation(target:DisplayObject, duration:Number = 1)
		{
			this.target = target;
			this.duration = duration;
			
			_completer = new Completer();
		}
		
		public function get target():Object { return _target; }
		public function set target(value:Object):void { _target = value; }
		
		public function get duration():Number { return _duration; }
		public function set duration(value:Number):void { _duration = value; }
		
		public function get delay():Number { return _delay; }
		public function set delay(value:Number):void { _delay = value; }
		
		public function get loop():Boolean { return _loop; }
		public function set loop(value:Boolean):void { _loop = value; }
		
		public function get disposeOnComplete():Boolean { return false; }
		public function set disposeOnComplete(value:Boolean):void { _disposeOnComplete = value; }
		
		public function get juggler():Juggler { return _juggler ? _juggler : Starling.juggler; }
		public function set juggler(value:Juggler):void { _juggler = value; }
		
		public function get easier():IEaser { return _easier; }
		public function set easier(value:IEaser):void { _easier = value; }
		
		public function get isPlaying():Boolean { return _isPlaying; }
		public function get isPause():Boolean { return _isPause; }
		public function get isDefaultJuggler():Boolean { return _juggler == null; }
		
		public function play():Future
		{
			if(_isPlaying)
				stop();
			
			_tween = createTween();
			_progress = new Progress(0, _tween.totalTime);
			juggler.add(_tween);
			_isPlaying = true;
			
			return _completer.future;
		}
		
		public function pause():void
		{
			if(_isPlaying)
			{
				juggler.remove(_tween);
				_isPlaying = false;
				_isPause = true;
			}
		}
		
		public function resume():void
		{
			if (_isPause)
			{
				juggler.add(_tween);
				_isPlaying = true;
				_isPause = true;
			}
		}
		
		public function stop():void
		{
			if(_isPlaying)
			{
				juggler.remove(_tween);
				Tween.toPool(_tween);
				_progress = null;
				_tween = null;
				_isPlaying = false;
				_isPause = false;
			}
		}
		
		public function end():void
		{
			if(_isPlaying)
				stop();
			
			_completer.complete();
		}
		
		public function dispose():void
		{
			stop();
			_target = null;
			_juggler = null;
			_completer = null;
		}
		
		protected function createTween():Tween
		{
			var tween:Tween = Tween.fromPool(target, duration);
			tween.transitionFunc = _easier.ease;
			tween.onComplete = onComplete;
			tween.onUpdate = onUpdate;
			if(!isNaN(delay)) 
				tween.delay = delay;
			
			return tween;
		}
		
		protected function onUpdate():void
		{
			_progress.current = _tween.currentTime;
			_progress.total = _tween.totalTime;
			_completer.sendProgress(_progress);
		}
		
		protected function onComplete():void
		{
			if(_loop)
			{
				play();
			}
			else 
			{
				juggler.remove(_tween);
				Tween.toPool(_tween);
				_progress = null;
				_tween = null;
				_isPlaying = false;
				_isPause = false;
				_completer.complete();
				
				if(_disposeOnComplete)
					dispose();
			}
		}
	}
}