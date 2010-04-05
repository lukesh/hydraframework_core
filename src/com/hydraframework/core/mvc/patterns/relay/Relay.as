/*
   HydraFramework - Copyright (c) 2010 andCulture, Inc. Some rights reserved.
   Your reuse is governed by the MIT License (http://www.opensource.org/licenses/mit-license.php)
 */
package com.hydraframework.core.mvc.patterns.relay {
	import com.hydraframework.core.HydraFramework;
	import com.hydraframework.core.hydraframework_internal;
	import com.hydraframework.core.mvc.events.Notification;
	import com.hydraframework.core.mvc.interfaces.IFacade;
	import com.hydraframework.core.mvc.interfaces.IRelay;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.getQualifiedClassName;
	
	use namespace hydraframework_internal;
	
	/**
	 * Relay is the base class for MVC actors. Facade, Proxy and Mediator all
	 * sublcass Relay.
	 */
	public class Relay extends EventDispatcher implements IRelay {
		
		public static const VERSION:String = "2.0.2";
		
		public static const REGISTER:String = "Relay.register";
		public static const REMOVE:String = "Relay.remove";
		
		public function getVersion():String {
			return VERSION;
		}
		
		/**
		 * Name of Relay. This is important when retrieving an instance of a
		 * registered Relay.
		 */
		private var _name : String;
		public function set name(value : String) : void {
			_name = value;
		}
		public function get name() : String {
			if (_name == null) {
				_name = Math.floor(Math.random() * 999999).toString();
				_name = getQualifiedClassName(this) + "@" + (function(s : String) : String {
					while (s.length < 6) {
						s = "0" + s;
					}
					return s;
				})(_name);
			}
			return _name;
		}

		public function setName(name:String):void {
			this.name = name;
		}

		public function getName():String {
			return this.name;
		}
		/**
		 * Facades and Mediators can be bound to IEventDispatchers.
		 */
		public var component:IEventDispatcher;

		public function setComponent(component:IEventDispatcher):void {
			this.component = component;
		}

		public function getComponent():IEventDispatcher {
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
		 * @private
		 */
		hydraframework_internal var __isInitializing : Boolean = false;		
		
		/**
		 * @private
		 */
		hydraframework_internal function __initialize(notificationName:String=null):void {
			this.hydraframework_internal::__isInitializing = true;
			if (_initialized)
				return;
			//trace("Relay.initialize():", this);
			HydraFramework.log(HydraFramework.DEBUG_SHOW_INTERNALS, "----- <HydraFramework> Relay.hydraframework_internal::__initialize", this);
			this.attachEventListeners();
			_initialized = true;
			initialize();
			this.sendNotification(new Notification(notificationName || Relay.REGISTER, this));
		}
		
		/**
		 * The initialize() method registers the Relay's event listeners, which
		 * binds it to the MVC. In addition, initialize() can be overridden to
		 * introduce more startup functionality.
		 */
		public function initialize():void {
			// If this is overridden, and Hydra can't call its own
			// __initialize, the best we can do is try to call it. If they
			// don't call super.initialize(), then they must perform those
			// steps manually.
			if (!this.hydraframework_internal::__isInitializing) {
				this.hydraframework_internal::__initialize();
			}
		}
		
		/**
		 * private
		 */
		hydraframework_internal var __isDisposing : Boolean = false;
		
		/**
		 * @private
		 */
		hydraframework_internal function __dispose(notificationName:String=null):void {
			this.hydraframework_internal::__isDisposing = true;
			if (!_initialized)
				return;
			HydraFramework.log(HydraFramework.DEBUG_SHOW_INTERNALS, "----- <HydraFramework> Relay.hydraframework_internal::__dispose", this);
			//trace("Relay.dispose():", this);
			dispose();
			this.sendNotification(new Notification(notificationName || Relay.REMOVE, this));
			this.removeEventListeners();
			_initialized = false;
		}

		/**
		 * The dispose() method removes the Relay's event listeners, removing
		 * it from participation in the MVC. In addition, dispose() can be
		 * overridden to introduce more shutdown functionality.
		 */
		public function dispose():void {
			// If this is overridden, and Hydra can't call its own
			// __dispose, the best we can do is try to call it. If they
			// don't call super.dispose(), then they must perform those
			// steps manually.
			if (!this.hydraframework_internal::__isDisposing) {
				this.hydraframework_internal::__dispose();
			}
		}

		/**
		 * Sends the Notification type event.
		 */
		public function sendNotification(notification:Notification):void {
			this.dispatchEvent(Event(notification));
		}

		/**
		 * @private
		 */
		hydraframework_internal function __handleNotification(notification:Notification):void {
			HydraFramework.log(HydraFramework.DEBUG_SHOW_INTERNALS, "----- <HydraFramework> Relay.hydraframework_internal::__handleNotification:", this, notification.name);
			handleNotification(notification);
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
			this.hydraframework_internal::__initialize();
		}

		/**
		 * This method handles the appropriate removal events, ultimately
		 * calling dispose() and removing the actor from the MVC.
		 */
		protected function handleRemove(event:Event):void {
			if (event.target == this.component) {
				this.hydraframework_internal::__dispose();
				event.stopPropagation();
			}
		}
	}
}