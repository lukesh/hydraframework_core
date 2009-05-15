/*
   HydraFramework - Copyright (c) 2009 andCulture, Inc. Some rights reserved.
   Your reuse is governed by the Creative Commons Attribution 3.0 United States License
 */
package com.hydraframework.core.mvc.patterns.plugin {
	import com.hydraframework.core.mvc.events.Notification;
	import com.hydraframework.core.mvc.interfaces.IPlugin;
	import com.hydraframework.core.mvc.patterns.facade.Facade;
	import com.hydraframework.core.mvc.patterns.relay.Relay;

	//import nl.demonsters.debugger.MonsterDebugger;
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
		override public function handleNotification(notification:Notification):void {
			super.handleNotification(notification);

			switch (notification.name) {
				case Facade.REGISTER:
					initialize();
					break;
				case Facade.REMOVE:
					dispose();
					break;
			}
		}

		public function preinitialize():void {
		}
		
		override public function initialize():void {
			if (initialized)
				return;
			//MonsterDebugger.trace(this, "Plugin.initialize()");
			//trace("Plugin.initialize()", this);
			super.initialize();
		}

		override public function dispose():void {
			if (!initialized)
				return;
			//MonsterDebugger.trace(this, "Plugin.dispose()");
			//trace("Plugin.dispose()", this);
			super.dispose();
		}
	}
}