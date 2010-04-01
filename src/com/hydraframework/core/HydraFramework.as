/*
   HydraFramework - Copyright (c) 2010 andCulture, Inc. Some rights reserved.
   Your reuse is governed by the MIT License (http://www.opensource.org/licenses/mit-license.php)
 */
package com.hydraframework.core {
	import flash.events.EventDispatcher;
	
	import mx.core.IUIComponent;

	public class HydraFramework extends EventDispatcher {

		public static const VERSION : String = "2.0.0";

		public static const DEBUG_SHOW_WARNINGS : uint = 1;
		public static const DEBUG_SHOW_INFO : uint = 2;
		public static const DEBUG_SHOW_INTERNALS : uint = 4;

		public static var debugLevel : uint = DEBUG_SHOW_WARNINGS | DEBUG_SHOW_INFO;

		public static var defaultEventMap : HydraEventMap; 
		
		public function HydraFramework() {
			defaultEventMap = new HydraEventMap(["initialize"], ["creationComplete", "add"], ["remove"]);
		}

		public static function initialize(component : IUIComponent, facadeClass : Class, eventMap : HydraEventMap = null) : HydraCore {
			return new HydraCore(component, facadeClass, eventMap);
		}

		public static function log(level : uint, ... args) : void {
			if (debugLevel & level) {
				trace(args.join(" "));
			}
		}
	}
}