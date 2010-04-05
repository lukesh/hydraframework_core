/*
   HydraFramework - Copyright (c) 2010 andCulture, Inc. Some rights reserved.
   Your reuse is governed by the MIT License (http://www.opensource.org/licenses/mit-license.php)
 */
package com.hydraframework.core.mvc.patterns.mediator {
	import com.hydraframework.core.hydraframework_internal;
	import com.hydraframework.core.mvc.events.Notification;
	import com.hydraframework.core.mvc.interfaces.IMediator;
	import com.hydraframework.core.mvc.patterns.facade.Facade;
	import com.hydraframework.core.mvc.patterns.relay.Relay;
	
	import flash.events.IEventDispatcher;
	
	//import nl.demonsters.debugger.MonsterDebugger;

	use namespace hydraframework_internal;
	
	public class Mediator extends Relay implements IMediator {
		public static const REGISTER:String = "Mediator.register";
		public static const REMOVE:String = "Mediator.remove";

		/*
		   ...rest is a compatibility feature. Ultimately, we'd like this:
		   component : IEventDispatcher = null
		   however this would explode compatibility with previous versions,
		   and AS3 does not support overloading.
		 */
		public function Mediator(...rest) {
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
				if (rest[1] is IEventDispatcher) {
					this.setComponent(IEventDispatcher(rest[1]));
				}
			}

			if (component) {
				this.hydraframework_internal::__initialize();
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
				case Facade.REMOVE:
					this.hydraframework_internal::__dispose();
					break;
			}
		}
		
		override hydraframework_internal function __initialize(notificationName:String=null) : void {
			super.__initialize(notificationName || Mediator.REGISTER);
		}
		

		override hydraframework_internal function __dispose(notificationName:String=null) : void {
			super.__dispose(notificationName || Mediator.REMOVE);
		}
	}
}
