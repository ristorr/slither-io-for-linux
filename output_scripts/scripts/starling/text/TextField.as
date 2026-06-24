package starling.text
{
   import flash.display3D.Context3DTextureFormat;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.text.StyleSheet;
   import flash.utils.Dictionary;
   import starling.core.Starling;
   import starling.display.DisplayObject;
   import starling.display.DisplayObjectContainer;
   import starling.display.MeshBatch;
   import starling.display.Quad;
   import starling.display.Sprite;
   import starling.events.Event;
   import starling.rendering.Painter;
   import starling.styles.MeshStyle;
   import starling.utils.RectangleUtil;
   import starling.utils.SystemUtil;
   
   public class TextField extends DisplayObjectContainer
   {
      
      private static const COMPOSITOR_DATA_NAME:String = "starling.display.TextField.compositors";
      
      private static var sMatrix:Matrix = new Matrix();
      
      private static var sDefaultCompositor:starling.text.ITextCompositor = new starling.text.TrueTypeCompositor();
      
      private static var sDefaultTextureFormat:String = Context3DTextureFormat.BGRA_PACKED;
      
      private static var sStringCache:Dictionary = new Dictionary();
       
      
      private var _text:String;
      
      private var _options:starling.text.TextOptions;
      
      private var _format:starling.text.TextFormat;
      
      private var _textBounds:flash.geom.Rectangle;
      
      private var _hitArea:flash.geom.Rectangle;
      
      private var _compositor:starling.text.ITextCompositor;
      
      private var _requiresRecomposition:Boolean;
      
      private var _border:DisplayObjectContainer;
      
      private var _meshBatch:MeshBatch;
      
      private var _customStyle:MeshStyle;
      
      private var _defaultStyle:MeshStyle;
      
      private var _recomposing:Boolean;
      
      public function TextField(param1:int, param2:int, param3:String = "", param4:starling.text.TextFormat = null, param5:starling.text.TextOptions = null)
      {
         super();
         this._text = !!param3 ? param3 : "";
         this._hitArea = new flash.geom.Rectangle(0,0,param1,param2);
         this._requiresRecomposition = true;
         this._compositor = sDefaultCompositor;
         this._format = !!param4 ? param4.clone() : new starling.text.TextFormat();
         this._format.addEventListener(Event.CHANGE,this.setRequiresRecomposition);
         this._options = !!param5 ? param5.clone() : new starling.text.TextOptions();
         this._options.addEventListener(Event.CHANGE,this.setRequiresRecomposition);
         this._meshBatch = new MeshBatch();
         this._meshBatch.touchable = false;
         this._meshBatch.pixelSnapping = true;
         addChild(this._meshBatch);
      }
      
      public static function get defaultTextureFormat() : String
      {
         return sDefaultTextureFormat;
      }
      
      public static function set defaultTextureFormat(param1:String) : void
      {
         sDefaultTextureFormat = param1;
      }
      
      public static function get defaultCompositor() : starling.text.ITextCompositor
      {
         return sDefaultCompositor;
      }
      
      public static function set defaultCompositor(param1:starling.text.ITextCompositor) : void
      {
         sDefaultCompositor = param1;
      }
      
      public static function updateEmbeddedFonts() : void
      {
         SystemUtil.updateEmbeddedFonts();
      }
      
      public static function registerCompositor(param1:starling.text.ITextCompositor, param2:String) : void
      {
         if(param2 == null)
         {
            throw new ArgumentError("fontName must not be null");
         }
         compositors[convertToLowerCase(param2)] = param1;
      }
      
      public static function unregisterCompositor(param1:String, param2:Boolean = true) : void
      {
         param1 = convertToLowerCase(param1);
         if(param2 && compositors[param1] != undefined)
         {
            compositors[param1].dispose();
         }
         delete compositors[param1];
      }
      
      public static function getCompositor(param1:String) : starling.text.ITextCompositor
      {
         return compositors[convertToLowerCase(param1)];
      }
      
      public static function registerBitmapFont(param1:starling.text.BitmapFont, param2:String = null) : String
      {
         if(param2 == null)
         {
            param2 = param1.name;
         }
         registerCompositor(param1,param2);
         return param2;
      }
      
      public static function unregisterBitmapFont(param1:String, param2:Boolean = true) : void
      {
         unregisterCompositor(param1,param2);
      }
      
      public static function getBitmapFont(param1:String) : starling.text.BitmapFont
      {
         return getCompositor(param1) as starling.text.BitmapFont;
      }
      
      private static function get compositors() : Dictionary
      {
         var _loc1_:Dictionary = Starling.painter.sharedData[COMPOSITOR_DATA_NAME] as Dictionary;
         if(_loc1_ == null)
         {
            _loc1_ = new Dictionary();
            Starling.painter.sharedData[COMPOSITOR_DATA_NAME] = _loc1_;
         }
         return _loc1_;
      }
      
      private static function convertToLowerCase(param1:String) : String
      {
         var _loc2_:String = String(sStringCache[param1]);
         if(_loc2_ == null)
         {
            _loc2_ = param1.toLowerCase();
            sStringCache[param1] = _loc2_;
         }
         return _loc2_;
      }
      
      override public function dispose() : void
      {
         this._format.removeEventListener(Event.CHANGE,this.setRequiresRecomposition);
         this._options.removeEventListener(Event.CHANGE,this.setRequiresRecomposition);
         this._compositor.clearMeshBatch(this._meshBatch);
         super.dispose();
      }
      
      override public function render(param1:Painter) : void
      {
         if(this._requiresRecomposition)
         {
            this.recompose();
         }
         super.render(param1);
      }
      
      private function recompose() : void
      {
         var _loc1_:String = null;
         var _loc2_:starling.text.ITextCompositor = null;
         if(this._requiresRecomposition)
         {
            this._recomposing = true;
            this._compositor.clearMeshBatch(this._meshBatch);
            _loc1_ = this._format.font;
            _loc2_ = getCompositor(_loc1_);
            if(_loc2_ == null && _loc1_ == starling.text.BitmapFont.MINI)
            {
               _loc2_ = new starling.text.BitmapFont();
               registerCompositor(_loc2_,_loc1_);
            }
            this._compositor = !!_loc2_ ? _loc2_ : sDefaultCompositor;
            this.updateText();
            this.updateBorder();
            this._requiresRecomposition = false;
            this._recomposing = false;
         }
      }
      
      private function updateText() : void
      {
         var _loc1_:Number = this._hitArea.width;
         var _loc2_:Number = this._hitArea.height;
         if(this.isHorizontalAutoSize && !this._options.isHtmlText)
         {
            _loc1_ = 100000;
         }
         if(this.isVerticalAutoSize)
         {
            _loc2_ = 100000;
         }
         this._meshBatch.x = this._meshBatch.y = 0;
         this._options.textureScale = Starling.contentScaleFactor;
         this._compositor.fillMeshBatch(this._meshBatch,_loc1_,_loc2_,this._text,this._format,this._options);
         if(this._customStyle)
         {
            this._meshBatch.style = this._customStyle;
         }
         else
         {
            this._defaultStyle = this._compositor.getDefaultMeshStyle(this._defaultStyle,this._format,this._options);
            if(this._defaultStyle)
            {
               this._meshBatch.style = this._defaultStyle;
            }
         }
         if(this._options.autoSize != starling.text.TextFieldAutoSize.NONE)
         {
            this._textBounds = this._meshBatch.getBounds(this._meshBatch,this._textBounds);
            if(this.isHorizontalAutoSize)
            {
               this._meshBatch.x = this._textBounds.x = -this._textBounds.x;
               this._hitArea.width = this._textBounds.width;
               this._textBounds.x = 0;
            }
            if(this.isVerticalAutoSize)
            {
               this._meshBatch.y = this._textBounds.y = -this._textBounds.y;
               this._hitArea.height = this._textBounds.height;
               this._textBounds.y = 0;
            }
         }
         else
         {
            this._textBounds = null;
         }
      }
      
      private function updateBorder() : void
      {
         if(this._border == null)
         {
            return;
         }
         var _loc1_:Number = this._hitArea.width;
         var _loc2_:Number = this._hitArea.height;
         var _loc3_:Quad = this._border.getChildAt(0) as Quad;
         var _loc4_:Quad = this._border.getChildAt(1) as Quad;
         var _loc5_:Quad = this._border.getChildAt(2) as Quad;
         var _loc6_:Quad = this._border.getChildAt(3) as Quad;
         _loc3_.width = _loc1_;
         _loc3_.height = 1;
         _loc5_.width = _loc1_;
         _loc5_.height = 1;
         _loc6_.width = 1;
         _loc6_.height = _loc2_;
         _loc4_.width = 1;
         _loc4_.height = _loc2_;
         _loc4_.x = _loc1_ - 1;
         _loc5_.y = _loc2_ - 1;
         _loc3_.color = _loc4_.color = _loc5_.color = _loc6_.color = this._format.color;
      }
      
      public function setRequiresRecomposition() : void
      {
         if(!this._recomposing)
         {
            this._requiresRecomposition = true;
            setRequiresRedraw();
         }
      }
      
      private function get isHorizontalAutoSize() : Boolean
      {
         return this._options.autoSize == starling.text.TextFieldAutoSize.HORIZONTAL || this._options.autoSize == starling.text.TextFieldAutoSize.BOTH_DIRECTIONS;
      }
      
      private function get isVerticalAutoSize() : Boolean
      {
         return this._options.autoSize == starling.text.TextFieldAutoSize.VERTICAL || this._options.autoSize == starling.text.TextFieldAutoSize.BOTH_DIRECTIONS;
      }
      
      public function get textBounds() : flash.geom.Rectangle
      {
         return this.getTextBounds(this);
      }
      
      override public function getBounds(param1:DisplayObject, param2:flash.geom.Rectangle = null) : flash.geom.Rectangle
      {
         if(this._requiresRecomposition)
         {
            this.recompose();
         }
         getTransformationMatrix(param1,sMatrix);
         return RectangleUtil.getBounds(this._hitArea,sMatrix,param2);
      }
      
      public function getTextBounds(param1:DisplayObject, param2:flash.geom.Rectangle = null) : flash.geom.Rectangle
      {
         if(this._requiresRecomposition)
         {
            this.recompose();
         }
         if(this._textBounds == null)
         {
            this._textBounds = this._meshBatch.getBounds(this);
         }
         getTransformationMatrix(param1,sMatrix);
         return RectangleUtil.getBounds(this._textBounds,sMatrix,param2);
      }
      
      override public function hitTest(param1:Point) : DisplayObject
      {
         if(!visible || !touchable || !hitTestMask(param1))
         {
            return null;
         }
         if(this._hitArea.containsPoint(param1))
         {
            return this;
         }
         return null;
      }
      
      override public function set width(param1:Number) : void
      {
         this._hitArea.width = param1 / (scaleX || 1);
         this.setRequiresRecomposition();
      }
      
      override public function set height(param1:Number) : void
      {
         this._hitArea.height = param1 / (scaleY || 1);
         this.setRequiresRecomposition();
      }
      
      public function get text() : String
      {
         return this._text;
      }
      
      public function set text(param1:String) : void
      {
         if(param1 == null)
         {
            param1 = "";
         }
         if(this._text != param1)
         {
            this._text = param1;
            this.setRequiresRecomposition();
         }
      }
      
      public function get format() : starling.text.TextFormat
      {
         return this._format;
      }
      
      public function set format(param1:starling.text.TextFormat) : void
      {
         if(param1 == null)
         {
            throw new ArgumentError("format cannot be null");
         }
         this._format.copyFrom(param1);
      }
      
      protected function get options() : starling.text.TextOptions
      {
         return this._options;
      }
      
      public function get border() : Boolean
      {
         return this._border != null;
      }
      
      public function set border(param1:Boolean) : void
      {
         var _loc2_:int = 0;
         if(param1 && this._border == null)
         {
            this._border = new Sprite();
            addChild(this._border);
            _loc2_ = 0;
            while(_loc2_ < 4)
            {
               this._border.addChild(new Quad(1,1));
               _loc2_++;
            }
            this.updateBorder();
         }
         else if(!param1 && this._border != null)
         {
            this._border.removeFromParent(true);
            this._border = null;
         }
      }
      
      public function get autoScale() : Boolean
      {
         return this._options.autoScale;
      }
      
      public function set autoScale(param1:Boolean) : void
      {
         this._options.autoScale = param1;
      }
      
      public function get autoSize() : String
      {
         return this._options.autoSize;
      }
      
      public function set autoSize(param1:String) : void
      {
         this._options.autoSize = param1;
      }
      
      public function get wordWrap() : Boolean
      {
         return this._options.wordWrap;
      }
      
      public function set wordWrap(param1:Boolean) : void
      {
         this._options.wordWrap = param1;
      }
      
      public function get batchable() : Boolean
      {
         return this._meshBatch.batchable;
      }
      
      public function set batchable(param1:Boolean) : void
      {
         this._meshBatch.batchable = param1;
      }
      
      public function get isHtmlText() : Boolean
      {
         return this._options.isHtmlText;
      }
      
      public function set isHtmlText(param1:Boolean) : void
      {
         this._options.isHtmlText = param1;
      }
      
      public function get styleSheet() : StyleSheet
      {
         return this._options.styleSheet;
      }
      
      public function set styleSheet(param1:StyleSheet) : void
      {
         this._options.styleSheet = param1;
      }
      
      public function get padding() : Number
      {
         return this._options.padding;
      }
      
      public function set padding(param1:Number) : void
      {
         this._options.padding = param1;
      }
      
      public function get pixelSnapping() : Boolean
      {
         return this._meshBatch.pixelSnapping;
      }
      
      public function set pixelSnapping(param1:Boolean) : void
      {
         this._meshBatch.pixelSnapping = param1;
      }
      
      public function get style() : MeshStyle
      {
         if(this._requiresRecomposition)
         {
            this.recompose();
         }
         return this._meshBatch.style;
      }
      
      public function set style(param1:MeshStyle) : void
      {
         this._customStyle = param1;
         this.setRequiresRecomposition();
      }
   }
}
