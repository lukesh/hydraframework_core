/*
   HydraFramework - Copyright (c) 2009 andCulture, Inc. Some rights reserved.
   Your reuse is governed by the Creative Commons Attribution 3.0 United States License
 */
package com.hydraframework.core {
	import com.hydraframework.core.mvc.interfaces.IFacade;
	import flash.events.EventDispatcher;
	import mx.core.IUIComponent;
	import mx.events.FlexEvent;

	public class HydraCore extends EventDispatcher {
		public var component:IUIComponent;
		public var facadeClass:Class;
		public var facade:IFacade;

		public function HydraCore(component:IUIComponent, facadeClass:Class) {
			this.component = component;
			this.facadeClass = facadeClass;
			this.component.addEventListener(FlexEvent.INITIALIZE, handleInitialize);
			this.component.addEventListener(FlexEvent.CREATION_COMPLETE, handleCreationComplete);
		}

		private function handleInitialize(event:FlexEvent):void {
			this.facade = new facadeClass(component);
		}

		private function handleCreationComplete(event:FlexEvent):void {
		}
	}
}