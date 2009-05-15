/*
   HydraFramework - Copyright (c) 2009 andCulture, Inc. Some rights reserved.
   Your reuse is governed by the Creative Commons Attribution 3.0 United States License
 */
package com.hydraframework.core {
	import flash.events.EventDispatcher;
	import mx.events.FlexEvent;

	public class HydraFramework extends EventDispatcher {
		/**
		 * @private
		 * Instance of the HydraFramework.
		 */
		private static const _instance:HydraFramework = new HydraFramework();

		/**
		 * Returns instance of the HydraFramework.
		 */
		public static function getInstance():HydraFramework {
			return _instance;
		}
		private var application:HydraApplication;
		private var mainFacade:Class;

		public function HydraFramework() {
		}

		public static function initialize(application:HydraApplication, mainFacade:Class):void {
			HydraFramework.getInstance().application = application;
			HydraFramework.getInstance().mainFacade = mainFacade;
			application.addEventListener(FlexEvent.INITIALIZE, HydraFramework.getInstance().handleInitialize);
			application.addEventListener(FlexEvent.CREATION_COMPLETE, HydraFramework.getInstance().handleCreationComplete);
		}

		private function handleInitialize(event:FlexEvent):void {
			application.facade = new mainFacade(application);
		}

		private function handleCreationComplete(event:FlexEvent):void {
		}
	}
}