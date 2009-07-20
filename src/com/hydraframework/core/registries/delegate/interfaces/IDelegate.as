/*
   HydraFramework - Copyright (c) 2009 andCulture, Inc. Some rights reserved.
   Your reuse is governed by the Creative Commons Attribution 3.0 United States License
 */
 package com.hydraframework.core.registries.delegate.interfaces {
	import mx.rpc.IResponder;

	public interface IDelegate {
		function set responder(value:IResponder):void;
		function get responder():IResponder;
	}
}