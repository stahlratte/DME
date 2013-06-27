DecisonMakingEngine for OMGWTF2

you will need haxe 3.0 openfl and various libraries to compile.
the haxe compiler will tell you more.

The DME consists of 5 Deciders a DecisonHub and a Client to connect to the hub.
The Hub communicates via xmpp to the deciders which generate a random YES/NO response.
The Hub sends those back to the client over a socket connection.
For svety reasons there is an unhackable Serialization protocoll implementation and possibly you could use ssl for connecting over xmpp, but the serialization should be enough.