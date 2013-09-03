package com.audio.base
{
	import flash.events.AsyncErrorEvent;
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.StatusEvent;
	import flash.media.Microphone;
	import flash.media.SoundCodec;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.net.ObjectEncoding;

	public class Audio
	{
		public  var audio_target:String="";
		public  var url_play:String="aaa";
		private var nc:NetConnection; 
		private var ns:NetStream;
		private var mic:Microphone;
		public function Audio()
		{
		}
		
		public function connect():void {
			
			NetConnection.defaultObjectEncoding = ObjectEncoding.AMF3; // MUST SUPPLY THIS!!!
			if ( url_play!=null && url_play.length>10 && url_play != "aaa" )
			{
				if (nc == null) 
				{
					nc = new NetConnection();
					nc.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler, false, 0, true);
					nc.addEventListener(IOErrorEvent.IO_ERROR, errorHandler, false, 0, true);
					nc.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler, false, 0, true);
					nc.addEventListener(AsyncErrorEvent.ASYNC_ERROR, errorHandler, false, 0, true);
					nc.connect(url_play);
				}
			}
		}
		private function publish():void {
			if (ns == null && nc != null && nc.connected)
			{
				ns = new NetStream(nc);
				ns.bufferTime = 0;
				
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
				nc.removeEventListener(NetStatusEvent.NET_STATUS, netStatusHandler, false);
				nc.removeEventListener(IOErrorEvent.IO_ERROR, errorHandler, false);
				nc.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler, false);
				nc.removeEventListener(AsyncErrorEvent.ASYNC_ERROR, errorHandler, false);
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