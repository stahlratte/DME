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
package jabber.util;

#if nodejs
import js.Node;
#end

/**
	Creates a MD5 of a String.
	Modified version from the haxe std lib to provide raw encoding as well as support for non official compiler targets.
**/
class MD5 {
	
	/**
	*/
	public static inline function encode( s : String, raw : Bool = false ) : String {
		
		#if neko
		var t = make_md5( untyped s.__s );
		return untyped new String( raw ? t : base_encode( t, "0123456789abcdef".__s ) );
		
		#elseif nodejs
		var h = js.Node.crypto.createHash( "md5" );
		h.update( s );
		return h.digest( raw ? NodeC.BINARY : NodeC.HEX );
		
		#elseif php
		return untyped __call__( "md5", s, raw );
		
		#elseif cpp
			//TODO
			//#if hxssl
			//return sys.crypt.MD5.encode( s, raw );
			//#else
			return raw ? new MD5().doEncodeRaw(s) : new MD5().doEncode(s);
			//#end
			
		#else
		return raw ? inst.doEncodeRaw(s) : inst.doEncode(s);
		
		#end
	}
	
	#if neko
	static var base_encode = neko.Lib.load( "std", "base_encode", 2 );
	static var make_md5 = neko.Lib.load( "std", "make_md5", 1 );
	#elseif (php||nodejs)
	#else
	 
	static var inst = new MD5();
	
	function new() {}
	
	function rhex( n : Int ) : String {
		var s = "";
		var hex = "0123456789abcdef";
		for( j in 0...4 ) {
			s += hex.charAt( (n >> (j * 8 + 4)) & 0x0F ) +
				 hex.charAt( (n >> (j * 8)) & 0x0F );
		}
		return s;
	}
	
	function bitOR( a : Int, b : Int ) : Int {
		var lsb = (a & 0x1) | (b & 0x1);
		var msb31 = (a >>> 1) | (b >>> 1);
		return (msb31 << 1) | lsb;
	}

	function bitXOR( a : Int, b : Int ) : Int {
		var lsb = (a & 0x1) ^ (b & 0x1);
		var msb31 = (a >>> 1) ^ (b >>> 1);
		return (msb31 << 1) | lsb;
	}

	function bitAND( a : Int, b : Int ) : Int {
		var lsb = (a & 0x1) & (b & 0x1);
		var msb31 = (a >>> 1) & (b >>> 1);
		return (msb31 << 1) | lsb;
	}

	function addme( x : Int, y : Int ) : Int {
		var lsw = (x & 0xFFFF)+(y & 0xFFFF);
		var msw = (x >> 16)+(y >> 16)+(lsw >> 16);
		return (msw << 16) | (lsw & 0xFFFF);
	}

	function str2blks( s : String ) : Array<Int> {
		var nblk = ((s.length + 8) >> 6) + 1;
		var blks = new Array<Int>();
		for( i in 0...(nblk * 16) ) blks[i] = 0;
		var i = 0;
		while( i < s.length ) {
			blks[i >> 2] |= StringTools.fastCodeAt(s,i) << (((s.length * 8 + i) % 4) * 8);
			i++;
		}
		blks[i >> 2] |= 0x80 << (((s.length * 8 + i) % 4) * 8);
		var l = s.length * 8;
		var k = nblk * 16 - 2;
		blks[k] = (l & 0xFF);
		blks[k] |= ((l >>> 8) & 0xFF) << 8;
		blks[k] |= ((l >>> 16) & 0xFF) << 16;
		blks[k] |= ((l >>> 24) & 0xFF) << 24;
		return blks;
	}

	function rol( num : Int, cnt : Int ) : Int {
		return (num << cnt) | (num >>> (32 - cnt));
	}

	function cmn( q : Int, a : Int, b : Int, x : Int, s : Int, t : Int ) : Int {
		return addme( rol( ( addme( addme(a, q), addme(x, t) ) ), s ), b );
	}

