/*
   HydraFramework - Copyright (c) 2009 andCulture, Inc. Some rights reserved.
   Your reuse is governed by the MIT License (http://www.opensource.org/licenses/mit-license.php)
 */
package com.hydraframework.core {
	import flash.events.EventDispatcher;
	
	import mx.core.IUIComponent;

	public class HydraFramework extends EventDispatcher {
		
		public static const VERSION : String = "1.5.0";
		
		public static const DEBUG_SHOW_WARNINGS : uint = 1;
		public static const DEBUG_SHOW_INFO : uint = 2;
		public static const DEBUG_SHOW_INTERNALS : uint = 4;
		
		public static var debugLevel : uint = DEBUG_SHOW_WARNINGS | DEBUG_SHOW_INFO;
		
		public function HydraFramework() {
		}

		public static function initialize(component:IUIComponent, facadeClass:Class):HydraCore {
			return new HydraCore(component, facadeClass);
		}
		
		public static function log(level : uint, ...args):void {
			if (debugLevel & level) {
				trace(args.join(" "));
			}
		}
	}
}