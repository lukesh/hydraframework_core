/*
   HydraFramework - Copyright (c) 2009 andCulture, Inc. Some rights reserved.
   Your reuse is governed by the Creative Commons Attribution 3.0 United States License
 */
 package com.hydraframework.core.mvc.interfaces
{
	import flash.events.Event;
	
	public interface INotification
	{
		function getName():String;
		function getBody():Object;
		function getPhase():String;
		function isRequest():Boolean;
		function isResponse():Boolean;
		function isComplete():Boolean;
		function isCancel():Boolean;
		function clone():Event;
	}
}