/*
   HydraFramework - Copyright (c) 2010 andCulture, Inc. Some rights reserved.
   Your reuse is governed by the MIT License (http://www.opensource.org/licenses/mit-license.php)
 */
package com.hydraframework.core.mvc.patterns.proxy {
	import com.hydraframework.core.hydraframework_internal;
	import com.hydraframework.core.mvc.events.Notification;
	import com.hydraframework.core.mvc.interfaces.IProxy;
	import com.hydraframework.core.mvc.patterns.facade.Facade;
	import com.hydraframework.core.mvc.patterns.relay.Relay;
	
	import flash.events.IEventDispatcher;

	//import nl.demonsters.debugger.MonsterDebugger;
	
	use namespace hydraframework_internal;
	
	public class Proxy extends Relay implements IProxy {
		public static const REGISTER:String = "Proxy.register";
		public static const REMOVE:String = "Proxy.remove";

		public var data:Object;

		/*
		   ...rest is a compatibility feature. Proxy doesn't need args,
		   however this would explode compatibility with previous versions,
		   and AS3 does not support overloading.
		 */
		public function Proxy(...rest) {
			super();
			if (rest.length > 0) {
				if (rest[0] is Array) {
					rest = rest[0];
				}
				if (rest[0] is String) {
					this.setName(String(rest[0]));
				} else if (rest[0] is IEventDispatcher) {
					this.setComponent(IEventDispatcher(rest[0]));
				}
			}
			if (rest.length > 1) {
				this.data = rest[1];
			}
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