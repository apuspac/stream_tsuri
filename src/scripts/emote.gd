extends Node

# emote
class EmoteContainer:
	var emote_static: Image
	var emote_gif: SpriteFrames
	
func AddStatic(e: Image) -> EmoteContainer:
	var ec = EmoteContainer.new()
	ec.emote_static = e
	ec.emote_gif = null
	
	return ec

	
func AddAnimated(e: SpriteFrames) -> EmoteContainer:
	var ec = EmoteContainer.new()
	ec.emote_static = null
	ec.emote_gif = e
	
	return ec