	function ff( a : Int, b : Int, c : Int, d : Int, x : Int, s : Int, t : Int ) : Int {
		return cmn( bitOR(bitAND(b, c), bitAND((~b), d)), a, b, x, s, t );
	}

	function gg( a : Int, b : Int, c : Int, d : Int, x : Int, s : Int, t : Int ) : Int {
		return cmn( bitOR(bitAND(b, d), bitAND(c, (~d))), a, b, x, s, t );
	}

	function hh( a : Int, b : Int, c : Int, d : Int, x : Int, s : Int, t : Int ) : Int {
		return cmn(bitXOR(bitXOR(b, c), d), a, b, x, s, t);
	}

	function ii( a : Int, b : Int, c : Int, d : Int, x : Int, s : Int, t : Int ) : Int {
		return cmn(bitXOR(c, bitOR(b, (~d))), a, b, x, s, t);
	}
	
	function str2bin( inp : String ) : Array<Int> {
		var r = new Array<Int>();
		for( i in 0...r.length )
			r[i] = 0;
		var i2 = 0;
		while( i2 < inp.length * 8 ) {
		    r[i2>>5] |=  ( StringTools.fastCodeAt( inp, Std.int( i2 / 8 ) ) & 0xFF) << ( i2 % 32 );
		    i2 += 8;
		}
		return r;
	}
	
	function bin2str( inp : Array<Int> ) : String {
		var r = "";
		var i = 0;
		while( i < inp.length * 32 ) {
			r += String.fromCharCode( ( inp[i>>5] >>> ( i % 32 ) ) & 0xFF );
			i += 8;
		}
		return r;
	}
	
	function doEncodeRaw( t : String ) : String {
		var len = t.length*8;
		var x = str2bin( t );
		x[len >> 5] |= 0x80 << ((len) % 32);
		x[(((len + 64) >>> 9) << 4) + 14] = len;
		return bin2str( __encode( x ) );
	}
	
	function doEncode( t : String ) : String {
		var t = __encode( str2blks(t) );
		return rhex(t[0])+rhex(t[1])+rhex(t[2])+rhex(t[3]);
	}
	
