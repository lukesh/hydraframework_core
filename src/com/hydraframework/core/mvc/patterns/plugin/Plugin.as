/*
   HydraFramework - Copyright (c) 2009 andCulture, Inc. Some rights reserved.
   Your reuse is governed by the MIT License (http://www.opensource.org/licenses/mit-license.php)
 */
package com.hydraframework.core.mvc.patterns.plugin {
	import com.hydraframework.core.hydraframework_internal;
	import com.hydraframework.core.mvc.events.Notification;
	import com.hydraframework.core.mvc.interfaces.IPlugin;
	import com.hydraframework.core.mvc.patterns.facade.Facade;
	import com.hydraframework.core.mvc.patterns.relay.Relay;
	//import nl.demonsters.debugger.MonsterDebugger;
	
	use namespace hydraframework_internal;
	
	public class Plugin extends Relay implements IPlugin {
		public static const REGISTER:String = "Plugin.register";
		public static const REMOVE:String = "Plugin.remove";

		public var data:Object;
		
		public function Plugin(name:String = null, data:Object = null) {
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
			super.__initialize(notificationName || Plugin.REGISTER);
		}
		
		
		override hydraframework_internal function __dispose(notificationName:String=null) : void {
			super.__dispose(notificationName || Plugin.REMOVE);
		}
		
		public function preinitialize():void {
		}
	}
}