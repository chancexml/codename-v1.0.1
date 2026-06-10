package mobile.controls;

#if mobile
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.group.FlxSpriteGroup;
import flixel.input.keyboard.FlxKey;
import flixel.input.touch.FlxTouch;

typedef ExtraButtonInfo = {
    var justPressed:Bool;
    var justReleased:Bool;
    var isPressed:Bool;
    var sprite:FlxSprite;
    var activeTouchId:Int;
}

class ExtraButtons extends FlxSpriteGroup {
    public var B_W:Int = 100;
    public var B_H:Int = 100;

    public var btnBack:ExtraButtonInfo;
    public var btnM:ExtraButtonInfo;
    public var btnE:ExtraButtonInfo;

    public var extraCam:FlxCamera;

    public function new(buttonMode:String) {
        super();

        btnBack = { justPressed: false, justReleased: false, isPressed: false, sprite: null, activeTouchId: -1 };
        btnM = { justPressed: false, justReleased: false, isPressed: false, sprite: null, activeTouchId: -1 };
        btnE = { justPressed: false, justReleased: false, isPressed: false, sprite: null, activeTouchId: -1 };
        
        extraCam = new FlxCamera();
        extraCam.bgColor = 0x00000000;
        extraCam.scroll.set(0, 0);
        extraCam.follow(null);
        FlxG.cameras.add(extraCam, false);
        this.cameras = [extraCam];
        
        initButtons(buttonMode);
    }

    public function initButtons(buttonMode:String) {
        switch (buttonMode) {
            case "E":
                btnE.sprite = createImageButton(50, 475, "menus/EButton");
                add(btnE.sprite);

            case "E_M":
                btnE.sprite = createImageButton(50, 475, "menus/EButton");
                add(btnE.sprite);
                btnM.sprite = createImageButton(1000, 475, "menus/MButton");
                add(btnM.sprite);

            case "M":
                btnM.sprite = createImageButton(1000, 475, "menus/MButton");
                add(btnM.sprite);

            case "Back":
                btnBack.sprite = createSparrowButton(1000, 475, "menus/backButton", "back");
                add(btnBack.sprite);
        }
    }

    private function createSparrowButton(x:Float, y:Float, path:String, animName:String):FlxSprite {
        var btn = new FlxSprite(x, y);
        var atlas = Paths.getSparrowAtlas(path);
        if (atlas != null) {
            btn.frames = atlas;
            btn.animation.addByPrefix("idle", animName + "idle", 24, false);
            btn.animation.addByPrefix("click", animName + "click", 24, false);
            btn.animation.play("idle");
        } else {
            btn.makeGraphic(B_W, B_H, 0xFFFFFFFF);
        }
        btn.scale.set(0.8, 0.8);
        btn.updateHitbox();
        return btn;
    }

    private function createImageButton(x:Float, y:Float, path:String):FlxSprite {
        var btn = new FlxSprite(x, y);
        var img = Paths.image(path);
        if (img != null) {
            btn.loadGraphic(img);
        } else {
            btn.makeGraphic(B_W, B_H, 0xFFFFFFFF);
        }
        btn.scale.set(0.8, 0.8);
        btn.updateHitbox();
        return btn;
    }

    override public function update(elapsed:Float) {
        if (extraCam != null && FlxG.cameras.list != null) {
            var idx = FlxG.cameras.list.indexOf(extraCam);
            if (idx != -1 && idx != FlxG.cameras.list.length - 1) {
                FlxG.cameras.remove(extraCam, false);
                FlxG.cameras.add(extraCam, false);
            }
        }

        super.update(elapsed);

        updateButton(btnBack);
        updateButton(btnM);
        updateButton(btnE);

        handleButtonLogic(btnBack, FlxKey.ESCAPE);
        handleButtonLogic(btnM, FlxKey.TAB);
        handleButtonLogic(btnE, FlxKey.SEVEN);
    }

    private function handleButtonLogic(btn:ExtraButtonInfo, key:FlxKey) {
        if (btn.sprite == null) return;

        if (btn.justPressed) {
            if (btn.sprite.animation != null && btn.sprite.animation.getByName("click") != null) {
                btn.sprite.animation.play("click", true);
            }
            FlxG.keys.handleAction(key, true);
        } else if (btn.justReleased) {
            FlxG.keys.handleAction(key, false);
        }

        if (btn.sprite.animation != null && btn.sprite.animation.finished && btn.sprite.animation.name == "click") {
            btn.sprite.animation.play("idle");
        }
    }

    private function updateButton(btn:ExtraButtonInfo) {
        if (btn.sprite == null || !btn.sprite.visible || !btn.sprite.active) {
            if (btn.isPressed) {
                btn.justReleased = true;
                btn.isPressed = false;
                btn.activeTouchId = -1;
            } else {
                btn.justPressed = false;
                btn.justReleased = false;
            }
            return;
        }

        btn.justPressed = false;
        btn.justReleased = false;

        var touchFound = false;

        if (FlxG.touches != null) {
            for (touch in FlxG.touches.list) {
                if (touch.overlaps(btn.sprite, extraCam)) {
                    touchFound = true;
                    
                    if (!btn.isPressed && touch.justPressed) {
                        btn.justPressed = true;
                        btn.isPressed = true;
                        btn.activeTouchId = touch.touchPointID;
                    }
                }
            }

            if (btn.isPressed && btn.activeTouchId != -1) {
                var trackedTouch:FlxTouch = null;
                for (touch in FlxG.touches.list) {
                    if (touch.touchPointID == btn.activeTouchId) {
                        trackedTouch = touch;
                        break;
                    }
                }

                if (trackedTouch == null || trackedTouch.justReleased || !trackedTouch.overlaps(btn.sprite, extraCam)) {
                    btn.justReleased = true;
                    btn.isPressed = false;
                    btn.activeTouchId = -1;
                }
            }
        }

        if (!touchFound && FlxG.mouse != null && FlxG.mouse.visible) {
            if (FlxG.mouse.overlaps(btn.sprite, extraCam)) {
                if (!btn.isPressed && FlxG.mouse.justPressed) {
                    btn.justPressed = true;
                    btn.isPressed = true;
                }
            }

            if (btn.isPressed && btn.activeTouchId == -1) {
                if (FlxG.mouse.justReleased || !FlxG.mouse.overlaps(btn.sprite, extraCam)) {
                    btn.justReleased = true;
                    btn.isPressed = false;
                }
            }
        }
    }

    override public function destroy() {
        if (FlxG.cameras != null && extraCam != null) {
            FlxG.cameras.remove(extraCam);
        }
        super.destroy();
    }
}
#end