	function __encode( x : Array<Int> ) : Array<Int> {
		
		var a : Int =  1732584193;
		var b : Int = -271733879;
		var c : Int = -1732584194;
		var d : Int =  271733878;
		
		var i = 0;
		while( i < x.length ) {
			
		    var olda : Int = a;
		    var oldb : Int = b;
		    var oldc : Int = c;
		    var oldd : Int = d;
		    
		    a = ff(a, b, c, d, x[i+ 0], 7 , -680876936);
		    d = ff(d, a, b, c, x[i+ 1], 12, -389564586);
		    c = ff(c, d, a, b, x[i+ 2], 17,  606105819);
		    b = ff(b, c, d, a, x[i+ 3], 22, -1044525330);
		    a = ff(a, b, c, d, x[i+ 4], 7 , -176418897);
		    d = ff(d, a, b, c, x[i+ 5], 12,  1200080426);
		    c = ff(c, d, a, b, x[i+ 6], 17, -1473231341);
		    b = ff(b, c, d, a, x[i+ 7], 22, -45705983);
		    a = ff(a, b, c, d, x[i+ 8], 7 ,  1770035416);
		    d = ff(d, a, b, c, x[i+ 9], 12, -1958414417);
		    c = ff(c, d, a, b, x[i+10], 17, -42063);
		    b = ff(b, c, d, a, x[i+11], 22, -1990404162);
		    a = ff(a, b, c, d, x[i+12], 7 ,  1804603682);
		    d = ff(d, a, b, c, x[i+13], 12, -40341101);
		    c = ff(c, d, a, b, x[i+14], 17, -1502002290);
		    b = ff(b, c, d, a, x[i+15], 22,  1236535329);
		
		    a = gg(a, b, c, d, x[i+ 1], 5 , -165796510);
		    d = gg(d, a, b, c, x[i+ 6], 9 , -1069501632);
		    c = gg(c, d, a, b, x[i+11], 14,  643717713);
		    b = gg(b, c, d, a, x[i+ 0], 20, -373897302);
		    a = gg(a, b, c, d, x[i+ 5], 5 , -701558691);
		    d = gg(d, a, b, c, x[i+10], 9 ,  38016083);
		    c = gg(c, d, a, b, x[i+15], 14, -660478335);
		    b = gg(b, c, d, a, x[i+ 4], 20, -405537848);
		    a = gg(a, b, c, d, x[i+ 9], 5 ,  568446438);
		    d = gg(d, a, b, c, x[i+14], 9 , -1019803690);
		    c = gg(c, d, a, b, x[i+ 3], 14, -187363961);
		    b = gg(b, c, d, a, x[i+ 8], 20,  1163531501);
		    a = gg(a, b, c, d, x[i+13], 5 , -1444681467);
		    d = gg(d, a, b, c, x[i+ 2], 9 , -51403784);
		    c = gg(c, d, a, b, x[i+ 7], 14,  1735328473);
		    b = gg(b, c, d, a, x[i+12], 20, -1926607734);
		
		    a = hh(a, b, c, d, x[i+ 5], 4 , -378558);
		    d = hh(d, a, b, c, x[i+ 8], 11, -2022574463);
		    c = hh(c, d, a, b, x[i+11], 16,  1839030562);
		    b = hh(b, c, d, a, x[i+14], 23, -35309556);
		    a = hh(a, b, c, d, x[i+ 1], 4 , -1530992060);
		    d = hh(d, a, b, c, x[i+ 4], 11,  1272893353);
		    c = hh(c, d, a, b, x[i+ 7], 16, -155497632);
		    b = hh(b, c, d, a, x[i+10], 23, -1094730640);
		    a = hh(a, b, c, d, x[i+13], 4 ,  681279174);
		    d = hh(d, a, b, c, x[i+ 0], 11, -358537222);
		    c = hh(c, d, a, b, x[i+ 3], 16, -722521979);
		    b = hh(b, c, d, a, x[i+ 6], 23,  76029189);
		    a = hh(a, b, c, d, x[i+ 9], 4 , -640364487);
		    d = hh(d, a, b, c, x[i+12], 11, -421815835);
		    c = hh(c, d, a, b, x[i+15], 16,  530742520);
		    b = hh(b, c, d, a, x[i+ 2], 23, -995338651);
		
		    a = ii(a, b, c, d, x[i+ 0], 6 , -198630844);
		    d = ii(d, a, b, c, x[i+ 7], 10,  1126891415);
		    c = ii(c, d, a, b, x[i+14], 15, -1416354905);
		    b = ii(b, c, d, a, x[i+ 5], 21, -57434055);
		    a = ii(a, b, c, d, x[i+12], 6 ,  1700485571);
		    d = ii(d, a, b, c, x[i+ 3], 10, -1894986606);
		    c = ii(c, d, a, b, x[i+10], 15, -1051523);
		    b = ii(b, c, d, a, x[i+ 1], 21, -2054922799);
		    a = ii(a, b, c, d, x[i+ 8], 6 ,  1873313359);
		    d = ii(d, a, b, c, x[i+15], 10, -30611744);
		    c = ii(c, d, a, b, x[i+ 6], 15, -1560198380);
		    b = ii(b, c, d, a, x[i+13], 21,  1309151649);
		    a = ii(a, b, c, d, x[i+ 4], 6 , -145523070);
		    d = ii(d, a, b, c, x[i+11], 10, -1120210379);
		    c = ii(c, d, a, b, x[i+ 2], 15,  718787259);
		    b = ii(b, c, d, a, x[i+ 9], 21, -343485551);
		
		    a = addme( a, olda );
		    b = addme( b, oldb );
		    c = addme( c, oldc );
		    d = addme( d, oldd );
		    
		    i += 16;
		}
		return [a,b,c,d];
	}

	#end

}
