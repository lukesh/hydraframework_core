/*
   HydraFramework - Copyright (c) 2010 andCulture, Inc. Some rights reserved.
   Your reuse is governed by the MIT License (http://www.opensource.org/licenses/mit-license.php)
 */
package com.hydraframework.core {
	import flash.events.IEventDispatcher;

	public class HydraEventMap {
		public function HydraEventMap(initializeFacadeEvents : Array = null, initializeCoreEvents : Array = null, disposeCoreEvents : Array = null) {
			this.initializeFacadeEvents = initializeFacadeEvents;
			this.initializeCoreEvents = initializeCoreEvents;
			this.disposeCoreEvents = disposeCoreEvents;
		}

		public var initializeFacadeEvents : Array = [];
		public var initializeCoreEvents : Array = [];
		public var disposeCoreEvents : Array = [];

		public function registerInitializeFacadeEvents(component : IEventDispatcher, handler : Function) : void {
			registerEvents(initializeFacadeEvents, component, handler, false);
		}

		public function removeInitializeFacadeEvents(component : IEventDispatcher, handler : Function) : void {
			removeEvents(initializeFacadeEvents, component, handler);
		}

		public function registerInitializeCoreEvents(component : IEventDispatcher, handler : Function, onlyRegisterFirst : Boolean = false) : void {
			registerEvents(onlyRegisterFirst ? ((initializeCoreEvents && initializeCoreEvents.length > 0) ? [initializeCoreEvents[0]] : initializeCoreEvents) : initializeCoreEvents, component, handler, true, 20);
		}

		public function removeInitializeCoreEvents(component : IEventDispatcher, handler : Function) : void {
			removeEvents(initializeCoreEvents, component, handler);
		}

		public function registerDisposeCoreEvents(component : IEventDispatcher, handler : Function) : void {
			registerEvents(disposeCoreEvents, component, handler);
		}

		public function removeDisposeCoreEvents(component : IEventDispatcher, handler : Function) : void {
			removeEvents(disposeCoreEvents, component, handler);
		}

		public function registerEvents(events : Array, component : IEventDispatcher, handler : Function, useWeakReference : Boolean = true, priority : int = 0) : void {
			events.forEach(function(e : *, i : int, a : Array) : void {
					component.addEventListener(String(e), handler, false, priority, useWeakReference);
				});
		}

		public function removeEvents(events : Array, component : IEventDispatcher, handler : Function) : void {
			events.forEach(function(e : *, i : int, a : Array) : void {
					component.removeEventListener(String(e), handler);
				});
		}

		public function clone() : HydraEventMap {
			return new HydraEventMap(initializeFacadeEvents, initializeCoreEvents, disposeCoreEvents);
		}
	}
}