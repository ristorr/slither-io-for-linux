package starling.styles
{
   import flash.geom.Matrix;
   import starling.core.Starling;
   import starling.display.Mesh;
   import starling.rendering.MeshEffect;
   import starling.rendering.RenderState;
   import starling.rendering.VertexData;
   import starling.rendering.VertexDataFormat;
   import starling.utils.Color;
   import starling.utils.MathUtil;
   
   public class DistanceFieldStyle extends MeshStyle
   {
      
      public static const VERTEX_FORMAT:VertexDataFormat = MeshStyle.VERTEX_FORMAT.extend("basic:bytes4, extended:bytes4, outerColor:bytes4");
      
      public static const MODE_BASIC:String = "basic";
      
      public static const MODE_OUTLINE:String = "outline";
      
      public static const MODE_GLOW:String = "glow";
      
      public static const MODE_SHADOW:String = "shadow";
       
      
      private var _mode:String;
      
      private var _multiChannel:Boolean;
      
      private var _threshold:Number;
      
      private var _alpha:Number;
      
      private var _softness:Number;
      
      private var _outerThreshold:Number;
      
      private var _outerAlphaEnd:Number;
      
      private var _shadowOffsetX:Number;
      
      private var _shadowOffsetY:Number;
      
      private var _outerColor:uint;
      
      private var _outerAlphaStart:Number;
      
      public function DistanceFieldStyle(param1:Number = 0.125, param2:Number = 0.5)
      {
         super();
         this._mode = MODE_BASIC;
         this._threshold = param2;
         this._softness = param1;
         this._alpha = 1;
         this._outerThreshold = this._outerAlphaEnd = 0;
         this._shadowOffsetX = this._shadowOffsetY = 0;
         this._outerColor = 0;
         this._outerAlphaStart = 0;
      }
      
      override public function copyFrom(param1:MeshStyle) : void
      {
         var _loc2_:DistanceFieldStyle = param1 as DistanceFieldStyle;
         if(_loc2_)
         {
            this._mode = _loc2_._mode;
            this._multiChannel = _loc2_._multiChannel;
            this._threshold = _loc2_._threshold;
            this._softness = _loc2_._softness;
            this._alpha = _loc2_._alpha;
            this._outerThreshold = _loc2_._outerThreshold;
            this._outerAlphaEnd = _loc2_._outerAlphaEnd;
            this._shadowOffsetX = _loc2_._shadowOffsetX;
            this._shadowOffsetY = _loc2_._shadowOffsetY;
            this._outerColor = _loc2_._outerColor;
            this._outerAlphaStart = _loc2_._outerAlphaStart;
         }
         super.copyFrom(param1);
      }
      
      override public function createEffect() : MeshEffect
      {
         return new DistanceFieldEffect();
      }
      
      override public function get vertexFormat() : VertexDataFormat
      {
         return VERTEX_FORMAT;
      }
      
      override protected function onTargetAssigned(param1:Mesh) : void
      {
         this.updateVertices();
      }
      
      private function updateVertices() : void
      {
         if(vertexData == null)
         {
            return;
         }
         var _loc1_:int = vertexData.numVertices;
         var _loc2_:int = DistanceFieldEffect.MAX_SCALE;
         var _loc3_:int = DistanceFieldEffect.MAX_OUTER_OFFSET;
         var _loc4_:Number = (this._shadowOffsetX + _loc3_) / (2 * _loc3_);
         var _loc5_:Number = (this._shadowOffsetY + _loc3_) / (2 * _loc3_);
         var _loc6_:uint = uint(uint(this._threshold * 255) | uint(this._alpha * 255) << 8 | uint(this._softness / 2 * 255) << 16 | uint(1 / _loc2_ * 255) << 24);
         var _loc7_:uint = uint(uint(this._outerThreshold * 255) | uint(this._outerAlphaEnd * 255) << 8 | uint(_loc4_ * 255) << 16 | uint(_loc5_ * 255) << 24);
         var _loc8_:uint = uint(Color.getRed(this._outerColor) | Color.getGreen(this._outerColor) << 8 | Color.getBlue(this._outerColor) << 16 | uint(this._outerAlphaStart * 255) << 24);
         var _loc9_:int = 0;
         while(_loc9_ < _loc1_)
         {
            vertexData.setUnsignedInt(_loc9_,"basic",_loc6_);
            vertexData.setUnsignedInt(_loc9_,"extended",_loc7_);
            vertexData.setUnsignedInt(_loc9_,"outerColor",_loc8_);
            _loc9_++;
         }
         setVertexDataChanged();
      }
      
      override public function batchVertexData(param1:MeshStyle, param2:int = 0, param3:Matrix = null, param4:int = 0, param5:int = -1) : void
      {
         var _loc6_:Number = NaN;
         var _loc7_:VertexData = null;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:int = 0;
         var _loc11_:uint = 0;
         var _loc12_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc14_:uint = 0;
         super.batchVertexData(param1,param2,param3,param4,param5);
         if(param3)
         {
            _loc6_ = Math.sqrt(param3.a * param3.a + param3.c * param3.c);
            if(!MathUtil.isEquivalent(_loc6_,1,0.01))
            {
               _loc7_ = (param1 as DistanceFieldStyle).vertexData;
               _loc9_ = (_loc8_ = DistanceFieldEffect.MAX_SCALE) / 255;
               if(param5 < 0)
               {
                  param5 = vertexData.numVertices - param4;
               }
               _loc10_ = 0;
               while(_loc10_ < param5)
               {
                  _loc12_ = ((_loc11_ = vertexData.getUnsignedInt(param4 + _loc10_,"basic")) >> 24 & 255) / 255 * _loc8_;
                  _loc13_ = MathUtil.clamp(_loc12_ * _loc6_,_loc9_,_loc8_);
                  _loc14_ = uint(_loc11_ & 16777215 | uint(_loc13_ / _loc8_ * 255) << 24);
                  _loc7_.setUnsignedInt(param2 + _loc10_,"basic",_loc14_);
                  _loc10_++;
               }
            }
         }
      }
      
      override public function updateEffect(param1:MeshEffect, param2:RenderState) : void
      {
         var _loc4_:Matrix = null;
         var _loc5_:Number = NaN;
         var _loc3_:DistanceFieldEffect = param1 as DistanceFieldEffect;
         _loc3_.mode = this._mode;
         _loc3_.multiChannel = this._multiChannel;
         if(param2.is3D)
         {
            _loc3_.scale = 1;
         }
         else
         {
            _loc4_ = param2.modelviewMatrix;
            _loc5_ = Math.sqrt(_loc4_.a * _loc4_.a + _loc4_.c * _loc4_.c);
            _loc3_.scale = _loc5_ * Starling.contentScaleFactor;
         }
         super.updateEffect(param1,param2);
      }
      
      override public function canBatchWith(param1:MeshStyle) : Boolean
      {
         var _loc2_:DistanceFieldStyle = param1 as DistanceFieldStyle;
         if(Boolean(_loc2_) && super.canBatchWith(param1))
         {
            return _loc2_._mode == this._mode && _loc2_._multiChannel == this._multiChannel;
         }
         return false;
      }
      
      public function setupBasic() : void
      {
         this._mode = MODE_BASIC;
         setRequiresRedraw();
      }
      
      public function setupOutline(param1:Number = 0.25, param2:uint = 0, param3:Number = 1) : void
      {
         this._mode = MODE_OUTLINE;
         this._outerThreshold = MathUtil.clamp(this._threshold - param1,0,this._threshold);
         this._outerColor = param2;
         this._outerAlphaStart = this._outerAlphaEnd = MathUtil.clamp(param3,0,1);
         this._shadowOffsetX = this._shadowOffsetY = 0;
         this.updateVertices();
      }
      
      public function setupGlow(param1:Number = 0.2, param2:uint = 16776960, param3:Number = 0.5) : void
      {
         this._mode = MODE_GLOW;
         this._outerThreshold = MathUtil.clamp(this._threshold - param1,0,this._threshold);
         this._outerColor = param2;
         this._outerAlphaStart = MathUtil.clamp(param3,0,1);
         this._outerAlphaEnd = 0;
         this._shadowOffsetX = this._shadowOffsetY = 0;
         this.updateVertices();
      }
      
      public function setupDropShadow(param1:Number = 0.2, param2:Number = 2, param3:Number = 2, param4:uint = 0, param5:Number = 0.5) : void
      {
         var _loc6_:Number = DistanceFieldEffect.MAX_OUTER_OFFSET;
         this._mode = MODE_SHADOW;
         this._outerThreshold = MathUtil.clamp(this._threshold - param1,0,this._threshold);
         this._outerColor = param4;
         this._outerAlphaStart = MathUtil.clamp(param5,0,1);
         this._outerAlphaEnd = 0;
         this._shadowOffsetX = MathUtil.clamp(param2,-_loc6_,_loc6_);
         this._shadowOffsetY = MathUtil.clamp(param3,-_loc6_,_loc6_);
         this.updateVertices();
      }
      
      public function get mode() : String
      {
         return this._mode;
      }
      
      public function set mode(param1:String) : void
      {
         this._mode = param1;
         setRequiresRedraw();
      }
      
      public function get multiChannel() : Boolean
      {
         return this._multiChannel;
      }
      
      public function set multiChannel(param1:Boolean) : void
      {
         this._multiChannel = param1;
         setRequiresRedraw();
      }
      
      public function get threshold() : Number
      {
         return this._threshold;
      }
      
      public function set threshold(param1:Number) : void
      {
         param1 = MathUtil.clamp(param1,0,1);
         if(this._threshold != param1)
         {
            this._threshold = param1;
            this.updateVertices();
         }
      }
      
      public function get softness() : Number
      {
         return this._softness;
      }
      
      public function set softness(param1:Number) : void
      {
         param1 = MathUtil.clamp(param1,0,1);
         if(this._softness != param1)
         {
            this._softness = param1;
            this.updateVertices();
         }
      }
      
      public function get alpha() : Number
      {
         return this._alpha;
      }
      
      public function set alpha(param1:Number) : void
      {
         param1 = MathUtil.clamp(param1,0,1);
         if(this._alpha != param1)
         {
            this._alpha = param1;
            this.updateVertices();
         }
      }
      
      public function get outerThreshold() : Number
      {
         return this._outerThreshold;
      }
      
      public function set outerThreshold(param1:Number) : void
      {
         param1 = MathUtil.clamp(param1,0,1);
         if(this._outerThreshold != param1)
         {
            this._outerThreshold = param1;
            this.updateVertices();
         }
      }
      
      public function get outerAlphaStart() : Number
      {
         return this._outerAlphaStart;
      }
      
      public function set outerAlphaStart(param1:Number) : void
      {
         param1 = MathUtil.clamp(param1,0,1);
         if(this._outerAlphaStart != param1)
         {
            this._outerAlphaStart = param1;
            this.updateVertices();
         }
      }
      
      public function get outerAlphaEnd() : Number
      {
         return this._outerAlphaEnd;
      }
      
      public function set outerAlphaEnd(param1:Number) : void
      {
         param1 = MathUtil.clamp(param1,0,1);
         if(this._outerAlphaEnd != param1)
         {
            this._outerAlphaEnd = param1;
            this.updateVertices();
         }
      }
      
      public function get outerColor() : uint
      {
         return this._outerColor;
      }
      
      public function set outerColor(param1:uint) : void
      {
         if(this._outerColor != param1)
         {
            this._outerColor = param1;
            this.updateVertices();
         }
      }
      
      public function get shadowOffsetX() : Number
      {
         return this._shadowOffsetX;
      }
      
      public function set shadowOffsetX(param1:Number) : void
      {
         var _loc2_:Number = DistanceFieldEffect.MAX_OUTER_OFFSET;
         param1 = MathUtil.clamp(param1,-_loc2_,_loc2_);
         if(this._shadowOffsetX != param1)
         {
            this._shadowOffsetX = param1;
            this.updateVertices();
         }
      }
      
      public function get shadowOffsetY() : Number
      {
         return this._shadowOffsetY;
      }
      
      public function set shadowOffsetY(param1:Number) : void
      {
         var _loc2_:Number = DistanceFieldEffect.MAX_OUTER_OFFSET;
         param1 = MathUtil.clamp(param1,-_loc2_,_loc2_);
         if(this._shadowOffsetY != param1)
         {
            this._shadowOffsetY = param1;
            this.updateVertices();
         }
      }
   }
}

