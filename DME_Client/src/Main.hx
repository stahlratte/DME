package ;

import flash.display.Bitmap;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.Lib;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.utils.ByteArray;
import haxe.Json;
import openfl.Assets;
import motion.Actuate;
import motion.easing.Quad;

/**
 * ...
 * @author tentakl
 */

class Main extends Sprite 
{
	var inited:Bool;
	var sock:DecisionSocket;
	
	var _received:Int;
	var _targetAngle:Float;
	var _needleRot:Float;
	var _damping:Float;
	var _pointer:flash.display.Sprite;
	
	private var _button:Sprite;
	var _pressed:Bitmap;
	
	var _facts:Array<String>;
	var _factInd:Int;
	
	var _sign:Sprite;
	var _factField:TextField;
	var _particles:Particles;
	
	
	function resize(e) 
	{
		if (!inited) init();
	}
	
	function init() 
	{
		if (inited) return;
		inited = true;
		
		var bear:Bitmap = new Bitmap (Assets.getBitmapData ("img/businessbear.png"));
		addChild(bear);
		_pointer = new Sprite();
		_particles = new Particles();
		
			var p:Bitmap = new Bitmap (Assets.getBitmapData ("img/pointer.png"));
			_pointer.addChild(p);
			addChild(_pointer);
			addChild(_particles);
			_particles.point.x = 400;
			_particles.point.y = 250;
			p.x = -105; p.y = -153;
			_pointer.x = 286;
			_pointer.y = 221;
		_particles.point = new Point(457, 96);
		_particles.init();
		_button = new Sprite();
		var but:Bitmap = new Bitmap (Assets.getBitmapData ("img/decidebutton.png"));
		_button.addChild(but);
		addChild(_button);
		_pressed = new Bitmap (Assets.getBitmapData ("img/decidebuttondown.png"));
		addChild(_pressed);
		_pressed.x = _button.x = 500;
		_pressed.y = _button.y = 300;
		_pressed.alpha = 0.0;
		_button.alpha = 1.0;
		
		_button.addEventListener(MouseEvent.MOUSE_DOWN, down);
		_received = 5;
		_targetAngle = 0;
		_damping  = 0.90;
		
		_sign = new Sprite();
		var s:Bitmap = new Bitmap (Assets.getBitmapData ("img/sign.png"));
		_sign.addChild(s);
		_factField = new TextField();
		var font = Assets.getFont ("font/font.ttf");
		var format = new TextFormat (font.fontName, 20, 0x000000);
		_factField.defaultTextFormat = format;
		_factField.selectable = false;
		_factField.embedFonts = true;
		_factField.multiline = true;
		_factField.wordWrap  = true;
		_factField.x = 49;
		_factField.y = 69;
		_factField.width = 331;
		_factField.height = 224;
		//_factField.border = true;
		//_factField.borderColor = 0xff0000;
		//_factField.textColor = 0xff0000;
		_sign.addChild(_factField);
		_sign.x = 185;
		_sign.y = 500;
		_sign.alpha = 1.0;
		_sign.scaleY = _sign.scaleX = 0.8;
		
		addChild(_sign);
		
		
		sock = new DecisionSocket(data, open, close, error);
		//Sys.sleep(2);
		sock.connect("localhost", 44444);
		
		
		getFacts();

_particles.alpha = 0;
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, kdHandler);
		addEventListener(Event.ENTER_FRAME, onEnterFrame);
	}
	
	private function getFacts():Void {
		_facts = new Array<String>();
		_factInd = 0;
		var req = new haxe.Http("http://mentalfloss.com/api/1.0/views/amazing_facts.json");
		req.onData = function( data  : String ) {
				trace(data);
				var position:Int = 0;
				var char:String;
				var startfindme:Array<String> = ["\"", "n", "i", "d", "\"", ":", "\"", "<", "p", ">"];
				var delete:Array<String> = ["<em>", "</em>", "\n","\\"];
				var startfindmeind:Int = 0;
				var startPos:Int = 0;
				var lookingforend:Bool = false;
				while(position < data.length) {
					char = data.substr(position, 1);
					if (char == startfindme[startfindmeind]) {
						if (startfindmeind == startfindme.length-1) {
							startPos = position;
							lookingforend = true;
						} else {
							startfindmeind++;
						}
					} else {
						startfindmeind = 0;
					}
					
					if (lookingforend && data.substr(position, 4) == "</p>") {
						lookingforend = false;
						var str:String = data.substr(startPos + 1, position - startPos - 1);
						for (del in delete) {
							StringTools.replace(str, del, "");
						}
						_facts.push(str);
					}
					position++;
				}

			}
		req.request(false);
	}
	
	private function showFact():Void {
		if (_facts != null && _factInd < _facts.length) {
			Actuate.tween (_sign, 0.5, { y: 230 }, false).ease (Quad.easeOut);
			_factField.text = "A random fact to help you make decisions on your own:\n\n" + _facts[_factInd];
			Actuate.timer (15).onComplete (hideFact);
			trace(_facts[_factInd]);
			_factInd++;
		} else {
			getFacts();
			showFact();
		}
	}
	
	private function hideFact():Void {
		Actuate.tween (_sign, 0.5, { y: 500 }, false).ease (Quad.easeOut);
	}
	
	private function down(e:Event):Void {
		if (_received >= 5) {
			Assets.getSound ("music/music.ogg").play();
			Actuate.reset();
			Actuate.tween (_particles, 1.5, { alpha: 1.0 }, false).ease (Quad.easeOut);
			if (_sign.y < 500) {
				hideFact();
				Actuate.timer (0.5).onComplete (showFact);
			} else {
				showFact();
			}
			
			_particles.visible = true;
			_pressed.alpha = 1.0;
		_button.alpha = 0.0;
			_received = 0;
			_targetAngle = 0;
				var msg:Msg = new Msg();
		msg.msg = "decide";

		var bytes:ByteArray = new ByteArray();
			bytes.writeUTFBytes(msg.serialize());
		sock.writeUTFString(msg.serialize());
		}
	}
	
	private function onEnterFrame(event:Event):Void {
		_particles.point = _pointer.localToGlobal(new Point(178, -133) ) ;
			_needleRot = _needleRot * _damping + _targetAngle * (1-_damping);
			_particles.doStuff();
			if (_needleRot >= _targetAngle-0.05 && _needleRot <= _targetAngle + 0.05) {
				if (_received >= 5) {
					//_particles.visible = false;
					Actuate.tween (_particles, 1.5, { alpha: 0.0 }, false).ease (Quad.easeOut);
				}
				return;
			}
			
			
			
			var rotation:Float = _needleRot;
			_pointer.rotation = rotation;
			//trace(rotation);

	}
	
	public function close():Void {
		trace("closed");
	}
	
	public function open():Void {
		trace("opened");
	}

	public function data(instring:String):Void {
		
		var keep:String = new String(instring);
		trace(instring);
		
		if (StringTools.startsWith(keep, "INSERT")) {
			_received++;
			trace(_received + " : " + keep);
			if (keep.indexOf("YES") > -1) {
				_targetAngle += 10;
			} else {
				_targetAngle -= 10;
			}
			if (_received >= 5) {
				_pressed.alpha = 0.0;
				_button.alpha = 1.0;
				// _particles.visible = false;
			}
		} else {
			trace(keep);
		}
	}
	
	public function error(string:String):Void {
		trace(string);
	}

	public function kdHandler(e:KeyboardEvent):Void {
		return;
		if (_received >= 5) {
		_received = 0;
		_targetAngle = 0;
			trace(e.keyCode);
				var msg:Msg = new Msg();
		msg.msg = "decide";

		var bytes:ByteArray = new ByteArray();
			bytes.writeUTFBytes(msg.serialize());
		sock.writeUTFString(msg.serialize());
		}
		
	}
		
	public function new() 
	{
		super();	
		addEventListener(Event.ADDED_TO_STAGE, added);
	}

	function added(e) 
	{
		removeEventListener(Event.ADDED_TO_STAGE, added);
		stage.addEventListener(Event.RESIZE, resize);
		#if ios
		haxe.Timer.delay(init, 100); // iOS 6
		#else
		init();
		#end
	}
	
	public static function main() 
	{
		// static entry point
		Lib.current.stage.align = flash.display.StageAlign.TOP_LEFT;
		Lib.current.stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
		Lib.current.addChild(new Main());
	}
}
