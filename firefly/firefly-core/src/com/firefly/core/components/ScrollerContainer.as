package com.firefly.core.components
{
	import com.firefly.core.firefly_internal;
	import com.firefly.core.display.IViewport;
	
	import starling.textures.Texture;
	
	use namespace firefly_internal;

	public class ScrollerContainer extends ScrollerContainerBase
	{
		private var _viewport:IViewport;
		
		public function ScrollerContainer(hThumbTexture:Texture=null, vThumbTexture:Texture=null)
		{
			super(hThumbTexture, vThumbTexture);
		}
		
		public function get viewport():IViewport { return _viewport; }
		
		public function setViewport(viewport:IViewport, ...layouts):void
		{
			if (_viewport)
			{
				viewports.splice(viewports.indexOf(_viewport), 1);
				layout.removeElement(_viewport);
			}
			
			_viewport = viewport;
			
			viewports.push(viewport);
			layout.addElement.apply(null, [_viewport].concat(layouts));
			
			layoutScrollBars();
		}

		public function addElement(child:Object, ...layouts):void
		{
			_viewport.layout.addElement.apply(null, [child].concat(layouts));
		}
		
		public function addElementAt(child:Object, index:int, ...layouts):void
		{
			_viewport.layout.addElementAt.apply(null, [child, index].concat(layouts));
		}
		
		public function removeElement(child:Object, dispose:Boolean=false):void
		{
			_viewport.layout.removeElement(child, dispose);
		}
		
		public function removeElementAt(index:int, dispose:Boolean=false):void
		{
			_viewport.layout.removeElementAt(index, dispose);
		}
	}
}