import flash.display3D.Context3D;
import flash.display3D.Context3DProgramType;
import starling.rendering.MeshEffect;
import starling.rendering.Program;
import starling.rendering.VertexDataFormat;
import starling.styles.DistanceFieldStyle;
import starling.utils.StringUtil;

class DistanceFieldEffect extends MeshEffect
{
   
   public static const VERTEX_FORMAT:VertexDataFormat = DistanceFieldStyle.VERTEX_FORMAT;
   
   public static const MAX_OUTER_OFFSET:int = 8;
   
   public static const MAX_SCALE:int = 8;
   
   private static const sVector:Vector.<Number> = new Vector.<Number>(4,true);
    
   
   private var _mode:String;
   
   private var _scale:Number;
   
   private var _multiChannel:Boolean;
   
   public function DistanceFieldEffect()
   {
      super();
      this._scale = 1;
      this._mode = DistanceFieldStyle.MODE_BASIC;
   }
   
   private static function step(param1:String, param2:String, param3:String, param4:String = "ft6") : String
   {
      return [StringUtil.format("sub {0}, {1}, {2}",param4,param3,param2),StringUtil.format("rcp {0}, {0}",param4),StringUtil.format("sub {0}, {0}, {1}",param1,param2),StringUtil.format("mul {0}, {0}, {1}",param1,param4),StringUtil.format("sat {0}, {0}",param1)].join("\n");
   }
   
