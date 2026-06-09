package mobile.controls;

#if mobile
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.group.FlxSpriteGroup;
import flixel.input.keyboard.FlxKey;

typedef ExtraButtonInfo = {
    var justPressed:Bool;
    var justReleased:Bool;
    var sprite:FlxSprite;
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

        btnBack = { justPressed: false, justReleased: false, sprite: null };
        btnM = { justPressed: false, justReleased: false, sprite: null };
        btnE = { justPressed: false, justReleased: false, sprite: null };
        
        extraCam = new FlxCamera();
        extraCam.bgColor = 0x00000000;
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
        btn.frames = Paths.getSparrowAtlas(path);
        btn.animation.addByPrefix("idle", animName + "0000", 24, false);
        btn.animation.addByPrefix("click", animName, 24, false);
        btn.animation.play("idle");
        btn.scale.set(0.8, 0.8);
        btn.updateHitbox();
        return btn;
    }

    private function createButton(x:Float, y:Float, w:Int, h:Int, name:String):FlxSprite {
        var btn = new FlxSprite(x, y).makeGraphic(w, h, 0xFFFFFFFF);
        btn.scale.set(0.8, 0.8);
        btn.updateHitbox();
        return btn;
    }

    private function createImageButton(x:Float, y:Float, path:String):FlxSprite {
        var btn = new FlxSprite(x, y);
        btn.loadGraphic(Paths.image(path));
        btn.scale.set(0.8, 0.8);
        btn.updateHitbox();
        return btn;
    }

    override public function update(elapsed:Float) {
        super.update(elapsed);

        updateButton(btnBack);
        updateButton(btnM);
        updateButton(btnE);

        if (btnBack.sprite != null) {
            if (btnBack.justPressed) {
                if (btnBack.sprite.animation.getByName("click") != null) btnBack.sprite.animation.play("click", true);
                FlxG.keys.handleAction(FlxKey.ESCAPE, true);
            } else if (btnBack.justReleased) {
                FlxG.keys.handleAction(FlxKey.ESCAPE, false);
            }
            if (btnBack.sprite.animation.finished && btnBack.sprite.animation.name == "click") btnBack.sprite.animation.play("idle");
        }

        if (btnM.sprite != null) {
            if (btnM.justPressed) {
                if (btnM.sprite.animation.getByName("click") != null) btnM.sprite.animation.play("click", true);
                FlxG.keys.handleAction(FlxKey.TAB, true);
            } else if (btnM.justReleased) {
                FlxG.keys.handleAction(FlxKey.TAB, false);
            }
            if (btnM.sprite.animation.finished && btnM.sprite.animation.name == "click") btnM.sprite.animation.play("idle");
        }

        if (btnE.sprite != null) {
            if (btnE.justPressed) {
                if (btnE.sprite.animation.getByName("click") != null) btnE.sprite.animation.play("click", true);
                FlxG.keys.handleAction(FlxKey.SEVEN, true);
            } else if (btnE.justReleased) {
                FlxG.keys.handleAction(FlxKey.SEVEN, false);
            }
            if (btnE.sprite.animation.finished && btnE.sprite.animation.name == "click") btnE.sprite.animation.play("idle");
        }
    }

    private function updateButton(btn:ExtraButtonInfo) {
        if (btn.sprite == null) return;
        btn.justPressed = false;
        btn.justReleased = false;
        for (touch in FlxG.touches.list) {
            if (touch.overlaps(btn.sprite, extraCam)) {
                if (touch.justPressed) btn.justPressed = true;
                if (touch.justReleased) btn.justReleased = true;
            }
        }
        if (FlxG.mouse.overlaps(btn.sprite, extraCam)) {
            if (FlxG.mouse.justPressed) btn.justPressed = true;
            if (FlxG.mouse.justReleased) btn.justReleased = true;
        }
    }

    override public function destroy() {
        if (extraCam != null) {
            FlxG.cameras.remove(extraCam);
        }
        super.destroy();
    }
}
#end
