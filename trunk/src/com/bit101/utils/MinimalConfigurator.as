package com.bit101.utils
{
	// usually don't use * but we really are importing everything here.
	import com.bit101.components.*;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.getDefinitionByName;

	/**
	 * Creates and lays out minimal components based on a simple xml format.
	 */
	public class MinimalConfigurator extends EventDispatcher
	{
		private var loader:URLLoader;
		private var parent:DisplayObjectContainer;
		
		/**
		 * Constructor.
		 * @param parent The display object container on which to create components and look for ids and event handlers.
		 */
		public function MinimalConfigurator(parent:DisplayObjectContainer)
		{
			this.parent = parent;
		}
		
		/**
		 * Loads an xml file from the specified url and attempts to parse it as a layout format for this class.
		 * @param url The location of the xml file.
		 */
		public function loadXML(url:String):void
		{
			loader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, onLoadComplete);
			loader.load(new URLRequest(url));
		}
		
		/**
		 * Called when the xml has loaded. Will attempt to parse the loaded data as xml.
		 */
		private function onLoadComplete(event:Event):void
		{
			parseXMLString(loader.data as String);
		}
		
		/**
		 * Parses a string as xml.
		 * @param string The xml string to parse.
		 */ 
		public function parseXMLString(string:String):void
		{
			try
			{
				var xml:XML = new XML(string);
				parseXML(xml);
			}
			catch(e:Error)
			{
				
			}
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		/**
		 * Parses xml and creates componetns based on it.
		 * @param xml The xml to parse.
		 */
		public function parseXML(xml:XML):void
		{
			// root tag should contain one or more component tags
			// each tag's name should be the base name of a component, i.e. "PushButton"
			// package is assumed "com.bit101.components"
			for(var i:int = 0; i < xml.children().length(); i++)
			{
				var comp:XML = xml.children()[i];
				var compInst:Component = parseComp(comp);
				if(compInst != null)
				{
					parent.addChild(compInst);
				}
			}
		}
		
		/**
		 * Parses a single component's xml.
		 * @param xml The xml definition for this component.
		 * @return A component instance.
		 */
		private function parseComp(xml:XML):Component
		{
			var compInst:Object;
			try
			{
				var classRef:Class = getDefinitionByName("com.bit101.components." + xml.name()) as Class;
				compInst = new classRef();
				
				// id is special case
				if(xml.@id.toString() != "")
				{
					// if id exists on parent as a public property, assign this component to it.
					if(parent.hasOwnProperty(trim(xml.@id.toString())))
					{
						parent[trim(xml.@id)] = compInst;
					}
				}
				
				// event is another special case
				if(xml.@event.toString() != "")
				{
					// events are in the format: event="eventName:eventHandler"
					// i.e. event="click:onClick"
					var parts:Array = xml.@event.split(":");
					var eventName:String = trim(parts[0]);
					var handler:String = trim(parts[1]);
					if(parent.hasOwnProperty(handler))
					{
						// if event handler exists on parent as a public method, assign it as a handler for the event.
						compInst.addEventListener(eventName, parent[handler]);
					}
				}
				
				// every other attribute handled essentially the same
				for each(var attrib:XML in xml.attributes())
				{
					var prop:String = attrib.name().toString();
					// if the property exists on the component, assign it.
					if(compInst.hasOwnProperty(prop))
					{
						// special handling to correctly parse booleans
						if(compInst[prop] is Boolean)
						{
							compInst[prop] = attrib == "true";
						}
						else
						{
							compInst[prop] = attrib;
						}
					}
				}
				
				// child nodes will be added as children to the instance just created.
				for(var j:int = 0; j < xml.children().length(); j++)
				{
					var child:Component = parseComp(xml.children()[j]);
					if(child != null)
					{
						if(compInst.hasOwnProperty("content"))
						{
							// some components (window, panel, scrollpane) need childen added to the content property
							compInst.content.addChild(child);
						}
						else
						{
							// otherwise, just add them normally.
							compInst.addChild(child);
						}
					}
				}
			}
			catch(e:Error)
			{
				
			}
			return compInst as Component;
		}
		
		/**
		 * Trims a string.
		 * @param s The string to trim.
		 * @return The trimmed string.
		 */
		private function trim(s:String):String
		{
			// http://jeffchannell.com/ActionScript-3/as3-trim.html
			return s.replace(/^\s+|\s+$/gs, '');
		}
		
		/**
		 * This method merely serves to include all component classes in the swf.
		 */
		private function comprefs():void
		{
			Accordion;
			Calendar;
			CheckBox;
			ColorChooser;
			ComboBox;
			FPSMeter;
			HBox;
			HRangeSlider;
			HScrollBar;
			HSlider;
			HUISlider;
			IndicatorLight;
			InputText;
			Knob;
			Label;
			List;
			ListItem;
			Meter;
			NumericStepper;
			Panel;
			ProgressBar;
			PushButton;
			RadioButton;
			RangeSlider;
			RotarySelector;
			ScrollBar;
			ScrollPane;
			Slider;
			Style;
			Text;
			TextArea;
			UISlider;
			VBox;
			VRangeSlider;
			VScrollBar;
			VSlider;
			VUISlider;
			WheelMenu;
			Window;
		}
	}
}