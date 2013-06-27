package ;
import haxe.Http;
import neko.vm.Mutex;

//import cpp.Lib;


/**
 * ...
 * @author tentakl
 */

class Main  {
	
	static var stream;
	
	static var counter:Int;
	static var doingStuff:Bool;
	static var countermutex:neko.vm.Mutex;
	
	static function main() {
		countermutex = new Mutex();
		var array:Array<String> = Sys.args();
		if (array == null || array.length != 3) {
			connect("dme1@dme.dme","127.0.0.1","wtf");
		} else {
			connect(array[0],array[1],array[2]);
		}
		
	}
	
	static function onMessage( m : xmpp.Message ) {
		if( xmpp.Delayed.fromPacket( m ) != null || m.body == null)
			return; // avoid processing of offline sent messages

		var jid = new jabber.JID( m.from );
		trace("received: " + m.body +" from: "+m.from);
		
		var msg:Msg = new Msg();
		var parsed:Msg = msg.parse(m.body);
		trace(parsed.msg);
		
		var start:Float = Date.now().getTime();

		doingStuff = true;
		counter = 0;
		neko.vm.Thread.create(count);
		var req = new haxe.Http("http://www.microsoft.com/");
		req.onData = function( data  : String ) {
			
				doingStuff = false;
				Sys.sleep(parsed.delay/1000);
				trace(counter);
				var delta = Date.now().getTime() - start;
				trace("delta: " + delta);
				// precision is 1 second on windows so adding some more random stuff
				var end = Math.random() * 100;
				var i = 0;
				while ( i < end ) {
					delta++;
					i++;
				}
				delta *= data.length * Math.random();
				trace("new delta because of presicion issues: " + delta);
				var deceision:String = counter % 2 == 0?"NO":"YES";
				var smsg:Msg = new Msg();
				smsg.msg = deceision;
				smsg.delay = 0;
				stream.sendMessage( m.from, smsg.serialize() ); // send response
			}
		req.request(false);
	}
	
	static function count():Void { countermutex .acquire();
		while (doingStuff) {
			counter++;
		}
		countermutex.release();
	}
	
	static function connect(jidStr:String, host:String, pwd:String) {
		//var jid = new jabber.JID( jid );
		var cnx = new jabber.SocketConnection( host );
		stream = new jabber.client.Stream( cnx );
		stream.onOpen = function(){
			trace( 'XMPP stream opened, proceed with authentication ....' );
			var auth = new jabber.client.Authentication( stream, [new jabber.sasl.PlainMechanism()] );
			auth.onSuccess = function() {
				trace( 'Succesfully authenticated as ['+jidStr+']' );
				new jabber.MessageListener( stream, onMessage ); // listen for incoming messages
				stream.sendPresence(); // send initial presence
			}
			auth.onFail = function( info : String ) {
				trace( 'Failed to authenticate ['+info+']' );
			}
			auth.start( pwd, 'DecisionMakingEngine' ); // auth
		}
		stream.onClose = function(?e){
			trace( 'XMPP stream closed ['+e+']' );
		}
		stream.open( new jabber.JID( jidStr ) );
	}
	
}