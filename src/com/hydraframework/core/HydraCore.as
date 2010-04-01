/*
   HydraFramework - Copyright (c) 2010 andCulture, Inc. Some rights reserved.
   Your reuse is governed by the MIT License (http://www.opensource.org/licenses/mit-license.php)
 */
package com.hydraframework.core {
	import com.hydraframework.core.mvc.interfaces.IFacade;
	
	import flash.events.EventDispatcher;
	
	import mx.core.IUIComponent;
	import mx.events.FlexEvent;

	public class HydraCore extends EventDispatcher {
		public var component : IUIComponent;
		public var facadeClass : Class;
		public var facade : IFacade;
		public var eventMap : HydraEventMap;
		
		public function HydraCore(component : IUIComponent, facadeClass : Class, eventMap : HydraEventMap = null) {
			this.component = component;
			this.facadeClass = facadeClass;
			this.eventMap = eventMap ? eventMap.clone() : HydraFramework.defaultEventMap.clone();
			this.eventMap.registerInitializeFacadeEvents(component, handleInitialize);
		}

		private function handleInitialize(event : FlexEvent) : void {
			this.facade = new facadeClass(component, eventMap);
		}
	}
}