package starling.display
{
   import flash.geom.Rectangle;
   import flash.utils.Dictionary;
   import starling.rendering.IndexData;
   import starling.rendering.VertexData;
   import starling.textures.Texture;
   import starling.utils.MathUtil;
   import starling.utils.Padding;
   import starling.utils.Pool;
   import starling.utils.RectangleUtil;
   
   public class Image extends starling.display.Quad
   {
      
      private static var sAutomators:Dictionary = new Dictionary(true);
      
      private static var sPadding:Padding = new Padding();
      
      private static var sBounds:flash.geom.Rectangle = new flash.geom.Rectangle();
      
      private static var sBasCols:Vector.<Number> = new Vector.<Number>(3,true);
      
      private static var sBasRows:Vector.<Number> = new Vector.<Number>(3,true);
      
      private static var sPosCols:Vector.<Number> = new Vector.<Number>(3,true);
      
      private static var sPosRows:Vector.<Number> = new Vector.<Number>(3,true);
      
      private static var sTexCols:Vector.<Number> = new Vector.<Number>(3,true);
      
      private static var sTexRows:Vector.<Number> = new Vector.<Number>(3,true);
       
      
      private var _scale9Grid:flash.geom.Rectangle;
      
      private var _tileGrid:flash.geom.Rectangle;
      
      public function Image(param1:Texture)
      {
         super(100,100);
         this.texture = param1;
         readjustSize();
      }
      
      public static function automateSetupForTexture(param1:Texture, param2:Function, param3:Function = null) : void
      {
         var _loc4_:SetupAutomator;
         if(_loc4_ = sAutomators[param1])
         {
            _loc4_.add(param2,param3);
         }
         else
         {
            sAutomators[param1] = new SetupAutomator(param2,param3);
         }
      }
      
      public static function resetSetupForTexture(param1:Texture) : void
      {
         delete sAutomators[param1];
      }
      
      public static function removeSetupForTexture(param1:Texture, param2:Function, param3:Function = null) : void
      {
         var _loc4_:SetupAutomator;
         if(_loc4_ = sAutomators[param1])
         {
            _loc4_.remove(param2,param3);
         }
      }
      
      public static function bindScale9GridToTexture(param1:Texture, param2:flash.geom.Rectangle) : void
      {
         var texture:Texture = param1;
         var scale9Grid:flash.geom.Rectangle = param2;
         automateSetupForTexture(texture,function(param1:starling.display.Image):void
         {
            param1.scale9Grid = scale9Grid;
         },function(param1:starling.display.Image):void
         {
            param1.scale9Grid = null;
         });
      }
      
      public static function bindPivotPointToTexture(param1:Texture, param2:Number, param3:Number) : void
      {
         var texture:Texture = param1;
         var pivotX:Number = param2;
         var pivotY:Number = param3;
         automateSetupForTexture(texture,function(param1:starling.display.Image):void
         {
            param1.pivotX = pivotX;
            param1.pivotY = pivotY;
         },function(param1:starling.display.Image):void
         {
            param1.pivotX = param1.pivotY = 0;
         });
      }
      
      public function get scale9Grid() : flash.geom.Rectangle
      {
         return this._scale9Grid;
      }
      
      public function set scale9Grid(param1:flash.geom.Rectangle) : void
      {
         if(param1)
         {
            if(this._scale9Grid == null)
            {
               this._scale9Grid = param1.clone();
            }
            else
            {
               this._scale9Grid.copyFrom(param1);
            }
            readjustSize();
            this._tileGrid = null;
         }
         else
         {
            this._scale9Grid = null;
         }
         this.setupVertices();
      }
      
      public function get tileGrid() : flash.geom.Rectangle
      {
         return this._tileGrid;
      }
      
      public function set tileGrid(param1:flash.geom.Rectangle) : void
      {
         if(param1)
         {
            if(this._tileGrid == null)
            {
               this._tileGrid = param1.clone();
            }
            else
            {
               this._tileGrid.copyFrom(param1);
            }
            this._scale9Grid = null;
         }
         else
         {
            this._tileGrid = null;
         }
         this.setupVertices();
      }
      
      override protected function setupVertices() : void
      {
         if(Boolean(texture) && Boolean(this._scale9Grid))
         {
            this.setupScale9Grid();
         }
         else if(Boolean(texture) && Boolean(this._tileGrid))
         {
            this.setupTileGrid();
         }
         else
         {
            super.setupVertices();
         }
      }
      
      override public function set scaleX(param1:Number) : void
      {
         super.scaleX = param1;
         if(Boolean(texture) && (Boolean(this._scale9Grid) || Boolean(this._tileGrid)))
         {
            this.setupVertices();
         }
      }
      
      override public function set scaleY(param1:Number) : void
      {
         super.scaleY = param1;
         if(Boolean(texture) && (Boolean(this._scale9Grid) || Boolean(this._tileGrid)))
         {
            this.setupVertices();
         }
      }
      
      override public function set texture(param1:Texture) : void
      {
         if(param1 != texture)
         {
            if(Boolean(texture) && Boolean(sAutomators[texture]))
            {
               sAutomators[texture].onRelease(this);
            }
            super.texture = param1;
            if(Boolean(param1) && Boolean(sAutomators[param1]))
            {
               sAutomators[param1].onAssign(this);
            }
            else if(Boolean(this._scale9Grid) && Boolean(param1))
            {
               readjustSize();
            }
         }
      }
      
      private function setupScale9Grid() : void
      {
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         var _loc12_:Number = NaN;
         var _loc18_:uint = 0;
         var _loc19_:Number = NaN;
         var _loc1_:Texture = this.texture;
         var _loc2_:flash.geom.Rectangle = _loc1_.frame;
         var _loc3_:Number = scaleX > 0 ? scaleX : -scaleX;
         var _loc4_:Number = scaleY > 0 ? scaleY : -scaleY;
         if(_loc3_ == 0 || _loc4_ == 0)
         {
            return;
         }
         if(MathUtil.isEquivalent(this._scale9Grid.width,_loc1_.frameWidth))
         {
            _loc4_ /= _loc3_;
         }
         else if(MathUtil.isEquivalent(this._scale9Grid.height,_loc1_.frameHeight))
         {
            _loc3_ /= _loc4_;
         }
         var _loc5_:Number = 1 / _loc3_;
         var _loc6_:Number = 1 / _loc4_;
         var _loc7_:VertexData = this.vertexData;
         var _loc8_:IndexData = this.indexData;
         var _loc9_:int = _loc7_.numVertices;
         var _loc13_:flash.geom.Rectangle = Pool.getRectangle();
         var _loc14_:flash.geom.Rectangle = Pool.getRectangle();
         var _loc15_:flash.geom.Rectangle = Pool.getRectangle();
         var _loc16_:flash.geom.Rectangle = Pool.getRectangle();
         _loc13_.copyFrom(this._scale9Grid);
         _loc14_.setTo(0,0,_loc1_.frameWidth,_loc1_.frameHeight);
         if(_loc2_)
         {
            _loc15_.setTo(-_loc2_.x,-_loc2_.y,_loc1_.width,_loc1_.height);
         }
         else
         {
            _loc15_.copyFrom(_loc14_);
         }
         RectangleUtil.intersect(_loc13_,_loc15_,_loc16_);
         sBasCols[0] = sBasCols[2] = 0;
         sBasRows[0] = sBasRows[2] = 0;
         sBasCols[1] = _loc16_.width;
         sBasRows[1] = _loc16_.height;
         if(_loc15_.x < _loc13_.x)
         {
            sBasCols[0] = _loc13_.x - _loc15_.x;
         }
         if(_loc15_.y < _loc13_.y)
         {
            sBasRows[0] = _loc13_.y - _loc15_.y;
         }
         if(_loc15_.right > _loc13_.right)
         {
            sBasCols[2] = _loc15_.right - _loc13_.right;
         }
         if(_loc15_.bottom > _loc13_.bottom)
         {
            sBasRows[2] = _loc15_.bottom - _loc13_.bottom;
         }
         if(_loc15_.x < _loc13_.x)
         {
            sPadding.left = _loc15_.x * _loc5_;
         }
         else
         {
            sPadding.left = _loc13_.x * _loc5_ + _loc15_.x - _loc13_.x;
         }
         if(_loc15_.right > _loc13_.right)
         {
            sPadding.right = (_loc14_.width - _loc15_.right) * _loc5_;
         }
         else
         {
            sPadding.right = (_loc14_.width - _loc13_.right) * _loc5_ + _loc13_.right - _loc15_.right;
         }
         if(_loc15_.y < _loc13_.y)
         {
            sPadding.top = _loc15_.y * _loc6_;
         }
         else
         {
            sPadding.top = _loc13_.y * _loc6_ + _loc15_.y - _loc13_.y;
         }
         if(_loc15_.bottom > _loc13_.bottom)
         {
            sPadding.bottom = (_loc14_.height - _loc15_.bottom) * _loc6_;
         }
         else
         {
            sPadding.bottom = (_loc14_.height - _loc13_.bottom) * _loc6_ + _loc13_.bottom - _loc15_.bottom;
         }
         sPosCols[0] = sBasCols[0] * _loc5_;
         sPosCols[2] = sBasCols[2] * _loc5_;
         sPosCols[1] = _loc14_.width - sPadding.left - sPadding.right - sPosCols[0] - sPosCols[2];
         sPosRows[0] = sBasRows[0] * _loc6_;
         sPosRows[2] = sBasRows[2] * _loc6_;
         sPosRows[1] = _loc14_.height - sPadding.top - sPadding.bottom - sPosRows[0] - sPosRows[2];
         if(sPosCols[1] <= 0)
         {
            _loc12_ = _loc14_.width / (_loc14_.width - _loc13_.width) * _loc3_;
            sPadding.left *= _loc12_;
            sPosCols[0] *= _loc12_;
            sPosCols[1] = 0;
            sPosCols[2] *= _loc12_;
         }
         if(sPosRows[1] <= 0)
         {
            _loc12_ = _loc14_.height / (_loc14_.height - _loc13_.height) * _loc4_;
            sPadding.top *= _loc12_;
            sPosRows[0] *= _loc12_;
            sPosRows[1] = 0;
            sPosRows[2] *= _loc12_;
         }
         sTexCols[0] = sBasCols[0] / _loc15_.width;
         sTexCols[2] = sBasCols[2] / _loc15_.width;
         sTexCols[1] = 1 - sTexCols[0] - sTexCols[2];
         sTexRows[0] = sBasRows[0] / _loc15_.height;
         sTexRows[2] = sBasRows[2] / _loc15_.height;
         sTexRows[1] = 1 - sTexRows[0] - sTexRows[2];
         _loc11_ = (_loc10_ = this.setupScale9GridAttributes(sPadding.left,sPadding.top,sPosCols,sPosRows,sTexCols,sTexRows)) / 4;
         _loc7_.numVertices = _loc10_;
         _loc8_.numIndices = 0;
         var _loc17_:int = 0;
         while(_loc17_ < _loc11_)
         {
            _loc8_.addQuad(_loc17_ * 4,_loc17_ * 4 + 1,_loc17_ * 4 + 2,_loc17_ * 4 + 3);
            _loc17_++;
         }
         if(_loc10_ != _loc9_)
         {
            _loc18_ = !!_loc9_ ? _loc7_.getColor(0) : 16777215;
            _loc19_ = !!_loc9_ ? _loc7_.getAlpha(0) : 1;
            _loc7_.colorize("color",_loc18_,_loc19_);
         }
         Pool.putRectangle(_loc14_);
         Pool.putRectangle(_loc15_);
         Pool.putRectangle(_loc13_);
         Pool.putRectangle(_loc16_);
         setRequiresRedraw();
      }
      
      private function setupScale9GridAttributes(param1:Number, param2:Number, param3:Vector.<Number>, param4:Vector.<Number>, param5:Vector.<Number>, param6:Vector.<Number>) : int
      {
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc11_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc7_:String = "position";
         var _loc8_:String = "texCoords";
         var _loc15_:VertexData = this.vertexData;
         var _loc16_:Texture = this.texture;
         var _loc17_:Number = param1;
         var _loc18_:Number = param2;
         var _loc19_:Number = 0;
         var _loc20_:Number = 0;
         var _loc21_:int = 0;
         _loc9_ = 0;
         while(_loc9_ < 3)
         {
            _loc12_ = param4[_loc9_];
            _loc14_ = param6[_loc9_];
            if(_loc12_ > 0)
            {
               _loc10_ = 0;
               while(_loc10_ < 3)
               {
                  _loc11_ = param3[_loc10_];
                  _loc13_ = param5[_loc10_];
                  if(_loc11_ > 0)
                  {
                     _loc15_.setPoint(_loc21_,_loc7_,_loc17_,_loc18_);
                     _loc16_.setTexCoords(_loc15_,_loc21_,_loc8_,_loc19_,_loc20_);
                     _loc21_++;
                     _loc15_.setPoint(_loc21_,_loc7_,_loc17_ + _loc11_,_loc18_);
                     _loc16_.setTexCoords(_loc15_,_loc21_,_loc8_,_loc19_ + _loc13_,_loc20_);
                     _loc21_++;
                     _loc15_.setPoint(_loc21_,_loc7_,_loc17_,_loc18_ + _loc12_);
                     _loc16_.setTexCoords(_loc15_,_loc21_,_loc8_,_loc19_,_loc20_ + _loc14_);
                     _loc21_++;
                     _loc15_.setPoint(_loc21_,_loc7_,_loc17_ + _loc11_,_loc18_ + _loc12_);
                     _loc16_.setTexCoords(_loc15_,_loc21_,_loc8_,_loc19_ + _loc13_,_loc20_ + _loc14_);
                     _loc21_++;
                     _loc17_ += _loc11_;
                  }
                  _loc19_ += _loc13_;
                  _loc10_++;
               }
               _loc18_ += _loc12_;
            }
            _loc17_ = param1;
            _loc19_ = 0;
            _loc20_ += _loc14_;
            _loc9_++;
         }
         return _loc21_;
      }
      
      private function setupTileGrid() : void
      {
         var _loc6_:int = 0;
         var _loc21_:Number = NaN;
         var _loc22_:Number = NaN;
         var _loc23_:Number = NaN;
         var _loc24_:Number = NaN;
         var _loc25_:Number = NaN;
         var _loc26_:Number = NaN;
         var _loc27_:Number = NaN;
         var _loc28_:Number = NaN;
         var _loc31_:Number = NaN;
         var _loc1_:Texture = this.texture;
         var _loc2_:flash.geom.Rectangle = _loc1_.frame;
         var _loc3_:VertexData = this.vertexData;
         var _loc4_:IndexData = this.indexData;
         var _loc5_:flash.geom.Rectangle = getBounds(this,sBounds);
         var _loc7_:uint = !!(_loc6_ = _loc3_.numVertices) ? _loc3_.getColor(0) : 16777215;
         var _loc8_:Number = !!_loc6_ ? _loc3_.getAlpha(0) : 1;
         var _loc9_:Number = scaleX > 0 ? 1 / scaleX : -1 / scaleX;
         var _loc10_:Number = scaleY > 0 ? 1 / scaleY : -1 / scaleY;
         var _loc11_:Number = this._tileGrid.width > 0 ? this._tileGrid.width : _loc1_.frameWidth;
         var _loc12_:Number = this._tileGrid.height > 0 ? this._tileGrid.height : _loc1_.frameHeight;
         _loc11_ *= _loc9_;
         _loc12_ *= _loc10_;
         var _loc13_:Number = !!_loc2_ ? -_loc2_.x * (_loc11_ / _loc2_.width) : 0;
         var _loc14_:Number = !!_loc2_ ? -_loc2_.y * (_loc12_ / _loc2_.height) : 0;
         var _loc15_:Number = _loc1_.width * (_loc11_ / _loc1_.frameWidth);
         var _loc16_:Number = _loc1_.height * (_loc12_ / _loc1_.frameHeight);
         var _loc17_:Number = this._tileGrid.x * _loc9_ % _loc11_;
         var _loc18_:Number = this._tileGrid.y * _loc10_ % _loc12_;
         if(_loc17_ < 0)
         {
            _loc17_ += _loc11_;
         }
         if(_loc18_ < 0)
         {
            _loc18_ += _loc12_;
         }
         var _loc19_:Number = _loc17_ + _loc13_;
         var _loc20_:Number = _loc18_ + _loc14_;
         if(_loc19_ > _loc11_ - _loc15_)
         {
            _loc19_ -= _loc11_;
         }
         if(_loc20_ > _loc12_ - _loc16_)
         {
            _loc20_ -= _loc12_;
         }
         var _loc29_:String = "position";
         var _loc30_:String = "texCoords";
         var _loc32_:Number = _loc20_;
         var _loc33_:int = 0;
         _loc4_.numIndices = 0;
         while(_loc32_ < _loc5_.height)
         {
            _loc31_ = _loc19_;
            while(_loc31_ < _loc5_.width)
            {
               _loc4_.addQuad(_loc33_,_loc33_ + 1,_loc33_ + 2,_loc33_ + 3);
               _loc21_ = _loc31_ < 0 ? 0 : _loc31_;
               _loc23_ = _loc32_ < 0 ? 0 : _loc32_;
               _loc22_ = _loc31_ + _loc15_ > _loc5_.width ? _loc5_.width : _loc31_ + _loc15_;
               _loc24_ = _loc32_ + _loc16_ > _loc5_.height ? _loc5_.height : _loc32_ + _loc16_;
               _loc3_.setPoint(_loc33_,_loc29_,_loc21_,_loc23_);
               _loc3_.setPoint(_loc33_ + 1,_loc29_,_loc22_,_loc23_);
               _loc3_.setPoint(_loc33_ + 2,_loc29_,_loc21_,_loc24_);
               _loc3_.setPoint(_loc33_ + 3,_loc29_,_loc22_,_loc24_);
               _loc25_ = (_loc21_ - _loc31_) / _loc15_;
               _loc27_ = (_loc23_ - _loc32_) / _loc16_;
               _loc26_ = (_loc22_ - _loc31_) / _loc15_;
               _loc28_ = (_loc24_ - _loc32_) / _loc16_;
               _loc1_.setTexCoords(_loc3_,_loc33_,_loc30_,_loc25_,_loc27_);
               _loc1_.setTexCoords(_loc3_,_loc33_ + 1,_loc30_,_loc26_,_loc27_);
               _loc1_.setTexCoords(_loc3_,_loc33_ + 2,_loc30_,_loc25_,_loc28_);
               _loc1_.setTexCoords(_loc3_,_loc33_ + 3,_loc30_,_loc26_,_loc28_);
               _loc31_ += _loc11_;
               _loc33_ += 4;
            }
            _loc32_ += _loc12_;
         }
         _loc3_.numVertices = _loc33_;
         var _loc34_:int = _loc6_;
         while(_loc34_ < _loc33_)
         {
            _loc3_.setColor(_loc34_,"color",_loc7_);
            _loc3_.setAlpha(_loc34_,"color",_loc8_);
            _loc34_++;
         }
         setRequiresRedraw();
      }
   }
}

