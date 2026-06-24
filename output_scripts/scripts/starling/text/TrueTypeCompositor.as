package starling.text
{
   import flash.geom.Matrix;
   import flash.text.AntiAliasType;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import starling.display.MeshBatch;
   import starling.display.Quad;
   import starling.styles.MeshStyle;
   import starling.textures.Texture;
   import starling.utils.Align;
   import starling.utils.MathUtil;
   import starling.utils.SystemUtil;
   
   public class TrueTypeCompositor implements ITextCompositor
   {
      
      private static var sHelperMatrix:Matrix = new Matrix();
      
      private static var sHelperQuad:Quad = new Quad(100,100);
      
      private static var sNativeTextField:flash.text.TextField = new flash.text.TextField();
      
      private static var sNativeFormat:flash.text.TextFormat = new flash.text.TextFormat();
       
      
      public function TrueTypeCompositor()
      {
         super();
      }
      
      private static function autoScaleNativeTextField(param1:flash.text.TextField, param2:String, param3:Boolean) : void
      {
         var _loc4_:flash.text.TextFormat = param1.defaultTextFormat;
         var _loc5_:int = param1.width - 4;
         var _loc6_:int = param1.height - 4;
         var _loc7_:Number = Number(_loc4_.size);
         while(param1.textWidth > _loc5_ || param1.textHeight > _loc6_)
         {
            if(_loc7_ <= 4)
            {
               break;
            }
            _loc4_.size = _loc7_--;
            param1.defaultTextFormat = _loc4_;
            if(param3)
            {
               param1.htmlText = param2;
            }
            else
            {
               param1.text = param2;
            }
         }
      }
      
      private static function snapToPixels(param1:Number, param2:Number) : Number
      {
         var _loc3_:Number = NaN;
         if(param1 == 0 || param2 == 0)
         {
            return param1;
         }
         _loc3_ = 1 / param2;
         return Math.round(param1 / _loc3_) * _loc3_;
      }
      
      public function dispose() : void
      {
      }
      
      public function fillMeshBatch(param1:MeshBatch, param2:Number, param3:Number, param4:String, param5:starling.text.TextFormat, param6:TextOptions = null) : void
      {
         var textureFormat:String;
         var texture:Texture = null;
         var bitmapData:BitmapDataEx = null;
         var meshBatch:MeshBatch = param1;
         var starling.text.width:Number = param2;
         var starling.text.height:Number = param3;
         var text:String = param4;
         var format:starling.text.TextFormat = param5;
         var options:TextOptions = param6;
         if(text == null || text == "")
         {
            return;
         }
         textureFormat = options.textureFormat;
         bitmapData = this.renderText(starling.text.width,starling.text.height,text,format,options);
         texture = Texture.fromBitmapData(bitmapData,false,false,bitmapData.scale,textureFormat);
         texture.root.onRestore = function():void
         {
            bitmapData = renderText(starling.text.width,starling.text.height,text,format,options);
            texture.root.uploadBitmapData(bitmapData);
            bitmapData.dispose();
            bitmapData = null;
         };
         bitmapData.dispose();
         bitmapData = null;
         sHelperQuad.texture = texture;
         sHelperQuad.readjustSize();
         if(format.horizontalAlign == Align.LEFT)
         {
            sHelperQuad.x = 0;
         }
         else if(format.horizontalAlign == Align.CENTER)
         {
            sHelperQuad.x = (starling.text.width - texture.width) / 2;
         }
         else
         {
            sHelperQuad.x = starling.text.width - texture.width;
         }
         if(format.verticalAlign == Align.TOP)
         {
            sHelperQuad.y = 0;
         }
         else if(format.verticalAlign == Align.CENTER)
         {
            sHelperQuad.y = (starling.text.height - texture.height) / 2;
         }
         else
         {
            sHelperQuad.y = starling.text.height - texture.height;
         }
         sHelperQuad.x = snapToPixels(sHelperQuad.x,options.textureScale);
         sHelperQuad.y = snapToPixels(sHelperQuad.y,options.textureScale);
         meshBatch.addMesh(sHelperQuad);
         sHelperQuad.texture = null;
      }
      
      public function clearMeshBatch(param1:MeshBatch) : void
      {
         param1.clear();
         if(param1.texture)
         {
            param1.texture.dispose();
            param1.texture = null;
         }
      }
      
      public function getDefaultMeshStyle(param1:MeshStyle, param2:starling.text.TextFormat, param3:TextOptions) : MeshStyle
      {
         return null;
      }
      
      private function renderText(param1:Number, param2:Number, param3:String, param4:starling.text.TextFormat, param5:TextOptions) : BitmapDataEx
      {
         var _loc18_:Number = NaN;
         var _loc19_:Number = NaN;
         var _loc20_:BitmapDataEx = null;
         var _loc6_:Number = param5.textureScale;
         var _loc7_:Number = param1 * _loc6_;
         var _loc8_:Number = param2 * _loc6_;
         var _loc9_:String = param4.horizontalAlign;
         param4.toNativeFormat(sNativeFormat);
         sNativeFormat.size = Number(sNativeFormat.size) * _loc6_;
         sNativeTextField.embedFonts = SystemUtil.isEmbeddedFont(param4.font,param4.bold,param4.italic);
         sNativeTextField.styleSheet = null;
         sNativeTextField.defaultTextFormat = sNativeFormat;
         sNativeTextField.styleSheet = param5.styleSheet;
         sNativeTextField.width = _loc7_;
         sNativeTextField.height = _loc8_;
         sNativeTextField.antiAliasType = AntiAliasType.ADVANCED;
         sNativeTextField.selectable = false;
         sNativeTextField.multiline = true;
         sNativeTextField.wordWrap = param5.wordWrap;
         if(param5.isHtmlText)
         {
            sNativeTextField.htmlText = param3;
         }
         else
         {
            sNativeTextField.text = param3;
         }
         if(param5.autoScale)
         {
            autoScaleNativeTextField(sNativeTextField,param3,param5.isHtmlText);
         }
         var _loc10_:int = 1;
         var _loc11_:int = Texture.getMaxSize(param5.textureFormat);
         var _loc12_:Number = param5.padding * _loc6_;
         var _loc13_:Number = param5.padding * _loc6_;
         var _loc14_:Number = sNativeTextField.textWidth + 4;
         var _loc15_:Number = sNativeTextField.textHeight + 4;
         var _loc16_:int = Math.ceil(_loc14_) + 2 * _loc12_;
         var _loc17_:int = Math.ceil(_loc15_) + 2 * _loc13_;
         if(_loc16_ > _loc7_)
         {
            _loc12_ = MathUtil.max(0,(_loc7_ - _loc14_) / 2);
            _loc16_ = Math.ceil(_loc7_);
         }
         if(_loc17_ > _loc8_)
         {
            _loc13_ = MathUtil.max(0,(_loc8_ - _loc15_) / 2);
            _loc17_ = Math.ceil(_loc8_);
         }
         if(param5.isHtmlText)
         {
            _loc14_ = _loc16_ = _loc7_;
         }
         if(_loc16_ < _loc10_)
         {
            _loc16_ = 1;
         }
         if(_loc17_ < _loc10_)
         {
            _loc17_ = 1;
         }
         if(_loc17_ > _loc11_ || _loc16_ > _loc11_)
         {
            param5.textureScale *= _loc11_ / Math.max(_loc16_,_loc17_);
            return this.renderText(param1,param2,param3,param4,param5);
         }
         _loc18_ = -_loc12_;
         _loc19_ = -_loc13_;
         if(!param5.isHtmlText)
         {
            if(_loc9_ == Align.RIGHT)
            {
               _loc18_ = _loc7_ - _loc14_ - _loc12_;
            }
            else if(_loc9_ == Align.CENTER)
            {
               _loc18_ = (_loc7_ - _loc14_) / 2 - _loc12_;
            }
         }
         _loc20_ = new BitmapDataEx(_loc16_,_loc17_);
         sHelperMatrix.setTo(1,0,0,1,-_loc18_,-_loc19_);
         _loc20_.draw(sNativeTextField,sHelperMatrix);
         _loc20_.scale = _loc6_;
         sNativeTextField.text = "";
         return _loc20_;
      }
   }
}

import flash.display.BitmapData;

class BitmapDataEx extends BitmapData
{
    
   
   private var _scale:Number = 1;
   
   public function BitmapDataEx(param1:int, param2:int, param3:Boolean = true, param4:uint = 0)
   {
      super(param1,param2,param3,param4);
   }
   
   public function get scale() : Number
   {
      return this._scale;
   }
   
   public function set scale(param1:Number) : void
   {
      this._scale = param1;
   }
}
