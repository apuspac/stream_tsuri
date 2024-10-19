extends Node

# emote
class EmoteContainer:
	var emote_static: Image
	var emote_gif: SpriteFrames
	var emote_name: String
	
func AddStatic(e: Image, id: String) -> EmoteContainer:
	var ec = EmoteContainer.new()
	ec.emote_static = e
	ec.emote_gif = null
	ec.emote_name = id
	
	return ec

	
func AddAnimated(e: SpriteFrames, id: String) -> EmoteContainer:
	var ec = EmoteContainer.new()
	ec.emote_static = null
	ec.emote_gif = e
	ec.emote_name = id
	
	return ec

