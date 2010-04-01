/*
   HydraFramework - Copyright (c) 2010 andCulture, Inc. Some rights reserved.
   Your reuse is governed by the MIT License (http://www.opensource.org/licenses/mit-license.php)
 */
package com.hydraframework.core.mvc.events {

	/**
	 * @see	Notification.phase
	 */
	public class Phase {
		public static const REQUEST : String = "Phase.request";
		public static const RESPONSE : String = "Phase.response";
		public static const COMPLETE : String = "Phase.complete";
		public static const CANCEL : String = "Phase.cancel";
	}
}