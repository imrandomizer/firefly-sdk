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
	
	use namespace starling_internal;
	
	/** The base class for animations based on tween.
	 * 
	 *  @see com.firefly.core.effects.Fade
	 *  @see com.firefly.core.effects.Rotate
	 *  @see com.firefly.core.effects.Scale
	 *  @see com.firefly.core.effects.easing.Linear
	 *  @see com.firefly.core.effects.easing.Back
	 *  @see com.firefly.core.effects.easing.Bounce
	 *  @see com.firefly.core.effects.easing.Circular
	 *  @see com.firefly.core.effects.easing.Elastic
	 *  @see com.firefly.core.effects.easing.Power
	 *  @see com.firefly.core.effects.easing.Sine
	 *  @see com.firefly.core.effects.easing.StarlingEaser */
	public class Animation implements IAnimation
	{
		private var _juggler:Juggler;
		private var _target:Object;
		private var _duration:Number;
		private var _repeatCount:int;
		private var _repeatDelay:Number;
		private var _isPlaying:Boolean;
		private var _isPause:Boolean;
		private var _delay:Number;
		private var _easer:IEaser;
		private var _completer:Completer;
		private var _progress:Progress
		private var _tween:Tween;
		
		/** Constructor.
		 *  @param target Target of the animation.
		 *  @param duration Duration in seconds. */
		public function Animation(target:Object, duration:Number=NaN)
		{
			_target = target;
			_duration = duration;
			
			_repeatCount = 1;
			_repeatDelay = 0;
			_completer = new Completer();
			_easer = new Linear();
		}
		
		/** @inheritDoc */
		public function get isDefaultJuggler():Boolean { return _juggler == null; }
		/** @inheritDoc */
		public function get isPlaying():Boolean { return _isPlaying; }
		/** @inheritDoc */
		public function get isPause():Boolean { return _isPause; }
		
		/** @inheritDoc */
		public function get target():Object { return _target; }
		public function set target(value:Object):void { _target = value; }
		
		/** The animation duration in seconds.
		 *  @default NaN */
		public function get duration():Number { return _duration; }
		public function set duration(value:Number):void { _duration = value; }
		
		/** The delay before starting the animation in seconds.
		 *  @default NaN */
		public function get delay():Number { return _delay; }
		public function set delay(value:Number):void { _delay = value; }
		
		/** The number of times the animation will be executed.
		 *  In case if the value is <code>0</code> the animation will be looped.
		 *  @default 1 */
		public function get repeatCount():int { return _repeatCount; }
		public function set repeatCount(value:int):void { _repeatCount = value; }
		
		/** The delay between repeat of the animation in seconds.
		 *  @default 0 */
		public function get repeatDelay():Number { return _repeatDelay; }
		public function set repeatDelay(value:Number):void { _repeatDelay = value; }
		
		/** @inheritDoc */
		public function get juggler():Juggler { return _juggler ? _juggler : Starling.juggler; }
		public function set juggler(value:Juggler):void { _juggler = value; }
		
		/** The easer modification of the animation.
		 *  @default Linear */
		public function get easer():IEaser { return _easer; }
		public function set easer(value:IEaser):void { _easer = value; }
		
		/** @inheritDoc */
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
		
		/** @inheritDoc */
		public function pause():void
		{
			if(_isPlaying)
			{
				juggler.remove(_tween);
				_isPlaying = false;
				_isPause = true;
			}
		}
		
		/** @inheritDoc */
		public function resume():void
		{
			if (_isPause)
			{
				juggler.add(_tween);
				_isPlaying = true;
				_isPause = true;
			}
		}
		
		/** @inheritDoc */
		public function stop():void
		{
			if(_isPlaying || _isPause)
			{
				juggler.remove(_tween);
				Tween.toPool(_tween);
				_progress = null;
				_tween = null;
				_isPlaying = _isPause = false;
			}
		}
		
		/** @inheritDoc */
		public function end():void
		{
			if(_isPlaying || _isPause)
				stop();
			
			_completer.complete();
		}
		
		/** @inheritDoc */
		public function dispose():void
		{
			stop();
			
			_target = null;
			_juggler = null;
			_easer = null;
			_progress = null;
			_completer = null;
		}
		
		/** Create the help instance of <code>Tween</code> class for animation. */
		protected function createTween():Tween
		{
			var tween:Tween = Tween.fromPool(target, isNaN(duration) ? 1 : duration);
			tween.transitionFunc = _easer.ease;
			tween.onComplete = onComplete;
			tween.onUpdate = onUpdate;
			tween.repeatDelay = _repeatDelay;
			tween.repeatCount = _repeatCount;
			if (!isNaN(_delay))
				tween.delay = _delay;
			
			return tween;
		}
		
		/** @private */
		private function onUpdate():void
		{
			_progress.current = _tween.currentTime;
			_progress.total = _tween.totalTime;
			_completer.sendProgress(_progress);
		}
		
		/** @private */
		private function onComplete():void
		{
			stop();
			
			_completer.complete();
		}
	}
}