/*
   HydraFramework - Copyright (c) 2009 andCulture, Inc. Some rights reserved.
   Your reuse is governed by the Creative Commons Attribution 3.0 United States License
 */
package com.hydraframework.core.mvc.patterns.command {
	import com.hydraframework.core.mvc.events.Notification;
	import com.hydraframework.core.mvc.interfaces.ICommand;
	import com.hydraframework.core.mvc.interfaces.IFacade;
	import com.hydraframework.core.mvc.patterns.relay.Relay;

	/**
	 * Basic command. This is the most commonly-used command type.
	 *
	 * TODO: Create MacroCommand, and IUndoable and IRedoable interfaces.
	 */
	public class SimpleCommand extends Relay implements ICommand {
		public function SimpleCommand(facade:IFacade) {
			super(facade);
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