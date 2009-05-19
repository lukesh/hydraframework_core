/*
   HydraFramework - Copyright (c) 2009 andCulture, Inc. Some rights reserved.
   Your reuse is governed by the Creative Commons Attribution 3.0 United States License
 */
package com.hydraframework.core {
	import flash.events.EventDispatcher;
	import mx.core.IUIComponent;

	public class HydraFramework extends EventDispatcher {
		public function HydraFramework() {
		}

		public static function initialize(component:IUIComponent, facadeClass:Class):void {
			new HydraCore(component, facadeClass);
		}
	}
}