   private static function median(param1:String) : String
   {
      return [StringUtil.format("max {0}.xyz, {0}.xxy, {0}.yzz",param1),StringUtil.format("min {0}.x, {0}.x, {0}.y",param1),StringUtil.format("min {0}, {0}.xxxx, {0}.zzzz",param1)].join("\n");
   }
   
   override protected function createProgram() : Program
   {
      var _loc1_:* = false;
      var _loc2_:* = false;
      var _loc3_:Vector.<String> = null;
      var _loc4_:Vector.<String> = null;
      if(texture)
      {
         _loc1_ = this._mode == DistanceFieldStyle.MODE_BASIC;
         _loc2_ = this._mode == DistanceFieldStyle.MODE_SHADOW;
         _loc3_ = new <String>["m44 op, va0, vc0","mov v0, va1","mul vt4, va3.yyyy, vc4","mul v1, va2, vt4","mov v3, va3","mov v4, va4","mov v5, va5","mul vt4.w, vc4.w, va2.w","mul v4.y, va4.y, vt4.w","mul v5.w, va5.w, vt4.w","mul vt0.x, va3.w, vc5.z","mul vt0.x, vt0.x, vc5.w","div vt0.x, va3.z, vt0.x","mov vt1, vc4","sub vt1.x, va3.x, vt0.x","add vt1.y, va3.x, vt0.x"];
         if(!_loc1_)
         {
            _loc3_.push("sub vt1.z, va4.x, vt0.x","add vt1.w, va4.x, vt0.x");
         }
         _loc3_.push("sat v6, vt1");
         if(_loc2_)
         {
            _loc3_.push("mul vt0.xy, va4.zw, vc6.zz","sub vt0.xy, vt0.xy, vc6.yy","mul vt0.xy, vt0.xy, vc5.xy","sub v7, va1, vt0.xyxy","sub vt0.z, va3.x, va4.x","add v7.z, va3.x, vt0.z");
         }
         _loc4_ = new <String>[tex("ft0","v0",0,texture),!!this._multiChannel ? String(median("ft0")) : "mov ft0, ft0.xxxx","mov ft1, ft0",step("ft1.w","v6.x","v6.y"),"mov ft3, ft1","mul ft1, v1, ft1.wwww"];
         if(_loc2_)
         {
            _loc4_.push(tex("ft0","v7",0,texture),!!this._multiChannel ? median("ft0") : "mov ft0, ft0.xxxx","mov ft5.x, v7.z");
         }
         else if(!_loc1_)
         {
            _loc4_.push("mov ft5.x, v6.x");
         }
         if(!_loc1_)
         {
            _loc4_.push("mov ft2, ft0",step("ft2.w","v6.z","v6.w"),"sub ft2.w, ft2.w, ft3.w","sat ft2.w, ft2.w","mov ft4, ft0",step("ft4.w","v6.z","ft5.x"),"sub ft6.w, v5.w, v4.y","mul ft4.w, ft4.w, ft6.w","add ft4.w, ft4.w, v4.y","mul ft2.w, ft2.w, ft4.w","mul ft2.xyz, v5.xyz, ft2.www");
         }
         if(_loc1_)
         {
            _loc4_.push("mov oc, ft1");
         }
         else
         {
            _loc4_.push("add oc, ft1, ft2");
         }
         return Program.fromSource(_loc3_.join("\n"),_loc4_.join("\n"));
      }
      return super.createProgram();
   }
   
