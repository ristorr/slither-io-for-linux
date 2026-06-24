package starling.display
{
   import flash.display3D.Context3DBlendFactor;
   
   public class MyBlendMode
   {
      
      private static var BlendFactors:Array = [{
         "none":[Context3DBlendFactor.ONE,Context3DBlendFactor.ZERO],
         "normal":[Context3DBlendFactor.SOURCE_ALPHA,Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA],
         "add":[Context3DBlendFactor.SOURCE_ALPHA,Context3DBlendFactor.DESTINATION_ALPHA],
         "multiply":[Context3DBlendFactor.DESTINATION_COLOR,Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA],
         "screen":[Context3DBlendFactor.SOURCE_ALPHA,Context3DBlendFactor.ONE],
         "erase":[Context3DBlendFactor.ZERO,Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA],
         "mask":[Context3DBlendFactor.ZERO,Context3DBlendFactor.SOURCE_ALPHA],
         "below":[Context3DBlendFactor.ONE_MINUS_DESTINATION_ALPHA,Context3DBlendFactor.DESTINATION_ALPHA],
         "one_source_alpha":[Context3DBlendFactor.SOURCE_COLOR,Context3DBlendFactor.DESTINATION_ALPHA],
         "source_alpha":[Context3DBlendFactor.SOURCE_ALPHA,Context3DBlendFactor.ONE],
         "overlay_glow":[Context3DBlendFactor.DESTINATION_COLOR,Context3DBlendFactor.DESTINATION_ALPHA],
         "overlay_alpha":[Context3DBlendFactor.SOURCE_COLOR,Context3DBlendFactor.DESTINATION_ALPHA],
         "overlay_dark":[Context3DBlendFactor.ONE_MINUS_DESTINATION_COLOR,Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA]
      },{
         "none":[Context3DBlendFactor.ONE,Context3DBlendFactor.ZERO],
         "normal":[Context3DBlendFactor.ONE,Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA],
         "add":[Context3DBlendFactor.ONE,Context3DBlendFactor.ONE],
         "multiply":[Context3DBlendFactor.DESTINATION_COLOR,Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA],
         "screen":[Context3DBlendFactor.ONE,Context3DBlendFactor.ONE_MINUS_SOURCE_COLOR],
         "erase":[Context3DBlendFactor.ZERO,Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA],
         "mask":[Context3DBlendFactor.ZERO,Context3DBlendFactor.SOURCE_ALPHA],
         "below":[Context3DBlendFactor.ONE_MINUS_DESTINATION_ALPHA,Context3DBlendFactor.DESTINATION_ALPHA],
         "one_source_alpha":[Context3DBlendFactor.SOURCE_COLOR,Context3DBlendFactor.DESTINATION_ALPHA],
         "source_alpha":[Context3DBlendFactor.SOURCE_ALPHA,Context3DBlendFactor.ONE],
         "overlay_glow":[Context3DBlendFactor.DESTINATION_COLOR,Context3DBlendFactor.DESTINATION_ALPHA],
         "overlay_alpha":[Context3DBlendFactor.SOURCE_COLOR,Context3DBlendFactor.DESTINATION_ALPHA],
         "overlay_dark":[Context3DBlendFactor.ONE_MINUS_DESTINATION_COLOR,Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA]
      }];
       
      
      public function MyBlendMode()
      {
         super();
      }
      
      public static function getBlendFactors(param1:String, param2:Boolean = true) : Array
      {
         var _loc3_:Object = BlendFactors[int(param2)];
         if(param1 in _loc3_)
         {
            return _loc3_[param1];
         }
         throw new ArgumentError("Invalid blend mode");
      }
   }
}
