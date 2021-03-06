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
package xmpp.file;

class ByteStreamHost {
	
	public var jid : String;
	public var host : String;
	public var port : Null<Int>;
	public var zeroconf : String;
	
	public function new( jid : String , host : String,
						 ?port : Null<Int>, ?zeroconf : String ) {
		this.jid = jid;
		this.host = host;
		this.port = port;
		this.zeroconf = zeroconf;
	}
	
	public function toXml() : Xml {
		var x = Xml.createElement( "streamhost" );
		x.set( "jid", jid );
		x.set( "host", host );
		if( port != null ) x.set( "port", Std.string( port ) );
		if( zeroconf != null ) x.set( "zeroconf", zeroconf );
		return x;
	}
	
	public static function parse( x : Xml ) : ByteStreamHost {
		return new ByteStreamHost( x.get( "jid" ),
								   x.get( "host" ),
								   ( x.exists( "port" ) ) ? Std.parseInt( x.get( "port" ) ) : null,
								   x.get( "zeroconf" ) );
	}
	
}
