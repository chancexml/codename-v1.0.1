package mobile.controls;

#if mobile
import flixel.FlxG;
import flixel.FlxSprite;
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
    public var btnB:ExtraButtonInfo;

    public function new(buttonMode:String) {
        super();

        btnBack = { justPressed: false, justReleased: false, sprite: null };
        btnM = { justPressed: false, justReleased: false, sprite: null };
        btnE = { justPressed: false, justReleased: false, sprite: null };
        btnB = { justPressed: false, justReleased: false, sprite: null };

        initButtons(buttonMode);
    }

    public function initButtons(buttonMode:String) {
        switch (buttonMode) {
            case "E":
                btnE.sprite = createSparrowButton(50, 475, "menus/EButton", "E");
                add(btnE.sprite);

            case "B":
                btnB.sprite = createButton(0, FlxG.height - 135, B_W, B_H, "down");
                add(btnB.sprite);

            case "E_B":
                btnE.sprite = createSparrowButton(50, 475, "menus/EButton", "E");
                add(btnE.sprite);
                btnB.sprite = createButton(0, FlxG.height - 135, B_W, B_H, "down");
                add(btnB.sprite);

            case "M":
                btnM.sprite = createSparrowButton(1000, 475, "menus/MButton", "M");
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

    override public function update(elapsed:Float) {
        super.update(elapsed);

        updateButton(btnBack);
        updateButton(btnM);
        updateButton(btnE);
        updateButton(btnB);

        if (btnBack.sprite != null) {
            if (btnBack.justPressed) {
                btnBack.sprite.animation.play("click", true);
                FlxG.keys.handleAction(FlxKey.ESCAPE, true);
            } else if (btnBack.justReleased) {
                FlxG.keys.handleAction(FlxKey.ESCAPE, false);
            }
            if (btnBack.sprite.animation.finished && btnBack.sprite.animation.name == "click") btnBack.sprite.animation.play("idle");
        }

        if (btnM.sprite != null) {
            if (btnM.justPressed) {
                btnM.sprite.animation.play("click", true);
                FlxG.keys.handleAction(FlxKey.TAB, true);
            } else if (btnM.justReleased) {
                FlxG.keys.handleAction(FlxKey.TAB, false);
            }
            if (btnM.sprite.animation.finished && btnM.sprite.animation.name == "click") btnM.sprite.animation.play("idle");
        }

        if (btnE.sprite != null) {
            if (btnE.justPressed) {
                btnE.sprite.animation.play("click", true);
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
            if (touch.overlaps(btn.sprite)) {
                if (touch.justPressed) btn.justPressed = true;
                if (touch.justReleased) btn.justReleased = true;
            }
        }
        if (FlxG.mouse.overlaps(btn.sprite)) {
            if (FlxG.mouse.justPressed) btn.justPressed = true;
            if (FlxG.mouse.justReleased) btn.justReleased = true;
        }
    }
}
#end
