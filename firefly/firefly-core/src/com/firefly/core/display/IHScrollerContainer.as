package com.firefly.core.display
{
	import com.firefly.core.controllers.HScrollerCtrl;

	public interface IHScrollerContainer extends IScroller
	{
		function get width():Number;
		function get hScrollerCtrl():HScrollerCtrl;
	}
}