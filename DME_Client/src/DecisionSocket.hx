package ;

import haxe.io.Bytes;
import haxe.io.BytesBuffer;
import flash.utils.ByteArray;

import sys.net.Host;
import cpp.vm.Mutex;
import sys.net.Socket;
import cpp.vm.Thread;

class DecisionSocket {
	
	var _sock			: Socket;
	var _inBuf			: BytesBuffer;
	var BUF_SIZE  		: Int = 32;
	var _byteCounter	: Int;
	private var _socketMutex:Mutex;
	private var _connected : Bool;
	private var _host:String;
	private var _port:Int;
	
	private var _dataCallBack:Dynamic;
	private var _onOpenCallBack:Dynamic;
	private var _onCloseCallBack:Dynamic;
	private var _onErrorCallBack:Dynamic;
	
	public function new(dataCallBack : Dynamic, onOpenCallBack : Dynamic, onCloseCallBack : Dynamic, onErrorCallBack : Dynamic) {
		_dataCallBack = dataCallBack;
		_onOpenCallBack = onOpenCallBack;
		_onCloseCallBack = onCloseCallBack;
		_onErrorCallBack = onErrorCallBack;
		_socketMutex = new Mutex();
		_sock = new Socket();
	}
	
	public function connect( host : String, port : Int ) {
		_connected = false;
		_host = host;
		_port = port;
		try {
			//if (_socketMutex.tryAcquire()) {
				if (_sock != null) {
				try{	
					//_sock.close();
				} catch (e:Dynamic){
					trace("no disconnect from connect()");
				}

				}
				_sock.connect( new Host( _host ), 44444 );
				//_socketMutex.release();
			//}
			
			_inBuf = new BytesBuffer();
			_byteCounter = 0;
				
				_connected = true;

				Thread.create( checkInput );
				_onOpenCallBack();
				
		}catch ( e : Dynamic ) {
			_connected = false;
			_onErrorCallBack();
		}
		
	}
	
	public function close() {
		
		try {
			_connected = false;
			_socketMutex.acquire();
			if (_sock != null) {
				try{	
					_sock.close();
				} catch (e:Dynamic){
					trace("no disconnect from connect()");
				}
			}
			_socketMutex.release();
			_onCloseCallBack();
		}catch ( e : Dynamic ) {
			_onErrorCallBack();
		}
		
	}
	
	public function writeBytes( bytes : ByteArray ) {
		trace("connected: "+_connected);
		if (!_connected) return;
		
		try {

			//if (_socketMutex.tryAcquire()) {
				trace("sending");
				_sock.output.writeBytes( bytes, 0, bytes.length );
				//_socketMutex.release();
			//}

			
		}catch ( e : Dynamic ) {
			trace("no send");
			_onErrorCallBack();
		}
		
	}
	
	public function writeUTFString( msg : String ) {
		var bytes:ByteArray = new ByteArray();
		bytes.writeUTFBytes(msg);
		writeBytes(bytes);
	}
	
	
	private function connectInThread() {
		
		try {
			//	try{	
			//		_sock.setBlocking(false);
			//	} catch (e:Dynamic){
			//		trace("failed to set socket nonblocking");
			//	}
			//	Sys.sleep(0.1);
			//	try {
			//		_sock.setFastSend(true);
			//	} catch (e:Dynamic) {
			//		trace("failed to set fastsend on socked");
			//	}
			//	Sys.sleep(0.1);
				if (_socketMutex.tryAcquire()) {
					trace("connecting");
					_sock.connect( new Host( _host ), 44444 );
					_socketMutex.release();
				}
				
				_connected = true;
				Sys.sleep(0.5);
				Thread.create( checkInput );
				_onOpenCallBack();
		} catch (e:Dynamic){
				trace("no connect");
		}
		
	}
	
	private function checkInput() {
		while ( _connected && _sock != null ) {
			if (_socketMutex.tryAcquire()) {
				try {
					var byte:Bytes = _sock.input.read(1);
					_byteCounter++;
					if (byte.toString() == "\n") {
					//if (_byteCounter >= BUF_SIZE) {
						var data:String = _inBuf.getBytes()+"";
						_inBuf = new BytesBuffer();
						_byteCounter = 0;
						_dataCallBack(data);
					} else {
						_inBuf.add(byte);
					}
				}catch ( e : Dynamic ) {
					_connected = false;
					_onErrorCallBack();
				}
				_socketMutex.release();
			}	
		}
	}
}

