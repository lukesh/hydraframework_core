/*
   HydraFramework - Copyright (c) 2009 andCulture, Inc. Some rights reserved.
   Your reuse is governed by the Creative Commons Attribution 3.0 United States License
 */
package com.hydraframework.core.mvc.patterns.mediator {
	import com.hydraframework.core.mvc.events.Notification;
	import com.hydraframework.core.mvc.interfaces.IMediator;
	import com.hydraframework.core.mvc.patterns.facade.Facade;
	import com.hydraframework.core.mvc.patterns.relay.Relay;
	
	import mx.core.IUIComponent;

	//import nl.demonsters.debugger.MonsterDebugger;
	public class Mediator extends Relay implements IMediator {
		public static const REGISTER:String = "Mediator.register";
		public static const REMOVE:String = "Mediator.remove";

		public function Mediator(name:String = null, component:IUIComponent = null) {
			super();
			this.setName(name);
			this.setComponent(component);

			if (component) {
				initialize();
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
		override public function handleNotification(notification:Notification):void {
			super.handleNotification(notification);

			switch (notification.name) {
				case Facade.REMOVE:
					dispose();
					break;
			}
		}

		override public function initialize():void {
			if (initialized)
				return;
			//MonsterDebugger.trace(this, "Mediator.initialize()");
			//trace("Mediator.initialize()", this);
			super.initialize();
		}

		override public function dispose():void {
			if (!initialized)
				return;
			//MonsterDebugger.trace(this, "Mediator.dispose()");
			//trace("Mediator.dispose()", this);
			super.dispose();
		}
	}
}