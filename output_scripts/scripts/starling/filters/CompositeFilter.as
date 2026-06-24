package starling.filters
{
   import flash.geom.Point;
   import starling.rendering.FilterEffect;
   import starling.rendering.Painter;
   import starling.textures.Texture;
   
   public class CompositeFilter extends FragmentFilter
   {
       
      
      public function CompositeFilter()
      {
         super();
      }
      
      override public function process(param1:Painter, param2:IFilterHelper, param3:Texture = null, param4:Texture = null, param5:Texture = null, param6:Texture = null) : Texture
      {
         this.compositeEffect.texture = param3;
         this.compositeEffect.getLayerAt(1).texture = param4;
         this.compositeEffect.getLayerAt(2).texture = param5;
         this.compositeEffect.getLayerAt(3).texture = param6;
         if(param4)
         {
            param4.setupTextureCoordinates(vertexData,0,"texCoords1");
         }
         if(param5)
         {
            param5.setupTextureCoordinates(vertexData,0,"texCoords2");
         }
         if(param6)
         {
            param6.setupTextureCoordinates(vertexData,0,"texCoords3");
         }
         return super.process(param1,param2,param3,param4,param5,param6);
      }
      
      override protected function createEffect() : FilterEffect
      {
         return new CompositeEffect();
      }
      
      public function getOffsetAt(param1:int, param2:Point = null) : Point
      {
         if(param2 == null)
         {
            param2 = new Point();
         }
         param2.x = this.compositeEffect.getLayerAt(param1).x;
         param2.y = this.compositeEffect.getLayerAt(param1).y;
         return param2;
      }
      
      public function setOffsetAt(param1:int, param2:Number, param3:Number) : void
      {
         this.compositeEffect.getLayerAt(param1).x = param2;
         this.compositeEffect.getLayerAt(param1).y = param3;
      }
      
      public function getColorAt(param1:int) : uint
      {
         return this.compositeEffect.getLayerAt(param1).color;
      }
      
      public function getReplaceColorAt(param1:int) : Boolean
      {
         return this.compositeEffect.getLayerAt(param1).replaceColor;
      }
      
      public function setColorAt(param1:int, param2:uint, param3:Boolean = false) : void
      {
         this.compositeEffect.getLayerAt(param1).color = param2;
         this.compositeEffect.getLayerAt(param1).replaceColor = param3;
      }
      
      public function getAlphaAt(param1:int) : Number
      {
         return this.compositeEffect.getLayerAt(param1).alpha;
      }
      
      public function setAlphaAt(param1:int, param2:Number) : void
      {
         this.compositeEffect.getLayerAt(param1).alpha = param2;
      }
      
      public function getModeAt(param1:int) : String
      {
         return this.compositeEffect.getLayerAt(param1).mode;
      }
      
      public function setModeAt(param1:int, param2:String) : void
      {
         this.compositeEffect.getLayerAt(param1).mode = param2;
      }
      
      public function getInvertAlphaAt(param1:int) : Boolean
      {
         return this.compositeEffect.getLayerAt(param1).invertAlpha;
      }
      
      public function setInvertAlphaAt(param1:int, param2:Boolean = true) : void
      {
         this.compositeEffect.getLayerAt(param1).invertAlpha = param2;
      }
      
      private function get compositeEffect() : CompositeEffect
      {
         return this.effect as CompositeEffect;
      }
   }
}

import flash.display3D.Context3D;
import flash.display3D.Context3DProgramType;
import starling.filters.CompositeMode;
import starling.rendering.FilterEffect;
import starling.rendering.Program;
import starling.rendering.VertexDataFormat;
import starling.textures.Texture;
import starling.utils.Color;
import starling.utils.RenderUtil;
import starling.utils.StringUtil;

class CompositeEffect extends FilterEffect
{
   
   public static const VERTEX_FORMAT:VertexDataFormat = FilterEffect.VERTEX_FORMAT.extend("texCoords1:float2, texCoords2:float2, texCoords3:float2");
   
   private static var sLayers:Array = [];
   
   private static var sOffset:Vector.<Number> = new <Number>[0,0,0,0];
   
   private static var sColor:Vector.<Number> = new <Number>[0,0,0,0];
    
   
   private var _layers:Vector.<CompositeLayer>;
   
