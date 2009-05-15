/*
   HydraFramework - Copyright (c) 2009 andCulture, Inc. Some rights reserved.
   Your reuse is governed by the Creative Commons Attribution 3.0 United States License
 */
package com.hydraframework.core.mvc.interfaces {
	import com.hydraframework.core.mvc.events.Notification;
	
	import flash.events.IEventDispatcher;
	
	import mx.core.IUIComponent;

	public interface IRelay extends IEventDispatcher {
		function setName(name:String):void;
		function getName():String;
		function setComponent(component:IUIComponent):void;
		function getComponent():IUIComponent;
		function setFacade(facade:IFacade):void;
		function getFacade():IFacade;
		function initialize():void;
		function dispose():void;
		function sendNotification(notification:Notification):void;
		function handleNotification(notification:Notification):void;
	}
}