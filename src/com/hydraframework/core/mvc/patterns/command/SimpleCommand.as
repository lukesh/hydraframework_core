/*
   HydraFramework - Copyright (c) 2009 andCulture, Inc. Some rights reserved.
   Your reuse is governed by the MIT License (http://www.opensource.org/licenses/mit-license.php)
 */
package com.hydraframework.core.mvc.patterns.command {
	import com.hydraframework.core.hydraframework_internal;
	import com.hydraframework.core.mvc.events.Notification;
	import com.hydraframework.core.mvc.events.Phase;
	import com.hydraframework.core.mvc.interfaces.ICommand;
	import com.hydraframework.core.mvc.interfaces.IFacade;
	import com.hydraframework.core.mvc.patterns.relay.Relay;
	
	use namespace hydraframework_internal;
	
	/**
	 * Basic command. This is the most commonly-used command type.
	 *
	 * TODO: Create MacroCommand, and IUndoable and IRedoable interfaces.
	 */
	public class SimpleCommand extends Relay implements ICommand {
		public function SimpleCommand(facade:IFacade) {
			super(facade);
		}

		public var notification:Notification;
		
		/**
		 * @private
		 */
		hydraframework_internal function __execute(notification:Notification):void {
			this.notification = notification; 	
			execute(notification);
		}
		
		public function respond(body:Object):void {
			sendNotification(new Notification(notification.name, body, Phase.RESPONSE));
		}
		
		public function cancel(body:Object):void {
			sendNotification(new Notification(notification.name, body, Phase.CANCEL));
		}
		
		public function complete(body:Object):void {
			sendNotification(new Notification(notification.name, body, Phase.COMPLETE));
		}
		
		/**
		 * Override this method to define what action this command performs.
		 *
		 * @param	Notification
		 * @return	void
		 */
		public function execute(notification:Notification):void {
		}
		
		/**
		 * Since the Command is instantiated as needed, it must forward the
		 * note to the listening Facade.
		 * 
		 * @param	Notification
		 * @return	void
		 */
		override public function sendNotification(notification:Notification) : void
		{
			if (this.facade)
			{
				this.facade.sendNotification(notification);
			}
		}
	}
}