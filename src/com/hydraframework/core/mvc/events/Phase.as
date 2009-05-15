/*
   HydraFramework - Copyright (c) 2009 andCulture, Inc. Some rights reserved.
   Your reuse is governed by the Creative Commons Attribution 3.0 United States License
 */
package com.hydraframework.core.mvc.events {

	/**
	 * @see	Notification.phase
	 */
	public class Phase {
		public static const REQUEST:String = "Phase.request";
		public static const RESPONSE:String = "Phase.response";
		public static const COMPLETE:String = "Phase.complete";
		public static const CANCEL:String = "Phase.cancel";
	}
}