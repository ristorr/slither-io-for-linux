package starling.text
{
   import flash.geom.Rectangle;
   import flash.utils.Dictionary;
   import starling.display.Image;
   import starling.display.MeshBatch;
   import starling.display.Sprite;
   import starling.styles.DistanceFieldStyle;
   import starling.styles.MeshStyle;
   import starling.textures.Texture;
   import starling.textures.TextureSmoothing;
   import starling.utils.Align;
   import starling.utils.StringUtil;
   
   public class BitmapFont implements starling.text.ITextCompositor
   {
      
      public static const NATIVE_SIZE:int = -1;
      
      public static const MINI:String = "mini";
      
      private static const CHAR_MISSING:int = 0;
      
      private static const CHAR_TAB:int = 9;
      
      private static const CHAR_NEWLINE:int = 10;
      
      private static const CHAR_CARRIAGE_RETURN:int = 13;
      
      private static const CHAR_SPACE:int = 32;
      
      private static var sLines:Array = [];
      
      private static var sDefaultOptions:starling.text.TextOptions = new starling.text.TextOptions();
       
      
      private var _texture:Texture;
      
      private var _chars:Dictionary;
      
      private var _name:String;
      
      private var _size:Number;
      
      private var _lineHeight:Number;
      
      private var _baseline:Number;
      
      private var _offsetX:Number;
      
      private var _offsetY:Number;
      
      private var _padding:Number;
      
      private var _helperImage:Image;
      
      private var _type:String;
      
      private var _distanceFieldSpread:Number;
      
      public function BitmapFont(param1:Texture = null, param2:* = null)
      {
         super();
         if(param1 == null && param2 == null)
         {
            param1 = starling.text.MiniBitmapFont.texture;
            param2 = starling.text.MiniBitmapFont.xml;
         }
         else if(param1 == null || param2 == null)
         {
            throw new ArgumentError("Set both of the \'texture\' and \'fontData\' " + "arguments to valid objects or leave both of them null.");
         }
         this._name = "unknown";
         this._lineHeight = this._size = this._baseline = 14;
         this._offsetX = this._offsetY = this._padding = 0;
         this._texture = param1;
         this._chars = new Dictionary();
         this._helperImage = new Image(param1);
         this._type = starling.text.BitmapFontType.STANDARD;
         this._distanceFieldSpread = 0;
         this.addChar(CHAR_MISSING,new starling.text.BitmapChar(CHAR_MISSING,null,0,0,0));
         this.parseFontData(param2);
      }
      
      public function dispose() : void
      {
         if(this._texture)
         {
            this._texture.dispose();
         }
      }
      
      protected function parseFontData(param1:*) : void
      {
         if(param1 is XML)
         {
            this.parseFontXml(param1);
            return;
         }
         throw new ArgumentError("BitmapFont only supports XML data");
      }
      
      private function parseFontXml(param1:XML) : void
      {
         var _loc6_:XML = null;
         var _loc7_:XML = null;
         var _loc8_:int = 0;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc12_:flash.geom.Rectangle = null;
         var _loc13_:Texture = null;
         var _loc14_:starling.text.BitmapChar = null;
         var _loc15_:int = 0;
         var _loc16_:int = 0;
         var _loc17_:Number = NaN;
         var _loc2_:Number = this._texture.scale;
         var _loc3_:flash.geom.Rectangle = this._texture.frame;
         var _loc4_:Number = !!_loc3_ ? _loc3_.x : 0;
         var _loc5_:Number = !!_loc3_ ? _loc3_.y : 0;
         this._name = StringUtil.clean(param1.info.@face);
         this._size = parseFloat(param1.info.@size) / _loc2_;
         this._lineHeight = parseFloat(param1.common.@lineHeight) / _loc2_;
         this._baseline = parseFloat(param1.common.@base) / _loc2_;
         if(param1.info.@smooth.toString() == "0")
         {
            this.smoothing = TextureSmoothing.NONE;
         }
         if(this._size <= 0)
         {
            trace("[Starling] Warning: invalid font size in \'" + this._name + "\' font.");
            this._size = this._size == 0 ? 16 : this._size * -1;
         }
         if(param1.distanceField.length())
         {
            this._distanceFieldSpread = parseFloat(param1.distanceField.@distanceRange);
            this._type = param1.distanceField.@fieldType == "msdf" ? starling.text.BitmapFontType.MULTI_CHANNEL_DISTANCE_FIELD : starling.text.BitmapFontType.DISTANCE_FIELD;
         }
         else
         {
            this._distanceFieldSpread = 0;
            this._type = starling.text.BitmapFontType.STANDARD;
         }
         for each(_loc6_ in param1.chars.char)
         {
            _loc8_ = parseInt(_loc6_.@id);
            _loc9_ = parseFloat(_loc6_.@xoffset) / _loc2_;
            _loc10_ = parseFloat(_loc6_.@yoffset) / _loc2_;
            _loc11_ = parseFloat(_loc6_.@xadvance) / _loc2_;
            (_loc12_ = new flash.geom.Rectangle()).x = parseFloat(_loc6_.@x) / _loc2_ + _loc4_;
            _loc12_.y = parseFloat(_loc6_.@y) / _loc2_ + _loc5_;
            _loc12_.width = parseFloat(_loc6_.@width) / _loc2_;
            _loc12_.height = parseFloat(_loc6_.@height) / _loc2_;
            _loc13_ = Texture.fromTexture(this._texture,_loc12_);
            _loc14_ = new starling.text.BitmapChar(_loc8_,_loc13_,_loc9_,_loc10_,_loc11_);
            this.addChar(_loc8_,_loc14_);
         }
         for each(_loc7_ in param1.kernings.kerning)
         {
            _loc15_ = parseInt(_loc7_.@first);
            _loc16_ = parseInt(_loc7_.@second);
            _loc17_ = parseFloat(_loc7_.@amount) / _loc2_;
            if(_loc16_ in this._chars)
            {
               this.getChar(_loc16_).addKerning(_loc15_,_loc17_);
            }
         }
      }
      
      public function getChar(param1:int) : starling.text.BitmapChar
      {
         return this._chars[param1];
      }
      
      public function addChar(param1:int, param2:starling.text.BitmapChar) : void
      {
         this._chars[param1] = param2;
      }
      
      public function getCharIDs(param1:Vector.<int> = null) : Vector.<int>
      {
         var _loc2_:* = undefined;
         if(param1 == null)
         {
            param1 = new Vector.<int>(0);
         }
         for(_loc2_ in this._chars)
         {
            param1[param1.length] = int(_loc2_);
         }
         return param1;
      }
      
      public function hasChars(param1:String) : Boolean
      {
         var _loc2_:int = 0;
         if(param1 == null)
         {
            return true;
         }
         var _loc3_:int = param1.length;
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_)
         {
            _loc2_ = param1.charCodeAt(_loc4_);
            if(_loc2_ != CHAR_SPACE && _loc2_ != CHAR_TAB && _loc2_ != CHAR_NEWLINE && _loc2_ != CHAR_CARRIAGE_RETURN && this.getChar(_loc2_) == null)
            {
               return false;
            }
            _loc4_++;
         }
         return true;
      }
      
      public function createSprite(param1:Number, param2:Number, param3:String, param4:starling.text.TextFormat, param5:starling.text.TextOptions = null) : Sprite
      {
         var _loc11_:starling.text.BitmapCharLocation = null;
         var _loc12_:Image = null;
         var _loc6_:Vector.<starling.text.BitmapCharLocation>;
         var _loc7_:int = int((_loc6_ = this.arrangeChars(param1,param2,param3,param4,param5)).length);
         var _loc8_:String = this.smoothing;
         var _loc9_:Sprite = new Sprite();
         var _loc10_:int = 0;
         while(_loc10_ < _loc7_)
         {
            (_loc12_ = (_loc11_ = _loc6_[_loc10_]).char.createImage()).x = _loc11_.x;
            _loc12_.y = _loc11_.y;
            _loc12_.scale = _loc11_.scale;
            _loc12_.color = param4.color;
            _loc12_.textureSmoothing = _loc8_;
            _loc9_.addChild(_loc12_);
            _loc10_++;
         }
         starling.text.BitmapCharLocation.rechargePool();
         return _loc9_;
      }
      
      public function fillMeshBatch(param1:MeshBatch, param2:Number, param3:Number, param4:String, param5:starling.text.TextFormat, param6:starling.text.TextOptions = null) : void
      {
         var _loc10_:starling.text.BitmapCharLocation = null;
         var _loc7_:Vector.<starling.text.BitmapCharLocation>;
         var _loc8_:int = int((_loc7_ = this.arrangeChars(param2,param3,param4,param5,param6)).length);
         this._helperImage.color = param5.color;
         var _loc9_:int = 0;
         while(_loc9_ < _loc8_)
         {
            _loc10_ = _loc7_[_loc9_];
            this._helperImage.texture = _loc10_.char.texture;
            this._helperImage.readjustSize();
            this._helperImage.x = _loc10_.x;
            this._helperImage.y = _loc10_.y;
            this._helperImage.scale = _loc10_.scale;
            param1.addMeshAt(this._helperImage);
            _loc9_++;
         }
         starling.text.BitmapCharLocation.rechargePool();
      }
      
      public function clearMeshBatch(param1:MeshBatch) : void
      {
         param1.clear();
      }
      
      public function getDefaultMeshStyle(param1:MeshStyle, param2:starling.text.TextFormat, param3:starling.text.TextOptions) : MeshStyle
      {
         var _loc4_:DistanceFieldStyle = null;
         var _loc5_:Number = NaN;
         if(this._type == starling.text.BitmapFontType.STANDARD)
         {
            return null;
         }
         _loc5_ = param2.size < 0 ? param2.size * -this._size : param2.size;
         (_loc4_ = param1 as DistanceFieldStyle || new DistanceFieldStyle()).multiChannel = this._type == starling.text.BitmapFontType.MULTI_CHANNEL_DISTANCE_FIELD;
         _loc4_.softness = this._size / (_loc5_ * this._distanceFieldSpread);
         return _loc4_;
      }
      
      public function arrangeChars(param1:Number, param2:Number, param3:String, param4:starling.text.TextFormat, param5:starling.text.TextOptions) : Vector.<starling.text.BitmapCharLocation>
      {
         var _loc15_:starling.text.BitmapCharLocation = null;
         var _loc16_:int = 0;
         var _loc17_:Number = NaN;
         var _loc18_:Number = NaN;
         var _loc19_:Number = NaN;
         var _loc20_:int = 0;
         var _loc21_:int = 0;
         var _loc27_:int = 0;
         var _loc28_:int = 0;
         var _loc29_:Number = NaN;
         var _loc30_:Number = NaN;
         var _loc31_:Vector.<starling.text.BitmapCharLocation> = null;
         var _loc32_:Boolean = false;
         var _loc33_:int = 0;
         var _loc34_:starling.text.BitmapChar = null;
         var _loc35_:int = 0;
         var _loc36_:Vector.<starling.text.BitmapCharLocation> = null;
         var _loc37_:int = 0;
         var _loc38_:starling.text.BitmapCharLocation = null;
         var _loc39_:Number = NaN;
         var _loc40_:int = 0;
         if(param3 == null || param3.length == 0)
         {
            return starling.text.BitmapCharLocation.vectorFromPool();
         }
         if(param5 == null)
         {
            param5 = sDefaultOptions;
         }
         var _loc6_:Boolean = param4.kerning;
         var _loc7_:Number = param4.leading;
         var _loc8_:Number = param4.letterSpacing;
         var _loc9_:String = param4.horizontalAlign;
         var _loc10_:String = param4.verticalAlign;
         var _loc11_:Number = param4.size;
         var _loc12_:Boolean = param5.autoScale;
         var _loc13_:Boolean = param5.wordWrap;
         var _loc14_:Boolean = false;
         if(_loc11_ < 0)
         {
            _loc11_ *= -this._size;
         }
         while(!_loc14_)
         {
            sLines.length = 0;
            _loc19_ = _loc11_ / this._size;
            _loc17_ = (param1 - 2 * this._padding) / _loc19_;
            _loc18_ = (param2 - 2 * this._padding) / _loc19_;
            if(this._size <= _loc18_)
            {
               _loc27_ = -1;
               _loc28_ = -1;
               _loc29_ = 0;
               _loc30_ = 0;
               _loc31_ = starling.text.BitmapCharLocation.vectorFromPool();
               _loc16_ = param3.length;
               _loc20_ = 0;
               while(_loc20_ < _loc16_)
               {
                  _loc32_ = false;
                  _loc33_ = param3.charCodeAt(_loc20_);
                  _loc34_ = this.getChar(_loc33_);
                  if(_loc33_ == CHAR_NEWLINE || _loc33_ == CHAR_CARRIAGE_RETURN)
                  {
                     _loc32_ = true;
                  }
                  else
                  {
                     if(_loc34_ == null)
                     {
                        trace(StringUtil.format("[Starling] Character \'{0}\' (id: {1}) not found in \'{2}\'",param3.charAt(_loc20_),_loc33_,this.name));
                        _loc33_ = CHAR_MISSING;
                        _loc34_ = this.getChar(CHAR_MISSING);
                     }
                     if(_loc33_ == CHAR_SPACE || _loc33_ == CHAR_TAB)
                     {
                        _loc27_ = _loc20_;
                     }
                     if(_loc6_)
                     {
                        _loc29_ += _loc34_.getKerning(_loc28_);
                     }
                     (_loc15_ = starling.text.BitmapCharLocation.instanceFromPool(_loc34_)).index = _loc20_;
                     _loc15_.x = _loc29_ + _loc34_.xOffset;
                     _loc15_.y = _loc30_ + _loc34_.yOffset;
                     _loc31_[_loc31_.length] = _loc15_;
                     _loc29_ += _loc34_.xAdvance + _loc8_;
                     _loc28_ = _loc33_;
                     if(_loc15_.x + _loc34_.width > _loc17_)
                     {
                        if(_loc13_)
                        {
                           if(_loc12_ && _loc27_ == -1)
                           {
                              break;
                           }
                           _loc35_ = _loc27_ == -1 ? 1 : _loc20_ - _loc27_;
                           _loc21_ = 0;
                           while(_loc21_ < _loc35_)
                           {
                              _loc31_.pop();
                              _loc21_++;
                           }
                           if(_loc31_.length == 0)
                           {
                              break;
                           }
                           _loc20_ -= _loc35_;
                        }
                        else
                        {
                           if(_loc12_)
                           {
                              break;
                           }
                           _loc31_.pop();
                           while(_loc20_ < _loc16_ - 1 && param3.charCodeAt(_loc20_) != CHAR_NEWLINE)
                           {
                              _loc20_++;
                           }
                        }
                        _loc32_ = true;
                     }
                  }
                  if(_loc20_ == _loc16_ - 1)
                  {
                     sLines[sLines.length] = _loc31_;
                     _loc14_ = true;
                  }
                  else if(_loc32_)
                  {
                     sLines[sLines.length] = _loc31_;
                     if(_loc27_ == _loc20_)
                     {
                        _loc31_.pop();
                     }
                     if(_loc30_ + this._lineHeight + _loc7_ + this._size > _loc18_)
                     {
                        break;
                     }
                     _loc31_ = starling.text.BitmapCharLocation.vectorFromPool();
                     _loc29_ = 0;
                     _loc30_ += this._lineHeight + _loc7_;
                     _loc27_ = -1;
                     _loc28_ = -1;
                  }
                  _loc20_++;
               }
            }
            if(_loc12_ && !_loc14_ && _loc11_ > 3)
            {
               _loc11_--;
            }
            else
            {
               _loc14_ = true;
            }
         }
         var _loc22_:Vector.<starling.text.BitmapCharLocation> = starling.text.BitmapCharLocation.vectorFromPool();
         var _loc23_:int = int(sLines.length);
         var _loc24_:Number = _loc30_ + this._lineHeight;
         var _loc25_:int = 0;
         if(_loc10_ == Align.BOTTOM)
         {
            _loc25_ = _loc18_ - _loc24_;
         }
         else if(_loc10_ == Align.CENTER)
         {
            _loc25_ = (_loc18_ - _loc24_) / 2;
         }
         var _loc26_:int = 0;
         while(_loc26_ < _loc23_)
         {
            if((_loc16_ = int((_loc36_ = sLines[_loc26_]).length)) != 0)
            {
               _loc37_ = 0;
               _loc39_ = (_loc38_ = _loc36_[_loc36_.length - 1]).x - _loc38_.char.xOffset + _loc38_.char.xAdvance;
               if(_loc9_ == Align.RIGHT)
               {
                  _loc37_ = _loc17_ - _loc39_;
               }
               else if(_loc9_ == Align.CENTER)
               {
                  _loc37_ = (_loc17_ - _loc39_) / 2;
               }
               _loc40_ = 0;
               while(_loc40_ < _loc16_)
               {
                  (_loc15_ = _loc36_[_loc40_]).x = _loc19_ * (_loc15_.x + _loc37_ + this._offsetX) + this._padding;
                  _loc15_.y = _loc19_ * (_loc15_.y + _loc25_ + this._offsetY) + this._padding;
                  _loc15_.scale = _loc19_;
                  if(_loc15_.char.width > 0 && _loc15_.char.height > 0)
                  {
                     _loc22_[_loc22_.length] = _loc15_;
                  }
                  _loc40_++;
               }
            }
            _loc26_++;
         }
         return _loc22_;
      }
      
      public function get name() : String
      {
         return this._name;
      }
      
      public function set name(param1:String) : void
      {
         this._name = param1;
      }
      
      public function get size() : Number
      {
         return this._size;
      }
      
      public function set size(param1:Number) : void
      {
         this._size = param1;
      }
      
      public function get type() : String
      {
         return this._type;
      }
      
      public function set type(param1:String) : void
      {
         this._type = param1;
      }
      
      public function get distanceFieldSpread() : Number
      {
         return this._distanceFieldSpread;
      }
      
      public function set distanceFieldSpread(param1:Number) : void
      {
         this._distanceFieldSpread = param1;
      }
      
      public function get lineHeight() : Number
      {
         return this._lineHeight;
      }
      
      public function set lineHeight(param1:Number) : void
      {
         this._lineHeight = param1;
      }
      
      public function get smoothing() : String
      {
         return this._helperImage.textureSmoothing;
      }
      
      public function set smoothing(param1:String) : void
      {
         this._helperImage.textureSmoothing = param1;
      }
      
      public function get baseline() : Number
      {
         return this._baseline;
      }
      
      public function set baseline(param1:Number) : void
      {
         this._baseline = param1;
      }
      
      public function get offsetX() : Number
      {
         return this._offsetX;
      }
      
      public function set offsetX(param1:Number) : void
      {
         this._offsetX = param1;
      }
      
      public function get offsetY() : Number
      {
         return this._offsetY;
      }
      
      public function set offsetY(param1:Number) : void
      {
         this._offsetY = param1;
      }
      
      public function get padding() : Number
      {
         return this._padding;
      }
      
      public function set padding(param1:Number) : void
      {
         this._padding = param1;
      }
      
      public function get texture() : Texture
      {
         return this._texture;
      }
   }
}
