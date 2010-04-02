/*
   HydraFramework - Copyright (c) 2010 andCulture, Inc. Some rights reserved.
   Your reuse is governed by the MIT License (http://www.opensource.org/licenses/mit-license.php)
 */
package com.hydraframework.core {
	import com.hydraframework.core.mvc.interfaces.IFacade;

	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.describeType;
	import flash.xml.XMLNode;

	public class HydraCore extends EventDispatcher {
		public var component : IEventDispatcher;
		public var facadeClass : Class;
		public var facade : IFacade;
		public var eventMap : HydraEventMap;

		public function HydraCore(component : IEventDispatcher, facadeClass : Class, eventMap : HydraEventMap = null) {
			this.component = component;
			this.facadeClass = facadeClass;
			this.eventMap = eventMap ? eventMap.clone() : HydraFramework.defaultEventMap.clone();
			this.eventMap.registerInitializeFacadeEvents(component, handleInitialize);
			HydraFramework.log(HydraFramework.DEBUG_SHOW_INFO, "<HydraFramework> HydraCore created for component:", component, "facadeClass:", facadeClass, "eventMap:", eventMap);
		}

		private function handleInitialize(event : Event) : void {
			var o : XML = describeType(facadeClass);
			var params : Array = [];
			for each (var p : XML in o..constructor.parameter) {
				params.push(p);
			}
			this.facade = (function() : IFacade {
					if (params.length == 0) {
						HydraFramework.log(HydraFramework.DEBUG_SHOW_INFO, "<HydraFramework> HydraCore initializing Facade with no arguments. Component will be null; Facade must be manually initialized(). Name will be null unless assigned as a const, use interface or classreference to retrieve. EventMap will be default.");
						return IFacade(new facadeClass());
					} else if (params.length == 1) {
						if (params[0].@type != "String") {
							HydraFramework.log(HydraFramework.DEBUG_SHOW_INFO, "<HydraFramework> HydraCore initializing Facade with one argument. Component is assigned; Facade will attempt to automatically initialize based on eventMap. Name will be null unless assigned as a const, use interface or classreference to retrieve. EventMap will be default.");
							return IFacade(new facadeClass(component));
						}
					} else if (params.length == 2) {
						if (params[0].@type != "String" && params[1].@type == "com.hydraframework.core::HydraEventMap") {
							HydraFramework.log(HydraFramework.DEBUG_SHOW_INFO, "<HydraFramework> HydraCore initializing Facade with two arguments. Component is assigned; Facade will attempt to automatically initialize based on eventMap. Name will be null unless assigned as a const, use interface or classreference to retrieve. EventMap has been assigned:", eventMap);
							return IFacade(new facadeClass(component, eventMap));
						}
					}
					throw new Error("<HydraFramework> Cannot initialize HydraCore, unrecognized Facade signature.");
					return null;
				})();
		}
	}
}