/*
   HydraFramework - Copyright (c) 2009 andCulture, Inc. Some rights reserved.
   Your reuse is governed by the Creative Commons Attribution 3.0 United States License
 */
package com.hydraframework.core.registries {
	import flash.utils.getQualifiedClassName;

	public class DelegateRegistry {

		private static const _instance:DelegateRegistry=new DelegateRegistry();

		public static function getInstance():DelegateRegistry {
			return _instance;
		}

		private var delegateMap:Array;

		public function DelegateRegistry() {
			super();
			delegateMap = [];
		}
		
		/**
		 * Registers a delegate.
		 *
		 * @param	Class
		 * @return	void
		 */
		public function registerDelegate(delegate:Class):void {
			var delegateClass:String = getQualifiedClassName(delegate);
			delegateMap[delegateClass] = delegate;
			trace("Registering delegate:", delegateClass);
		}

		/**
		 * Retrieves the delegate that implements delegateInterface.
		 *
		 * @param	Class
		 * @return	Object
		 */
		public function retrieveDelegate(delegateInterface:Class):Object {
			var obj:Object;
			for (var s:String in delegateMap) {
				obj = new (delegateMap[s] as Class)();
				if (obj is delegateInterface) {
					return obj;
				}
			}
			return null;
		}

		/**
		 * Removes a specific delegate.
		 *
		 * @param	String
		 * @param	Class
		 * @return	void
		 */
		public function removeDelegate(delegate:Class):void {
			var delegateClass:String = getQualifiedClassName(delegate);
			delete delegateMap[delegateClass];
			trace("Removing delegate:", delegateClass);
		}

		/**
		 * Removes all registered delegates for specified interface.
		 *
		 * @param	String
		 * @param	Class
		 * @return	void
		 */
		public function removeDelegatesByInterface(delegateInterface:Class):void {
			var obj:Object;
			for (var s:String in delegateMap) {
				obj = new (delegateMap[s] as Class)();
				if (obj is delegateInterface) {
					delete delegateMap[s];
					trace("Removing delegate by Interface:", getQualifiedClassName(delegateInterface));
				}
			}
		}

		/**
		 * Completely removes all registered delegates.
		 * 
		 * @return	void
		 */		
		public function removeAll():void {
			var s:String;
			for (s in delegateMap) {
				delete delegateMap[s];
			}
		}
	}
}