   override protected function beforeDraw(param1:Context3D) : void
   {
      var _loc2_:Number = NaN;
      var _loc3_:Number = NaN;
      super.beforeDraw(param1);
      if(texture)
      {
         this.vertexFormat.setVertexBufferAt(3,vertexBuffer,"basic");
         this.vertexFormat.setVertexBufferAt(4,vertexBuffer,"extended");
         this.vertexFormat.setVertexBufferAt(5,vertexBuffer,"outerColor");
         _loc2_ = 1 / (texture.root.nativeWidth / texture.scale);
         _loc3_ = 1 / (texture.root.nativeHeight / texture.scale);
         sVector[0] = MAX_OUTER_OFFSET * _loc2_;
         sVector[1] = MAX_OUTER_OFFSET * _loc3_;
         sVector[2] = MAX_SCALE;
         sVector[3] = this._scale;
         param1.setProgramConstantsFromVector(Context3DProgramType.VERTEX,5,sVector);
         sVector[0] = 0;
         sVector[1] = 1;
         sVector[2] = 2;
         param1.setProgramConstantsFromVector(Context3DProgramType.VERTEX,6,sVector);
      }
   }
   
   override protected function afterDraw(param1:Context3D) : void
   {
      if(texture)
      {
         param1.setVertexBufferAt(3,null);
         param1.setVertexBufferAt(4,null);
         param1.setVertexBufferAt(5,null);
      }
      super.afterDraw(param1);
   }
   
   override public function get vertexFormat() : VertexDataFormat
   {
      return VERTEX_FORMAT;
   }
   
   override protected function get programVariantName() : uint
   {
      var _loc1_:uint = 0;
      switch(this._mode)
      {
         case DistanceFieldStyle.MODE_SHADOW:
            _loc1_ = 3;
            break;
         case DistanceFieldStyle.MODE_GLOW:
            _loc1_ = 2;
            break;
         case DistanceFieldStyle.MODE_OUTLINE:
            _loc1_ = 1;
            break;
         default:
            _loc1_ = 0;
      }
      if(this._multiChannel)
      {
         _loc1_ |= 1 << 2;
      }
      return super.programVariantName | _loc1_ << 8;
   }
   
   public function get scale() : Number
   {
      return this._scale;
   }
   
   public function set scale(param1:Number) : void
   {
      this._scale = param1;
   }
   
   public function get mode() : String
   {
      return this._mode;
   }
   
   public function set mode(param1:String) : void
   {
      this._mode = param1;
   }
   
   public function get multiChannel() : Boolean
   {
      return this._multiChannel;
   }
   
   public function set multiChannel(param1:Boolean) : void
   {
      this._multiChannel = param1;
   }
}
