/*
 * Copyright (c) 2012, disktree.net
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
package jabber.jingle.io;

#if flash

import flash.events.NetStatusEvent;
import flash.net.NetStream;

@:require(flash10) class RTMFPOutput extends RTMFPTransport {
	
	/**
		Determines if the cirrus development key should get sent to the occupant in the candidate URL.
	*/
	public var send_cirrus_key : Bool;
	
	public function new( url : String,
						 send_cirrus_key : Bool = false ) {
		super( url );
		this.send_cirrus_key = send_cirrus_key;
	}
	
	public override function toXml() : Xml {
		var x = Xml.createElement( "candidate" );
		x.set( "id", id );
		if( send_cirrus_key )
			x.set( "url", url );
		else {
			RTMFPTransport.EREG_URL.match( url );
			x.set( "url", RTMFPTransport.EREG_URL.matched(1)+
						  RTMFPTransport.EREG_URL.matched(2) );
		}
		return x;
	}
	
	override function netConnectionHandler( e : NetStatusEvent ) {
		#if jabber_debug trace( e.info.code, 'debug' ); #end
		switch( e.info.code ) {
		case "NetConnection.Connect.Success" :
			id = nc.nearID;
			__onConnect();
			return;
		}
		super.netConnectionHandler( e );
	}
	
}

#end // flash
