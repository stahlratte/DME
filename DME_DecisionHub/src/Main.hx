package ;

import neko.Lib;
import neko.vm.Mutex;
import sys.net.Socket;
import neko.net.ThreadServer;
import haxe.io.Bytes;

/**
 * ...
 * @author tentakl
 */

typedef Client = {
  var id : Int;
}

typedef Message = {
  var str : String;
}

class Main extends ThreadServer<Client, Message>{
	
	private var hbridge:HXMPPBridge;
	private var mtx:Mutex;

	private var socks: Array<Socket>;
	
	private var stream:jabber.client.Stream;
	static var srvr;
	
	private var _currentSocket:Socket;
	
	public static var array:Array<String>;
	
	
	public function new() {
		super();
		//array = new Array();
		socks = new Array<Socket>();
		for( i in 0...100 ) {
         socks.push(null);
		}
		mtx = new Mutex();
		//Sys.sleep(0.2);
		hbridge = new HXMPPBridge();
		//hbridge.start();
		
		neko.vm.Thread.create(hxb);
	}
	
	public function hxb():Void {
		//mtx.acquire();
		trace("start");
		hbridge.start(this);
		//mtx.release();
	}
	
	
	override function run( host : String, port : Int ) : Void {
		super.run(host, port);
	}
	 
  // create a Client
  override function clientConnected( s : Socket ) : Client {
    var num = Std.random(100);
	socks[num] = s;
	_currentSocket = socks[num];
	_currentSocket.write("hello socket!\n");
    Lib.println("client " + num + " is " + s.peer());
    return { id: num };
  }

  override function clientDisconnected( c : Client ) {
    Lib.println("client " + Std.string(c.id) + " disconnected");
  }

  override function readClientMessage(c:Client, buf:Bytes, pos:Int, len:Int) {
	  trace("read");
	var msg:String = buf.readString(pos, len);
    return {msg: {str: msg}, bytes: len};
  }

	override function clientMessage( c : Client, msg : Message ) {
	trace("should send to: "+c.id+" - "+msg.str);
		
	var mes:Msg = new Msg();
	var parsed:Msg = mes.parse(msg.str);
	mes.id = Std.string(c.id);
    Lib.println(c.id + " sent: " + msg.str);
	makeDes(mes);
	
	}
	
	public function sendMessageToId(msg:Msg, id:Int):Void {
		trace(msg.msg);
		var bytes:Bytes = Bytes.ofString(msg.serialize());
		_currentSocket.write("there is data!\n");
		_currentSocket.write(msg.serialize()+"\n");
		//s.output.writeBytes(bytes, 0, bytes.length);
	}
  
	function makeDes(ms:Msg):Void {
	 // if (mtx.tryAcquire()) {
		  hbridge.makeDescision(ms);
		//  mtx.release();
		//}
	}

  public static function main()
  {
	  array = Sys.args();
		
      var server = new Main();
      server.run("localhost", 44444);
	 
  }





	
}