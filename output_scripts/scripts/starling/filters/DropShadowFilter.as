package starling.filters
{
   import starling.rendering.Painter;
   import starling.textures.Texture;
   import starling.utils.Padding;
   
   public class DropShadowFilter extends FragmentFilter
   {
       
      
      private var _blurFilter:BlurFilter;
      
      private var _compositeFilter:CompositeFilter;
      
      private var _distance:Number;
      
      private var _angle:Number;
      
      private var _inner:Boolean;
      
      private var _knockout:Boolean;
      
      public function DropShadowFilter(param1:Number = 4, param2:Number = 0.785, param3:uint = 0, param4:Number = 0.5, param5:Number = 1, param6:Number = 0.5, param7:Boolean = false, param8:Boolean = false)
      {
         super();
         this._compositeFilter = new CompositeFilter();
         this._blurFilter = new BlurFilter(param5,param5);
         this._distance = param1;
         this._angle = param2;
         this.color = param3;
         this.alpha = param4;
         this.quality = param6;
         this.inner = param7;
         this.knockout = param8;
         this.updatePadding();
      }
      
      private static function getMode(param1:Boolean, param2:Boolean) : String
      {
         return param2 ? (param1 ? CompositeMode.INSIDE_KNOCKOUT : CompositeMode.OUTSIDE_KNOCKOUT) : (param1 ? CompositeMode.INSIDE : CompositeMode.OUTSIDE);
      }
      
      override public function dispose() : void
      {
         this._blurFilter.dispose();
         this._compositeFilter.dispose();
         super.dispose();
      }
      
      override public function process(param1:Painter, param2:IFilterHelper, param3:Texture = null, param4:Texture = null, param5:Texture = null, param6:Texture = null) : Texture
      {
         var _loc7_:Texture = this._blurFilter.process(param1,param2,param3);
         var _loc8_:Texture = this._compositeFilter.process(param1,param2,param3,_loc7_);
         param2.putTexture(_loc7_);
         return _loc8_;
      }
      
      override public function get numPasses() : int
      {
         return this._blurFilter.numPasses + this._compositeFilter.numPasses;
      }
      
      private function updatePadding() : void
      {
         var _loc1_:Number = Math.cos(this._angle) * this._distance;
         var _loc2_:Number = Math.sin(this._angle) * this._distance;
         this._compositeFilter.setOffsetAt(1,_loc1_,_loc2_);
         var _loc3_:Padding = this._blurFilter.padding;
         var _loc4_:Number = _loc3_.left;
         var _loc5_:Number = _loc3_.right;
         var _loc6_:Number = _loc3_.top;
         var _loc7_:Number = _loc3_.bottom;
         if(_loc1_ > 0)
         {
            _loc5_ += _loc1_;
         }
         else
         {
            _loc4_ -= _loc1_;
         }
         if(_loc2_ > 0)
         {
            _loc7_ += _loc2_;
         }
         else
         {
            _loc6_ -= _loc2_;
         }
         padding.setTo(_loc4_,_loc5_,_loc6_,_loc7_);
      }
      
      public function get color() : uint
      {
         return this._compositeFilter.getColorAt(1);
      }
      
      public function set color(param1:uint) : void
      {
         if(this.color != param1 || !this._compositeFilter.getReplaceColorAt(1))
         {
            this._compositeFilter.setColorAt(1,param1,true);
            setRequiresRedraw();
         }
      }
      
      public function get alpha() : Number
      {
         return this._compositeFilter.getAlphaAt(1);
      }
      
      public function set alpha(param1:Number) : void
      {
         if(this.alpha != param1)
         {
            this._compositeFilter.setAlphaAt(1,param1);
            setRequiresRedraw();
         }
      }
      
      public function get distance() : Number
      {
         return this._distance;
      }
      
      public function set distance(param1:Number) : void
      {
         if(this._distance != param1)
         {
            this._distance = param1;
            setRequiresRedraw();
            this.updatePadding();
         }
      }
      
      public function get angle() : Number
      {
         return this._angle;
      }
      
      public function set angle(param1:Number) : void
      {
         if(this._angle != param1)
         {
            this._angle = param1;
            setRequiresRedraw();
            this.updatePadding();
         }
      }
      
      public function get blur() : Number
      {
         return this._blurFilter.blurX;
      }
      
      public function set blur(param1:Number) : void
      {
         if(this.blur != param1)
         {
            this._blurFilter.blurX = this._blurFilter.blurY = param1;
            setRequiresRedraw();
            this.updatePadding();
         }
      }
      
      public function get quality() : Number
      {
         return this._blurFilter.quality;
      }
      
      public function set quality(param1:Number) : void
      {
         if(this.quality != param1)
         {
            this._blurFilter.quality = param1;
            setRequiresRedraw();
            this.updatePadding();
         }
      }
      
      public function get inner() : Boolean
      {
         return this._inner;
      }
      
      public function set inner(param1:Boolean) : void
      {
         this._inner = param1;
         this._compositeFilter.setModeAt(1,getMode(this._inner,this._knockout));
         this._compositeFilter.setInvertAlphaAt(1,this._inner);
         setRequiresRedraw();
      }
      
      public function get knockout() : Boolean
      {
         return this._knockout;
      }
      
      public function set knockout(param1:Boolean) : void
      {
         this._knockout = param1;
         this._compositeFilter.setModeAt(1,getMode(this._inner,this._knockout));
         setRequiresRedraw();
      }
   }
}
