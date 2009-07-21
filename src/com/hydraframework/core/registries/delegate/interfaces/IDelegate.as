/*
   HydraFramework - Copyright (c) 2009 andCulture, Inc. Some rights reserved.
   Your reuse is governed by the Creative Commons Attribution 3.0 United States License
 */
 package com.hydraframework.core.registries.delegate.interfaces {
	import mx.rpc.IResponder;

	public interface IDelegate {
		function set responder(value:IResponder):void;
		/**
		 * The delegate maintains a responder property of type IResponder.
		 * When the delegate gets a response from the server, it is responsible
		 * transforming the data and applying it to the responder.
		 */
		function get responder():IResponder;
	}
}