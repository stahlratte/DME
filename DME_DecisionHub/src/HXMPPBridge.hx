package ;

/**
 * ...
 * @author tentakl
 */
class HXMPPBridge
{
	
	private var stream:jabber.client.Stream;
	static var srvr;
	
	static var _main;

	public function new() 
	{
		
	}
	
	public function start(main:Main):Void {
		_main = main;
		if (Main.array == null || Main.array.length != 3) {
			connect("dmehub@dme.dme","127.0.0.1","wtf");
		} else {
			connect(Main.array[0],Main.array[1],Main.array[2]);
		}
	}
	
	function connect(jidStr:String, host:String, pwd:String) {
			trace("connect?");
		
		var jid = new jabber.JID( jidStr );
		var cnx = new jabber.SocketConnection( host );
		stream = new jabber.client.Stream( cnx );
		stream.onOpen = function(){
			trace( 'XMPP stream opened, proceed with authentication ....' );
			var auth = new jabber.client.Authentication( stream, [new jabber.sasl.PlainMechanism()] );
			auth.onSuccess = function() {
				trace( 'Succesfully authenticated as ['+jid+']' );
				new jabber.MessageListener( stream, onMessage ); // listen for incoming messages
				stream.sendPresence(); // send initial presence
				//makeDescision();
				//stream.sendMessage( "dme2@dme.dme", "bla" );
			}
			auth.onFail = function( info : String ) {
				trace( 'Failed to authenticate ['+info+']' );
			}
			auth.start( pwd, 'DecisionMakingEngine' ); // auth
		}
		stream.onClose = function(?e){
			trace( 'XMPP stream closed ['+e+']' );
		}
		stream.open( jid );
	}
	
	function onMessage( m : xmpp.Message ) {
		if( xmpp.Delayed.fromPacket( m ) != null || m.body == null)
			return; // avoid processing of offline sent messages

		var jid = new jabber.JID( m.from );
		//trace("received: " + m.body);
		var msg:Msg = new Msg();
		var parsed:Msg = msg.parse(m.body);
		trace(parsed.msg);
		_main.sendMessageToId(parsed, Std.parseInt(parsed.id));
	}
	
	public function makeDescision(msg:Msg):Void {
		msg.msg = "decide";
		trace("sending");
		msg.delay = 1000;
		stream.sendMessage( "dme1@dme.dme", msg.serialize() );
		msg.delay = 2000;
		stream.sendMessage( "dme2@dme.dme", msg.serialize() );
		msg.delay = 3000;
		stream.sendMessage( "dme3@dme.dme", msg.serialize() );
		msg.delay = 4000;
		stream.sendMessage( "dme4@dme.dme", msg.serialize() );
		msg.delay = 5000;
		stream.sendMessage( "dme5@dme.dme", msg.serialize() );
	}
	
}