import starling.display.Image;
import starling.utils.execute;

class SetupAutomator
{
    
   
   private var _onAssign:Array;
   
   private var _onRelease:Array;
   
   public function SetupAutomator(param1:Function, param2:Function)
   {
      super();
      this._onAssign = [];
      this._onRelease = [];
      this.add(param1,param2);
   }
   
   public function add(param1:Function, param2:Function) : void
   {
      if(param1 != null && this._onAssign.indexOf(param1) == -1)
      {
         this._onAssign[this._onAssign.length] = param1;
      }
      if(param2 != null && this._onRelease.indexOf(param2) == -1)
      {
         this._onRelease[this._onRelease.length] = param2;
      }
   }
   
   public function remove(param1:Function, param2:Function) : void
   {
      var _loc3_:int = 0;
      var _loc4_:int = 0;
      if(param1 != null)
      {
         _loc3_ = int(this._onAssign.indexOf(param1));
         if(_loc3_ != -1)
         {
            this._onAssign.removeAt(_loc3_);
         }
      }
      if(param2 != null)
      {
         if((_loc4_ = int(this._onRelease.indexOf(param2))) != -1)
         {
            this._onRelease.removeAt(_loc4_);
         }
      }
   }
   
   public function onAssign(param1:Image) : void
   {
      var _loc2_:int = int(this._onAssign.length);
      var _loc3_:int = 0;
      while(_loc3_ < _loc2_)
      {
         execute(this._onAssign[_loc3_],param1);
         _loc3_++;
      }
   }
   
   public function onRelease(param1:Image) : void
   {
      var _loc2_:int = int(this._onRelease.length);
      var _loc3_:int = 0;
      while(_loc3_ < _loc2_)
      {
         execute(this._onRelease[_loc3_],param1);
         _loc3_++;
      }
   }
}
