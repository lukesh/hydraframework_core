/*
   HydraFramework - Copyright (c) 2009 andCulture, Inc. Some rights reserved.
   Your reuse is governed by the Creative Commons Attribution 3.0 United States License
 */
package com.hydraframework.core {
	import com.hydraframework.core.mvc.interfaces.IFacade;
	import mx.core.Application;

	public class HydraApplication extends Application {
		public var facade:IFacade;

		public function HydraApplication() {
			super();
		}
	}
}