package starling.filters
{
   import starling.core.Starling;
   import starling.rendering.FilterEffect;
   import starling.rendering.Painter;
   import starling.textures.Texture;
   import starling.utils.MathUtil;
   
   public class BlurFilter extends FragmentFilter
   {
       
      
      private var _blurX:Number;
      
      private var _blurY:Number;
      
      private var _quality:Number;
      
      public function BlurFilter(param1:Number = 1, param2:Number = 1, param3:Number = 1)
      {
         super();
         this._blurX = Math.abs(param1);
         this._blurY = Math.abs(param2);
         this._quality = 1;
         this.resolution = param3;
         this.maintainResolutionAcrossPasses = true;
      }
      
      private static function getNumPasses(param1:Number) : int
      {
         var _loc2_:int = 1;
         while(param1 > 1)
         {
            _loc2_ += 1;
            param1 /= 2;
         }
         return _loc2_;
      }
      
      override public function process(param1:Painter, param2:IFilterHelper, param3:Texture = null, param4:Texture = null, param5:Texture = null, param6:Texture = null) : Texture
      {
         var _loc8_:Texture = null;
         var _loc7_:BlurEffect = this.effect as BlurEffect;
         if(this._blurX == 0 && this._blurY == 0)
         {
            _loc7_.strength = 0;
            return super.process(param1,param2,param3);
         }
         var _loc9_:Texture = param3;
         var _loc10_:Number = this.totalBlurX;
         var _loc11_:Number = this.totalBlurY;
         _loc7_.quality = this._quality;
         _loc7_.direction = BlurEffect.HORIZONTAL;
         while(_loc10_ > 0)
         {
            _loc7_.strength = _loc10_;
            _loc8_ = _loc9_;
            _loc9_ = super.process(param1,param2,_loc8_);
            if(_loc8_ != param3)
            {
               param2.putTexture(_loc8_);
            }
            if(_loc10_ <= 1)
            {
               break;
            }
            _loc10_ /= 2;
         }
         _loc7_.direction = BlurEffect.VERTICAL;
         while(_loc11_ > 0)
         {
            _loc7_.strength = _loc11_;
            _loc8_ = _loc9_;
            _loc9_ = super.process(param1,param2,_loc8_);
            if(_loc8_ != param3)
            {
               param2.putTexture(_loc8_);
            }
            if(_loc11_ <= 1)
            {
               break;
            }
            _loc11_ /= 2;
         }
         return _loc9_;
      }
      
      override protected function createEffect() : FilterEffect
      {
         return new BlurEffect();
      }
      
      override public function set resolution(param1:Number) : void
      {
         super.resolution = param1;
         this.updatePadding();
      }
      
      private function updatePadding() : void
      {
         var _loc1_:Number = !!this._blurX ? (this.totalBlurX * 3 + 2) / (resolution * this._quality) : 0;
         var _loc2_:Number = !!this._blurY ? (this.totalBlurY * 3 + 2) / (resolution * this._quality) : 0;
         padding.setTo(_loc1_,_loc1_,_loc2_,_loc2_);
      }
      
      override public function get numPasses() : int
      {
         if(this._blurX == 0 && this._blurY == 0)
         {
            return 1;
         }
         return getNumPasses(this.totalBlurX) + getNumPasses(this.totalBlurY);
      }
      
      private function get totalBlurX() : Number
      {
         return this._blurX * Starling.contentScaleFactor;
      }
      
      private function get totalBlurY() : Number
      {
         return this._blurY * Starling.contentScaleFactor;
      }
      
      public function get blurX() : Number
      {
         return this._blurX;
      }
      
      public function set blurX(param1:Number) : void
      {
         if(this._blurX != param1)
         {
            this._blurX = Math.abs(param1);
            this.updatePadding();
         }
      }
      
      public function get blurY() : Number
      {
         return this._blurY;
      }
      
      public function set blurY(param1:Number) : void
      {
         if(this._blurY != param1)
         {
            this._blurY = Math.abs(param1);
            this.updatePadding();
         }
      }
      
      public function get quality() : Number
      {
         return this._quality;
      }
      
      public function set quality(param1:Number) : void
      {
         if(this._quality != param1)
         {
            this._quality = MathUtil.clamp(param1,0.1,1);
            this.updatePadding();
         }
      }
   }
}

import flash.display3D.Context3D;
import flash.display3D.Context3DProgramType;
import starling.rendering.FilterEffect;
import starling.rendering.Program;

class BlurEffect extends FilterEffect
{
   
   public static const HORIZONTAL:String = "horizontal";
   
   public static const VERTICAL:String = "vertical";
   
   private static const sTmpWeights:Vector.<Number> = new <Number>[0,0,0,0,0];
   
   private static const sWeights:Vector.<Number> = new <Number>[0,0,0,0];
   