   public function CompositeEffect(param1:int = 4)
   {
      super();
      if(param1 < 1 || param1 > 4)
      {
         throw new ArgumentError("number of layers must be between 1 and 4");
      }
      this._layers = new Vector.<CompositeLayer>(param1,true);
      var _loc2_:int = 0;
      while(_loc2_ < param1)
      {
         this._layers[_loc2_] = new CompositeLayer();
         _loc2_++;
      }
   }
   
   public function getLayerAt(param1:int) : CompositeLayer
   {
      return this._layers[param1];
   }
   
   private function getUsedLayers(param1:Array = null) : Array
   {
      var _loc2_:CompositeLayer = null;
      if(param1 == null)
      {
         param1 = [];
      }
      else
      {
         param1.length = 0;
      }
      for each(_loc2_ in this._layers)
      {
         if(_loc2_.texture)
         {
            param1[param1.length] = _loc2_;
         }
      }
      return param1;
   }
   
   override protected function createProgram() : Program
   {
      var _loc3_:int = 0;
      var _loc4_:Array = null;
      var _loc5_:CompositeLayer = null;
      var _loc6_:Array = null;
      var _loc7_:String = null;
      var _loc8_:String = null;
      var _loc9_:String = null;
      var _loc1_:Array = this.getUsedLayers(sLayers);
      var _loc2_:int = int(_loc1_.length);
      if(_loc2_)
      {
         _loc4_ = ["m44 op, va0, vc0"];
         _loc5_ = this._layers[0];
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            _loc4_.push(StringUtil.format("add v{0}, va{1}, vc{2}",_loc3_,_loc3_ + 1,_loc3_ + 4));
            _loc3_++;
         }
         _loc6_ = ["sge ft5, v0, v0"];
         _loc3_ = 0;
         for(; _loc3_ < _loc2_; _loc3_++)
         {
            _loc7_ = "ft" + _loc3_;
            _loc8_ = "fc" + _loc3_;
            _loc9_ = "v" + _loc3_;
            _loc5_ = this._layers[_loc3_];
            _loc6_.push(tex(_loc7_,_loc9_,_loc3_,_loc1_[_loc3_].texture));
            if(_loc5_.replaceColor)
            {
               if(_loc5_.invertAlpha)
               {
                  _loc6_.push("sub " + _loc7_ + ".w, ft5.w, " + _loc7_ + ".w");
               }
               _loc6_.push("mul " + _loc7_ + ".w,   " + _loc7_ + ".w,   " + _loc8_ + ".w","sat " + _loc7_ + ".w,   " + _loc7_ + ".w    ","mul " + _loc7_ + ".xyz, " + _loc8_ + ".xyz, " + _loc7_ + ".www");
            }
            else
            {
               _loc6_.push("mul " + _loc7_ + ", " + _loc7_ + ", " + _loc8_);
            }
            if(_loc3_ == 0)
            {
               continue;
            }
            switch(_loc5_.mode)
            {
               case CompositeMode.NORMAL:
                  _loc6_.push("sub ft4, ft5, " + _loc7_ + ".wwww","mul ft0, ft0, ft4","add ft0, ft0, " + _loc7_);
                  break;
               case CompositeMode.INSIDE:
                  _loc6_.push("mul ft4, ft0.wwww, " + _loc7_,"sub ft6, ft5, " + _loc7_ + ".wwww","mul ft6, ft6, ft0","add ft0, ft6, ft4");
                  break;
               case CompositeMode.INSIDE_KNOCKOUT:
                  _loc6_.push("mul ft0, ft0.wwww, " + _loc7_);
                  break;
               case CompositeMode.OUTSIDE:
                  _loc6_.push("sub ft4, ft5, ft0.wwww","mul ft4, ft4, " + _loc7_,"add ft0, ft0, ft4");
                  break;
               case CompositeMode.OUTSIDE_KNOCKOUT:
                  _loc6_.push("sub ft4, ft5, ft0.wwww","mul ft0, ft4, " + _loc7_);
                  break;
               default:
                  throw new ArgumentError("Invalid composite mode: " + _loc5_.mode);
            }
         }
         _loc6_.push("mov oc, ft0");
         return Program.fromSource(_loc4_.join("\n"),_loc6_.join("\n"));
      }
      return super.createProgram();
   }
   
   override protected function get programVariantName() : uint
   {
      var _loc1_:uint = 0;
      var _loc2_:uint = 0;
      var _loc3_:uint = 0;
      var _loc4_:uint = 0;
      var _loc5_:uint = 0;
      var _loc7_:CompositeLayer = null;
      var _loc6_:uint = 0;
      var _loc8_:Array;
      var _loc9_:int = int((_loc8_ = this.getUsedLayers(sLayers)).length);
      var _loc10_:int = 0;
      while(_loc10_ < _loc9_)
      {
         _loc7_ = _loc8_[_loc10_];
         _loc3_ = RenderUtil.getTextureVariantBits(_loc7_.texture);
         _loc2_ = uint(CompositeMode.getIndex(_loc7_.mode));
         _loc5_ = uint(int(_loc7_.replaceColor));
         _loc4_ = uint(int(_loc7_.invertAlpha));
         _loc1_ = uint(_loc3_ | _loc2_ << 3 | _loc5_ << 6 | _loc4_ << 7);
         _loc6_ |= _loc1_ << _loc10_ * 8;
         _loc10_++;
      }
      return _loc6_;
   }
   
   override protected function beforeDraw(param1:Context3D) : void
   {
      var _loc4_:int = 0;
      var _loc5_:CompositeLayer = null;
      var _loc6_:Texture = null;
      var _loc7_:Number = NaN;
      super.beforeDraw(param1);
      var _loc2_:Array = this.getUsedLayers(sLayers);
      var _loc3_:int = int(_loc2_.length);
      if(_loc3_)
      {
         _loc4_ = 0;
         while(_loc4_ < _loc3_)
         {
            _loc6_ = (_loc5_ = _loc2_[_loc4_]).texture;
            _loc7_ = _loc5_.replaceColor ? 1 : _loc5_.alpha;
            sOffset[0] = -_loc5_.x / (_loc6_.root.nativeWidth / _loc6_.scale);
            sOffset[1] = -_loc5_.y / (_loc6_.root.nativeHeight / _loc6_.scale);
            sColor[0] = Color.getRed(_loc5_.color) * _loc7_ / 255;
            sColor[1] = Color.getGreen(_loc5_.color) * _loc7_ / 255;
            sColor[2] = Color.getBlue(_loc5_.color) * _loc7_ / 255;
            sColor[3] = _loc5_.alpha;
            param1.setProgramConstantsFromVector(Context3DProgramType.VERTEX,_loc4_ + 4,sOffset);
            param1.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT,_loc4_,sColor);
            if(_loc4_ > 0)
            {
               param1.setTextureAt(_loc4_,_loc6_.base);
               RenderUtil.setSamplerStateAt(_loc4_,_loc6_.mipMapping,textureSmoothing);
               this.vertexFormat.setVertexBufferAt(_loc4_ + 1,vertexBuffer,"texCoords" + _loc4_);
            }
            _loc4_++;
         }
      }
   }
   
   override protected function afterDraw(param1:Context3D) : void
   {
      var _loc2_:Array = this.getUsedLayers(sLayers);
      var _loc3_:int = int(_loc2_.length);
      var _loc4_:int = 1;
      while(_loc4_ < _loc3_)
      {
         param1.setTextureAt(_loc4_,null);
         param1.setVertexBufferAt(_loc4_ + 1,null);
         _loc4_++;
      }
      super.afterDraw(param1);
   }
   
   override public function get vertexFormat() : VertexDataFormat
   {
      return VERTEX_FORMAT;
   }
   
   public function get numLayers() : int
   {
      return this._layers.length;
   }
   
   override public function set texture(param1:Texture) : void
   {
      this._layers[0].texture = param1;
      super.texture = param1;
   }
}

import starling.filters.CompositeMode;
import starling.textures.Texture;

class CompositeLayer
{
    
   
   public var texture:Texture;
   
   public var x:Number;
   
   public var y:Number;
   
   public var color:uint;
   
   public var alpha:Number;
   
   public var replaceColor:Boolean;
   
   public var invertAlpha:Boolean;
   
   public var mode:String;
   
   public function CompositeLayer()
   {
      super();
      this.x = this.y = 0;
      this.alpha = 1;
      this.color = 16777215;
      this.mode = CompositeMode.NORMAL;
   }
}
