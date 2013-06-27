package ;

import flash.display.Shape;
import flash.display.Graphics;
import flash.geom.ColorTransform;
import flash.geom.Point;

class Particle extends Shape {

	public var color:Int;
	public var radius:Float;
	public var speedX:Float;
	public var speedY:Float;
	public var colorTrans:ColorTransform;
	public var startPoint:Point;

	public function new () {
		super();
		color = 0;
		radius = 1.0;
		speedX = 0.0;
		speedY = 0.0;
		alpha = 0.5;
		startPoint = new Point();
		colorTrans = new ColorTransform();
	}

	// draws the particle on the given target Graphics
	// or on the own graphics
	public function draw(?target:Graphics):Void
	{

		if(target==null || target==graphics){
			target = graphics;
			target.clear();
		}

		target.beginFill(color);
		target.drawCircle(x,y,radius);
		target.endFill();
	}
}