   private static const sOffsets:Vector.<Number> = new <Number>[0,0,0,0];
    
   
   private var _strength:Number;
   
   private var _direction:String;
   
   private var _quality:Number;
   
   public function BlurEffect()
   {
      super();
      this._strength = 0;
      this._direction = HORIZONTAL;
      this._quality = 1;
   }
   
   override protected function createProgram() : Program
   {
      if(this._strength == 0)
      {
         return super.createProgram();
      }
      var _loc1_:String = ["m44 op, va0, vc0      ","mov v0, va1           ","add v1,  va1, vc4.xyww","sub v2,  va1, vc4.xyww","add v3,  va1, vc4.zwxx","sub v4,  va1, vc4.zwxx"].join("\n");
      var _loc2_:String = [tex("ft0","v0",0,texture),"mul ft5, ft0, fc0.xxxx       ",tex("ft1","v1",0,texture),"mul ft1, ft1, fc0.yyyy       ","add ft5, ft5, ft1            ",tex("ft2","v2",0,texture),"mul ft2, ft2, fc0.yyyy       ","add ft5, ft5, ft2            ",tex("ft3","v3",0,texture),"mul ft3, ft3, fc0.zzzz       ","add ft5, ft5, ft3            ",tex("ft4","v4",0,texture),"mul ft4, ft4, fc0.zzzz       ","add  oc, ft5, ft4            "].join("\n");
      return Program.fromSource(_loc1_,_loc2_);
   }
   
   override protected function beforeDraw(param1:Context3D) : void
   {
      super.beforeDraw(param1);
      if(this._strength)
      {
         this.updateParameters();
         param1.setProgramConstantsFromVector(Context3DProgramType.VERTEX,4,sOffsets);
         param1.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT,0,sWeights);
      }
   }
   
   private function updateParameters() : void
   {
      var _loc1_:Number = NaN;
      var _loc2_:Number = NaN;
      var _loc4_:Number = NaN;
      var _loc5_:Number = NaN;
      var _loc6_:Number = NaN;
      var _loc7_:int = 0;
      var _loc8_:Number = NaN;
      var _loc9_:Number = NaN;
      var _loc3_:Number = 1 / (this._direction == HORIZONTAL ? texture.root.nativeWidth : texture.root.nativeHeight);
      if(this._strength <= 1)
      {
         _loc4_ = this._strength * 2;
         _loc5_ = 2 * _loc4_ * _loc4_;
         _loc6_ = 1 / Math.sqrt(_loc5_ * Math.PI);
         _loc7_ = 0;
         while(_loc7_ < 5)
         {
            sTmpWeights[_loc7_] = _loc6_ * Math.exp(-_loc7_ * _loc7_ / _loc5_);
            _loc7_++;
         }
         sWeights[0] = sTmpWeights[0];
         sWeights[1] = sTmpWeights[1] + sTmpWeights[2];
         sWeights[2] = sTmpWeights[3] + sTmpWeights[4];
         _loc8_ = sWeights[0] + 2 * sWeights[1] + 2 * sWeights[2];
         _loc9_ = 1 / _loc8_;
         sWeights[0] *= _loc9_;
         sWeights[1] *= _loc9_;
         sWeights[2] *= _loc9_;
         _loc1_ = (sTmpWeights[1] + 2 * sTmpWeights[2]) / sWeights[1];
         _loc2_ = (3 * sTmpWeights[3] + 4 * sTmpWeights[4]) / sWeights[2];
      }
      else
      {
         sWeights[0] = 0.29412;
         sWeights[1] = 0.23529;
         sWeights[2] = 0.11765;
         _loc1_ = this._strength * 1.3;
         _loc2_ = this._strength * 2.3;
      }
      if(this._direction == HORIZONTAL)
      {
         sOffsets[0] = _loc1_ * _loc3_ / this._quality;
         sOffsets[1] = 0;
         sOffsets[2] = _loc2_ * _loc3_ / this._quality;
         sOffsets[3] = 0;
      }
      else
      {
         sOffsets[0] = 0;
         sOffsets[1] = _loc1_ * _loc3_ / this._quality;
         sOffsets[2] = 0;
         sOffsets[3] = _loc2_ * _loc3_ / this._quality;
      }
   }
   
   override protected function get programVariantName() : uint
   {
      return super.programVariantName | (!!this._strength ? 1 << 4 : 0);
   }
   
   public function get direction() : String
   {
      return this._direction;
   }
   
   public function set direction(param1:String) : void
   {
      this._direction = param1;
   }
   
   public function get strength() : Number
   {
      return this._strength;
   }
   
   public function set strength(param1:Number) : void
   {
      this._strength = param1;
   }
   
   public function get quality() : Number
   {
      return this._quality;
   }
   
   public function set quality(param1:Number) : void
   {
      this._quality = param1;
   }
}
