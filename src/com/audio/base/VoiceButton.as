package org.osmf.yf.player
{
	import com.adobe.protocols.dict.events.ErrorEvent;
	
	import flash.events.AsyncErrorEvent;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.StatusEvent;
	import flash.events.TimerEvent;
	import flash.media.Microphone;
	import flash.media.MicrophoneEnhancedMode;
	import flash.media.MicrophoneEnhancedOptions;
	import flash.media.SoundCodec;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.net.ObjectEncoding;
	import flash.utils.Timer;
	
	import org.osmf.events.MediaError;
	import org.osmf.events.MediaErrorCodes;
	import org.osmf.events.MediaErrorEvent;
	import org.osmf.player.chrome.ChromeProvider;
	import org.osmf.player.chrome.assets.AssetIDs;
	import org.osmf.player.chrome.assets.AssetsManager;
	import org.osmf.player.chrome.widgets.PlayableButton;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.traits.PlayState;
	import org.osmf.traits.PlayTrait;
	import org.osmf.traits.SeekTrait;
	import org.osmf.traits.TimeTrait;
	
	public class VoiceButton extends PlayableButton
	{
		// Public API
		//
		public static const NORMAL_STATE:String="normalstate";
		public static const HANGUP_STATE:String="hangupstate";
		public static const CALLING_STATE:String="callingstate";
		public static const RECORD_STATE:String="recordstate";
		private var _voiceState:String=NORMAL_STATE;
		public function VoiceButton()
		{
			visibilityTimer = new Timer(VISIBILITY_DELAY, 1);
			visibilityTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onVisibilityTimerComplete);
			
			super();
			
			changeFace();
		}
		/**
		 * yf
		 * state 普通状态 normalstate  挂起等待状态 hangupstate 通话中 callingstate
		 */ 
		public function set voiceState( value:String ):void
		{
			_voiceState = value;
			changeFace();
			configure(<default/>,ChromeProvider.getInstance().assetManager);
		}	
		public function get voiceState( ):String
		{
			return _voiceState;
		}
		public function changeFace( ):void
		{
			switch ( _voiceState )
			{
				case NORMAL_STATE:{
					upFace   = AssetIDs.VOICE_NORMAL;
					downFace = AssetIDs.VOICE_HIGHLIGHT;
					overFace = AssetIDs.VOICE_HIGHLIGHT;
					break;
				}
				case HANGUP_STATE:{
					upFace   = AssetIDs.VOICE_PAIMAI;
					downFace = AssetIDs.VOICE_PAIMAI;
					overFace = AssetIDs.VOICE_PAIMAI;
					break;
				}
				case CALLING_STATE:{
					upFace   = AssetIDs.VOICE_KEEPLIVE;
					downFace = AssetIDs.VOICE_KEEPLIVE;
					overFace = AssetIDs.VOICE_KEEPLIVE;
					break;
					
				}
				case RECORD_STATE:{
					upFace   = AssetIDs.VOICE_MUTE;
					downFace = AssetIDs.VOICE_MUTE;
					overFace = AssetIDs.VOICE_MUTE;
					break;
				}
				default:
				
			}
		}
		// Overrides
		//
		override public function configure(xml:XML, assetManager:AssetsManager):void
		{
			super.configure(xml, assetManager);
			
			// Make sure that the overlay is toggle invisible intially:
			visible = true;
		}
		
		override public function set visible(value:Boolean):void
		{
			if (value != _visible)
			{
				_visible = value;
				
				if (value == false)
				{
					visibilityTimer.stop();
					super.visible = false;					
				}
				else
				{
					if (visibilityTimer.running)
					{
						visibilityTimer.stop();
					}
					if (parent)
					{
						visibilityTimer.reset();
						visibilityTimer.start();
					}
					else
					{
						super.visible = true;
					}
				}
			}
			super.visible = true;
		}
		
		override public function get visible():Boolean
		{
			return _visible;
		}
		
		//override protected function onMouseClick(event:MouseEvent):void
		//{
		//trace("截图");
		//}
		
		override protected function visibilityDeterminingEventHandler(event:Event = null):void
		{
			
			visible = true;
		}
		
		// Internals
		//
		
		private function onVisibilityTimerComplete(event:TimerEvent):void
		{
			super.visible = true;	
		}
		
		private var _visible:Boolean = true;
		private var visibilityTimer:Timer;
		
		/* static */
		private static const VISIBILITY_DELAY:int = 500;
		
		public static var audio_target:String="";
		public static var surl:String="aaa";
		public static var live:Boolean=false;
		private var nc:NetConnection; 
		private var ns:NetStream;
		private var mic:Microphone;
		public static var startVoice:Boolean=false;
		public function connect():void {
		
			NetConnection.defaultObjectEncoding = ObjectEncoding.AMF3; // MUST SUPPLY THIS!!!
			if ( surl!=null && surl.length>10 && surl != "aaa" )
			{
				if (nc == null) 
				{
					nc = new NetConnection();
					nc.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler, false, 0, true);
					nc.addEventListener(IOErrorEvent.IO_ERROR, errorHandler, false, 0, true);
					nc.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler, false, 0, true);
					nc.addEventListener(AsyncErrorEvent.ASYNC_ERROR, errorHandler, false, 0, true);
					nc.connect(surl);
				}
			}else{
				startVoice = false;
				voiceState = VoiceButton.NORMAL_STATE;
			}
		}
		private function publish():void {
			if (ns == null && nc != null && nc.connected)
			{
				ns = new NetStream(nc);
				ns.bufferTime = 0;
//				mic = Microphone.getMicrophone();
//			    mic.setUseEchoSuppression(true);
////				mic.rate = 16;
//				mic.setSilenceLevel(0);
//				mic.framesPerPacket =6;
//				mic.codec = SoundCodec.SPEEX;
//				ns.publish(audio_target);
//				ns.attachAudio(mic);
				
//				ns.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler, false, 0, true);
//				ns.addEventListener(IOErrorEvent.IO_ERROR, streamErrorHandler, false, 0, true);
//				ns.addEventListener(AsyncErrorEvent.ASYNC_ERROR, streamErrorHandler, false, 0, true);
////				
//				try
//				{
//					mic = Microphone.getEnhancedMicrophone();
//					var options:MicrophoneEnhancedOptions = new MicrophoneEnhancedOptions();

//					options.mode = MicrophoneEnhancedMode.FULL_DUPLEX;
//					options.autoGain = true;
//					options.echoPath = 128;
//					options.nonLinearProcessing = false;
//					mic.enhancedOptions = options;
					
					//				debug("mic's enhanced options <==> ", mic.enhancedOptions.autoGain, mic.enhancedOptions.echoPath,
					//					mic.enhancedOptions.mode, mic.enhancedOptions.nonLinearProcessing);
					
//				}catch(e:Error)
//				{
					mic = Microphone.getMicrophone();
					mic.setUseEchoSuppression(true);
					
//				}
				
				if (mic)
				{
					mic.codec=SoundCodec.SPEEX;
					//每包1帧
					mic.framesPerPacket = 1;
					mic.setSilenceLevel(0);
					ns.publish(audio_target);
					ns.attachAudio(mic);
				}
				else {
					closeStream();
					return;
				}	
			}
		}      
		public function onStatus(evt :StatusEvent ) :void
		{
		
		}
		public function closeStream():void {
			if (ns != null) {
				try{
					ns.close();
				}catch(e:Error){}
				ns = null;
			}
			if (nc != null) {
				try{
					nc.close();
				}catch(e:Error){}
				nc = null;
			}
//			if(startVoice) {
//				debug("restart voice session now!!");
//				connect();
//			}
		}
		private function netStatusHandler(event:NetStatusEvent):void {
			//	Debug.traceObj(event);
			switch (event.info.code) {
				case 'NetConnection.Connect.Success':
					publish();     
					break;
				case 'NetConnection.Connect.Failed':
				
				case 'NetConnection.Connect.Reject':
					
				case "NetStream.Connect.Rejected":  
				case "NetStream.Connect.Failed":
					startVoice = false;
//					XXCN.getInstance().dispatchEvent(new XXCN_Event(XXCN_Event.CONNECT_NOT));
					voiceState = VoiceButton.NORMAL_STATE;
//					throw new MediaError(MediaErrorCodes.NETSTREAM_PLAY_FAILED,"netstream.connect.failed:VoiceButton");
				case 'NetConnection.Connect.Closed':
					nc = null;
					closeStream();
					break;
				  
			}
		}
		
		private function errorHandler(event:flash.events.ErrorEvent):void {
//			debug('errorHandler() ' + event.type + ' ' + event.text);
			closeStream();
		}
		
		private function streamErrorHandler(event:flash.events.ErrorEvent):void {
			debug('streamErrorHandler() ' + event.type + ' ' + event.text);
			closeStream();
		}
		private function debug(msg:String):void {
			//	Debug.trace(msg);
		}
		
	}
}
