package;

import flash.display.Sprite;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.geom.Matrix;
import flash.events.Event;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.Lib;

class Particles extends Sprite {

	static var STAGE_W:Int 				= 800;
	static var STAGE_H:Int 				= 500;
	static var MAX_DISTANCE: Int		= 300;
	static var NUM_PARTICLES:Int			= 500;
	private static var PARTICLE_MAX_RADIUS:Int 	= 5;
	var _particles:Array<Particle>;
	private var _canvas:BitmapData;
	public var _canvasContainer:Bitmap;
	static var CANVAS_CLEAR_COLOR:Int 	= 0x00000000;
	
	public var point:Point;

	public function new () {
		super ();
		point = new Point(STAGE_W*0.5,STAGE_H*0.5);
	}

	public function init():Void {
		_particles = new Array<Particle>();
		generateParticles();
		_canvas = new BitmapData(STAGE_W,STAGE_H,true,CANVAS_CLEAR_COLOR);
		_canvasContainer = new Bitmap(_canvas);
		addChild(_canvasContainer);
	}

	private function generateParticles():Void {
		var particle:Particle;
		while(_particles.length < NUM_PARTICLES){
			particle = new Particle();
			particle.radius = Math.random()*PARTICLE_MAX_RADIUS;
			var r:Int = cast(particle.radius/PARTICLE_MAX_RADIUS*0xFF);
			var b:Int = cast(particle.radius/PARTICLE_MAX_RADIUS*0xFF);
			var g:Int = cast(particle.radius/PARTICLE_MAX_RADIUS*0xFF);
			// and combining them to one color
			particle.color = r << g << 8 | b ;
			particle.speedX = (Math.random() - 0.5) * particle.radius * 1;
			particle.speedY = (Math.random()-0.5) * particle.radius * 1;
			particle.draw();
			particle.startPoint.x = point.x;
			particle.startPoint.y = point.y;
			particle.x = point.x;
			particle.y = point.y;
			_particles.push(
				particle
			);
		}

		_particles.sort(
			function(p1:Particle,p2:Particle):Int {
				if(p1.radius==p2.radius)
					return 0;
				return p1.radius>p2.radius?1:-1;
			}
		);

	}

	public function doStuff():Void {
		if (alpha == 0) return;
		_canvas.fillRect(_canvas.rect,CANVAS_CLEAR_COLOR);
		var matrix:Matrix = new Matrix();
		var particle:Particle;
		for(i in 0...NUM_PARTICLES){
			particle = _particles[i];
			particle.x += particle.speedX;
			particle.y += particle.speedY;
			particle.speedY += 0.05;
			var dst:Float = dist(particle.startPoint.x, particle.x, particle.startPoint.y, particle.y);
			//if (dst != 0) trace(dst);
			//particle.colorTrans.alphaMultiplier =Math.max(0,1-(Math.max(Math.abs(particle.x-STAGE_W*0.5),Math.abs(particle.y-STAGE_H*0.5))/STAGE_W*3));
			particle.colorTrans.alphaMultiplier = Math.max(0,1-dst/MAX_DISTANCE);
			if (dst > MAX_DISTANCE || particle.x < 0 || particle.y < 0 || particle.x > STAGE_W || particle.y > STAGE_H) {
				particle.startPoint.x = point.x;
				particle.startPoint.y = point.y;
				particle.x = point.x;
				particle.y = point.y;
				particle.speedX = (Math.random() - 0.5) * particle.radius * 1;
				particle.speedY = (Math.random()-0.5) * particle.radius * 1;
			}
			matrix.tx = particle.x;
			matrix.ty = particle.y;
			_canvas.draw(particle, matrix);
			_canvas.colorTransform(new Rectangle(particle.x-particle.radius,particle.y-particle.radius,particle.radius*2+2,particle.radius*2+2),particle.colorTrans);
		}
	}
	
	function dist(x1:Float, x2:Float,  y1:Float, y2:Float): Float {
		var dx:Float = x1-x2;
		var dy:Float = y1-y2;
		return Math.sqrt(dx * dx + dy * dy);
	}

}