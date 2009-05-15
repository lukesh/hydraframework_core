/*
   HydraFramework - Copyright (c) 2009 andCulture, Inc. Some rights reserved.
   Your reuse is governed by the Creative Commons Attribution 3.0 United States License
 */
package com.hydraframework.core.mvc.patterns.relay {
	import com.hydraframework.core.mvc.events.Notification;
	import com.hydraframework.core.mvc.interfaces.IFacade;
	import com.hydraframework.core.mvc.interfaces.IRelay;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import mx.core.IUIComponent;

	/**
	 * Relay is the base class for MVC actors. Facade, Proxy and Mediator all
	 * sublcass Relay.
	 */
	public class Relay extends EventDispatcher implements IRelay {
		public static const REGISTER:String = "Relay.register";
		public static const REMOVE:String = "Relay.remove";
		/**
		 * Name of Relay. This is important when retrieving an instance of a
		 * registered Relay.
		 */
		public var name:String;

		public function setName(name:String):void {
			this.name = name;
		}

		public function getName():String {
			return this.name;
		}
		/**
		 * Facades and Mediators can be bound to IUIComponents.
		 */
		public var component:IUIComponent;

		public function setComponent(component:IUIComponent):void {
			this.component = component;
		}

		public function getComponent():IUIComponent {
			return this.component;
		}
		/**
		 * Although Relays can participate in multiple Facades (as with
		 * singleton Proxies), in most cases a Relay is bound to a single
		 * Facade. This stores the last Facade with which this Relay was
		 * registered.
		 */
		public var facade:IFacade;

		public function setFacade(facade:IFacade):void {
			this.facade = facade;
		}

		public function getFacade():IFacade {
			return this.facade;
		}
		/**
		 * The initialization sequence is critical to the functionality of
		 * the MVC. The initialized property indicates whether the actor is
		 * intialized and active or not.
		 */
		private var _initialized:Boolean = false;

		public function set initialized(value:Boolean):void {
			_initialized = value;
		}

		public function get initialized():Boolean {
			return _initialized;
		}

		public function Relay(facade:IFacade = null) {
			super();
			this.setFacade(facade);
		}

		/**
		 * These core Relay methods are used in the initialization and disposal
		 * sequences to ensure that events are registered and removed at the
		 * proper time.
		 */
		protected function attachEventListeners():void {
		}

		protected function removeEventListeners():void {
		}

		/**
		 * The initialize() method registers the Relay's event listeners, which
		 * binds it to the MVC. In addition, initialize() can be overridden to
		 * introduce more startup functionality.
		 */
		public function initialize():void {
			if (_initialized)
				return;
			//trace("Relay.initialize():", this);	
			this.attachEventListeners();
			_initialized = true;
			this.sendNotification(new Notification(Relay.REGISTER, this));
		}

		/**
		 * The dispose() method removes the Relay's event listeners, removing
		 * it from participation in the MVC. In addition, dispose() can be
		 * overridden to introduce more shutdown functionality.
		 */
		public function dispose():void {
			if (!_initialized)
				return;
			//trace("Relay.dispose():", this);	
			this.sendNotification(new Notification(Relay.REMOVE, this));
			this.removeEventListeners();
			_initialized = false;
		}

		/**
		 * Sends the Notification type event.
		 */
		public function sendNotification(notification:Notification):void {
			this.dispatchEvent(notification);
		}

		/**
		 * This core method handles Notification events, and needs to be
		 * overridden in subclasses do do anything.
		 */
		public function handleNotification(notification:Notification):void {
		}

		/**
		 * This method handles the appropriate registration events, ultimately
		 * calling the initialize() method.
		 */
		protected function handleRegister(event:Event):void {
			if (_initialized)
				return;
			this.initialize();
		}

		/**
		 * This method handles the appropriate removal events, ultimately
		 * calling dispose() and removing the actor from the MVC.
		 */
		protected function handleRemove(event:Event):void {
			if (event.target == this.component) {
				this.dispose();
				event.stopPropagation();
			}
		}
	}
}