package ;

/**
 * ...
 * @author tentakl
 */
class Msg
{
	
	public var id:String;
	public var msg:String;
	public var delay:Int;

	public function new() {
		
	}
	
	
	public function serialize():String {
		return "INSERT INTO Object (msg,delay) VALUES ('" + this.msg + "'," + this.delay + ")";
	}
	
	public function parse(msg:String):Msg {
				var cnx = sys.db.Sqlite.open(":memory:");
		cnx.request("
        CREATE TABLE IF NOT EXISTS Object (
            id INTEGER PRIMARY KEY AUTOINCREMENT, 
            msg TEXT, 
            delay INTEGER
        )
		");
		cnx.request(msg);
var rset = cnx.request("SELECT * FROM Object");
trace("Found "+rset.length+" Objects");
for( row in rset ) {
    //neko.Lib.print("Object " + row.msg + " hs delay of " + row.delay);
		var m:Msg = new Msg();
	m.id = row.id;
	m.msg = row.msg;
	m.delay = Std.parseInt(row.delay);
	cnx.close();
	return m;
}
        return new Msg();
		
	}
	
}