/*
   HydraFramework - Copyright (c) 2009 andCulture, Inc. Some rights reserved.
   Your reuse is governed by the Creative Commons Attribution 3.0 United States License
 */
package com.hydraframework.core.mvc.patterns.proxy {
	import com.hydraframework.core.hydraframework_internal;
	import com.hydraframework.core.mvc.events.Notification;
	import com.hydraframework.core.mvc.interfaces.IProxy;
	import com.hydraframework.core.mvc.patterns.facade.Facade;
	import com.hydraframework.core.mvc.patterns.relay.Relay;
	//import nl.demonsters.debugger.MonsterDebugger;
	
	use namespace hydraframework_internal;
	
	public class Proxy extends Relay implements IProxy {
		public static const REGISTER:String = "Proxy.register";
		public static const REMOVE:String = "Proxy.remove";

		public var data:Object;

		public function Proxy(name:String = null, data:Object = null) {
			super();
			this.setName(name);
			this.data = data;
		}

		/**
		 * Handles Notification type events. Override this method to add logic
		 * for notifications that are sent throughout the MVC triad. Remember
		 * to call super.handleNotification(notification).
		 *
		 * @param	Notification
		 * @return	void
		 */
		override hydraframework_internal function __handleNotification(notification:Notification):void {
			super.__handleNotification(notification);

			switch (notification.name) {
				case Facade.REGISTER:
					this.hydraframework_internal::__initialize();
					break;
				case Facade.REMOVE:
					this.hydraframework_internal::__dispose();
					break;
			}
		}
		
		override hydraframework_internal function __initialize(notificationName:String=null) : void {
			super.__initialize(notificationName || Proxy.REGISTER);
		}
		
		
		override hydraframework_internal function __dispose(notificationName:String=null) : void {
			super.__dispose(notificationName || Proxy.REMOVE);
		}
	}
}