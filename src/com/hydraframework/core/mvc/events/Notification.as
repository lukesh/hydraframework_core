/*
   HydraFramework - Copyright (c) 2009 andCulture, Inc. Some rights reserved.
   Your reuse is governed by the MIT License (http://www.opensource.org/licenses/mit-license.php)
 */
package com.hydraframework.core.mvc.events {

	import flash.events.Event;

	/**
	 * A Notification is a subclass of the Flash Event object, of type
	 * "Notification" and is used to facilitate MVC communication between
	 * the actors.
	 */
	public class Notification extends Event {
		/**
		 * All Notification events are of type Notification.TYPE
		 * ("Notification")
		 */
		public static const TYPE:String="Notification";
		/*
		   These constants are the same as what is found in the Phase class.
		   The only reason they are here so to allow the phase property to be set
		   to a default in the constructor. Phase should be used to access the
		   values of these constants.
		 */
		private static const PHASE_REQUEST:String="Phase.request";
		private static const PHASE_RESPONSE:String="Phase.response";
		private static const PHASE_COMPLETE:String="Phase.complete";
		private static const PHASE_CANCEL:String="Phase.cancel";
		private static const PHASE_FAULT:String="Phase.fault";
		
		private var _name:String;
		
		/**
		 * Name of the Notification event. This is the core of the notification
		 * system. Names should be assigned via constants stored in Facades,
		 * and correspond with application workflow logic.
		 *
		 * Notification names, while arbitrary should be formatted as
		 * "SUBJECT_VERB", where the subject identifies the process or object,
		 * and the verb is the present-tense action word, such as:
		 * AUTHENTICATION_LOGIN. It is advisable not to create two
		 * notifications for the same process, such as "USER_CREATE" and
		 * "USER_CREATED", or "PROCESS_START" and "PROCESS_FINISHED". Rather,
		 * use the Notification.phase property to indicate the phase of the
		 * process. For most processes, the phase can be identified by one of
		 * the constants in the Phase class.
		 */

		public function set name(value:String):void {
			if (value != _name) {
				_name=value;
			}
		}

		public function get name():String {
			return _name;
		}

		/**
		 * This provides another method to access the "name" property, as you
		 * would using PureMVC.
		 *
		 * @return String
		 */
		public function getName():String {
			return name;
		}
		
		private var _body:Object;
		
		/**
		 * Body is the "payload" of the notification, and is weakly typed.
		 * This is both a weakness and a strength of the HydraFramework framework.
		 * Remember that you typicaly will have to properly cast the body of
		 * your notification before you use it.
		 */

		public function set body(value:Object):void {
			if (value != _body) {
				_body=value;
			}
		}

		public function get body():Object {
			return _body;
		}

		/**
		 * This provides another method to access the "body" property, as you
		 * would using PureMVC.
		 *
		 * @return Object
		 */
		public function getBody():Object {
			return body;
		}
		
		private var _phase:String;
		
		/**
		 * Phase indicates the point in the process defined by the
		 * Notification's body. That process will run through several phases,
		 * which we've established as constants in the Phase class. While you
		 * can define your own phase constants, most of the time the four phase
		 * types (Phase.REQUEST, Phase.RESPONSE, Phase.CANCEL, Phase.COMPLETE, 
		 * and Phase.FAULT), are adequate to describe most processes.
		 *
		 * For example, you might define a process as "USER_CREATE". A
		 * "USER_CREATE" notification might be sent from a mediator of type
		 * Phase.REQUEST, which is handled by the UserCreateCommand. This
		 * command might run a .createUser() method on your proxy, which in
		 * turn sends a "USER_CREATE" notification of type Phase.RESPONSE.
		 *
		 * IMPORTANT: Always remember to test the phase of the notification in
		 * your commmands!!! It's easy to create an infinite loop. For example,
		 * if your UserCreateCommand response to a USER_CREATE notification,
		 * that command will run when that notification is sent from the
		 * mediator AND when it is sent from the proxy (in the above example).
		 * For most instances, you will only want the command to execute in the
		 * Phase.REQUEST phase. However, in some (infrequent) cases, handling
		 * multiple phases in the same command could be beneficial.
		 *
		 * In PureMVC, the third property of Notifications is called "type",
		 * however, in HydraFramework, we felt that "phase" was a clearer designation
		 * of how we used it in Flex.
		 */

		public function set phase(value:String):void {
			if (value != _phase) {
				_phase=value;
			}
		}

		public function get phase():String {
			return _phase;
		}

		/**
		 * This provides another method to access the "phase" property. However,
		 * note that PureMVC defines the Notification phase as its "type"--an
		 * architecture decision that we changed in HydraFramework.
		 *
		 * @return String
		 */
		public function getPhase():String {
			return phase;
		}
		
		public function isRequest():Boolean {
			return phase == Phase.REQUEST;
		}

		public function isResponse():Boolean {
			return phase == Phase.RESPONSE;
		}

		public function isComplete():Boolean {
			return phase == Phase.COMPLETE;
		}

		public function isCancel():Boolean {
			return phase == Phase.CANCEL;
		}
		
		public function isFault():Boolean {
			return phase == Phase.FAULT;
		}
		
		public function Notification(name:String, body:Object=null, phase:String=PHASE_REQUEST, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(TYPE, bubbles, cancelable);
			this.name=name;
			this.body=body;
			this.phase=phase;
		}

		override public function clone():Event {
			var clone:Notification=new Notification(this.name, this.body, this.phase, this.bubbles, this.cancelable);
			return clone;
		}
	}
}