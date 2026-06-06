package funkin.options.type;

/**
 * Option type that allows stepping through a number.
**/
class NumOption extends TextOption {
	public var changedCallback:Float->Void;

	public var min:Float;
	public var max:Float;
	public var step:Float;

	public var currentValue(default, set):Float;

	public var parent:Dynamic;
	public var optionName:String;

	var __colon:Alphabet;
	var __number:Alphabet;
	var __left:Alphabet;
	var __right:Alphabet;

	var holdTime:Float = 0;

	function set_currentValue(v:Float):Float {
		currentValue = v;

		if (__number != null) {
			var textValue:String =
				(v % 1 == 0) ? '${Std.int(v)}' : '$v';

			__number.text = textValue;
		}

		updateArrowPositions();

		return currentValue;
	}

	function updateArrowPositions() {
		if (__colon == null || __number == null || __left == null || __right == null)
			return;

		var spacing:Float = 10;

		__colon.x = __text.x + __text.width + 12;

		__left.x = __colon.x + __colon.width + spacing;

		__number.x = __left.x + __left.width + spacing;

		__right.x = __number.x + __number.width + spacing;

		__colon.y = __text.y;
		__left.y = __text.y;
		__number.y = __text.y;
		__right.y = __text.y;
	}

	override function set_text(v:String):String {
		super.set_text(v);
		updateArrowPositions();
		return v;
	}

	public function new(
		text:String,
		desc:String,
		min:Float,
		max:Float,
		step:Float = 1,
		?optionName:String,
		?changedCallback:Float->Void = null,
		?parent:Dynamic
	) {
		this.changedCallback = changedCallback;
		this.min = min;
		this.max = max;
		this.step = step;
		this.optionName = optionName;
		this.parent = parent != null ? parent : Options;

		if (Reflect.field(this.parent, optionName) != null)
			currentValue = Reflect.field(this.parent, optionName);
		else
			currentValue = min;

		super(text, desc);

		__colon = new Alphabet(0, 20, ':', 'bold');
		__left = new Alphabet(0, 20, '<', 'bold');
		__number = new Alphabet(0, 20, '$currentValue', 'bold');
		__right = new Alphabet(0, 20, '>', 'bold');

		add(__colon);
		add(__left);
		add(__number);
		add(__right);

		updateArrowPositions();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		var leftOverlaps = FlxG.mouse.overlaps(__left);
		var rightOverlaps = FlxG.mouse.overlaps(__right);

		if (FlxG.mouse.justPressed) {
			if (leftOverlaps)
				changeValue(-1);

			if (rightOverlaps)
				changeValue(1);
				
			holdTime = 0;
		} else if (FlxG.mouse.pressed) {
			if (leftOverlaps || rightOverlaps) {
				holdTime += elapsed;
				if (holdTime >= 0.5) {
					if (leftOverlaps)
						changeValue(-1);
					
					if (rightOverlaps)
						changeValue(1);
						
					holdTime -= 0.05;
				}
			} else {
				holdTime = 0;
			}
		} else {
			holdTime = 0;
		}
	}

	function changeValue(change:Int) {
		if (locked)
			return;

		var old = currentValue;

		currentValue = FlxMath.bound(
			currentValue + change * step,
			min,
			max
		);

		if (old == currentValue)
			return;

		Reflect.setField(parent, optionName, currentValue);

		if (changedCallback != null)
			changedCallback(currentValue);

		CoolUtil.playMenuSFX(SCROLL);
	}

	override function changeSelection(change:Int):Void {
		changeValue(change);
	}

	override function select() {}
}
