// =================================================================================================
//
//	Firefly Framework
//	Copyright 2013 in4ray. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package com.firefly.core.components
{
	import com.firefly.core.firefly_internal;
	import com.firefly.core.components.helpers.LocalizationField;
	import com.firefly.core.display.ILocalizedComponent;
	
	import starling.events.Event;
	import starling.text.TextField;
	
	use namespace firefly_internal;
	
	/** Starling text field component with capability of localization. */
	public class TextField extends starling.text.TextField implements ILocalizedComponent
	{
		/** @private */
		private var _localizationField:LocalizationField;
		
		/** Constructor. 
		 *  @param localeField Locale field with localized text.
		 *  @param fontName Font name.
		 *  @param fontSize Font size.
		 *  @param color Color of the text.
		 *  @param bold Font weight. */		
		public function TextField(localizationField:LocalizationField, fontName:String="Verdana", fontSize:Number=12, color:uint=0, bold:Boolean=false)
		{
			super(1, 1, "", fontName, fontSize, color, bold);
			
			_localizationField = localizationField;
			
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
		}
		
		/** Locale field with localized text. */	
		public function get localeField():LocalizationField { return _localizationField; }
		
		/** Invokes to localize text in the component.
		 *  @param text Localized string. */
		public function localize(text:String):void
		{ 
			this.text = text; 
		}
		
		/** @inheritDoc */		
		override public function dispose():void
		{
			_localizationField.unlink(this);
			_localizationField = null;
			
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			
			super.dispose();
		}
		
		/** @private */
		private function onAddedToStage(e:Event):void
		{
			_localizationField.link(this);
		}
		
		/** @private */
		private function onRemovedFromStage(e:Event):void
		{
			_localizationField.unlink(this);
		}
	}
}